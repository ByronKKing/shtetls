library("plotly")
library("maptools")
library("ggmap")

setwd("~/shtetls/")

df = read.csv("./data/additional_shtetl_data.csv",stringsAsFactors = FALSE)

plotdf1 = df[!(is.na(df$pop1)),]

plotdf1 = head(plotdf1,50)

## create first pass through plotly map

g = list(
  scope = 'europe',
  projection = list(type = 'natural earth',scale = 5),
  showland = TRUE,
  landcolor = toRGB("gray85"),
  subunitwidth = 1,
  countrywidth = 1,
  subunitcolor = toRGB("white"),
  countrycolor = toRGB("white"),
  center = list(lon=mean(plotdf1$google_long),lat=mean(plotdf1$google_lat))
)

p = plot_geo(plotdf1, locationmode = 'country names', sizes = c(1, 250)) %>%
  add_markers(
    x = ~google_long, y = ~google_lat, size = ~pop1, color = ~region,
    hoverinfo = "text",
    text = ~paste(plotdf1$name,", Population: ",plotdf1$pop1,sep = " ")
  ) %>%
  layout(title = 'Shtetls in Eastern Europe', geo = g)

p

## try building in ggmap instead


###all shtetls
baseMap = ggmap(get_googlemap(center=c(mean(plotdf1$google_long),mean(plotdf1$google_lat)), scale=2, zoom=6), extent="normal")

circle_scale_amt = .001

baseMap + 
  geom_point(aes(x=google_long, y=google_lat), data=plotdf1, col="orange", 
             alpha=0.4, size=ifelse(plotdf1$pop1*circle_scale_amt >7,7,plotdf1$pop1*circle_scale_amt)
             ) +  
  scale_size_continuous(range=range(plotdf1$pop1))

###top 100
geom.text.size = 7
theme.size = 7

plotdf1 = plotdf1[order(-plotdf1$pop1),]

baseMap = ggmap(get_googlemap(center=c(mean(head(plotdf1,15)$google_long),mean(head(plotdf1,15)$google_lat)), 
                                       scale=2, zoom=6,maptype = "roadmap"), 
                extent="normal")

circle_scale_amt = .0001

baseMap + 
  geom_point(aes(x=google_long, y=google_lat), data=head(plotdf1,15), col="orange", 
             alpha=0.4, size=ifelse(head(plotdf1,15)$pop1*circle_scale_amt >9,9,head(plotdf1,15)$pop1*circle_scale_amt)
  ) +  
  scale_size_continuous(range=range(head(plotdf1,15)$pop1)) +
  geom_text(data = head(plotdf1,15), aes(x = google_long, y = google_lat, label = name), 
            size = 3, vjust = 0, hjust = -0.5,  size=geom.text.size) + 
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank())


## Build plots for blogpost, and save widgets using htmlwidgets to integrate html into blogdown post

## language and faith

setwd("~/shtetls/")

pop = read.csv("./data/language_census_1931.csv",stringsAsFactors = FALSE)

p = plot_ly(x=pop$language,y=pop$count,
        name="1931 Polish Census: Mother Tongue",type = "bar",
        marker = list(color = c('rgb(49,130,189)', 'rgb(49,130,189)',
                                'rgb(49,130,189)', 'rgb(49,130,189)',
                                'rgb(49,130,189)','rgb(49,130,189)', 
                                'rgb(49,130,189)', 'rgb(49,130,189)',
                                'rgba(222,45,38,0.8)', 'rgba(222,45,38,0.8)',
                                'rgb(49,130,189)', 'rgb(49,130,189)',
                                'rgb(49,130,189)'))) %>%
  layout(title = "1931 Polish Census: Mother Tongue",
         xaxis = list(title = "Language"),
         yaxis = list(title = "Population"))

relig = read.csv("./data/religion_census_1931.csv",stringsAsFactors = FALSE)

frameWidget(p, height = '300')

htmlwidgets::saveWidget(p, file = "~/shtetls/plots/lang_plot.html", selfcontained = TRUE)

p = plot_ly(x=relig$religion,y=relig$count,
        name="1931 Polish Census: Faith",type = "bar",
        marker = list(color = c('rgb(49,130,189)', 'rgb(49,130,189)',
                                'rgb(49,130,189)', 'rgb(49,130,189)',
                                'rgb(49,130,189)','rgb(49,130,189)', 
                                'rgb(49,130,189)', 'rgb(49,130,189)',
                                'rgba(222,45,38,0.8)', 'rgb(49,130,189)',
                                'rgb(49,130,189)', 'rgb(49,130,189)'))) %>%
  layout(title = "1931 Polish Census: Faith",
         xaxis = list(title = "Faith"),
         yaxis = list(title = "Population"))

frameWidget(p, height = '300')

htmlwidgets::saveWidget(p, file = "~/shtetls/plots/faith_plot.html", selfcontained = TRUE)


## top cities by jewish population

setwd("~/shtetls/")

df = read.csv("./data/additional_shtetl_data.csv",stringsAsFactors = FALSE)

largepop = df[!(is.na(df$pop1)),]

largepop = largepop[!(largepop$name %in% c('Solec Kujawski','Jozefow Nad Wisla')),]

largepop = largepop[order(-largepop$pop1),c("name","pop1","year1")]

largepop = head(largepop,8)

largepop$total_pop = c(670000,314780,66000,159877,110000,76025,53600,422700)

p = plot_ly(largepop, color = I("gray80")) %>%
  add_segments(x = ~pop1, xend = ~total_pop, y = ~name, yend = ~name, showlegend = FALSE) %>%
  add_markers(x = ~pop1, y = ~name, name = "Jewish Population", marker = list(color = 'rgba(222,45,38,0.8)')) %>%
  add_markers(x = ~total_pop, y = ~name, name = "Total Population", marker = list(color = 'rgb(49,130,189)')) %>%
  layout(
    title = "Population Disparity",
    xaxis = list(title = "Population Disparity (in thousands)"),
    yaxis = list(title = "City"),
    margin = list(l = 65)
  ) %>%
  layout(title = "Cities with Largest Jewish Population",
         xaxis = list(title = "City"),
         yaxis = list(title = "Population"))

frameWidget(p, height = '300')

htmlwidgets::saveWidget(p, file = "~/shtetls/plots/top_cities_disparity_plot.html", selfcontained = TRUE)


p = plot_ly(largepop, x = ~name, y = ~pop1, 
        type = 'bar', name = 'Jewish Population',
        marker = list(color = 'rgba(222,45,38,0.8)')) %>%
  add_trace(y = ~total_pop, name = 'Total Population',
            marker = list(color = 'rgb(49,130,189)')) %>%
  layout(yaxis = list(title = 'Count'), barmode = 'group') %>%
  layout(title = "Cities with Largest Jewish Population",
         xaxis = list(title = "City"),
         yaxis = list(title = "Population"))

frameWidget(p, height = '300')

htmlwidgets::saveWidget(p, file = "~/shtetls/plots/top_cities_plot.html", selfcontained = TRUE)

## population shift plots

setwd("~/shtetls/")

df = read.csv("./data/additional_shtetl_data.csv",stringsAsFactors = FALSE)

popdiff = df[!(is.na(df$pop1)),]
popdiff = df[!(is.na(df$pop2)),]

popdiff = popdiff[!(popdiff$name %in% c('Solec Kujawski','Jozefow Nad Wisla')),]

popdiff = popdiff[,c("name","pop1","year1","pop2","year2")]

popdiff$yeardiff = popdiff$year2-popdiff$year1
popdiff$popdiff = popdiff$pop2-popdiff$pop1

popdiff$diff_year = popdiff$popdiff / popdiff$yeardiff

popdiff = popdiff[order(-popdiff$diff_year),]

popdiff = head(popdiff,8)

p = plot_ly(popdiff, x = ~name, y = ~diff_year, 
        text = ~yeardiff, textposition = 'auto',
        type = 'bar', name = 'Yearly Jewish Population Difference',
        marker = list(color = 'rgba(222,45,38,0.8)')) %>%
        layout(
          title = "Population Shift by Year",
          xaxis = list(title = "City"),
          yaxis = list(title = "Yearly Population Increase"),
          margin = list(l = 65)
        )

frameWidget(p, height = '300')

htmlwidgets::saveWidget(p, file = "~/shtetls/plots/pop_shift.html", selfcontained = TRUE)

p = plot_ly(popdiff, color = I("gray80")) %>%
  add_segments(x = ~pop1, xend = ~pop2, y = ~name, yend = ~name, showlegend = FALSE) %>%
  add_markers(x = ~pop1, y = ~name, name = "Jewish Population", marker = list(color = 'rgba(222,45,38,0.8)')) %>%
  add_markers(x = ~pop2, y = ~name, name = "Total Population", marker = list(color = 'rgb(49,130,189)')) %>%
  layout(
    title = "Population Shift",
    xaxis = list(title = "Population Shift (in thousands)"),
    yaxis = list(title = "City"),
    margin = list(l = 65)
  )

frameWidget(p, height = '300')

htmlwidgets::saveWidget(p, file = "~/shtetls/plots/pop_shift_disparity.html", selfcontained = TRUE)

