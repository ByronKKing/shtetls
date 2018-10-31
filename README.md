
# A Data-Driven Look at Shtetl Life

This repo details my attempt to collect data -- particularly population data -- on life in shtetls in Eastern Europe. I could not find a great source of information on shtetl populations in Germany and Eastern Europe, but there are some great sources on the web with data on Jewish life. The issue is that this information is widely dispersed, so I had to hop across a different sources to gather this data.

The three online sources I found with the widest variety of information on shtetls are here:

1) Jewish Record Indexing (JRI): https://www.jri-poland.org/index.htm
2) JewishGen: https://www.jewishgen.org/
3) Virtual Shtetl: https://sztetl.org.pl/pl 

I use the first two sites to gather the population information I was looking for. These two sources had data in shtetls in Germany, Poland and Ukraine.

There are a number of components to this repo:

## 1) A Python script that gathers the information, **scrape_towns.py**

This script gathers information from the first two sources mentioned above. The Jewish Record Indexing has a large list of shtetls here: https://www.jri-poland.org/town/index.htm. This site has for each town its latitude and longitude, a few different maps, as well as their province and administrative region. What I'm really after, however, is the USBGN for each town. USBGN stands for United States Board on Geographic Names, and in this case is essentially an id for each shtetl. The script goes to each town's page (here for example: https://www.jri-poland.org/town/aleksandrow_lod.htm) and gathers its USBGN.

On the JewishGen site, there also exists information on each shtetl. Each town has its own webpage, which includes my coveted population figure. I noticed that each town has a USBGN appended to its url. I cannot gather information directly from its site because of a paywall, but my workaround is to append the USBGN I gathered from the JRI site to the url (for example here: https://www.jewishgen.org/Communities/community.php?usbgn=-492271). I loop over each shtetl's page and gather the population figure for each, and then write this info to a csv.

## 2) A Jupyter notebook that analyzes the data, **shtetl_analysis.ipynb**

I analyze the data here. The notebook renders in Github, so feel free to follow the analysis. The first part of the workbook is formatting the data, especially the population column, which is very messy.

## 3) A small Shiny app I use in a blog post to plot the data, **shiny_map.R**

My idea was to create an app so that the user could get a visual and quantitate sense of how big the Jewish population was in a particular area at different times. You can find the blog post here: **here**

## 4) An R script I use to create a few other maps, **plot_map.R**

I first tried to generate a map using RPlotly, whose functionality I much prefer to ggplot2. However, their mapping feature lacks a lot of documentation and is harder to use. I may revisit this in the future.

## 5) A folder with the data I compiled, as well as various map templates for the shiny app, **data/**

The original data that I scraped is in the all_towns.csv, whereas the processed data (the result of the first part of the shtetl_analysis.ipynb workbook) exists in the additional_shtetl_data.csv. The various map templates that I use for the shiny app also reside here.




