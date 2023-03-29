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
RUN R -e "install.packages('renv')"

# Copy the project files into the container
COPY . /app

# Activate the renv environment
RUN R -e "renv::init()" && \
    R -e "renv::restore()"

# Set the default command
CMD ["R"]
