

library(shinydashboard)

dashboardPage(
    dashboardHeader(title = "Plant Scoring"),
    
    
    dashboardSidebar(
        sidebarMenu(
            menuItem("Seminal roots", tabName = "seminals", icon = icon("dashboard")),
            menuItem("Tables", tabName = "tables", icon = icon("th")),
            menuItem("Settings", tabName = "settings", icon = icon("cog"))
        )
    ),
    
    
    
    dashboardBody(
        tabItems(
            # First tab content
            tabItem(tabName = "seminals",
                    fluidRow(
                        column(4,
                           wellPanel(
                                radioButtons("camera", "Choose camera", 
                                           c("A","B"), selected = c("A")),
                               selectInput("date", "Choose date", "wait"),
                               tags$hr(),
                               htmlOutput("to_do"),
                               htmlOutput("done")
                           )       
                        ),
                        column(8,
                               h2("How many seminals do you see?"),
                           actionButton("button_1", "1"),
                           actionButton("button_2", "2"),
                           actionButton("button_3", "3"),
                           actionButton("button_4", "4"),
                           actionButton("button_5", "5"),
                           actionButton("button_6", "6"),
                           actionButton("button_next", "> Next"),
                           tags$hr(),
                           htmlOutput("img_title"),
                           imageOutput("myImage", width="100%"),   
                           tags$hr()
                        )
                    )
            ),
            
            # Second tab content
            tabItem(tabName = "tables",
                    selectInput("select_table", label = "Choose table", choices = c("seminals")),
                    downloadButton("download_table_data", "Download"),
                    tags$hr(),
                    dataTableOutput("table_data")
            ),
            
            # Second tab content
            tabItem(tabName = "settings",
                    textInput("path", "Path to experimental folder", init_path),
                    actionButton("update_path", "Update"),
                    tags$hr(),
                    actionButton("create_database", "Create database")
            )
        )
    )
)
