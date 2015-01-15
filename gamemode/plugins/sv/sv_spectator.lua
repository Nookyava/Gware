function GM:SetSpectator(ply)
	ply:SetTeam(3)
	ply:KillSilent()
	ply:Spectate( OBS_MODE_ROAMING )
end

function GM:CheckSpectator(ply)
	if ply:Team() == 3 || ply:Team() == 0 then
		self:SetSpectator(ply)
	else
		ply:UnSpectate()
	end
end

function GM:SpectateChange(ply)
	if !ply:Alive() or ply:Team() == 3 then
		local target = util.GetNextAlivePlayer(ply:GetObserverTarget())
		
		if IsValid(target) then
			ply:Spectate(ply.spec_mode or OBS_MODE_CHASE)
			ply:SpectateEntity(target)
        end
	end
end

function GM:SpectateRoam(ply)
	if !ply:Alive() or ply:Team() == 3 then
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SpectateEntity(nil)
		
		local alive = util.GetAlivePlayers()
		
		if #alive < 1 then return end
		
		local target = table.Random(alive)
		if IsValid(target) then
			ply:SetPos(target:EyePos())
		end
	end
end