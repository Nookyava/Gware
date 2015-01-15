if SERVER then
	util.AddNetworkString("gw.slender_rage")
	resource.AddFile("materials/gware/bosses/slenderman/slendy")
	resource.AddFile("sound/gware/slenderman/intro.wav")
	resource.AddFile("sound/gware/slenderman/loss.wav")
	resource.AddFile("sound/gware/slenderman/win.wav")
	resource.AddFile("sound/gware/slenderman/rage.wav")
end
	
GM:AddBoss("Slenderman", "models/slenderman/slenderman.mdl", 1000, "gware/slenderman/intro.wav", "gware/slenderman/loss.wav", "gware/slenderman/win.wav", "gware/slenderman/rage.wav", "Slenderman causes everyones screens to become filled with his image, and teleports to a random player.", "Half Life 2", function(ply)
	local victimtable = {}
	
	for _, victims in ipairs(team.GetPlayers(TEAM_PLAYER)) do
		if !victims:Alive() then continue end
		
		table.insert(victimtable, victims)
		
		net.Start("gw.slender_rage")
			net.WriteInt(1, 32)
		net.Send(victims)
	end
	
	local slend_victim = table.Random(victimtable)
	
	ply:SetPos(slend_victim:GetPos() + Vector(50, 0, 0))
	ply:SetEyeAngles((slend_victim:GetShootPos() - ply:GetShootPos()):Angle())
	
	timer.Create("slender_rage", 5, 1, function()
		for _, victims in ipairs(player.GetAll()) do
			net.Start("gw.slender_rage")
				net.WriteInt(0, 32)
			net.Send(victims)
		end
	end)
	
	ply:SetRage(0)
end)

if SERVER then return end

net.Receive("gw.slender_rage", function(len, CLIENT)
	local ply = LocalPlayer()
	ply.IsHaunted = net.ReadInt(32)
end)

local screen = Material("gware/bosses/slenderman/slendy")
hook.Add("HUDPaint", "gw.slenderman", function()
	local ply = LocalPlayer()
	
	if ply.IsHaunted == 1 then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(screen)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end
	
	-- SLENDY PASSIVE --
	--surface.SetDrawColor(0, 0, 0, 155)
	--surface.DrawRect(0, 0, ScrW(), ScrH())
end)

--[[
	GM:AddBoss("BossName", "BossModel", 1000, "BossRoundStartSound", "BossDeathSound", function(ply)
		Bosses rage function goes here
	end)

]]--