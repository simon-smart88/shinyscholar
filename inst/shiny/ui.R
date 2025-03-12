resourcePath <- system.file("shiny", "www", package = "shinyscholar")
shiny::addResourcePath("resources", resourcePath)

tagList(
  rintrojs::introjsUI(),
  shinyjs::useShinyjs(),
  shinyjs::extendShinyjs(
    script = file.path("resources", "js", "shinyjs-funcs.js"),
    functions = c("scrollLogger", "disableModule", "enableModule")
  ),
  navbarPage(
    theme = bslib::bs_theme(version = 5,
                            bootswatch = "spacelab"),
    id = "tabs",
    collapsible = TRUE,
    header = tagList(
      tags$head(tags$link(href = "css/styles.css", rel = "stylesheet"),
                # run current module on enter key press
                tags$script(HTML("$(document).on('keydown', function(e) {
                                    if (e.keyCode == 13) {
                                      Shiny.onInputChange('run_module', new Date().getTime());
                                    }
      });"))
    )),
    title = img(src = "logo.png", height = "50", width = "50",
                style = "margin-top: -15px"),
    windowTitle = "shinyscholar",

    tabPanel("Intro", value = "intro"),
    tabPanel("Select data", value = "select"),
    tabPanel("Plot data", value = "plot"),
    tabPanel("Reproduce", value = "rep"),
    tabPanel("Template", value = "template"),
    navbarMenu("Support", icon = icon("life-ring"),
               HTML('<a href="https://github.com/simon-smart88/shinyscholar/issues" target="_blank">GitHub Issues</a>'),
               HTML('<a href="mailto: simon.smart@cantab.net" target="_blank">Send Email</a>')),
    tabPanel(NULL, icon = icon("power-off"), value = "_stopapp")
  ),
  tags$div(
    class = "container-fluid",
    fluidRow(
      column(
        4,
        wellPanel(
          conditionalPanel(
            "input.tabs == 'intro'",
            includeMarkdown("Rmd/text_intro_tab.Rmd")
          ),
          # SELECT DATA ####
          conditionalPanel(
            "input.tabs == 'select'",
            div("Component: Select Data", class = "componentName"),
            help_comp_ui("selectHelp"),
            radioButtons(
              "selectSel", "Modules Available:",
              choices = insert_modules_options("select"),
              selected = character(0)
            ),
            tags$hr(),
            insert_modules_ui("select")
          ),
          # PLOT DATA ####
          conditionalPanel(
            "input.tabs == 'plot'",
            div("Component: Plot Data", class = "componentName"),
            help_comp_ui("plotHelp"),
            radioButtons(
              "plotSel", "Modules Available:",
              choices = insert_modules_options("plot"),
              selected = character(0)
            ),
            tags$hr(),
            insert_modules_ui("plot")
          ),
          # REPRODUCIBILITY
          conditionalPanel(
            "input.tabs == 'rep'",
            div("Component: Reproduce", class = "componentName"),
            radioButtons(
              "repSel", "Modules Available:",
              choices = insert_modules_options("rep"),
              selected = character(0)
            ),
            tags$hr(),
            insert_modules_ui("rep")
          ),
          # TEMPLATE
          conditionalPanel(
            "input.tabs == 'template'",
            div("Component: Template", class = "componentName"),
            radioButtons(
              "templateSel", "Modules Available:",
              choices = insert_modules_options("template")
            ),
            tags$hr(),
            insert_modules_ui("template")
          )
        )
      ),
      # --- RESULTS WINDOW ---
      column(
        8,
        conditionalPanel(
          "input.tabs != 'intro' & input.tabs != 'rep'",
          fixedRow(
            column(
              4,
              strong("Global settings"),
              br(),
              actionButton("reset", "Delete data"),
            ),
            column(
              2,
              align = "left",
              div(style = "margin-top: -10px"),
              strong("Log window"),
              div(style = "margin-top: 5px"),
              div(
                id = "messageLog",
                div(id = "logHeader", div(id = "logContent"))
              ),
            )
          )
          ,
          fixedRow(
            column(
              10,
              offset = 4,
              br(),
              textOutput("running_tasks")
            )
          )
        ),
        br(),
        conditionalPanel(
          "input.tabs != 'intro' & input.tabs != 'rep' & input.tabs != 'template'",
          tabsetPanel(
            id = 'main',
            tabPanel(
              'Map',
              core_mapping_module_ui("core_mapping")
            ),
            tabPanel(
              'Table', br(),
              DT::dataTableOutput('table'),
              downloadButton('dl_table', "CSV file")
            ),
            tabPanel(
              'Results',
              lapply(COMPONENTS, function(component) {
                conditionalPanel(
                  glue::glue("input.tabs == '{component}'"),
                  insert_modules_results(component)
                )
              })
            ),
            tabPanel(
              'Component Guidance', icon = icon("circle-info"),
              uiOutput('gtext_component')
            ),
            tabPanel(
              'Module Guidance', icon = icon("circle-info", class = "mod_icon"),
              uiOutput('gtext_module')
            ),
            tabPanel(
              'Code',
              core_code_module_ui("core_code")
            ),
            tabPanel(
              'Save', icon = icon("floppy-disk", class = "save_icon"),
              core_save_module_ui("core_save")
              )
          )
        ),
        conditionalPanel(
          "input.tabs == 'rep' & input.repSel == null",
          column(8,
                 includeMarkdown("Rmd/gtext_rep.Rmd")
          )
        ),
        conditionalPanel(
          "input.tabs == 'rep' & input.repSel == 'rep_renv'",
          column(8,
                 includeMarkdown("modules/rep_renv.md")
          )
        ),
        conditionalPanel(
          "input.tabs == 'rep' & input.repSel == 'rep_markdown'",
          column(8,
                 includeMarkdown("modules/rep_markdown.md")
          )
        ),
        conditionalPanel(
          "input.tabs == 'rep' & input.repSel == 'rep_refPackages'",
          column(8,
                 includeMarkdown("modules/rep_refPackages.md")
          )
        ),
        conditionalPanel(
          "input.tabs == 'template'",
          column(8,
                 includeMarkdown("modules/template_create.md")
          )
        ),
        conditionalPanel(
          "input.tabs == 'intro'",
          tabsetPanel(
            id = 'introTabs',
            tabPanel(
              'About',
              br(),
              tags$div(
                style="text-align: center;",
                core_intro_module_ui("core_intro")
              ),
              includeMarkdown("Rmd/text_about.Rmd")
            ),
            tabPanel(
              'Team',
              fluidRow(
                column(8, includeMarkdown("Rmd/text_team.Rmd")
                )
              )
            ),
            tabPanel(
              'How To Use',
              includeMarkdown("Rmd/text_how_to_use.Rmd")
            ),
            tabPanel(
              'Load Prior Session',
              core_load_module_ui("core_load")
            )
          )
        )
      )
    )
  )
)
