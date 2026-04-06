# ShopSmart Infrastructure Architecture Document

**Document ID:** ARCH-2024-SS-001
**Version:** 2.3
**Classification:** Internal
**Last Updated:** 2024-11-15
**Owner:** Platform Engineering Team

---

## 1. Overview

ShopSmart is an e-commerce platform serving approximately 50,000 daily active users.
This document describes the production infrastructure architecture required to operate
the ShopSmart application on Amazon Web Services. It is intended to serve as the
authoritative reference for provisioning and disaster recovery.

---

## 2. Architecture Diagram

```
                         +-----------------------+
                         |      INTERNET          |
                         +-----------+-----------+
                                     |
                                     |
                         +-----------+-----------+
                         |   Internet Gateway     |
                         +-----------+-----------+
                                     |
                         +-----------+-----------+
                         |     Route Table        |
                         |   0.0.0.0/0 -> IGW     |
                         +-----------+-----------+
                                     |
                    +----------------+----------------+
                    |                                 |
         +----------+----------+           +----------+----------+
         |  Public Subnet 1    |           |  Public Subnet 2    |
         |  10.0.1.0/24        |           |  10.0.2.0/24        |
         |  AZ: us-west-2a     |           |  AZ: us-west-2b     |
         +----------+----------+           +---------------------+
                    |
         +----------+----------+
         |   EC2 Instance      |
         |   t2.micro          |
         |   Amazon Linux 2    |
         |                     |
         |   SG: HTTP (80)     |
         |       SSH  (22)     |
         +---------------------+

         +---------------------+           +---------------------+
         |  S3 Bucket          |           |  S3 Bucket          |
         |  Product Images     |           |  Application Logs   |
         |                     |           |                     |
         |                     |           |  Lifecycle:          |
         |                     |           |  -> Glacier @ 90d   |
         +---------------------+           +---------------------+

         VPC: 10.0.0.0/16
```

---

## 3. Networking

### 3.1 Virtual Private Cloud (VPC)

| Property | Value |
|---|---|
| CIDR Block | `10.0.0.0/16` |
| DNS Support | Enabled |
| DNS Hostnames | Enabled |
| Region | `us-west-2` (Oregon) |

### 3.2 Subnets

Two public subnets are provisioned across separate Availability Zones for redundancy.

| Subnet | CIDR Block | Availability Zone | Public IP on Launch |
|---|---|---|---|
| Public Subnet 1 | `10.0.1.0/24` | `us-west-2a` | Yes |
| Public Subnet 2 | `10.0.2.0/24` | `us-west-2b` | Yes |

### 3.3 Internet Gateway

An Internet Gateway is attached to the VPC to provide inbound and outbound internet
connectivity for resources in the public subnets.

### 3.4 Route Table

A single route table is associated with both public subnets.

| Destination | Target |
|---|---|
| `10.0.0.0/16` | Local |
| `0.0.0.0/0` | Internet Gateway |

---

## 4. Compute

### 4.1 Application Server (EC2)

| Property | Value |
|---|---|
| Instance Type | `t2.micro` |
| AMI | Amazon Linux 2 (latest, region-specific) |
| Subnet | Public Subnet 1 (`10.0.1.0/24`) |
| Public IP | Enabled (via subnet setting) |
| Key Pair | Operator-managed |

### 4.2 Security Group

The application server security group enforces the following inbound rules:

| Protocol | Port | Source | Purpose |
|---|---|---|---|
| TCP | 80 | `0.0.0.0/0` | HTTP traffic from the internet |
| TCP | 22 | `10.0.0.0/8` | SSH access from internal network only |

**Outbound:** All traffic allowed (default).

> **Security Note:** SSH access is restricted to the internal network range (`10.0.0.0/8`).
> SSH must never be opened to `0.0.0.0/0` in any environment.

---

## 5. Storage

### 5.1 Product Images Bucket (S3)

| Property | Value |
|---|---|
| Purpose | Store product catalog images |
| Versioning | Not required |
| Encryption | Default (SSE-S3) |
| Public Access | Blocked |

### 5.2 Application Logs Bucket (S3)

| Property | Value |
|---|---|
| Purpose | Centralized application log storage |
| Versioning | Not required |
| Encryption | Default (SSE-S3) |
| Public Access | Blocked |

**Lifecycle Policy:**

| Rule | Transition | Days |
|---|---|---|
| Archive old logs | Transition to Glacier | 90 |

All objects in the logs bucket must be transitioned to the S3 Glacier storage class
after 90 days to reduce long-term storage costs.

---

## 6. Tagging Standard

All infrastructure resources must carry the following tags for cost allocation,
ownership tracking, and automation.

| Tag Key | Value | Purpose |
|---|---|---|
| `Project` | `shopsmart` | Cost allocation and resource grouping |
| `Environment` | `disaster-recovery` | Environment identification |
| `ManagedBy` | `terraform` | Identifies IaC-managed resources |

---

## 7. Disaster Recovery

In the event of a regional outage, this architecture document serves as the
authoritative specification for rebuilding the ShopSmart infrastructure in an
alternate AWS region. The target recovery region is `us-west-2` (Oregon).

**Recovery Time Objective (RTO):** 1 hour
**Recovery Point Objective (RPO):** Dependent on backup frequency (out of scope)

The infrastructure should be fully reproducible from this document using
Infrastructure as Code tooling.
