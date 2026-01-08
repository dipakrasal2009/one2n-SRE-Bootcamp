#Base image
FROM python:3.10-slim
#Set working directory
WORKDIR /app

#Install system dependencies (make + build tools + sqlite)
RUN apt-get update && apt-get install -y \
    gcc \
    sqlite3 \
    make \
    && rm -rf /var/lib/apt/lists/*

#Copy requirements first (for caching)
COPY requirements.txt .

#Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

#Copy application code (includes Makefile)
COPY . .

 #Expose Flask port
EXPOSE 5000

CMD ["make", "run"]

