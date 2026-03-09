# ProxyHell

![GitHub Repo
stars](https://img.shields.io/github/stars/harindujayakody/proxyhell?style=for-the-badge)
![GitHub
forks](https://img.shields.io/github/forks/harindujayakody/proxyhell?style=for-the-badge)
![GitHub
issues](https://img.shields.io/github/issues/harindujayakody/proxyhell?style=for-the-badge)
![GitHub last
commit](https://img.shields.io/github/last-commit/harindujayakody/proxyhell?style=for-the-badge)
![GitHub repo
size](https://img.shields.io/github/repo-size/harindujayakody/proxyhell?style=for-the-badge)
![GitHub
license](https://img.shields.io/github/license/harindujayakody/proxyhell?style=for-the-badge)
![GitHub
language](https://img.shields.io/github/languages/top/harindujayakody/proxyhell?style=for-the-badge)

🔥 **ProxyHell | SOCKS5 One-Click Proxy Installer**

ProxyHell installs and manages SOCKS5 proxies using **Dante Server**
with a clean terminal interface.

GitHub: https://github.com/harindujayakody/proxyhell

------------------------------------------------------------------------

## Installation

Run this command on your server:

``` bash
bash <(curl -s https://raw.githubusercontent.com/harindujayakody/proxyhell/main/install-proxyhell.sh)
```

After installation run:

``` bash
sudo proxyhell
```

------------------------------------------------------------------------

## Features

-   One‑click SOCKS5 installation
-   Random proxy generator
-   Custom port and quantity creation
-   Random 5 proxy generation
-   Automatic username and password generation
-   Clean terminal UI
-   Global command access (`proxyhell`)
-   Firewall port auto‑opening
-   Proxy database management

------------------------------------------------------------------------

## Example Output

    52.1.46.45:20015:u_6shfe337:x8nLcnTUwYxTd0
    52.1.46.45:20016:u_91kd212:Qm3Pz81LxkR0Qw

Format:

    IP:PORT:USERNAME:PASSWORD

------------------------------------------------------------------------

## Usage Example

``` bash
curl --proxy socks5h://USERNAME:PASSWORD@IP:PORT https://ifconfig.me
```

------------------------------------------------------------------------

## Recommended Ports

Good ports:

    1080
    1090
    20000-40000

Avoid:

    1-1023
    22
    25
    53
    80
    443

------------------------------------------------------------------------

## Proxy Database

    /etc/proxyhell/proxies.db

------------------------------------------------------------------------

## Credits

Project: **ProxyHell**\
Author: **Harindu Jayakody**

GitHub: https://github.com/harindujayakody/proxyhell

------------------------------------------------------------------------

## License

MIT License
