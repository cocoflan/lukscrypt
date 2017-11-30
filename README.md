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

This role passes idempotency test, meaning no changes will occur on
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

* `lukscrypt_boot_fs` (string) - Default `btrfs`, boot partition file system type
* `lukscrypt_lv_root_fs` (string) - Default `btrfs`, root partition file system type
* `lukscrypt_lv_home_fs` (string) - Default `xfs`, home partition file system type
* `lukscrypt_container` (string) - Default `luks-container`, block device mapper name used while wiping LUKS partition.
* `lukscrypt_boot_part_size` (string) - Default `2GiB`, size of boot partition, at a minimum this should be `256MiB`.
* `lukscrypt_efi_part_size` (string) - Default `150MiB`, size of EFI partition.
* `lukscrypt_passphrase` (string) - Passphrase used to secure LUKS partition, `:` should be avoided.
* `lukscrypt_blockdev` (string) - Block device that will potentially have all data destroyed.
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
    lukscrypt_boot_part_size: 100MiB
    lukscrypt_efi_part_size: 100MiB
    lukscrypt_vg_name: ryzen-system
    lukscrypt_lv_root_size: 200m
    lukscrypt_lv_home_size: 200m
    lukscrypt_lv_swap_size: 100m
    blockdev_serial: S3EUNX0J500227A
  tasks:
    - name: Register | lukscrypt_all_blockdev_info_results
      command: lsblk -d -i -J --output NAME,TYPE,SERIAL,MODEL,TRAN
      register: lukscrypt_all_blockdev_info_results
      changed_when: false

    - name: Set Fact | lukscrypt_all_blockdev_info
      set_fact:
        lukscrypt_all_blockdev_info: "{{ lukscrypt_all_blockdev_info_results.stdout|from_json }}"

    - name: Set Fact | lukscrypt_blockdev | serach by serial
      set_fact:
        lukscrypt_blockdev: /dev/{{ item.name }}
      when: item.serial|search(blockdev_serial)
      with_items: "{{ lukscrypt_all_blockdev_info.blockdevices }}"

    - name: Setup lvm on LUKS
      include_role:
        name: ansible-lukscrypt
      when: lukscrypt_blockdev is defined

```

```yaml
---
- hosts: localhost
  become: true
  become_method: sudo
  vars:
    lukscrypt_passphrase: "SecretPassphrase."
    lukscrypt_boot_part_size: 100MiB
    lukscrypt_efi_part_size: 100MiB
    lukscrypt_vg_name: ryzen-system
    lukscrypt_lv_root_size: 200m
    lukscrypt_lv_home_size: 200m
    lukscrypt_lv_swap_size: 100m
    blockdev_serial: S3EUNX0J500227A
  tasks:
    - name: Register | blkdev_search_result | serach by serial
      shell: for blk_dev in $(lsblk -d -n --output NAME); do smartctl -i /dev/$blk_dev | awk -v blk_dev="$blk_dev" -v userial={{ blkdev_serial }} 'BEGIN { FS=":" } $2 ~ userial { print blk_dev; }'; done
      register: blkdev_search_result
      change_when: false

    - name: Set Fact | lukscrypt_blockdev
      set_fact:
        lukscrypt_blockdev: /dev/{{ blkdev_search_result.stdout }}
      when: blkdev_search_result is defined

    - name: Setup lvm on LUKS
      include_role:
        name: ansible-lukscrypt
      when: lukscrypt_blockdev is defined
```

License
-------

[MIT][license]

Author Information
------------------

Author:: [Carlos Hernandez][hurricanehrndz] <[carlos@techbyte.ca](carlos@techbyte.ca)>



[hurricanehrndz]: https://github.com/hurricanehrndz
[license]: http://opensource.org/licenses/MIT
