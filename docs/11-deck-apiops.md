# decK and APIOps

## Objective

Demonstrate declarative Kong Gateway configuration validation and understand how decK fits into a controlled API platform delivery workflow.

---

## What is decK?

decK is a command-line tool for managing and validating Kong Gateway configuration.

Instead of manually changing Gateway configuration, configuration can be represented as code:

```text
Git
 |
 v
Kong declarative configuration
 |
 v
Validation
 |
 v
Review
 |
 v
Deployment / Synchronisation
```

This enables an APIOps-style workflow.

---

## Repository Configuration

The lab contains:

```text
deck/kong.yaml
```

The declarative configuration includes example Kong Services, Routes and plugins.

---

## Offline Validation

The repository validates the configuration with:

```bash
deck file validate deck/kong.yaml
```

This catches configuration errors before deployment.

For example, introducing an invalid property causes validation to fail rather than allowing the bad configuration to progress unnoticed.

---

## CI Validation

GitHub Actions automatically runs decK validation when repository changes are pushed.

Conceptually:

```text
Developer
    |
    v
Git push / Pull Request
    |
    v
GitHub Actions
    |
    v
deck file validate
    |
    +---- valid ----> continue
    |
    +---- invalid --> fail pipeline
```

This moves configuration checking earlier in the delivery lifecycle.

---

## Typical Managed Gateway Workflow

For a Kong deployment managed directly through decK, a production workflow may include:

```text
1. Validate configuration
2. Connect to the intended Gateway
3. Export/backup current state
4. Compare desired and current state
5. Review changes
6. Synchronise approved configuration
7. Verify resulting state
```

Representative commands include:

```bash
deck file validate deck/kong.yaml

deck gateway ping

deck gateway dump -o backup.yaml

deck gateway diff deck/kong.yaml

deck gateway sync deck/kong.yaml
```

Exact command behaviour should always be checked against the decK version being used.

---

## Important Sync Behaviour

`deck gateway sync` is not equivalent to simply adding missing objects.

It reconciles the managed Gateway state with the supplied desired configuration.

Configuration absent from the managed desired state can therefore be removed.

For production:

```text
validate
   |
backup
   |
diff
   |
review
   |
sync
   |
verify
```

Do not treat `sync` as a harmless command.

---

## Configuration Ownership

One of the most important platform design decisions is determining which system owns Gateway configuration.

For example:

```text
Kubernetes APIs
      |
      v
Kong Ingress Controller
```

or:

```text
Git declarative config
      |
      v
decK
      |
      v
Kong Admin API
```

Avoid having multiple independent systems manage the same Kong entities.

For example:

```text
KIC --------\
             > same Route
decK -------/
```

creates ambiguous ownership and configuration drift.

---

## This Lab's Ownership Model

The running local Kubernetes Gateway is primarily managed through Kubernetes resources and Kong Ingress Controller.

Therefore, this repository uses decK primarily for:

```text
declarative configuration learning
offline validation
CI/APIOps practice
```

The lab does **not** use `deck gateway sync` against the KIC-managed DB-less runtime.

This keeps the configuration ownership boundary explicit.

---

## DB-less Consideration

A DB-less Kong deployment loads declarative configuration without using the traditional database-backed entity-management model.

`deck gateway` commands operate through Kong's Admin API and are not the management mechanism for a DB-less Gateway.

Offline commands such as:

```bash
deck file validate
```

remain useful because they validate declarative configuration without modifying the running Gateway.

---

## Partial Configuration Ownership

Larger organisations may divide Kong configuration ownership between teams.

When partial configuration management is required, ownership must be deliberately scoped so that one pipeline does not delete or overwrite another team's resources.

Tags and repository boundaries can form part of that strategy, depending on the deployment model.

The core rule remains:

```text
one clearly defined owner
for each managed Gateway resource
```

---

## APIOps

APIOps applies software delivery practices to API platform configuration.

A typical workflow is:

```text
Engineer
   |
   v
Git branch
   |
   v
Configuration change
   |
   v
Automated validation
   |
   v
Pull request
   |
   v
Review
   |
   v
Approved merge
   |
   v
Controlled deployment
   |
   v
Post-deployment verification
```

Benefits include:

- version history
- peer review
- automated validation
- reproducibility
- rollback capability
- auditability
- reduced manual configuration drift

---

## decK vs KIC vs Terraform vs Helm

These tools solve different problems.

```text
Helm
  -> installs/configures Kong platform components

KIC
  -> translates Kubernetes networking resources into Kong configuration

decK
  -> validates/manages Kong Gateway entity configuration

Terraform
  -> manages infrastructure and supported platform resources declaratively
```

The important architecture question is not:

```text
Which tool is best?
```

It is:

```text
Which tool owns which resource?
```

Clear ownership prevents configuration conflicts.

---

## Key Lessons

1. Kong configuration should be version controlled rather than relying on ad-hoc production changes.

2. Validate configuration before deployment.

3. Review differences before synchronising Gateway state.

4. `deck gateway sync` can remove configuration that is outside the supplied managed state.

5. KIC and decK should not independently own the same Kong resources.

6. DB-less Kong and database-backed Kong require different management approaches.

7. Offline decK validation is useful even when decK does not own the running Gateway.

8. CI validation catches configuration mistakes before they reach production.

9. APIOps combines Git, automation, review and controlled deployment.

10. Configuration ownership is an architectural decision, not merely a tooling decision.
