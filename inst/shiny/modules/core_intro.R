core_intro_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    actionButton(ns("intro"), "Start tour")
  )
}

core_intro_module_server <- function(id, common, parent_session) {
  moduleServer(id, function(input, output, session) {
    #Steps in the introduction - the element to tag, the message to display, position of the tooltip, any javascript needed to move between tabs / click buttons
    steps <- data.frame(c(NA, "Welcome to Shinyscholar! This tour will show you various features of the application to help get you started", NA, NA),
                        c("div[class=\"well\"]", "This panel shows all of the possible steps in the analysis", "bottom", NA),
                        c("a[data-value=\"How To Use\"]", "Detailed instructions can be found in the How To Use tab", "bottom","$('a[data-value=\"intro\"]').removeClass('active');
                                                                                                                            $('a[data-value=\"How To Use\"]').trigger('click');
                                                                                                                            $('a[data-value=\"How To Use\"]').addClass('active');"),
                        c("a[data-value=\"select\"]", "Click on the tabs to move between components", "bottom", "$('a[data-value=\"How To Use\"]').removeClass('active');
                                                                                                          $('a[data-value=\"select\"]').trigger('click');
                                                                                                          $('a[data-value=\"select\"]').addClass('active');"),
                        c("#selectHelp", "Click on the question mark to view instructions for the component", "bottom", "$('a[data-value=\"select\"]').removeClass('active');
                                                                                                                     $('a[data-value=\"Component Guidance\"]').trigger('click');
                                                                                                                     $('a[data-value=\"Component Guidance\"]').addClass('active');"),
                        c("#selectSel", "Select a module to load the options", "bottom", "$('a[data-value=\"Component Guidance\"]').removeClass('active');
                                                                                      $('a[data-value=\"Map\"]').trigger('click');
                                                                                      $('a[data-value=\"Map\"]').addClass('active');
                                                                                      $('input[value=\"select_query\"]').trigger('click');"),
                        c("#select_queryHelp", "Click on the question mark to view instructions for the module", "bottom", "$('a[data-value=\"Map\"]').removeClass('active');
                                                                                                                        $('a[data-value=\"Module Guidance\"]').trigger('click');
                                                                                                                        $('a[data-value=\"Module Guidance\"]').addClass('active');"),
                        c("div[class=\"form-group shiny-input-container\"]", "Choose from the list of options", "bottom", "$('a[data-value=\"Module Guidance\"]').removeClass('active');
                                                                                                                       $('a[data-value=\"Map\"]').trigger('click');
                                                                                                                       $('a[data-value=\"Map\"]').addClass('active');"),
                        c("#select_query-run", "Click the button to run the module", "bottom", NA),
                        c("a[data-value=\"Map\"]", "Outputs will be loaded onto the Map...", "bottom", NA),
                        c("a[data-value=\"Table\"]", "or the Table...", "bottom", "$('a[data-value=\"Map\"]').removeClass('active');
                                                                               $('a[data-value=\"Table\"]').trigger('click');
                                                                               $('a[data-value=\"Table\"]').addClass('active');"),
                        c("a[data-value=\"Results\"]", "or the Results tabs depending on the module", "bottom", "$('a[data-value=\"Table\"]').removeClass('active');
                                                                                                             $('a[data-value=\"Results\"]').trigger('click');
                                                                                                             $('a[data-value=\"Results\"]').addClass('active');"),
                        c("div[id=\"messageLog\"]", "Messages will appear in the log window", "bottom", NA),
                        c("a[data-value=\"Code\"]", "You can view the source code for the module", "left","$('a[data-value=\"Results\"]').removeClass('active');
                                                                                                       $('a[data-value=\"Code\"]').trigger('click');
                                                                                                       $('a[data-value=\"Code\"]').addClass('active');"),
                        c("a[data-value=\"rep\"]", "You can download code to reproduce your analysis in the Session Code module", "bottom","$('a[data-value=\"Code\"]').removeClass('active');
                                                                                                                                             $('a[data-value=\"rep\"]').trigger('click');
                                                                                                                                             $('a[data-value=\"rep\"]').addClass('active');
                                                                                                                                             $('input[value=\"rep_markdown\"]').trigger('click');"),
                        c("a[data-value=\"select\"]", "When you are inside an analysis component...","bottom", "$('a[data-value=\"rep\"]').removeClass('active');
                                                                                                             $('a[data-value=\"select\"]').trigger('click');
                                                                                                             $('a[data-value=\"select\"]').addClass('active');"),
                        c("a[data-value=\"Save\"]", "you can download a file which saves the state of the app", "left", "$('a[data-value=\"Save\"]').trigger('click');
                                                                                                                              $('a[data-value=\"Save\"]').addClass('active');"),
                        c("a[data-value=\"intro\"]", "Next time you visit...", "bottom", "$('a[data-value=\"select\"]').removeClass('active');
                                                                                                                     $('a[data-value=\"intro\"]').trigger('click');
                                                                                                                     $('a[data-value=\"intro\"]').addClass('active');"),
                        c("a[data-value=\"Load Prior Session\"]", "you can upload the file to restore the app", "left","$('a[data-value=\"Load Prior Session\"]').trigger('click');
                                                                                                                     $('a[data-value=\"Load Prior Session\"]').addClass('active');"),
                        c(NA, "You are ready to go!", NA, "$('a[data-value=\"About\"]').trigger('click');
                                                         $('a[data-value=\"About\"]').addClass('active');")
    )
    #transpose and add columns names
    steps <- as.data.frame(t(steps))
    colnames(steps) <- c("element", "intro", "position", "javascript")

    #extract the javascript into one string
    intro_js <- ""
    for (r in 1:nrow(steps)){
      if (!is.na(steps$javascript[r])){
        intro_js <- paste(intro_js, glue::glue("if (this._currentStep == {r-1} ) {{ {steps$javascript[r]} }}"))
      }
    }
    intro_js <- gsub("[\r\n]", "", intro_js)

    intro_cookie_value <- reactive({
      cookie_value <- cookies::get_cookie(cookie_name = "intro")
      return(cookie_value)
    })

    #launch intro if the intro cookie is empty
    #prevent running in test mode as the popup blocks other interactions
    observeEvent(
      once = TRUE,
      intro_cookie_value,
      {
        if (is.null(intro_cookie_value()) & (isTRUE(getOption("shiny.testmode")) == FALSE)) {
          rintrojs::introjs(session, options = list(steps = steps, "showBullets" = "true", "showProgress" = "true",
                                                    "showStepNumbers" = "false", "nextLabel" = "Next", "prevLabel" = "Prev", "skipLabel" = "Skip"),
                            events = list(onbeforechange = I(intro_js)))
          cookies::set_cookie(cookie_name = "intro",  cookie_value = TRUE, expiration = 365)
        }
      })

    #launch intro if the button is clicked
    observeEvent(input$intro,{
      rintrojs::introjs(session, options = list(steps = steps, "showBullets" = "true", "showProgress" = "true",
                                                "showStepNumbers" = "false", "nextLabel" = "Next", "prevLabel" = "Prev", "skipLabel" = "Skip"),
                        events = list(onbeforechange = I(intro_js))
      )})
    })}
