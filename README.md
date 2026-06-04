# Data Wrangling Web App

An interactive R Shiny web application for loading, exploring, cleaning, and exporting CSV datasets. This project was built as a STAT 440 final project to make common data-wrangling tasks faster and more accessible through a simple browser-based interface.

## Features

- Upload a local CSV file or load a CSV from a URL
- Preview data in an interactive table
- Select, deselect, and keep specific columns
- Rename columns through the UI
- Move selected columns to the front of the dataset
- Filter numeric columns by range
- Filter text columns by keyword
- Reset applied filters
- Drop rows with missing values
- View dataset summary and structure
- Download the cleaned dataset as a CSV file

## Demo

The repository includes a demo video:

```text
App Demo.mp4
```

## Project Structure

```text
Data-Wrangling-Web-App/
├── final project.R
├── App Demo.mp4
└── README.md
```

| File | Description |
| --- | --- |
| `final project.R` | Main R Shiny application source code |
| `App Demo.mp4` | Video demonstration of the app workflow |
| `README.md` | Project documentation |

## Requirements

Install R and the required R packages:

```r
install.packages(c("shiny", "tidyverse", "DT"))
```

The app uses:

- `shiny` for the web application framework
- `tidyverse` for data loading and transformation
- `DT` for interactive data table rendering

## How to Run

1. Clone the repository:

   ```bash
   git clone https://github.com/williamwyh/Data-Wrangling-Web-App.git
   cd Data-Wrangling-Web-App
   ```

2. Open R or RStudio and install dependencies:

   ```r
   install.packages(c("shiny", "tidyverse", "DT"))
   ```

3. Run the app:

   ```r
   shiny::runApp("final project.R")
   ```

4. Use the sidebar to upload a CSV file or enter a CSV URL, then apply wrangling operations and download the cleaned result.

## Usage Workflow

```text
Load CSV
↓
Preview data
↓
Select or rename columns
↓
Rearrange columns
↓
Apply numeric or text filters
↓
Handle missing values
↓
Download cleaned CSV
```

## Notes

- The app is designed for comma-delimited CSV files.
- URL loading requires a direct and accessible CSV link.
- Filter reset restores the dataset to the state before the first filter was applied.
- The app is intended as an educational and productivity-focused data-wrangling tool.

## Author

Yuhong Wu
