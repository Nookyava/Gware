
if SERVER then
   AddCSLuaFile( "shared.lua" )
   
   resource.AddSingleFile( "materials/emp/icon_hook.vtf" )
   resource.AddSingleFile( "materials/emp/icon_hook.vmt" )
end

if CLIENT then
   SWEP.PrintName = "Grappling Hook"

   SWEP.Slot = 3
end


SWEP.Base				= "weapon_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Primary.Ammo = "Grappling Hooks"
SWEP.Primary.Damage = 0
SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.75
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.AutoSpawnable      = false
SWEP.AmmoEnt = ""
SWEP.HoldType = "revolver"
SWEP.ViewModelFOV = 75
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.Primary.Sound			= Sound( "weapons/Irifle/irifle_fire2.wav" )
SWEP.Primary.Recoil			= 0

function SWEP:SetupDataTables()
   self:DTVar("Int", 0, "charge")
   self:DTVar("Int", 1, "status")
   self:DTVar("Entity", 0, "hook")

   //wreturn self.BaseClass.SetupDataTables(self)
end

function SWEP:Reload()
end


function SWEP:CanPrimaryAttack()
   return (self.dt.status==2 and CurTime()>self:GetNextPrimaryFire())
end

function SWEP:Deploy()
   return self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
	if not IsValid( self.Owner ) then return end
	if self.dt.status~=2 then return end
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if SERVER then
		local tr = self.Owner:GetEyeTrace()
		
		if tr.HitSky or (not tr.Hit) then return end
		if IsValid(tr.Entity) and tr.Entity:IsPlayer() and ((tr.Distance or 0)>1000) then return end
		
		self.Hooked = tr.Entity
		self.dt.status = 0
		
		if IsValid( self.Hooked ) then self.Hooked:TakeDamage(1, self.Owner, self) end
		if IsValid(self.dt.hook) then
			self.dt.hook:Remove()
		end
		
		local h = ents.Create( "prop_physics" )
		if IsValid(h) then
			self.dt.hook = h
			h:SetModel( "models/props_junk/harpoon002a.mdl" )
			
			local a = tr.HitNormal:Angle() a.p = a.p+180
			h:SetAngles( a )
			h:SetPos( tr.HitPos )
			h:SetModelScale( 0.3, 0 )
			h:Spawn()
			h:SetMoveType( MOVETYPE_NOCLIP )
			h:SetCollisionGroup( COLLISION_GROUP_WORLD )
			h:SetSolid( SOLID_NONE )
			
			h:EmitSound( "weapons/crossbow/hit1.wav" )
			
			if IsValid( self.Hooked ) then
				h:SetParent( self.Hooked )
				h.Hooked = true
				self.MoveOwner = false
			else
				h.Hooked = false
				self.MoveOwner = true
			end
		end
	end
end
function SWEP:SecondaryAttack()
end

local PullBlacklist = {"func_door","prop_door_rotating","func_door_rotating", "prop_dynamic", "player"}
function SWEP:CanPull( ent )
	if not IsValid(ent) then return false end
	
	if table.HasValue(PullBlacklist, ent:GetClass()) then return false end
	if CLIENT then return true end
	
	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return false end
	
	return (IsValid(phys) and phys:IsMoveable() and (not phys:HasGameFlag(FVPHYSICS_PLAYER_HELD)))
end

if SERVER then
	function SWEP:Initialize()
		self.dt.charge = 40
		self.dt.status = 1
		
		local TimerName = self:EntIndex().." Grappling Hook Charging Timer"
		timer.Create( TimerName, 0.1, 0, function() --Should also work when the SWEP is holstered. SWEP:Think only runs if it's active
			if IsValid( self ) then self:DoCharge() else timer.Remove( TimerName ) end
		end)
		hook.Add( "Move", self, self.PlayerMove )
		
		return self.BaseClass.Initialize( self )
	end
	
	function SWEP:DoCharge()
		if self.dt.status==1 then
			if IsValid( self.dt.hook ) then self.dt.hook:Remove() end
			self.dt.charge = math.Approach( self.dt.charge, 40, 1 )
			
			if self.dt.charge==40 then self.dt.status = 2 end
		elseif self.dt.status==0 then
			self.dt.charge = math.Approach( self.dt.charge, 0, 1 )
			
			if self.dt.charge==0 then
				self.dt.status = 1
				if IsValid( self.dt.hook ) then self.dt.hook:Remove() end
			end
		else
			if IsValid( self.dt.hook ) then self.dt.hook:Remove() end
		end
	end
	
	local function ForceJump( ply )
		if not IsValid(ply) then return end
		if not ply:OnGround() then return end
		
		local tr = util.TraceLine( {start = ply:GetPos(), endpos = ply:GetPos()+Vector(0,0,20), filter = ply} )
		if tr.Hit then return end
		
		ply:SetPos(ply:GetPos()+Vector(0,0,5) )
	end
	
	function SWEP:Think()
		if self.dt.status ~= 0 then return end
		if not self.Owner then return end
		
		if not self.Owner:KeyDown( IN_ATTACK ) then
			self.dt.status = 1
			if IsValid(self.dt.hook) then self.dt.hook:Remove() end
			return
		end
		
		local phys
		if IsValid( self.Hooked ) then phys = self.Hooked:GetPhysicsObject() end
		
		if self:CanPull( self.Hooked ) then
			self.MoveOwner = false
		elseif self.dt.hook.Hooked then
			self.MoveOwner = true
			if not IsValid(self.Hooked) then
				self.MoveOwner = false
				self:EmitSound( "physics/cardboard/cardboard_box_break2.wav" )
				self.dt.status = 1
				
				if IsValid(self.dt.hook) then self.dt.hook:Remove() end
			end
		else
			self.MoveOwner = true
		end
		
		if self.ForceJump then ForceJump( self.ForceJump ) self.ForceJump = nil end --Doesn't work in PlayerMove
	end
	
	function SWEP:PlayerMove( ply, data )
		if self.dt.status ~= 0 then return nil end
		if not IsValid( self.dt.hook ) then self.dt.status = 1 return end
		
		if ply==self.Owner then
			if self.MoveOwner then --Move ourself
				local TargetDir = (self.dt.hook:GetPos() - self.Owner:EyePos()):GetNormal()*400
				TargetDir[3] = (TargetDir[3]/400)*200
				local dir = data:GetVelocity()
				
				if self.dt.hook:GetPos()[3]> (ply:GetPos()[3]+70) then self.ForceJump=ply end
				
				dir[1] = math.Approach(dir[1], TargetDir[1], 60)
				dir[2] = math.Approach(dir[2], TargetDir[2], 60)
				if (TargetDir[3]>0) or (dir[3] > TargetDir[3]) then dir[3] = math.Approach(dir[3], TargetDir[3], 20) end
				
				data:SetVelocity( dir )
				return
			elseif self:CanPull( self.Hooked ) then --Move a prop
				if self.Hooked:IsPlayer() then return end
				
				local phys = self.Hooked:GetPhysicsObject()
				if (not IsValid(phys)) or (phys:GetPos():Distance(self:GetPos())<75 and self.Hooked:GetClass()~="prop_ragdoll") then return end
				
				local TargetDir
				if IsValid( self.Owner ) then TargetDir = (self.Owner:EyePos() - self.dt.hook:GetPos()):GetNormal()*400 else TargetDir = (self:GetPos() - self.dt.hook:GetPos()):GetNormal()*400 end
				if self.Hooked:GetClass()=="prop_ragdoll" then
					TargetDir[3] = (TargetDir[3]/600)*450
				else
					TargetDir[3] = (TargetDir[3]/600)*300
				end
				local dir = phys:GetVelocity()
				
				dir[1] = math.Approach(dir[1], TargetDir[1], 600/(phys:GetMass()/4))
				dir[2] = math.Approach(dir[2], TargetDir[2], 600/(phys:GetMass()/4))
				if (TargetDir[3]>0) or (dir[3] > TargetDir[3]) then
					if self.Hooked:GetClass()=="prop_ragdoll" then
						dir[3] = math.Approach(dir[3], TargetDir[3], 350/(phys:GetMass()/4))
					else
						dir[3] = math.Approach(dir[3], TargetDir[3], 200/(phys:GetMass()/4))
					end
				end
				
				phys:SetVelocityInstantaneous( dir )
			end
		elseif ply==self.Hooked then --Move a player
			local TargetDir
			if IsValid( self.Owner ) then TargetDir = (self.Owner:EyePos() - self.dt.hook:GetPos()):GetNormal()*400 else TargetDir = (self:GetPos() - self.dt.hook:GetPos()):GetNormal()*400 end
			TargetDir[3] = (TargetDir[3]/400)*200
			local dir = data:GetVelocity()
			
			if self.Owner:EyePos()[3]> (self.dt.hook:GetPos()[3]+70) then self.ForceJump=ply end
			
			dir[1] = math.Approach(dir[1], TargetDir[1], 60)
			dir[2] = math.Approach(dir[2], TargetDir[2], 60)
			if (TargetDir[3]>0) or (dir[3] > TargetDir[3]) then dir[3] = math.Approach(dir[3], TargetDir[3], 20) end
			
			data:SetVelocity( dir )
			ply.was_pushed = {att=self.Owner, t=CurTime()}
			return
		end
	end
end

function SWEP:Holster()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	if SERVER then
		if self.dt.status==0 then self.dt.status=1 end
		if IsValid(self.dt.hook) then self.dt.hook:Remove() end
		self.Hooked = nil
	end
	
	return self.BaseClass.Holster( self )
end
function SWEP:OnRemove()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return self.BaseClass.OnRemove( self )
end
function SWEP:OnDrop()
	if SERVER then
		if self.dt.status==0 then self.dt.status=1 end
		if IsValid(self.Hook) then self.Hook:Remove() end
		self.Hook = nil
		self.Hooked = nil
	end
	
	return self.BaseClass.OnDrop( self )
end

----------------------------------
--- SWEP CONSTRUCTION KIT CODE ---
----------------------------------

if CLIENT then
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false
	SWEP.ViewModelBoneMods = {
		["v_weapon.famas"] = { scale = Vector(0.05, 0.05, 0.05), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}

	local ColCharging = Color(150,150,50)
	local ColActive = Color( 250, 50, 50 )
	local ColPull = Color( 100, 100, 250 )
	local ColReady = Color(50, 250, 50)
	SWEP.VElements = {
		["Hook"] = { type = "Model", model = "models/props_junk/harpoon002a.mdl", bone = "v_weapon", rel = "Barrel", pos = Vector(0, 0.2, 3.4), angle = Angle(-90, 0, 180), size = Vector(0.1, 0.1, 0.2), NormalSize = Vector(0.1, 0.1, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["ScreenBase"] = { type = "Model", model = "models/props_combine/combine_intmonitor003.mdl", bone = "v_weapon", rel = "Back", pos = Vector(-2, -2, -1.15), angle = Angle(-52.16, -90, -90), size = Vector(0.05, 0.05, 0.05), color = Color(70, 70, 70, 255), surpresslightning = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
		["Back"] = { type = "Model", model = "models/hunter/blocks/cube075x1x075.mdl", bone = "v_weapon", rel = "Main", pos = Vector(0, 4, 0), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.1), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["Main"] = { type = "Model", model = "models/hunter/blocks/cube05x1x05.mdl", bone = "v_weapon.famas", rel = "", pos = Vector(0.3, 0, 14), angle = Angle(1, 0, 80), size = Vector(0.059, 0.059, 0.059), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["Screen"] = { type = "Quad", bone = "v_weapon", rel = "ScreenBase", pos = Vector(1.2, -0.201, 1.2), angle = Angle(-90, 180, 180), size = 0.02, draw_func = function( self )
			draw.RoundedBox( 4, -55, -30, 110, 80, Color(150,175,255,10) )
			draw.SimpleText( "Status", "TargetID", 0, -25, Color(255,255,255,255), TEXT_ALIGN_CENTER )

			draw.RoundedBox( 0, -35, -10, 70, 15, Color(0,0,0,150) )
			draw.RoundedBox( 0, -34, -9, 68, 13, Color(255,255,255,50) )
			draw.RoundedBox( 0, -34, -9, 68*(self.dt.charge/40), 13, Color(0,255,0,255) )
			
			local Active = self.dt.status==0
			local Charging = not self:CanPrimaryAttack()
			draw.SimpleText( (Active and "Deployed") or (Charging and "Charging") or "Ready", "TargetID", 0, 5, (Active and ColActive) or (Charging and ColCharging) or ColReady, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			
			if self.dt.status~=0 then
				if not IsValid( self.Owner ) then return end
				local tr = self.Owner:GetEyeTrace()
				local TargetPullable = self:CanPull( tr.Entity )
				draw.SimpleText( (TargetPullable and "Pull") or "Approach", "TargetID", 0, 20, (TargetPullable and ColPull) or ColReady, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			end
		end},
		["dec_Main001"] = { type = "Model", model = "models/props_combine/weaponstripper.mdl", bone = "v_weapon", rel = "Main", pos = Vector(-0.49, 0.3, -0.7), angle = Angle(-85, 0, 0), size = Vector(0.009, 0.025, 0.009), color = Color(0, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["Barrel"] = { type = "Model", model = "models/hunter/tubes/tube1x1x4.mdl", bone = "v_weapon", rel = "Main", pos = Vector(0, -4, 0), angle = Angle(0, 0, 90), size = Vector(0.019, 0.019, 0.019), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["dec_Back002"] = { type = "Model", model = "models/props_combine/advisorpod_docked.mdl", bone = "v_weapon", rel = "Back", pos = Vector(1, -0.5, -0.301), angle = Angle(164.658, 0, 90), size = Vector(0.009, 0.009, 0.012), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["dec_Back001"] = { type = "Model", model = "models/props_lab/generatorconsole.mdl", bone = "v_weapon", rel = "Back", pos = Vector(-0.201, 0.1, 0.899), angle = Angle(180, -90, -90), size = Vector(0.045, 0.045, 0.045), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["dec_Main002"] = { type = "Model", model = "models/props_combine/combine_intwallunit.mdl", bone = "v_weapon", rel = "Main", pos = Vector(0.699, 0, 0.2), angle = Angle(0, 0, 0), size = Vector(0.05, 0.07, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	SWEP.WElements = {
		["Hook"] = { type = "Model", model = "models/props_junk/harpoon002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Barrel", pos = Vector(0, 0.2, 3.4), angle = Angle(-90, 0, 180), size = Vector(0.1, 0.1, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["ScreenBase"] = { type = "Model", model = "models/props_combine/combine_intmonitor003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Back", pos = Vector(-2, -2, -1.15), angle = Angle(-52.16, -90, -90), size = Vector(0.05, 0.05, 0.05), color = Color(70, 70, 70, 255), surpresslightning = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} },
		["Back"] = { type = "Model", model = "models/hunter/blocks/cube075x1x075.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Main", pos = Vector(0.6, 3.799, -0.601), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.1), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["Handle"] = { type = "Model", model = "models/hunter/tubes/tubebend2x2x90outer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Back", pos = Vector(-1, 2, 2), angle = Angle(0, 0, 90), size = Vector(0.029, 0.029, 0.029), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["Main"] = { type = "Model", model = "models/hunter/blocks/cube05x1x05.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(11, 2, -3), angle = Angle(0, -90, -3.069), size = Vector(0.059, 0.059, 0.059), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["Screen"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "ScreenBase", pos = Vector(1.2, -0.201, 1.2), angle = Angle(-90, 180, 180), size = 0.02, draw_func = function( self )
			draw.RoundedBox( 4, -55, -30, 110, 80, Color(150,175,255,10) )
			draw.SimpleText( "Status", "TargetID", 0, -20, Color(255,255,255,255), TEXT_ALIGN_CENTER )

			draw.RoundedBox( 0, -35, -5, 70, 15, Color(0,0,0,150) )
			draw.RoundedBox( 0, -34, -4, 68, 13, Color(255,255,255,50) )
			draw.RoundedBox( 0, -34, -4, 68*(self.dt.charge/40), 13, Color(0,255,0,255) )
			
			local Active = self.dt.status==0
			local Charging =  self.dt.status==1
			draw.SimpleText( (Active and "Deployed") or (Charging and "Charging") or "Ready", "TargetID", 0, 10, (Active and ColActive) or (Charging and ColCharging) or ColReady, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		end},
		["dec_Back002+"] = { type = "Model", model = "models/props_combine/advisorpod_docked.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Back", pos = Vector(1, -0.5, -0.301), angle = Angle(164.658, 0, 90), size = Vector(0.009, 0.009, 0.012), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["dec_Main001"] = { type = "Model", model = "models/props_combine/weaponstripper.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Main", pos = Vector(-0.601, 0.3, -0.7), angle = Angle(-90, 0, 0), size = Vector(0.009, 0.025, 0.009), color = Color(0, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["Barrel"] = { type = "Model", model = "models/hunter/tubes/tube1x1x4.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Main", pos = Vector(0, -4, 0), angle = Angle(0, 0, 90), size = Vector(0.019, 0.019, 0.019), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["dec_Main002+"] = { type = "Model", model = "models/props_combine/combine_intwallunit.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Main", pos = Vector(-0.7, 0, 0), angle = Angle(-180, 0, 0), size = Vector(0.05, 0.07, 0.039), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["dec_Main002"] = { type = "Model", model = "models/props_combine/combine_intwallunit.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Main", pos = Vector(0.699, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.05, 0.07, 0.039), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["dec_Back001"] = { type = "Model", model = "models/props_lab/generatorconsole.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Back", pos = Vector(-0.201, 0.1, 0.899), angle = Angle(180, -90, -90), size = Vector(0.045, 0.045, 0.045), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["dec_Back002"] = { type = "Model", model = "models/props_combine/advisorpod_docked.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "Back", pos = Vector(-2, -0.5, -0.301), angle = Angle(-7.159, 0, 90), size = Vector(0.009, 0.009, 0.012), color = Color(50, 50, 50, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	
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
	local HookCable = Material( "cable/blue_elec" )
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
				if name=="Hook" then
					local scale = (self.dt.status==0 and 0) or (self.dt.charge/100)
					v.color.a= 255*scale
					v.size = v.NormalSize * scale
				end
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
				
				if name=="Hook" and IsValid(self.dt.hook) then
					render.SetMaterial( HookCable )
					render.DrawBeam( self.dt.hook:GetPos(),
						model:GetPos() + ang:Forward() * 3.5, 1, CurTime(), CurTime()+2, Color(255,255,255,255) )
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
				
				if name=="Hook" and IsValid(self.dt.hook) then
					render.SetMaterial( HookCable )
					render.DrawBeam( self.dt.hook:GetPos(),
						model:GetPos(), 1, 0, 2, Color(255,255,255,255) )
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