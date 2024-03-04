#!/bin/bash
### --- Prompt ------------------------
echo "export PS1='[\[\033[0;31m\]\u@\h\[\033[00m\]:\[\033[00;36m\]\W\[\033[00m\]]\[\033[01;94m\]\[\033[00m\]\# '" >> /root/.bashrc
echo "export PS1='[\[\033[0;33m\]\u@\h\[\033[00m\]:\[\033[00;36m\]\W\[\033[00m\]]\[\033[01;94m\]\[\033[00m\]\$ '" >> /home/ec2-user/.bashrc
cd /tmp/
yum update -y
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
curl -L https://github.com/sharkdp/bat/releases/download/v0.18.3/bat-v0.18.3-x86_64-unknown-linux-musl.tar.gz -o bat-v0.18.3.tar.gz
tar xzf bat-v0.18.3.tar.gz
cp bat-v0.18.3-x86_64-unknown-linux-musl/bat /usr/local/bin/
yum install -y tree vim htop git tmux mysql
cat <<EOF >> /home/ec2-user/.bashrc
alias vi='vim'
alias tree='tree -C'
alias bat='bat --style=plain --paging never'
alias y='bat -lyaml --paging never'
alias l='bat -llog --paging never'
alias kkk='bat -l nix --paging never'
alias kk='bat -l gvy --paging never'
alias k='bat -l hs --paging never'
EOF

cat <<EOF >> /home/ec2-user/.vimrc
colorscheme desert
set ts=2
set sts=2
set sw=2
set expandtab
syntax on
set cindent
set ruler
EOF

echo "[client]
user=
password=
host=
" > /home/ec2-user/.my.cnf
