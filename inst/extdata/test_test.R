test_test_module_ui <- function(id){
  ns <- shiny::NS(id)
  tagList(
    checkboxInput(ns("checkbox"), "Checkbox", value = TRUE),
    checkboxGroupInput(ns("checkboxgroup"), "Checkbox", choices = c("A", "B", "C")),
    dateInput(ns("date"), "Date"),
    dateRangeInput(ns("daterange"), "Daterange"),
    fileInput(ns("file"), "File"),
    numericInput(ns("numeric"), "Numeric", value = 5),
    radioButtons(ns("radio"), "Radio", choices = c("A", "B", "C")),
    selectInput(ns("select"), "Select", choices = c("A", "B", "C")),
    sliderInput(ns("slider"), "Slider", min = 1, max = 10, value = 5),
    textInput(ns("text"), "Text"),
    textInput(ns('single_quote'), 'Text')
  )
}

test_test_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

    # METADATA ####

  })

  return(list(
    save = function() {
    },
    load = function(state) {
    }
  ))
}

test_test_module_rmd <- function(common) {

}
