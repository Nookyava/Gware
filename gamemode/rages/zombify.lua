------------------
-- Zombify Rage --
------------------

if SERVER then
	util.AddNetworkString("gw_zombiealert")
	
	-- On spawn we are also resetting it, just incase they lived --
	
	hook.Add("PlayerSpawn", "gw.resetzombie", function(ply)
		if GAMEMODE:GetRound() != ROUND_ACTIVE then
			if ply.zombie then
				player_manager.SetPlayerClass(ply, ply.Class)
				ply.zombie = false
				ply:KillSilent()
				ply:Spawn()
			end
		end
		
		if ply.zombie then
			ply:Give("weapon_gw_zombie")
		end
	end)
	
	----------------------
	-- Player Functions --
	----------------------
	
	local plyMeta = FindMetaTable("Player")
	
	-- Turn the Player into the servant --
	
	function plyMeta:Zombify()
		if self:IsValid() and self:IsPlayer() then
			self:SetTeam(2)
			self.zombie = true
		
			net.Start("gw_zombiealert")
			net.Send(self)
			
			self:SetModel(table.Random({"models/player/Charple01.mdl", "models/player/zombie_soldier.mdl", "models/player/corpse1.mdl"}))
			player_manager.SetPlayerClass(self, "Zombie")
			self:Spawn()
		end
	end
	
	function plyMeta:IsZombie()
		return self.servant
	end
else
	-------------------
	-- Notifications --
	-------------------

	net.Receive("gw_zombiealert", function()
		GAMEMODE:Notify("You have become a zombie. Kill them all.", Color(255, 255, 255), 5)
	end)
end