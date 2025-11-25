# Working with Multiple Providers (Chapter 7 Notes)

## Map of the Examples Directory

```mermaid
flowchart LR
    Single[examples/single-account] --> RootMain["Single AWS provider"]
    MultiRegion[examples/multi-region] --> AliasPerRegion
    MultiAccountRoot[examples/multi-account-root] --> Roles["Root assumes roles"]
    MultiAccountModule[examples/multi-account-module] --> ModuleAlias
    K8sLocal[examples/kubernetes-local] --> LocalCluster
    K8sEKS[examples/kubernetes-eks] --> EKSK8s["EKS Cluster + K8s Provider"]

    classDef aws fill:#fff4e6,color:#c92a2a;
    classDef k8s fill:#e3fafc,color:#0ca678;
    class Single,MultiRegion,MultiAccountRoot,MultiAccountModule aws;
    class K8sLocal,K8sEKS k8s;
```

Each subdirectory highlights one provider pattern:

- `single-account`: baseline configuration with a single AWS provider block.
- `multi-region`: same account, multiple regions via provider aliases.
- `multi-account-root`: root Terraform code assumes roles in child accounts.
- `multi-account-module`: modules accept aliased providers.
- `kubernetes-local`: targets a local cluster with the Kubernetes provider.
- `kubernetes-eks`: provisions AWS EKS and then configures Kubernetes via the EKS kubeconfig.

---

## Provider Aliasing Cheat Sheet

```mermaid
sequenceDiagram
    participant TF as Terraform Root Module
    participant AWS1 as aws.primary (us-east-2)
    participant AWS2 as aws.replica (us-west-1)
    participant Module as module.mysql

    TF->>AWS1: provider "aws" { alias = "primary" }
    TF->>AWS2: provider "aws" { alias = "replica" }
    TF->>Module: providers = { aws = aws.primary }
    TF->>Module: (second invoke) providers = { aws = aws.replica }
```

- Declare aliases in the root module.
- Pass alias references via the `providers` map when calling modules.
- Inside modules, never declare new provider blocks; rely on the injected alias.

---

## Multi-Account Role Assumption Flow

```mermaid
flowchart LR
    Root[examples/multi-account-root] -->|profile=parent| ParentAWS
    ParentAWS -->|assume role| ChildAccount1
    ParentAWS -->|assume role| ChildAccount2
    ChildAccount1 --> ModulesAWS
    ChildAccount2 --> ModulesAWS

    classDef acct fill:#ffd8a8,color:#99582a;
    class ParentAWS,ChildAccount1,ChildAccount2 acct;
```

Steps:
1. Configure the parent profile credentials locally (or via aws-vault/SSO).
2. Terraform root uses the parent provider to assume roles in each child account.
3. Modules receive the child account providers via alias maps.
4. Outputs often include the caller identities so you can verify access.

---

## Kubernetes Example Summary

```mermaid
flowchart TD
    subgraph Local["kubernetes-local"]
        KindCluster["KinD Cluster"]
        ProviderLocal["Kubernetes provider"]
        AppLocal["Helm/Manifest app"]
    end
    subgraph EKS["kubernetes-eks"]
        AWSInfra["AWS providers: EKS + IAM"]
        Kubeconfig["Data source: aws_eks_cluster + aws_eks_cluster_auth"]
        ProviderK8s["Kubernetes provider configured from kubeconfig"]
        AppEKS["modules/services/k8s-app"]
    end
```

- Local example points the Kubernetes provider at a KinD/minikube cluster.
- EKS example wires together the AWS and Kubernetes providers so workloads are deployed immediately after the cluster comes online.

---

## Best Practices Checklist

```mermaid
graph TD
    A[Use dedicated provider aliases] --> B[Pass providers map to modules]
    B --> C[Keep state/workspaces per environment]
    C --> D[Document role assumption requirements]
    D --> E[Output caller identities for sanity checks]
    E --> F[Version-lock providers in terraform block]
```

1. **Aliases everywhere:** Even in single-account examples, start with aliases so scaling to multi-region later is easy.
2. **Module inputs:** Make `providers` blocks explicit; avoid relying on default provider since it hinders reuse.
3. **Cross-account credentials:** Document which IAM role names or profiles are required (`README.md` in each example already outlines this; keep it updated).
4. **State isolation:** Multi-region and multi-account deployments usually need separate state backends per environment to avoid drift.
5. **Diagnostics:** Expose outputs like `aws_caller_identity` for parent/child accounts to verify your workflow.

---

## Quick Map from Examples to Modules

| Example | Modules Used | Key Concept |
|---------|--------------|-------------|
| single-account | `modules/services/eks-cluster` | One provider config |
| multi-region | `modules/data-stores/mysql` twice | Same account, multiple regions |
| multi-account-root | `modules/multi-account`, `modules/data-stores/mysql` | Root assumes roles |
| multi-account-module | `modules/multi-account` | Modules accept multiple providers |
| kubernetes-local | `modules/services/k8s-app` | Non-AWS provider usage |
| kubernetes-eks | `modules/services/eks-cluster`, `modules/services/k8s-app` | Chaining AWS + Kubernetes |

Use this table to decide which pattern to follow in your own infrastructure.

