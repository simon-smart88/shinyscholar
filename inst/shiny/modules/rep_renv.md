### **Module:** ***Reproduce environment***

**BACKGROUND**
In order to ensure that an analysis is reproducible, it is necessary to record the exact versions of all software dependencies used in an analysis. This module allows you to download a list of all packages used by shinyscholar which can be used to restore those versions in the future.

**IMPLEMENTATION**
The module uses `renv::snapshot()` to produce a `.lock` file which can passed to `renv::restore()` to reinstall the same package versions on your own machine.

**REFERENCES**

Sandve GK, Nekrutenko A, Taylor J, Hovig E (2013) Ten Simple Rules for Reproducible Computational Research. *PLoS Comput Biol* 9(10): e1003285. https://doi.org/10.1371/journal.pcbi.1003285
