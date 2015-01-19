net.Receive("gware_pickteam", function(len, CLIENT)
	
	local gw_frame = vgui.Create("DFrame")
		gw_frame:SetSize(400, 300)
		gw_frame:SetPos(ScrW() / 2 - gw_frame:GetWide() / 2, ScrH() / 2 - gw_frame:GetTall() / 2)
		gw_frame:SetBackgroundBlur(false)
		gw_frame:MakePopup()
		gw_frame:SetTitle("")
		gw_frame:ShowCloseButton(false)
		
		local gw_team1 = vgui.Create("DButton", gw_frame)
		gw_team1:SetPos(0, 0)
		gw_team1:SetSize(gw_frame:GetWide() / 2, gw_frame:GetTall())
		gw_team1:SetText("Players")
		
		gw_team1.DoClick = function()
			net.Start("gw_pickteam")
				net.WriteInt(1, 32)
				net.WriteEntity(LocalPlayer())
			net.SendToServer()
			
			GAMEMODE:Notify("You have joined the Players.", Color(255, 255, 255), 5)
			
			gw_frame:Close()
		end
		
		local gw_team2 = vgui.Create("DButton", gw_frame)
		gw_team2:CopyPos(gw_team1)
		gw_team2:SetSize(gw_frame:GetWide() / 2, gw_frame:GetTall())
		gw_team2:MoveRightOf(gw_team1, 0)
		gw_team2:SetText("Spectator")
		
		gw_team2.DoClick = function()
			net.Start("gw_pickteam")
				net.WriteInt(3, 32)
				net.WriteEntity(LocalPlayer())
			net.SendToServer()
			
			GAMEMODE:Notify("You have joined the Spectators.", Color(255, 255, 255), 5)
			
			gw_frame:Close()
		end
end)