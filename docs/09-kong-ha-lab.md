# Kong Gateway High Availability Lab

## Objective

Demonstrate that Kong Gateway remains available when one Gateway pod fails.

## Architecture

```text
Test Client
    |
    v
Kubernetes Service
    |
    +---------+---------+
    |         |         |
    v         v         v
 Kong-1    Kong-2    Kong-3
