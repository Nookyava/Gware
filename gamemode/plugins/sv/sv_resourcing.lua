util.AddNetworkString("gware_pickteam")
util.AddNetworkString("gw_pickteam")
util.AddNetworkString("gw_networkroundinfo")
util.AddNetworkString("gw_bosschoice")
util.AddNetworkString("gw_syncsuperjump")
util.AddNetworkString("gw_alertkill")
util.AddNetworkString("gw_bossservantalert")
util.AddNetworkString("gw_cantservant")
util.AddNetworkString("gw_hasservant")
util.AddNetworkString("gw_playerchoice")
util.AddNetworkString("gw_alertbossdeath") -- When the boss dies, play their death sound (SERVER TO CLIENT)
util.AddNetworkString("gware_roundover") -- When the round ends (SERVER TO CLIENT)
util.AddNetworkString("gw_chooseboss") -- When the player is chosen, pick a boss (SERVER TO CLIENT)
util.AddNetworkString("gw_playerchoseboss") -- When the player chooses a boss (CLIENT TO SERVER)
util.AddNetworkString("gw_updaterage") -- Updates the rage for the boss (SERVER TO CLIENT)
util.AddNetworkString("gw_servantalert") -- Alerts the servant that hey, you're a servant (SERVER TO CLIENT)
util.AddNetworkString("gw_updatebosshp") -- Updates the bosses HP (UNUSED UNTIL FUTURE UPDATE) (N/A)
util.AddNetworkString("gw_resetservant") -- To stop showing to the servant that they are, in fact, a servant (SERVER TO CLIENT)
util.AddNetworkString("gw_showcredits") -- To show the player the credit list (SERVER TO CLIENT)
util.AddNetworkString("gware_pickclass") -- To open the menu when the player picks a boss (SERVER TO CLIENT)
util.AddNetworkString("gw_pickclass") -- When the player is picking a class (CLIENT TO SERVER)
util.AddNetworkString("gw_showhelp") -- To open the help menu (SERVER TO CLIENT)
util.AddNetworkString("gw_ragesound") -- When the boss rages (SERVER TO CLIENT)
util.AddNetworkString("gw_prechooseboss") -- When the player chooses a boss via menu (when not boss) (CLIENT TO SERVER)
util.AddNetworkString("gware_grabservant")
util.AddNetworkString("gware_sendservant")
util.AddNetworkString("gw_updatecredits")
util.AddNetworkString("gw_retrievecreditlist")
util.AddNetworkString("gw_sendcreditlist")
util.AddNetworkString("gw_updatedamage")

-- HUD Stuff --
resource.AddFile("materials/gware/icons/boss.png")
resource.AddFile("materials/gware/icons/spectator.png")
resource.AddFile("materials/gware/hud/ammo_icon.png")
resource.AddFile("materials/gware/hud/boss_icon.png")
resource.AddFile("materials/gware/hud/players_icon.png")

-- Main Menu Resource Icons --
resource.AddFile("materials/gware/menu/boss_select.png")
resource.AddFile("materials/gware/menu/loadout_select.png")
resource.AddFile("materials/gware/menu/class_select.png")
resource.AddFile("materials/gware/menu/inventory_select.png")
resource.AddFile("materials/gware/menu/back.png")

-- Class Icons --
resource.AddFile("materials/gware/menu/sniper.png")
resource.AddFile("materials/gware/menu/soldier.png")
resource.AddFile("materials/gware/menu/thief.png")

function GM:Initialize()
	self:RoundInitialize()
end

-- Just so we can hide the servant on scoreboard --
net.Receive("gware_grabservant", function(len)
	net.Start("gware_sendservant")
		for _, servant in ipairs(player.GetAll()) do
			if !servant.servant then continue end
			net.WriteEntity(servant)
		end
	net.Broadcast()
end)

net.Receive("gw_retrievecreditlist", function(len)
	local creditlist = {}
	
	for _, ply in ipairs(player.GetAll()) do
		table.insert(creditlist, {Name = ply:Name(), Credits = ply:GetCredits()})
	end
	
	table.sort(creditlist, function(a, b)
		return a.Credits > b.Credits
	end)
	
	net.Start("gw_sendcreditlist")
		net.WriteTable(creditlist)
	net.Send(net.ReadEntity())
end)

function GM:OnDamagedByExplosion(ply, dmginfo)
	ply:SetDSP(0, false)
end