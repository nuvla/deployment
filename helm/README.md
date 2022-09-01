# NuvlaEdge Engine installation in Kubernetes

**This installation method is still in trial and should not be used for production**

## Requirements

Make sure you have:
 - a Kubernetes cluster
 - Helm (v3.4.2 or higher) on any machine, with access to the Kubernetes cluster above (it is enough to `export KUBECONFIG=/path/to/target-k8s-admin.conf` on the same node where Helm is installed)

## Install the NuvlaEdge Engine

First, go through the usual NuvlaEdge creation process via Nuvla, to get your `NUVLAEDGE_UUID`.

This installation places the NuvlaEdge Engine in a single node of the Kubernetes cluster (preferrably a master). So before doing the installation, make sure you choose your TARGET_KUBERNETES_NODE_NAME. You can do this by running `kubectl get nodes` and choosing one of the master nodes.

Then, from this directory, run:

```
helm install --set NUVLAEDGE_UUID=<paste_NUVLAEDGE_UUID_from_nuvla> \
    --set kubernetesNode=<TARGET_KUBERNETES_NODE_NAME> \
    $(echo "<paste_NUVLAEDGE_UUID_from_nuvla>" | tr "/" "-") \
    ./nuvlaedge-engine
```

This will install the core NuvlaEdge Engine components in your Kubernetes node, within the namespace "nuvlaedge-<uuid_of_your_nuvlaedge>".

### Enable optional NuvlaEdge Engine components

The following components are optional:
 - security
 - peripheral-manager-usb
 - peripheral-manager-network
 - peripheral-manager-bluetooth
 - peripheral-manager-gpu
 - peripheral-manager-modbus
 
To enable them at installation time, simply add `--set security=true --set peripheralManagerGPU=true     # etc.` to the command above, according to your preferences.

### Parameterization

There are certain parameters that can be set at installation time.

#### Change the Docker Images of the components being installed

Add `--set images.<componentName>.repository=<your_image_repo> --set images.<componentName>.tag=<your_image_tag>` to the command above, for every component's Docker image you want to override. The <componentName> values can be found in "./nuvlaedge-engine/values.yaml".

Example:

```
helm install --set NUVLAEDGE_UUID=<paste_NUVLAEDGE_UUID_from_nuvla> \
    --set kubernetesNode=<TARGET_KUBERNETES_NODE_NAME> \
    --set images.agent.repository=nuvladev/agent \
    --set images.agent.tag=master \
    # etc...
```
