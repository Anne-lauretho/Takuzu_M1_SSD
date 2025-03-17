#' Check if a Takuzu Grid is Valid
#'
#' This function checks if a given Takuzu grid follows all the rules.
#'
#' @param grid Matrix. The grid to check.
#'
#' @return Logical. TRUE if the grid is valid, FALSE otherwise.
#'
#' @export
check_takuzu_grid <- function(grid) {
  n <- nrow(grid)

  # Vérifier que chaque ligne et colonne a le même nombre de 0 et 1
  for (i in 1:n) {
    if (sum(grid[i, ] == "0", na.rm = TRUE) != sum(grid[i, ] == "1", na.rm = TRUE)) return(FALSE)
    if (sum(grid[, i] == "0", na.rm = TRUE) != sum(grid[, i] == "1", na.rm = TRUE)) return(FALSE)
  }

  # Vérifier qu'il n'y a pas plus de 2 chiffres identiques adjacents
  for (i in 1:n) {
    row_seq <- rle(grid[i, ])
    col_seq <- rle(grid[, i])

    if (any(row_seq$lengths[row_seq$values == "0"] > 2) ||
        any(row_seq$lengths[row_seq$values == "1"] > 2)) return(FALSE)

    if (any(col_seq$lengths[col_seq$values == "0"] > 2) ||
        any(col_seq$lengths[col_seq$values == "1"] > 2)) return(FALSE)
  }

  # Vérifier qu'il n'y a pas deux lignes ou colonnes identiques
  for (i in 1:(n-1)) {
    for (j in (i+1):n) {
      if (all(grid[i, ] == grid[j, ])) return(FALSE)
      if (all(grid[, i] == grid[, j])) return(FALSE)
    }
  }

  return(TRUE)
}
