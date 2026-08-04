$base = "C:\tools"

# Zorg dat Edge niet draait
Stop-Process -Name msedge -Force -ErrorAction SilentlyContinue

# Run embedded Node
& "$base\pw\node.exe" "$base\set-cookies.js"