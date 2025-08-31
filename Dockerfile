# # Use the official Python image as the base image
# FROM python:3.9

# # Set the working directory in the container
# WORKDIR /app

# # Copy the application files into the container
# COPY . .

# # Install necessary packages
# RUN apt-get update && apt-get install -y unixodbc unixodbc-dev
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
# RUN apt-get update
# RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17

# RUN pip install -r requirements.txt

# # Start the FastAPI application
# CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]


# FROM ubuntu:20.04

# # Avoid interactive tzdata prompt
# ENV DEBIAN_FRONTEND=noninteractive

# # Install system dependencies
# RUN apt-get update && apt-get install -y \
#     curl \
#     gnupg2 \
#     ca-certificates \
#     apt-transport-https \
#     software-properties-common \
#     lsb-release \
#     sudo \
#     unixodbc \
#     unixodbc-dev \
#     python3.9 \
#     python3.9-venv \
#     python3-pip \
#     build-essential

# # Verify supported Ubuntu version
# RUN VERSION_ID=$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2) && \
#     case "$VERSION_ID" in \
#         14.04|16.04|18.04|20.04|22.04) echo "Ubuntu $VERSION_ID is supported." ;; \
#         *) echo "Ubuntu $VERSION_ID is not supported." && exit 1 ;; \
#     esac

# # Install Microsoft ODBC Driver
# RUN VERSION_ID=$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2) && \
#     curl -sSL -O https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb && \
#     dpkg -i packages-microsoft-prod.deb && \
#     rm packages-microsoft-prod.deb

# RUN apt-get update && \
#     ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools && \
#     echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
#     echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.profile

# # Set working dir
# WORKDIR /app

# # Copy source code
# COPY . .

# # Install Python requirements
# RUN pip3 install --no-cache-dir -r requirements.txt

# # Expose port
# EXPOSE 8000

# # Run the app
# CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]


# Use official Python slim image as base
# Use Python 3.9 based on Debian Bullseye (stable & compatible)


FROM python:3.9-bullseye

# Set working directory inside container
WORKDIR /app

# Install required system dependencies in one RUN command
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    unixodbc \
    unixodbc-dev \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft package repository and install MS ODBC Driver + tools
RUN bash -c '\
    DEB_VERSION=$(grep VERSION_ID /etc/os-release | cut -d "\"" -f 2 | cut -d "." -f 1); \
    if ! [[ "8 9 10 11 12" == *"$DEB_VERSION"* ]]; then \
        echo "Debian $DEB_VERSION is not currently supported."; \
        exit 1; \
    fi; \
    curl -sSL -O https://packages.microsoft.com/config/debian/$DEB_VERSION/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools unixodbc-dev libgssapi-krb5-2 && \
    echo "export PATH=\$PATH:/opt/mssql-tools/bin" >> /etc/profile.d/mssql.sh; \
'

# Copy the current directory contents into the container at /app
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8000 (if you're using FastAPI or similar)
EXPOSE 8000

# Run the app (change if your entrypoint is different)
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
