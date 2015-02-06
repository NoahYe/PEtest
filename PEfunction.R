# the function input requires: InnerCode, TradingDate
# select the in PE in LC_IndicesForValuation
# some innter functions are called:
#   1. func_mostRecentTradingDate(EndDate) in MostRecentTradingDate.R
#   2. func_BaseClosePrice <- function(InnerCode,TradingDateList)
# it return the base TTM PE value for the given InnerCode
func_baseTTMPEValue <- function(InnerCode,TradingDate){
  require('dplyr')
  require('RODBC')
  
  if (!exists('myconn')){
    myconn <- odbcConnect("JYDB",uid='jianyu.ye',pwd='123456')
  }
  ####################tempInnerCode is the test value for InnerCode
  tempInnerCode <- InnerCode
  tempInnerCode <- 3
  ####################
  
  #  根据InnerCode索引CompanyCode，在LC_IndicesForValuation表中查询各个EndDate对应的TTM PE值
  tempCompanyCode <- filter(SecuMainInfo, InnerCode == tempInnerCode) %>% select(CompanyCode)
  sql <- paste("select a.InnerCode,b.CompanyCode,b.InfoPublDate,b.Mark,a.EndDate,a.PE,b.EPS from (LC_IndicesForValuation as a right join LC_MainDataNew as b on a.EndDate = b.EndDate) where a.InnerCode = ", tempInnerCode, " and b.CompanyCode = ", tempCompanyCode, " order by a.EndDate, b.InfoPublDate;", sep='')
  tempPEValue <- sqlQuery(myconn, sql)
  
  # 添加一栏MostRecentTradingDate,按照最近交易日值索引当日的ClosePrice,忽略NA行
  tempPEValue <- tempPEValue %>% mutate(MostRecentTradingDate = as.character(as.POSIXlt(func_mostRecentTradingDate(EndDate),origin="1970-01-01",tz ="Asia/Taipei")))
  tempPEValue <- na.omit(tempPEValue)
  #tempEndDayList <- paste(tempPEValue$EndDate, collapse="','") %>% paste("'",.,"'",sep='')
  #sql <- paste("select * from QT_DailyQuote as a where InnerCode = 3 and TradingDay in (",tempEndDayList,")", sep='')
  tempBaseClosePrice <- func_BaseClosePrice(tempInnerCode,tempPEValue$MostRecentTradingDate)
  #temp <- tempBaseClosePrice %>% transmute(MostRecentTradingDate = as.character(TradingDay),ClosePrice)
  tempPEValue <- merge(tempPEValue,tempBaseClosePrice) %>% filter(TradingDay == MostRecentTradingDate) %>% select(-(TradingDay))
  print(tempPEValue)
  
  return(tempPEValue)
  
  tempPESecuCodeDate <- func_PESecuCodeDate(tempInnerCode,tempTradingDate,tempPEValue)

}