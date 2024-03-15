### **Module:** ***Reference Packages***

**BACKGROUND**

*shinyscholar* (or apps created using it) provide citations of the particular R packages (and their versions) used in a given analysis (Module: *Reference Packages*). The citation of all packages used both promotes documentation and gives credit to the developers of the packages with which the app is built. Dovetailing with the modular nature of shinyscholar, such citation should increase the incentive for researchers to formalize their code into R packages on CRAN and join the app’s community to integrate them into future releases of the software. 

**IMPLEMENTATION**

Users can download a list of references for the R packages used in the analyses. This module utilizes `RefManageR` and `knitcitations` (McLean 2020; Boettiger 2021). The list can be downloaded as a .pdf, HTML, or .doc file.

**REFERENCES**

Boettiger, C. (2021). knitcitations: Citations for 'Knitr' Markdown Files. R package version 1.0.12. <a href="https://CRAN.R-project.org/package=knitcitations" target="_blank">CRAN</a> 

McLean, M.W. (2020). RefManageR: Straightforward 'BibTeX' and 'BibLaTeX' Bibliography Management. R package version 1.3.0.  <a href="https://CRAN.R-project.org/package=RefManageR" target="_blank">CRAN</a>  

