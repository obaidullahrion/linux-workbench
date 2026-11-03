# BlackSwan GRUB Theme

`BlackSwan.zip` is a complete GRUB 2 boot-menu theme.

## Install (summary)

```bash
sudo cp /etc/default/grub /etc/default/grub.backup
sudo mkdir -p /boot/grub/themes
sudo unzip BlackSwan.zip -d /tmp/blackswan
sudo cp -r /tmp/blackswan/BlackSwan /boot/grub/themes/BlackSwan

# Add this line to /etc/default/grub:
# GRUB_THEME="/boot/grub/themes/BlackSwan/theme.txt"

sudo update-grub
sudo reboot
```

Full instructions, customisation and recovery steps:

**→ [`docs/grub-theme.md`](../docs/grub-theme.md)**
