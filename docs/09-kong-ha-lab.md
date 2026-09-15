# Kong Gateway High Availability Lab

## Objective

Demonstrate how multiple Kong Gateway replicas improve runtime availability and understand what Kubernetes replica-level high availability does — and does not — protect against.

---

## Architecture

```text
                     Client
                       |
                       v
              Kubernetes Service
                       |
          +------------+------------+
          |            |            |
          v            v            v
       Kong-1       Kong-2       Kong-3
          |            |            |
          +------------+------------+
                       |
                       v
              Kubernetes Services
                       |
                       v
                Backend Pods
```

Multiple Kong Gateway pods allow Kubernetes to continue sending traffic to healthy Gateway instances when an individual Gateway pod becomes unavailable.

---

## Why Multiple Gateway Replicas?

Running one Kong Gateway pod creates a runtime single point of failure.

```text
Client
  |
  v
Kong Pod
  |
  X
```

If that pod fails, API traffic is interrupted until Kubernetes replaces it.

With multiple replicas:

```text
Client
  |
  v
Kubernetes Service
  |
  +----------+----------+
  |          |          |
  v          v          v
Kong-1     Kong-2     Kong-3
```

traffic can continue through the remaining ready Gateway pods.

---

## Scaling the Gateway

The lab can increase the number of Kong Gateway replicas with:

```bash
kubectl scale deployment kong-gateway \
  -n kong \
  --replicas=3
```

Verify:

```bash
kubectl get pods -n kong -o wide
```

For an actual managed deployment, replica count should be stored in Helm values or another declarative configuration source rather than relying on an imperative `kubectl scale` command.

---

## Readiness and Liveness

High availability depends on Kubernetes knowing which Gateway pods are healthy.

Kong provides health endpoints including:

```text
/status
/status/ready
```

Conceptually:

```text
Liveness
   |
   +-- Is this Kong process alive?
   |
   +-- failure -> Kubernetes may restart the container


Readiness
   |
   +-- Can this Kong instance currently serve traffic?
   |
   +-- failure -> remove the pod from Service endpoints
```

A running process should not automatically be considered ready for production traffic.

---

## Failure Test

The key HA test is to remove one Gateway pod while traffic is being sent through the Kubernetes Service.

First inspect the Gateway pods:

```bash
kubectl get pods -n kong
```

Delete one Gateway pod:

```bash
kubectl delete pod -n kong <kong-gateway-pod>
```

Kubernetes should create a replacement because the Deployment maintains the desired replica count.

During the replacement, the Service can continue routing requests to other ready Gateway pods.

---

## What This Test Proves

The lab demonstrates:

```text
Individual Kong pod failure
            |
            v
Other ready Kong replicas remain
            |
            v
Service continues routing traffic
```

This demonstrates **pod-level redundancy**.

It does not by itself prove full production high availability.

---

## kind Limitation

The local lab uses kind.

A typical local kind environment may place all Kong replicas on the same Kubernetes node.

Therefore:

```text
3 Kong pods
     !=
3 independent failure domains
```

If the single kind node fails, all three Gateway replicas fail with it.

The lab therefore demonstrates Kubernetes pod redundancy, not node or availability-zone redundancy.

---

## Production EKS Architecture

A stronger production architecture distributes Kong Gateway replicas across multiple worker nodes and Availability Zones.

```text
                         Route 53
                            |
                            v
                     AWS Load Balancer
                            |
              +-------------+-------------+
              |                           |
              v                           v
           AZ-A                         AZ-B
              |                           |
        +-----------+               +-----------+
        | Kong DP 1 |               | Kong DP 2 |
        +-----------+               +-----------+
              |                           |
              +-------------+-------------+
                            |
                            v
                   Kubernetes Services
                            |
                            v
                     Application Pods
```

Production considerations include:

- multiple Kong replicas
- multiple Kubernetes worker nodes
- multi-AZ placement
- topology spread constraints or pod anti-affinity
- readiness and liveness probes
- resource requests and limits
- PodDisruptionBudgets
- rolling deployments
- autoscaling where appropriate
- monitoring and alerting
- external load balancing

---

## PodDisruptionBudget

The repository includes a PodDisruptionBudget example.

A PDB helps protect application availability during **voluntary disruptions**, such as:

```text
node drain
cluster maintenance
planned upgrades
```

It does not guarantee protection against involuntary failures such as:

```text
node crash
AZ outage
hardware failure
network partition
```

This distinction is important when discussing Kubernetes high availability.

---

## Kong Hybrid Architecture

A production Kong deployment may separate the Control Plane from Data Planes.

```text
                Platform Engineers
                       |
                       v
                +-------------+
                | Control     |
                | Plane       |
                +------+------+
                       |
                  Config Sync
                       |
          +------------+------------+
          |                         |
          v                         v
     +---------+               +---------+
     | Data    |               | Data    |
     | Plane A |               | Plane B |
     +---------+               +---------+
          ^                         ^
          |                         |
          +------------+------------+
                       |
                 Load Balancer
                       |
                       v
                    Clients
```

The Control Plane manages Gateway configuration.

The Data Planes process runtime API traffic.

---

## Control Plane Failure

A temporary Control Plane outage does not automatically stop existing Data Plane traffic.

Data Planes can continue serving requests using their previously received configuration.

Conceptually:

```text
Control Plane
     X

Data Plane
     |
cached / last-known configuration
     |
     v
API traffic continues
```

However, new configuration cannot be propagated normally until connectivity to the Control Plane is restored.

This separates:

```text
management-plane availability
```

from:

```text
runtime API availability
```

---

## Rolling Deployment

Gateway upgrades should avoid replacing every instance simultaneously.

Conceptually:

```text
Kong v1
Kong v1
Kong v1

   ↓ rolling update

Kong v2
Kong v1
Kong v1

   ↓

Kong v2
Kong v2
Kong v1

   ↓

Kong v2
Kong v2
Kong v2
```

Readiness checks prevent a newly started Gateway instance from receiving traffic before it is ready.

---

## Production Failure Domains

High availability should be considered at several levels:

```text
Process
   |
Pod
   |
Node
   |
Availability Zone
   |
Region
```

Increasing pod replicas protects primarily against failures near the top of this hierarchy.

Production architecture must consider the larger failure domains separately.

---

## Troubleshooting HA

When Gateway capacity appears unavailable, inspect:

```bash
kubectl get deployment -n kong
kubectl get pods -n kong -o wide
kubectl get svc -n kong
kubectl get endpointslice -n kong
kubectl describe pod -n kong <pod>
kubectl logs -n kong <pod>
```

The investigation should determine whether the problem is:

```text
Gateway process
       |
Gateway pod
       |
Kubernetes Service
       |
EndpointSlice
       |
node/network
       |
upstream service
```

Avoid immediately restarting Kong before identifying which layer is failing.

---

## Key Lessons

1. Multiple Kong replicas remove the individual Gateway pod as a single point of failure.

2. Kubernetes Services send traffic only to available endpoints.

3. Readiness determines whether a Gateway instance should receive traffic.

4. Liveness determines whether Kubernetes should consider restarting a failed process.

5. A PodDisruptionBudget protects against voluntary disruption; it is not a complete HA solution.

6. Multiple pods on one node do not provide node-level high availability.

7. Production EKS deployments should distribute Gateway replicas across nodes and Availability Zones.

8. Kong hybrid architecture separates configuration management from runtime traffic processing.

9. Data Planes can continue serving previously received configuration during temporary Control Plane loss.

10. Production HA combines Gateway redundancy, Kubernetes scheduling, load balancing, health checks, observability, safe deployment strategy, and failure-domain design.
