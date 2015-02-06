# This script use JuYuan Database as data source
# we limit the investment on stocks only, so we only query the data with SecuMain.SecuCategory=1
# some innter functions are called:
# 1. func_PESecuCodeDate(InnerCode,TradingDate)
# 
# to use this script, we need some input as below:
# 1. an array of SecuCode, represent the scope of stocks we want to include in the regression test
# 2. the startTime and endTime of the regression test
# 3. the time interval of change in position, by default is weekly
# 4. factor for the regression, e.g. PE
 
library(RODBC)
library(dplyr)
library(lubridate)
library(ggplot2)
library(lubridate)
 
source('~/GitHub/PEtest/PESecuCodeDate.R')

# Step 0: initiate the odbc connect myconn with the JYDB database. this part should be overwrite on MacOS
if (grep(pattern='Windows', Sys.getenv()['OS'], fixed=T))
{
myconn <- odbcConnect("JYDB",uid='jianyu.ye',pwd='123456')
# test if database is connected
dbSecuMainTable <- sqlQuery(myconn, "select count(name) from sysobjects where xtype='U' and name = 'SecuMain'")
if (1 != dbSecuMainTable){cat("\nDatabase connection error! Process terminated!\n");stop()} else{cat("\nDatabase connected!\n");rm(dbSecuMainTable)}
}
#if(macos){}
# else
# {
# cat("the script cannot run on the OS!\n")
# stop()
# }
# Step 1: query for the InnerCode for all the securities in the scope. The security scope is pre-defined in an .csv file

############################################
# set secuCode example to 000001
# secuCode <- '000001'
# sql <- paste("select * from JYDB.dbo.SecuMain as a where a.SecuCategory=1 and a.SecuCode= ",secuCode,sep='')
# InnerCode <- sqlQuery(myconn, sql)['Innercode']
############################################

#  Step 1.1: fetch for the stockID, e.g. 000001, 600130, from the .csv file and store in the vector SecurityID
#  SecurityID <- func_SecuCodeScope 

  
SecurityID <- read.csv("000300cons.csv", header=T, sep=",")[,1]
SecurityID <- paste(substring("000000", 1, (6-nchar(SecurityID))),SecurityID, sep='')
SecurityID <- data.frame(SecurityID)
cat(paste("\nTotally ", nrow(SecurityID)," stocks included!\n", sep=''))

#  Step 1.2: query the database to match the SecurityID with the InnerCode of JYDB database
SecuMainInfo <- sqlQuery(myconn, "select * from JYDB.dbo.SecuMain as a where a.SecuCategory=1")
SecuMainInfo <- merge(SecuMainInfo, SecurityID, by.x="SecuCode", by.y='SecurityID', all.y = T)
SecuMainInfo <- SecuMainInfo[c('SecuCode','InnerCode','CompanyCode')]
#  Step 1.3: match the Industry code in SecuMainInfo by InnerCode
#  行业划分表 LC_ExgIndustry
#  Step 1.4: match other info with the InnerCode


#  Step 2: query for the array exchange date based on the startTime, endTime and position time interval
#  Step 2.1: set the startDate example as 2014-06-03
startDate <- '2014-06-03'
#  Step 2.1: set the endDate example as current date
endDate <- as.character(Sys.Date())
#  Step 2.3: query for the position time
sql <- "select * from QT_TradingDayNew where SecuMarket = 83 and IfTradingDay = 1 and IfWeekEnd = 1 and TradingDate < GETDATE()"
tradingDate <- sqlQuery(myconn,sql)
tradingDate <- tradingDate[which(tradingDate$TradingDate > startDate & tradingDate$TradingDate < endDate),]
tradingDate <- tradingDate['TradingDate']

tradingSecuDate<-merge(SecuMainInfo,tradingDate, all=T)

#  query for the OpenPrice, ClosePrice
innerCodeList <- paste(SecuMainInfo$InnerCode,collapse = ',')
tradingDateList <- paste(as.character(tradingDate$TradingDate),collapse = "','")
tradingDateList <- paste("'",tradingDateList,"'",sep='')
sql <- paste("select * from JYDB.dbo.QT_DailyQuote where InnerCode in (", innerCodeList, ") and TradingDay in (", tradingDateList,") order by InnerCode", sep='')
tempsqlresult <- sqlQuery(myconn, sql)
tempsqlresult <- tempsqlresult[c('InnerCode','TradingDay','OpenPrice','HighPrice','LowPrice','ClosePrice','PrevClosePrice')]
names(tempsqlresult)[names(tempsqlresult)=="TradingDay"] <- "TradingDate"

tradingSecuDate <- merge(tradingSecuDate, tempsqlresult)
tradingSecuDate <- tradingSecuDate[order(tradingSecuDate$InnerCode,tradingSecuDate$TradingDate),]


#  calculate the return based on the open price and close price
#  为tradingSecuDate数据框新增一列BasePrice，默认为每个股票TradingDate第一天的ClosePrice
#tradingSecuDate$BasePrice[tradingSecuDate$InnerCode == 3] <- tradingSecuDate$OpenPrice[tradingSecuDate$InnerCode == 3 & tradingSecuDate$TradingDate == '2014-06-06']

# tradingSecuDate <- group_by(tradingSecuDate, InnerCode)
# tradingSecuDate <- mutate(tradingSecuDate, BasePrice = lag(ClosePrice))
# tradingSecuDate[is.na(tradingSecuDate['BasePrice']),]['BasePrice'] <- tradingSecuDate[is.na(tradingSecuDate['BasePrice']),]['ClosePrice']
# tradingSecuDate <- ungroup(tradingSecuDate)
# baseDate <- min(tradingSecuDate$TradingDate)

temp <- filter(tradingSecuDate, TradingDate == min(TradingDate))
temp <- select(temp, InnerCode, BasePrice = ClosePrice)
tradingSecuDate<- merge(tradingSecuDate,temp)
rm(temp)
#  为tradingSecuDate数据框新增一列Return，值为ClosePrice/BasePrice
tradingSecuDate <- mutate(tradingSecuDate,Return=ClosePrice/BasePrice)

#  为每个计算InnerCode在对应的TradingDate上计算TTM PE值
tradingSecuDate <- tradingSecuDate %>% group_by(InnerCode) %>% mutate(RealPE = func_PESecuCodeDate(InnerCode,TradingDate))
#tempPESecuCodeDate <- func_PESecuCodeDate(tempInnerCode,tempTradingDate,tempPEValue)

#  为tradingSecuDate的数据框新增一列虚拟信号数据MockPE
#tradingSecuDate <- mutate(tradingSecuDate, MockPE = ClosePrice - (LowPrice/5))


#  为tradingSecuDate的数据框新增一列Basket，记录根据每一个交易日个股的信号（PE）五等分位
tradingSecuDate <- group_by(tradingSecuDate, TradingDate)
tradingSecuDate <- mutate(tradingSecuDate, Basket = round((rank(RealPE))/(nrow(SecurityID))*5+0.49999))
tradingSecuDate <- ungroup(tradingSecuDate)

#  在每个TradingDate，计算每个五分位Basket内所有股票的平均Return
tradingSecuDate <- group_by(tradingSecuDate, TradingDate, Basket)
BasketReturnDate <- summarise(tradingSecuDate, BasketReturn = mean(Return))
tradingSecuDate <- ungroup(tradingSecuDate)

temp1 <- BasketReturnDate %>% filter(Basket==1) %>% select(TradingDate, Basket1Return=BasketReturn)
temp2 <- BasketReturnDate %>% filter(Basket==2) %>% select(TradingDate, Basket2Return=BasketReturn)
temp3 <- BasketReturnDate %>% filter(Basket==3) %>% select(TradingDate, Basket3Return=BasketReturn)
temp4 <- BasketReturnDate %>% filter(Basket==4) %>% select(TradingDate, Basket4Return=BasketReturn)
temp5 <- BasketReturnDate %>% filter(Basket==5) %>% select(TradingDate, Basket5Return=BasketReturn)
temp <- temp1 %>% merge(temp2) %>% merge(temp3) %>% merge(temp4) %>% merge(temp5)

rm(temp1, temp2, temp3, temp4,temp5)

fiveQuantileGraph <- ggplot(temp)+
geom_line(aes(x=TradingDate,y=Basket1Return),color = 'red', size = 1)+
geom_line(aes(x=TradingDate,y=Basket2Return),color = 'black',size=1)+
geom_line(aes(x=TradingDate,y=Basket3Return),color = 'yellow',size=1)+
geom_line(aes(x=TradingDate,y=Basket4Return),color = 'orange',size=1)+
geom_line(aes(x=TradingDate,y=Basket5Return),color = 'green',size=1)

print(fiveQuantileGraph)

cat('\nDone!\n')






