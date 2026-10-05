local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local bowChargeEffects = Players.LocalPlayer.PlayerScripts.Assets.Misc.BowChargeEffects
local v = {
	Color3.fromRGB(191, 191, 191),
	Color3.fromRGB(100, 255, 50),
	Color3.fromRGB(255, 180, 0),
	Color3.fromRGB(255, 50, 50)
}
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._charge_attachment = self.Model:FindFirstChild("_bow_charge", true)
	self._charge_particles = {}
	self._visibility_delayed = nil
	self._charm_attachment_parent = self._charm_pivot_attachment and self._charm_pivot_attachment.Parent
	self._registered_ammo_visuals = {}
	self:_Init()
	return self
end

function object:GetChargeColor(p)
	return v[p]
end

function object:PlayChargeSound(p)
	self:CreateSound("rbxassetid://13744359504", 1, 0.75 + 0.25 * p, true, 10)
end

function object:PlayChargeEffect(p)
	self:PlayChargeSound(p)

	for _, _charge_particle in pairs(self._charge_particles) do
		_charge_particle.Color = ColorSequence.new(self:GetChargeColor(p))
		_charge_particle:Emit(1)
	end
end

function object:_UpdateArrow()
	if self._destroyed then
		return
	end

	local v2 = self.ClientItem:Get("Ammo") > 0 or (self:IsAnimationPlaying("Reload") or self:IsAnimationPlaying("Shoot1") or self:IsAnimationPlaying("ChargeRelease") and self.ClientItem:Get("AmmoReserve") > 0)

	if v2 and not self._visibility_delayed then
		self._visibility_delayed = true
		wait(0.1)
		self:_UpdateArrow()
	else
		if self._charm_pivot_attachment then
			local _charm_pivot_attachment = self._charm_pivot_attachment
			local parent

			if v2 then
				parent = self._charm_attachment_parent or nil
			end

			_charm_pivot_attachment.Parent = parent
		end

		local v3 = v2 and 0 or 1

		for _, _registered_ammo_visual in pairs(self._registered_ammo_visuals) do
			self:_LocalTransparencyModifier(_registered_ammo_visual, "AmmoVisual", v3)
		end

		self._visibility_delayed = nil
	end
end

function object:_RegisterAmmoVisual(p2)
	table.insert(self._registered_ammo_visuals, p2)
end

function object:_Setup()
	for _, child in pairs((bowChargeEffects:FindFirstChild(self.Name) or bowChargeEffects.Default).Attachment:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._charge_attachment
		table.insert(self._charge_particles, clone)
	end
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateArrow()
	end)
	self.AnimationPlayed:Connect(function()
		self:_UpdateArrow()
	end)
	self.AnimationStopped:Connect(function()
		self:_UpdateArrow()
	end)
	self:_Setup()
	task.spawn(self._UpdateArrow, self)
end

return object