

library(shinydashboard)

dashboardPage(
    dashboardHeader(title = "Plant Scoring"),
    
    
    dashboardSidebar(
        sidebarMenu(
            menuItem("Scoring", tabName = "scoring", icon = icon("dashboard")),
            menuItem("Tables", tabName = "tables", icon = icon("th"))
        )
    ),
    
    
    
    dashboardBody(
        tabItems(
            # First tab content
            tabItem(tabName = "scoring",
                    fluidRow(
                        column(4,
                           wellPanel(
                               textInput("path", "Path to experimental folder", init_path),
                               actionButton("update_path", "Update"),
                                radioButtons("camera", "Choose camera", 
                                           c("A","B"), selected = c("A")),
                               selectInput("date", "Choose date", "wait"),
                               tags$hr(),
                               htmlOutput("to_do"),
                               htmlOutput("done")
                           )       
                        ),
                        column(4,
                           actionButton("button_1", "1"),
                           actionButton("button_2", "2"),
                           actionButton("button_3", "3"),
                           actionButton("button_4", "4"),
                           actionButton("button_5", "5"),
                           actionButton("button_6", "6"),
                           tags$hr(),
                           htmlOutput("img_title"),
                           imageOutput("myImage", width="100%"),   
                           tags$hr()
                        )
                    )
            ),
            
            # Second tab content
            tabItem(tabName = "tables",

                    selectInput("select_table", label = "Choose table", choices = c("results")),
                    downloadButton("download_table_data", "Download"),
                    tags$hr(),
                    dataTableOutput("table_data")
                    
                    
            )
        )
    )
)
