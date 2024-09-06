# charms-testing-scripts

----

This repo contains some scripts to ease the iteration process on testing of the NoSQL charms during development.

----


## For OpenSearch

### 1. Clone
```
git clone https://github.com/canonical/opensearch-operator
git clone https://github.com/Mehdi-Bendriss/charm-testing-scripts
cd charm-testing-scripts/opensearch
```

### 2. Deploy:
#### For large deployments
```
bash deploy.sh --type large --project ../../opensearch-operator/

# Add integrations
juju switch :dev1
juju integrate main:peer-cluster-orchestrator failover:peer-cluster

juju switch :dev2
juju integrate main:peer-cluster-orchestrator data:peer-cluster
juju integrate main:peer-cluster-orchestrator ml:peer-cluster
juju integrate failover:peer-cluster-orchestrator data:peer-cluster
juju integrate failover:peer-cluster-orchestrator ml:peer-cluster
```

#### For small deployments
```
bash deploy.sh --type small --project ../../opensearch-operator/
```
