FROM rocker/rstudio:latest

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y gdebi-core libapparmor1 libedit2 libssl1.1 libssl-dev libxml2-dev sudo

# Copy RStudio config file into container
COPY rserver.conf /etc/rstudio/rserver.conf

# Set RStudio server port and address
RUN echo "www-port=8787" >> /etc/rstudio/rserver.conf && \
    echo "www-address=127.0.0.1" >> /etc/rstudio/rserver.conf && \
    echo "rsession-which-r=/usr/local/bin/R" >> /etc/rstudio/rserver.conf

# Set username and password for RStudio
RUN useradd -m testuser && \
    echo 'testuser:admiral' | chpasswd

# Set working directory to home directory
WORKDIR /root

# Clone your Admiral Fork repo
RUN git clone https://github.com/zdz2101/admiral_fork.git

# Install necessary R packages
RUN Rscript -e "install.packages(c('dplyr', 'ggplot2'))"

# Set permissions for R library
RUN chown -R rstudio:rstudio /usr/local/lib/R/site-library

# Expose port for RStudio server
EXPOSE 8787

# Start RStudio server
CMD ["/init"]
