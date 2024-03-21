FROM rocker/shiny:4.3.0

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra \
    libgdal-dev
  
# install R packages required 
RUN R -e "install.packages('devtools')"
RUN R -e "devtools::install_github('simon-smart88/shinyscholar')"

COPY ./inst/shiny/ /srv/shiny-server/shinyscholar

# select port
EXPOSE 3838

# allow permission
RUN sudo chown -R shiny:shiny /srv/shiny-server

USER shiny

# run app
CMD ["/usr/bin/shiny-server"]

