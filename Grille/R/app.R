# Télécharger les packages

library(shiny)
library(shinydashboard)
library(DT)
library(shinycssloaders)
library(shinyjs)
library(Grille)

# UI - Interface utilisateur

ui <- fluidPage(
  useShinyjs(),  # Utiliser shinyjs pour pouvoir cacher les éléments
  tags$head(
    tags$style(HTML("
      body {
        background-color: #D8BFD8;
        color: white;
        text-align: center;
        overflow: hidden;
      }

      .title {
        font-size: 50px;
        font-weight: bold;
        text-shadow: 3px 3px 5px rgba(0, 0, 0, 0.3);
      }

      .btn-custom {
        background: linear-gradient(to bottom, #FFD700, #FFA500);
        border: 3px solid #B87333;
        color: white;
        font-size: 22px;
        font-weight: bold;
        width: 220px;
        height: 60px;
        margin: 15px;
        border-radius: 15px;
        box-shadow: 4px 4px 6px rgba(0,0,0,0.3);
        position: relative;
        z-index: 10; /* Les boutons restent au premier plan */
      }

      .btn-custom:hover {
        background: linear-gradient(to bottom, #FFEE88, #FFBB33);
      }

      .cloud-container {
        position: absolute;
        width: 100%;
        height: 100%;
        overflow: hidden;
        z-index: 0; /* Nuages en arrière-plan */
      }

      .cloud {
        position: absolute;
        background: white;
        width: 120px;
        height: 70px;
        border-radius: 50%;
        box-shadow: 30px 10px 0 10px white, -30px 10px 0 10px white;
        opacity: 0.7;
        animation: float 12s linear infinite alternate;
        z-index: 0; /* S'assurer que les nuages sont en arrière-plan */
      }

      .cloud:nth-child(1) { top: 5%; left: 10%; animation-duration: 14s; }
      .cloud:nth-child(2) { top: 20%; left: 50%; animation-duration: 12s; }
      .cloud:nth-child(3) { top: 35%; left: 80%; animation-duration: 16s; }
      .cloud:nth-child(4) { top: 50%; left: 20%; animation-duration: 18s; }
      .cloud:nth-child(5) { top: 65%; left: 60%; animation-duration: 15s; }
      .cloud:nth-child(6) { top: 80%; left: 30%; animation-duration: 17s; }
      .cloud:nth-child(7) { top: 90%; left: 70%; animation-duration: 13s; }

      @keyframes float {
        0% { transform: translateX(0); }
        100% { transform: translateX(40px); }
      }

      .button-container {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        z-index: 10;
      }

      .rules-container {
        background-color: rgba(255, 255, 255, 0.8);
        color: black;
        border: 3px solid #B87333;
        padding: 20px;
        margin: 50px auto;
        width: 70%;
        box-shadow: 4px 4px 6px rgba(0, 0, 0, 0.3);
        border-radius: 15px;
        position: relative;
        z-index: 20; /* Cadre en avant-plan */
      }

      .description {
        color: black;
      }

      .takuzu-grid {
        display: inline-grid;
        grid-template-columns: repeat(auto-fill, minmax(50px, 1fr));
        gap: 5px;
        margin: 20px auto;
        max-width: 600px;
      }

      .takuzu-cell {
        width: 50px;
        height: 50px;
        background-color: #f0f0f0;
        border: 2px solid #B87333;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 24px;
        font-weight: bold;
        cursor: pointer;
        transition: background-color 0.3s;
      }

      .takuzu-cell:hover {
        background-color: #FFD700;
      }

      .takuzu-cell-editable {
        background-color: white;
      }
    "))
  ),

  div(class = "cloud-container",
      div(class = "cloud"), div(class = "cloud"), div(class = "cloud"),
      div(class = "cloud"), div(class = "cloud"), div(class = "cloud"),
      div(class = "cloud")
  ),

  div(id = "buttons", class = "button-container",
      h1(class = "title", "Takuzu Game"),
      actionButton("play", "Jouer", class = "btn-custom"),
      br(),
      actionButton("rules", "Règles", class = "btn-custom"),
      br(),
      actionButton("records", "Records", class = "btn-custom")
  ),

  uiOutput("content")
)

# Serveur

server <- function(input, output, session) {
  # Variable réactive pour stocker la grille de jeu
  game_grid <- reactiveVal(NULL)

  observeEvent(input$play, {
    removeUI(selector = "#buttons")
    output$content <- renderUI({
      tagList(
        h2("Niveaux"),
        actionButton("easy", "Facile", class = "btn-custom"),
        p(class = "description", "Ce niveau comprend une grille 6x6"),
        br(),
        actionButton("medium", "Moyen", class = "btn-custom"),
        p(class = "description", "Ce niveau comprend une grille 8x8"),
        br(),
        actionButton("hard", "Difficile", class = "btn-custom"),
        p(class = "description", "Ce niveau comprend une grille 10x10"),
        br(),
        actionButton("back", "Retour", class = "btn-custom")
      )
    })
  })

  # Gestionnaire d'événements pour les niveaux
  observeEvent(input$easy, {
    removeUI(selector = "#buttons")
    grid <- generate_takuzu_grid(6)
    game_grid(grid)

    output$content <- renderUI({
      div(
        h2("Takuzu - Niveau Facile (6x6)"),
        div(class = "takuzu-grid",
            lapply(1:nrow(grid), function(i) {
              lapply(1:ncol(grid), function(j) {
                div(
                  class = paste0("takuzu-cell",
                                 if(runif(1) > 0.5) " takuzu-cell-editable" else ""),
                  id = paste0("cell-", i, "-", j),
                  if(is.na(grid[i,j]) || runif(1) > 0.5) "" else grid[i,j]
                )
              })
            })
        ),
        actionButton("back", "Retour", class = "btn-custom")
      )
    })
  })

  observeEvent(input$medium, {
    removeUI(selector = "#buttons")
    grid <- generate_takuzu_grid(8)
    game_grid(grid)

    output$content <- renderUI({
      div(
        h2("Takuzu - Niveau Moyen (8x8)"),
        div(class = "takuzu-grid",
            lapply(1:nrow(grid), function(i) {
              lapply(1:ncol(grid), function(j) {
                div(
                  class = paste0("takuzu-cell",
                                 if(runif(1) > 0.5) " takuzu-cell-editable" else ""),
                  id = paste0("cell-", i, "-", j),
                  if(is.na(grid[i,j]) || runif(1) > 0.5) "" else grid[i,j]
                )
              })
            })
        ),
        actionButton("back", "Retour", class = "btn-custom")
      )
    })
  })

  observeEvent(input$hard, {
    removeUI(selector = "#buttons")
    grid <- generate_takuzu_grid(10)
    game_grid(grid)

    output$content <- renderUI({
      div(
        h2("Takuzu - Niveau Difficile (10x10)"),
        div(class = "takuzu-grid",
            lapply(1:nrow(grid), function(i) {
              lapply(1:ncol(grid), function(j) {
                div(
                  class = paste0("takuzu-cell",
                                 if(runif(1) > 0.5) " takuzu-cell-editable" else ""),
                  id = paste0("cell-", i, "-", j),
                  if(is.na(grid[i,j]) || runif(1) > 0.5) "" else grid[i,j]
                )
              })
            })
        ),
        actionButton("back", "Retour", class = "btn-custom")
      )
    })
  })

  observeEvent(input$rules, {
    removeUI(selector = "#buttons")
    output$content <- renderUI({
      div(class = "rules-container",
          h2("Règles du jeu"),
          p("Chaque cellule de la grille doit être remplie soit par un 0, soit par un 1."),
          p("Chaque ligne et chaque colonne doivent contenir un nombre égal de 0 et de 1."),
          p("Il est interdit d'avoir trois 0 consécutifs ou trois 1 consécutifs dans une ligne ou une colonne."),
          p("Deux lignes ou deux colonnes identiques ne sont pas autorisées dans la même grille."),
          h3("Stratégies pour résoudre un Takuzu"),
          p("Éviter les triplets : si deux 0 ou deux 1 sont consécutifs, la cellule suivante doit contenir l'autre chiffre."),
          p("Équilibrer les 0 et les 1 : une ligne ou une colonne ne peut pas contenir plus de la moitié de ses cellules avec le même chiffre."),
          p("Comparer les lignes et les colonnes complétées : si une ligne ou une colonne est presque remplie et qu'une autre est similaire, ajustez les chiffres pour éviter les doublons."),
          actionButton("back", "Retour", class = "btn-custom")
      )
    })
  })

  observeEvent(input$records, {
    removeUI(selector = "#buttons")
    output$content <- renderUI({
      tagList(
        h2("Records de Takuzu")
        # A REMPLIR
      )
    })
  })

  observeEvent(input$back, {
    output$content <- renderUI({
      tagList(
        div(id = "buttons", class = "button-container",
            h1(class = "title", "Takuzu Game"),
            actionButton("play", "Jouer", class = "btn-custom"),
            br(),
            actionButton("rules", "Règles", class = "btn-custom"),
            br(),
            actionButton("records", "Records", class = "btn-custom")
        )
      )
    })
  })
}

# Lancer l'application

shinyApp(ui, server)
