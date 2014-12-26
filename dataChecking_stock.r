#data cleaning for stock info

#check if NA in PE
cat('Start checking the data...\n')
cat('loading the stockID list from the stock_list_file...\n\n')
stock_list_file <- '000300cons.csv'
stock_list <- read.csv(stock_list_file,header=T,stringsAsFactors=F,colClasses='character')[,1]
total_naNum <- 0
naStatus <- NA
name <- NA
# stock_list <- stock_list[1:10]

for(name in stock_list){
	stockID <- name 
	filename <- paste(getwd(),'/stock_info/',as.character(stockID),'.csv',sep='')
	stock_info_PE <- read.csv(filename,header=T,stringsAsFactors=F,)[,c('dataDate','PE')]
	naStatus <- is.na(stock_info_PE[,'PE'])
	total_naNum <- total_naNum + sum(naStatus)
	missing_data <- stock_info_PE[naStatus,]
	cat('There are ',sum(naStatus),' NA value in PE for the stock ',stockID,'\n',
	'missing the data in ',paste(as.character(missing_data['dataDate']),sep=' '),'\n\n',sep='')
}

cat('There are totally ',total_naNum,' NA value in PE for all stocks \n',sep='')