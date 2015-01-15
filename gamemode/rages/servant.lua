------------------
-- Servant Rage --
------------------

if SERVER then
	-- On the death, reset their servant status --
	
	hook.Add("PlayerDeath", "gw.servantdeath", function(ply)
		if ply:IsServant() then
			local boss = GAMEMODE:GetBoss()
			
			boss.HasServant = false
			
			net.Start("gw_resetservant")
				net.WriteString(ply:Name())
				net.WriteEntity(boss)
			net.Broadcast()
		end
	end)
	
	-- On spawn we are also resetting it, just incase they lived --
	
	hook.Add("PlayerSpawn", "gw.resetservant", function(ply)
		ply.servant = false
	end)
	
	----------------------
	-- Player Functions --
	----------------------
	
	local plyMeta = FindMetaTable("Player")
	
	-- Turn the Player into the servant --
	
	function plyMeta:Servant()
		if self:IsValid() and self:IsPlayer() then
			self:SetTeam(2)
			self.servant = true
		
			net.Start("gw_servantalert")
			net.Send(self)
		end
	end
	
	function plyMeta:IsServant()
		return self.servant
	end
else
	-------------------
	-- Notifications --
	-------------------
	
	net.Receive("gw_hasservant", function()
		GAMEMODE:Notify("You cannot gain a servant while you have one already!", Color(255, 255, 255), 5)
	end)

	net.Receive("gw_servantalert", function()
		local ply = LocalPlayer()
		ply.IsAServant = true
		GAMEMODE:Notify("You have become a servant of the boss. Kill the enemy players if you wish to please your master.", Color(255, 255, 255), 5)
	end)
	
	net.Receive("gw_bossservantalert", function()
		local ply = LocalPlayer()
		local servant = net.ReadString()
		ply.Servant = servant
		GAMEMODE:Notify(servant .. " has become your servant.", Color(255, 255, 255), 5)
	end)
		
	net.Receive("gw_cantservant", function(len, CLIENT)
		GAMEMODE:Notify("You can't request a servant when there are at least 3 players left!", Color(255, 255, 255), 5)
	end)
	
	net.Receive("gw_resetservant", function(len, CLIENT)
		GAMEMODE:Notify("The Servant " .. net.ReadString() .. " has died!", Color(255, 255, 255), 5)
		
		local boss = net.ReadEntity()
		
		boss.Servant = nil
	end)
end