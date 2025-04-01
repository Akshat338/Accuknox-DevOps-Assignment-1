# Use a base image
FROM ubuntu:20.04

# Install prerequisites
RUN apt-get update && apt-get install -y fortune-mod cowsay

# Copy the application script
COPY wisecow.sh /app/wisecow.sh

# Set working directory
WORKDIR /app

# Grant execution permissions for the script
RUN chmod +x wisecow.sh

# Expose the application port
EXPOSE 4499

# Run the application
CMD ["./wisecow.sh"]
