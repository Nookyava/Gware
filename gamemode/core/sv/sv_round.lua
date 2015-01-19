--[[
	GWARE ROUND SYSTEM
	LAST UPDATED: 04/09/14
	BY: NOOKYAVA
--]]

function GM:RoundInitialize() -- When the server starts, we setup a waiting period and just set some basic variables
	GAMEMODE:SetRound(ROUND_WAIT, 0)
	GAMEMODE:SetRoundAmount(1)
	
	timer.Create("gware_checkforstart", 1, 0, GAMEMODE.CheckReady) -- Runs a constant timer to see if we're ready for the round to start
end

function GM:SetRound(round, rtime) -- Function to set the round
	GAMEMODE.roundstate = round
	GAMEMODE.roundtime = (CurTime() + rtime)
	
	GAMEMODE:NetworkRound()
end

function GM:GetRound() -- Just returns the round
	return GAMEMODE.roundstate
end

function GM:GetTime() -- Returns the rounds time
	return GAMEMODE.roundtime
end

function GM:SetRoundAmount(ra) -- Sets how many rounds (used in RTV)
	if self.roundamount then -- If it exists then...
		GAMEMODE.roundamount = GAMEMODE.roundamount + ra -- We add onto it
	else
		GAMEMODE.roundamount = 1 -- Otherwise we set it to one (used for round initialize)
	end
end

function GM:GetRoundAmount() -- Returns our round numbers (how many we've progressed into)
	return GAMEMODE.roundamount || 1
end

function GM:CheckReady() -- This is a function we use to check if the server can leave the waiting phase
	if (#team.GetPlayers(1)) >= 2 then -- Since nobody can join the bosses team, we see how many are in players. If it's greater or equal to 2 then we go ahead
		GAMEMODE:StartPrep() -- Since it passed we start the prep round
		timer.Stop("gware_checkforstart") -- We also need to stop the timer started when we are in ROUND_WAIT
	end
end

concommand.Add("gw_testit", function(ply)
	GAMEMODE:StartPrep()
end)

function GM:StartPrep() -- Starts the servers preround
	GAMEMODE:SetRound(ROUND_PREP, 10) -- We set the round as the prep round time convar
	
	for _, boss in ipairs(team.GetPlayers(2)) do -- Just a small reset on stats and stuff. Anyone on team 2 gets set back to team 1 and set back to their class standards
		boss:SetTeam(1)
		GAMEMODE:ResetStats(boss)
	end
	
	for _, everyone in ipairs(player.GetAll()) do
		everyone:SetDamage(0)
	end
	
	local playerlist = team.GetPlayers(1) -- I create the list here for ease later on
	
	for _, players in ipairs(playerlist) do -- For each player in it we...
		if players:Alive() then -- Check if they're alive...
			players:KillSilent() -- And kill them
		end
		
		players:UnSpectate() -- Unspectate them (since in death they are technically spectators
		players:Spawn() -- Respawn them
		players:Freeze(true) -- And freeze them so they don't move around too early
	end
	
	GAMEMODE:SelectBoss() -- We select our boss
	
	timer.Create("gware_roundprep", 10, 1, GAMEMODE.StartRound) -- And start the round after the prep time convar
end

function GM:StartRound()
	GAMEMODE:SetRound(ROUND_ACTIVE, 480) -- Set it equal to the round time convar and set the round as active
	
	timer.Stop("gware_roundprep") -- Stop the round prep timer just incase it still continues
	
	for _, players in ipairs(team.GetPlayers(1)) do -- For every player of TEAM_PLAYERS
		players:Freeze(false) -- Unfreeze them
		if players:Alive() then continue end -- Then if they're already alive ignore them
		players:Spawn() -- And spawn those who aren't
	end
	
	for _, boss in ipairs(team.GetPlayers(2)) do -- For every player of TEAM_BOSS
		GAMEMODE:SetBoss(boss) -- Set them as their boss selection
		boss:Freeze(false) -- And unfreeze them as well
	end
	
	timer.Create("gware_checkwin", 1, 0, GAMEMODE.CheckEnd) -- Start a constant timer to see if the round will end
end

util.AddNetworkString("gw_lms") -- TODO: Move to sv_resourcing
local lms_active = false -- Set at initialize that there is no LMS

function GM:CheckEnd() -- Checks if the round should end
	-- Empty tables we can add to
	local players = {} 
	local bosses = {} 
	
	for _, plys in ipairs(team.GetPlayers(1)) do -- For every TEAM_PLAYERS
		if !plys:Alive() then continue end -- If they're dead then move past them
		table.insert(players, plys) -- Add them to the table of players for easy checking
	end
	
	for _, boss in ipairs(team.GetPlayers(2)) do -- Same as players
		if !boss:Alive() or !boss:IsBoss() then continue end -- Except if the player isn't a boss (minion/servant) it ignores them
		table.insert(bosses, boss)
	end
	
	//if #players == 1 then -- If the number of players in the table are 1 then it starts LMS
	//	if !lms_active then -- To prevent spam we do a check to see if it's active
	//		net.Start("gw_lms") -- Starts the music
	//		net.Broadcast()
	//		
	//		lms_active = true -- Stop the spam by setting this to true
	//	end
	//end
	
	if (#players) < 1 then -- If there is nobody in the players table then we end the round with the boss winning
		GAMEMODE:EndRound(WIN_BOSS)
	elseif (#bosses) < 1 then -- Else if there is nobody here the players win
		GAMEMODE:EndRound(WIN_PLAYERS)
	elseif GAMEMODE:GetTime() <= CurTime() then -- Then even more, if the time runs out then the boss wins
		GAMEMODE:EndRound(WIN_BOSS)
	end
end

function GM:EndRound(roundwin)
	GAMEMODE:SetRound(ROUND_POST, 15) -- Sets the post round to the convar
	GAMEMODE:SetRoundAmount(1)
	
	GAMEMODE:CleanMap() -- Resets the map

	timer.Stop("gware_checkwin") -- Stops the timer to check for the win
	
	lms_active = false -- Reset LMS
	
	hook.Call("GwareRoundEnded") -- Any hooks with this will be called on round end
	
	net.Start("gware_roundover") -- Start the end round sound based on boss
		if roundwin == WIN_PLAYERS then -- If boss lost
			net.WriteString(GAMEMODE:GetBossTable(GAMEMODE.BossID).DeathSound)
		else -- If players lost
			net.WriteString(GAMEMODE:GetBossTable(GAMEMODE.BossID).WinSound)
		end
	net.Broadcast()
	
	GAMEMODE:CheckPrep() -- Start the whole process over
end

function GM:CleanMap()
	RunConsoleCommand("r_cleardecals") -- Clean all decals up
	
	timer.Simple(15, function() -- Timer for postround convar
		game.CleanUpMap()
		for _, ply in ipairs(player.GetAll()) do
			ply:ConCommand("stopsound") -- Stops it if the music continues on
		end
	end)
end

function GM:CheckPrep() -- Sees at the end of the round what is the next step
	if (#team.GetPlayers(1) + #team.GetPlayers(2)) <= 1 then -- If we have less than or equal to one player, then we wait for another
		GAMEMODE:SetRound(ROUND_WAIT, 0)
		timer.Create("gware_checkforstart", 1, 0, GAMEMODE.CheckReady)
	else -- Otherwise we continue as planned
		timer.Create("gware_roundend", 15, 1, GAMEMODE.StartPrep)
	end
end

function GM:NetworkRound(ply) -- This networks a majority of info to all players. I created this so I wasn't constantly doing this
	net.Start("gw_networkroundinfo")
	net.WriteInt(GAMEMODE:GetRound(), 32) -- Round State
	net.WriteInt(GAMEMODE:GetTime(), 32) -- Round Timer
	net.WriteInt(GAMEMODE:GetRoundAmount(), 32) -- Rounds Played
	
	if !ply then -- If I used it without a ply definer, then it sends it to all players (for major round things)
		net.Broadcast()
	else -- If I did use a ply, then it sends it to that player only, still sending the same info
		net.Send(ply)
	end
end

concommand.Add("gw_resetround", function(ply) -- Developer Command
	if ply:IsSuperAdmin() then
		GAMEMODE:EndRound()
	end
end)