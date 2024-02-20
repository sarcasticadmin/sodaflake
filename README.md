# S.O.D.A Flake

A NixOS vm image for the https://github.com/jetbalsa/soda-machine

## How to build

Assuming you have nix installed locally:

```
$ nix build .#colaImage
```
> `result` will contain a symlink to your new image

## Testing

To check the basic functionality of the vm:

```
$ nix build .#nixosConfigurations.cola.config.system.build.vm
$ ./result/bin/run-nixos-vm
```

Or you can craft some user-data and see how cloud-init handles that:

```
$ cat << EOF > user-data
#cloud-config
chpasswd:
  expire: false
  users:
    - name: user
      password: scale21x
      type: text
touch meta-data
touch network-config
EOF
```

Build the image that contains the user-data and other data files:
```
$ nix shell nixpkgs#cdrkit
$ genisoimage -output seed.img -volid cidata -rational-rock -joliet user-data network-config meta-data
```

Build and run the image:

```
$ nix build .#colaImage
$ rm -f nixos.qcow2 && cp result/nixos.qcow2 . && chmod 664 nixos.qcow2
$ qemu-system-x86_64 -m 1024 -net nic -net user  -drive file=nixos.qcow2,if=virtio -drive file=seed.img,if=virtio
```

Verify that the user-data ran without error (password should be what we set it to in user-data):

```
$ journalctl -u cloud-init
$ cd /var/run/cloud
```
> Check for any failures

## Known Issues

- cloud-init needs some work in a NixOS environment. The only thing guaranteed to work is the password setup.
  - `bootcmd` seems to assume `/bin/sh` so that doesn't work at the moment.
  - Setting the hostname fails since cloud-init wants to edit the read-only symlink to the nix store. This always shows
    up in the logs
