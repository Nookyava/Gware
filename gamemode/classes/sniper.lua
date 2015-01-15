------------
-- SNIPER --
------------

local sniper = {}
sniper.DisplayName = "Sniper"
sniper.ClassColor = Color(61, 145, 64)
sniper.Icon = Material("gware/menu/sniper.png", "smooth")

function sniper:Loadout()
	self.Player:SetMaxHealth(70)
	self.Player:SetHealth(70)
	
	self.Player.CanDoubleJump = false

	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_gw_hook")
	self.Player:Give("weapon_awp")
end

table.insert(GM.Classes, {Name = sniper.DisplayName, Color = sniper.ClassColor, Icon = sniper.Icon})

player_manager.RegisterClass("Sniper", sniper, "player_default")