resourcePath <- system.file("shiny", "www", package = "SMART")
shiny::addResourcePath("smartres", resourcePath)

tagList(
  shinyjs::useShinyjs(),
  shinyjs::extendShinyjs(
    script = file.path("smartres", "js", "shinyjs-funcs.js"),
    functions = c("scrollLogger", "disableModule", "enableModule")
  ),
  navbarPage(
    theme = bslib::bs_theme(version = 3,
                            bootswatch = "spacelab"),
    id = 'tabs',
    collapsible = TRUE,
    header = tagList(
      tags$head(tags$link(href = "css/styles.css", rel = "stylesheet"))
    ),
    title = img(src = "logo.png", height = '50', width = '50',
                style = "margin-top: -15px"),
    windowTitle = "#SMART",
    tabPanel("Intro", value = 'intro'),
    tabPanel("Select data", value = 'select'),
    tabPanel("Plot data", value = 'plot'),
    tabPanel("Reproduce", value = 'rep'),
    navbarMenu("Support", icon = icon("life-ring"),
               HTML('<a href="https://github.com/simon-smart88/SMART/issues" target="_blank">GitHub Issues</a>'),
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
              2,
              offset = 1,
              align = "left",
              div(style = "margin-top: -10px"),
              strong("Log window"),
              div(style = "margin-top: 5px"),
              div(
                id = "wallaceLog",
                div(id = "logHeader", div(id = "logContent"))
              )
            )
          )
        ),
        br(),
        conditionalPanel(
          "input.tabs != 'intro' & input.tabs != 'rep'",
          tabsetPanel(
            id = 'main',
            tabPanel(
              'Map',
              leaflet::leafletOutput("map", height = 700),
              absolutePanel(
                top = 160, right = 20, width = 150, draggable = TRUE,
                selectInput("bmap", "",
                            choices = c('ESRI Topo' = "Esri.WorldTopoMap",
                                        'Stamen Terrain' = "Stamen.Terrain",
                                        'Open Topo' = "OpenTopoMap",
                                        'ESRI Imagery' = "Esri.WorldImagery",
                                        'ESRI Nat Geo' = 'Esri.NatGeoWorldMap'),
                            selected = "Esri.WorldTopoMap"
                )
              )
            ),
            tabPanel(
              'Table', br(),
              DT::dataTableOutput('table')
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
              radioButtons("code_choice","Choose file", choices=c('Module','Function','Markdown'),selected='Module'),
              verbatimTextOutput('code_module')
            ),
            tabPanel(
              'Save', icon = icon("floppy-disk", class = "save_icon"),
              br(),
              h5(em("Note: To save your session code or metadata, use the Reproduce component")),
              wellPanel(
                h4(strong("Save Session")),
                p(paste0("By saving your session into an RDS file, you can resume ",
                       "working on it at a later time or you can share the file",
                       " with a collaborator.")),
                shinyjs::hidden(p(
                  id = "save_warning",
                  icon("triangle-exclamation"),
                  paste0("The current session data is large, which means the ",
                         "downloaded file may be large and the download might",
                         " take a long time.")
                  )),
                downloadButton("save_session", "Save Session"),
                br()
              ),
              wellPanel(
                h4(strong("Download Data")),
                p(paste0("Download data/results from analyses from currently selected module")),
                ## save module data BEGIN ##
                # save occs #
                conditionalPanel(
                  "input.tabs == 'occs'",
                  br(),
                  fluidRow(
                    column(3, h5("Download original occurrence data")),
                    column(2, shinyjs::disabled(downloadButton('dlDbOccs', "CSV file")))
                  ),
                  br(),
                  fluidRow(
                    column(3, h5("Download current table")),
                    column(2, shinyjs::disabled(downloadButton('dlOccs', "CSV file")))
                  ),
                  br(),
                  fluidRow(
                    column(3, h5("Download all data")),
                    column(2, shinyjs::disabled(downloadButton('dlAllOccs', "CSV file")))
                  )
                )


              )
            )
          )
        ),
        ## save module data END ##
        conditionalPanel(
          "input.tabs == 'rep' & input.repSel == null",
          column(8,
                 includeMarkdown("Rmd/gtext_rep.Rmd")
          )
        ),
        conditionalPanel(
          "input.tabs == 'rep' & input.repSel == 'rep_markdown'",
          column(8,
                 includeMarkdown("modules/rep_markdown.md")
          )
        ),
        conditionalPanel(
          "input.tabs == 'rep' & input.repSel == 'rep_rmms'",
          column(8,
                 includeMarkdown("modules/rep_rmms.md")
          )
        ),
        conditionalPanel(
          "input.tabs == 'rep' & input.repSel == 'rep_refPackages'",
          column(8,
                 includeMarkdown("modules/rep_refPackages.md")
          )
        ),
        conditionalPanel(
          "input.tabs == 'intro'",
          tabsetPanel(
            id = 'introTabs',
            tabPanel(
              'About',
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
              h4("Load session"),
              includeMarkdown("Rmd/text_loadsesh.Rmd"),
              fileInput("load_session", "", accept = ".rds"),
              actionButton('goLoad_session', 'Load RDS')
            )
          )
        )
      )
    )
  )
)
