⚙️ STEP 1 — Clone Repository
git clone https://github.com/YOUR_USERNAME/wordpress-gitops-platform.git
cd wordpress-gitops-platform
☁️ STEP 2 — Deploy Infrastructure (CloudFormation)
2.1 Deploy VPC
aws cloudformation create-stack \
  --stack-name wp-vpc \
  --template-body file://cloudformation/00-vpc.yaml \
  --capabilities CAPABILITY_NAMED_IAM
2.2 Deploy EKS Cluster
aws cloudformation create-stack \
  --stack-name wp-eks \
  --template-body file://cloudformation/01-eks.yaml \
  --capabilities CAPABILITY_NAMED_IAM
2.3 Deploy Database (RDS Multi-AZ)
aws cloudformation create-stack \
  --stack-name wp-rds \
  --template-body file://cloudformation/02-rds.yaml \
  --capabilities CAPABILITY_NAMED_IAM
2.4 Deploy S3 Bucket (Media Storage)
aws cloudformation create-stack \
  --stack-name wp-s3 \
  --template-body file://cloudformation/04-s3.yaml \
  --capabilities CAPABILITY_NAMED_IAM
🔗 STEP 3 — Connect to EKS Cluster
aws eks update-kubeconfig \
  --region us-east-1 \
  --name wordpress-cluster

Verify:

kubectl get nodes
⚙️ STEP 4 — Install Argo CD (GitOps Engine)
4.1 Install Argo CD
bash argocd/install-argocd.sh

OR manually:

kubectl create namespace argocd

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
4.2 Access Argo CD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

Login:

Username: admin
Password:
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
📦 STEP 5 — Deploy WordPress via GitOps
5.1 Apply Argo CD Application
kubectl apply -f argocd/application.yaml
5.2 Verify Sync Status
kubectl get applications -n argocd

Expected:

SYNCED   HEALTHY
🧱 STEP 6 — WordPress Deployment Model

WordPress is deployed using:

Helm chart (apps/wordpress/helm)
Managed by Argo CD
Running inside EKS

Key components:

WordPress Deployment (pods)
LoadBalancer Service
Ingress (optional)
RDS backend
S3 media storage
📊 STEP 7 — Monitoring Stack
Install Prometheus + Grafana
kubectl apply -f monitoring/prometheus.yaml
kubectl apply -f monitoring/grafana.yaml

Access Grafana:

kubectl port-forward svc/grafana 3000:80
🔁 STEP 8 — GitOps Workflow
How deployments work:
1. Developer changes Git repo:
git add .
git commit -m "update wordpress config"
git push
2. Argo CD detects change
3. Argo CD syncs cluster automatically
4. Kubernetes updates workloads

No manual deployment required.

🚨 STEP 9 — Incident Response
Check system health
kubectl get pods -A
kubectl get svc
Check application logs
kubectl logs deployment/wordpress
Rollback deployment
kubectl rollout undo deployment wordpress

OR via Argo CD:

kubectl delete application wordpress -n argocd
kubectl apply -f argocd/application.yaml
📈 STEP 10 — Scaling Behavior
Auto Scaling (HPA)
kubectl autoscale deployment wordpress \
  --cpu-percent=50 \
  --min=2 \
  --max=10
🔐 STEP 11 — Security Model

Implemented controls:

AWS WAF protects web traffic
IAM roles enforce least privilege
Private subnets for EKS worker nodes
RDS not publicly exposed
Secrets stored securely in Kubernetes
🧪 STEP 12 — Load Testing (Optional)
k6 run load-test.js

OR:

ab -n 10000 -c 50 http://your-lb-url
🧹 STEP 13 — Tear Down Environment
aws cloudformation delete-stack --stack-name wp-eks
aws cloudformation delete-stack --stack-name wp-rds
aws cloudformation delete-stack --stack-name wp-vpc
aws cloudformation delete-stack --stack-name wp-s3