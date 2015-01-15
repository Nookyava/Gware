GM:AddBoss("Zombie Lord", "models/player/zombie_classic.mdl", 1000, "ambient/creatures/town_zombie_call1.wav", "npc/fast_zombie/fz_scream1.wav", "ambient/levels/prison/inside_battle_zombie2.wav", "npc/zombie/zombie_die3.wav", "Zombie Lord brings back all dead players as zombies to devour the living.", "Half Life 2", function(ply)	
	for _, ply in ipairs(team.GetPlayers(1)) do
		if !ply:Alive() then 
			ply:Zombify()
		end
	end
	
	ply:SetRage(0)
end)