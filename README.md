# Wisecow
Step 1: Dockerization
Prepare the Dockerfile:
Dockerfile
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

# 2.Build the Docker Image:

Run the following commands:
docker build -t wisecow-app .
docker run -p 4499:4499 wisecow-app
# 3.Verify the Image:

Visit http://localhost:4499 or use curl to check for the ASCII cow wisdom output.

# Step 2: Kubernetes Deployment

1.Create Manifest Files:
Deployment Manifest (deployment.yaml):

apiVersion: apps/v1
kind: Deployment
metadata:
  name: wisecow-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wisecow-app
  template:
    metadata:
      labels:
        app: wisecow-app
    spec:
      containers:
      - name: wisecow-container
        image: <your-container-registry>/wisecow-app:latest
        ports:
        - containerPort: 4499
        
Service Manifest (service.yaml):

apiVersion: v1
kind: Service
metadata:
  name: wisecow-service
spec:
  type: LoadBalancer
  selector:
    app: wisecow-app
  ports:
  - port: 80
    targetPort: 4499
    
2.Deploy to Kubernetes:

Apply the manifests:
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

3.Verify Deployment:

Use:
kubectl get pods
kubectl get services

Access the app through the external IP of the LoadBalancer service.

###Step 3: GitHub Actions for CI/CD###

1.Create Workflow File (.github/workflows/deploy.yaml):
  name: Build and Deploy

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Build and Push Docker Image
      run: |
        docker build -t <your-container-registry>/wisecow-app:${{ github.sha }} .
        echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
        docker push <your-container-registry>/wisecow-app:${{ github.sha }}

  deploy:
    runs-on: ubuntu-latest
    needs: build
    steps:
    - name: Deploy to Kubernetes
      run: |
        echo "${{ secrets.KUBECONFIG }}" > ~/.kube/config
        kubectl set image deployment/wisecow-app wisecow-app=<your-container-registry>/wisecow-app:${{ github.sha }}
        
2.Add Repository Secrets:
Add secrets like DOCKER_USERNAME, DOCKER_PASSWORD, and KUBECONFIG in the GitHub repository settings.

###Step 4: TLS Implementation###

1.Generate TLS Certificates:
Use OpenSSL:
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt

2.Create Kubernetes Secret:
kubectl create secret tls wisecow-tls --key=tls.key --cert=tls.crt

3.Update Manifests:
Update the service manifest to use HTTPS and attach the TLS secret.

4.Verify Secure Communication:
Access the app via HTTPS through the LoadBalancer.

Output:
When deployed, accessing the app will display the ASCII cow wisdom image along with a motivational quote (e.g., "Living your life is a task so difficult, it has never been attempted before").


