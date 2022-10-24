#!/bin/bash

## BEGIN INSTRUCTIONS
#
#  Run script with -s (for service type, i.e. "consul" or "nomad") and -t (install type, i.e. "server" or "client").
#  To install both consul & nomad, run with -s consul,nomad (or nomad,consul).
#  To install both client & server, run with -t server,client (or client,server).
#
#  By default, this script installs Nomad/Consul on a single host, the local machine.
#  Script prompts for admin pass to send as --ssh-target-sudo-pass $ssh_pass.
#
#  Make sure to change $advertise_addr to this machine's IP address!
#
## END INSTRUCTIONS

## Variables
datacenter_name="lab1"
server_ip="127.0.0.1"
## change this to your IP address
advertise_addr="192.168.1.22"

## Make sure at least 1 arg was passed, then prompt for password
if [[ ! $1 == "" ]]; then
    read -ps "Remote server sudo password: " ssh_pass
fi

## Functions
function install_nomad() {
    ## Install Nomad. $1 dictates install type (server, client, both)

    case $1 in
        "server")
            hashi-up nomad install \
                --local \
                --datacenter $datacenter_name \
                --bootstrap-expect 1 \
                --address 0.0.0.0 \
                --ssh-target-sudo-pass $ssh_pass \
                --retry-join $server_ip \
                --server
        ;;
        "client")
            hashi-up nomad install \
                --local \
                --datacenter $datacenter_name \
                --retry-join $server_ip \
                --client

        ;;
        "both")
            hashi-up nomad install \
                --local \
                --datacenter $datacenter_name \
                --bootstrap-expect 1 \
                --address 0.0.0.0 \
                --ssh-target-sudo-pass $ssh_pass \
                --retry-join $server_ip \
                --server \
                --client
        ;;
    esac

}

function install_consul() {
    ## Install Consul. $1 dictates install type (server, client, both)

    case $1 in
        "server")
            hashi-up consul install \
                --local \
                --advertise-addr $advertise_addr \
                --datacenter $datacenter_name \
                --bootstrap-expect 1 \
                --client-addr "0.0.0.0" \
                --server
        ;;
        "client")
            hashi-up consul install \
                --local \
                --advertise-addr $advertise_addr \
                --datacenter $datacenter_name \
                --connect \
                --retry-join $server_ip \
                --client-addr "0.0.0.0" \
        ;;
        "both")
            hashi-up consul install \
                --local \
                --advertise-addr $advertise_addr \
                --datacenter $datacenter_name \
                --bootstrap-expect 1 \
                --retry-join $server_ip \
                --server \
                --client-addr "0.0.0.0" \
                --connect 
        ;;
    esac

}

function install_vault() {
    ## Install Vault. $1 dictates install type (server, client, both)

    hashi-up vault install \
        --local \
        --storage consul \
        --consul-path "vault/"

}

## Create empty array for positional arguments
POSITIONAL_ARGS=()

## Parse cli args
while [[ $# -gt 0 ]]; do
    case $1 in
        "-s" | "--service")
            ## Set service type to value of -s
            SERVICE="$2"
            shift  # Past argument
            shift  # Past value
        ;;
        "-t" | "--type")
            ## Set install type to value of -t
            INSTALL_TYPE="$2"
            shift
            shift
        ;;
        "*")
            ## Append additional/unmatched args to POSITIONAL_ARGS
            POSITIONAL_ARGS+=("$1")
            shift
        ;;
    esac
done

# Restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"

## Parse -s arg val
case $SERVICE in
    "nomad")
        ## Parse -t arg val
        case $INSTALL_TYPE in
            "server")
                echo "Install Nomad server"
                install_nomad server
            ;;
            "client")
                echo "Install Nomad client"
                install_nomad client
            ;;
            "server,client" | "server+client" | "server-client" | "client,server" | "client+server" | "client-server")
                echo "Install Nomad server + client"
                install_nomad both
            ;;
            "*" | "")
                echo "Invalid install type: $INSTALL_TYPE"
                echo "  Options: server, client, {server,client | server+client | server-client}"
            ;;
        esac
    ;;
    "consul")
        ## Parse -t arg val
        case $INSTALL_TYPE in
            "server")
                echo "Install Consul server"
                install_consul server
            ;;
            "client")
                echo "Install Consul client"
                install_consul client
            ;;
            "server,client" | "server+client" | "server-client" | "client,server" | "client+server" | "client-server")
                echo "Install Consul server + client"
                install_consul both
            ;;
            "*" | "")
                echo "Invalid install type: $INSTALL_TYPE"
                echo "  Options: server, client, {server,client | server+client | server-client}"
            ;;
        esac
    ;;
    "vault")
        install_vault
    ;;
    "nomad,consul" | "nomad+consul" | "nomad-consul" | "consul,nomad" | "consul+nomad" | "consul-nomad")
        case $INSTALL_TYPE in
            "server")
                echo "Install Nomad & Consul server"
                install_consul server
                install_nomad server
            ;;
            "client")
                echo "Install Nomad & Consul client"
                install_consul client
                install_nomad client
            ;;
            "server,client" | "server+client" | "server-client")
                echo "Install Nomad & Consul server + client"
                install_consul both
                install_nomad both
            ;;
            "*" | "")
                echo "Invalid install type: $INSTALL_TYPE"
                echo "  Options: server, client, {server,client | server+client | server-client}"
            ;;
        esac
    ;;
    "all")
        case $INSTALL_TYPE in
            "server")
                echo "Install Nomad (server), Consul (server), & Vault"
                install_consul server
                install_nomad server
                install_vault
            ;;
            "client")
                echo "Install Nomad (client), Consul (client), & Vault"
                install_consul client
                install_nomad client
                install_vault
            ;;
            "server,client" | "server+client" | "server-client")
                echo "Install Nomad (server + client), Consul (server + client), & Vault"
                install_consul both
                install_nomad both
                install_vault
            ;;
            "*" | "")
                echo "Invalid install type: $INSTALL_TYPE"
                echo "  Options: server, client, {server,client | server+client | server-client}"
            ;;
        esac
    ;;
    "*" | "")
        echo "Invalid option for Service: $SERVICE"
    ;;
esac
