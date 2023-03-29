# Use an official R runtime as a parent image
FROM rocker/r-ver.4.1.3

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    git \
    r-base \
    gdebi-core

RUN wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2021.09.0%2B351-amd64.deb

RUN sudo gdebi rstudio-server-2021.09.0+351-amd64.deb

# Install R packages
RUN R -e "install.packages('renv')"

# Copy the project files into the container
COPY . /app

# Activate the renv environment
RUN R -e "renv::init()" && \
    R -e "renv::restore()"

# Set the default command
CMD ["R"]
