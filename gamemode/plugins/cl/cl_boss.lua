net.Receive("gw_bosschoice", function(len, CLIENT)
	local name = net.ReadString()
	local boss = net.ReadString()
	local startsound = net.ReadString()
	GAMEMODE.health = net.ReadString()
	
	surface.PlaySound(startsound)
	
	GAMEMODE:Notify(name .. " has become " .. boss .. " with " .. GAMEMODE.health .. " health!", Color(255, 255, 255), 10)
end)

net.Receive("gw_alertbossdeath", function(len, CLIENT)
	GAMEMODE:Notify("The boss " .. net.ReadString(), Color(255, 255, 255), 5)
end)

local gmw = 250 -- Main menu width
local gmh = 400 -- Main menu height

net.Receive("gw_ragesound", function(len, CLIENT)
	surface.PlaySound(net.ReadString())
end)

function GM:OnContextMenuOpen()
	GAMEMODE:BossMenu()
end

function GM:BossMenu()	
	if gw_menu and ValidPanel(gw_menu) then 
		gw_menu:MoveTo(ScrW(), ScrH() / 2 - gw_menu:GetTall() / 2, 1, 0, 2)
		timer.Simple(2, function()
			gw_menu:Close() 
		end)
		return 
	end
	
	net.Start("gw_retrievecreditlist")
		net.WriteEntity(LocalPlayer())
	net.SendToServer()
	
	gw_menu = vgui.Create("DFrame")
	gw_menu:ShowCloseButton(false)
	gw_menu:SetTitle("")
	gw_menu:SetSize(gmw, gmh)
	gw_menu:SetPos(ScrW(), ScrH() / 2 - gw_menu:GetTall() / 2)
	gw_menu:MoveTo(ScrW() - gw_menu:GetWide(), ScrH() / 2 - gw_menu:GetTall() / 2, 1, 0, 2)
	
	gw_menu.Paint = function()
		draw.RoundedBox(8, 0, 0, gmw, gmh, Color(255, 255, 255, 155))
		draw.RoundedBox(8, 2, 2, gmw - 4, gmh - 4, Color(55, 55, 55, 155))
		
		draw.RoundedBoxEx(8, 2, 2, gmw - 4, 40, Color(125, 125, 125, 225), true, true, false, false)
		
		draw.SimpleText("Boss Queue", "HUDText_Rage", gw_menu:GetWide() / 2, 12, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
end

net.Receive("gw_sendcreditlist", function(len, CLIENT)
	local list = vgui.Create("DListView", gw_menu)
	list:SetMultiSelect(false)
	list:SetPos(0, 40)
	list:SetSize(gmw, gmh - 40)
	list:AddColumn("Name")
	list:AddColumn("Credits")
	list.Paint = function()
	
	end
	
	local creditlist = net.ReadTable()
	
	for _, ply in ipairs(creditlist) do
		list:AddLine(ply.Name, ply.Credits)
	end
end)