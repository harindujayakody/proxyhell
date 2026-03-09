#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

INSTALL_DIR="/opt/proxyhell"
STATE_DIR="/etc/proxyhell"
BIN_PATH="/usr/local/bin/proxyhell"
MANAGER_PATH="${INSTALL_DIR}/proxyhell.sh"

mkdir -p "$INSTALL_DIR" "$STATE_DIR"

apt-get update -y
apt-get install -y software-properties-common curl openssl ufw gawk sed grep coreutils

if ! apt-cache show dante-server >/dev/null 2>&1; then
  add-apt-repository -y universe || true
  apt-get update -y
fi

apt-get install -y dante-server

cat > "$MANAGER_PATH" <<'MANAGER_EOF'
#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/etc/proxyhell"
DB_FILE="${STATE_DIR}/proxies.db"
CONF_FILE="/etc/danted.conf"
PROJECT_NAME="ProxyHell"
PROJECT_REPO="https://github.com/harindujayakody/proxyhell"
PROJECT_AUTHOR="Harindu Jayakody"

mkdir -p "$STATE_DIR"
touch "$DB_FILE"

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
DIM="\033[2m"
BOLD="\033[1m"
RESET="\033[0m"

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo -e "${RED}Please run with sudo: sudo proxyhell${RESET}"
    exit 1
  fi
}

line() {
  printf '%*s\n' "${COLUMNS:-70}" '' | tr ' ' '─'
}

title() {
  clear
  echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}${BOLD}║                        PROXYHELL                            ║${RESET}"
  echo -e "${CYAN}${BOLD}║               SOCKS5 ONE-CLICK INSTALLER                    ║${RESET}"
  echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
  echo
  echo -e "${DIM}GitHub: ${PROJECT_REPO}${RESET}"
  echo -e "${DIM}Created by: ${PROJECT_AUTHOR}${RESET}"
  echo
}

info()    { echo -e "${BLUE}[INFO]${RESET} $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
fail()    { echo -e "${RED}[ERR]${RESET}  $*"; }

pause() {
  echo
  read -rp "Press Enter to continue..." _
}

get_ext_if() {
  ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -n1
}

get_public_ip() {
  local ip ext_if
  ip="$(curl -4 -s https://ifconfig.me || true)"
  if [[ -n "$ip" ]]; then
    echo "$ip"
    return
  fi
  ext_if="$(get_ext_if)"
  ip="$(ip -4 addr show "$ext_if" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)"
  echo "$ip"
}

random_user() {
  echo "u_$(tr -dc 'a-z0-9' </dev/urandom | head -c 8)"
}

random_pass() {
  openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 14
}

port_in_db() {
  local port="$1"
  awk -F: -v p="$port" '$2 == p { found=1 } END { exit(found ? 0 : 1) }' "$DB_FILE"
}

user_in_db() {
  local user="$1"
  awk -F: -v u="$user" '$3 == u { found=1 } END { exit(found ? 0 : 1) }' "$DB_FILE"
}

pick_random_port() {
  local p
  while true; do
    p="$(shuf -i 20000-40000 -n 1)"
    if ! port_in_db "$p"; then
      echo "$p"
      return
    fi
  done
}

pick_unique_user() {
  local u
  while true; do
    u="$(random_user)"
    if ! id "$u" >/dev/null 2>&1 && ! user_in_db "$u"; then
      echo "$u"
      return
    fi
  done
}

create_system_user() {
  local user="$1" pass="$2"
  useradd --system --no-create-home --shell /usr/sbin/nologin "$user"
  echo "${user}:${pass}" | chpasswd
}

append_proxy() {
  local ip="$1" port="$2" user="$3" pass="$4"
  echo "${ip}:${port}:${user}:${pass}" >> "$DB_FILE"
}

count_proxies() {
  grep -c . "$DB_FILE" 2>/dev/null || true
}

rebuild_dante() {
  local ext_if
  ext_if="$(get_ext_if)"

  if [[ -z "$ext_if" ]]; then
    fail "Could not detect external network interface."
    exit 1
  fi

  cp "$CONF_FILE" "${CONF_FILE}.bak.$(date +%s)" 2>/dev/null || true

  {
    echo "logoutput: syslog"
    echo
    awk -F: 'NF>=4 {print "internal: 0.0.0.0 port = " $2}' "$DB_FILE"
    echo "external: ${ext_if}"
    echo
    echo "socksmethod: username"
    echo "user.privileged: root"
    echo "user.unprivileged: nobody"
    echo "user.libwrap: nobody"
    echo
    echo "client pass {"
    echo "  from: 0.0.0.0/0 to: 0.0.0.0/0"
    echo "  log: error connect disconnect"
    echo "}"
    echo
    echo "client block {"
    echo "  from: 0.0.0.0/0 to: 0.0.0.0/0"
    echo "  log: connect error"
    echo "}"
    echo
    echo "socks pass {"
    echo "  from: 0.0.0.0/0 to: 0.0.0.0/0"
    echo "  command: connect bind udpassociate"
    echo "  socksmethod: username"
    echo "  log: error connect disconnect"
    echo "}"
    echo
    echo "socks block {"
    echo "  from: 0.0.0.0/0 to: 0.0.0.0/0"
    echo "  log: connect error"
    echo "}"
  } > "$CONF_FILE"

  systemctl enable danted >/dev/null 2>&1 || true
  systemctl restart danted
}

open_ports() {
  local p
  for p in "$@"; do
    ufw allow "${p}/tcp" >/dev/null 2>&1 || true
  done
}

show_proxy_result() {
  local ip="$1" port="$2" user="$3" pass="$4"
  echo -e "${GREEN}${BOLD}${ip}:${port}:${user}:${pass}${RESET}"
}

show_summary() {
  local total pub_ip
  total="$(count_proxies)"
  pub_ip="$(get_public_ip)"

  echo
  line
  echo -e "${BOLD}Project     :${RESET} ${PROJECT_NAME}"
  echo -e "${BOLD}Public IPv4 :${RESET} ${pub_ip:-N/A}"
  echo -e "${BOLD}Total Proxies:${RESET} ${total}"
  echo -e "${BOLD}Database    :${RESET} ${DB_FILE}"
  echo -e "${BOLD}Command     :${RESET} sudo proxyhell"
  echo -e "${BOLD}GitHub      :${RESET} ${PROJECT_REPO}"
  line
  echo
}

create_one_random() {
  local ip port user pass

  ip="$(get_public_ip)"
  [[ -z "$ip" ]] && { fail "No public IPv4 detected."; return; }

  port="$(pick_random_port)"
  user="$(pick_unique_user)"
  pass="$(random_pass)"

  create_system_user "$user" "$pass"
  append_proxy "$ip" "$port" "$user" "$pass"
  rebuild_dante
  open_ports "$port"

  ok "Random single proxy created"
  echo
  show_proxy_result "$ip" "$port" "$user" "$pass"
}

create_custom_batch() {
  local count start_port end_port ip
  read -rp "Enter start port: " start_port
  read -rp "How many proxies: " count

  if ! [[ "$start_port" =~ ^[0-9]+$ ]] || (( start_port < 1024 || start_port > 65000 )); then
    fail "Start port must be between 1024 and 65000."
    return
  fi

  if ! [[ "$count" =~ ^[0-9]+$ ]] || (( count < 1 || count > 500 )); then
    fail "Count must be between 1 and 500."
    return
  fi

  end_port=$((start_port + count - 1))
  if (( end_port > 65535 )); then
    fail "Port range exceeds 65535."
    return
  fi

  ip="$(get_public_ip)"
  [[ -z "$ip" ]] && { fail "No public IPv4 detected."; return; }

  local i port user pass
  local ports=()

  for ((i=0; i<count; i++)); do
    port=$((start_port + i))
    if port_in_db "$port"; then
      fail "Port already exists: $port"
      return
    fi
  done

  ok "Creating ${count} proxies..."
  echo

  for ((i=0; i<count; i++)); do
    port=$((start_port + i))
    user="$(pick_unique_user)"
    pass="$(random_pass)"
    create_system_user "$user" "$pass"
    append_proxy "$ip" "$port" "$user" "$pass"
    ports+=("$port")
    show_proxy_result "$ip" "$port" "$user" "$pass"
  done

  rebuild_dante
  open_ports "${ports[@]}"
  echo
  ok "Created ${count} proxies on ports ${start_port}-${end_port}"
}

create_random_five() {
  local ip user pass port
  local ports=()
  local i

  ip="$(get_public_ip)"
  [[ -z "$ip" ]] && { fail "No public IPv4 detected."; return; }

  ok "Creating 5 random proxies..."
  echo

  for ((i=1; i<=5; i++)); do
    port="$(pick_random_port)"
    user="$(pick_unique_user)"
    pass="$(random_pass)"
    create_system_user "$user" "$pass"
    append_proxy "$ip" "$port" "$user" "$pass"
    ports+=("$port")
    show_proxy_result "$ip" "$port" "$user" "$pass"
  done

  rebuild_dante
  open_ports "${ports[@]}"
  echo
  ok "Created 5 random proxies"
}

list_proxies() {
  local total
  total="$(count_proxies)"

  echo
  echo -e "${MAGENTA}${BOLD}Saved Proxies${RESET}"
  line

  if [[ "$total" -eq 0 ]]; then
    warn "No proxies created yet."
    return
  fi

  cat "$DB_FILE"
  echo
  ok "Total proxies: ${total}"
}

show_recommended_ports() {
  echo
  echo -e "${CYAN}${BOLD}Recommended ports:${RESET} 1080, 1090, 20000-40000"
  echo -e "${CYAN}${BOLD}Avoid ports:${RESET} 1-1023, 22, 25, 53, 80, 443, 3306, 5432"
  echo
}

show_credits() {
  echo
  line
  echo -e "${BOLD}Project :${RESET} ${PROJECT_NAME}"
  echo -e "${BOLD}Author  :${RESET} ${PROJECT_AUTHOR}"
  echo -e "${BOLD}GitHub  :${RESET} ${PROJECT_REPO}"
  line
  echo
}

menu() {
  title
  show_summary
  echo -e "${BOLD}1)${RESET} Random Single Proxy Generate ${DIM}(recommended random port)${RESET}"
  echo -e "${BOLD}2)${RESET} Choose Port and Quantity"
  echo -e "${BOLD}3)${RESET} Random 5 Proxies"
  echo -e "${BOLD}4)${RESET} List / Show Created Proxies"
  echo -e "${BOLD}5)${RESET} Recommended Ports"
  echo -e "${BOLD}6)${RESET} Credits"
  echo -e "${BOLD}7)${RESET} Exit"
  echo
}

main() {
  require_root
  while true; do
    menu
    read -rp "Select option [1-7]: " choice
    case "$choice" in
      1) create_one_random; pause ;;
      2) create_custom_batch; pause ;;
      3) create_random_five; pause ;;
      4) list_proxies; pause ;;
      5) show_recommended_ports; pause ;;
      6) show_credits; pause ;;
      7) exit 0 ;;
      *) fail "Invalid option"; sleep 1 ;;
    esac
  done
}

main
MANAGER_EOF

chmod +x "$MANAGER_PATH"
ln -sf "$MANAGER_PATH" "$BIN_PATH"

echo
echo "Installed successfully."
echo "Project : ProxyHell"
echo "Command : sudo proxyhell"
echo "GitHub  : https://github.com/harindujayakody/proxyhell"
echo
