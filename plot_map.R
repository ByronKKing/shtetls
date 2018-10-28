library("plotly")
library("maptools")
library("ggmap")

setwd("~/shtetls/")

df = read.csv("./data/additional_shtetl_data.csv",stringsAsFactors = FALSE)

plotdf1 = df[!(is.na(df$pop1)),]

#######

g = list(
  scope = 'europe',
  projection = list(type = 'natural earth',scale = 3),
  showland = TRUE,
  landcolor = toRGB("gray85"),
  subunitwidth = 1,
  countrywidth = 1,
  subunitcolor = toRGB("white"),
  countrycolor = toRGB("white")
)

p = plot_geo(plotdf1, locationmode = 'country names', sizes = c(1, 250)) %>%
  add_markers(
    x = ~google_long, y = ~google_lat, size = ~pop1
    # , 
    # hoverinfo = "text",
    # text = ~paste(df$name, "<br />", df$pop1/1e6, " million")
  ) %>%
  layout(title = '2014 US city populations<br>(Click legend to toggle)', geo = g)

p

###
#geocodeQueryCheck()

#usa_center = as.numeric(geocode("United States"))


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


