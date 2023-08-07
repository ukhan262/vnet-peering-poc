#!/bin/bash

az account clear

# Login to your Azure account
az login

# Get a list of all subscriptions
echo "" > peerings.txt
echo "" > syncedpeerings.txt
subscriptions=$(az account list --query "[].name" -o tsv)

# Loop over each subscription
for subscription in $subscriptions; do    
    if [[ $subscription == *"az3"* ]]; then
        echo "==================================="
        echo "SUBSCRIPTION: $subscription"
        echo "==================================="

        az account set --subscription $subscription

        # Get a list of all resource groups in the current subscription
        resource_groups=$(az group list --query "[].name" -o tsv)

        # Loop over each resource group
        for resource_group in $resource_groups; do
            echo "Resource Group: $resource_group"

            # Get a list of all virtual networks in the current resource group
            virtual_networks=$(az network vnet list --resource-group $resource_group --query "[].name" -o tsv)

            # Loop over each virtual network
            for virtual_network in $virtual_networks; do
                echo "Virtual Network: $virtual_network"

                # Query all peerings for the current virtual network
                peerings=$(az network vnet peering list --resource-group $resource_group --vnet-name $virtual_network --query "[].{Name:name, PeeringSyncLevel:peeringSyncLevel}" -o json)

                # Loop over each peering
                for peering in $(echo "${peerings}" | jq -c '.[]'); do
                    peering_name=$(echo "${peering}" | jq -r '.Name')
                    peering_sync_level=$(echo "${peering}" | jq -r '.PeeringSyncLevel')

                    if [ "$peering_sync_level" != "FullyInSync" ]; then
                        echo "Peering '$peering_name' for virtual network '$virtual_network' in resource group '$resource_group' is not fully in sync. Initiating sync..."
                        az network vnet peering sync --resource-group $resource_group --vnet-name $virtual_network --name $peering_name --query "remoteVirtualNetwork.id" -o tsv >> peerings.txt
                        echo "Sync initiated for peering '$peering_name'." >> peerings.txt
                    else
                        echo "Peering '$peering_name' for virtual network '$virtual_network' in resource group '$resource_group' is already fully in sync." >> syncedpeerings.txt
                    fi
                done
            done
        done

        echo "==================================="
        echo "======= NEXT SUBSCRIPTION ========="
        echo "==================================="
    fi

    echo "Not an az3 subscription $subscription"
done