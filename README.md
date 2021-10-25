# Deliverybot

Simple Continuous Delivery for GitHub: Fast, safe and secure Continous Delivery pipelines you can setup in minutes.
Fully open source.

![Product screenshot](https://deliverybot.dev/assets/images/deploy-list.png)

* Click to deploy: Click the latest commit in the Deliverybot dashboard to deploy your code. It doesn't get any simpler
  than that.
* Automatic deployments: Deploy automatically to multiple clusters and environments given a specific branch.
* Advanced deployment workflows: Orchestrate canary deployments to test code in incremental steps. Push out environments
  per pull request.
* Integrates with slack: Deploy from slack as well as deployments from a dashboard.

## Contributing

If you have suggestions for how deliverybot could be improved, or want to report a bug, open an issue! We'd love all and
any contributions.

For more, check out the [Contributing Guide](CONTRIBUTING.md).

### Setup

    yarn install
    yarn start

### Example deployment to Kubernetes

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: deliverybot
data:
  LOG_LEVEL: "debug"
  APP_ID: "<app id from Github>"
  CLIENT_ID: "<client id from App installation>"
  NODE_ENV: "production"
  BASE_URL: "https://delivery.example.org"
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deliverybot
data:
  CLIENT_SECRET: <base64-encoded App client secret>
  WEBHOOK_SECRET: "<base64-encoded configured value for webhook secret>"
  PRIVATE_KEY: <base64-encoded App private key>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deliverybot
spec:
  replicas: 1
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: deliverybot
  template:
    metadata:
      labels:
        app: deliverybot
    spec:
      containers:
      - image: ghcr.io/opzkit/deliverybot:v0.7.2
        imagePullPolicy: IfNotPresent
        name: deliverybot
        envFrom:
        - configMapRef:
            name: deliverybot
            optional: false
        - secretRef:
            name: deliverybot
        ports:
        - name: "http"
          containerPort: 3000
        resources:
          limits:
            cpu: "200m"
            memory: "400Mi"
          requests:
            cpu: "50m"
            memory: "128Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: deliverybot
spec:
  ports:
  - port: 80
    targetPort: 3000
    name: "http"
  selector:
    app: deliverybot
  type: NodePort
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/group.name: default
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/backend-protocol: HTTP
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/healthcheck-path: /health
  name: deliverybot
spec:
  rules:
  - host: delivery.example.org
    http:
      paths:
      - backend:
          service:
            name: deliverybot
            port:
              name: "http"
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - delivery.example.org

```

## License

[MIT](LICENSE) © 2019 Deliverybot (https://github.com/cloudposse/deliverybot)

