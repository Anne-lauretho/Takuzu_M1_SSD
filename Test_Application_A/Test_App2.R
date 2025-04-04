# Charger les packages

library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(Grille2)

# Problèmes du code :
# 2. Les messsages de "félicitation" ou de "désolé essayez encore quand on vérifie la grille ne s'affichent pas

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
        overflow-y: scroll; */ défilement vertical */
        scroll-behavior: smooth; */ défilement fluide */
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

      .size-option {
        display: inline-block;
        width: 150px;
        height: 100px;
        margin: 15px;
        background-color: #8E1D7B;
        color: white;
        border-radius: 10px;
        border: 3px solid #5E0950;
        cursor: pointer;
        transition: all 0.3s;
        vertical-align: top;
        box-shadow: 3px 3px 5px rgba(0, 0, 0, 0.3);
      }

      .size-option:hover {
        background-color: #D8BFD8;
      }

      .size-value {
        font-size: 24px;
        font-weight: bold;
        margin-top: 20px;
      }

      .size-desc {
        font-size: 16px;
        margin-top: 10px;
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

  # Input caché pour gérer l'état et la taille
  textInput("display_mode", label = NULL, value = "home", width = "0px"),
  textInput("grid_size", label = NULL, value = "6", width = "0px"),
  tags$style(type="text/css", "#display_mode, #grid_size {visibility: hidden; height: 0px;}"),

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
            p("Le Takuzu est un jeu de logique qui se joue sur une grille comportant des cellules à remplir avec les chiffres 0 et 1, en respectant les règles suivantes :"),
            ul(
              li("Chaque cellule doit contenir soit un 0, soit un 1."),
              li("Chaque ligne et chaque colonne doivent comporter un nombre équivalent de 0 et de 1."),
              li("Il est interdit d’avoir plus de deux 0 ou deux 1 consécutifs dans une même ligne ou colonne."),
              li("Deux lignes ou deux colonnes identiques sont interdites dans une même grille.")
            ),
            h2("Stratégies pour résoudre un Takuzu"),
            p("Pour résoudre efficacement une grille de Takuzu, il est recommandé d'appliquer les stratégies suivantes :"),
            ul(
              li(strong("Éviter les triplets : "), "Lorsqu’une ligne ou une colonne contient déjà deux 0 ou deux 1 consécutifs, la cellule suivante doit impérativement contenir l’autre chiffre."),
              li(strong("Assurer l’équilibre : "), "Chaque ligne et chaque colonne doivent comporter un nombre équivalent de 0 et de 1. Il faut donc éviter de dépasser cette limite lors du remplissage."),
              li(strong("Comparer les lignes et les colonnes : "), "Lorsqu’une ligne ou une colonne est presque complétée, il convient de vérifier qu’elle ne soit pas identique à une autre déjà remplie et d’ajuster si nécessaire.")
            )
        ),
        actionButton("back_from_rules", "Retour", class = "btn-custom")
    )
  ),


  # Page du jeu
  conditionalPanel(
    condition = "input.display_mode == 'game'",
    div(class = "game-container",
        h2("Jeu de Takuzu"),

        # Affichage de la taille actuelle
        uiOutput("game_size_display"),

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
          actionButton("change_size_btn", "Changer taille", class = "btn-custom"),
          actionButton("back_to_home", "Retour", class = "btn-custom")
        ),

        div(
          style = "overflow-y: auto; max-height: 80vh; padding-bottom: 20px;",
          tableOutput("takuzu_grid")  # ou ton équivalent
        ),

        # Slider de difficulté
        div(class = "difficulty-slider",
            sliderInput("difficulty", "Difficulté",
                        min = 0.1, max = 0.8, value = 0.5, step = 0.1,
                        width = "80%")
        )
    )
  )
)

# Serveur
server <- function(input, output, session) {
  # État du jeu actuel
  game_data <- reactiveVal(NULL)

  # Taille actuelle de la grille (réactive)
  grid_size <- reactive({
    as.numeric(input$grid_size)
  })

  # Valeurs actuelles des cellules (réactives)
  cell_values <- reactiveVal(NULL)

  # Affichage de la taille actuelle
  output$game_size_display <- renderUI({
    size <- grid_size()
    h3(paste0("Taille de la grille: ", size, "x", size))
  })

  # Aller à la page de sélection de taille
  observeEvent(input$start_button, {
    updateTextInput(session, "display_mode", value = "size_select")
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

  # Sélection de la taille 6x6
  observeEvent(input$select_size_6, {
    updateTextInput(session, "grid_size", value = "6")

    # Générer la grille initiale
    game_data(generate_takuzu_grid(6, input$difficulty))

    # Initialiser les valeurs des cellules
    cell_values(game_data()$grid)

    # Passer à l'écran de jeu
    updateTextInput(session, "display_mode", value = "game")
  })

  # Sélection de la taille 8x8
  observeEvent(input$select_size_8, {
    updateTextInput(session, "grid_size", value = "8")

    # Générer la grille initiale
    game_data(generate_takuzu_grid(8, input$difficulty))

    # Initialiser les valeurs des cellules
    cell_values(game_data()$grid)

    # Passer à l'écran de jeu
    updateTextInput(session, "display_mode", value = "game")
  })

  # Sélection de la taille 10x10
  observeEvent(input$select_size_10, {
    updateTextInput(session, "grid_size", value = "10")

    # Générer la grille initiale
    game_data(generate_takuzu_grid(10, input$difficulty))

    # Initialiser les valeurs des cellules
    cell_values(game_data()$grid)

    # Passer à l'écran de jeu
    updateTextInput(session, "display_mode", value = "game")
  })

  # Génération dynamique de la grille UI
  output$grid_ui <- renderUI({
    req(game_data())  # S'assurer que game_data est initialisé

    size <- grid_size()
    data <- game_data()
    values <- cell_values()
    initial_filled <- data$initial_filled
    fixed_color <- input$fixed_cell_color

    # Ajuster dynamiquement le style de la grille selon la taille
    grid_width <- min(size * 50, 500)  # Limiter la largeur maximale

    # Style de la grille adapté à la taille
    grid_style <- sprintf("
      display: grid;
      grid-template-columns: repeat(%d, 1fr);
      gap: 5px;
      margin: 20px auto;
      width: %dpx;
    ", size, grid_width)

    tags$div(
      style = grid_style,
      lapply(1:size, function(row) {
        lapply(1:size, function(col) {
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

          # Ajuster la taille des cellules si la grille est grande
          cell_size <- max(30, min(50, 400/size))
          cell_style <- paste0(cell_style, sprintf("width: %dpx; height: %dpx; font-size: %dpx;",
                                                   cell_size, cell_size, cell_size * 0.5))

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

  # Observer dynamique pour les clics sur les cellules
  observe({
    req(game_data())
    size <- grid_size()

    # Créer des observateurs pour chaque cellule selon la taille actuelle
    lapply(1:size, function(row) {
      lapply(1:size, function(col) {
        cell_id <- paste0("cell_", row, "_", col)

        observeEvent(input[[cell_id]], {
          req(game_data())
          data <- game_data()
          initial_filled <- data$initial_filled

          # Ne pas permettre la modification des cellules initialement remplies
          if (row <= nrow(initial_filled) && col <= ncol(initial_filled) && !initial_filled[row, col]) {
            values <- cell_values()
            current_value <- values[row, col]

            # Changement cyclique : "" → "0" → "1" → ""
            new_value <- ifelse(current_value == "", "0",
                                ifelse(current_value == "0", "1", ""))

            values[row, col] <- new_value
            cell_values(values)
            updateActionButton(session, cell_id, label = new_value)
          }
        }, ignoreInit = TRUE)
      })
    })
  })

  # Mettre à jour les styles des cellules lorsque la couleur change
  observeEvent(input$fixed_cell_color, {
    req(game_data())
    size <- grid_size()
    data <- game_data()
    initial_filled <- data$initial_filled
    fixed_color <- input$fixed_cell_color

    # Parcourir toutes les cellules fixes et mettre à jour leur style
    for (row in 1:size) {
      for (col in 1:size) {
        if (row <= nrow(initial_filled) && col <= ncol(initial_filled) && initial_filled[row, col]) {
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
    req(game_data())
    size <- grid_size()
    data <- game_data()
    values <- cell_values()

    # Débogage
    print("Valeurs actuelles:")
    print(values)
    print("Solution attendue:")
    print(data$solution)

    # Vérifier que toutes les cellules sont remplies
    if (any(values == "")) {
      showModal(modalDialog(
        title = "Grille incomplète",
        HTML("<p style='color: black;'>Veuillez remplir toutes les cellules avant de vérifier.</p>"),
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
        HTML("<h3 style='color: black; text-align: center;'>Bravo ! Vous avez résolu le puzzle correctement.</h3>"),
        easyClose = TRUE,
        footer = modalButton("Continuer")
      ))
    } else {
      showModal(modalDialog(
        title = "Essayez encore",
        HTML("<p style='color: black;'>Il y a des erreurs dans votre solution. Continuez à essayer !</p>"),
        easyClose = TRUE,
        footer = modalButton("OK")
      ))
    }
  })

  # Nouvelle partie
  observeEvent(input$new_game_btn, {
    # Obtenir la taille et difficulté actuelles
    size <- grid_size()
    diff_level <- input$difficulty

    # Générer une nouvelle grille avec la taille actuelle
    new_data <- generate_takuzu_grid(size, diff_level)
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
