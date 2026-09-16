#!/bin/bash

 _base_setup(){

    if [ ! -d "/var/log/unicore" ]; then
        echo "Creating logging directory /var/log/unicore ..."
        mkdir -p /var/log/unicore && chown unicore:unicore /var/log/unicore
    fi

    if [ ! -d "/var/run/unicore" ]; then
        echo "Creating data directory /var/run/unicore ..."
        mkdir -p /var/run/unicore && chown unicore:unicore /var/run/unicore
    fi

    if [ ! -d "/local" ]; then
        echo "Creating directory /local ..."
        mkdir /local && chown unicore:unicore /local
    fi

    if [ ! -d "/local/trusted" ]; then
        echo "Creating directory /local ..."
        mkdir /local/trusted && chown unicore:unicore /local/trusted
    fi

    if [ ! -e "/local/server-credential.pem" ]; then
        echo "Creating self-signed credential /local/server-credential.pem ..."
        openssl req -x509 -newkey rsa:4096 \
                -sha256 -nodes -days 3650 \
                -keyout "/local/server-key.pem" \
                -out "/local/trusted/server-certificate.pem" \
                -subj "/C=EU/O=UNICORE/CN=UNICORE Connector"
        cat /local/server-key.pem /local/trusted/server-certificate.pem > /local/server-credential.pem
        chown unicore:unicore /local/*.pem
        chmod og+r /local/*.pem
        cp /local/server-credential.pem /local/trusted/
    fi

 }

_unicore_setup() {
    sudo -u unicore touch /var/log/unicore/unicorex.log
    if [ -e "/local/environment.sh" ]; then
        echo "Reading /local/environment.sh ..."
        . /local/environment.sh
    fi

    if [ ! -e "/local/user-authfile.txt" ]; then
        echo "Configuring access for HPC user '${HPC_USER}' ..."
        cat > /local/user-mapfile.json <<EOF
{
  ".*": {
    "role": "user",
    "xlogin": "${HPC_USER}"
  }
}
EOF
        chown unicore:unicore /local/user-mapfile.json

    fi

    if [ ! -e "/local/identities.json" ]; then
        cat > /local/identities.json <<EOF
{

  "${HPC_USER}": {
    "key": "${HPC_USER_KEY}",
    "passphrase": "${HPC_USER_PASSPHRASE}"
  }

}
EOF
        chown unicore:unicore /local/identities.json
    fi

    if [ ! -e "/local/user-authfile.txt" ]; then
        echo "Creating username/password authentication file /local/user-authfile.txt ..."
        cp /unicore/unicorex/conf/user-authfile.txt /local/
        chown unicore:unicore /local/user-authfile.txt
    fi

    if [ ! -e "/local/idb.json" ]; then
        echo "Creating cluster configuration file /local/idb.json ..."
        cp /unicore/unicorex/conf/idb.json /local/
        chown unicore:unicore /local/idb.json
    fi

}

_main() {
    _base_setup

    _unicore_setup
    if [ -e "/local/environment.sh" ]; then
        . /local/environment.sh
    fi
    echo "Starting  UNICORE ..."
    sudo -E -u unicore /unicore/start.sh

    if [[ -t 0 && -t 1 ]] ; then
	echo "Running interactive shell"
	if [[ "${1:0:1}" = "-" ]]; then
            echo "Please pass a program name to the container!"
            exit 1
	else
            exec "$@"
	fi
    else
	echo "Running detached ..."
    tail -f /var/log/unicore/unicorex.log
    fi
}

_main "$@"
