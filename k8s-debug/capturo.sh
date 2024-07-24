#!/bin/bash

# Set variables
NGINX_SERVICE_NAME="nginx-service"                                                      # Replace with your actual Nginx service name
REDIS_POD_NAME=$(kubectl get pods -l app=redis -o jsonpath='{.items[0].metadata.name}') # Assumes Redis pods are labeled with app=redis
NAMESPACE="default"                                                                     # Replace with the actual namespace if different

echo "=== Kubernetes Troubleshooting Script ==="
echo "Nginx Service Name: $NGINX_SERVICE_NAME"
echo "Redis Pod Name: $REDIS_POD_NAME"
echo "Namespace: $NAMESPACE"
echo ""

# 1. Get services
echo "=== Kubernetes Services ==="
kubectl get svc -n $NAMESPACE
echo ""

# 2. Describe Nginx service
echo "=== Nginx Service Details ==="
kubectl describe svc $NGINX_SERVICE_NAME -n $NAMESPACE
echo ""

# 3. Get pods
echo "=== Kubernetes Pods ==="
kubectl get pods -n $NAMESPACE
echo ""

# 4. Get network policies
echo "=== Network Policies ==="
kubectl get networkpolicies -n $NAMESPACE
echo ""

# 5. DNS resolution from Redis pod
echo "=== DNS Resolution from Redis Pod ==="
kubectl exec $REDIS_POD_NAME -n $NAMESPACE -- nslookup $NGINX_SERVICE_NAME
echo ""

# 6. Curl Nginx service from Redis pod
echo "=== Curl Nginx Service from Redis Pod ==="
kubectl exec $REDIS_POD_NAME -n $NAMESPACE -- curl -v $NGINX_SERVICE_NAME
echo ""

# 7. Check kube-proxy status
echo "=== kube-proxy Status ==="
kubectl get pods -n kube-system | grep kube-proxy
echo ""

# 8. Get kube-proxy logs (last 20 lines)
echo "=== kube-proxy Logs (last 20 lines) ==="
KUBE_PROXY_POD=$(kubectl get pods -n kube-system | grep kube-proxy | awk '{print $1}' | head -n 1)
kubectl logs $KUBE_PROXY_POD -n kube-system | tail -n 20
echo ""

echo "=== Troubleshooting Script Completed ==="
