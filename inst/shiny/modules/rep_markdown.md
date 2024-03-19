### **Module:** ***Session Code***

**BACKGROUND**
Via the *Session Code* module, the user can download files that document the analyses run in a given *shinyscholar* session (including executable code that can reproduce them).  This functionality supports reproducible science.

**IMPLEMENTATION**

Here, the user can download documented code that corresponds to the analyses run in the current session of *shinyscholar*. Multiple formats are available for download (.Rmd [R Markdown], .pdf, .html, or .doc). The .Rmd format is an executable R script file that will reproduce the analysis when run in an R session; it is composed of plain text and R code “chunks”. Extended functionality for R Markdown files exists in RStudio. Simply open the .Rmd in RStudio, click on “Run” in the upper-right corner, and run chunk by chunk or all at once. To learn more details, see the RStudio tutorial.

The *shinyscholar* session code .Rmd file is composed of a chain of code chunks with module functions that are for internal use in *shinyscholar*. Each of these functions corresponds to a single module that the user ran during the session. To see the internal code for these module functions, click on the links in the .Rmd file. Users are encouraged to write custom code in the .Rmd directly to modify their analysis, and even modify the module function code to further customize.

***Notes***
To generate a PDF of your session code, it is essential you have a working version of TeX installed. For Mac OS, download MacTeX <a href="https://tug.org/mactex/" target="_blank">here</a>. For Windows, please perform the following steps:  

1. Download and Install MiKTeX <a href="https://miktex.org/download" target="_blank">here</a>.  
2. Run `Sys.getenv("PATH")` in RStudio. This command returns the path where RStudio is trying to find pdflatex.exe. In Windows (64-bit), it should return `C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe`. If pdflatex.exe is not located in this location, RStudio gives the error code “41”.  
3. To set the path variable, run the following in RStudio:  
`d <- "C:/Program Files/MiKTeX 2.9/miktex/bin/x64/"`  
`Sys.setenv(PATH=paste(Sys.getenv("PATH"), d, sep=";"))`  
