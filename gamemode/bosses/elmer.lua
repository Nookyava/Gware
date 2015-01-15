local bossfolder = "elmer"

GM:AddBoss("Elmer J. Fapp", "models/player/monk.mdl", 1000, "gware/"..bossfolder.."/intro.mp3", "gware/"..bossfolder.."/loss.mp3", "gware/"..bossfolder.."/win.mp3", "gware/"..bossfolder.."/rage.mp3", "Elmer launches himself into the air, slamming back down.", "Kitty0706's Videos", function(ply)
	ply:SetVelocity(Vector(0, 0, 2000))
	
	timer.Simple(2, function()
		ply.CanElmerSlam = true
		ply:SetVelocity(Vector(0, 0, -2000))
	end)

	ply:SetRage(0)
end)

hook.Add("OnPlayerHitGround", "elmer.rage", function(ply, water, floater, speed)
	if ply.CanElmerSlam and speed > 2000 then
		local exp = ents.Create( "env_explosion" )
		exp:SetOwner(ply)
        exp:SetPos( ply:GetPos() )
        exp:Spawn()
        exp:SetKeyValue( "spawnflags", 144 ) //Setting the key values of the explosion 
		exp:SetKeyValue( "iMagnitude", 200 ) // Setting the damage done by the explosion
		exp:SetKeyValue( "iRadiusOverride", 512 ) // Setting the radius of the explosion 
        exp:Fire( "Explode", 0, 0 )
		
		ply.CanElmerSlam = false
	else
		ply.CanElmerSlam = false
	end
end)

if SERVER then
	resource.AddFile("sound/gware/"..bossfolder.."/intro.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/loss.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/rage.mp3")
	resource.AddFile("sound/gware/"..bossfolder.."/win.mp3")
end