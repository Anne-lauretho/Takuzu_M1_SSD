library(shiny)
library(Grille)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Generate a Grid"),
  sidebarLayout(
    sidebarPanel(
      numericInput("n_rows", "Number of rows:", 10, min = 1),
      numericInput("n_cols", "Number of columns:", 10, min = 1),
      numericInput("spacing", "Spacing:", 1, min = 0.1),
      actionButton("generate", "Generate Grid")
    ),
    mainPanel(
      plotOutput("gridPlot")
    )
  )
)

server <- function(input, output) {
  grid_data <- eventReactive(input$generate, {
    create_grid(n_rows = input$n_rows, n_cols = input$n_cols, spacing = input$spacing)
  })

  output$gridPlot <- renderPlot({
    data <- grid_data()
    ggplot(data, aes(x = x, y = y)) +
      geom_point(size = 3) +
      theme_minimal() +
      labs(title = "Generated Grid", x = "X", y = "Y")
  })
}

shinyApp(ui, server)


