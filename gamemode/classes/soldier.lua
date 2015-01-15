-----------
-- SOLDIER --
-----------

local soldier = {}
soldier.DisplayName = "Soldier"
soldier.ClassColor = Color(210, 180, 140)
soldier.Icon = Material("gware/menu/soldier.png", "smooth")

function soldier:Loadout()
	self.Player:SetMaxHealth(140)
	self.Player:SetHealth(140)
	self.Player:SetRunSpeed(250)
	self.Player:SetWalkSpeed(250)
	
	self.Player.CanDoubleJump = false
	
	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_pistol")
	self.Player:Give("weapon_smg1")
end

table.insert(GM.Classes, {Name = soldier.DisplayName, Color = soldier.ClassColor, Icon = soldier.Icon})

player_manager.RegisterClass("Soldier", soldier, "player_default")