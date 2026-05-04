#!/bin/bash -e

# this script must be run as root
if [ "$EUID" -ne 0 ]
  then echo "Please re-run as root (i.e. sudo [this script].sh)."
  exit
fi


# install ollama
curl -fsSL https://ollama.com/install.sh | sh
#sed -i 's/^\[Service\]$/[Service]\nEnvironment="OLLAMA_HOST=0.0.0.0"/g' /etc/systemd/system/ollama.service
systemctl daemon-reload
systemctl restart ollama

# install open webui to run as a service
rm -rf /etc/open-webui
mkdir -p /etc/open-webui/venv
mkdir -p /etc/open-webui/data
uv venv --python 3.11 /etc/open-webui/venv
uv pip install --python /etc/open-webui/venv/bin/python open-webui

echo '
[Unit]
Description=Open WebUI Service
After=network-online.target

[Service]
WorkingDirectory=/etc/open-webui
ExecStart=env WEBUI_AUTH=false DATA_DIR=/etc/open-webui/data /etc/open-webui/venv/bin/open-webui serve --port 8989
Restart=always
RestartSec=3
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

[Install]
WantedBy=default.target
' > /etc/systemd/system/open-webui.service

systemctl daemon-reload
systemctl enable open-webui.service
systemctl restart open-webui.service


# install comfyui to run as a service 
rm -rf /etc/comfyui
mkdir -p /etc/comfyui
git clone https://github.com/Comfy-Org/ComfyUI.git /etc/comfyui/src
uv venv --python 3.12 /etc/comfyui/venv
uv pip install --python /etc/comfyui/venv/bin/python torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130
uv pip install --python /etc/comfyui/venv/bin/python -r /etc/comfyui/src/requirements.txt

echo '
[Unit]
Description=ComfyUI Service
After=network-online.target

[Service]
WorkingDirectory=/etc/comfyui/src
ExecStart=/etc/comfyui/venv/bin/python main.py
Restart=always
RestartSec=3
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

[Install]
WantedBy=default.target
' > /etc/systemd/system/comfyui.service

systemctl daemon-reload
systemctl enable comfyui.service
systemctl restart comfyui.service

echo 'Complete!'
