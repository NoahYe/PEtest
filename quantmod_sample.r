require(quantmod)
# https://www.google.com/finance?q=NASDAQ
# learn the symbol of different companies

# Dow Jones Industrial average
getSymbols("^DJI", from="2011-09-01", to='2011-11-01')
dji = Cl(DJI["/2011"]) # only the close price

# S&P 500(INDEXSP:.INX)
# refer to: http://statmath.wu.ac.at/~hornik/QFS1/quantmod-vignette.pdf
sp500 <- new.env()
getSymbols("^GSPC", env = sp500, src = "yahoo", from="2011-09-01", to='2011-11-01')
GSPC <- sp500$GSPC
SPC <- GSPC$GSPC.Close  # plot(SPC)

nasdaq<- new.env() 
getSymbols("^NDX", env = nasdaq, src = "yahoo", from="2011-09-01", to='2011-11-01')
NDX<-nasdaq$NDX
ndx<-NDX$NDX.Close

sum<-as.data.frame(cbind(dji, SPC, ndx))
write.csv(sum, "D:/github/Data-Mining-With-R/quantmod/aggregate_stock_price.csv")