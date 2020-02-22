echo off
echo "Start client"
copy client\main.lua main.lua
copy client\conf.lua conf.lua
love . --console
del main.lua
del conf.lua