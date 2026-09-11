# Kubernetes Architecture Fundamentals

## What is Kubernetes?

Kubernetes is a container orchestration platform used to deploy, manage, scale, and recover containerized applications.

Instead of manually managing individual containers, we declare the desired state and Kubernetes continuously works to maintain that state.

## High-Level Architecture

A Kubernetes cluster consists of:

- Control Plane
- Worker Nodes

Traffic and management flow:

User / DevOps Engineer
        |
        v
   kubectl / API
        |
        v
+-------------------+
|   Control Plane   |
|-------------------|
| API Server        |
| Scheduler         |
| Controller Manager|
| etcd              |
+-------------------+
        |
        v
+-------------------+
|   Worker Nodes    |
|-------------------|
| kubelet           |
| container runtime |
| kube-proxy / CNI  |
| Pods              |
+-------------------+

## Control Plane

### API Server

The API Server is the main entry point into Kubernetes.

Commands such as:

kubectl get pods

communicate with the Kubernetes API Server.

### etcd

etcd is the distributed key-value store containing Kubernetes cluster state and configuration.

### Scheduler

The Scheduler decides which worker node should run a newly created Pod.

It considers factors such as:

- available resources
- scheduling constraints
- affinity and anti-affinity
- taints and tolerations

### Controller Manager

Controllers continuously compare the desired state with the actual state and attempt to reconcile differences.

Example:

Desired replicas: 3
Actual replicas: 2

The Deployment controller works to create another Pod.

## Worker Node

Worker nodes run application workloads.

Important components include:

### kubelet

The kubelet communicates with the Kubernetes API and ensures the required Pods are running on its node.

### Container Runtime

The container runtime executes containers.

Examples include containerd and CRI-O.

### Pods

A Pod is the smallest deployable unit in Kubernetes.

A Pod can contain one or more tightly coupled containers.

## Desired State and Reconciliation

A fundamental Kubernetes concept is reconciliation.

We declare:

Desired State

Kubernetes observes:

Actual State

Controllers continuously work toward:

Actual State = Desired State

This self-healing model is one of the most important Kubernetes concepts.

## Connection to Kong

In our lab:

Kubernetes manages the infrastructure and workloads.

Kong Gateway handles API runtime traffic.

Kong Ingress Controller watches Kubernetes resources and translates them into Kong Gateway configuration.

A simplified flow is:

Client
  |
  v
Kong Gateway
  |
  v
Kubernetes Service
  |
  v
Pod

Kong Ingress Controller participates in configuration and reconciliation; it is not the component proxying application traffic.

## Production Considerations

In production:

- run multiple worker nodes
- use multiple replicas for critical workloads
- configure readiness and liveness probes
- define CPU and memory requests/limits
- use RBAC and least privilege
- protect secrets
- monitor cluster and application health
- design for node and Pod failures
- avoid relying on individual Pod IP addresses

In AWS, Amazon EKS provides the managed Kubernetes control plane while application workloads normally run on worker infrastructure such as EC2 nodes.
