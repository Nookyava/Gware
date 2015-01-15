--[[
	GWARE PLAYER SYSTEM
	LAST UPDATED: 04/09/14
	BY: NOOKYAVA
--]]

-- On player's first spawn we set some variables and run some functions. --
function GM:PlayerInitialSpawn(ply)
	net.Start("gware_pickteam") -- Set them to pick a team
	net.Send(ply)
	
	ply:SetCredits(ply:GetPData("gw_credits", 0)) -- Their credits to become boss (if none then 0)
	ply.PrePickedBoss = nil -- No pre-picked bosses yet
	player_manager.SetPlayerClass(ply, "Soldier") -- Set to soldier so they spawn with some weapon
	
	self:NetworkRound(ply) -- And lets them know our round info
end

-- Each spawn --
function GM:PlayerSpawn(ply)
	self:CheckSpectator(ply) -- See if they're a spectator, if so then it'll run some stuff to stop them from spawning
	self:SetModel(ply) 
	self:PlayerLoadout(ply) -- Give them their class weapons
	self:CheckHands(ply) -- Make sure they see their hands
	
	ply:SetDamage(0) -- We set their damage to 0 at the beginning of the round
	ply:SetRage(0) -- Set any rage to 0 (just in the off chance they got some
	
	ply:SetCanZoom(false) -- Disable Suit Zoom (so they can press it and rage
end

-- Stops players from spawning at a click --
function GM:PlayerDeathThink(ply)
	return false
end

-- Each death will be checked if they're the boss, and to alert players that it is --
function GM:PlayerDeath(victim, weapon, killer)
	if victim:IsBoss() and self:GetRound() == ROUND_ACTIVE then
		net.Start("gw_alertbossdeath")
		
		if (victim == killer) then
			net.WriteString("has killed themself!")
		else
			net.WriteString("has been killed by " .. killer:GetName())
		end
		
		net.Broadcast()
	end
end

-- On a player leave it'll save their credits --
function GM:PlayerDisconnected(ply)
	ply:SetPData("gw_credits", ply.Credits)
end

-- Small stuff to prevent stuff such as noclipping --
function GM:PlayerNoClip(ply, bool)
	return false
end

-- This will be removed when pointshop is added --
function GM:SetModel(ply)
	if ply:Team() != TEAM_BOSS then
		ply:SetModel("models/player/police.mdl")
	end
end

-- Wiki function to give them hands --
function GM:CheckHands(ply)
	local oldhands = ply:GetHands()
	if ( IsValid( oldhands ) ) then oldhands:Remove() end

	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
		ply:SetHands( hands )
		hands:SetOwner( ply )

		-- Which hands should we use?
		local cl_playermodel = ply:GetInfo( "cl_playermodel" )
		local info = player_manager.TranslatePlayerHands( cl_playermodel )
		if ( info ) then
			hands:SetModel( info.model )
			hands:SetSkin( info.skin )
			hands:SetBodyGroups( info.body )
		end

		-- Attach them to the viewmodel
		local vm = ply:GetViewModel( 0 )
		hands:AttachToViewmodel( vm )

		vm:DeleteOnRemove( hands )
		ply:DeleteOnRemove( hands )

		hands:Spawn()
 	end
end

-- Extremely important to do a few checks on jumping/falling --
function GM:OnPlayerHitGround(ply, water, floater, speed)
	if ply:IsBoss() then -- The Goomba Function
		local goomba = (ply:GetGroundEntity())
		if goomba:IsValid() and goomba:IsPlayer() then
			goomba:Kill()
		end
	elseif ply:Team() == TEAM_PLAYER and ply.HasDoubleJumped then -- The double jump function
		ply.HasDoubleJumped = false
		ply.CanDoubleJump = true
	end
end

-- Stop friendly fire --
function GM:PlayerShouldTakeDamage(ply, attacker)
	if attacker:IsPlayer() and attacker:Team() == ply:Team() or self:GetRound() != ROUND_ACTIVE then 
		return false 
	end
	
	return true
end

-- Set the attackers damage amount (for credits) and bosses rage --
function GM:PlayerHurt(victim, attacker, health, dmg)
	if victim:IsBoss() then
		attacker:SetDamage(attacker:GetDamage() + dmg)
		GAMEMODE:SetCredits(attacker)
		
		victim:SetRage(victim:GetRage() + (dmg * 0.2))
	end
end

-- Most of the key press functions goes here, a tad messy --
function GM:KeyPress(ply, key)
	if (key == IN_ZOOM and ply:IsBoss()) then
		self:Rage(ply)
	elseif (key == IN_DUCK and ply:IsBoss()) then
		self:SuperJumpPrepare(ply)
	elseif (key == IN_ATTACK) then
		self:SpectateChange(ply)
	elseif (key == IN_ATTACK2) then
		self:SpectateRoam(ply)
	elseif (key == IN_JUMP) and ply:IsBoss() and (ply.superjump and ply.superjump < CurTime()) then
		self:SuperJump(ply)
	elseif (key == IN_JUMP) and ply:Team() == TEAM_PLAYER and ply.CanDoubleJump then
		self:DoubleJump(ply)
	end
end

-- Custom function to allow one extra jump if they can --
function GM:DoubleJump(ply)
	if ply.HasDoubleJumped then
		ply:SetVelocity(Vector(0, 0, 375))
		ply.CanDoubleJump = false
	else
		ply.HasDoubleJumped = true
	end
end

-- Stop the super jump if they stop crouching --
function GM:KeyRelease(ply, key)
	if (key == IN_DUCK and ply:IsBoss()) then
		ply.superjump = nil
		ply.issuperjumping = false
		ply:SetWalkSpeed(300)
		
		net.Start("gw_syncsuperjump")
			net.WriteInt(0, 32)
		net.Send(ply)
	end
end

-- Stop all fall damage --
function GM:GetFallDamage(ply, speed)
	return 0
end

-- Sets all credits for the player --
function GM:SetCredits(ply)
	if ply:GetDamage() > 60 and ply:GetDamage() < 600 then
		ply:SetCredits(ply:GetCredits() + 1)
	elseif ply:GetDamage() > 600 and ply:GetDamage() < 1000 then
		ply:SetCredits(ply:GetCredits() + 2)
	elseif ply:GetDamage() >= 1000 then
		ply:SetCredits(ply:GetCredits() + 3)
	end
end

-- All player-specific functions goes here --
local plyMeta = FindMetaTable("Player")

-- If the player is a boss, returns true as a check --
function plyMeta:IsBoss()
	if self.BossID and (GAMEMODE:GetRound() == ROUND_ACTIVE or GAMEMODE:GetRound() == ROUND_POST) then
		return true
	end
	return false
end

-- Sets the individuals credits --
function plyMeta:SetCredits(creditnum)
	if self:IsValid() and self:IsPlayer() then
		self.Credits = creditnum
		
		net.Start("gw_updatecredits")
			net.WriteInt(self.Credits, 32)
		net.Send(self)
	end
end

-- Returns the individuals credits --
function plyMeta:GetCredits()
	if self:IsValid() and self:IsPlayer() then
		return tonumber(self.Credits)
	end
end

-- Sets the bosses rage --
function plyMeta:SetRage(rage)
	if self:IsValid() and self:IsPlayer() then
		if self.Rage then
			if rage > 0 then
				local rageamount = self.Rage + rage
				
				if rageamount > 100 then
					rageamount = self.Rage + (rageamount - 100)
				end
				
				self.Rage = rageamount
			else
				self.Rage = 0
			end
		else
			self.Rage = 0
		end
		
		net.Start("gw_updaterage")
			net.WriteEntity(self)
			net.WriteInt(self.Rage, 32)
		net.Send(self)
	end
end

-- Returns the bosses rage --
function plyMeta:GetRage()
	if self:IsValid() and self:IsPlayer() and self:IsBoss() then
		return self.Rage
	end
end

-- Sets the players damage --
function plyMeta:SetDamage(dmg)
	if self:IsValid() and self:IsPlayer() then
		self.Dmg = dmg
		
		net.Start("gw_updatedamage")
			net.WriteInt(self.Dmg, 32)
		net.Send(self)
	end
end

-- Returns the players damage --
function plyMeta:GetDamage()
	if self:IsValid() and self:IsPlayer() then
		return self.Dmg
	end
end