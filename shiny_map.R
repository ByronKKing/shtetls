library("maptools")
library("ggmap")
library("shiny")
library("png")

setwd("~/shtetls/")

df = read.csv("./data/additional_shtetl_data.csv",stringsAsFactors = FALSE)

plotdf1 = df[!(is.na(df$pop1)),]

plotdf1 = plotdf1[!(plotdf1$name %in% c('Solec Kujawski','Jozefow Nad Wisla')),]

plotdf1 = plotdf1[order(-plotdf1$pop1),]


ui = navbarPage(
  
  theme = shinytheme("cosmo"),
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
             plotlyOutput("mapPlot"),
             plotlyOutput("scatterPlot")
           )
  )
  
  ## Add Data Table Here to view data
  
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
  
  output$mapPlot = renderPlotly({

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
    
    p = plot_geo(head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,],input$maxNumb)
                 ,locationmode = 'country names', sizes = c(1, 250)) %>%
      add_markers(
        x = ~google_long, y = ~google_lat, size = ~pop1, color = ~region,
        hoverinfo = "text",
        text = ~paste(head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,]$name,input$maxNumb)
                      ,", Population: ",
                      head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,]$pop1,input$maxNumb)
                      ,sep = "")
      ) %>%
      layout(title = 'Shtetls in Eastern Europe', geo = g)
    
    p
    

  })
  
  output$scatterPlot = renderPlotly({
    
    
    plot_ly(data = head(dfReact()[dfReact()$pop1 <= input$popRange[2] & dfReact()$year1 <= input$yearRange[2] & dfReact()$region %in% input$selectRegion,],input$maxNumb), 
            x = ~year1, y = ~pop1, color = ~region)
    

  })
  
}


shinyApp(ui = ui, server = server)



