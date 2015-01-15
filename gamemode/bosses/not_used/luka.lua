local bossfolder = "luka"

GM:AddBoss("Megurine Luka", "models/player/lukap.mdl", 825, "gware/"..bossfolder.."/intro.mp3", "gware/"..bossfolder.."/loss.mp3", "gware/"..bossfolder.."/win.mp3", "gware/"..bossfolder.."/rage.mp3", "Luka will sing, causing any players near her to lose health.", "Vocaloid", function(ply)
	timer.Create("luka.rage", 1, 10, function()
		local scream = util.TraceLine({
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
			filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
		})

		for _, victim in ipairs(team.GetPlayers(1)) do
			if !victim:Alive() then return end
			
			victim.Distance = ((victim:GetPos() - scream.StartPos):Cross(victim:GetPos() - scream.HitPos)):Length() / scream.HitPos:Length(scream.StartPos)
			
			if victim.Distance < 50 then
				victim:SetHealth(victim:Health() - 5)
				
				if victim:Health() <= 0 then
					victim:Kill()
				end
			end
		end
	end)
	
	ply:SetRage(0)
end)

if SERVER then
	resource.AddFile("sound/gware/"..bossfolder.."/intro.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/loss.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/rage.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/win.mp3")
	
	resource.AddFile("models/player/lukap.mdl")
	
	resource.AddFile( "materials/lukamegurinetexture/expression.vmt" )
	resource.AddFile( "materials/lukamegurinetexture/expression.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/eyeball.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/glove_shoes.vmt" )
	resource.AddFile( "materials/lukamegurinetexture/glove_shoes.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/glove_shoesnormalmap.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/hair.vmt" )
	resource.AddFile( "materials/lukamegurinetexture/hair.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/hairnormalmap.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/iris_l.vmt" )
	resource.AddFile( "materials/lukamegurinetexture/iris_l.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/iris_r.vmt" )
	resource.AddFile( "materials/lukamegurinetexture/iris_r.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/lukahead.vmt" )
	resource.AddFile( "materials/lukamegurinetexture/lukahead.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/lukaheadnormalmap.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/lukainnercloth.vmt" )
	resource.AddFile( "materials/lukamegurinetexture/lukainnercloth.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/lukainnerclothnormalmap.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/lukaoutercloth.vmt" )
	resource.AddFile( "materials/lukamegurinetexture/lukaoutercloth.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/lukaouterclothnormalmap.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/lukaskin.vmt" )
	resource.AddFile( "materials/lukamegurinetexture/lukaskin.vtf" )
	resource.AddFile( "materials/lukamegurinetexture/lukaskinnormalmap.vtf" )
end