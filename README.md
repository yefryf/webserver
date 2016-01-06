# Ubuntu Server

Container Ubuntu Server with SSH service installed.

Apache + PHP + MariaDB5.5

This container had been created from official ubuntu image.

Config:

  - `PermitRootLogin yes`
  - `UsePAM no`
  - exposed port 22
  - default command: `/usr/sbin/sshd -D`
  - root password: `root`

# Run example

$ sudo docker run -d -P --name ubuntu_server yefryf/webserver:latest


