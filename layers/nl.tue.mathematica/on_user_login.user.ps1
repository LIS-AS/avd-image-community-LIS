# Copy custom init.m to use Mesa as 3D render engine otherwise Mathematica crashes on rotating 3D images
New-Item -ItemType Directory -Path "$env:APPDATA\Wolfram\FrontEnd" -Force
Copy-Item -Path "C:\temp\init.m" -Destination "$env:APPDATA\Wolfram\FrontEnd\init.m" -Force