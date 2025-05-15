# 🛠️ HowTo-IT

A collection of clean, practical shell scripts to set up self-hosted services and tools — made for homelabbers, tinkerers, and practical sysadmins.

---

## ✅ Quick Start

This installs a CMD tool called ####toit

```bash
curl -sSL https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main/install-toit.sh -o /tmp/install-toit.sh \
  && bash /tmp/install-toit.sh
source ~/.bashrc
```

To install a package from this repo just run:

```bash
toit xxx-setup.sh
```

To Delete ####toit#### juts run:
```bash
toit removeyourself
```




To install any setup script from this repo, just run:

```bash
bash <(curl -sS https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main/bootstrap.sh) <script-name>
```

For example

```
bash <(curl -sS https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main/bootstrap.sh) xmrig
```

That will: 1. Download xmrig-setup.sh from this repo 2. Set it as executable 3. Run it directly from your system

Ok change if direction:

this installs a CMD tool

```bash
curl -sSL https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main/install-toit.sh -o /tmp/install-toit.sh \
  && bash /tmp/install-toit.sh
source ~/.bashrc
```

so that all you need to do is"

```bash
toit xxx-setup.sh
```

In order to remove the toit command, you can run:

```bash
toit removeyouself
```

Also if you have/had another program that used the cammand toit before you installed this tool, the command will be:

```bash
h2it <command>
```
