# Docker-based simple UNICORE interface to a HPC cluster

## Quickstart

This is a Docker container (based on Ubuntu) running a minimal
UNICORE server which connects to a HPC cluster via SSH.

In contrast to a standard UNICORE installation, it does not require a TSI
on the HPC login node(s). A fixed service account on the HPC cluster
will be used.


*NOTE*: this is not a general purpose UNICORE installation. For most usage scenarios,
you should run a TSI and use standard configuration. Please see
[the documentation](https://unicore-docs.readthedocs.io/en/latest/gettingstarted.html)

To start the container in interactive mode:

```bash
docker run -p 8080:8080 -ti ghcr.io/unicore-eu/unicore-connector
```

or as a detached service

```bash
docker run -p 8080:8080 -d ghcr.io/unicore-eu/unicore-connector
```

The container exposes UNICORE REST APIs on localhost

  * UNICORE/X https://localhost:8080/UNICORE/rest/core
  * Registry https://localhost:8080/UNICORE/rest/registries/default_registry

## Configuration

### External access

Configuring the public URL

Firewall considerations

### SSH configuration

 - ssh key(s) and HPC user accounts
 - HPC login node(s)

### OIDC integration

 - OIDC token verification and user authentication
 - (optional) UNICORE token generation


## Using the service

### Authentication

### Running jobs


## Building the container

If you have Docker set up on your system, you can easily build the
container by executing `make`.  The first build may take a few
minutes.

```bash
make
```

Verify the build worked:

```bash
docker image ls
```

You can also start the container using

```bash
make run
```

or in detached mode

```bash
make run-services
```

To use a different port on the host than the default 8080, specify the port
on the command line, for example

```bash
make run-services PORT=7000
```


## Examples

TBD
