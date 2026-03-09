````markdown
# ProxyHell

![GitHub Repo stars](https://img.shields.io/github/stars/harindujayakody/proxyhell?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/harindujayakody/proxyhell?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/harindujayakody/proxyhell?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/harindujayakody/proxyhell?style=for-the-badge)
![GitHub repo size](https://img.shields.io/github/repo-size/harindujayakody/proxyhell?style=for-the-badge)
![GitHub license](https://img.shields.io/github/license/harindujayakody/proxyhell?style=for-the-badge)
![GitHub language](https://img.shields.io/github/languages/top/harindujayakody/proxyhell?style=for-the-badge)

🔥 **ProxyHell – SOCKS5 One-Click Proxy Installer**

ProxyHell is a professional SOCKS5 proxy manager for Linux servers.  
It installs and manages SOCKS5 proxies using **Dante Server** with a clean terminal interface.

With ProxyHell you can generate, manage, and list multiple SOCKS5 proxies instantly from a simple command.

---

# GitHub

https://github.com/harindujayakody/proxyhell

---

# Features

• One-click SOCKS5 proxy installation  
• Random proxy generator  
• Custom port + quantity creation  
• Random 5 proxy generation  
• Automatic username/password generation  
• Clean professional terminal UI  
• Global command access (`proxyhell`)  
• Firewall port auto-opening  
• Proxy database management  

---

# Supported Systems

- Ubuntu 20.04+
- Ubuntu 22.04+
- Debian 10+
- Debian 11+
- Debian 12+

---

# Installation

Run this command on your server:

```bash
bash <(curl -s https://raw.githubusercontent.com/harindujayakody/proxyhell/main/install-proxyhell.sh)
````

After installation run:

```bash
sudo proxyhell
```

---

# Menu

```
1) Random Single Proxy Generate
2) Choose Port and Quantity
3) Random 5 Proxies
4) List / Show Created Proxies
5) Recommended Ports
6) Credits
7) Exit
```

---

# Example Output

When proxies are created they appear like this:

```
52.1.46.45:20015:u_6shfe337:x8nLcnTUwYxTd0
52.1.46.45:20016:u_91kd212:Qm3Pz81LxkR0Qw
52.1.46.45:20017:u_h2sk9a1m:Zt7Ls20NqvP4Kd
```

Format:

```
IP:PORT:USERNAME:PASSWORD
```

---

# Usage Example

Test a proxy:

```bash
curl --proxy socks5h://USERNAME:PASSWORD@IP:PORT https://ifconfig.me
```

Example:

```bash
curl --proxy socks5h://u_6shfe337:x8nLcnTUwYxTd0@52.1.46.45:20015 https://ifconfig.me
```

---

# Recommended Ports

Good ports to use:

```
1080
1090
20000-40000
```

Avoid system ports:

```
1-1023
22
25
53
80
443
3306
5432
```

---

# Project Structure

```
proxyhell
│
├── install-proxyhell.sh
├── README.md
├── LICENSE
└── .gitignore
```

---

# Proxy Database

ProxyHell stores created proxies here:

```
/etc/proxyhell/proxies.db
```

Example:

```
52.1.46.45:20015:u_x82jf93k:Px9T2W0mLq5K
52.1.46.45:20016:u_f2a7m11z:Zm1kE7sP2Qy4
```

---

# Global Command

Once installed, start ProxyHell anytime with:

```bash
sudo proxyhell
```

---

# Requirements

* Root or sudo access
* Linux VPS with public IPv4
* Internet access
* Dante Server

---

# Credits

**Project:** ProxyHell
**Author:** Harindu Jayakody

GitHub:
[https://github.com/harindujayakody/proxyhell](https://github.com/harindujayakody/proxyhell)

---

# License

MIT License

Copyright (c) 2026 Harindu Jayakody

---

# Contributing

Pull requests and suggestions are welcome.

If you find bugs or improvements, please open an issue.

---

# Disclaimer

This project is provided for educational and system administration purposes.
Users are responsible for complying with their local laws and hosting provider policies.

```
