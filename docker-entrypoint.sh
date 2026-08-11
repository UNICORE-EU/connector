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
                -out "/local/server-credential.pem" \
                -subj "/C=EU/O=UNICORE/CN=UNICORE Connector"
        chown unicore:unicore /local/*.pem
        cp /local/server-credential.pem /local/trusted/
    fi

 }

_unicore_setup() {
    sudo -u unicore touch /var/log/unicore/unicorex.log
    if [ -e "/local/environment.sh" ]; then
        echo "Reading /local/environment.sh ..."
        . /local/environment.sh
    fi

    echo "Configuring access for HPC user '${HPC_USER}' ..."
    cat > /unicore/unicorex/conf/user-mapfile.json <<EOF
{
  ".*": {
    "role": "user",
    "xlogin": "${HPC_USER}"
  }
}
EOF

    cat > /unicore/unicorex/conf/identities.json <<EOF
{

  "${HPC_USER}": {
    "key": "/local/user-sshkey",
    "passphrase": "${HPC_USER_PASSPHRASE}"
  }

}


EOF

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
