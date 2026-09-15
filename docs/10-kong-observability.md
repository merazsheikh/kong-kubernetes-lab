# Kong Gateway Observability

## Objective

Monitor Kong Gateway and determine whether API failures or latency originate from Kong, Kubernetes networking, or the upstream application.

---

## Observability Path

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
Kong Route / Service / Upstream
  |
  v
Kubernetes Service
  |
  v
EndpointSlice
  |
  v
Backend Pod
```

Observability should make it possible to identify which layer is responsible for an API problem.

---

## Three Observability Signals

A production API platform should combine:

```text
Metrics
Logs
Traces
```

Metrics show system behaviour over time.

Logs provide detailed events and errors.

Distributed traces show how an individual request moves between components.

---

## Prometheus Plugin

The repository contains:

```text
kong/observability/prometheus-plugin.yaml
```

The plugin enables Kong Prometheus metrics including:

```yaml
config:
  status_code_metrics: true
  latency_metrics: true
  bandwidth_metrics: true
```

These metrics help monitor traffic volume, HTTP status codes, latency and bandwidth.

---

## Applying the Plugin

```bash
kubectl apply \
  -f kong/observability/prometheus-plugin.yaml
```

Verify:

```bash
kubectl get kongplugin prometheus \
  -n kong-learning
```

The plugin can then be associated with API routing resources.

---

## Kong Metrics

Useful metric categories include:

```text
HTTP request count
HTTP status codes
Kong latency
upstream latency
request bandwidth
response bandwidth
```

Examples available in relevant Kong versions/configurations include:

```text
http_requests_total
kong_request_latency_ms
kong_upstream_latency_ms
kong_kong_latency_ms
```

Metric names and available labels can vary between Kong versions, so dashboards and alerts should be validated against the deployed Gateway version.

---

## Gateway vs Upstream Latency

One of the most important troubleshooting questions is:

```text
Is Kong slow,
or is the backend slow?
```

Conceptually:

```text
Total request latency
        |
        +---- Kong processing
        |
        +---- Upstream processing
```

If Kong processing latency is small while upstream latency is high, investigate the backend or network path rather than restarting Kong.

---

## Kong Response Headers

Kong can expose useful diagnostic headers such as:

```text
X-Kong-Proxy-Latency
X-Kong-Upstream-Latency
X-Kong-Response-Latency
X-Kong-Request-Id
```

For example:

```text
X-Kong-Proxy-Latency: 2
X-Kong-Upstream-Latency: 850
```

This strongly suggests the majority of the delay occurred while communicating with or waiting for the upstream service.

Availability of specific latency headers depends on the deployed Kong version.

---

## Request IDs

A request ID provides a correlation point between Gateway and application logs.

Example:

```text
X-Kong-Request-Id
```

A useful investigation flow is:

```text
Client error
    |
request ID
    |
    +---- Kong logs
    |
    +---- application logs
    |
    +---- tracing platform
```

Correlation IDs reduce the time required to follow an individual request across distributed systems.

---

## 401 and 403

Authentication and authorization failures should be separated.

```text
401
 |
 +-- missing or invalid authentication

403
 |
 +-- authenticated identity lacks permission
```

For the secured APIs in this lab:

```text
No JWT
   -> 401

Valid JWT but ACL authorization fails
   -> 403
```

These are policy failures and do not automatically indicate an upstream application problem.

---

## 404 Troubleshooting

A 404 should first be classified by origin.

```text
Client
  |
  v
Kong routing
  |
  +-- no matching Route
  |      -> Kong 404
  |
  v
Upstream
         -> application 404
```

Check route configuration before changing the backend.

---

## 502, 503 and 504

These status codes provide different operational signals.

### 502 Bad Gateway

Kong selected an upstream destination but could not successfully communicate with it or received an invalid upstream response.

Investigate:

```text
target address
port
protocol
DNS
network connectivity
TLS
application process
```

### 503 Service Unavailable

Kong may have no usable upstream peer.

The lab reproduced this by scaling the Orders API to zero replicas.

Kong returned:

```text
failure to get a peer from the ring-balancer
```

Investigate:

```text
Kubernetes Service
EndpointSlice
Pod readiness
Kong upstream state
backend capacity
```

### 504 Gateway Timeout

Kong waited for the upstream longer than the configured timeout.

Investigate:

```text
upstream latency
application dependencies
database latency
network latency
Kong timeout configuration
```

Increasing the timeout without finding the underlying cause can hide a backend performance problem.

---

## Kubernetes Observability

Kong metrics alone are not enough.

Useful Kubernetes checks include:

```bash
kubectl get pods -n kong -o wide
kubectl get svc -n kong
kubectl get endpointslice -n kong
kubectl logs -n kong <kong-pod>
```

For the backend:

```bash
kubectl get pods -n kong-learning -o wide
kubectl get svc -n kong-learning
kubectl get endpointslice -n kong-learning
kubectl logs -n kong-learning <application-pod>
```

---

## Troubleshooting Order

A useful production investigation sequence is:

```text
1. Can the client reach Kong?
2. Did Kong match the expected Route?
3. Did authentication succeed?
4. Did authorization succeed?
5. Which Kong Service/upstream was selected?
6. Does the Kubernetes Service exist?
7. Are EndpointSlices populated?
8. Are backend pods Ready?
9. Can Kong reach the backend?
10. What do Kong and application logs show?
11. Where is the latency occurring?
```

This is preferable to immediately restarting components.

---

## Prometheus Architecture

A production monitoring architecture may look like:

```text
Kong Gateway Pods
       |
       | metrics
       v
   Prometheus
       |
       v
    Grafana
       |
       v
Dashboards / Alerts
```

Each Gateway instance should be observable so that failures are not hidden by aggregate load balancing.

---

## High-Cardinality Metrics

High-cardinality labels can create substantial monitoring cost and storage pressure.

Examples include labels containing highly variable values such as:

```text
consumer IDs
individual routes
dynamic identifiers
```

Metrics should therefore be enabled intentionally and monitored for cardinality growth.

---

## Alerts

Useful production alert categories include:

```text
5xx error rate
401/403 anomaly rate
request latency
upstream latency
Gateway pod availability
no healthy upstream targets
CPU and memory pressure
request volume changes
```

Alerts should indicate actionable conditions rather than simply reporting every metric change.

---

## Key Lessons

1. Determine whether an error originates from Kong or the upstream before taking action.

2. Compare Gateway latency with upstream latency.

3. Use request IDs to correlate requests across logs and services.

4. 401 and 403 normally indicate different security-policy failures.

5. 502, 503 and 504 represent different failure modes and should not be treated as interchangeable.

6. Kubernetes Service endpoints and Pod readiness are essential parts of Kong upstream troubleshooting.

7. Prometheus metrics, logs and traces complement each other.

8. Monitoring every Gateway instance is important in horizontally scaled environments.

9. High-cardinality metrics can create operational and financial problems.

10. Observability should shorten diagnosis time rather than simply collect more data.
