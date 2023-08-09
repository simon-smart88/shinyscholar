### **Module:** ***Reference Packages***

**BACKGROUND**

Scientific practice increasingly emphasizes documentation and reproducibility. *SMART* promotes documentation by allowing users to download information that includes sources of input data, methodological decisions, and results. One option for the documentation (see Module: *Download Session Code*) is a file that can be re-run in R to reproduce the analyses (if re-run on exactly the same versions of R and dependent packages). Many intermediate and advanced users of R likely will find this file useful as a template for modification. Additionally, *SMART* provides citations of the particular R packages (and their versions) used in a given analysis (Module: *Reference Packages*).

In publications and reports based on analyses run in *Wallace*, citation of all packages used both promotes documentation and gives credit to the developers of the packages with which Wallace is built. Dovetailing with the modular nature of *Wallace*, such citation should increase the incentive for researchers to formalize their code into R packages on CRAN and join the *Wallace* community to integrate them into future releases of the software. 

**IMPLEMENTATION**

Users can download a list of references for the R packages used in the analyses. This module utilizes `RefManageR` and `knitcitations` (McLean 2020; Boettiger 2021). The list can be downloaded as a .pdf, HTML, or .doc file.

**REFERENCES**

Boettiger, C. (2021). knitcitations: Citations for 'Knitr' Markdown Files. R package version 1.0.12. <a href="https://CRAN.R-project.org/package=knitcitations" target="_blank">CRAN</a> 

McLean, M.W. (2020). RefManageR: Straightforward 'BibTeX' and 'BibLaTeX' Bibliography Management. R package version 1.3.0.  <a href="https://CRAN.R-project.org/package=RefManageR" target="_blank">CRAN</a>  

