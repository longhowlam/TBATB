library(rvest)
library(lubridate)
library(tibble)
library(dplyr)

# using rvest to scrape 15 years of Bold and Beatiful recaps 
# see http://soapcentral.com/bb/recaps/index.php

yearstartdates = ymd(030106, 040105, 050103, 060102, 070101, 080107, 090105, 100104, 110103, 120102, 130107, 140106, 150105, 160104)

scrapeBByear = function(start){
  tmpout = NULL
  for(i in 1:52)
  {
    
    dstring = format(start, format="%y%m%d")  
    link = paste0("http://soapcentral.com/bb/recaps/", year(start), "/", dstring, ".php")
    print(link)
    out = read_html(link)
    recaps = html_nodes(out, xpath = '//div[@id="news_article"]')  %>% html_text()
    temp = tibble(recaps = recaps, date = start)
    tmpout = bind_rows(tmpout, temp)
    start = start + 7
  }
  tmpout
}

BBrecaps = purrr::map_dfr(yearstartdates, scrapeBByear)


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
  BBrecaps,
  outrecaps2017
)

saveRDS(AllBB , "data/AllBB.RDs")
