function GM:HUDDrawScoreBoard()
	return false
end

local servant
net.Receive("gware_sendservant", function(len, CLIENT)
	servant = net.ReadEntity()
end)

function GM:ScoreboardShow()
	net.Start("gware_grabservant")
	net.SendToServer()
	
	wb_sb = vgui.Create("Panel")
	wb_sb:SetSize(800, 600)
	wb_sb:SetPos(ScrW() / 2 - (wb_sb:GetWide() / 2), ScrH() / 2 - (wb_sb:GetTall() / 2))

	local ysb = 50
	
	wb_sb.Paint = function()
		draw.RoundedBox(8, 0, 0, wb_sb:GetWide(), wb_sb:GetTall(), Color(55, 55, 55, 155))
		draw.RoundedBox(0, 0, 0, wb_sb:GetWide(), 50, Color(55, 55, 55))
		
		draw.DrawText("Garry's Warehouse", "HUDText", 20, 12.5, Color(255, 255, 255), TEXT_ALIGN_LEFT)
		//draw.DrawText(GetConVarString("ip"), "HUDText", wb_sb:GetWide() - 25, 12.5, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
	end
	
	local pCol = vgui.Create('DPanelList', wb_sb)
		pCol:SetPos( 0,50 )
		pCol:SetSize( wb_sb:GetWide(), wb_sb:GetTall() )
		pCol:SetSpacing( 2 ) 
		pCol:EnableHorizontal( false )
		pCol:EnableVerticalScrollbar( false )
		pCol.NextRefresh = CurTime()+0.01
		pCol.Refill = function(self)
			self:Clear()
 
			for k, v in pairs(player.GetAll()) do

				local pInfo = vgui.Create( "DPanel", pCol )
				pInfo:SetSize(710, 36)

				local avatar = vgui.Create("AvatarImage", pInfo)
				avatar:SetPos(2, 2)
				avatar:SetSize(32, 32)
				avatar:SetPlayer( v, 32 )
				
				if v:Team() == TEAM_SPECTATOR then
					v.Color = Color(55, 55, 55, 55)
				elseif v == servant and v:Alive() then
					v.Color = Color(0, 255, 0, 55)
				elseif v == servant and !v:Alive() then
					v.Color = Color(155, 155, 0, 55)
				elseif v:Team() == TEAM_BOSS and v.IsAServant then
					v.Color = Color(0, 255, 0, 55)
				elseif v:Team() == TEAM_BOSS and v:Alive() then
					v.Color = Color(255, 255, 0, 155)
				elseif v:Team() == TEAM_BOSS and !v:Alive() then
					v.Color = Color(155, 155, 0, 55)
				elseif v:Team() == TEAM_PLAYER and v:Alive() then
					v.Color = Color(0, 255, 0, 55)
				elseif v:Team() == TEAM_PLAYER and !v:Alive() then
					v.Color = Color(0, 55, 0, 155)
				end
				
				function pInfo:Paint(w, h)
					draw.RoundedBox(0, 0, 0, w, h, v.Color)
					
					draw.SimpleText(v:Nick(), "HUDText", 40, 18, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(v:Ping(), "HUDText", wb_sb:GetWide() - 28, 5, Color(255, 255, 255), TEXT_ALIGN_RIGHT)

				end
				pCol:AddItem( pInfo )
			end
	end


			pCol.Think = function(self)
			if self:IsVisible() then
				if pCol.NextRefresh < CurTime() then
					pCol.NextRefresh = CurTime() + 1
					pCol:Refill()
				end
			end
		end

end

function GM:ScoreboardHide()
	if wb_sb then
		wb_sb:Remove()
		wb_sb = nil
	end
end