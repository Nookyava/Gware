local gmw = 900 -- Main menu width
local gmh = 250 -- Main menu height

local mats = {
	("gware/menu/back.png")
}

-- A small function to just draw the texture I want, with any color --
local function gw_drawimage(mat, color, x, y, w, h)
	surface.SetDrawColor(color)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

function GM:CreateClassSelection()
	-- Used when clicking off the main menu to close it --
	local gw_menu_close = vgui.Create("DFrame")	
	gw_menu_close:SetSize(ScrW(), ScrH())
	gw_menu_close:SetTitle("")
	gw_menu_close:ShowCloseButton(false)
	gw_menu_close:MakePopup(true)
	gw_menu_close.Paint = function() end
	
	gw_menu_close.OnMousePressed = function()
		gw_menu_close:Close()
	end
	
	-- Main boss selection menu --
	local gw_class_selection = vgui.Create("DFrame", gw_menu_close)
	gw_class_selection:MakePopup()
	gw_class_selection:ShowCloseButton(false)
	gw_class_selection:SetSize(gmw, gmh)
	gw_class_selection:SetDraggable(false)
	gw_class_selection:SetPos(ScrW() / 2 - gmw / 2, ScrH() / 2 - gmh / 2)
	gw_class_selection:SetTitle("")
	
	gw_class_selection.Paint = function()
		draw.RoundedBox(8, 0, 0, gmw, gmh, Color(255, 255, 255, 155))
		draw.RoundedBox(8, 2, 2, gmw - 4, gmh - 4, Color(55, 55, 55, 155))
		
		draw.RoundedBoxEx(8, 2, 2, gmw - 4, 40, Color(218, 165, 3), true, true, false, false)
		
		draw.SimpleText("Class Selection", "HUDText_Rage", gw_class_selection:GetWide() / 2, 12, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	-- Back Button --
	local gw_boss_back = vgui.Create("DImageButton", gw_class_selection)
	gw_boss_back:SetSize(48, 48)
	gw_boss_back:SetPos(10, 0)
	gw_boss_back:SetImage(mats[1])
	
	gw_boss_back.DoClick = function()
		gw_menu_close:Close()
		GAMEMODE:CreateMainMenu()
	end
	
	-- Class Selection Background --
	local gw_class_panel = vgui.Create("DIconLayout", gw_class_selection)
	gw_class_panel:SetPos(2, 42)
	gw_class_panel:SetSize(gmw - 2, gmh - 42)
	gw_class_panel:SetSpaceY(1)
	
	for _, classes in ipairs(self.Classes) do
		local gw_classes = gw_class_panel:Add("DButton")
		gw_classes:SetSize(298, gmh - 45)
		gw_classes:SetText("")
		
		gw_classes.Paint = function()
			draw.RoundedBoxEx(8, 0, 0, 298, gmh, classes.Color, false, false, false, false)
			
			gw_drawimage(classes.Icon, Color(255, 255, 255), 149 - 32, 5, 64, 48)
			
			draw.SimpleText(classes.Name, "HUDText_Rage", gw_classes:GetWide() / 2, 60, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		end
		
		gw_classes.DoClick = function()
			net.Start("gw_pickclass")
				net.WriteString(classes.Name)
				net.WriteEntity(LocalPlayer())
			net.SendToServer()
			
			GAMEMODE:Notify("You have become a " .. classes.Name, Color(255, 255, 255), 5)
		end
	end
end