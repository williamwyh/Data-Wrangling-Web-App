############################################################
# STAT 440 FINAL PROJECT - DATA WRANGLING SHINY APP
# Student: Yuhong Wu
# Video Demonstration Link: https://drive.google.com/file/d/1jKzC4bzFv2fU0zWn-KYZfU5ZK6t0ysKB/view?usp=sharing
############################################################

library(shiny)
library(tidyverse)
library(DT)

ui <- fluidPage(
  titlePanel("STAT 440 Final Project by Yuhong Wu"),
  
  sidebarLayout(
    sidebarPanel(
      
      # 1. Load Dataset
      h3("1. Load Dataset"),
      radioButtons("load_type", "Choose data source:",
                   choices = c("Upload local CSV" = "local", "Enter CSV URL" = "url")),
      
      conditionalPanel(
        condition = "input.load_type == 'local'",
        fileInput("file_local", "Upload CSV File", accept = ".csv")
      ),
      
      conditionalPanel(
        condition = "input.load_type == 'url'",
        textInput("file_url", "CSV URL:", placeholder = "https://example.com/data.csv")
      ),
      
      # 2. Select Columns
      h3("2. Select Columns"),
      actionButton("select_all", "Select All Columns"),
      actionButton("deselect_all", "Deselect All Columns"),
      uiOutput("column_selector"),
      
      # 3. Rename Columns
      h3("3. Rename Column"),
      selectInput("col_to_rename", "Select column to rename:", choices = NULL),
      textInput("new_col_name", "New column name:"),
      actionButton("apply_rename", "Rename Column"),
      
      # 4. Rearrange Columns
      h3("4. Rearrange Column"),
      selectInput("col_to_front", "Move column to front:", choices = NULL),
      actionButton("apply_move_front", "Move to First Column"),
      
      # 5. Filtering Columns
      h3("5. Filtering Column"),
      selectInput("filter_column", "Column to filter:", choices = NULL),
      uiOutput("filter_controls"),
      actionButton("apply_filter", "Apply Filter"),
      actionButton("reset_filter", "Reset Filter"),
      
      # 6. Missing value handling
      h3("6. Missing Value Handling"),
      actionButton("apply_drop_na", "Drop Rows with Missing Values"),
      
      # 7. Download
      h3("7. Download Current Data"),
      downloadButton("download_data", "Download CSV")
    ),
    
    # Main Panel Outputs
    mainPanel(
      tabsetPanel(
        tabPanel("Data Preview", DTOutput("data_preview")),
        tabPanel("Summary", verbatimTextOutput("data_summary")),
        tabPanel("Structure", verbatimTextOutput("data_str")),
        
        # App introduction
        tabPanel("About This App",
                 h3("Purpose of This App"),
                 p("This Shiny app is designed as a data-wrangling tool that works with any comma-delimited CSV file.
                   The app allows users to quickly load data from either a local file or a URL, explore its structure, and perform essential wrangling tasks.
                   Its features include selecting and reordering columns, renaming variables, filtering rows based on text or numeric conditions, removing missing values, and downloading the cleaned dataset."),
                 h3("App highlights"),
                 p("I designed this app to create a practical and efficient data wrangling tool.
                   I added several creative features which are useful from my perspective to streamline the workflow.
                   These include one-click actions such as selecting all columns, resetting all filters, handling missing values, and downloading the current dataset at any time.
                   By building these tools into an interactive interface, I aimed to make common wrangling steps faster, more accessible, and more intuitive.")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  dataset <- reactiveVal(NULL) # Current working dataset
  filter_backup <- reactiveVal(NULL) # Backup for reset filter
  
  # Load data (with error handling)
  observeEvent({
    if (input$load_type == "local") input$file_local else input$file_url
  }, ignoreInit = TRUE, {
    df <- NULL
    if (input$load_type == "local") { # Local file input
      req(input$file_local)
      df <- tryCatch(read_csv(input$file_local$datapath), error = function(e) {
        showNotification("Error: Unable to read CSV file.", type = "error")
        return(NULL)
      })
    } else { # URL input
      req(input$file_url)
      df <- tryCatch(read_csv(input$file_url), error = function(e) {
          showNotification("Invalid or inaccessible URL.", type = "error")
          return(NULL)
        })
    }
    
    if (!is.null(df)) { # initialization
      dataset(df)
      filter_backup(NULL)
      showNotification("Dataset loaded successfully.", type = "message")
    } else {
      dataset(NULL)
    }
  })
  
  # Update dropdowns when dataset changes
  observeEvent(dataset(), { 
    req(dataset())
    updateSelectInput(session, "col_to_rename", choices = names(dataset()))
    updateSelectInput(session, "col_to_front", choices = names(dataset()))
    updateSelectInput(session, "filter_column", choices = names(dataset()))
  })
  
  # Column selector UI
  output$column_selector <- renderUI({
    req(dataset())
    checkboxGroupInput("selected_cols", "Choose columns to keep:", choices = names(dataset()), selected = names(dataset()))
  })
  observeEvent(input$select_all, {
    updateCheckboxGroupInput(session, "selected_cols", selected = names(dataset()))
  })
  observeEvent(input$deselect_all, {
    updateCheckboxGroupInput(session, "selected_cols", selected = character(0))
  })
  
  # Filtered Data (subset by selected columns)
  filtered_data <- reactive({
    req(dataset())
    dataset()[, input$selected_cols]
  })
  
  # Rename column
  observeEvent(input$apply_rename, {
    req(dataset(), input$col_to_rename, input$new_col_name)
    df <- dataset()
    names(df)[names(df) == input$col_to_rename] <- input$new_col_name
    dataset(df)
  })
  
  # Move column to front
  observeEvent(input$apply_move_front, {
    req(dataset(), input$col_to_front)
    df <- dataset()
    col <- input$col_to_front
    df <- df[, c(col, setdiff(names(df), col))]
    dataset(df)
  })
  
  # Filtering UI
  output$filter_controls <- renderUI({
    req(dataset(), input$filter_column)
    col <- dataset()[[input$filter_column]]
    if (is.numeric(col)) {
      tagList(
        numericInput("filter_min", "Min value:", min(col, na.rm = TRUE)),
        numericInput("filter_max", "Max value:", max(col, na.rm = TRUE))
      )
    } else {
      textInput("filter_text", "Contains text:")
    }
  })
  
  # Apply filter
  observeEvent(input$apply_filter, {
    req(dataset(), input$filter_column)
    if (is.null(filter_backup())) { # backup only once
      filter_backup(dataset())
    }
    df <- dataset()
    col <- input$filter_column
    if (is.numeric(df[[col]])) { # Numeric filter between min and max
      df <- df %>% filter(.data[[col]] >= input$filter_min & .data[[col]] <= input$filter_max)
    } else { # Text filter
      df <- df %>% filter(str_detect(.data[[col]], fixed(input$filter_text, ignore_case = TRUE)))
    }
    dataset(df)
  })
  
  # Reset filter
  observeEvent(input$reset_filter, {
    req(filter_backup())
    dataset(filter_backup())
    filter_backup(NULL)
  })
  
  # Drop NA
  observeEvent(input$apply_drop_na, {
    req(dataset())
    dataset(dataset() %>% drop_na())
  })
  
  # Download CSV
  output$download_data <- downloadHandler(
    filename = function() paste0("cleaned_data_", Sys.Date(), ".csv"),
    content = function(file) {
      write_csv(filtered_data(), file)
    }
  )
  
  # Data Preview
  output$data_preview <- renderDT({
    req(filtered_data())
    datatable(filtered_data(), options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Data Summary
  output$data_summary <- renderPrint({
    req(filtered_data())
    summary(filtered_data())
  })
  
  # Data Structure
  output$data_str <- renderPrint({
    req(filtered_data())
    str(filtered_data())
  })
}

shinyApp(ui, server)
