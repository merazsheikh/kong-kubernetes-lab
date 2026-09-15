# Kong Gateway Observability

## Objective

Monitor Kong Gateway and distinguish Gateway problems from upstream application problems.

## Observability Layers

```text
Client
  |
  v
Load Balancer
  |
  v
Kong Gateway
  |
  v
Kong Service / Upstream
  |
  v
Kubernetes Service
  |
  v
Backend Pod
