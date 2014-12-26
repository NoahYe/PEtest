#query factors from the stock list
#load stockID list from the stock_list_file
cat('loading the stockID list from the stock_list_file...\n')
stock_list_file <- '000300cons.csv'
stock_list <- read.csv(stock_list_file,header=T,stringsAsFactors=F,colClasses='character')[,1]

startDate <- '20140101'
endDate <- '20141221'
field <- ''
callback <- ''

stock_list <- stock_list[259:300]
cat('Start download...\n')
for(name in stock_list){
	stockID <- name 
	source('query_datayes.r')
}

cat('\n\nAll stocks data downloaded!\n')