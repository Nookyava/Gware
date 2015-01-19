AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Auto-includes each new Lua file --

local folder, files, dir
folder = GM.FolderName.."/gamemode/core/sv"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/bosses"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
	AddCSLuaFile(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/classes"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
	AddCSLuaFile(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/core"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
	AddCSLuaFile(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/rages"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
	AddCSLuaFile(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/core/cl"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	AddCSLuaFile(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/vgui"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	AddCSLuaFile(folder.."/"..file)
end

concommand.Add("gw_setrage", function(ply)
	ply:SetRage(100)
end)