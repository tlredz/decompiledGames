local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Other = {}
Other.__index = Other

function Other.new(fighterInterface)
	local self = setmetatable({}, Other)
	self.FighterInterface = fighterInterface
	self.RefillAmmoVignette = self.FighterInterface.Frame:WaitForChild("RefillAmmoVignette")
	self.RefillAmmoVignetteTexture = self.RefillAmmoVignette:WaitForChild("Texture")
	self._refill_ammo_effect_hash = 0
	self:_Init()
	return self
end

function Other:RefillAmmoEffect()
	if not self.FighterInterface:IsActive() then
		return
	end

	self._refill_ammo_effect_hash += 1
	local _refill_ammo_effect_hash = self._refill_ammo_effect_hash
	self.FighterInterface:CreateSound("rbxassetid://93185674378015", 1, 1, script, true, 10)
	self.FighterInterface:CreateSound("rbxassetid://96308464356768", 1.5, 1, script, true, 10)
	task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 4, function(p)
		if _refill_ammo_effect_hash ~= self._refill_ammo_effect_hash then
			return true
		end

		local imageTransparency = 0 + 1 * (p / 100)
		self.RefillAmmoVignette.ImageTransparency = imageTransparency
		self.RefillAmmoVignetteTexture.ImageTransparency = imageTransparency
	end)
end

function Other:Destroy()
	self._refill_ammo_effect_hash += 1
end

function Other:_Init() end

return Other