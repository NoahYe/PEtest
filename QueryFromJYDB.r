# This script use JuYuan Database as data source
# we limit the investment on stocks only, so we only query the data with SecuMain.SecuCategory=1

# to use this script, we need some input as below:
# 1. an array of SecuCode, represent the scope of stocks we want to include in the regression test
# 2. the startTime and endTime of the regression test
# 3. the time interval of change in position, by default is weekly
# 4. factor for the regression, e.g. PE
 
# Step 0: initiate the odbc connect myconn with the JYDB database. this part should be overwrite on MacOS
myconn <- odbcConnect("JYDB",uid='jianyu.ye',pwd='123456')
# test if database is connected
dbSecuMainTable <- sqlQuery(myconn, "select count(name) from sysobjects where xtype='U' and name = 'SecuMain'")
if (1 != dbSecuMainTable){cat("\nDatabase connection error! Process terminated!\n");stop()} else{cat("\nDatabase connected!\n");rm(dbSecuMainTable)}

# Step 1: query for the InnerCode for all the securities in the scope. The security scope is pre-defined in an .csv file

############################################
# set secuCode example to 000001
# secuCode <- '000001'
# sql <- paste("select * from JYDB.dbo.SecuMain as a where a.SecuCategory=1 and a.SecuCode= ",secuCode,sep='')
# InnerCode <- sqlQuery(myconn, sql)['Innercode']
############################################

#  Step 1.1: fetch for the stockID, e.g. 000001, 600130, from the .csv file and store in the vector SecurityID
SecurityID <- read.csv("000300cons.csv", header=T, sep=",")[,1]
SecurityID <- paste(substring("000000", 1, (6-nchar(SecurityID))),SecurityID, sep='')
SecurityID <- data.frame(SecurityID)
cat(paste("\nTotally ", length(SecurityID)," stocks included!\n", sep=''))

#  Step 1.2: query the database to match the SecurityID with the InnerCode of JYDB database
SecuMainInfo <- sqlQuery(myconn, "select * from JYDB.dbo.SecuMain as a where a.SecuCategory=1")
SecuMainInfo <- merge(SecuMainInfo, SecurityID, by.x="SecuCode", by.y='SecurityID', all.y = T)
#  Step 1.3: match the Industry code in SecuMainInfo by InnerCode
#  行业划分表 LC_ExgIndustry
#  Step 1.4: match other info with the InnerCode


# query for the array exchange date based on the startTime, endTime and position time interval
# set the baseDate example as 2014/06/03
baseDate <- '2014/06/03'

# query for the factor info, and filter out the info which published late than the baseDate 
# set factor example as PE
sql <- paste("select * from JYDB.dbo.LC_IndicesForValuation where InnerCode = ", InnerCode," order by UpdateTime")
histData <- sqlQuery(myconn, sql)
histData_updatetimeAD <- histData[histData$UpdateTime < baseDate,]

# sort to get the latest factor info
histData_enddateAD <- histData_updatetimeAD[order(histData_updatetimeAD$EndDate),][nrow(histData_updatetimeAD),]

# histData_enddateAD
         # ID InnerCode    EndDate     PE     PB
# 9 4.516e+11         3 2014-03-31 6.1415 0.8742
     # PCF     PS DividendRatio          UpdateTime
# 9 1.1185 1.9648            NA 2014-04-23 20:26:57
       # JSID
# 9 4.516e+11

# to calculate the PE factor, we need to query for the ClosePrice for the endDate 2014-03-31 and baseDate 2014/06/03
sql <- paste("select * from JYDB.dbo.QT_DailyQuote where InnerCode = 3 and TradingDay = \'",histData_enddateAD$EndDate,"\'",sep='')
tempEndDate <- sqlQuery(myconn,sql)
sql <- paste("select * from JYDB.dbo.QT_DailyQuote where InnerCode = 3 and TradingDay = \'",baseDate,"\'",sep='')
tempBaseDate <- sqlQuery(myconn,sql)

# now we get the stock 000001 PE value for the baseDate 2014/06/03 based on the PE info on endDate 2014-03-31 which published on 2014-04-23 20:26:57
PEBaseDate <- tempBaseDate$ClosePrice/tempEndDate$ClosePrice*histData_enddateAD$PE






