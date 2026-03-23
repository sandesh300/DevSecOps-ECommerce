#!/bin/bash
# =============================================================================
# linux-harden.sh — Harden Ubuntu Linux for DevSecOps Pipeline
# Run as root: sudo bash linux-harden.sh
# Tested on: Ubuntu 22.04 LTS
# =============================================================================

set -euo pipefail
LOGFILE="/var/log/harden-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
section() { echo -e "\n${RED}══════════════════════════════════════════${NC}"; \
            echo -e "${RED} $* ${NC}"; \
            echo -e "${RED}══════════════════════════════════════════${NC}"; }

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0"; exit 1
fi

# =============================================================================
section "1. SYSTEM UPDATES"
# =============================================================================
info "Updating package lists and upgrading..."
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get autoclean

# Enable automatic security updates
apt-get install -y unattended-upgrades apt-listchanges
cat > /etc/apt/apt.conf.d/50unattended-upgrades <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Packages "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF
systemctl enable unattended-upgrades
info "Automatic security updates enabled."

# =============================================================================
section "2. USER SECURITY"
# =============================================================================
info "Locking root password..."
passwd -l root

info "Creating jenkins user if not exists..."
if ! id "jenkins" &>/dev/null; then
  useradd -m -s /bin/bash -G docker jenkins
  info "jenkins user created and added to docker group"
else
  usermod -aG docker jenkins
  info "jenkins already exists; added to docker group"
fi

info "Setting password aging policies..."
# Max password age: 90 days; Min: 7 days; Warn: 14 days
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/'  /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

info "Enforcing strong password policy (PAM)..."
apt-get install -y libpam-pwquality
cat > /etc/security/pwquality.conf <<'EOF'
minlen = 12
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
maxrepeat = 3
gecoscheck = 1
EOF

# =============================================================================
section "3. SSH HARDENING"
# =============================================================================
SSH_CONFIG="/etc/ssh/sshd_config"
info "Backing up SSH config..."
cp "$SSH_CONFIG" "${SSH_CONFIG}.bak.$(date +%Y%m%d)"

info "Applying SSH hardening..."
cat > "$SSH_CONFIG" <<'EOF'
# ── Port ────────────────────────────────────────────────────────────────────
Port 2222                        # Non-default port
AddressFamily inet               # IPv4 only

# ── Authentication ───────────────────────────────────────────────────────────
PermitRootLogin no               # Never allow root SSH
PasswordAuthentication no        # Key-based auth only
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
ChallengeResponseAuthentication no
UsePAM yes
KerberosAuthentication no
GSSAPIAuthentication no
PermitEmptyPasswords no

# ── Session Controls ─────────────────────────────────────────────────────────
MaxAuthTries 3
MaxSessions 4
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
TCPKeepAlive no

# ── Privilege Separation ──────────────────────────────────────────────────────
UsePrivilegeSeparation sandbox

# ── Forwarding ────────────────────────────────────────────────────────────────
AllowTcpForwarding no
X11Forwarding no
AllowAgentForwarding no
PermitTunnel no

# ── Logging ───────────────────────────────────────────────────────────────────
LogLevel VERBOSE
SyslogFacility AUTH

# ── Ciphers/MACs (modern, secure only) ───────────────────────────────────────
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
KexAlgorithms curve25519-sha256,diffie-hellman-group14-sha256

# ── Banner ───────────────────────────────────────────────────────────────────
Banner /etc/issue.net
EOF

echo "UNAUTHORIZED ACCESS PROHIBITED — All activity is monitored and logged." \
  > /etc/issue.net

systemctl restart sshd
info "SSH hardened. New port: 2222. Ensure your SSH key is added BEFORE logging out."

# =============================================================================
section "4. FIREWALL (UFW)"
# =============================================================================
apt-get install -y ufw

info "Resetting UFW to defaults..."
ufw --force reset

info "Setting default deny policies..."
ufw default deny incoming
ufw default allow outgoing

info "Allowing SSH on new port..."
ufw allow 2222/tcp comment 'SSH hardened port'

info "Allowing Jenkins web UI..."
ufw allow 8080/tcp comment 'Jenkins'

info "Allowing SonarQube..."
ufw allow 9000/tcp comment 'SonarQube'

info "Allowing Minikube NodePort range..."
ufw allow 30000:32767/tcp comment 'Minikube NodePorts'

info "Allowing Docker internal network..."
ufw allow from 172.16.0.0/12 comment 'Docker network'

info "Allowing Minikube bridge network..."
ufw allow from 192.168.49.0/24 comment 'Minikube network'

info "Enabling UFW..."
ufw --force enable
ufw status verbose
info "Firewall configured."

# =============================================================================
section "5. KERNEL HARDENING (sysctl)"
# =============================================================================
info "Applying sysctl security parameters..."
cat > /etc/sysctl.d/99-security-harden.conf <<'EOF'
# ── Network hardening ────────────────────────────────────────────────────────
net.ipv4.ip_forward = 1                        # Required for Docker/K8s
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 1

# ── IPv6 disable (optional: set 0 if you need IPv6) ─────────────────────────
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# ── Kernel hardening ─────────────────────────────────────────────────────────
kernel.randomize_va_space = 2             # ASLR: full randomization
kernel.dmesg_restrict = 1                # Restrict dmesg to root
kernel.kptr_restrict = 2                 # Hide kernel pointers
kernel.sysrq = 0                         # Disable SysRq
kernel.core_uses_pid = 1
kernel.perf_event_paranoid = 3
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
EOF

sysctl --system
info "Kernel parameters applied."

# =============================================================================
section "6. AUDIT LOGGING (auditd)"
# =============================================================================
apt-get install -y auditd audispd-plugins

info "Configuring audit rules..."
cat > /etc/audit/rules.d/99-ecommerce-devsecops.rules <<'EOF'
# Delete all existing rules
-D

# Buffer size
-b 8192

# Failure mode: 1=log, 2=panic
-f 1

# ── Authentication events ─────────────────────────────────────────────────────
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers

# ── SSH events ────────────────────────────────────────────────────────────────
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /var/log/auth.log -p wa -k auth_log

# ── Docker and container events ───────────────────────────────────────────────
-w /usr/bin/docker -p xa -k docker
-w /var/lib/docker -p wa -k docker_data
-w /etc/docker -p wa -k docker_config
-w /usr/bin/kubectl -p xa -k kubectl
-w /usr/local/bin/minikube -p xa -k minikube

# ── Jenkins events ────────────────────────────────────────────────────────────
-w /var/lib/jenkins -p wa -k jenkins
-w /etc/default/jenkins -p wa -k jenkins_config

# ── Network configuration ──────────────────────────────────────────────────────
-w /etc/hosts -p wa -k network
-w /etc/resolv.conf -p wa -k network
-w /etc/iptables -p wa -k firewall

# ── System call rules ─────────────────────────────────────────────────────────
# Privilege escalation attempts
-a always,exit -F arch=b64 -S setuid -S setgid -k priv_esc
-a always,exit -F arch=b64 -S ptrace -k ptrace
-a always,exit -F arch=b64 -S mount -k mount
-a always,exit -F arch=b64 -S unshare -k unshare

# Module loading/unloading
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules

# Crontab modifications
-w /etc/cron.d/ -p wa -k cron
-w /etc/crontab -p wa -k cron
-w /var/spool/cron/ -p wa -k cron
EOF

service auditd restart
systemctl enable auditd
info "auditd configured and enabled."

# =============================================================================
section "7. FAIL2BAN (Brute Force Protection)"
# =============================================================================
apt-get install -y fail2ban

cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 3
backend  = systemd

[sshd]
enabled = true
port    = 2222
logpath = /var/log/auth.log

[jenkins]
enabled  = true
port     = 8080
filter   = jenkins
logpath  = /var/log/jenkins/jenkins.log
maxretry = 5
bantime  = 600
EOF

systemctl enable fail2ban
systemctl restart fail2ban
info "fail2ban configured."

# =============================================================================
section "8. REMOVE UNNECESSARY SERVICES"
# =============================================================================
SERVICES_TO_DISABLE=(
  "avahi-daemon"
  "bluetooth"
  "cups"
  "rpcbind"
  "nfs-server"
  "telnet"
  "vsftpd"
)

for svc in "${SERVICES_TO_DISABLE[@]}"; do
  if systemctl list-unit-files | grep -q "$svc"; then
    systemctl stop "$svc" 2>/dev/null || true
    systemctl disable "$svc" 2>/dev/null || true
    info "Disabled: $svc"
  fi
done

# =============================================================================
section "9. FILE PERMISSIONS HARDENING"
# =============================================================================
info "Hardening sensitive file permissions..."
chmod 644 /etc/passwd
chmod 640 /etc/shadow
chmod 644 /etc/group
chmod 640 /etc/gshadow
chmod 440 /etc/sudoers

# Remove world-writable files from /tmp
chmod 1777 /tmp
chmod 1777 /var/tmp

info "Restricting compiler access..."
for bin in gcc cc g++ as ld; do
  if which "$bin" &>/dev/null; then
    chmod o-x "$(which $bin)" 2>/dev/null || true
  fi
done

# =============================================================================
section "10. INSTALL SECURITY TOOLS"
# =============================================================================
info "Installing security tools..."
apt-get install -y \
  rkhunter \
  chkrootkit \
  lynis \
  aide \
  clamav \
  net-tools \
  htop \
  iotop \
  lsof \
  strace

# Initialize AIDE database
aideinit -y -f 2>/dev/null || true
info "AIDE database initialized (takes a few minutes)."

# Update ClamAV definitions
freshclam 2>/dev/null || true

# =============================================================================
section "11. DOCKER SECURITY HARDENING"
# =============================================================================
info "Configuring Docker daemon security settings..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "no-new-privileges": true,
  "icc": false,
  "userns-remap": "default",
  "storage-driver": "overlay2",
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  },
  "seccomp-profile": "/etc/docker/seccomp-default.json"
}
EOF

systemctl restart docker
info "Docker daemon hardened."

# =============================================================================
section "12. LOGROTATE FOR PIPELINE LOGS"
# =============================================================================
cat > /etc/logrotate.d/devsecops-pipeline <<'EOF'
/var/log/jenkins/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    sharedscripts
}

/var/log/audit/audit.log {
    weekly
    missingok
    rotate 13
    compress
    delaycompress
    notifempty
}
EOF

# =============================================================================
section "HARDENING COMPLETE"
# =============================================================================
echo ""
info "Linux hardening complete. Log saved to: $LOGFILE"
warn "IMPORTANT: Before logging out, ensure:"
warn "  1. Your SSH public key is in ~/.ssh/authorized_keys"
warn "  2. UFW is allowing port 2222 (new SSH port)"
warn "  3. SSH PasswordAuthentication is now disabled"
warn "  4. Test SSH: ssh -p 2222 user@host"
echo ""
info "Run a security audit: sudo lynis audit system"