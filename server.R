library(shiny)
library(datasets)
library(ggplot2)

# This Shiny application lets a user dynamically configure the appearance of
# a ggplot2 scatter-plot using the mtcars dataset. There are five aesthetics
# the user can control: x-axis, y-axis, color, shape and size.
#
# Logically a variable in a dataset can only applied to one aesthetic of the
# ggplot. Therefore the select-inputs in the UI have dependencies with each
# other: downstream inputs only appear when their upstream counterparts have
# been selected and they can only allow the user to select a remaining value.
#
# This application is entirely self-contained and uses no externally-sourced
# datasets.
shinyServer(function(input, output) {
    columns <- c("", colnames(mtcars))
    
    # The x-axis select input is always available. If the user changes this value
    # all of the downstream select inputs are reset.
    output$xaxis <- renderUI(
        selectInput("xaxis", "Select a x-axis value",
                    choices = columns, selected = NULL, multiple = FALSE))
    
    # The y-axis select input depends on the x-axis input having a valid value.
    # It offers all remaining column names aside from the selected x-axis value.
    output$yaxis <- renderUI({
        req(input$xaxis)
        yaxis_columns <- columns[columns != input$xaxis]
        selectInput("yaxis", "Select a y-axis value", choices = yaxis_columns)
    })
    
    # The color select input depends on the y-axis input having a valid value.
    # It offers all remaining column names aside from the selected x-axis and
    # y-axis values.
    output$color <- renderUI({
        req(input$yaxis)
        color_columns <- columns[!columns %in% c(input$xaxis, input$yaxis)]
        selectInput("color", "Select a color value", choices = color_columns)
    })
    
    # The shape select input depends on the color input having a valid value.
    # It offers all remaining column names aside from the selected x-axis, y-axis
    # and color values.
    output$shape <- renderUI({
        req(input$color)
        shape_columns <- columns[!columns %in% c(input$xaxis, input$yaxis, input$color)]
        selectInput("shape", "Select a shape value", shape_columns)
    })
    
    # The size select input depends on the shape input having a valid value.
    # It offers all remaining column names aside from the selected x-axis, y-axis,
    # color and shape values.
    output$size <- renderUI({
        req(input$shape)
        size_columns <- columns[!columns %in% c(input$xaxis, input$yaxis, input$color, input$shape)]
        selectInput("size", "Select a size value", size_columns)
    })
    
    column_labels <- c(mpg = "Miles Per Gallon", cyl = "Number of Cylinders",
                       disp = "Displacement", hp = "Gross Horsepower",
                       drat = "Rear Axle Ratio", wt = "Weight (1000 lbs)",
                       qsec = "Quarter Mile Time", vs = "V/S",
                       am = "Transmission", gear = "Number of Gears",
                       carb = "Number of Carburetors")
    
    output$distPlot <- renderPlot({
        req(input$xaxis, input$yaxis, input$color, input$shape, input$size)
        
        tryCatch({
            ggplot(mtcars, aes(x=mtcars[[input$xaxis]],
                               y=mtcars[[input$yaxis]],
                               color=mtcars[[input$color]],
                               size=mtcars[[input$size]],
                               shape=as.factor(mtcars[[input$shape]]))) +
                labs(x = column_labels[[input$xaxis]],
                     y = column_labels[[input$yaxis]],
                     color = column_labels[[input$color]],
                     size = column_labels[[input$size]],
                     shape = column_labels[[input$shape]]) +
                geom_point()
        }, error = function(e) {
            output$error <- renderText(e)
        }, warning = function(w) {
            output$warning <- renderText(w)
        })
    })
    
})