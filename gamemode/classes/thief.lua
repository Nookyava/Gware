-----------
-- THIEF --
-----------

local thief = {}
thief.DisplayName = "Thief"
thief.ClassColor = Color(128, 138, 135)
thief.Icon = Material("gware/menu/thief.png", "smooth")

function thief:Loadout()
	self.Player:SetMaxHealth(70)
	self.Player:SetHealth(70)
	self.Player:SetRunSpeed(275)
	self.Player:SetWalkSpeed(275)
	
	self.Player.CanDoubleJump = true
	self.Player.HasDoubleJumped = false

	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_gw_fxbow")
end

table.insert(GM.Classes, {Name = thief.DisplayName, Color = thief.ClassColor, Icon = thief.Icon})

player_manager.RegisterClass("Thief", thief, "player_default")