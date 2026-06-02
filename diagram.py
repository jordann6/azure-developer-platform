from diagrams import Diagram, Cluster, Edge
from diagrams.azure.compute import AKS
from diagrams.azure.storage import StorageAccounts
from diagrams.azure.identity import ManagedIdentities
from diagrams.onprem.gitops import Flux
from diagrams.k8s.compute import Deploy
from diagrams.onprem.vcs import Github

graph_attrs = {"fontsize": "13", "bgcolor": "white", "pad": "0.5", "splines": "ortho"}
node_attrs = {"fontsize": "11"}

with Diagram(
    "Azure Developer Platform",
    filename="docs/architecture",
    outformat="png",
    show=False,
    direction="LR",
    graph_attr=graph_attrs,
    node_attr=node_attrs,
):
    repo = Github("Platform repo\n(GitOps source)")

    with Cluster("Azure subscription · eastus"):
        with Cluster("AKS cluster (adp-az-dev)"):
            flux = Flux("Flux\nGitOps")

            with Cluster("Platform components"):
                crossplane = Deploy("Crossplane\n+ Azure provider")
                kyverno = Deploy("Kyverno\nguardrails")
                backstage = Deploy("Backstage\ngolden-path portal")

        wi = ManagedIdentities("Workload Identity\n(federated, no secrets)")
        sa = StorageAccounts("Hardened Storage\nTLS1_2 · HTTPS-only\nno public blobs")

    repo >> Edge(label="reconciles") >> flux
    flux >> Edge(label="syncs") >> [crossplane, kyverno, backstage]
    crossplane >> Edge(label="federates") >> wi
    wi >> Edge(label="provisions on claim") >> sa
