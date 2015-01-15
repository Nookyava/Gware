--[[
	GWARE BOSS SYSTEM
	LAST UPDATED: 04/09/14
	BY: NOOKYAVA
--]]

function GM:SelectBoss()
	-- Set boss to nothing at the start --
	local boss = NULL
	
	-- Then, looping through each player --
	for k,v in ipairs(team.GetPlayers(TEAM_PLAYER)) do
		-- If they have themselves not selected, ignore them --
		if v.NotBoss then continue end
		if !IsValid(boss) then
			boss = v
		end
		
		-- Then if the player has more than the last player, make them the new selection --
		if v:GetCredits() > boss:GetCredits() then
			boss = v
		end
	end
	
	-- Here we just set their choice random until it is overwritten --
	local numBoss 
	if boss.PrePickedBoss != nil then
		numBoss = boss.PrePickedBoss
	else
		numBoss = math.random(1, #self.Bosses)
	end
	
	boss.BossID = numBoss
	
	boss:SetTeam(2)
	
	self.BossID = numBoss
	
	net.Start("gw_playerchoice")
		net.WriteString(boss:GetName())
	net.Broadcast()
	
	net.Start("gw_chooseboss")
		net.WriteInt(1, 32)
		
		if boss.PrePickedBoss != nil then
			net.WriteInt(1, 32)
		end
	net.Send(boss)
end

net.Receive("gw_playerchoseboss", function(len, ply)
	local ply = net.ReadEntity()
	local numBoss = net.ReadUInt(8)
	ply.BossID = numBoss
	GAMEMODE.BossID = numBoss
end)

function GM:SetBoss(ply)	
	ply:KillSilent()
	ply:Spawn()
	
	local boss = self:GetBossTable(ply.BossID)
	local hp,plys,pInc = boss.Health, team.NumPlayers(1), 0.5
	hp = hp + (hp*(plys-1)*pInc)
	
	ply:SetModel(boss.Model)

	ply:SetHealth(hp)
	ply:SetWalkSpeed(300)
	ply:SetRage(0)
	ply:StripWeapons()
	ply:Give("weapon_gw_bossweapon")
	ply.Cooldown = CurTime() + 5
	
	net.Start("gw_bosschoice")
		net.WriteString(ply:GetName())
		net.WriteString(boss.Name)
		net.WriteString(boss.StartSound)
		net.WriteString(ply:Health())
	net.Broadcast()
	
	ply:SetCredits(0)
	
	if ply.PrePickedBoss != nil then
		ply.PrePickedBoss = nil
	end
end
	
function GM:GetBossTable(idNum)
	return self.Bosses[idNum]
end

function GM:ResetStats(ply)
	ply.BossID = nil
	ply.Rage = nil
	ply.HasServant = nil
	ply:SetRage(0)
end

function GM:SuperJumpPrepare(ply)
	ply.issuperjumping = true
	ply:SetWalkSpeed(250)
	ply.superjump = CurTime() + 3
	net.Start("gw_syncsuperjump")
		net.WriteInt(ply.superjump, 32)
	net.Send(ply)
end

function GM:SuperJump(ply)
	if !ply.issuperjumping then return end
	if ply.superjump > CurTime() then 
		ply.issuperjumping = false 
		ply:SetWalkSpeed(300)
		
		net.Start("gw_syncsuperjump")
			net.WriteInt(0, 32)
		net.Send(ply)
		return 
	end
	
	net.Start("gw_syncsuperjump")
		net.WriteInt(0, 32)
	net.Send(ply)
	
	ply:SetWalkSpeed(300)
	ply:SetVelocity(ply:GetForward() * 200 + Vector(0, 0, 1000))
	ply.issuperjumping = false
end

function GM:Rage(ply)
	print(ply.Cooldown, CurTime());
	if ply:GetRage() >= 100 and (ply.Cooldown <= CurTime())then
		self:GetBossTable(ply.BossID).RageFunc(ply)
		ply.Cooldown = CurTime() + 10
		
		net.Start("gw_ragesound")
			net.WriteString(self:GetBossTable(ply.BossID).RageSound)
		net.Broadcast()
	end
end

function GM:GetBoss()
	local boss
	
	for _, ply in ipairs(team.GetPlayers(2)) do
		if ply:IsBoss() then
			boss = ply
		end
	end
	
	return boss
end

net.Receive("gw_prechooseboss", function(len)
	local ply = net.ReadEntity()
	local boss = net.ReadUInt(8)
	
	ply.PrePickedBoss = boss
end)