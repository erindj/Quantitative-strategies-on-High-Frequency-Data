# setting the working directory if needed
setwd("C:\\Users\\erind\\Desktop\\drive-download-20211202T141140Z-001")

# lets load needed packages
library(xts)
library(quantmod)
library(tseries) 
library(chron)
library(TTR)
library(caTools)
library(lubridate)
library(scales)
library(ggplot2)
library(RColorBrewer)
library(kableExtra) # for even more nicely looking tables in html files


# lets change the LC_TIME option to English
Sys.setlocale("LC_TIME", "en_US")

# loading additional functions
# created by the lecturer

source("https://raw.githubusercontent.com/ptwojcik/HFD/master/function_mySR.R")
source("https://raw.githubusercontent.com/ptwojcik/HFD/master/function_positionVB_new.R")

# lets define the system time zone as America/New_York (used in the data)
Sys.setenv(TZ = 'America/New_York')


for (selected_quarter in c( "2019_Q1","2019_Q2","2019_Q3", "2019_Q4", 
                            "2020_Q1","2020_Q2","2020_Q3","2020_Q4", 
                            "2021_Q1", "2021_Q2","2021_Q3","2021_Q4")) {
  
  message(selected_quarter)
  
  # loading the data for a selected quarter from a subdirectory "data""
  
  filename_ <- paste0("data/data1_", selected_quarter, ".RData")
  
  load(filename_)
  
  data.group1 <- get(paste0("data1_", selected_quarter))
  
  times_ <- substr(index(data.group1), 12, 19)
  
  # lets change the LC_TIME option to English
  
  Sys.setlocale("LC_TIME", "en_US")
  
  # lets create an xts object "pos_flat" 
  # = 1 if position has to be = 0 
  # = 0 otherwise
  
  # first we fill it with 0s
  
  data.group1$pos_flat <- xts(rep(0, nrow(data.group1)), 
                              index(data.group1))
  
  
  # lets apply the remaining assumptions
  # - exit all positions 20 minutes before the session end, i.e. at 15:45
  # - do not trade within the first 20 minutes of stocks quotations (until 09:50)
  
  data.group1$pos_flatbreaks[times(times_) <= times("09:50:00") | 
                              times(times_) > times("15:45:00")] <- 1
  
  # we also need to add 1s for weekends (Fri, 17:00 - Sun, 18:00)
  # lets save the day of the week using wday() function
  # from the lubridate package (1=Sun, 2=Mon, 3=Tue,...,7=Sat)
  
  dweek_ <- wday(data.group1)
  
  # we have all weekdays in the data !!!
  
  # lets create a vector of times in a character format
  
  data.group1$pos_flatbreaks[(dweek_ == 6 & times(times_) > times("17:00:00")) |   # end of Friday,time after 17:00
                         (dweek_ == 7) |                                      # whole Saturday
                         (dweek_ == 1 & times(times_) <= times("18:00:00")),] <- 1 # beginning of Sunday,time before 18:00
  
  
  #volatility breakout model
  
  # as a strategy signal we use some fastEMA
  # and breakouts are slowEMA+/-m*std
  
  # sample parameters
  
  signalEMA <- 20
  slowEMA <- 90
  volat.sd <- 60
  m_ <- 2
  
  # save time index for the data processed
  # (not to generate it in every iteration of the loop)
  
  data.group1$index_ <- index(data.group1)
  
  # here calculation on coredata() makes a difference
  
  # position for momentum strategy for selected parameters
  
  data.group1$pos.mom <- positionVB_new(signal = EMA(na.locf(data.group1$SP, na.rm = FALSE),#price or fast moving average
                                                     signalEMA),
                                        lower = EMA(na.locf(data.group1$SP, na.rm = FALSE), 
                                                    slowEMA) - 
                                          m_ * runsd(na.locf(data.group1$SP, na.rm = FALSE), #multiplier * running standard deviation
                                                     volat.sd, 
                                                     endrule = "NA", 
                                                     align = "right"),
                                        upper = EMA(na.locf(data.group1$SP, na.rm = FALSE), 
                                                    slowEMA) +
                                          m_ * runsd(na.locf(data.group1$SP, na.rm = FALSE),
                                                     volat.sd, 
                                                     endrule = "NA", 
                                                     align = "right"),
                                        pos_flat = data.group1$pos_flat,
                                        strategy = "mom") # important !!!
  
  # here calculation on coredata() makes a difference
  data.group1$signalEMA <- EMA(na.locf(data.group1$SP, na.rm = FALSE), 
                                      signalEMA)
  data.group1$slowEMA <- EMA(na.locf(data.group1$SP, na.rm = FALSE), 
                                    slowEMA)
  data.group1$volat.sd <- runsd(na.locf(data.group1$SP, na.rm = FALSE),
                                       volat.sd, 
                                       endrule = "NA", 
                                       align = "right")
  
  # put missing values whenever the original price is missing
  data.group1$signalEMA[is.na(data.group1$SP)] <- NA
  data.group1$slowEMA[is.na(data.group1$SP)] <- NA
  data.group1$volat.sd[is.na(data.group1$SP)] <- NA
  
  # position for momentum strategy
  data.group1$pos.mom <- positionVB_new(signal = data.group1$signalEMA,
                                        lower = data.group1$slowEMA - m_ * data.group1$volat.sd,
                                        upper = data.group1$slowEMA + m_ * data.group1$volat.sd,
                                        pos_flat = coredata(data.group1$pos_flat),
                                        strategy = "mom" # important !!! mom-moment
  )
  
  data.group1$pos.mr <-(-data.group1$pos.mom)
  
  # gross pnl
  data.group1$pnl.gross.mom <- ifelse(is.na(data.group1$pos.mom * diff.xts(data.group1$SP)),
                                      0, data.group1$pos.mom * diff.xts(data.group1$SP) * 50 # point value for SP
  )
  data.group1$pnl.gross.mr <- (-data.group1$pnl.gross.mom)
  
  # nr of transactions - the same for mom and mr
  data.group1$ntrans <- abs(diff.xts(data.group1$pos.mom))
  data.group1$ntrans[1] <- 0
  
  # net pnl
  data.group1$pnl.net.mom <- data.group1$pnl.gross.mom - data.group1$ntrans * 10 # 5$ per transaction of SP
  data.group1$pnl.net.mr <- data.group1$pnl.gross.mr - data.group1$ntrans * 10 # 5$ per transaction of SP
  
  # aggregate to daily
  ends_ <- endpoints(data.group1, "days")
  
  data.group1$pnl.gross.mr.d <- period.apply(data.group1$pnl.gross.mr, 
                                             INDEX=ends_, 
                                             FUN = function(x) sum(x, na.rm = TRUE))
  data.group1$pnl.net.mr.d <- period.apply(data.group1$pnl.net.mr, 
                                           INDEX = ends_, 
                                           FUN = function(x) sum(x, na.rm = TRUE))
  data.group1$ntrans.d <- period.apply(data.group1$ntrans,
                                       INDEX = ends_, 
                                       FUN = function(x) sum(x, na.rm = TRUE))
  
  # calculate summary measurements
  gross.SR.mr <- mySR(data.group1$pnl.gross.mr.d, 
                      scale = 252)
  
  net.SR.mr <- mySR(data.group1$pnl.net.mr.d, 
                    scale = 252)
  
  gross.PnL.mr <- sum(data.group1$pnl.gross.mr.d, 
                      na.rm = TRUE)
  
  net.PnL.mr <- sum(data.group1$pnl.net.mr.d, 
                    na.rm = TRUE)
  
  days_ <- data.group1$index_[ends_]
  av.ntrans <- mean(data.group1$ntrans.d[wday(data.group1$ntrans.d) != 7],
                          na.rm = TRUE) 
  
  # stat
  stat = (net.SR.mr - 0.5) * log(abs(net.PnL.mr/1000))
  
  # collecting all statistics for a particular quarter
  quarter_stats <- data.frame(quarter = selected_quarter,
                              assets.group = 1,
                              gross.SR.mr,
                              net.SR.mr,
                              av.ntrans,
                              gross.PnL.mr,
                              net.PnL.mr,
                              stat,
                              stringsAsFactors = FALSE
  )
  
  
  # collect summaries for all quarters
  if(!exists("quarter_stats.all.group1")) quarter_stats.all.group1 <- quarter_stats else
    quarter_stats.all.group1 <- rbind(quarter_stats.all.group1, quarter_stats)
  
  # create a plot of gros and net pnl and save it to png file
  
  png(filename = paste0("pnl_group1_", selected_quarter, ".png"),
      width = 1000, height = 600)
  print( # when plotting in a loop you have to use print()
    plot(cbind(cumsum(data.group1$pnl.gross.mr),
               cumsum(data.group1$pnl.net.mr)),
         multi.panel = FALSE,
         main = paste0("Gross and net PnL for asset group 1 \n quarter ", selected_quarter), 
         col = c("#377EB8", "#E41A1C"),
         major.ticks = "weeks", 
         grid.ticks.on = "weeks",
         grid.ticks.lty = 3,
         legend.loc = "topleft",
         cex = 1)
  )
  dev.off()
  
  rm(data.group1, end_, gross.SR.mr, net.SR.mr, av.daily.ntrans,
     gross.PnL.mr, net.PnL.mr, stat, quarter_stats, data.group1.d)
  
  gc()
  
  
} # end of the loop
     

write.csv(quarter_stats.all.group1, 
          "quarter_stats.all.group1.csv",
          row.names = FALSE)