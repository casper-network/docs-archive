Getting Started Packages
========================

At release, links to installation packages and relevant documentation is available on GitHub.

- Packages are available on [GitHub](https://github.com/CasperLabs/CasperLabs/releases) 

##  Pre-built Binaries
- [Debian](https://dl.bintray.com/casperlabs/debian/) recommended for Ubuntu
- [RPM](https://dl.bintray.com/casperlabs/rpm/) recommended for Fedora
- Brew package recommended for Mac
  - tar.gz
- Docker images available via [DockerHub](https://hub.docker.com/u/casperlabs)
- Docs are available on [GitHub](https://github.com/CasperLabs/CasperLabs/blob/v0.14.0/README.md#documentation)


## Linux

| **Platform**                                         | **Package type**      | **Installation information**                                 |
| ---------------------------------------------------- | --------------------- | ------------------------------------------------------------ |
| Debian 9 Stretch  Ubuntu 16.04 LTS  Ubuntu 18.04 LTS | Debian Package (.deb) | First time installation:  apt install ./Node_0.x.x_all.deb   **Re-installation:**  systemctl stop Node && apt remove Node && rm -rf /var/lib/Node/space && apt install ./Node_0.x.x_all.deb |
| Fedora 27  Fedora 28 Fedora 29                       | RPM Package (.rpm)    | **First time installation:**  dnf install ./Node-0.x.x-1.noarch.rpm   **Re-installation:**  systemctl stop Node && dnf remove Node && rm -rf /var/lib/Node/space && dnf install ./Node-0.x.x-1.noarch.rpm |
| Other Linux distributions                            | Tarball (.tgz)        | **Prerequisites** Java - We recommend Open JDK 10, https://openjdk.java.net/projects/jdk/10/+Libsodium - [{+}](https://download.libsodium.org/doc/)https://download.libsodium.org/doc/+ installed in a standard prefix (/user or /user/local)   **First time installation:**  tar -xvf Node-0.x.x.tgz |

## Mac

| **Platform** | **Package type** | **Installation information**                                 |
| ------------ | ---------------- | ------------------------------------------------------------ |
| Mac          | Tarball (.tgz)   | **Prerequisites** Java - We recommend Open JDK 10, [{+}](https://openjdk.java.net/projects/jdk/10/)https://openjdk.java.net/projects/jdk/10/+Libsodium - [{+}](https://download.libsodium.org/doc/)https://download.libsodium.org/doc/+ installed in a standard prefix (/user or /user/local)

 **First time installation:**  
 tar -xvf Node-0.x.x.tgz  
 cd Node-0.x.x  ./macos_install.sh

 **Note:** The `macos_install.sh` script installs the Homebrew package manager on your machine and then installs libsodium. If you already have Homebrew installed on your machine, you can refer to the script for how to install libsodium directly. |

## Docker

Although it is simple to install Node in Docker, it is important to have an understanding for working with Docker to successfully run and interface with Node.

- If you are brand new to working with Docker, read the [Docker get started documentation](https://docs.docker.com/get-started/).


[Docker](https://github.com/CasperLabs/CasperLabs/tree/v0.14.0/hack/docker)

- If you a familiar with Docker, you may find it helpful to review or have ready access to the cheat sheets published at the end of each section of the [Docker get started documentation](https://docs.docker.com/get-started/).

docker pull CasperLabs/Node


