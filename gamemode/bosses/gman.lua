GM:AddBoss("G-Man", "models/player/gman_high.mdl", 1000, "vo/gman_misc/gman_riseshine.wav", "vo/Citadel/gman_exit01.wav", "vo/gman_misc/gman_04.wav", "vo/Citadel/gman_exit08.wav", "G-Man convinces another player to fight for him, allowing them to kill their team.", "Half Life 2", function(ply)
	local targets = {}
				
	for _, ply in ipairs(team.GetPlayers(1)) do
		if ply:Alive() then 
			table.insert(targets, ply)
		end
	end
	
	if ply.HasServant then
		net.Start("gw_hasservant")
		net.Send(ply)
		return
	end
	
	if (#targets) < 3 then
		net.Start("gw_cantservant")
		net.Send(ply)
		return
	end
	
	local chosen = table.Random(targets)
	
	chosen:Servant()
	
	ply.HasServant = true
	
	net.Start("gw_bossservantalert")
		net.WriteString(chosen:Name())
	net.Send(ply)
	
	ply:SetRage(0)
end)

--[[
	GM:AddBoss("BossName", "BossModel", 1000, "BossRoundStartSound", "BossDeathSound", function(ply)
		Bosses rage function goes here
	end)

]]--