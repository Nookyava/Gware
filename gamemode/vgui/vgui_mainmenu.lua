local gmw = 700 -- Main menu width
local gmh = 243 -- Main menu height

-- Each of the materials we use listed here for easy use, already smoothed out --
local mats = {
	Material("gware/menu/boss_select.png", "smooth"),
	Material("gware/menu/loadout_select.png", "smooth"),
	Material("gware/menu/class_select.png", "smooth"),
	Material("gware/menu/inventory_select.png", "smooth")
}

-- A small function to just draw the texture I want, with any color --
local function gw_drawimage(mat, color, x, y, w, h)
	surface.SetDrawColor(color)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

function GM:CreateMainMenu()
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
	
	-- The main menu that players see --
	local gw_menu = vgui.Create("DFrame", gw_menu_close)
	gw_menu:MakePopup(true)
	gw_menu:ShowCloseButton(false)
	gw_menu:SetTitle("")
	gw_menu:SetSize(gmw, gmh)
	gw_menu:SetPos(ScrW() / 2 - gw_menu:GetWide() / 2, ScrH() / 2 - gw_menu:GetTall() / 2)
	
	gw_menu.Paint = function()
		draw.RoundedBox(8, 0, 0, gmw, gmh, Color(255, 255, 255, 155))
		draw.RoundedBox(8, 2, 2, gmw - 4, gmh - 4, Color(55, 55, 55, 155))
	end
	
	-- The layout that allows us to easily add more (and keep things sorted) --
	local gw_selection = vgui.Create("DIconLayout", gw_menu)
	gw_selection:SetSize(gmw, 50)
	gw_selection:SetPos(0, 0)
	gw_selection:SetSpaceY(0)
	gw_selection:SetSpaceX(0)
	
	-- Selecting the boss category --
	local gw_boss_selection = gw_selection:Add("DButton")
	gw_boss_selection:SetSize(gmw, 60)
	gw_boss_selection:SetText("")
	
	gw_boss_selection.Paint = function()
		draw.RoundedBoxEx(8, 2, 2, gmw - 4, 60, Color(178, 34, 34, 225), true, true, false, false)
		
		gw_drawimage(mats[1], Color(255, 255, 255), 15, 10, 48, 48)
		gw_drawimage(mats[1], Color(255, 255, 255), gw_boss_selection:GetWide() - 63, 10, 48, 48)
		
		draw.SimpleText("Boss Selection", "HUDText_Rage", gw_boss_selection:GetWide() / 2, 25, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	gw_boss_selection.OnMousePressed = function()
		gw_menu_close:Close()
		self:CreateBossSelection()
	end
	
	-- Choosing a loadout category --
	local gw_loadout_selection = gw_selection:Add("DButton")
	gw_loadout_selection:SetSize(gmw, 60)
	gw_loadout_selection:SetText("")
	
	gw_loadout_selection.Paint = function()
		draw.RoundedBoxEx(8, 2, 2, gmw - 4, 60, Color(205, 201, 201, 75), false, false, false, false)
		
		gw_drawimage(mats[2], Color(255, 255, 255, 75), 15, 10, 48, 48)
		gw_drawimage(mats[2], Color(255, 255, 255, 75), gw_loadout_selection:GetWide() - 63, 10, 48, 48)
		
		draw.SimpleText("Loadout", "HUDText_Rage", gw_loadout_selection:GetWide() / 2, 25, Color(255, 255, 255, 75), TEXT_ALIGN_CENTER)
	end
	
	-- Selecting a class category --
	local gw_class_selection = gw_selection:Add("DButton")
	gw_class_selection:SetSize(gmw, 60)
	gw_class_selection:SetText("")
	
	gw_class_selection.Paint = function()
		draw.RoundedBoxEx(8, 2, 2, gmw - 4, 60, Color(218, 165, 32, 225), false, false, false, false)
		
		gw_drawimage(mats[3], Color(255, 255, 255), 15, 10, 48, 48)
		gw_drawimage(mats[3], Color(255, 255, 255), gw_class_selection:GetWide() - 63, 10, 48, 48)
		
		draw.SimpleText("Class Selection", "HUDText_Rage", gw_class_selection:GetWide() / 2, 25, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	gw_class_selection.OnMousePressed = function()
		gw_menu_close:Close()
		GAMEMODE:CreateClassSelection()
	end
	
	-- Looking in your inventory category --
	local gw_inventory_selection = gw_selection:Add("DButton")
	gw_inventory_selection:SetSize(gmw, 60)
	gw_inventory_selection:SetText("")
	
	gw_inventory_selection.Paint = function()
		draw.RoundedBoxEx(8, 2, 2, gmw - 4, 60, Color(160, 82, 45, 255), false, false, true, true)
		
		gw_drawimage(mats[4], Color(255, 255, 255, 255), 15, 10, 48, 48)
		gw_drawimage(mats[4], Color(255, 255, 255, 255), gw_inventory_selection:GetWide() - 63, 10, 48, 48)
		
		draw.SimpleText("Inventory Selection", "HUDText_Rage", gw_inventory_selection:GetWide() / 2, 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	gw_inventory_selection.DoClick = function()
		gw_menu_close:Close()
		GAMEMODE:CreateInventoryMenu()
	end
end