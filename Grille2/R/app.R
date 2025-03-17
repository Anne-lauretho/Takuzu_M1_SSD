library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(Grille2)

# UI
ui <- fluidPage(
  useShinyjs(),
  titlePanel("Jeu de Takuzu"),

  # Input caché pour gérer l'état
  textInput("display_mode", label = NULL, value = "home", width = "0px"),
  tags$style(type="text/css", "#display_mode {visibility: hidden; height: 0px;}"),

  # Page d'accueil
  conditionalPanel(
    condition = "input.display_mode == 'home'",
    fluidRow(
      column(12,
             h3("Bienvenue dans le jeu Takuzu !"),
             p("Cliquez sur le bouton ci-dessous pour commencer à jouer."),
             actionButton("start_button", "Commencer")
      )
    )
  ),

  # Page du jeu
  conditionalPanel(
    condition = "input.display_mode == 'game'",
    fluidPage(
      # Sélecteur de couleur
      tags$div(
        style = "position: absolute; top: 10px; right: 10px;",
        pickerInput(
          inputId = "fixed_cell_color",
          label = "Couleur des cases initiales",
          choices = c("Gris clair" = "#e0e0e0", "Bleu" = "#add8e6", "Vert" = "#cdecc5", "Jaune" = "#fffacd", "Rose" = "#e7c5ec"),
          choicesOpt = list(
            style = c(
              "background-color: #e0e0e0; color: black;",
              "background-color: #add8e6; color: black;",
              "background-color: #cdecc5; color: black;",
              "background-color: #fffacd; color: black;",
              "background-color: #e7c5ec; color: black;"
            )
          ),
          selected = "#e0e0e0"
        )
      ),

      # Espacement
      tags$div(style = "height: 60px;"),

      # Grille interactive
      uiOutput("grid_ui"),

      # Boutons de contrôle
      fluidRow(
        column(4, actionButton("check_btn", "Vérifier la grille")),
        column(4, actionButton("new_game_btn", "Nouvelle partie")),
        column(4, sliderInput("difficulty", "Difficulté",
                              min = 0.1, max = 0.8, value = 0.5, step = 0.1))
      )
    )
  )
)

# Serveur
server <- function(input, output, session) {
  # État du jeu actuel
  game_data <- reactiveVal(NULL)  # Initialiser à NULL

  # Valeurs actuelles des cellules
  cell_values <- reactiveVal(matrix("", 6, 6))

  # Lorsque l'utilisateur clique sur "Commencer"
  observeEvent(input$start_button, {
    # Générer la grille initiale
    game_data(generate_takuzu_grid(6, 0.5))

    # Initialiser les valeurs des cellules
    cell_values(game_data()$grid)

    # Passer à l'écran de jeu
    updateTextInput(session, "display_mode", value = "game")
  })

  # Génération dynamique de la grille UI
  output$grid_ui <- renderUI({
    req(game_data())  # S'assurer que game_data est initialisé

    data <- game_data()
    values <- cell_values()
    initial_filled <- data$initial_filled
    fixed_color <- input$fixed_cell_color

    tags$div(
      style = "display: grid; grid-template-columns: repeat(6, 1fr); gap: 5px; width: 300px; margin: auto;",

      lapply(1:6, function(row) {
        lapply(1:6, function(col) {
          btn_id <- paste0("btn_", row, "_", col)
          current_value <- values[row, col]

          # Vérifier si cette cellule est initialement remplie
          is_fixed <- initial_filled[row, col]

          # Style différent pour les cellules fixes
          button_style <- if (is_fixed) {
            sprintf("width: 100%%; aspect-ratio: 1 / 1; font-size: 16px; background-color: %s; font-weight: bold;", fixed_color)
          } else {
            "width: 100%; aspect-ratio: 1 / 1; font-size: 16px;"
          }

          actionButton(
            inputId = btn_id,
            label = current_value,
            style = button_style
          )
        })
      })
    )
  })

  # Gestion des clics sur les cellules
  lapply(1:6, function(row) {
    lapply(1:6, function(col) {
      btn_id <- paste0("btn_", row, "_", col)

      observeEvent(input[[btn_id]], {
        req(game_data())  # S'assurer que game_data est initialisé

        data <- game_data()
        initial_filled <- data$initial_filled

        # Ne pas permettre la modification des cellules initialement remplies
        if (!initial_filled[row, col]) {
          values <- cell_values()
          current_value <- values[row, col]

          # Changement cyclique : "" → "0" → "1" → ""
          new_value <- ifelse(current_value == "", "0",
                              ifelse(current_value == "0", "1", ""))

          values[row, col] <- new_value
          cell_values(values)
          updateActionButton(session, btn_id, label = new_value)
        }
      })
    })
  })

  # Mettre à jour les styles des boutons lorsque la couleur change
  observeEvent(input$fixed_cell_color, {
    req(game_data())  # S'assurer que game_data est initialisé

    data <- game_data()
    initial_filled <- data$initial_filled
    fixed_color <- input$fixed_cell_color

    # Parcourir toutes les cellules fixes et mettre à jour leur style
    for (row in 1:6) {
      for (col in 1:6) {
        if (initial_filled[row, col]) {
          btn_id <- paste0("btn_", row, "_", col)
          runjs(sprintf(
            "$('#%s').css('background-color', '%s');",
            btn_id, fixed_color
          ))
        }
      }
    }
  })

  # Vérification de la grille
  observeEvent(input$check_btn, {
    req(game_data())  # S'assurer que game_data est initialisé

    data <- game_data()
    values <- cell_values()

    # Vérifier que toutes les cellules sont remplies
    if (any(values == "")) {
      showModal(modalDialog(
        "Veuillez remplir toutes les cellules avant de vérifier.",
        easyClose = TRUE
      ))
      return()
    }

    # Vérifier si la grille est valide selon les règles du Takuzu
    correct <- all(values == data$solution)

    showModal(modalDialog(
      if (correct) {
        "Bravo ! Vous avez résolu le puzzle correctement."
      } else {
        "Il y a des erreurs dans votre solution. Continuez à essayer."
      },
      easyClose = TRUE
    ))
  })

  # Nouvelle partie
  observeEvent(input$new_game_btn, {
    new_data <- generate_takuzu_grid(6, input$difficulty)
    game_data(new_data)
    cell_values(new_data$grid)
  })
}

# Lancer l'application
shinyApp(ui, server)
