# Takuzu_M1_SSD 

Welcome to our project for the HAX815X course for the academic year 2024-2025.
Our project is titled **Takuzu_M1_SSD**.\
The team members are :
- AIGOIN Emilie
- THOMAS Anne-Laure

## Introduction
The goal of this project is to develop a library in the R language, including an interactive Shiny application for the game Takuzu (a variant of Binairo).

## Introduction to Takuzu (Binairo)
Takuzu, also known as Binairo, is a combinatorial logic game played on a square grid, usually of size 6 × 6 or 8 × 8. It follows strict rules that are reminiscent of Sudoku and other logic placement games.

### Game Rules
- Each cell in the grid must be filled with either a 0 or a 1.
- Each row and each column must contain an equal number of 0s and 1s.
- It is forbidden to have three consecutive 0s or three consecutive 1s in a row or column.
- Two identical rows or two identical columns are not allowed in the same grid.

### Strategies for Solving a Takuzu
- **Avoiding Triples**: If two 0s or two 1s are consecutive, the next cell must contain the other digit.
- **Balancing 0s and 1s**: A row or column cannot contain more than half of its cells with the same digit.
- **Comparing Completed Rows and Columns**: If a row or column is almost filled and another is similar, adjust the digits to avoid duplicates.

Takuzu is an accessible game but becomes increasingly complex as the grid size increases.

Here is a diagram of the architecture of our project, detailing the location of each folder and file:

```Takuzu_M1_SSD/
    ├── Ideas.txt
    ├── README.md
    └── requirements.txt