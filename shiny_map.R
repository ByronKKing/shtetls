library("maptools")
library("ggmap")
library("shiny")
library("png")

setwd("~/shtetls/")

df = read.csv("./data/additional_shtetl_data.csv",stringsAsFactors = FALSE)

plotdf1 = df[!(is.na(df$pop1)),]

plotdf1 = plotdf1[plotdf1$name!='Sarnaki',]

plotdf1 = plotdf1[order(-plotdf1$pop1),]


ui = navbarPage(
  
  #theme = shinytheme("cosmo"),
  title = "Shtetl Map",
  
  tabPanel("My Listings",
           sidebarPanel(
             # htmlOutput("text1"),
             uiOutput("mapType"),
             uiOutput("popRange"),
             uiOutput("yearRange"),
             uiOutput("selectRegion"),
             uiOutput("maxNumb"),
             actionButton("go", "Go!"),
             width = 4
           ),
           mainPanel(
             plotOutput("mapPlot"),
             plotOutput("scatterPlot")
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
  
  # Initialize selectors not based on reactive dataframe
  
  ##map type
  output$mapType = renderUI({
    selectInput("mapType", label = "Select Map Type", 
                choices = list("Satellite" = "satellite", "Terrain" = "terrain", "Road" = "road","Hybrid" = "hybrid"), 
                selected = "terrain")
  })

  
  ##pop diff vs pop1
  
  dfReact = eventReactive(input$go,{plotdf1}) 
  
  # Initialize selectors based on reactive dataframe
  
  output$popRange = renderUI({
    sliderInput("popRange", "Select the Population Range:",
                min = min(plotdf1$pop1),
                max = max(plotdf1$pop1),
                value = c(min(plotdf1$pop1),max(plotdf1$pop1)))
  })
  
  output$yearRange = renderUI({
    sliderInput("yearRange", "Select Year Range:",
                min = min(plotdf1$year1),
                max = max(plotdf1$year1),
                value = c(min(plotdf1$year1),max(plotdf1$year1)))
  })
  
  output$selectRegion = renderUI({
    checkboxGroupInput("selectRegion",
                       label = "Select Region:", 
                       choices = unique(plotdf1$region),
                       selected = unique(plotdf1$region),inline = TRUE)
  })
  
  output$maxNumb = renderUI({
    numericInput("maxNumb", label = "Enter Max Number Shtetls:", value = 10)
  })

  
  # Plot map
  
  output$mapPlot = renderPlot({
    print(input$mapType)
    baseMap = ggmap(get_map(location=c(mean(plotdf1$google_long),mean(plotdf1$google_lat)), 
                            scale=2, zoom=6,maptype = "roadmap",
                    filename = paste("./data/",input$mapType,"_map.png",sep = "")),
                    extent="normal")
    print(paste("./data/",input$mapType,"_map.png",sep = ""))
    circle_scale_amt = .0001
    geom.text.size = 7
    
    baseMap + 
      geom_point(aes(x=google_long, y=google_lat), 
                 data=head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,],input$maxNumb), col="orange", 
                 alpha=0.4, 
                 size=ifelse(head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,]$pop1,input$maxNumb)*circle_scale_amt >9,9,
                             head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,]$pop1,input$maxNumb)*circle_scale_amt)
      ) +  
      scale_size_continuous(range=range(head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,]$pop1),input$maxNumb)) +
      geom_text(data = head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,],input$maxNumb), 
                aes(x = google_long, y = google_lat, label = name), 
                size = 3, vjust = 0, hjust = -0.5,  size=geom.text.size) + 
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.title.y=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank())
    
  })
  
  output$scatterPlot = renderPlot({
    
    ggplot(head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,],input$maxNumb)
      , aes(x=year1, y=pop1, color=region)) +
      geom_point() +
      geom_text(data=head(head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,],input$maxNumb),5),
                aes(year1,pop1,label=name),hjust=0,vjust=0,
                check_overlap = TRUE)
    
  })
  
}


shinyApp(ui = ui, server = server)

#dfReact()[dfReact()$pop1 <= input$popRange[2],]

