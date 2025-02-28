install.packages(c("shiny", "shinydashboard", "DT"))

# Chargement des bibliothèques
library(shiny)
library(shinydashboard)
library(DT)

# Fonction pour générer une grille vide
generate_grid <- function(size = 4) {
  matrix("", nrow = size, ncol = size)
}

# UI - Interface utilisateur
ui <- dashboardPage(
  skin = "purple", 
  dashboardHeader(title = "Takuzu_M1_SSD"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Règles", tabName = "rules", icon = icon("book")),
      menuItem("Jouer", tabName = "play", icon = icon("gamepad")),
      menuItem("Records", tabName = "records", icon = icon("trophy"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # Onglet "Règles"
      tabItem(tabName = "rules",
              h2("Les règles du Takuzu"),
              p("Le Takuzu est un jeu de logique avec les règles suivantes :"),
              tags$ul(
                tags$li("Chaque ligne et chaque colonne doit contenir autant de 0 que de 1."),
                tags$li("Il ne peut pas y avoir plus de deux 0 ou deux 1 consécutifs."),
                tags$li("Chaque ligne et chaque colonne doit être unique."),
                tags$li("Remplissez la grille en respectant ces contraintes !")
              ),
              img(src = "takuzu.png", width = "50%") 
      ),
      
      # Onglet "Jouer"
      tabItem(tabName = "play",
              fluidRow(
                column(width = 4,
                       h3("Bon jeu !"),
                       box(
                         title = "Paramètres", solidHeader = TRUE, status = "warning", width = 12,
                         selectInput("level", "Niveau", choices = c("Facile", "Moyen", "Difficile")),
                         selectInput("errors", "Nombre d'erreurs autorisées", choices = c(3, 5, 10)),
                         selectInput("hints", "Aides", choices = c(1, 3, 5)),
                         div(style = "text-align:center;",
                             img(src = "magic_wand.png", height = "30px"), 
                             img(src = "magic_wand.png", height = "30px"), 
                             img(src = "magic_wand.png", height = "30px")
                         ),
                         verbatimTextOutput("timer")
                       )
                ),
                column(width = 8,
                       h4("Grille de jeu"),
                       DTOutput("takuzu_grid") # Grille interactive
                )
              )
      ),
      
      # Onglet "Records"
      tabItem(tabName = "records",
              h2("Records des joueurs"),
              DTOutput("record_table")
      )
    )
  )
)

# SERVER - Logique de l'application
server <- function(input, output, session) {
  
  # Stocker la grille de jeu réactive
  game_grid <- reactiveVal(generate_grid(4))
  
  output$takuzu_grid <- renderDT({
    datatable(game_grid(), editable = "cell", options = list(dom = 't'))
  }, server = FALSE)
  
  # Mise à jour de la grille quand l'utilisateur modifie une case
  observeEvent(input$takuzu_grid_cell_edit, {
    info <- input$takuzu_grid_cell_edit
    grid <- game_grid()
    grid[info$row, info$col] <- as.character(info$value)
    game_grid(grid)
  })
  
  # Timer (statique pour le moment)
  output$timer <- renderText({
    "00:00" # On ajoutera un vrai chronomètre après
  })
  
  # Stocker les records des joueurs
  records <- reactiveVal(data.frame(Joueur = character(), Temps = character(), stringsAsFactors = FALSE))
  
  output$record_table <- renderDT({
    datatable(records(), options = list(pageLength = 5))
  })
}

# Lancer l'application Shiny
shinyApp(ui = ui, server = server)
