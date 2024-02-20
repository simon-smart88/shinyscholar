core_code_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    radioButtons(ns("code_choice"),"Choose file", choices=c('Module','Function','Markdown'),selected='Module'),
    verbatimTextOutput(ns("code_module"))
  )
}

core_code_module_server <- function(id, common, module) {
  moduleServer(id, function(input, output, session) {
    output$code_module <- renderPrint({
      req(module != "")
      req(module != "intro")
      if (input$code_choice == "Module"){
        code <- readLines(system.file(glue("shiny/modules/{module}.R"), package = "shinyscholar"))
      }
      if (input$code_choice == "Function"){
        #separate call required in case there are multiple functions
        ga_call <- getAnywhere(module)
        code <- capture.output(print(getAnywhere(module)[which(ga_call$where == "package:shinyscholar")]))
        code <- code[1:(length(code)-2)]
      }
      if (input$code_choice == "Markdown"){
        if (file.exists(system.file(glue::glue("shiny/modules/{module}.Rmd"), package = "shinyscholar"))){
          code <- readLines(system.file(glue::glue("shiny/modules/{module}.Rmd"), package = "shinyscholar"))
        } else {
          code <- "There is no markdown file for this module"
        }
      }
      cat(code, sep = "\n")
    })
  })
}
