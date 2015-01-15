local gmw = 700 -- Main menu width
local gmh = 500 -- Main menu height

local mats = {
	("gware/menu/back.png")
}

local bossname = ""
local bossrage = ""
local bossappear = ""
local bossmodel = ""

function GM:CreateBossSelection(IsPlayerOpened, ResetChoice)
	-- Variables we use --
	local bosschoices = GAMEMODE.Bosses
	local gw_menu_close
	
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
	
	if IsPlayerOpened != nil then -- Just a small detection to see if we opened it or the player did
		gw_menu_close:SetSize(0, 0)
	end
	
	-- Main boss selection menu --
	local gw_boss_selection = vgui.Create("DFrame", gw_menu_close)
	gw_boss_selection:MakePopup(true)
	gw_boss_selection:ShowCloseButton(false)
	gw_boss_selection:SetSize(gmw, gmh)
	gw_boss_selection:SetDraggable(false)
	gw_boss_selection:SetPos(ScrW() / 2 - gmw / 2, ScrH() / 2 - gmh / 2)
	gw_boss_selection:SetTitle("")
	
	gw_boss_selection.Paint = function()
		draw.RoundedBox(8, 0, 0, gmw, gmh, Color(255, 255, 255, 155))
		draw.RoundedBox(8, 2, 2, gmw - 4, gmh - 4, Color(55, 55, 55, 155))
		
		draw.RoundedBoxEx(8, 2, 2, gmw - 4, 40, Color(178, 34, 34, 225), true, true, false, false)
		
		draw.SimpleText("Boss Selection", "HUDText_Rage", gw_boss_selection:GetWide() / 2, 12, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	-- Back Button --
	if IsPlayerOpened == nil then
		local gw_boss_back = vgui.Create("DImageButton", gw_boss_selection)
		gw_boss_back:SetSize(48, 48)
		gw_boss_back:SetPos(10, 0)
		gw_boss_back:SetImage(mats[1])
		
		gw_boss_back.DoClick = function()
			gw_menu_close:Close()
			GAMEMODE:CreateMainMenu()
		end
	end
	
	-- Model Panel Background --
	local gw_model_panel = vgui.Create("DPanel", gw_boss_selection)
	gw_model_panel:SetPos(2, 42)
	gw_model_panel:SetSize(200, gmh / 2)
	
	gw_model_panel.Paint = function()
		draw.RoundedBoxEx(8, 0, 0, gw_model_panel:GetWide(), gw_model_panel:GetTall(), Color(255, 255, 255, 155), false, false, false, false)
		draw.RoundedBoxEx(8, 1, 2, gw_model_panel:GetWide() - 3, gw_model_panel:GetTall() - 4, Color(155, 155, 155, 255), false, false, false, false)
	end
	
	-- Actual Model we draw onto the panel --
	local gw_model = vgui.Create("DModelPanel", gw_model_panel)
	gw_model:SetPos(0, 0)
	gw_model:SetSize(200, gmh / 2)
	gw_model:SetModel(bossmodel)
	gw_model:SetAnimated(false)
	gw_model:SetCamPos(Vector(30, 40, 50))
	gw_model:SetFOV(85)
	
	function gw_model:LayoutEntity(Entity) 
		self:RunAnimation() 
		Entity:SetAngles(Angle(0, 50, 0))
    end
	
	-- The description background for the boss selected --
	local gw_description_panel = vgui.Create("DPanel", gw_boss_selection)
	gw_description_panel:SetPos(gw_model_panel:GetWide() + 2, 42)
	gw_description_panel:SetSize(gw_boss_selection:GetWide() - gw_model_panel:GetWide(), gmh / 2)
	
	gw_description_panel.Paint = function()
		draw.RoundedBoxEx(8, 0, 0, gw_description_panel:GetWide(), gw_description_panel:GetTall(), Color(255, 255, 255, 155), false, false, false, false)
		draw.RoundedBoxEx(8, 1, 2, gw_description_panel:GetWide() - 6, gw_description_panel:GetTall() - 4, Color(155, 155, 155, 155), false, false, false, false)
		
		-- Name --
		draw.RoundedBox(8, 12, 5, gw_description_panel:GetWide() - 25, 25, Color(155, 155, 155, 225))
		draw.SimpleText("Name", "HUDText_Rage", gw_description_panel:GetWide() / 2, 12, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		draw.SimpleText(bossname, "HUDText_Rage", gw_description_panel:GetWide() / 2, 35, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		
		-- Rage --
		draw.RoundedBox(8, 12, 60, gw_description_panel:GetWide() - 25, 25, Color(155, 155, 155, 225))
		draw.SimpleText("Rage", "HUDText_Rage", gw_description_panel:GetWide() / 2, 65, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		if string.len(bossrage) > 45 then
			draw.SimpleText(string.sub(bossrage, 1, 45), "HUDText_Rage", gw_description_panel:GetWide() / 2, 90, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			draw.SimpleText(string.sub(bossrage, 46, 90), "HUDText_Rage", gw_description_panel:GetWide() / 2, 110, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(string.sub(bossrage, 1, 45), "HUDText_Rage", gw_description_panel:GetWide() / 2, 90, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		end
		-- Appears on --
		draw.RoundedBox(8, 12, 135, gw_description_panel:GetWide() - 25, 25, Color(155, 155, 155, 225))
		draw.SimpleText("Origin", "HUDText_Rage", gw_description_panel:GetWide() / 2, 138, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		
		draw.SimpleText(bossappear, "HUDText_Rage", gw_description_panel:GetWide() / 2, 170, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	-- Boss Selection Panel Background --
	local gw_boss_choices_panel = vgui.Create("DPanel", gw_boss_selection)
	gw_boss_choices_panel:SetSize(gmw, gmh/2)
	gw_boss_choices_panel:SetPos(0, gmh / 2 + 42)
	
	gw_boss_choices_panel.Paint = function()
		draw.RoundedBoxEx(8, 0, 0, gw_boss_choices_panel:GetWide(), gw_boss_choices_panel:GetTall(), Color(255, 255, 255, 155), false, false, true, true)
		draw.RoundedBoxEx(8, 3, 2, gw_boss_choices_panel:GetWide() - 6, gw_boss_choices_panel:GetTall() - 47, Color(155, 155, 155, 255), false, false, true, true)
	end
	
	-- Boss Icons --
	local gw_boss_choices = vgui.Create("DIconLayout", gw_boss_choices_panel)
	gw_boss_choices:SetSize(gw_boss_choices_panel:GetWide(), gw_boss_choices_panel:GetTall())
	gw_boss_choices:SetPos(5, 5)
	gw_boss_choices:SetSpaceY(5)
	gw_boss_choices:SetSpaceX(5)
	
	for k,v in ipairs(bosschoices) do
		local gw_boss_bg = gw_boss_choices:Add("DPanel")
		gw_boss_bg:SetSize(64, 64)
		gw_boss_bg.Paint = function() 
			draw.RoundedBox(8, 0, 0, 64, 64, Color(155, 155, 155, 255))
		end
		
		local gw_boss = gw_boss_bg:Add("DModelPanel")
		gw_boss:SetModel(v.Model)
		local icon = gw_boss:GetEntity()
		
		gw_boss:SetSize(64, 64)
		gw_boss:SetAnimated(false)
		gw_boss:SetCamPos(Vector(50, 0, 65))
		
		if icon:LookupBone("ValveBiped.Bip01_Head1") then
			bone_id = icon:GetBonePosition(icon:LookupBone("ValveBiped.Bip01_Head1"))
		elseif icon:LookupBone("ValveBiped.Bip01_Spine4") then
			bone_id = icon:GetBonePosition(icon:LookupBone("ValveBiped.Bip01_Spine4"))
		else
			bone_id = Vector(0, 0, 0)
		end
		
		gw_boss:SetLookAt(bone_id)
		gw_boss:SetFOV(20)
		
		function gw_boss:LayoutEntity(ent)
			self:RunAnimation()
		end
		
		gw_boss.DoClick = function()
			if IsPlayerOpened != nil then
				net.Start("gw_playerchoseboss")
					net.WriteEntity(LocalPlayer())
					net.WriteUInt(k, 8)
				net.SendToServer()
			else
				net.Start("gw_prechooseboss")
					net.WriteEntity(LocalPlayer())
					net.WriteUInt(k, 8)
				net.SendToServer()
			end
			
			gw_model:SetModel(v.Model)
			bossname = v.Name
			bossmodel = v.Model
			bossrage = v.RageDesc
			bossappear = v.AppearsOn
		end
	end
	
	-- Just close the menu after 10 seconds --
	if IsPlayerOpened != nil then
		timer.Simple(10, function()
			-- If we are resetting the choice, these need to be blank --
			if ResetChoice != nil then
				bossname = ""
				bossrage = ""
				bossappear = ""
				bossmodel = ""
			end
			
			gw_menu_close:Close()
		end)
	end
end