# Kong Troubleshooting

## Duplicate Route Security Bypass

### Scenario

A protected `/echo` route was configured with:

- JWT authentication
- ACL authorization
- rate limiting
- a custom Lua request-header validation plugin

Despite this, unauthenticated requests returned HTTP 200.

### Symptoms

Expected:

GET /echo without JWT -> 401

Observed:

GET /echo without JWT -> 200

### Investigation

The custom plugin was verified as loaded by Kong:

KONG_PLUGINS=bundled,request-header-validator

KIC successfully validated the plugin schema and synchronized configuration.

The cluster was then inspected for overlapping routes:

kubectl get ingress -A
kubectl get httproute -A

Two Ingress resources exposed the same path:

default/echo         -> /echo -> no security plugins
kong-learning/echo   -> /echo -> JWT + ACL + rate limiting + custom plugin

The unprotected route allowed traffic to reach the backend without traversing the intended security policy.

### Resolution

The obsolete Ingress was removed:

kubectl delete ingress echo -n default

After removal:

No JWT                      -> 401 Unauthorized
Valid JWT, no X-Client-ID   -> 400 Bad Request
Valid JWT + X-Client-ID     -> 200 OK

The successful request also confirmed the custom plugin executed by adding:

X-Header-Validated: true

to the upstream request.

## Troubleshooting Principle

When a Kong security policy appears to be bypassed, first confirm which Route handled the request.

Check:

1. Ingress resources
2. HTTPRoute resources
3. host and path overlap
4. Kong runtime routes
5. plugins attached to the selected route
6. KIC reconciliation logs
7. upstream connectivity

Do not assume an authentication or custom plugin is defective until route selection has been verified.
