# example: 
# cntrade(c('600000', '000008'), path ='D:/stockprice', start = 20010104, end = 20140124)

cntrade <- function(tickers, path = "", start = 20010104, end = "") {

	address <- "http://quotes.money.163.com/service/chddata.html"
	#field <- "&fields=TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP"

	if (path == "") {
		path <- getwd()
	}

	if (!file.exists(path)) {
		dir.create(path)
	}

	if (substr(path, nchar(path), nchar(path)) != "/") {
		path <- paste(path, "/", sep = "")
	}

	if (end == "") {
		year <- substr(Sys.time(), 1, 4)
		month <- substr(Sys.time(), 6, 7)
		day <- substr(Sys.time(), 9, 10)
		end <- paste(year, month, day, sep = "")
	}

	count <- 0
	tickers <- as.character(tickers)
	for (name in tickers) {
		while (nchar(name) < 6) {
		name <- paste("0", name, sep = "")
	}

	if (nchar(name) > 6) {
		warning(paste("invalid stock code: ", name, sep = ""))
		next
	}

	if (as.numeric(name) > 600000) {
		url <- paste(address, "?code=0", name, "&start=", start, "&end=", end, field, sep = "")
	} else {
		url <- paste(address, "?code=1", name, "&start=", start, "&end=", end, field, sep = "")
	}
	destfile <- paste(path, name, ".csv", sep = "")
	download.file(url, destfile, quiet = TRUE)
	
	testifnull <- read.csv(destfile,header=T)
	while(nrow(testifnull)==0){
		download.file(url, destfile, quiet = TRUE)
	}
	
	count <- count + 1
	}

	if (count == 0) {
		cat("No File Downloaded!\n")
	} else {
		cat("Data Downloaded Completed!\n")
		cat(paste("Totally", count, "Files Downloaded\n", sep = " "))
	}
	
}

#cntrade(c('600000', '000001', '600810'), path = "d:\temp", start = 19990101, end = 20121231)
#cntrade(c(600000, 000001, 600810))
#cntrade('000002', start = 19990101)
#cntrade(000002, end = 19990101)
#cntrade(c(2, 16))