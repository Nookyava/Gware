local gmw = 500 -- Main menu width
local gmh = 500 -- Main menu height

-- Each of the materials we use listed here for easy use, already smoothed out --
local mats = {
	("gware/menu/back.png")
}

-- A small function to just draw the texture I want, with any color --
local function gw_drawimage(mat, color, x, y, w, h)
	surface.SetDrawColor(color)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

function GM:CreateInventoryMenu()
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
		
		draw.RoundedBoxEx(8, 2, 2, gmw - 4, 40, Color(160, 82, 45, 225), true, true, false, false)
		
		draw.SimpleText("Inventory", "HUDText_Rage", gw_menu:GetWide() / 2, 12, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	local gw_inventory_back = vgui.Create("DImageButton", gw_menu)
	gw_inventory_back:SetSize(48, 48)
	gw_inventory_back:SetPos(10, 0)
	gw_inventory_back:SetImage(mats[1])
	
	gw_inventory_back.DoClick = function()
		gw_menu_close:Close()
		GAMEMODE:CreateMainMenu()
	end
	
	-- The layout that allows us to easily add more (and keep things sorted) --
	local gw_selection = vgui.Create("DIconLayout", gw_menu)
	gw_selection:SetSize(gmw, gmh)
	gw_selection:SetPos(15, 55)
	gw_selection:SetSpaceY(10)
	gw_selection:SetSpaceX(17)
	
	for i = 0, 15 do
		local gw_items = gw_selection:Add("DButton")
		gw_items:SetSize(64, 64)
		gw_items:SetText("")
		gw_items:SetToolTip("Item")
	end
end