container rm -f dotfile-test 2>/dev/null || true

container run -it \
  --name dotfile-test \
  --dns 8.8.8.8 \
  -v ~/.dotfiles:/tmp/.dotfiles:ro \
  ubuntu:latest \
  bash -c '
    apt-get update && \
    apt-get install -y sudo git && \
    rm -rf /var/lib/apt/lists/*;
    
    # Create user if it doesn"t exist (Standard Ubuntu images don"t have it)
    id -u ubuntu &>/dev/null || useradd -m -s /bin/bash ubuntu
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

    echo "changing perms";
    cp -r /tmp/.dotfiles /home/ubuntu/.dotfiles;
    mkdir -p /home/linuxbrew/.linuxbrew && chown -R ubuntu:ubuntu /home/linuxbrew
    chown -R ubuntu:ubuntu /home/ubuntu/.dotfiles;
    
    echo "setup init starting";
    passwd -d ubuntu;
    cd /home/ubuntu/.dotfiles;
    /bin/bash setup_init.sh;
    
    echo "setup brew starting";
    # Use single quotes inside the double quotes for the sudo command
    sudo -u ubuntu bash -c "cd ~/.dotfiles && chmod +x ./setup_brew.sh && ./setup_brew.sh && chmod +x ./setup_zsh.sh && ./setup_zsh.sh"; bash
  '