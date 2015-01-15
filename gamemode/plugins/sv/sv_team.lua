net.Receive("gw_pickteam", function(len, ply)
	local cteam = net.ReadInt(32)
	local ply = net.ReadEntity()
	ply:SetTeam(cteam)
	ply:KillSilent()
	
	net.Start("gware_pickclass")
	net.Send(ply)
end)

function GM:PlayerSelectSpawn(ply)
	if ply:Team() == TEAM_PLAYER then
		local spawns = ents.FindByClass( "info_player_terrorist" )
		local random_entry = math.random( #spawns )
		
		return spawns[ random_entry ]
	elseif ply:Team() == TEAM_BOSS then
		local spawns = ents.FindByClass( "info_player_counterterrorist" )
		local random_entry = math.random( #spawns )
		
		return spawns[ random_entry ]
	end
end

concommand.Add("gw_setbotteam", function()
	for _, bots in ipairs(player.GetAll()) do
		if bots:IsBot() then
			bots:SetTeam(TEAM_PLAYER)
		end
	end
end)