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


FROM python:3.9

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

# Install system dependencies
RUN apt-get update && \
    apt-get install -y curl gnupg2 unixodbc unixodbc-dev apt-transport-https ca-certificates && \
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/debian/10/prod stable main" > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    apt-get clean

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]