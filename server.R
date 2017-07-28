#creating the server
shinyServer(function(input, output,session) {
  
  #### Creating Interactive Map #########
  #loading map for indices
  output$map <- renderLeaflet({leaflet(counties) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      addTiles() %>%
      addProviderTiles(providers$Esri.WorldImagery,
                       options = providerTileOptions(opacity = 0.35)) %>%
      setView(lng = -99.67, lat = 38.93, zoom = 4)
  })
  
  
  
  #Reset View button
  observe({
    input$reset_button
    leafletProxy("map") %>% setView(lng = -99.67, lat = 38.93, zoom = 4)
  })      
  

  #observations for coloring the indices map
  observe({
    colorBy <- input$color
    
    colorData <- countydatamap[[colorBy]]
    pal <- colorNumeric("Reds", colorData)
    
    leafletProxy("map", data = counties) %>%
      clearShapes() %>%
      addProviderTiles(providers$HERE.hybridDay) %>%
      addPolygons(data = counties, fillColor=pal(colorData),
                  fillOpacity = 0.55, color = "black", weight = 0.5,label = ~paste0(Location, ": ", formatC(colorData))) %>%
      addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                layerId="colorLegend")
    
    #If hazard multiplier is selected, the score is multiplied with the associated hazard score
        if(input$hazrisk){
      colorBy <- input$color
      
      colorData <- countydatamap[[colorBy]] * countydatamap$PDDscore
      pal <- colorNumeric("Reds", colorData)
      
      leafletProxy("map", data = counties) %>%
        clearShapes() %>%
        addProviderTiles(providers$HERE.hybridDay) %>%
        addPolygons(data = counties, fillColor=pal(colorData),
                    fillOpacity = 0.55, color = "black", weight = 0.5,label = ~paste0(Location, ": ", formatC(colorData))) %>%
        addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                  layerId="colorLegend")
    }
    
    
  })
  
  #loading map for indices differences
  observe({
    colorDatadiff <- counties@data$diffdf
    
    paldiff <- colorNumeric("RdBu", colorDatadiff)
    
    output$diffmap <- renderLeaflet({leaflet(counties) %>%
        addTiles(
          urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
          attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
        addTiles() %>%
        addProviderTiles(providers$Esri.WorldImagery,
                         options = providerTileOptions(opacity = 0.35)) %>%
        addPolygons(data = counties, fillOpacity = 0.75, fillColor= paldiff(colorDatadiff),
                    color = "black", weight = 0.5,label = ~paste0(Location, ": ", formatC(diffdf))) %>%
        addLegend("bottomleft", pal=paldiff, values=colorDatadiff, layerId="colorLegend") %>%
        setView(lng = -99.67, lat = 38.93, zoom = 4) 
    })
    if(input$hazrisk_diff){
      colorDatadiff <- counties@data$diffdf * counties@data$PDDscore
      
      paldiff <- colorNumeric("RdBu", colorDatadiff)
      
      output$diffmap <- renderLeaflet({leaflet(counties) %>%
          addTiles(
            urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
            attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
          addTiles() %>%
          addProviderTiles(providers$Esri.WorldImagery,
                           options = providerTileOptions(opacity = 0.35)) %>%
          addPolygons(data = counties, fillOpacity = 0.75, fillColor= paldiff(colorDatadiff),
                      color = "black", weight = 0.5,label = ~paste0(Location, ": ", formatC(colorDatadiff))) %>%
          addLegend("bottomleft", pal=paldiff, values=colorDatadiff, layerId="colorLegend") %>%
          setView(lng = -99.67, lat = 38.93, zoom = 4) 
      })
    }
  })
  
  #reset view button on diff map
  #Reset View button
  observe({
    input$reset_button_diff
    leafletProxy("diffmap") %>% setView(lng = -99.67, lat = 38.93, zoom = 4)
  })    
  

  #data table output with selection based on states then counties
  output$indextable <- DT::renderDataTable({
    df <- countydatatable %>%
      filter(
        is.null(input$states) | State %in% input$states,
        is.null(input$counties) | County %in% input$counties
      )
  })
  
  #density plot output with x axis as BIVI and y axis as SVI
  output$densityplot <- renderPlot({
    
    xchoice <- input$xaxis
    ychoice <- input$yaxis
    
    xdata <- as.integer(countydatamap[[xchoice]])
    ydata <- as.integer(countydatamap[[ychoice]])
    
    plotdata <- data.frame(xdata,ydata)
    
    dp <- ggplot(plotdata, aes_string(xdata,ydata), cex = 3) +
      xlab(input$xaxis) +
      ylab(input$yaxis) +
      geom_count(color = "#CB4335") +
      theme(axis.title.x = element_text(size=16, face = "bold")) +
      theme(axis.title.y = element_text(size=16, face = "bold"))
    
    if(input$line)
      dp <- dp + geom_smooth(method='lm')
    
    print(dp)
    
  })
  
  
  
  #outputting correlation dependent upon the linear regression line box
  output$correlation <- renderText({
    xchoice <- input$xaxis
    ychoice <- input$yaxis
    
    xdata <- as.integer(countydatamap[[xchoice]])
    ydata <- as.integer(countydatamap[[ychoice]])
    
    xdataomit <- na.omit(xdata)
    ydataomit <- na.omit(ydata)
    
    plotdata <- data.frame(xdata,ydata)
    
    corval <- cor(xdataomit,ydataomit, method = "spearman")
    
    if(input$line)
      sprintf(
    "The correlation value between %s 
            and %s is %.5f",xchoice, ychoice, corval)
  })
  
  #outputting r-squared dependent upon the linear regression line box
  output$linreg <- renderText({
    xchoice <- input$xaxis
    ychoice <- input$yaxis
    
    xdata <- as.integer(countydatamap[[xchoice]])
    ydata <- as.integer(countydatamap[[ychoice]])
    
    xdataomit <- na.omit(xdata)
    ydataomit <- na.omit(ydata)
    
    plotdata <- data.frame(xdata,ydata)
    
    linval <- summary(lm(xdataomit ~ ydataomit))
    
    rsq <- linval$r.squared
    
    if(input$line)
      sprintf(
        "The R-squared value between %s 
            and %s is %.5f",xchoice, ychoice, rsq)
    
  })
})
