net.Receive("gware_pickteam", function(len, CLIENT)
	
	local gw_frame = vgui.Create("DFrame")
		gw_frame:SetSize(400, 300)
		gw_frame:SetPos(ScrW() / 2 - gw_frame:GetWide() / 2, ScrH() / 2 - gw_frame:GetTall() / 2)
		gw_frame:SetBackgroundBlur(false)
		gw_frame:MakePopup()
		gw_frame:SetTitle("")
		gw_frame:ShowCloseButton(false)
		
		gw_frame.Paint = function()
			draw.RoundedBox(8, 0, 0, gw_frame:GetWide(), gw_frame:GetTall(), Color(55, 55, 55, 155))
		end
		
		local gw_team1 = vgui.Create("DButton", gw_frame)
		gw_team1:SetPos(0, 0)
		gw_team1:SetSize(gw_frame:GetWide() / 2, gw_frame:GetTall())
		gw_team1:SetText("")
		
		gw_team1.DoClick = function()
			net.Start("gw_pickteam")
				net.WriteInt(1, 32)
				net.WriteEntity(LocalPlayer())
			net.SendToServer()
			
			GAMEMODE:Notify("You have joined the Players.", Color(255, 255, 255), 5)
			
			gw_frame:Close()
		end
		
		gw_team1.Paint = function()
			surface.SetMaterial(Material("gware/icons/boss.png"), smooth)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(gw_team1:GetWide() / 2 - 59, 50, 128, 128)
		end
		
		local gw_team2 = vgui.Create("DButton", gw_frame)
		gw_team2:CopyPos(gw_team1)
		gw_team2:SetSize(gw_frame:GetWide() / 2, gw_frame:GetTall())
		gw_team2:MoveRightOf(gw_team1, 0)
		gw_team2:SetText("")
		
		gw_team2.DoClick = function()
			net.Start("gw_pickteam")
				net.WriteInt(3, 32)
				net.WriteEntity(LocalPlayer())
			net.SendToServer()
			
			GAMEMODE:Notify("You have joined the Spectators.", Color(255, 255, 255), 5)
			
			gw_frame:Close()
		end
		
		gw_team2.Paint = function()
			surface.SetMaterial(Material("gware/icons/spectator.png"), smooth)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(gw_team2:GetWide() / 2 - 59, 50, 128, 128)
		end
end)