library(shiny)
library(tidyverse)
library(tidymodels)
library(splines2)

ui <- pageWithSidebar(
  
  # App title ----
  headerPanel("Splines tipo M"),
  
  # Sidebar panel for inputs ----
  sidebarPanel(
    actionButton(inputId = "aleatorizar", label="Aleatorizar"),
    uiOutput("beta_control")
    
  ),
  
  # Main panel for displaying outputs ----
  mainPanel(
    
    plotOutput("graf_spline")
    
    
  )
)

valores_x <- seq(0, 100, 1)
num_nodos <- 6
 
server <- function(input, output, session) {
  
  # Compute the formula text ----
  # This is in a reactive expression since it is shared by the
  # output$caption and output$mpgPlot functions
  beta <- reactive({
    betas <- c(input$beta1, input$beta2, input$beta3, input$beta4, input$beta5, input$beta6)
    #betas[as.integer(input$beta_select)] <- input$beta
    betas
  })
  randomVals <- observeEvent(input$aleatorizar, {
    valores <- 5 * runif(6, -1, 1)
    updateSliderInput(session, "beta1", value = valores[1])
    updateSliderInput(session, "beta2", value = valores[2])
    updateSliderInput(session, "beta3", value = valores[3])
    updateSliderInput(session, "beta4", value = valores[4])
    updateSliderInput(session, "beta5", value = valores[5])
    updateSliderInput(session, "beta6", value = valores[6])
  })
  spline_tbl <- reactive({
    base_splines <- splines2::mSpline(x = valores_x, df = num_nodos, 
                                Boundary.knots = c(0, 100))
    spline_1 <- base_splines %*% beta()
    tibble(x = valores_x, y = spline_1)
  })
  

  output$graf_spline <- renderPlot({
    g_1 <- ggplot(spline_tbl(), aes(x = x, y = y)) + 
      geom_point() + geom_line() +
      geom_vline(xintercept = quantile(1:100, seq(0,1,by = 1/8)), colour = "red")
    g_1 
  })
  
  output$beta_control <- renderUI({
    fluidPage(
    sliderInput(inputId = "beta1", label = "beta1", min = -5, max = 5, value = 0, step = 0.1),
    sliderInput(inputId = "beta2", label = "beta2", min = -5, max = 5, value = 0, step = 0.1),
    sliderInput(inputId = "beta3", label = "beta3", min = -5, max = 5, value = 0, step = 0.1),
    sliderInput(inputId = "beta4", label = "beta4", min = -5, max = 5, value = 0, step = 0.1),
    sliderInput(inputId = "beta5", label = "beta5", min = -5, max = 5, value = 0, step = 0.1),
    sliderInput(inputId = "beta6", label = "beta6", min = -5, max = 5, value = 0, step = 0.1))
  })

  
}

shinyApp(ui, server)