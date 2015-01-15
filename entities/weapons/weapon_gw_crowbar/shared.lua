if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType			= "fist"

if CLIENT then
   SWEP.PrintName = "Crowbar"

   SWEP.Slot = 1
end

SWEP.Spawnable	= true
SWEP.UseHands	= true
SWEP.DrawAmmo	= false

SWEP.ViewModel	= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"

SWEP.ViewModelFOV	= 52
SWEP.Slot			= 0
SWEP.SlotPos		= 5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

//local SwingSound = Sound( "weapons/slam/throw.wav" )
local HitSound = Sound( "Flesh.ImpactHard" )

function SWEP:Initialize()
	self:SetWeaponHoldType( "fist" )
	self.Owner.CanRage = true
end

function SWEP:PrimaryAttack()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	//self:EmitSound( SwingSound )
	
	self:SetNextPrimaryFire( CurTime() + 1.5 )
	self:SetNextSecondaryFire( CurTime() + 0.9 )
	
	//self:AttackPlayer()
end

function SWEP:SecondaryAttack()
	if CLIENT or GAMEMODE:GetRound() != ROUND_ACTIVE then return end

	GAMEMODE:Rage(self.Owner)
	self:SetNextSecondaryFire( CurTime() + 0.9 )
end

//function SWEP:AttackPlayer()
//	if SERVER then
//		local tracedata = {}
//	
//		self.Owner:LagCompensation(true)
//		tracedata.start = self.Owner:GetShootPos()
//		tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 50)
//		tracedata.filter = self.Owner
//		tracedata.mins = Vector( -10,-10,-10 )
//		tracedata.maxs = Vector( 10,10,10 )
//		tracedata.mask = MASK_SHOT_HULL
//		local tr = util.TraceHull( tracedata )
//		local victim = tr.Entity
//		local dmginfo = DamageInfo()
//		
//		if tr.Hit then self.Owner:EmitSound( HitSound ) end
//		
//		
//		if victim:IsPlayer() then
//			dmginfo:SetAttacker(self.Owner)
//			dmginfo:SetInflictor(self)
//			dmginfo:SetDamage(35)
//			victim:TakeDamageInfo(dmginfo)
//		end
//		self.Owner:LagCompensation(false)
//	end
//end