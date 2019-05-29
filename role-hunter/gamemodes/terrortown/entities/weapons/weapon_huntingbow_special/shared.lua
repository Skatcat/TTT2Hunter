SWEP.Base = "weapon_tttbase"


SWEP.AdminSpawnable= true
SWEP.HoldType = "normal"
SWEP.AmmoEnt = "item_ammo_357_ttt"
SWEP.Spawnable = true
 
SWEP.Kind = WEAPON_EQUIP1
SWEP.Slot = 6

SWEP.PrintName = "Ranger Bow"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""

local autoSpawnBow = CreateConVar("ttt_huntingbow_do_autospawn", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the Traitor be able to use the Second Chance.")

if(autoSpawnBow:GetBool()) then
	SWEP.AutoSpawnable = false
else 
	SWEP.AutoSpawnable = false
	SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = [[
	
	Use the bow to hunt down
	your enemies!
	
	]]
	}
	SWEP.LimitedStock = false
end

if( CLIENT ) then
    SWEP.PrintName = "Ranger Bow";
    SWEP.Slot = 2;
    SWEP.DrawAmmo = true;
    SWEP.DrawCrosshair = false;
    SWEP.Icon = "vgui/ttt/bowicon.png";
end

if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("vgui/ttt/bowicon.png")
end


SWEP.ViewModelFOV = 68
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_huntingbow.mdl")
SWEP.WorldModel = Model("models/weapons/w_huntingbow.mdl")

SWEP.AdminOnly = false

SWEP.Primary.Ammo       = "357"
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage = 35
SWEP.Primary.Delay = 0.3
SWEP.Primary.Cone = 0.001
SWEP.Primary.ClipSize = 1
SWEP.Primary.ClipMax = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.UseHands              = true
SWEP.IsSilent              = true

SWEP.m_WeaponDeploySpeed = 3

SWEP.STATE_NONE = 0
SWEP.STATE_NOCKED = 1
SWEP.STATE_PULLED = 2
SWEP.STATE_RELEASE = 3

SWEP.ActivitySound = {}
SWEP.ActivitySound[ACT_VM_PULLBACK] = "Weapon_HuntingBow.Pull"
SWEP.ActivitySound[ACT_VM_PRIMARYATTACK] = "Weapon_HuntingBow.Single"
SWEP.ActivitySound[ACT_VM_LOWERED_TO_IDLE] = "Weapon_HuntingBow.Nock"
SWEP.ActivitySound[ACT_VM_DRAW] = "Weapon_HuntingBow.Draw"
SWEP.ActivitySound[ACT_VM_RELEASE] = "Weapon_HuntingBow.Pull"

SWEP.ActivityLength = {}
SWEP.ActivityLength[ACT_VM_PULLBACK] = 0.2
SWEP.ActivityLength[ACT_VM_PRIMARYATTACK] = 0.25
SWEP.ActivityLength[ACT_VM_DRAW] = 0.2
SWEP.ActivityLength[ACT_VM_RELEASE] = 0.5
SWEP.ActivityLength[ACT_VM_LOWERED_TO_IDLE] = 1
SWEP.ActivityLength[ACT_VM_IDLE_TO_LOWERED] = 0.25

SWEP.HoldTypeTranslate = {}
SWEP.HoldTypeTranslate[SWEP.STATE_NONE] = "normal"
SWEP.HoldTypeTranslate[SWEP.STATE_NOCKED] = "pistol"
SWEP.HoldTypeTranslate[SWEP.STATE_PULLED] = "revolver"
SWEP.HoldTypeTranslate[SWEP.STATE_RELEASE] = "grenade"

sound.Add {
	channel = CHAN_AUTO,
	volume = 0.2,
	level = 60,
	name = "Weapon_HuntingBow.Draw",
	sound = { "weapons/huntingbow/draw_1.wav", "weapons/huntingbow/draw_2.wav" }
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 0.4,
	level = 60,
	name = "Weapon_HuntingBow.Nock",
	sound = { "weapons/huntingbow/nock_1.wav", "weapons/huntingbow/nock_2.wav", "weapons/huntingbow/nock_3.wav" }
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 0.3,
	level = 60,
	name = "Weapon_HuntingBow.Pull",
	sound = { "weapons/huntingbow/pull_1.wav", "weapons/huntingbow/pull_2.wav", "weapons/huntingbow/pull_3.wav" }
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 1,
	level = 60,
	name = "Weapon_HuntingBow.Single",
	sound = { "weapons/huntingbow/shoot_1.wav", "weapons/huntingbow/shoot_2.wav", "weapons/huntingbow/shoot_3.wav" }
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 1,
	level = 60,
	name = "Weapon_HuntingBow.ZoomIn",
	sound = "weapons/huntingbow/zoomin.wav"
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 1,
	level = 60,
	name = "Weapon_HuntingBow.ZoomOut",
	sound = "weapons/huntingbow/zoomout.wav"
}

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "WepState")
end

function SWEP:PrimaryAttack()
	return
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Reload()
	return
end

function SWEP:EmitSoundX(...)
	if (game.SinglePlayer() and SERVER) or (CLIENT and IsFirstTimePredicted()) then
		return self:EmitSound(...)
	end
end

function SWEP:PlayActivity(act)
	self:SendWeaponAnim(act)

	local snd = self.ActivitySound[act]
	if snd then
		self:EmitSoundX(snd)
	end

	local t = self.ActivityLength[act]
	if t then
		self:SetNextPrimaryFire(CurTime() + t)
	end
end

function SWEP:Ammo1()
	return self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
end

SWEP.ShakeBeginTime = 500
SWEP.ShakeLength = 5

SWEP.ShakeX = 0
SWEP.ShakeY = 0

local sin, cos = math.sin, math.cos

function SWEP:Think()
	local CT = CurTime()
	local nextFire = self:GetNextPrimaryFire()

	if self.dt.WepState == self.STATE_PULLED then
		local stamina  = math.Clamp(CT - self:GetNextSecondaryFire() - self.ShakeBeginTime, 0, self.ShakeLength) / self.ShakeLength
		local stamina2 = 1 - stamina ^ 3

		self.ShakeX = sin(CT * 3)      * 0.6 * stamina + sin(CT * 64)      * 0.2 * stamina ^ 3
		self.ShakeY = cos(CT * 2 + 45) * 0.6 * stamina + sin(CT * 58 + 45) * 0.2 * stamina ^ 3
	else
		self.ShakeX = 0
		self.ShakeY = 0
	end

	local holdType = self.HoldTypeTranslate[self.dt.WepState]
	if holdType ~= self:GetHoldType() then
		self:SetHoldType(holdType)
	end

	if nextFire >= CT then
		return
	end

	local noClip = self.Owner:GetMoveType() == MOVETYPE_NOCLIP
	local onGround = self.Owner:IsOnGround()

	if self.dt.WepState == self.STATE_PULLED then
		if self.Owner:KeyDown(IN_RELOAD) or self.Owner:KeyDown(IN_SPEED) or self:Clip1() <= 0 then
			self.dt.WepState = self.STATE_NOCKED
			self:PlayActivity(ACT_VM_RELEASE)
		elseif not self.Owner:KeyDown(IN_ATTACK) then
			self.dt.WepState = self.STATE_RELEASE
			self:PlayActivity(ACT_VM_PRIMARYATTACK)

			if SERVER then
				local ang = self.Owner:GetAimVector():Angle()

				ang:RotateAroundAxis(ang:Right(), self.ShakeY * math.pi * 2 + 2)
				ang:RotateAroundAxis(ang:Up(), self.ShakeX * math.pi * 2 + 0.1)

				local pos = self.Owner:EyePos() + ang:Up() * -7 + ang:Forward() * -4

				if not self.Owner:KeyDown(IN_ATTACK2) then
					pos = pos + ang:Right() * 1.5
				end

				local charge = self:GetNextSecondaryFire()
				      charge = math.Clamp(CT - charge, 0, 1)

				local arrow = ents.Create("huntingbow_arrow")
				arrow:SetOwner(self.Owner)
				arrow:SetPos(pos)
				arrow:SetAngles(ang)
				arrow:Spawn()
				arrow:Activate()
				arrow:SetVelocity(ang:Forward() * 2500 * charge)
				arrow.Weapon = self

				self:TakePrimaryAmmo(1)
			end
		end
	elseif self.dt.WepState == self.STATE_RELEASE then
		if self.Owner:KeyDown(IN_ATTACK) and self:Clip1() > 0 then
			self.dt.WepState = self.STATE_NOCKED
			self:PlayActivity(ACT_VM_PRIMARYATTACK)
		else
			self.dt.WepState = self.STATE_NONE
			self:PlayActivity(ACT_VM_PRIMARYATTACK)
		end
	elseif self.dt.WepState == self.STATE_NOCKED then
		if self.Owner:KeyDown(IN_ATTACK) and not self.Owner:KeyDown(IN_RELOAD) and not self.Owner:KeyDown(IN_SPEED) then
			self.dt.WepState = self.STATE_PULLED

			self:PlayActivity(ACT_VM_PULLBACK)
			self:SetNextSecondaryFire(CT)
		end
	elseif self.dt.WepState == self.STATE_NONE then
		if (self.Owner:KeyDown(IN_RELOAD) or self.Owner:KeyPressed(IN_ATTACK)) and self:Clip1() == 0 and self:Ammo1() > 0 then
			self.dt.WepState = self.STATE_NOCKED
			self:TakePrimaryAmmo(1)
			self:SetClip1( self:Clip1() + 1 )
			self:PlayActivity(ACT_VM_RELEASE)
		end
	elseif self.dt.WepState == BOW_HOLSTER then
		if SERVER then
			if IsValid(self.nextWeapon) then
				self.Owner:SelectWeapon(self.nextWeapon:GetClass())
				self.nextWeapon = nil
			end
		end
	end
end

function SWEP:Holster(wep)
	return true
end

function SWEP:Deploy()
	if CLIENT then
		self.AimMult = 0
		self.AimMult2 = 0
	end
	self.dt.WepState = self.STATE_NONE

	self.nextWeapon = nil

	self:PlayActivity(ACT_VM_DRAW)
		
	if self:Clip1() == 1 then
		self.dt.WepState = self.STATE_NOCKED
		self:PlayActivity(ACT_VM_LOWERED_TO_IDLE)
	end
	return true
end

if SERVER then
	hook.Add("Initialize", "AddBowToDefaultLoadout", function()
		local wep = weapons.GetStored("weapon_huntingbow_special")

		if wep then
			wep.InLoadoutFor = wep.InLoadoutFor or {}

			if not table.HasValue(wep.InLoadoutFor, ROLE_HUNTER) then
				table.insert(wep.InLoadoutFor, ROLE_HUNTER)
			end
		end
	end)
end