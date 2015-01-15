local bossfolder = "boxman"

GM:AddBoss("Boxman", "models/player/lukap.mdl", 900, "gware/"..bossfolder.."/intro.mp3", "gware/"..bossfolder.."/loss.mp3", "gware/"..bossfolder.."/win.mp3", "gware/"..bossfolder.."/rage.mp3", "Luka will sing, causing any players near her to lose health.", "Vocaloid", function(ply)
	for _, ammo in ipairs(ents.FindByClass("gw_ammo")) do
		
	end
	
	ply:SetRage(0)
end)

if SERVER then
	resource.AddFile("sound/gware/"..bossfolder.."/intro.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/loss.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/rage.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/win.mp3")
end