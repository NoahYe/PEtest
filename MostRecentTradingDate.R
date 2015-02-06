func_mostRecentTradingDate <- function(EndDate){
  #在QT_TradingDayNew表中查询与所传入向量参数EndDate最接近的历史可交易日期,返回对应的历史可交易日期向量
  MostRecentTradingDate <- NULL
  for (i in 1:length(EndDate)){
    sql <- paste("select top 1 TradingDate from QT_TradingDayNew as a where a.SecuMarket = 83 and a.IfTradingDay = 1 and a.TradingDate <= '", EndDate[i], "' order by a.TradingDate desc", sep='')
    # MostRecentTradingDate <- sqlQuery(myconn,sql)
    MostRecentTradingDate[i] <- sqlQuery(myconn,sql)[1,1]
  }
  MostResentTradingDate <- (as.numeric(MostRecentTradingDate))
  # print(MostResentTradingDate)
  return(MostResentTradingDate)
}