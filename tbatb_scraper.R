library(rvest)
library(lubridate)
library(tibble)
library(dplyr)

# see http://soapcentral.com/bb/recaps/index.php



start = ymd(100104)
outrecaps2010 = NULL

for(i in 1:52)
{
  
  dstring = format(start, format="%y%m%d")  
  link = paste0("http://soapcentral.com/bb/recaps/2010/", dstring, ".php")
  print(link)
  out = read_html(link)
  recaps = html_nodes(out, xpath = '//div[@id="news_article"]')  %>% html_text()
  temp = tibble(recaps=recaps, date = start)
  outrecaps2010 = bind_rows(outrecaps2010, temp)
  start = start + 7
}




start = ymd(110103)
outrecaps2011 = NULL

for(i in 1:52)
{
  
  dstring = format(start, format="%y%m%d")  
  link = paste0("http://soapcentral.com/bb/recaps/2011/", dstring, ".php")
  print(link)
  out = read_html(link)
  recaps = html_nodes(out, xpath = '//div[@id="news_article"]')  %>% html_text()
  temp = tibble(recaps=recaps, date = start)
  outrecaps2011 = bind_rows(outrecaps2011, temp)
  start = start + 7
}



start = ymd(120102)
outrecaps2012 = NULL

for(i in 1:52)
{
  
  dstring = format(start, format="%y%m%d")  
  link = paste0("http://soapcentral.com/bb/recaps/2012/", dstring, ".php")
  print(link)
  out = read_html(link)
  recaps = html_nodes(out, xpath = '//div[@id="news_article"]')  %>% html_text()
  temp = tibble(recaps=recaps, date = start)
  outrecaps2012 = bind_rows(outrecaps2012, temp)
  start = start + 7
}



start = ymd(130107)
outrecaps2013 = NULL

for(i in 1:52)
{
  
  dstring = format(start, format="%y%m%d")  
  link = paste0("http://soapcentral.com/bb/recaps/2013/", dstring, ".php")
  print(link)
  out = read_html(link)
  recaps = html_nodes(out, xpath = '//div[@id="news_article"]')  %>% html_text()
  temp = tibble(recaps=recaps, date = start)
  outrecaps2013 = bind_rows(outrecaps2013, temp)
  start = start + 7
}


start = ymd(140106)
outrecaps2014 = NULL

for(i in 1:52)
{
  
  dstring = format(start, format="%y%m%d")  
  link = paste0("http://soapcentral.com/bb/recaps/2014/", dstring, ".php")
  print(link)
  out = read_html(link)
  recaps = html_nodes(out, xpath = '//div[@id="news_article"]')  %>% html_text()
  temp = tibble(recaps=recaps, date = start)
  outrecaps2014 = bind_rows(outrecaps2014, temp)
  start = start + 7
}



start = ymd(150105)
outrecaps2015 = NULL

for(i in 1:52)
{
  
  dstring = format(start, format="%y%m%d")  
  link = paste0("http://soapcentral.com/bb/recaps/2015/", dstring, ".php")
  print(link)
  out = read_html(link)
  recaps = html_nodes(out, xpath = '//div[@id="news_article"]')  %>% html_text()
  temp = tibble(recaps=recaps, date = start)
  outrecaps2015 = bind_rows(outrecaps2015, temp)
  start = start + 7
}


start = ymd(160104)
outrecaps2016 = NULL

for(i in 1:52)
{
 
  dstring = format(start, format="%y%m%d")  
  link = paste0("http://soapcentral.com/bb/recaps/2016/", dstring, ".php")
  print(link)
  out = read_html(link)
  recaps = html_nodes(out, xpath = '//div[@id="news_article"]')  %>% html_text()
  temp = tibble(recaps=recaps, date = start)
  outrecaps2016 = bind_rows(outrecaps2016, temp)
  start = start + 7
}

start = ymd(170102)
outrecaps2017 = NULL

for(i in 1:42)
{
  
  dstring = format(start, format="%y%m%d")  
  link = paste0("http://soapcentral.com/bb/recaps/2017/", dstring, ".php")
  print(link)
  out = read_html(link)
  recaps = html_nodes(out, xpath = '//div[@id="news_article"]')  %>% html_text()
  temp = tibble(recaps=recaps, date = start)
  outrecaps2017 = bind_rows(outrecaps2017, temp)
  start = start + 7
}


AllBB = bind_rows(
  outrecaps2010,
  outrecaps2011,
  outrecaps2012,
  outrecaps2013,
  outrecaps2014,
  outrecaps2015,
  outrecaps2016,
  outrecaps2017
)

saveRDS(AllBB , "data/AllBB.RDs")
