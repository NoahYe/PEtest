#the function input requires: InnerCode, TradingDate
#the function will return the PE of the InnerCode stock on TradingDate based on the given BasePE
# some innter functions are called:
# 1. func_baseTTMPEValue <- function(InnerCode,TradingDate)

func_PESecuCodeDate <- function(InnerCode,TradingDate){
  
  if (!exists('myconn')){
    myconn <- odbcConnect("JYDB",uid='jianyu.ye',pwd='123456')
  } 
  InnerCode <- InnerCode[1]
  ####
  #TradingDate <- tempTradingDate$TradingDate
  #InnerCode <- 3
  ####
  #  Step1. get the base PE for the given InnerCode
  tempBasePE <- func_baseTTMPEValue(InnerCode,TradingDate)
  
  #  Step2. get the PrevClosePrice for the given TradingDate
  tempTradingDateList <- TradingDate %>% paste("'",.,"'",collapse=",",sep='')
  sql <- paste("select a.InnerCode, a.TradingDay, a.ClosePrice, a.PrevClosePrice from QT_DailyQuote as a where InnerCode = ", InnerCode, " and TradingDay in (",tempTradingDateList,") order by TradingDay",sep='')
  tempPrevClosePrice <- sqlQuery(myconn,sql)
  
  #  Step3. calculate the PE on TradingDate
  temp <- merge(tempPrevClosePrice,tempBasePE) %>% filter(TradingDay > InfoPublDate) %>% group_by(TradingDay) %>% arrange(desc(EndDate),Mark) %>% slice(1)
  temp <- temp %>% mutate(PEOnTradingDate = PE / BaseClosePrice * PrevClosePrice)
  
  return(temp$PEOnTradingDate)
}  
