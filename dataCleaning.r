#data cleaning for stock info

#cat('Start checking the data...\n')
#cat('loading the stockID list from the stock_list_file...\n\n')
stock_list_file <- '000300cons.csv'
stock_list <- read.csv(stock_list_file,header=T,stringsAsFactors=F,colClasses='character')[,1]
name <- NA
filename <- paste(getwd(),'/stock_info/',as.character(stockID),'.csv',sep='')
stocks_info_PE <- read.csv(filename,header=T,stringsAsFactors=F)[,'dataDate']

stock_list <- stock_list[1:10]

for (name in stock_list){
	stockID <- name
	filename <- paste(getwd(),'/stock_info/',as.character(stockID),'.csv',sep='')
	stock_info_PE <- read.csv(filename,header=T,stringsAsFactors=F)[,c('dataDate','PE')]
	naStatus <- is.na(stock_info_PE[,'PE'])
	cat('start checking the NA data...\n')
	#fill the NA with the data one day earlier
	#stock_info_PE_full <- stock_info_PE[,'PE']
	#naStatus <- is.na(stock_info_PE_full[,'PE'])
	#stock_info_PE_full[which(naStatus),]<-stock_info_PE_full[which(naStatus)-1,]
	naStatus <- is.na(stock_info_PE[,'PE'])
	stock_info_PE[which(naStatus),]<-stock_info_PE[which(naStatus)-1,]
	filename <- paste(getwd(),'/stock_info/',as.character(stockID),'_full.csv',sep='')
	write.csv(stock_info_PE,filename)
	cat(paste(sum(naStatus),' NA processed for the stock ',stockID,' !\n\n',sep=''))
	stocks_info_PE <- cbind(stocks_info_PE,stock_info_PE[,'PE'])
	names(stocks_info_PE[ncol(stocks_info_PE)]) <- stockID
}
