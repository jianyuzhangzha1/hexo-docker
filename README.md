# 🚀 Hexo Docker Minimalist Deployment (Raspberry Pi + VPS)

This is a Dockerized workflow for a Hexo blog. It follows the principle of **"strict separation of environment and data"**, specifically designed for **generating static files locally on a Raspberry Pi and automatically pushing them to a cloud VPS for pure static hosting**.

## ✨ Architecture Highlights

* **Zero Environment Pollution**: Say goodbye to messing with Node.js versions and dependencies on your host machine. The entire build environment is encapsulated within Docker. The host machine only stores your plain text data.
* **Ultra-lightweight**: The cloud VPS only needs an Nginx container taking up less than 10MB of RAM to serve your static files.
* **Automated Disaster Recovery**: Built-in backup and restore scripts with an anti-nesting design. Data migration takes just one command.
* **Smart Utilities**: Fixes common pain points with intelligent scripts for unused image cleanup and automatic lossless optimization.

---

## 📂 Directory Structure

```text
hexo-docker/
├── blog/                   # Core data directory (all your posts, themes, and configs)
├── docker-compose.yml      # Core runtime environment configuration
├── Dockerfile              # Custom Node image (pre-installed with ImageMagick)
├── setup_alias.sh          # Environment variable auto-configuration script
├── backup.sh               # 1-click backup script (anti-nesting edition)
├── restore.sh              # 1-click cross-machine restore (auto-handles UID/GID)
├── deploy.sh               # [Create manually] Automated rsync push to VPS
├── clean_images.sh         # Smart unused image cleanup script
└── optimize_images.sh      # Image lossless compression & EXIF stripping script

```

#  🛠️ Quick Start Guide

If you just cloned or created this repository, follow these steps to initialize your blog:

    Enter the Workspace
    Bash

    cd hexo-docker

    Configure Global Command Alias
    Run this script to automatically grab the absolute path and set up a global hexo alias.
    Bash

    chmod +x setup_alias.sh
    ./setup_alias.sh
    source ~/.bashrc

