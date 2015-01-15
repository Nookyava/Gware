ENT.Type = "anim"
ENT.Base = "base_gmodentity" 

if SERVER then
	AddCSLuaFile()
end

function ENT:Initialize()
	self:SetModel("models/props_phx/construct/plastic/plastic_angle_360.mdl")
	self:SetMaterial("hunter/myplastic")
	self:SetModelScale(0.5, 0)
	self:SetSolid( SOLID_OBB )
	self:SetColor(Color(255,255,255,0))
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
end