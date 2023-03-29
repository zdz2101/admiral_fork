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

# Install R packages
RUN R -e "install.packages('renv')"

# Copy the project files into the container
COPY . /app

# Activate the renv environment
RUN R -e "renv::init()" && \
    R -e "renv::restore()"

# Set the default command
CMD ["R"]
