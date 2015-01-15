ENT.Type = "anim"
ENT.Base = "base_gmodentity" 

if SERVER then
	AddCSLuaFile()
end

function ENT:Initialize()
	self:SetModel("models/props_phx/construct/plastic/plastic_angle_360.mdl")
	self.AmmoM = "models/items/357ammo.mdl"
	self:SetMaterial("hunter/myplastic")
	self:SetModelScale(0.5, 0)
	self:SetSolid( SOLID_OBB )
	self:SetColor(Color(255,255,255,5))
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
end

function math.RotationalYaw( _speed )
	local _yaw = ( RealTime( ) * ( _speed or 180 ) ) % 360;
	_yaw = math.NormalizeAngle( _yaw );

	return _yaw;
end

function math.sinwave( _speed, _size, _abs )
	local _sin = math.sin( RealTime( ) * ( _speed or 1 ) ) * ( _size or 1 );

	if ( _abs ) then _sin = math.abs( _sin ); end

	return _sin;
end

if SERVER then
	function ENT:Use(activator, caller)
		if activator:IsValid() and activator:IsPlayer() then
			local wep = activator:GetActiveWeapon()
			if wep:IsValid() then
				activator:GiveAmmo(40, wep:GetPrimaryAmmoType())
				self:Remove()
			end
		end
	end
	
	function ENT:Touch(ent)
		if ent:IsValid() and ent:IsPlayer() then
			local wep = ent:GetActiveWeapon()
			if wep:IsValid() then
				ent:GiveAmmo(40, wep:GetPrimaryAmmoType())
				self:Remove()
			end
		end
	end
else
	function ENT:Draw()
		local l = DynamicLight( self:EntIndex() )
		l.Pos = self:GetPos() + Vector(0, 0, 5)
		l.r = 61
		l.g = 210
		l.b = 238
		l.Brightness = 0.1
		l.Decay = 500
		l.Size = 250
		l.DieTime = CurTime() + 1
		
		local _sin = math.sinwave( 3, 5 );
		local _yaw = math.RotationalYaw( 60 )
		
		self.weapon = ClientsideModel(self.AmmoM, RENDERGROUP_OPAQUE)
		self.weapon:SetRenderOrigin(self:GetPos()+Vector(0,0,math.sinwave(3,5)) + Vector(0, 0, 35))
		self.weapon:SetAngles(Angle( 0, _yaw, 0 ))
		self.weapon:DrawModel()
		self.weapon:Remove()
	
		
		self:DrawModel()
	end
end