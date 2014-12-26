#API of datayes

require(RCurl)

getdata <- function(url){
    http <- paste(base_url,url,sep = "")
    if(gregexpr(".csv?", url)>0)
        return (getURL(http, httpheader=httpheader, ssl.verifypeer = FALSE,.encoding="utf8"))
    return (getURL(http, httpheader=httpheader, ssl.verifypeer = FALSE))
}
