local round = 1
local rtime = 0
local ramount = 1
local superjump = 0
local credits = 0
local damage = 0

local round_string = {
	[ROUND_WAIT]   = "WAITING",
	[ROUND_PREP]   = "PREPPING",
	[ROUND_ACTIVE] = "ACTIVE",
	[ROUND_POST]   = "POST"
}

net.Receive("gw_networkroundinfo", function(len, CLIENT)
	round = net.ReadInt(32)
	rtime = net.ReadInt(32)
	ramount = net.ReadInt(32)
end)

net.Receive("gw_syncsuperjump", function(len, CLIENT)
	local ply = LocalPlayer()
	ply.superjump = (net.ReadInt(32))
end)

net.Receive("gw_updatedamage", function(len, CLIENT)
	damage = net.ReadInt(32)
end)

net.Receive("gw_updaterage", function(len, CLIENT)
	local ply = net.ReadEntity()
	ply.Rage = math.Clamp(net.ReadInt(32), 0, 100)
end)

net.Receive("gw_updatecredits", function(len, CLIENT)
	credits = net.ReadInt(32)
end)

function GM:Notify(msg, color, duration)
	local time = SysTime()
	table.insert(self.Notifications, {Msg = msg, Color = color, Duration = duration, STime = time})
	self.Notifications[#self.Notifications].ETime = time+(self.Notifications[#self.Notifications].Duration)
end

function GM:NotifyPaint()
	if (#self.Notifications) > 0 then
		local notification = self.Notifications[1]
		local frac = math.TimeFraction(notification.STime, notification.ETime, SysTime())
		frac = math.Clamp(frac, 0, 1)
		notification.Color.a = Lerp(frac, 255, 0)
		
		draw.RoundedBox(0, 0, 0, ScrW(), 50, Color(55, 55, 55, notification.Color.a))
		draw.DrawText(notification.Msg, "HUDText", ScrW() / 2, 20, notification.Color, TEXT_ALIGN_CENTER)
		
		if frac == 1 then
			table.remove(self.Notifications, 1)
			
			if #self.Notifications >= 1 then
				local time = SysTime()
				notification.STime = time
				notification.ETime = time+notification.Duration
			end
			return
		end
	end
end

-- A small function to just draw the texture I want, with any color --
local function gw_drawimage(mat, color, x, y, w, h)
	surface.SetDrawColor(color)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

local function gw_drawshadowedtext(string, font, x, y, color, alignment)
	draw.DrawText(string, font, x + 3, y + 3, Color(0, 0, 0), alignment)
	draw.DrawText(string, font, x, y, color, alignment)
end

local mats = {
	Material("gware/hud/boss_icon.png", "smooth"),
	Material("gware/hud/players_icon.png", "smooth"),
	Material("gware/hud/ammo_icon.png", "smooth")
}

function GM:HUDPaint()
	local ply = LocalPlayer()

	local wep = LocalPlayer():GetActiveWeapon()
	
	self:NotifyPaint()
	
	draw.DrawText("Queue Credits: "..credits, "HUDText", 13, 8, Color(0, 0, 0), TEXT_ALIGN_LEFT)
	draw.DrawText("Queue Credits: "..credits, "HUDText", 10, 5, Color(255, 255, 255), TEXT_ALIGN_LEFT)
	
	-- If they're not alive, display the timer only --
	if !ply:Alive() then 
		if rtime > 0 then
			gw_drawshadowedtext(round_string[round], "HUDText", ScrW() / 2, 60, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			gw_drawshadowedtext((string.FormattedTime(rtime - CurTime(), "%02i:%02i")), "HUDText", ScrW() / 2, 100, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		else
			gw_drawshadowedtext(round_string[round], "HUDText", ScrW() / 2, 60, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			gw_drawshadowedtext((string.FormattedTime(0, "%02i:%02i")), "HUDText", ScrW() / 2, 100, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		end
		
		return
	end
	
	if ply:Team() == TEAM_BOSS then -- BOSS
		-- RAGE --
		draw.RoundedBox(8, 245, ScrH() - 60, 175, 30, Color(155, 155, 155))
		draw.RoundedBox(8, 250, ScrH() - 55, 165, 20, Color(135, 135, 135))
		
		if ((ply.Rage / 100) * 165) >= 10 then
			RageColor = Color(148, 0, 211, 255)
		else
			RageColor = Color(148, 0, 211, 0)
		end
		
		draw.RoundedBox(8, 250, ScrH() - 55, (ply.Rage / 100) * 165, 20, RageColor)
		
		gw_drawshadowedtext(ply.Rage, "HUDText", 330, ScrH() - 60, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		
		-- HEALTH --
		draw.RoundedBox(8, 145, ScrH() - 120, 275, 60, Color(155, 155, 155))
		draw.RoundedBox(8, 145, ScrH() - 115, 270, 50, Color(92, 0, 0))
		
		gw_drawshadowedtext(ply:Health(), "HUDText", 290, ScrH() - 105, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		
		gw_drawimage(mats[1], Color(255, 255, 255), 40, ScrH() - 160, 128, 128)		
		
		-- TIME --
		if rtime > 0 then
			gw_drawshadowedtext(round_string[round], "HUDText", 165, ScrH() - 150, Color(255, 255, 255), TEXT_ALIGN_LEFT)
			gw_drawshadowedtext((string.FormattedTime(rtime - CurTime(), "%02i:%02i")), "HUDText", 420, ScrH() - 150, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
		else
			gw_drawshadowedtext(round_string[round], "HUDText", 170, ScrH() - 150, Color(255, 255, 255), TEXT_ALIGN_LEFT)
			gw_drawshadowedtext((string.FormattedTime(0, "%02i:%02i")), "HUDText", 420, ScrH() - 150, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
		end
	elseif ply:Team() == TEAM_PLAYER then -- PLAYERS
		-- HEALTH --
		draw.RoundedBox(8, 135, ScrH() - 140, 275, 60, Color(155, 155, 155))
		draw.RoundedBox(8, 135, ScrH() - 135, 270, 50, Color(92, 0, 0))
		
		gw_drawshadowedtext(ply:Health(), "HUDText", 283, ScrH() - 122, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		
		gw_drawimage(mats[2], Color(255, 255, 255), 40, ScrH() - 160, 128, 128)	
		
		-- AMMO --
		if ply:GetActiveWeapon():IsValid() then
			cm = wep:Clip1() or 0
			remain = ply:GetAmmoCount(wep:GetPrimaryAmmoType()) or 0
			weapon = wep:GetPrintName()
			
			draw.RoundedBox(8, ScrW() - 425, ScrH() - 135, 275, 60, Color(155, 155, 155))
			draw.RoundedBox(8, ScrW() - 420, ScrH() - 130, 270, 50, Color(184, 134, 11))
			
			gw_drawimage(mats[3], Color(255, 255, 255), ScrW() - 170, ScrH() - 160, 128, 128)	
			
			-- Ammo Text
			gw_drawshadowedtext(cm .. "/" .. remain, "HUDText", ScrW() - 267, ScrH() - 120, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			gw_drawshadowedtext(weapon, "HUDText", ScrW() - 270, ScrH() - 165, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		end
		
		-- Boss/Damage Info --
		gw_drawshadowedtext("Boss HP: "..GAMEMODE.health, "HUDText", ScrW() / 2, ScrH() / 2 + 225, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		
		gw_drawshadowedtext("Damage: "..damage, "HUDText", ScrW() / 2, ScrH() / 2 + 250, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		
		-- TIME --
		if rtime > 0 then
			gw_drawshadowedtext(round_string[round], "HUDText", 155, ScrH() - 170, Color(255, 255, 255), TEXT_ALIGN_LEFT)
			gw_drawshadowedtext((string.FormattedTime(rtime - CurTime(), "%02i:%02i")), "HUDText", 410, ScrH() - 170, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
		else
			gw_drawshadowedtext(round_string[round], "HUDText", 155, ScrH() - 170, Color(255, 255, 255), TEXT_ALIGN_LEFT)
			gw_drawshadowedtext((string.FormattedTime(0, "%02i:%02i")), "HUDText", 410, ScrH() - 170, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
		end
	end
	
	if ply.Servant then
		gw_drawshadowedtext("Servant: " .. ply.Servant, "HUDText", 50, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT)
	end
	
	if ply.IsAServant then
		gw_drawshadowedtext("You are a servant, kill your teammates!", "HUDText", 50, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT)
	end
	
	self:DrawSuperJump()
	
	self:DrawInfo()
end

function GM:DrawSuperJump()
	local ply = LocalPlayer()
	if ply:Team() != TEAM_BOSS then return end
	if !ply.superjump then ply.superjump = 0 end
	
	if ply.superjump > CurTime() then
		gw_drawshadowedtext(math.Round(ply.superjump - CurTime() + 1), "HUDText", ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT)
	end
end

function GM:DrawInfo()
	local ply = LocalPlayer()
	local trace = ply:GetEyeTrace(MASK_SHOT)
	local ent = trace.Entity
	
	if (not IsValid(ent)) or ent.NoTarget then return end
	
	if ent:IsPlayer() then
		w, h = surface.GetTextSize( ent:Name() )
		x = (ScrW() / 2 )
		draw.SimpleText( ent:Name(), "TargetID", x, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER )
		draw.SimpleText( ent:Health(), "TargetID", x, ScrH() / 2 + h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
end

function GM:HUDShouldDraw(name) -- This hides what we don't want in sandbox.
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"})do
		if name == v then return false end
	end
	return true
end

function GM:PostDrawViewModel( vm, ply, weapon )
	if ( weapon.UseHands || !weapon:IsScripted() ) then
		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end
	end
end

net.Receive("gw_showhelp", function(len, CLIENT)
	local ply = LocalPlayer()

	ply.NotBoss = !ply.NotBoss
end)