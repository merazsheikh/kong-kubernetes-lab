# Request Header Validator

Example Kong custom plugin used by the Kong Kubernetes Lab.

## Behaviour

The plugin checks for a configurable HTTP request header.

Default required header:

X-Client-ID

If the header is missing, Kong rejects the request before it reaches
the upstream service.

If validation succeeds, Kong adds:

X-Header-Validated: true

to the upstream request.

## Kong PDK APIs demonstrated

- kong.request.get_header()
- kong.response.exit()
- kong.service.request.set_header()

## Purpose

This plugin is intentionally small and demonstrates Kong custom plugin
structure, configuration schemas, access-phase execution, request
inspection and request rejection.
