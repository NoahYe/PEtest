func_BaseClosePrice <- function(InnerCode,TradingDateList){
  tempTradingDateString <- TradingDateList %>% paste(collapse ="','") %>% paste("'",.,"'",sep='')
  sql <- paste("select a.TradingDay,a.ClosePrice from QT_DailyQuote as a where a.InnerCode = ",InnerCode," and a.TradingDay in (",tempTradingDateString,") order by a.TradingDay ", sep='')
  
  return(sqlQuery(myconn,sql))
}