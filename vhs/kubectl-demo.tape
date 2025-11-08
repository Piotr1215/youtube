# VHS Tape for Kubernetes kubectl Demo
# Based on the kubectl-basics demo pattern

Output kubectl-demo.gif

# YouTube-optimized dimensions (16:9 ratio)
Set Width 1200
Set Height 675

# Terminal appearance
Set FontSize 18
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 40ms
Set PlaybackSpeed 1.0

# Clear screen to start fresh
Hide
Type "clear"
Enter
Show

Sleep 500ms

# Demo Title
Type "# Kubernetes kubectl Basics Demo"
Sleep 1s
Enter
Enter

# Create namespace
Type "kubectl create namespace demo-namespace"
Sleep 500ms
Enter
Sleep 1.5s

# List namespaces
Type "kubectl get namespaces"
Sleep 500ms
Enter
Sleep 2s

# Create deployment
Type "kubectl create deployment nginx-deployment --image=nginx --replicas=2 -n demo-namespace"
Sleep 500ms
Enter
Sleep 2s

# Check pods
Type "kubectl get pods -n demo-namespace"
Sleep 500ms
Enter
Sleep 2s

# Describe deployment for details
Type "kubectl describe deployment nginx-deployment -n demo-namespace | head -20"
Sleep 500ms
Enter
Sleep 3s

# Scale the deployment
Type "kubectl scale deployment nginx-deployment --replicas=4 -n demo-namespace"
Sleep 500ms
Enter
Sleep 1.5s

# Verify scaling
Type "kubectl get pods -n demo-namespace"
Sleep 500ms
Enter
Sleep 2.5s

# Show deployment status
Type "kubectl get deployment nginx-deployment -n demo-namespace"
Sleep 500ms
Enter
Sleep 2s

# Clean up
Type "kubectl delete namespace demo-namespace"
Sleep 500ms
Enter
Sleep 2s

# Final message
Enter
Type "# Demo completed! ✓"
Sleep 2s

# Note: Before recording, ensure you have:
# - A running Kubernetes cluster (minikube, kind, or real cluster)
# - kubectl configured and working
# - Sufficient permissions to create namespaces and deployments
