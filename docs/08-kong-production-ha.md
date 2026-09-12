# Kong Gateway Production High Availability

## Hybrid Architecture

Kong production deployments should avoid a single Gateway instance.

```text
                    Platform / DevOps
                           |
                           v
                  +------------------+
                  |  Control Plane   |
                  +--------+---------+
                           |
                           v
                      PostgreSQL
                           |
                      Config Sync
                           |
             +-------------+-------------+
             |                           |
             v                           v
      +-------------+             +-------------+
      | Data Plane  |             | Data Plane  |
      |    AZ-A     |             |    AZ-B     |
      +------+------+             +------+------+
             ^                           ^
             |                           |
             +-------------+-------------+
                           |
                    Load Balancer
                           |
                           v
                        Clients
