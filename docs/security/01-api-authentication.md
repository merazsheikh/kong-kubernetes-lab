# Kong API Authentication

## Authentication vs Authorization

Authentication answers:

> Who is calling the API?

Authorization answers:

> Is that caller allowed to perform this operation?

## API Security Flow

Client
  |
  | Bearer Token
  v
Kong Gateway
  |
  +-- Validate authentication
  +-- Validate token
  +-- Check authorization
  +-- Apply rate limits
  +-- Apply security policies
  |
  v
Backend API

## JWT

JWTs contain signed claims.

Important claims:

- iss - token issuer
- sub - subject
- aud - intended audience
- exp - expiration
- scope - permissions

A JWT must not simply be decoded and trusted.

The gateway must validate the signature and relevant claims.

## OAuth 2.0

OAuth 2.0 is an authorization framework.

Important flows:

### Authorization Code with PKCE

Used primarily for user-facing applications.

Client -> Identity Provider -> User Authentication -> Access Token -> API

### Client Credentials

Used for machine-to-machine communication.

Service A
   |
   | client credentials
   v
Identity Provider
   |
   | access token
   v
Service A
   |
   | Bearer token
   v
Kong
   |
   v
Service B

## OpenID Connect

OIDC adds identity/authentication capabilities on top of OAuth 2.0.

Common tokens:

- ID token
- Access token
- Refresh token

The access token is normally presented to APIs.

## mTLS

Mutual TLS authenticates both sides using certificates.

Client Certificate
       |
       v
Kong Gateway
       |
       v
Backend API

Typical use cases:

- B2B APIs
- financial APIs
- machine-to-machine APIs
- high-security internal services

## Layered Security

Enterprise APIs may combine controls:

Client
  |
  | mTLS certificate
  | OAuth access token
  v
Kong
  |
  +-- mTLS authentication
  +-- token validation
  +-- authorization
  +-- rate limiting
  +-- custom security policy
  |
  v
Backend

## Design Principle

Identity providers such as Microsoft Entra ID, Okta, or Keycloak
should normally manage identities and issue tokens.

Kong should enforce API security policy at the gateway boundary.
