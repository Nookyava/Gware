if SERVER then
	resource.AddFile("sound/gware/hacks01.wav")
end

local function PCThrow(ply)
	if SERVER then
		if ply:Alive() and ply:Team() == TEAM_BOSS then
			local pc = ents.Create("prop_physics")
			pc:SetModel("models/props_lab/monitor02.mdl")
			pc:SetPos( ply:EyePos() + ( ply:GetAimVector() * 20 ) )
			pc:SetAngles( ply:EyeAngles() )
			pc:Spawn()
			
			local phys = pc:GetPhysicsObject()
			if (  !IsValid( phys ) ) then pc:Remove() return end
			
			local velocity = ply:GetAimVector()
			velocity = velocity * 100000
			velocity = velocity + ( VectorRand() * 10 ) -- a random element
			phys:ApplyForceCenter( velocity )
			
			timer.Simple(10, function()
				pc:Remove()
			end)
		else
			timer.Stop("drhax.rage")
		end
	end
end

GM:AddBoss("Dr. Hax", "models/player/breen.mdl", 800, "gware/hacks01.wav", "gware/hacks01.wav", "gware/hacks01.wav", "gware/hacks01.wav", "Dr. Hax throws computers at players, killing them upon impact.", "G-mod Idiot Box", function(ply)
	timer.Create("drhax.rage", 0.2, 5, function()
		PCThrow(ply)
	end)
	
	ply:SetRage(0)
end)