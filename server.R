
# Define server logic required to draw a histogram
library(shiny)

shinyServer(function(input, output, clientData, session) {
  
  rs <- reactiveValues(path = init_path,
                       data = NULL,
                       images = NULL,
                       current_image = NULL,
                       images_left = NULL,
                       update = 1)
  

  observeEvent(input$update_path, {
    rs$path <- input$path
  })  
  
  
  
  observeEvent(input$create_database, {
    
    tryCatch({
      #--------------------------------------------------
      # SETUP DATABASE
      file.copy(from = paste0(rs$path, "/aeroscan/data/database.sql"), 
                to = paste0(rs$path, "/aeroscan/data/database_",Sys.Date(),".sql"))
      con <- dbConnect(RSQLite::SQLite(), paste0(rs$path, "/aeroscan/data/database.sql"))
      #--------------------------------------------------
      # RESULTS TABLE
      seminals <- data.frame(Datetime = character(0), 
                             Folder = character(0), 
                             QR = character(0),
                             seminal_number = numeric(0))
      dbWriteTable(con, "seminals", seminals, overwrite = TRUE)
      
      showModal(modalDialog(
        title = "Success",
        "Database created"
      ))
    }, error=function(cond) {
      showModal(modalDialog(
        title = "Failure",
        "Could not create database"
      ))
    })
  })  
  
  
  # Load the data and update the input fields
  observe({
    req(rs$path)
    
    # load the entry files
    # data <- read_tsv(paste0(init_path, "/aeroscan/data/EntryFile_A.txt")) %>% mutate(Datetime = as.character(Datetime))
    tryCatch({
      data1 <- read_tsv(paste0(rs$path, "/aeroscan/data/EntryFile_A.txt")) %>% 
        mutate(Datetime = as.character(Datetime)) %>% 
        mutate(camera = "A")
      
      data2 <- read_tsv(paste0(rs$path, "/aeroscan/data/EntryFile_B.txt")) %>% 
        mutate(Datetime = as.character(Datetime)) %>% 
        mutate(camera = "B")
      
      rs$data <- rbind(data1, data2) %>% 
        mutate(Datetime = as.character(Datetime))
      
      updateSelectInput(session, "date", choices = unique(rs$data$Folder))  
    }, error=function(cond) {})
  })
  
  
  
  # Get the list of images
  observe({
    req(rs$data)
    req(rs$update)
    
    tryCatch({
      con = dbcon(rs$path)
      results <- dbReadTable(con, "seminals") %>% 
        filter(as.character(Folder) %in% input$date)
      dbDisconnect(con)
      
      rs$images <- rs$data %>% 
        filter(as.character(Folder) %in% input$date) %>% 
        filter(!QR %in% results$QR) %>% 
        filter(camera %in% input$camera) %>% 
        select(Filename, QR, Datetime) %>% 
        group_by(QR) %>% 
        distinct(QR, .keep_all = TRUE) %>% 
        ungroup() 
    
      rs$image_left <- nrow(rs$images)
    }, error=function(cond) {})
  })
  
  # Select one image to display
  observe({
    req(rs$update)
    req(rs$images)
    rs$current_image <- rs$images %>% slice(1)
  })
  
  
  
  # Show the data in a table
  output$table_data = renderDataTable({
    
    con = dbcon(rs$path)
    temp <- dbReadTable(con, input$select_table)
    dbDisconnect(con)
    
    dt <- as.datatable(formattable(temp),
    rownames = F,
    options = list(pageLength = 50))
    
    dt
  })
  
  # Download a csv file of the selected dataset
  output$download_table_data <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_", input$select_table, ".csv")
    },
    content = function(file) {
      
      con = dbcon(rs$path)
      temp <- dbReadTable(con, input$select_table) 
      dbDisconnect(con)
      
      write.csv(temp, file, row.names = FALSE)
    }
  )

  
  # Display the image
  output$myImage <- renderImage({
    req(rs$current_image)
    req(rs$update)
    
    if(is.null(rs$current_image)) return(NULL)
    
    temp <- rs$data %>% 
      filter(Filename == rs$current_image$Filename) %>% 
      slice(1)
    
    if(temp$camera == "A") cam <- "camera1"
    else cam <- "camera2"
    
    filename <- normalizePath(file.path(rs$path,
                                        "images",
                                        cam,
                                        temp$Folder, 
                                        temp$Filename))
    
    # Return a list containing the filename and alt text
    list(src = filename,
         alt = paste("Image number", temp$Filename))
  }, deleteFile = F)
  
  
  # The image title
  output$img_title <- renderText({
    req(rs$current_image)
    req(rs$update)
    temp <- rs$data %>% 
      filter(Filename == rs$current_image$Filename) %>% 
      slice(1)
    text <- paste0("<h3>",temp$QR,"</h3>",
                   "<b>Filename</b> = ",temp$Filename,
                   " / <b>Datetime</b> = ", temp$Datetime,
                   " / <b>Folder</b> = ", temp$Folder,
                   "<br><b>Images left</b> = ", rs$image_left)
    text
  })
  
  
  
  observeEvent(input$button_1, {
    req(rs$current_image)
    temp <- rs$data %>% 
      filter(Filename == rs$current_image$Filename) %>% 
      slice(1)
    
    temp2 <- data.frame(Datetime = temp$Datetime,
                        Folder = as.character(temp$Folder),
                        QR = temp$QR,
                        seminal_number = 1)
    con = dbcon(rs$path) 
    dbWriteTable(con, "seminals", temp2, append = TRUE)   
    dbDisconnect(con)
    rs$current_image <- NULL
    rs$update <- -rs$update
  })
  
  observeEvent(input$button_2, {
    req(rs$current_image)
    temp <- rs$data %>% 
      filter(Filename == rs$current_image$Filename) %>% 
      slice(1)
    
    temp2 <- data.frame(Datetime = temp$Datetime,
                        Folder = as.character(temp$Folder),
                        QR = temp$QR,
                        seminal_number = 2)
    con = dbcon(rs$path) 
    dbWriteTable(con, "seminals", temp2, append = TRUE)   
    dbDisconnect(con)
    rs$current_image <- NULL
    rs$update <- -rs$update
  })
  
  observeEvent(input$button_3, {
    req(rs$current_image)
    temp <- rs$data %>% 
      filter(Filename == rs$current_image$Filename) %>% 
      slice(1)
    
    temp2 <- data.frame(Datetime = temp$Datetime,
                        Folder = as.character(temp$Folder),
                        QR = temp$QR,
                        seminal_number = 3)
    con = dbcon(rs$path) 
    dbWriteTable(con, "seminals", temp2, append = TRUE)   
    dbDisconnect(con)
    rs$current_image <- NULL
    rs$update <- -rs$update
  })
  
  observeEvent(input$button_4, {
    req(rs$current_image)
    temp <- rs$data %>% 
      filter(Filename == rs$current_image$Filename) %>% 
      slice(1)
    
    temp2 <- data.frame(Datetime = temp$Datetime,
                        Folder = as.character(temp$Folder),
                        QR = temp$QR,
                        seminal_number = 4)
    con = dbcon(rs$path) 
    dbWriteTable(con, "seminals", temp2, append = TRUE)   
    dbDisconnect(con)
    rs$current_image <- NULL
    rs$update <- -rs$update
  })
  
  observeEvent(input$button_5, {
    req(rs$current_image)
    temp <- rs$data %>% 
      filter(Filename == rs$current_image$Filename) %>% 
      slice(1)
    
    temp2 <- data.frame(Datetime = temp$Datetime,
                        Folder = as.character(temp$Folder),
                        QR = temp$QR,
                        seminal_number = 5)
    con = dbcon(rs$path) 
    dbWriteTable(con, "seminals", temp2, append = TRUE)   
    dbDisconnect(con)
    rs$current_image <- NULL
    rs$update <- -rs$update
  })
  
  observeEvent(input$button_6, {
    req(rs$current_image)
    temp <- rs$data %>% 
      filter(Filename == rs$current_image$Filename) %>% 
      slice(1)
    
    temp2 <- data.frame(Datetime = temp$Datetime,
                        Folder = as.character(temp$Folder),
                        QR = temp$QR,
                        seminal_number = 6)
    con = dbcon(rs$path) 
    dbWriteTable(con, "seminals", temp2, append = TRUE)   
    dbDisconnect(con)
    rs$current_image <- NULL
    rs$update <- -rs$update
  })
  
  
})




