#!/usr/bin/env python3
import os
import subprocess
import json
import sys
import time
from gi.repository import Gio

# --- Configuration ---
HOME_DIR = os.path.expanduser("~")
CACHE_FILE = os.path.expanduser("~/.cache/spotlight_cache.json")
CACHE_TTL = 86400  # 24 hours
MAX_DEPTH = 10     # Deep scan
EXCLUDE_DIRS = {".git", ".cache", "node_modules", ".npm", ".venv", "__pycache__", "target", "build", "dist", ".rustup", ".cargo"}
ROFI_CONF = os.path.expanduser("~/.config/rofi/config.rasi")

def get_apps():
    apps = []
    for app in Gio.AppInfo.get_all():
        if app.should_show():
            name = app.get_name()
            icon = app.get_icon()
            icon_name = "application-x-executable"
            if icon:
                icon_name = icon.to_string()
            
            exec_cmd = app.get_executable()
            if exec_cmd:
                apps.append({
                    "type": "app",
                    "label": f"{name} (App)",
                    "icon": icon_name,
                    "exec": exec_cmd
                })
    return apps

def get_windows():
    windows = []
    try:
        result = subprocess.run(["hyprctl", "clients", "-j"], capture_output=True, text=True)
        if result.returncode == 0:
            data = json.loads(result.stdout)
            for win in data:
                title = win.get("title") or win.get("class")
                address = win.get("address")
                cls = win.get("class", "").lower()
                windows.append({
                    "type": "window",
                    "label": f"{title} (Window)",
                    "icon": cls if cls else "window-new",
                    "address": address
                })
    except Exception:
        pass
    return windows

def scan_files():
    files = []
    for root, dirs, filenames in os.walk(HOME_DIR):
        # Filter directories to avoid noise
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS and not d.startswith('.')]
        
        # Check depth
        depth = root[len(HOME_DIR):].count(os.sep)
        if depth >= MAX_DEPTH:
            dirs[:] = []
            continue

        for filename in filenames:
            if not filename.startswith('.'):
                full_path = os.path.join(root, filename)
                files.append({
                    "type": "file",
                    "label": f"{filename} (File)",
                    "icon": "document-open",
                    "path": full_path
                })
    return files

def load_cache():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, 'r') as f:
                data = json.load(f)
                if time.time() - data.get("timestamp", 0) < CACHE_TTL:
                    return data.get("files", [])
        except Exception:
            pass
    return None

def save_cache(files):
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, 'w') as f:
        json.dump({"timestamp": time.time(), "files": files}, f)

def main():
    if "--refresh" in sys.argv:
        print("Refreshing cache...")
        files = scan_files()
        save_cache(files)
        print(f"Cache updated with {len(files)} files.")
        sys.exit(0)

    if len(sys.argv) > 1:
        # Handle selection
        selection_label = sys.argv[1]
        files = load_cache() or scan_files()
        all_items = get_apps() + get_windows() + files
        
        for item in all_items:
            if item["label"] == selection_label:
                if item["type"] == "app":
                    subprocess.Popen(item["exec"].split(), start_new_session=True)
                elif item["type"] == "window":
                    subprocess.run(["hyprctl", "dispatch", "focuswindow", f"address:{item['address']}"])
                elif item["type"] == "file":
                    subprocess.Popen(["xdg-open", item["path"]], start_new_session=True)
                sys.exit(0)
        sys.exit(1)

    # --- Main ---
    cached_files = load_cache()
    if cached_files is None:
        cached_files = scan_files()
        save_cache(cached_files)

    apps = get_apps()
    windows = get_windows()
    all_items = apps + windows + cached_files
    
    rofi_input = ""
    for item in all_items:
        icon = item.get("icon", "system-search")
        if "/" in icon:
            icon = icon.split("/")[-1].split(".")[0]
        rofi_input += f"{item['label']}\0icon\x1f{icon}\n"

    rofi_process = subprocess.Popen(
        ["rofi", "-dmenu", "-i", "-p", "Spotlight", "-config", ROFI_CONF],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
    )
    stdout, _ = rofi_process.communicate(input=rofi_input)
    
    if stdout:
        selection = stdout.strip()
        subprocess.run([sys.argv[0], selection])

if __name__ == "__main__":
    main()
