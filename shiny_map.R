library("maptools")
library("ggmap")
library("shiny")
library("png")

setwd("~/shtetls/")

df = read.csv("./data/additional_shtetl_data.csv",stringsAsFactors = FALSE)

plotdf1 = df[!(is.na(df$pop1)),]

plotdf1 = head(plotdf1[order(-plotdf1$pop1),],50)


ui = navbarPage(
  
  #theme = shinytheme("cosmo"),
  title = "Shtetl Map",
  
  tabPanel("My Listings",
           sidebarPanel(
             # htmlOutput("text1"),
             # htmlOutput("text2"),
             uiOutput("popRange"),
             actionButton("go", "Go!"),
             #uiOutput("selectTowns"),
             width = 4
           ),
           mainPanel(
             plotOutput("mapPlot")
           )
  )
  # ,
  # tabPanel("My Progress", 
  #          sidebarPanel(
  #            htmlOutput("progressText"),
  #            width = 4
  #          ),
  #          mainPanel(
  #            fluidRow(h3("Here are the listings you've contacted:", align="center")),
  #            fluidRow(column(12, 
  #                            h4("", align="center"), 
  #                            p(plotlyOutput("pie1"), align="center"))),
  #            fluidRow(h3("This is how your listings stack against others:", align="center")),
  #            fluidRow(column(12, 
  #                            h4("", align="center"), 
  #                            p(plotlyOutput("bar1"), align="center"))),
  #            fluidRow(h3("This is a glimpse at the market at large:", align="center")),
  #            fluidRow(column(12, 
  #                            h4("", align="center"), 
  #                            p(plotlyOutput("ts1"), align="center")))
  #          )
  # )
)


server = function(input, output,session) {
  
  output$popRange = renderUI({
    sliderInput("popRange", "Select the Population Range:",
                min = min(plotdf1$pop1),
                max = max(plotdf1$pop1),
                value = c(min(plotdf1$pop1),max(plotdf1$pop1)))
  })
  
  dfReact = eventReactive(input$go,{plotdf1})
  
  output$mapPlot = renderPlot({
    
    baseMap = ggmap(get_map(location=c(mean(head(plotdf1,15)$google_long),mean(head(plotdf1,15)$google_lat)), 
                            scale=2, zoom=6,maptype = "roadmap",
                    #readPNG("./data/satellite_map.png")
                    filename = "./data/satellite_map.png"),
                    extent="normal")
    
    circle_scale_amt = .0001
    
    baseMap + 
      geom_point(aes(x=google_long, y=google_lat), data=dfReact()[dfReact()$pop1 <= input$popRange[2],], col="orange", 
                 alpha=0.4, size=ifelse(dfReact()[dfReact()$pop1 <= input$popRange[2],]$pop1*circle_scale_amt >9,9,dfReact()[dfReact()$pop1 <= input$popRange[2],]$pop1*circle_scale_amt)
      ) +  
      scale_size_continuous(range=range(dfReact()[dfReact()$pop1 <= input$popRange[2],]$pop1)) +
      geom_text(data = dfReact()[dfReact()$pop1 <= input$popRange[2],], aes(x = google_long, y = google_lat, label = name), 
                size = 3, vjust = 0, hjust = -0.5,  size=geom.text.size) + 
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.title.y=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank())
    
  })
  
}


shinyApp(ui = ui, server = server)

#dfReact()[dfReact()$pop1 <= input$popRange[2],]

