# Use an official R runtime as a parent image
FROM r-base:latest

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
      libssl-dev \
      libxml2-dev \
      libcurl4-openssl-dev \
      git

# Install R packages
RUN R -e "install.packages(c("admiraldev", "dplyr", "hms",  "lifecycle", "lubridate", "magrittr", "purrr", "rlang", "stringr", "tidyr", "tidyselect", "admiral.test", "covr", "devtools", "DT", "diffdf", "knitr", "lintr", "methods", "pkgdown", "readxl", "rmarkdown", "roxygen2", "spelling", "styler", "testthat", "tibble", "usethis"))"

# Copy the project files into the container
COPY . /app

# Set the default command
CMD ["R"]
