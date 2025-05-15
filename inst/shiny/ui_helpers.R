uiTop <- function(mod_INFO) {
  modID <- mod_INFO$modID
  modName <- mod_INFO$modName
  pkgName <- mod_INFO$pkgName

  ls <- list(span(div(paste("Module: ", modName), class = "mod"),
             actionLink(paste0(modID, "Help"),
                        label = "", icon = icon("circle-question"),
                        class = "modHelpButton")
             ))

  ls <- c(ls,
          list(span(span("R packages:", class = "rpkg"),
                        span(paste(pkgName, collapse = ", "), class = "pkgDes")))
        )


  ls
}

uiBottom <- function(mod_INFO) {
  modAuts <- mod_INFO$modAuts
  pkgName <- mod_INFO$pkgName
  pkgAuts <- mod_INFO$pkgAuts
  pkgTitl <- mod_INFO$pkgTitl

  ls <- list(span(span('Module developers:', class = "rpkg"),
                  span(modAuts, class = "pkgDes")))

  for (i in seq_along(pkgName)) {
    ls <- c(ls, list(
      span(
        span(paste0(pkgName[i], ":"), class = "rpkg"),
        span(span(pkgTitl[i], class = "pkgTitl"))
      ),
      div(paste('Package Developers:', pkgAuts[i]), class = "pkgDes"),
      span(
        a("CRAN", href = file.path("http://cran.r-project.org/web/packages",
                                 pkgName[i], "index.html"), target = "_blank"), " | ",
        a("documentation", href = file.path("https://cran.r-project.org/web/packages",
                                            pkgName[i], paste0(pkgName[i], ".pdf")), target = "_blank"), br()
      )
    ))
  }
  ls
}

ui_top <- function(pkgName, modName, modAuts, modID) {
  uiTop(infoGenerator(pkgName, modName, modAuts, modID))
}
ui_bottom <- function(pkgName, modName, modAuts, modID) {
  uiBottom(infoGenerator(pkgName, modName, modAuts, modID))
}

infoGenerator <- function(pkgName, modName, modAuts, modID) {
  # Use installed package only (some packages are Suggested)
  pkgName <- pkgName[vapply(pkgName, requireNamespace, TRUE, quietly = TRUE)]

  pkgInfo <- sapply(pkgName, packageDescription, simplify = FALSE)
  pkgTitl <- sapply(pkgInfo, function(x) x$Title)
  # remove square brackets and spaces before commas
  pkgAuts <- sapply(pkgInfo, function(x) gsub("\\s+,", ",", gsub("\n|\\[.*?\\]", "", x$Author)))
  # remove parens and spaces before commas
  pkgAuts <- sapply(pkgAuts, function(x) gsub("\\s+,", ",", gsub("\\(.*?\\)", "", x)))
  list(modID = modID,
       modName = modName,
       modAuts = modAuts,
       pkgName = pkgName,
       pkgTitl = pkgTitl,
       pkgAuts = pkgAuts)
}

# Add radio buttons for all modules in a component
insert_modules_options <- function(component, exclude = NULL) {
  modules <- COMPONENT_MODULES[[component]]
  modules <- modules[!names(modules) %in% exclude]
  unlist(setNames(
    lapply(modules, `[[`, "id"),
    lapply(modules, `[[`, "short_name")
  ))
}

# Add the UI for a module
insert_modules_ui <- function(component, long_component, exclude = NULL) {
  modules <- COMPONENT_MODULES[[component]]
  modules <- modules[!names(modules) %in% exclude]
  tagList(
    conditionalPanel(
      glue("input.tabs == '{component}'"),
      div(glue("Component: {long_component}"), help_comp_ui(glue("{component}Help")), class = "componentName"),
      shinyWidgets::radioGroupButtons(
        glue("{component}Sel"), "",
        choices = insert_modules_options(component),
        direction = "vertical",
        status = "outline-secondary",
        width = "100%"
      ),
      lapply(modules, function(module) {
        conditionalPanel(
          glue("input.{component}Sel == '{module$id}'"),
          card(
            ui_top(
              modID = module$id,
              modName = module$long_name,
              modAuts = module$authors,
              pkgName = module$package
            ),
            do.call(module$ui_function, list(module$id)),
            class = "sidebar_card"
          ),
          card(
            ui_bottom(
              modID = module$id,
              modName = module$long_name,
              modAuts = module$authors,
              pkgName = module$package
            ),
            class = "sidebar_card"
          )
        )
      })
    )
  )
}

# Add the results section UI of all modules in a component
insert_modules_results <- function(component) {
  lapply(COMPONENT_MODULES[[component]], function(module) {
    if (is.null(module$result_function)){
      conditionalPanel(
        glue("input.{component}Sel == '{module$id}'"),
        tagList(tags$br(), tags$h3(glue("{module$short_name} does not produce results"))))
    } else {
      conditionalPanel(
        glue("input.{component}Sel == '{module$id}'"),
        do.call(module$result_function, list(module$id))
      )
    }
  })
}

# Add helper button for component
help_comp_ui <- function(name) {
  actionLink(name, label = "", icon = icon("circle-question"),
             class = "compHelpButton")
}

# adjust layout width depending on screen size
flex_wrap <- function(content) {
  layout_columns(
    col_widths = breakpoints(sm = c(12),
                             md = c(-1, 10, -1),
                             lg = c(-2, 8, -2),
                             xl = c(-2, 8, -2),
                             xxl = c(-3, 6, -3)),
    content,
  )
}
