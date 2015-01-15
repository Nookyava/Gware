include("shared.lua")

-- Auto-includes each new Lua file --

local folder, files, dir
folder = GM.FolderName.."/gamemode/plugins"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/rages"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/plugins/cl"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/bosses"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/classes"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
end

folder = GM.FolderName.."/gamemode/vgui"
files = file.Find(folder.."/*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder.."/"..file)
end