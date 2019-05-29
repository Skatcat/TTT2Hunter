if CLIENT then
   SWEP.Slot      = 7 

	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 54
end

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "normal"
SWEP.PrintName = "Bunnytrap"
SWEP.ViewModel  = "models/stiffy360/c_beartrap.mdl"
SWEP.WorldModel  = "models/stiffy360/beartrap.mdl"
SWEP.UseHands	= true
SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false
SWEP.LimitedStock = true
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.ClipMax = 1
SWEP.Primary.Ammo = "HelicopterGun"

function SWEP:Initialize()
	self:SetDeploySpeed(8)
end

if CLIENT then
   SWEP.Icon = "vgui/ttt/icon_beartrap.png"

   SWEP.EquipMenuData = {
      type = "item_weapon",
	  name = "Bunnytrap",
      desc = [[OM NOM NOM... OM NOM ]]
   }
   
	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 15, ang
	end
end

if SERVER then

	resource.AddFile("materials/vgui/ttt/icon_beartrap.png")
	
	resource.AddFile("materials/models/freeman/beartrap_diffuse.vtf")
	resource.AddFile("materials/models/freeman/beartrap_specular.vtf")
	resource.AddFile("materials/models/freeman/trap_dif.vmt")
	
	resource.AddFile("sound/beartrap.wav")
	
	resource.AddFile("models/stiffy360/beartrap.dx80.vtx")
	resource.AddFile("models/stiffy360/beartrap.dx90.vtx")
	resource.AddFile("models/stiffy360/beartrap.mdl")
	resource.AddFile("models/stiffy360/beartrap.phy")
	resource.AddFile("models/stiffy360/beartrap.sw.vtx")
	resource.AddFile("models/stiffy360/beartrap.vvd")
	resource.AddFile("models/stiffy360/beartrap.xbox.vtx")
	
	resource.AddFile("models/stiffy360/c_beartrap.dx80.vtx")
	resource.AddFile("models/stiffy360/c_beartrap.dx90.vtx")
	resource.AddFile("models/stiffy360/c_beartrap.mdl")
	resource.AddFile("models/stiffy360/c_beartrap.sw.vtx")
	resource.AddFile("models/stiffy360/c_beartrap.vvd")
	resource.AddFile("models/stiffy360/c_beartrap.xbox.vtx")
	
end

function SWEP:Deploy()
	self.Weapon:DrawWorldModel(false)
end

function SWEP:Reload() -- Checks ammo and clip before reloading.
	if self.Owner:GetAmmoCount(self.Primary.Ammo) != 0 && self.Owner:GetActiveWeapon():Clip1() != 1 then
		local rpg_vm = self.Owner:GetViewModel()
		self.Weapon:DefaultReload( ACT_VM_RELOAD )
		self:SetIronsights(false)
		self.Owner:PrintMessage(4, "Rearming traps...\nDon't switch weapons...")
	end
end

if SERVER then
	AddCSLuaFile()

	function SWEP:PrimaryAttack()
		if ( !self:CanPrimaryAttack() ) then return end
		local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 300, filter = self.Owner})
		if tr.HitWorld then
			local dot = vector_up:Dot(tr.HitNormal)
			if dot > 0.55 and dot <= 1 then
				local ent = ents.Create("ttt_bunny_trap")
				self.Weapon:TakePrimaryAmmo(1)
				ent:SetPos(tr.HitPos + tr.HitNormal)
				local ang = tr.HitNormal:Angle()
				ang:RotateAroundAxis(ang:Right(), -90)
				ent:SetAngles(ang)
				ent:Spawn()
				ent.Owner = self.Owner
				ent.fingerprints = self.fingerprints
			end
		end
	end
	
	function SWEP:Deploy()
	end
	
	function SWEP:OnRemove()
		if self.Owner:IsValid() and self.Owner:IsPlayer() then
			self.Owner:ConCommand("lastinv")
		end
	end
end

if SERVER then
	hook.Add("Initialize", "AddTrapToDefaultLoadout", function()
		local wep = weapons.GetStored("weapon_ttt_bunnytrap")

		if wep then
			wep.InLoadoutFor = wep.InLoadoutFor or {}

			if not table.HasValue(wep.InLoadoutFor, ROLE_HUNTER) then
				table.insert(wep.InLoadoutFor, ROLE_HUNTER)
			end
		end
	end)
end