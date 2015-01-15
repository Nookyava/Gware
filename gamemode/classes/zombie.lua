------------
-- ZOMBIE --
------------

local zombie = {}
zombie.DisplayName = "Zombie"
player_manager.RegisterClass("Zombie", zombie, "player_default")

function zombie:Loadout()
	self.Player:SetMaxHealth(400)
	self.Player:SetHealth(400)
	self.Player:SetRunSpeed(225)
	self.Player:SetWalkSpeed(225)
	self.Player:SetJumpPower(200)

	self.Player:Give("weapon_gw_zombie")
end