local bossfolder = "pyramid_head"

GM:AddBoss("Pyramid Head", "models/player/pyramidhead/pyramidhead.mdl", 1250, "gware/"..bossfolder.."/intro.mp3", "gware/"..bossfolder.."/loss.wav", "gware/"..bossfolder.."/win.mp3", "gware/"..bossfolder.."/rage.wav", "Pyramid Head pulls out a gigantic sword with increased range and damage", "Silent Hill", function(ply)
	ply:Give("weapon_gw_pyramid")
	ply:SelectWeapon("weapon_gw_pyramid")
	ply:SetRage(0)
	
	timer.Simple(10, function()
		if ply:Alive() then
			ply:StripWeapon("weapon_gw_pyramid")
		end
	end)
end)

if SERVER then
	resource.AddFile("sound/gware/"..bossfolder.."/intro.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/loss.wav")
	resource.AddFile("sound/gware/"..bossfolder.."/rage.wav")
	resource.AddFile("sound/gware/"..bossfolder.."/win.mp3")
	
	resource.AddFile("models/player/pyramidhead/pyramidhead.mdl")
	resource.AddFile("models/fallout 3/ff_sword.mdl")
	resource.AddFile("materials/models/player/elis/ph/ph1.vtf")
	resource.AddFile("materials/models/player/elis/ph/ph1_normal.vtf")
	resource.AddFile("materials/models/jason278/fallout 3/elsa.vmt")
	resource.AddFile("materials/models/jason278/fallout 3/elsadec.vmt")
	resource.AddFile("materials/models/jason278/fallout 3/impugnatura.vmt")
	resource.AddFile("materials/models/jason278/fallout 3/lama.vmt")
end