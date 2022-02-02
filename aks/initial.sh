RESOURCE_GROUP=danshue-rg
AZURE_REGION=westus2
AKS_CLUSTER_NAME=aks-tripinsights-danshue
ACR_NAME=registryltt9233.azurecr.io
AKS_VNET=danshue-vnet
AKS_VNET_SUBNET=danshue-subnet

# latest version of extension account
az extension add --upgrade -n account

AAD_TENANT_ID=$(az account tenant list --query id -o tsv)

# Create Resource Group
az group create --name $RESOURCE_GROUP --location $AZURE_REGION

# Create VNET
az network vnet create --name $AKS_VNET --resource-group $RESOURCE_GROUP --subnet-name $AKS_VNET_SUBNET

# Crate Subnet
az network vnet subnet create -n $AKS_VNET_SUBNET --vnet-name $AKS_VNET -g $RESOURCE_GROUP --address-prefixes "10.0.0.0/24"

# Create an AKS-managed Azure AD cluster
#az aks create -g $RESOURCE_GROUP -n $AKS_CLUSTER_NAME --enable-aad --aad-admin-group-object-ids <id-1,id-2> --aad-tenant-id $AAD_TENANT_ID
az aks create -g $RESOURCE_GROUP -n $AKS_CLUSTER_NAME --enable-aad --enable-azure-rbac

# Get your AKS Resource ID
AKS_ID=$(az aks show -g $RESOURCE_GROUP -n $AKS_CLUSTER_NAME --query id -o tsv)
az role assignment create --role "Azure Kubernetes Service RBAC Admin" --assignee <AAD-ENTITY-ID> --scope $AKS_ID



az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME


# update each ingress controller to the name of the cluster and namespace
k apply -f namespaces.yaml
k apply -f secrets.yaml
k apply -f poi.yaml
k apply -f trips.yaml
k apply -f tripviewer.yaml
k apply -f user-java.yaml
k apply -f userprofile.yaml

k get ingress --namespace tripinsights-frontend  
k get ingress --namespace tripinsights-backend  

k get pods --namespace tripinsights-frontend  
k get pods --namespace tripinsights-backend


k describe ingress poi-ingress -n tripinsights-backend

k logs
k exec sh
