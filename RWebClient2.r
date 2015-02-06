# send a http request to the web server using R httprequest package
require('httpRequest')
require('RCurl')

# tempHttpResponse <- getToHost('www.baidu.com')
# print(tempHttpResponse)

port <- 80
# tempHttpResponse <- getToHost("www.molgen.mpg.de",
       # "/~wolski/test.php4?test=test1&test2=test2&test3=3",
       # "www.test.pl", port=port)
	   
# tempHttpResponse <- getToHost("www.xy-inv.com",
	# "/enterprises/about_us",
	# "www.baidu.com",
	# port=port)
	
tempHttpResponse <- getToHost("",
	"/enterprises/about_us",
	"www.baidu.com",
	port=port)
	
print(tempHttpResponse)