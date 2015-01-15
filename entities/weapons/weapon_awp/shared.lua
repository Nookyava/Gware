if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

if ( CLIENT ) then
	SWEP.PrintName = "AWP"
	SWEP.Author = "Nookyava"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
end

-- BASE --
SWEP.Base = "weapon_base"
SWEP.HoldType = "crossbow"
SWEP.ViewModelFlip = true

-- SPAWNWABLE? --
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- MODELS --
SWEP.ViewModel = "models/weapons/v_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"

-- SWITCH TO AUTO --
SWEP.Weight = 5
SWEP.AutoSwitchTo = true

-- AMMO --
SWEP.Primary.NumShots = 2
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 5
SWEP.Primary.ClipMax = 10

-- BULLET STATS/INFO --
SWEP.Primary.Sound = Sound( "weapons/AWP/awp1.wav" )
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Damage = 100	
SWEP.Primary.Cone = 0.008
SWEP.Primary.Delay = 1.0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"

-- SCOPE --
SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos      = Vector( 5, -15, -2 )
SWEP.IronSightsAng      = Vector( 2.6, 1.37, 3.5 )

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
	if self:GetNextSecondaryFire() > CurTime() then return end
	
	if(!self.IsScoping) then
		if(SERVER) then
			self.Owner:SetFOV( 30, 0 )
		end
		
		self.IsScoping = true
	elseif (self.IsScoping) then
		if(SERVER) then
			self.Owner:SetFOV( 0, 0 )
		end
		
		self.IsScoping = false
	end
	
	self:SetNextSecondaryFire( CurTime() + 0.3)
end

if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
		if self.IsScoping then
			surface.SetDrawColor( 0, 0, 0, 255 )
         
			local x = ScrW() / 2.0
			local y = ScrH() / 2.0
			local scope_size = ScrH()
	
			-- crosshair
			local gap = 80
			local length = scope_size
			surface.DrawLine( x - length, y, x - gap, y )
			surface.DrawLine( x + length, y, x + gap, y )
			surface.DrawLine( x, y - length, x, y - gap )
			surface.DrawLine( x, y + length, x, y + gap )
	
			gap = 0
			length = 50
			surface.DrawLine( x - length, y, x - gap, y )
			surface.DrawLine( x + length, y, x + gap, y )
			surface.DrawLine( x, y - length, x, y - gap )
			surface.DrawLine( x, y + length, x, y + gap )
	
	
			-- cover edges
			local sh = scope_size / 2
			local w = (x - sh) + 2
			surface.DrawRect(0, 0, w, scope_size)
			surface.DrawRect(x + sh - 2, 0, w, scope_size)
	
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawLine(x, y, x + 1, y + 1)
	
			-- scope
			surface.SetTexture(scope)
			surface.SetDrawColor(255, 255, 255, 255)
	
			surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
		end
	end
end

function SWEP:TakePrimaryAmmo(num)
	if CLIENT then return end
	if ( self.Weapon:Clip1() <= 0 ) then 
	
		if ( self:Ammo1() <= 0 ) then return end
		
		self.Owner:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
	
	return end
	
	//self:SendWeaponAnim(ACT_VM_RELOAD)
	self.Weapon:SetClip1( self.Weapon:Clip1() - num )
	//self:Reload()
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
end