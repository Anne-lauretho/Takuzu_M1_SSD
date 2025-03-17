library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(Grille2)

# UI
ui <- fluidPage(
  useShinyjs(),
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
        background: #8E1D7B;
        border: 3px solid #5E0950;
        color: white;
        font-size: 22px;
        font-weight: bold;
        width: 220px;
        height: 60px;
        margin: 15px;
        border-radius: 15px;
        box-shadow: 4px 4px 6px rgba(0,0,0,0.3);
        position: relative;
        z-index: 10;
      }

      .btn-custom:hover {
        background: #D8BFD8;
        border: 3px solid #5E0950;
      }

      .cloud-container {
        position: absolute;
        width: 100%;
        height: 100%;
        overflow: hidden;
        z-index: 0;
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
        z-index: 0;
      }

      .cloud:nth-child(1) { top: 5%;  left: 10%; animation-duration: 14s; }
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

      .game-container {
        background-color: rgba(255, 255, 255, 0.8);
        color: black;
        border: 3px solid #5E0950;;
        padding: 20px;
        margin: 50px auto;
        width: 80%;
        box-shadow: 4px 4px 6px rgba(0, 0, 0, 0.3);
        border-radius: 15px;
        position: relative;
        z-index: 20;
      }

      .takuzu-grid {
        display: grid;
        grid-template-columns: repeat(6, 1fr);
        gap: 5px;
        margin: 20px auto;
        width: 300px;
      }

      .takuzu-cell {
        width: 50px;
        height: 50px;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 24px;
        font-weight: bold;
        border: 2px solid #5E0950;
        cursor: pointer;
        transition: background-color 0.3s;
      }

      .takuzu-cell-fixed {
        background-color: #e0e0e0;
      }

      .takuzu-cell-editable {
        background-color: white;
      }

      .takuzu-cell-editable:hover {
        background-color: #8E1D7B;
      }

      .difficulty-slider {
        margin: 20px auto;
        width: 50%;
      }

      .color-picker {
        margin: 10px auto;
      }

      .rules-section {
        text-align: left;
        margin: 20px auto;
        width: 90%;
      }

      h2 {
        color: #5E0950;
        font-size: 24px;
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
      }
    "))
  ),

  # Arrière-plan avec nuages
  div(class = "cloud-container",
      div(class = "cloud"), div(class = "cloud"), div(class = "cloud"),
      div(class = "cloud"), div(class = "cloud"), div(class = "cloud"),
      div(class = "cloud")
  ),

  # Input caché pour gérer l'état
  textInput("display_mode", label = NULL, value = "home", width = "0px"),
  tags$style(type="text/css", "#display_mode {visibility: hidden; height: 0px;}"),

  # Page d'accueil
  conditionalPanel(
    condition = "input.display_mode == 'home'",
    div(class = "button-container",
        h1(class = "title", "Takuzu Game"),
        actionButton("start_button", "Jouer", class = "btn-custom"),
        br(),
        actionButton("rules_button", "Règles", class = "btn-custom")
    )
  ),

  # Page de sélection de taille
  conditionalPanel(
    condition = "input.display_mode == 'size_select'",
    div(class = "game-container",
        h2("Choisissez une taille de grille"),

        div(style = "display: flex; justify-content: center; flex-wrap: wrap;",
            div(id = "size_6", class = "size-option", onclick = "Shiny.setInputValue('select_size_6', Math.random())",
                div(class = "size-value", "6 x 6"),
                div(class = "size-desc", "Niveau facile")
            ),
            div(id = "size_8", class = "size-option", onclick = "Shiny.setInputValue('select_size_8', Math.random())",
                div(class = "size-value", "8 x 8"),
                div(class = "size-desc", "Niveau moyen")
            ),
            div(id = "size_10", class = "size-option", onclick = "Shiny.setInputValue('select_size_10', Math.random())",
                div(class = "size-value", "10 x 10"),
                div(class = "size-desc", "Niveau difficile")
            )
        ),

        actionButton("back_from_size", "Retour", class = "btn-custom")
    )
  ),

  # Page des règles
  conditionalPanel(
    condition = "input.display_mode == 'rules'",
    div(class = "game-container",
        div(class = "rules-section",
            h2("Règles du jeu Takuzu"),
            p("Chaque cellule de la grille doit être remplie soit par un 0, soit par un 1."),
            p("Chaque ligne et chaque colonne doivent contenir un nombre égal de 0 et de 1."),
            p("Il est interdit d'avoir trois 0 consécutifs ou trois 1 consécutifs dans une ligne ou une colonne."),
            p("Deux lignes ou deux colonnes identiques ne sont pas autorisées dans la même grille.\n"),
        h2("Stratégies pour résoudre un Takuzu"),
            p("Éviter les triplets : si deux 0 ou deux 1 sont consécutifs, la cellule suivante doit contenir l'autre chiffre."),
            p("Équilibrer les 0 et les 1 : une ligne ou une colonne ne peut pas contenir plus de la moitié de ses cellules avec le même chiffre."),
            p("Comparer les lignes et les colonnes complétées : si une ligne ou
              une colonne est presque remplie et qu'une autre est similaire, ajustez les chiffres pour éviter les doublons.")
        ),
        actionButton("back_from_rules", "Retour", class = "btn-custom")
    )
  ),

  # Page du jeu
  conditionalPanel(
    condition = "input.display_mode == 'game'",
    div(class = "game-container",
        h2("Jeu de Takuzu"),

        # Sélecteur de couleur
        div(class = "color-picker",
            pickerInput(
              inputId = "fixed_cell_color",
              label = "Couleur des cases initiales",
              choices = c("Gris clair" = "#e0e0e0",
                          "Bleu" = "#add8e6",
                          "Vert" = "#cdecc5",
                          "Jaune" = "#fffacd",
                          "Rose" = "#D8BFD8"),
              choicesOpt = list(
                style = c(
                  "background-color: #e0e0e0; color: black;",
                  "background-color: #add8e6; color: black;",
                  "background-color: #cdecc5; color: black;",
                  "background-color: #fffacd; color: black;",
                  "background-color: #D8BFD8; color: black;"
                )
              ),
              selected = "#D8BFD8"
            )
        ),

        # Grille interactive
        uiOutput("grid_ui"),

        # Boutons de contrôle
        div(
          actionButton("check_btn", "Vérifier", class = "btn-custom"),
          actionButton("new_game_btn", "Nouvelle partie", class = "btn-custom"),
          actionButton("back_to_home", "Retour", class = "btn-custom")
        ),

        # Slider de difficulté
        div(class = "difficulty-slider",
            sliderInput("difficulty", "Difficulté",
                        min = 1, max = 8, value = 5, step = 1,
                        width = "80%")
        )
    )
  )
)

# Serveur
server <- function(input, output, session) {
  # État du jeu actuel
  game_data <- reactiveVal(NULL)

  # Valeurs actuelles des cellules
  cell_values <- reactiveVal(matrix("", 6, 6))

  # Affichage de la taille actuelle
  output$game_size_display <- renderUI({
    grid_size <- as.numeric(input$grid_size)
    h3(paste0("Taille de la grille: ", grid_size, "x", grid_size))
  })

  # Aller à la page des règles
  observeEvent(input$rules_button, {
    updateTextInput(session, "display_mode", value = "rules")
  })

  # Retour à l'accueil depuis les règles
  observeEvent(input$back_from_rules, {
    updateTextInput(session, "display_mode", value = "home")
  })

  # Retour à l'accueil depuis la sélection de taille
  observeEvent(input$back_from_size, {
    updateTextInput(session, "display_mode", value = "home")
  })

  # Retour à l'accueil depuis le jeu
  observeEvent(input$back_to_home, {
    updateTextInput(session, "display_mode", value = "home")
  })

  # Aller à la page de changement de taille
  observeEvent(input$change_size_btn, {
    updateTextInput(session, "display_mode", value = "size_select")
  })

  # Lorsque l'utilisateur clique sur "Jouer"
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
      class = "takuzu-grid",
      lapply(1:6, function(row) {
        lapply(1:6, function(col) {
          cell_id <- paste0("cell_", row, "_", col)
          current_value <- values[row, col]

          # Vérifier si cette cellule est initialement remplie
          is_fixed <- initial_filled[row, col]

          # Classe CSS différente pour les cellules fixes
          cell_class <- if (is_fixed) {
            "takuzu-cell takuzu-cell-fixed"
          } else {
            "takuzu-cell takuzu-cell-editable"
          }

          # Style pour les cellules fixes avec la couleur sélectionnée
          cell_style <- if (is_fixed) {
            sprintf("background-color: %s;", fixed_color)
          } else {
            ""
          }

          actionButton(
            inputId = cell_id,
            label = current_value,
            class = cell_class,
            style = cell_style
          )
        })
      })
    )
  })

  # Gestion des clics sur les cellules
  observeEvent(input[["cell"]], {
    # Obtenir l'ID de la cellule cliquée - fonctionne avec shinyjs
    cell_id <- gsub("cell", "", input$cell)
    parts <- strsplit(cell_id, "_")[[1]]
    row <- as.numeric(parts[1])
    col <- as.numeric(parts[2])

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
      updateActionButton(session, paste0("cell_", row, "_", col), label = new_value)
    }
  }, ignoreNULL = FALSE, ignoreInit = TRUE)

  # Capturer les clics sur les cellules individuelles
  lapply(1:6, function(row) {
    lapply(1:6, function(col) {
      cell_id <- paste0("cell_", row, "_", col)

      observeEvent(input[[cell_id]], {
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
          updateActionButton(session, cell_id, label = new_value)
        }
      })
    })
  })

  # Mettre à jour les styles des cellules lorsque la couleur change
  observeEvent(input$fixed_cell_color, {
    req(game_data())  # S'assurer que game_data est initialisé

    data <- game_data()
    initial_filled <- data$initial_filled
    fixed_color <- input$fixed_cell_color

    # Parcourir toutes les cellules fixes et mettre à jour leur style
    for (row in 1:6) {
      for (col in 1:6) {
        if (initial_filled[row, col]) {
          cell_id <- paste0("cell_", row, "_", col)
          runjs(sprintf(
            "$('#%s').css('background-color', '%s');",
            cell_id, fixed_color
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
        title = "Grille incomplète",
        "Veuillez remplir toutes les cellules avant de vérifier.",
        easyClose = TRUE,
        footer = modalButton("OK")
      ))
      return()
    }

    # Vérifier si la grille est valide selon les règles du Takuzu
    correct <- all(values == data$solution)

    if (correct) {
      showModal(modalDialog(
        title = "Félicitations !",
        div(
          style = "text-align: center;",
          tags$h3("Bravo ! Vous avez résolu le puzzle correctement.")
        ),
        easyClose = TRUE,
        footer = modalButton("Continuer")
      ))
    } else {
      showModal(modalDialog(
        title = "Essayez encore",
        "Il y a des erreurs dans votre solution. Continuez à essayer !",
        easyClose = TRUE,
        footer = modalButton("OK")
      ))
    }
  })

  # Nouvelle partie
  observeEvent(input$new_game_btn, {
    # Obtenir la difficulté actuelle
    diff_level <- input$difficulty

    # Générer une nouvelle grille
    new_data <- generate_takuzu_grid(6, diff_level)
    game_data(new_data)
    cell_values(new_data$grid)

    # Afficher un message
    showNotification(
      "Nouvelle partie générée !",
      type = "message",
      duration = 3
    )
  })
}

# Lancer l'application
shinyApp(ui, server)
