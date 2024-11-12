# Compsoio Helm Chart

This Helm chart deploys a complete application stack including:
- Frontend service
- Backend services (Hermes, Mercury, Mercury OpenAPI)
- PostgreSQL database
- Redis cache
- Loki logging system

## Prerequisites

- Kubernetes cluster
- Helm v3+
- kubectl configured to communicate with your cluster

## Installation

1. First, add the required Helm repositories:
   ```bash

   helm repo update
   ```

2. Configure values.yaml:
   - Set your image repositories and tags
   - Configure PostgreSQL settings (username, password, database name)
   - Configure Redis settings if needed
   - Set your ingress host domain
   - Configure Loki logging settings
   - Set OpenAI API key

3. Create required storage classes and PVCs (different if you are using other cloud providers):
   ```bash
   # Create gp2 storage class if not exists
   kubectl apply -f storage-class.yaml
   
   # Create PostgreSQL PVC
   kubectl apply -f postgresql-pvc.yaml
   ```

4. Install the chart:
   ```bash
   helm install my-release .
   ```

## Configuration

The following table lists the configurable parameters and their default values:

### Image Configuration
| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.hermes.repository` | Hermes image repository | `008971668139.dkr.ecr.ap-south-1.amazonaws.com/composio/hermes` |
| `image.hermes.tag` | Hermes image tag | `latest` |
| `image.frontend.repository` | Frontend image repository | `008971668139.dkr.ecr.ap-south-1.amazonaws.com/composio/frontend` |
| `image.frontend.tag` | Frontend image tag | `latest` |
| `image.mercury.repository` | Mercury image repository | `008971668139.dkr.ecr.ap-south-1.amazonaws.com/composio/mercury` |
| `image.mercury.tag` | Mercury image tag | `latest` |

### Database Configuration
| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Deploy PostgreSQL | `true` |
| `postgresql.auth.username` | PostgreSQL username | `postgres` |
| `postgresql.auth.password` | PostgreSQL password | `postgres` |
| `postgresql.auth.database` | PostgreSQL database | `composio` |

### Redis Configuration
| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Deploy Redis | `true` |
| `redis.architecture` | Redis architecture | `standalone` |
| `redis.auth.enabled` | Enable Redis auth | `false` |

### Ingress Configuration
| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.host` | Ingress host domain | `example.com` |
| `ingress.className` | Ingress class | `nginx` |

## Accessing the Application

Once deployed, your application will be available at:
- Frontend: https://app.[your-domain]
- Backend API: https://backend.[your-domain]/api

## Monitoring & Logging

The deployment includes:
- Loki for log aggregation
- Prometheus metrics endpoints on services
- HorizontalPodAutoscaler configured for backend services