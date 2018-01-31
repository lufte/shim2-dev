## Nim dev box

First, need to install the latest Nim (which will also include the nimble package manager since version .15.0 -- note, the version bundled with most Ubuntu's except Bionic is far too old). This should be done from the latest Github code, because Nim is moving so fast.

What's going on in the background: just like with Python, as much as possible of Nim is actually written in Nim -- so the C sources below are to compile to core nim language compiler, and then the `koch` tool (in Nim) is compiled, and finally Nim libraries are compiled with the `koch` tool. In the background, what Nim is actually doing is compiling the Nim sources to C sources (and mostly readable C language sources, unlike with Cython) and then compiling the C language sources to object code.

    sudo apt-get -qy install build-essential git libssl-dev
    git clone https://github.com/nim-lang/Nim.git
    cd Nim
    git clone --depth 1 https://github.com/nim-lang/csources.git
    cd csources
    sh build.sh
    cd ../
    bin/nim c koch
    ./koch boot -d:release

Nim is now built in `~/Nim/`. 

## Build and compile Userify shim2 sources

**Please note: this may overwrite existing /opt/userify/ files.**

    export PATH=$PATH:~/Nim/bin/
    cd
    mkdir shim2
    cd shim2
    wget https://gist.githubusercontent.com/jamiesonbecker/bf4a3c8e244ff3f91ae786ebf67cf925/raw/2983534b1ba938ef9527556b21622f1fb64e809e/shim2.nim \
      https://gist.githubusercontent.com/jamiesonbecker/c79d59580e026b00a4c39843f951898a/raw/279bb8ca606dda3672bd28f4eec4e39675f11276/post_data_to_server.nim \
      https://gist.githubusercontent.com/jamiesonbecker/008ed580a767f9596863b4020f0de4eb/raw/a34a1135935d362047d328cec3761320596f9d20/shim_test.sh
    # set up fake data vars:
    sudo bash ./shim_test.sh

## Ready to compile!

    nim c -r --debugger:native -d:ssl shim2.nim

This produces fake data from the server that can be used to create users as with shim.py above:

    [shim] Version:  | Start: 0.011387 | Processors: 16
    @[(username: "test2", perm: "\"ALL=NOPASSWD: ALL\"", name: "\"test2\"", preferred_shell: "\"/bin/bash\"", ssh_public_key: "\"\""), (username: "ec2-user", perm: "\"\"", name: "\"Test User\"", preferred_shell: "\"/bin/bash\"", ssh_public_key: "\"\""), (username: "test129", perm: "\"ALL=NOPASSWD: ALL\"", name: "\"Test User 129\"", preferred_shell: "\"/bin/bash\"", ssh_public_key: "\"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCUJOYH4dez7iM+k39tHtaNb3E7eeHDsU8tCkzkmX0S jamieson@fiji\""), (username: "jamieson", perm: "\"ALL=NOPASSWD: ALL\"", name: "\"Jamieson Becker\"", preferred_shell: "\"/bin/bash\"", ssh_public_key: "\"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCUJOYH4dez7iM+k39tHtaNb3E7eeHDsU8tCkzkmX0S jamieson@fiji\""), (username: "test476", perm: "\"\"", name: "\"\"", preferred_shell: "\"/bin/bash\"", ssh_public_key: "\"\""), (username: "test50", perm: "\"ALL=NOPASSWD: ALL\"", name: "\"\"", preferred_shell: "\"/bin/bash\"", ssh_public_key: "\"\"")]
    {"shim-delay": 88.36658720667255, "darknodes_enabled": false, "users": {"test2":{"ssh_public_key":"","name":"test2","perm":"ALL=NOPASSWD: ALL","preferred_shell":"/bin/bash"},"ec2-user":{"ssh_public_key":"","name":"Test User","perm":"","preferred_shell":"/bin/bash"},"test129":{"ssh_public_key":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCUJOYH4dez7iM+k39tHtaNb3E7eeHDsU8tCkzkmX0S jamieson@fiji","name":"Test User 129","perm":"ALL=NOPASSWD: ALL","preferred_shell":"/bin/bash"},"jamieson":{"ssh_public_key":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCUJOYH4dez7iM+k39tHtaNb3E7eeHDsU8tCkzkmX0S jamieson@fiji","name":"Jamieson Becker","perm":"ALL=NOPASSWD: ALL","preferred_shell":"/bin/bash"},"test476":{"ssh_public_key":"","name":"","perm":"","preferred_shell":"/bin/bash"},"test50":{"ssh_public_key":"","name":"","perm":"ALL=NOPASSWD: ALL","preferred_shell":"/bin/bash"}}, "darknodes_ssh_server_enable_login": true}


## Additional Tips

1. Debugging info:
https://nim-lang.org/blog/2017/10/02/documenting-profiling-and-debugging-nim-code.html

2. Current shim:
https://github.com/userify/shim/blob/master/shim.py
