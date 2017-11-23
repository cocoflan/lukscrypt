require_relative './spec_helper'

describe 'ansible-lukscrypt:default' do

  if host_inventory['platform'] == 'opensuse'
    describe package('btrfsprogs') do
      it { should be_installed }
    end
    describe package('cryptsetup') do
      it { should be_installed }
    end
    describe package('dosfstools') do
      it { should be_installed }
    end
    describe package('lvm2') do
      it { should be_installed }
    end
    describe package('parted') do
      it { should be_installed }
    end
    describe package('util-linux') do
      it { should be_installed }
    end
    describe package('xfsprogs') do
      it { should be_installed }
    end
  end

  describe file('/dev/nbd10') do
    it { should exist }
  end

  describe file('/dev/nbd10p1') do
    it { should exist }
  end

  describe file('/dev/nbd10p2') do
    it { should exist }
  end

  describe file('/dev/nbd10p3') do
    it { should exist }
  end

  describe file('/dev/mapper/test-root') do
    it { should exist }
  end

  describe file('/dev/mapper/test-swap') do
    it { should exist }
  end

  describe file('/dev/mapper/test-home') do
    it { should exist }
  end

  describe command('blkid -o value -s TYPE /dev/nbd10p1') do
    its(:stdout) { should match(/vfat/) }
  end

  describe command('blkid -o value -s TYPE /dev/nbd10p2') do
    its(:stdout) { should match(/btrfs/) }
  end

  describe command('blkid -o value -s TYPE /dev/nbd10p3') do
    its(:stdout) { should match(/crypto_LUKS/) }
  end

  describe command('blkid -o value -s TYPE /dev/mapper/test-root') do
    its(:stdout) { should match(/btrfs/) }
  end

  describe command('blkid -o value -s TYPE /dev/mapper/test-home') do
    its(:stdout) { should match(/xfs/) }
  end

  describe command('blkid -o value -s TYPE /dev/mapper/test-swap') do
    its(:stdout) { should match(/swap/) }
  end

end
