--[[
	GWARE Ammo SYSTEM
	LAST UPDATED: 04/09/14
	BY: NOOKYAVA
--]]

function GM:CreateAmmoSpawns( pos, ang ) -- A create function we can call on. Just sets our variables and stuff
	local spawn = ents.Create( "gw_ammo" )
	spawn:SetPos( pos )
	spawn:SetAngles( ang )
	spawn:Spawn()
	spawn:Activate()
end

function GM:LoadSpawns() -- Loads up the spawns so we can spawn them
	if ( file.Exists( "gw_ammo/"..string.lower( game.GetMap() ) .. ".txt", "DATA" ) ) then -- Just seeing if it exists
		local Spawns = util.JSONToTable( file.Read( "gw_ammo/"..string.lower( game.GetMap() ) .. ".txt" ) ) -- Now we read our nicely formatted file
		for _, ammo in ipairs(ents.FindByClass("gw_ammo")) do
			ammo:Remove()
		end
		
		for id, tab in pairs( Spawns ) do -- For each id we will run the create spawn function.
			GAMEMODE:CreateAmmoSpawns( tab.pos, tab.ang ) -- As well as read each variable.
		end
	else
		MsgN("Item Spawn file is missing for map " .. string.lower( game.GetMap() ) )
	end
end

hook.Add("Initialize", "gw.createammo", function()
	if !file.Exists("gw_ammo", "DATA") then
			
		file.CreateDir("gw_ammo")
			
		if file.Exists("gw_ammo", "DATA") then
			file.Write("gw_ammo/gw_ammo_spawns.txt")
		end
	end
	
	GAMEMODE:LoadSpawns()
	
	timer.Create("gw_respawnammo", 30, 0, GAMEMODE.LoadSpawns)
end)

concommand.Add( 'gw_saveammo', function(ply)
	if !ply:IsSuperAdmin() then return end
	if file.Read("gw_ammo/gw_ammo_spawns.txt") then -- Basically we're seeing if the file has any data. If so...
		local tableofSpawns = {}
		for _, ent in pairs( ents.FindByClass("gw_ammo") ) do -- Then for every item
			table.insert( tableofSpawns, { ang = ent:GetAngles(), pos = ent:GetPos()} ) -- Insert into the table the data we want to port.
		end
		
		file.Write( "gw_ammo/"..string.lower( game.GetMap() ) .. ".txt", util.TableToJSON( tableofSpawns ) ) -- Then insert it into the file in a nice Json format for reading.
	end
end)

concommand.Add( 'gw_reloadammo', function(ply)
	GAMEMODE:LoadSpawns()
end)

concommand.Add("gw_spawnammo", function(ply)
	if !ply:IsSuperAdmin() then return end
	local tr = util.TraceLine( { -- Then we get where they are aiming.
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
		filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
	} )
			
	local itemspawn = ents.Create("gw_ammo") -- Thus we spawn the item
	itemspawn:SetPos(tr.HitPos + Vector(0,0,0)) -- Moved up to stop clipping in ground
	itemspawn:Spawn()
end)