#' Create a Grid
#'
#' This function creates a grid of points with specified size and spacing.
#'
#' @param n_rows Number of rows in the grid.
#' @param n_cols Number of columns in the grid.
#' @param spacing Spacing between grid points.
#'
#' @return A data frame with x and y coordinates.
#' @export
create_grid <- function(n_rows = 10, n_cols = 10, spacing = 1) {
  x <- rep(1:n_cols * spacing, times = n_rows)
  y <- rep(1:n_rows * spacing, each = n_cols)
  grid <- data.frame(x = x, y = y)
  return(grid)
}
