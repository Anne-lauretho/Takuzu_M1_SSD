#' Create a Takuzu Grid
#'
#' This function creates a valid Takuzu grid puzzle with its solution.
#' Takuzu is a binary puzzle where each row and column must contain an equal number of 0s and 1s,
#' with no more than two identical numbers adjacent to each other, and no two rows or columns can be identical.
#'
#' @param n Integer. The size of the grid (n x n). Default is 6.
#' @param difficulty Numeric between 0 and 1. Controls how many cells are initially empty. Default is 0.5.
#'
#' @return A list containing:
#'   \item{grid}{The puzzle grid with empty cells represented by ""}
#'   \item{solution}{The complete solution grid}
#'   \item{initial_filled}{A logical matrix indicating which cells were initially filled}
#'
#' @export
generate_takuzu_grid <- function(n, difficulty) {
  # Générer une grille complète valide
  full_grid <- function() {
    grid <- matrix(rep("", n * n), nrow = n)

    check_valid <- function(grid, row, col, value) {
      grid[row, col] <- value

      if (sum(grid[row, ] == "0") > n / 2 || sum(grid[row, ] == "1") > n / 2) return(FALSE)
      if (sum(grid[, col] == "0") > n / 2 || sum(grid[, col] == "1") > n / 2) return(FALSE)

      row_seq <- rle(grid[row, ])
      col_seq <- rle(grid[, col])

      if (any(row_seq$lengths[row_seq$values == "0"] >= 3) ||
          any(row_seq$lengths[row_seq$values == "1"] >= 3)) return(FALSE)

      if (any(col_seq$lengths[col_seq$values == "0"] >= 3) ||
          any(col_seq$lengths[col_seq$values == "1"] >= 3)) return(FALSE)

      return(TRUE)
    }

    backtrack <- function(grid, row = 1, col = 1) {
      if (row > n) return(grid)

      if (col > n) {
        return(backtrack(grid, row + 1, 1))
      }

      for (value in c("0", "1")) {
        if (check_valid(grid, row, col, value)) {
          grid[row, col] <- value
          result <- backtrack(grid, row, col + 1)
          if (!is.null(result)) return(result)
          grid[row, col] <- ""
        }
      }

      return(NULL)
    }

    return(backtrack(grid))
  }

  # Générer une grille complète
  complete_grid <- full_grid()
  solution <- complete_grid  # Sauvegarder la solution complète

  # Créer la grille de puzzle en laissant certaines cellules vides
  puzzle_grid <- complete_grid

  # Calculer le nombre de cellules à laisser vides
  cells_to_remove <- round(n * n * difficulty)

  # Supprimer des cellules de manière aléatoire
  remove_indices <- sample(1:(n*n), cells_to_remove)
  puzzle_grid[remove_indices] <- ""

  # Créer une matrice booléenne pour les cellules initialement remplies
  initial_filled <- puzzle_grid != ""

  return(list(
    grid = puzzle_grid,
    solution = solution,
    initial_filled = initial_filled
  ))
}

