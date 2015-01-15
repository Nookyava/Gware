if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then
	SWEP.PrintName = "Fire Xbow"
	SWEP.Author = "Nookyava"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
end

-- BASE --
SWEP.Base = "weapon_base"
SWEP.HoldType = "crossbow"

-- SPAWNWABLE? --
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- MODELS --
SWEP.ViewModel = "models/weapons/v_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"

-- SWITCH TO AUTO --
SWEP.Weight = 5
SWEP.AutoSwitchTo = true

-- AMMO --
SWEP.Primary.NumShots = 1
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 5
SWEP.Primary.ClipMax = 10

-- BULLET STATS/INFO --
SWEP.Primary.Sound = Sound( "Weapon_Crossbow.Single" )
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Damage = 100	
SWEP.Primary.Cone = 0.008
SWEP.Primary.Delay = 1.0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "XBowBolt"

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	self:EmitSound( self.Primary.Sound )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:DoAnimationEvent(PLAYER_ATTACK1)
	
	self:SetNextPrimaryFire( CurTime() + 0.9 )
	self:SetNextSecondaryFire( CurTime() + 0.9 )
	
	self:TakePrimaryAmmo(1)
	
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK )
	self:ShootBullet(50, 1, 0)
end

function SWEP:CanPrimaryAttack()
	if self.Weapon:Clip1() <= 0 then
		self:EmitSound("weapons/pistol/pistol_empty.wav")
		return false
	end
	
	return true
end

function SWEP:SecondaryAttack()
	
end

function SWEP:TakePrimaryAmmo(num)
	if CLIENT then return end
	if ( self.Weapon:Clip1() <= 0 ) then 
	
		if ( self:Ammo1() <= 0 ) then return end
		
		self.Owner:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
	
	return end
	
	self:SendWeaponAnim(ACT_VM_RELOAD)
	self.Weapon:SetClip1( self.Weapon:Clip1() - num )
	self:Reload()
end

function SWEP:ShootBullet(dmg, bullets, aim)
	local bolt = {}
	
	bolt.Num = bullets
	bolt.Src = self.Owner:GetShootPos()
	bolt.Dir = self.Owner:GetAimVector()
	bolt.Damage = dmg
	bolt.AmmoType = "XBowBolt"
	
	self.Owner:FireBullets(bolt)
	self:ShootEffects()
	
	if CLIENT then return end
	
	local eyetrace = self.Owner:GetEyeTrace()
	
	local explode = ents.Create("env_explosion")
	explode:SetPos( eyetrace.HitPos )
	explode:SetOwner( self.Owner )
	explode:Spawn()
	explode:SetKeyValue("iMagnitude","50")
	explode:Fire("Explode", 0, 0 )
end

----------------------------------
--- SWEP CONSTRUCTION KIT CODE ---
----------------------------------


//****PASTE WEAPON CODE HERE****\\
SWEP.HoldType = "crossbow"
SWEP.ViewModelFOV = 43.385826771654
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_crossbow_dx7.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {
	["Crossbow_model.bolt"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

//****PASTE IRONSIGHTS HERE****\\
SWEP.IronSightsPos = Vector(-7, -10.693, 3.17)
SWEP.IronSightsAng = Vector(0, 0, 0)

//****PASTE VIEW MODEL TABLE HERE****\\
SWEP.VElements = {
	["arrow"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "Crossbow_model.bolt", rel = "", pos = Vector(0, 0.455, -1.364), angle = Angle(0, 0, 0), size = Vector(0.05, 0.05, 0.209), color = Color(255, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["flare+"] = { type = "Model", model = "models/Items/Flare.mdl", bone = "Crossbow_model.Crossbow_base", rel = "", pos = Vector(1.25, -0, 7), angle = Angle(0, 37.84, -15.341), size = Vector(0.264, 0.264, 0.264), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gas"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "Crossbow_model.Crossbow_base", rel = "", pos = Vector(1.363, -2.274, 0), angle = Angle(0, 0, 0), size = Vector(0.094, 0.094, 0.094), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["flare++"] = { type = "Model", model = "models/Items/Flare.mdl", bone = "Crossbow_model.Crossbow_base", rel = "", pos = Vector(1.25, -0, 5.4), angle = Angle(0, 37.84, -15.341), size = Vector(0.264, 0.264, 0.264), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["flare"] = { type = "Model", model = "models/Items/Flare.mdl", bone = "Crossbow_model.Crossbow_base", rel = "", pos = Vector(1.25, -0, 8.635), angle = Angle(0, 37.84, -15.341), size = Vector(0.264, 0.264, 0.264), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

//****PASTE WORLD MODEL TABLE HERE****\\
SWEP.WElements = {
	["arrow"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(16, -0.7, -4), angle = Angle(89.599, 9.6, 0), size = Vector(0.07, 0.07, 0.189), color = Color(255, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["flare+"] = { type = "Model", model = "models/Items/Flare.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(12.088, 1.422, -2.5), angle = Angle(36.799, 0, 91.199), size = Vector(0.264, 0.264, 0.264), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["gas"] = { type = "Model", model = "models/props_junk/gascan001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.689, 2.299, -4.268), angle = Angle(0, 97.599, 90), size = Vector(0.094, 0.094, 0.094), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["flare++"] = { type = "Model", model = "models/Items/Flare.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(13, 1.299, -2.5), angle = Angle(36.799, 0, 91.199), size = Vector(0.264, 0.264, 0.264), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["flare"] = { type = "Model", model = "models/Items/Flare.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(11.199, 1.6, -2.5), angle = Angle(36.799, 0, 91.199), size = Vector(0.264, 0.264, 0.264), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end
function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then
	function SWEP:Initialize()
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
			
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
					
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
		return self.BaseClass.Initialize( self )
	end
	

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			if ((LocalPlayer():GetObserverTarget() == self.Owner) and (LocalPlayer():GetObserverMode()== OBS_MODE_IN_EYE)) then return end
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end

		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end