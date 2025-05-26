#!/bin/bash

# MTProxy installer for Digital Ocean Ubuntu droplets
# Usage: curl -sSL https://raw.githubusercontent.com/trungpv1601/install.sh | bash

set -e

PORT=${1:-8443}
SECRET=${2:-$(head -c 16 /dev/urandom | xxd -ps)}

echo "🚀 Installing MTProxy..."
echo "   Port: $PORT | Secret: $SECRET"

# Check if already installed
if [[ -f ~/mtproxy/docker-compose.yml ]] && docker-compose -f ~/mtproxy/docker-compose.yml ps 2>/dev/null | grep -q "Up"; then
    echo "⚠️  MTProxy already running!"
    cat ~/mtproxy/connection-info.txt 2>/dev/null || echo "Check ~/mtproxy/ for details"
    exit 0
fi

# Install packages
echo "📦 Installing packages..."
apt update
apt install -y curl ufw

# Install Docker
if ! command -v docker &>/dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com | sh
fi

# Install Docker Compose
if ! command -v docker-compose &>/dev/null; then
    echo "📦 Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Setup Docker
usermod -aG docker root
systemctl enable --now docker

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
ufw allow 22/tcp
ufw allow $PORT/tcp
echo "y" | ufw enable

# Start MTProxy
echo "🚀 Starting MTProxy..."
docker-compose up -d

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
