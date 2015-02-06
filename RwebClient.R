# R as a web Client
# Executing this script will update the net value of the fund by sent a POST request to the www.xy-inv.com
# the Rscript.exe path in the FILE C:\Program Files\R\R-3.1.2\bin
# to run the script on FILE, run command the in cmd:
#
# "C:\Program Files\R\R-3.1.2\bin\Rscript.exe" C:\Users\jianyu.ye\Documents\NetValueDailyUpdate\RWebClient.R
#

require(RCurl)
require(dplyr)

originNetValue <- 55400460

# testheader <- c("Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
#                 "Accept-Encoding:identity",
#                 "Accept-Language:zh-CN,zh;q=0.8",
#                 "Cache-Control:max-age=0",
#                 "Connection:keep-alive",
#                 "DNT:1",
#                 "Host:www.xy-inv.com",
#                 "User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"
#                 )

paste("This script is about to update the net fund value for", format(Sys.Date()),"\n")%>% cat()

# Step 1. saving the daily nav record under D:/NAVDailyUpdate
cat("\n\n\nStep 1. saving the daily nav record\n")
setwd("D:/NAVDailyUpdate")
dir.create(as.character(Sys.Date()))  
file.copy(c('futures.csv','stock.csv'),Sys.Date()%>%as.character())
Sys.sleep(2)

# read daily stock and futures info from csv files
cat("\nStep 2. read daily info from csv files\n")
dailystockinfo <- read.csv(paste("./",Sys.Date()%>%as.character(),'/stock.csv',sep=''),stringsAsFactors=F,header=T)
dailystockvalue <- dailystockinfo[1,'净资产']
dailyfuturesinfo <- read.csv(paste("./",Sys.Date()%>%as.character(),'/futures.csv',sep=''),stringsAsFactors=F,header=T)
dailyfuturesvalue <- dailyfuturesinfo[1,'动态权益']
Sys.sleep(2)

# calculate for the nav
cat("\nStep 3. calculate for the nav\n")
HuashanNAV <- (dailystockvalue + dailyfuturesvalue) / originNetValue
Sys.sleep(2)

# acquire the access token for http POST request
cat("\nStep 4. acquire the access token for http POST request\n")
Sys.sleep(2)

# send out the http POST request to update the NAV 
cat("\nStep 5. send out the http POST request to update the NAV\n")
testheader <- c("Accept-Language:zh-CN,zh;q=0.8",
  "User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36",
  "Connection:keep-alive")
tempResponse <- getURL("www.xy-inv.com",httpheader=testheader,verbose=T)
Sys.sleep(2)

cat("\nnet fund value successfully updated, exit after 10s\n")
Sys.sleep(10)
