install.packages(c("shiny", "shinydashboard", "DT"))
install.packages("shinycssloaders")
install.packages("shinyjs")

# Chargement des bibliothèques
library(shiny)
library(shinydashboard)
library(DT)
library(shinycssloaders)
library(shinyjs)

# Fonction pour générer une grille vide en fonction du niveau avec des traits de séparation
generate_grid <- function(level) {
  size <- switch(level,
                 "Facile" = 6,
                 "Moyen" = 8,
                 "Difficile" = 10,
                 4)
  grid <- matrix("", nrow = size, ncol = size)
  colnames(grid) <- seq(1, size)
  rownames(grid) <- seq(1, size)
  grid
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
    useShinyjs(),
    tags$head(tags$style(HTML("
      .dataTable td, .dataTable th {
        text-align: center;
        vertical-align: middle;
        width: 40px;
        height: 40px;
      }
      .dataTables_wrapper {
        margin: 0 auto;
      }
      .table-bordered {
        border: 1px solid #ddd;
      }
      .table-bordered td, .table-bordered th {
        border: 1px solid #ddd !important;
      }
    "))),
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
              img(src = "www/takuzu.png", width = "50%")
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
                             img(src = "www/magic_wand.png", height = "30px"), 
                             img(src = "www/magic_wand.png", height = "30px"), 
                             img(src = "www/magic_wand.png", height = "30px")
                         ),
                         verbatimTextOutput("timer"),
                         actionButton("validate", "Valider la grille") # Bouton de validation
                       )
                ),
                column(width = 8,
                       h4("Grille de jeu"),
                       withSpinner(DTOutput("takuzu_grid"), type = 6) # Grille interactive avec chargement
                )
              ),
              verbatimTextOutput("validity_result") # Afficher le résultat de la validation
      ),
      
      # Onglet "Records"
      tabItem(tabName = "records",
              h2("Records des joueurs"),
              DTOutput("record_table")
      )
    )
  )
)

# Serveur - Logique de l'application
server <- function(input, output, session) {
  # Grille initiale
  grid <- reactiveVal(generate_grid("Facile"))
  
  # Générer une nouvelle grille en fonction du niveau sélectionné
  observeEvent(input$level, {
    grid(generate_grid(input$level))
  })
  
  # Afficher la grille
  output$takuzu_grid <- renderDT({
    datatable(grid(), selection = "none", editable = TRUE,
              options = list(dom = "t", ordering = FALSE, 
                             rowCallback = JS('function(row, data, index) {
                              $(row).children().each(function(i){
                                $(this).css("border", "1px solid #ddd");
                              });
                            }')
              ), class = 'table-bordered')
  }, server = FALSE)
  
  # Vérifier la validité de la grille
  observeEvent(input$validate, {
    validity <- check_validity(grid())
    output$validity_result <- renderText({
      if (validity) {
        "La grille est valide !"
      } else {
        "La grille n'est pas valide. Réessayez !"
      }
    })
  })
  
  # Timer (simulé ici comme un texte statique)
  output$timer <- renderText({
    paste("Temps écoulé : 00:00") #A changé
  })
  
  # Afficher les records (simulés ici comme un tableau vide)
  output$record_table <- renderDT({
    datatable(data.frame(
      Joueur = character(),
      Niveau = character(),
      Temps = character()
    ))
  })
}

# Lancer l'application
shinyApp(ui, server)

