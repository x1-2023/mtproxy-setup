#!/bin/bash

# MTProxy installer for Digital Ocean Ubuntu droplets
# Usage: curl -sSL https://raw.githubusercontent.com/your-repo/install.sh | bash

set -e

PORT=${1:-8443}
SECRET=${2:-$(head -c 16 /dev/urandom | xxd -ps)}
USER="mtproxy"

echo "🚀 Installing MTProxy..."
echo "   Port: $PORT | Secret: $SECRET"

# Handle root user - create regular user and switch
if [[ $EUID -eq 0 ]]; then
    # Create user if doesn't exist
    if ! id "$USER" &>/dev/null; then
        useradd -m -s /bin/bash -G sudo $USER
        echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER
        echo "✅ Created user: $USER"
    fi

    # Copy SSH keys
    if [[ -d /root/.ssh && ! -f /home/$USER/.ssh/authorized_keys ]]; then
        mkdir -p /home/$USER/.ssh
        cp /root/.ssh/authorized_keys /home/$USER/.ssh/ 2>/dev/null || true
        chown -R $USER:$USER /home/$USER/.ssh
        chmod 700 /home/$USER/.ssh
        chmod 600 /home/$USER/.ssh/authorized_keys 2>/dev/null || true
    fi

    # Re-run as regular user
    cp "$0" /home/$USER/install.sh && chown $USER:$USER /home/$USER/install.sh
    cd /home/$USER && exec sudo -u $USER bash install.sh $PORT $SECRET
fi

# Check if already installed
if [[ -f ~/mtproxy/docker-compose.yml ]] && docker-compose -f ~/mtproxy/docker-compose.yml ps 2>/dev/null | grep -q "Up"; then
    echo "⚠️  MTProxy already running!"
    cat ~/mtproxy/connection-info.txt 2>/dev/null || echo "Check ~/mtproxy/ for details"
    exit 0
fi

# Install packages
echo "📦 Installing packages..."
sudo apt update
sudo apt install -y curl ufw

# Install Docker
if ! command -v docker &>/dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com | sudo sh
fi

# Install Docker Compose
if ! command -v docker-compose &>/dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Setup Docker for user
sudo usermod -aG docker $USER
sudo systemctl enable --now docker

# Setup MTProxy
echo "⚙️  Setting up MTProxy..."
mkdir -p ~/mtproxy
cd ~/mtproxy

# Create docker-compose.yml
cat > docker-compose.yml << EOF
version: '3.8'
services:
  mtproxy:
    image: telegrammessenger/proxy:latest
    container_name: mtproxy
    restart: unless-stopped
    ports:
      - "$PORT:443"
    volumes:
      - ./config:/data
    environment:
      - SECRET=$SECRET
EOF

# Create management script
cat > manage.sh << 'EOF'
#!/bin/bash
cd ~/mtproxy
case "$1" in
    start)   docker-compose up -d ;;
    stop)    docker-compose down ;;
    restart) docker-compose restart ;;
    logs)    docker-compose logs -f ;;
    status)  docker-compose ps ;;
    update)  docker-compose pull && docker-compose up -d ;;
    *) echo "Usage: $0 {start|stop|restart|logs|status|update}" ;;
esac
EOF
chmod +x manage.sh

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow $PORT/tcp
echo "y" | sudo ufw enable

# Start MTProxy
echo "🚀 Starting MTProxy..."
newgrp docker << EOF
docker-compose up -d
EOF

# Get server info
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")

# Create connection info
cat > connection-info.txt << EOF
🎉 MTProxy Ready!

📍 Server: $SERVER_IP
🚪 Port: $PORT
🔐 Secret: $SECRET

📱 Telegram Links:
https://t.me/proxy?server=$SERVER_IP&port=$PORT&secret=$SECRET
tg://proxy?server=$SERVER_IP&port=$PORT&secret=$SECRET

🔧 Management:
./manage.sh start|stop|restart|logs|status|update

💾 Files: ~/mtproxy/
EOF

# Show results
echo
echo "================================================"
cat connection-info.txt
echo "================================================"
echo
echo "✅ Installation complete!"
echo "📁 Files saved in: ~/mtproxy/"
echo "🔗 Connection info: ~/mtproxy/connection-info.txt"
echo
echo "💡 Next steps:"
echo "1. Copy a Telegram link above"
echo "2. Open in browser or Telegram"
echo "3. Enable proxy when prompted"
echo
echo "🎯 Enjoy your private Telegram proxy!"
