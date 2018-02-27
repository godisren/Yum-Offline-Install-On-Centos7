#!/bin/bash

# install software you want
softwares=(httpd perl)
local_repo_path=$(pwd)"/my_repo/"

# prepare
mkdir $local_repo_path

# download neccessary rpm, for example 'httpd' or 'perl'
# if rpm files are already in a folder, then can skip this step.
for s in ${softwares[@]} ; do yum install --downloadonly --downloaddir=$local_repo_path $s; done

# 1.make our own repository.
yum install createrepo -y
createrepo --database $local_repo_path

# 2.define local repository
repo_file=/etc/yum.repos.d/MyRepo.repo
cat > $repo_file <<- EOM
[MyRepo]
name=My Repo
baseurl=file://$local_repo_path
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOM

# 3.show all repository
yum repolist

# 4.install softwares and disable all repositories besides our local repository
for s in ${softwares[@]} ; do yum --disablerepo=* --enablerepo=MyRepo install $s -y; done

# 5.delete local repositoy
rm $repo_file
