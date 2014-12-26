func_renamestock <- function(stock_row){
	stock_row[5] <- stock_row[1]
	while(nchar(stock_row[5])<6){
		stock_row[5] <- paste('0',stock_row[5],sep='')
	}
	stock_row[5]<-as.character(stock_row[5])
	if(stock_row[4]=='Shenzhen'){
		stock_row[5] <- paste('sz',stock_row[5],sep='')
	}else if (stock_row[4]=='Shanghai'){
		stock_row[5] <- paste('sh',stock_row[5],sep='')
	}
  return (stock_row)
}
