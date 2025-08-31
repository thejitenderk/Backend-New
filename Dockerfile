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


FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy your application files
COPY . .

# Install required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    ca-certificates \
    sudo \
    apt-transport-https \
    software-properties-common \
    lsb-release \
    unixodbc \
    unixodbc-dev

# Validate Ubuntu version is supported
RUN VERSION_ID=$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2) && \
    case "$VERSION_ID" in \
        14.04|16.04|18.04|20.04|22.04) echo "Ubuntu $VERSION_ID is supported." ;; \
        *) echo "Ubuntu $VERSION_ID is not currently supported." && exit 1 ;; \
    esac

# Download and install Microsoft repo
RUN VERSION_ID=$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2) && \
    curl -sSL -O https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb

# Install msodbcsql17 and optional tools
RUN apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.profile

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the app port
EXPOSE 8000

# Run the FastAPI app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
