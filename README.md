lukscrypt Ansible Role
=========================================

Ansible role to setup lvm on luks. This role is destructive, please exercise
caution. The target device will potentially have its partition table and all
data wiped. The role will create a new GPT partition on the target block device
and create the following three partitions:

1. Linux EFI partition
2. Linux BOOT partition
3. Linux crypto_LUKS partition

Additionally, the role will securely erase the LUKS partition as described on
the [Arch Wiki](https://wiki.archlinux.org/index.php/Dm-crypt/Drive_preparation#Secure_erasure_of_the_hard_disk_drive).
Finally, it will create an LVM volume group on the LUKS partiton and add three
logical volumes (root, home, swap).

This role passes idempotency tests, meaning no changes will occur on
additional runs.

The function of this role can be tested with `kitchen-ci` and `vagrant`.

Requirements
------------

To run this role you need a block device that contains no vital information.

Role Variables
--------------

The following variables are read from other roles and/or the global scope (ie.
hostvars, group vars, etc.), and are a prerequisite for any changes to occur on
the targeted host/hosts.

* `lukscrypt_container` (string) - Default `luks-container`, block device mapper name used while wiping LUKS partition.
* `lukscrypt_boot_part_size` (string) - Default `2GiB`, size of boot partition, at a minimum this should be `256MiB`.
* `lukscrypt_efi_part_size` (string) - Default `150MiB`, size of EFI partition.
* `lukscrypt_passphrase` (string) - Passphrase used to secure LUKS partition, `:` should be avoided.
* `lukscrypt_blockdevice` (string) - Block device that will potentially have all data destroyed.
* `lukscrypt_vg_name` (string) - LVM volume group name.
* `lukscrypt_lv_root_size` (string) - Size of root logical volume (i.e. 200m)
* `lukscrypt_lv_home_size` (string) - Size of home logical volume (i.e. 200m)
* `lukscrypt_lv_swap_size` (string) - Size of swap logical volume (i.e. 200m)


Example Playbook
----------------

```yaml
---
- hosts: localhost
  become: true
  become_method: sudo
  vars:
    lukscrypt_passphrase: "SecretPassphrase."
    lukscrypt_blockdevice: /dev/sdb
    lukscrypt_boot_part_size: 100MiB
    lukscrypt_efi_part_size: 100MiB
    lukscrypt_vg_name: ryzen-system
    lukscrypt_lv_root_size: 200m
    lukscrypt_lv_home_size: 200m
    lukscrypt_lv_swap_size: 100m
  roles:
    - ansible-lukscrypt

```

License
-------

[MIT][license]

Author Information
------------------

Author:: [Carlos Hernandez][hurricanehrndz] <[carlos@techbyte.ca](carlos@techbyte.ca)>



[hurricanehrndz]: https://github.com/hurricanehrndz
[license]: http://opensource.org/licenses/MIT
