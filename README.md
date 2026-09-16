# Docker-based simple UNICORE interface to a HPC cluster

## Overview

This is a Docker container (based on Ubuntu) running a minimal
UNICORE server which connects to a HPC cluster via SSH.


*NOTE*: this is not a general purpose UNICORE installation. For most usage scenarios,
you should run a TSI and use standard configuration. Please see
[the documentation](https://unicore-docs.readthedocs.io/en/latest/gettingstarted.html)


In contrast to a standard UNICORE installation, it does not require a TSI
on the HPC login node(s). A fixed service account on the HPC cluster
will be used, accessed via SSH using a fixed key.


## Configuration

The basic requirements are

 * a host machine capable of running the docker container: 4 cores, 2GB memory, 10GB of diskspace
 * a local directory on the host for storing configuration files which will be mounted 
   into the container
 * a publicly accessible network interface (host and port)
 * a HPC user account and associated SSH key (without MFA!)

Optional configuration items are

 * a web server certificate (if not provided, a self-signed certificate will be created and used)

Configuration files are held in the (in-container) "/local" directory. This should be bound to a directory
on the host to make configuration and operation easier.


### Main configuration file

Most of the configuration is provided in a file

 * /local/environment.sh


An example '/local/environment.sh' file 


```

# Public endpoint
export PUBLIC_ENDPOINT=https://localhost:8080/UNICORE

# HPC login node
export HPC_LOGIN_NODE=login1.hpc-your-org.info

# User account and SSH key for accessing HPC
export HPC_USER=service1
export HPC_USER_KEY=/local/user-sshkey
export HPC_USER_PASSPHRASE=secret

# where do job directories go
export HPC_JOBS_DIRECTORY='$HOME/UNICORE_Jobs'

# TSI location
export HPC_TSI_PATH='$HOME/.unicore/tsi.pyz'
# Download the TSI code before first use
export HPC_TSI_SETUP='mkdir -p .unicore ; [ -f .unicore/tsi.pyz ] || wget -q https://github.com/UNICORE-EU/tsi/releases/download/11.2.0/unicore-tsi-slurm-11.2.0.pyz -O .unicore/tsi.pyz'

# Authentication
export AUTHENTICATION='FILE OAUTH'
export OAUTH_ISSUER_URL=https://your-kc.org/realms/master/protocol/openid-connect/

```

### External access

To make the UNICORE API accessible for external clients / applications, a publicly accessible address
is required (for testing, a local address can be used).

### SSH configuration

All access to the HPC cluster is done via SSH through a single user account.

### OIDC integration

An OIDC server (like Keycloak or Unity) can be configured for user authentication - only REST API calls authenticated
with a valid OAuth token will be accepted.


### Server certificate (optional) and trusted CAs

The server credential (private key and certificate in a single PEM file)
 * /local/server-credential.pem

Trusted CA certificates (especially the CA certificate of the OAuth server) in PEM format go in
 * /local/trusted/


## Running the service

To start the container in interactive mode:

```bash
export PORT=8080
export LOCAL_CONF=/etc/unicore
docker run -p ${PORT}:8080 --mount type=bind,src=${LOCAL_CONF}$,dst=/local -ti ghcr.io/unicore-eu/unicore-connector
```

or as a detached service

```bash
export PORT=8080
export LOCAL_CONF=/etc/unicore
docker run -p ${PORT}:8080 --mount type=bind,src=${LOCAL_CONF},dst=/local -d ghcr.io/unicore-eu/unicore-connector
```


### Logging

Logfiles (in-container) are in '/var/log/unicore'

### Persistent data

Data (e.g. job metadata) is stored (in-container) in '/var/run/unicore/unicorex-data'


## Using the service

### Authentication

Apart from OIDC, the default setup includes username/password authentication. This is convenient for testing and can later be disabled.

This is configured in '/local/user-authfile.txt', with a default 'unicore' user with password 'test123'.

### Testing

Any UNICORE client can be used, for PyUNICORE

```bash

# install PyUNICORE
pip install -U pyunicore

# create a config file

cat > /tmp/unicore.preferences << EOF

authentication-method=USERNAME
username=unicore
password=test123

registry=https://localhost:8080/UNICORE/rest/registries/default_registry

accept-all-issuers=true
client.serverHostnameChecking=NONE

EOF

# show info about the service
unicore info -c /tmp/unicore.preferences  https://localhost:8080/UNICORE/rest/core

# run a short test executable 'id'
unicore exec -v -c /tmp/unicore.preferences -- id
```

