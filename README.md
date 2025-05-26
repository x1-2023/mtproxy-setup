# 🚀 Telegram MTProxy - 5 Minute Setup

**Get your own private Telegram proxy in 5 minutes using Digital Ocean**

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=e0496d81b971&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

---

## 🎯 Quick Start (3 Steps)

### 1️⃣ Create Server
1. **Sign up** at [DigitalOcean.com](https://www.digitalocean.com/?refcode=e0496d81b971&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)
2. **Create Droplet**:
   - Image: **Ubuntu 22.04 LTS**
   - Size: **Basic $4/month**
   - Authentication: **Password**
3. **Wait 2 minutes** for server to be ready

### 2️⃣ Open Console
1. **Click your droplet name** in dashboard
2. **Click "Console" button** (top right)
3. **Login as `root`** with your password

### 3️⃣ Install MTProxy
**Copy and paste this command:**

```bash
curl -sSL https://raw.githubusercontent.com/x1-2023/mtproxy-setup/main/install.sh | bash
```

**That's it!** 🎉

---

## 📱 Connect to Telegram

After installation, you'll see connection links like:

```
📱 Telegram Links:
https://t.me/proxy?server=123.45.67.89&port=8443&secret=abc123...
```

**To connect:**
1. **Copy the link** (starts with `https://t.me/proxy`)
2. **Open in browser** or paste in Telegram
3. **Tap "Enable Proxy"** when prompted

---

## 🔧 Managing Your Proxy

**Reconnect to your server console and run:**

```bash
cd ~/mtproxy

./manage.sh start     # Start proxy
./manage.sh stop      # Stop proxy
./manage.sh restart   # Restart proxy
./manage.sh logs      # View logs
./manage.sh status    # Check status
./manage.sh update    # Update proxy
```

---

## 🆘 Troubleshooting

### Proxy not working?
```bash
cd ~/mtproxy
./manage.sh status
./manage.sh restart
```

### Lost connection info?
```bash
cd ~/mtproxy
cat connection-info.txt
```

---

## 🗑️ Remove Everything

**To delete server:** Digital Ocean dashboard → Destroy droplet

---

## 🔒 What This Script Does

- ✅ Creates secure non-root user
- ✅ Installs Docker & MTProxy
- ✅ Configures firewall (SSH + proxy only)
- ✅ Sets up auto-restart on reboot
- ✅ Generates connection links

**Files created:** `~/mtproxy/` (config, logs, management script)

---

## 🤖 About This Project

**This entire codebase was written by AI (Claude Sonnet 4)** to help non-technical users set up their own Telegram proxy quickly and safely.

- ✅ **Script**: Fully automated installation
- ✅ **Documentation**: Step-by-step guide
- ✅ **Security**: Best practices implemented
- ✅ **Support**: Troubleshooting included

**Human oversight**: Code reviewed for security and functionality.

---

**🎉 Enjoy your private Telegram proxy!**

*Need help? Run `./manage.sh logs` to see what's happening*
