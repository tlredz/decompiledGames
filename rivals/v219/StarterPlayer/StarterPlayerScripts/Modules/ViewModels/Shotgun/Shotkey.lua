local Players = game:GetService("Players")
local Shotgun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Shotgun)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 218, 155))
local object = setmetatable({}, Shotgun)
object.__index = object

function object.new(...)
	local self = setmetatable(Shotgun.new(...), object)
	self._ammo_visuals = {}
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_UpdateAmmoVisuals()
	local ammo = self.ClientItem:Get("Ammo")

	for k, _ammo_visual in pairs(self._ammo_visuals) do
		local v

		if k <= ammo then
			v = true
		elseif k == 1 then
			v = self:IsAnimationPlaying("EmptyReloadStart")
		else
			v = false
		end

		for _, v2 in pairs(_ammo_visual) do
			self:_LocalTransparencyModifier(v2, "AmmoVisual", v and 0 or 1)
		end
	end

	task.defer(self.ChangeInspectAnimation, self, ammo <= 3 and "EmptyInspect" or "Inspect")
end

function object:_Setup()
	for i = 1, 7 do
		self._ammo_visuals[i] = {
			self.ItemModel:WaitForChild("Shell" .. i):WaitForChild("Black"),
			self.ItemModel:WaitForChild("Shell" .. i):WaitForChild("Metal")
		}
	end
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoVisuals()
	end)
	self.AnimationPlayed:Connect(function()
		self:_UpdateAmmoVisuals()
	end)
	self.AnimationStopped:Connect(function()
		self:_UpdateAmmoVisuals()
	end)
	self:_Setup()
	task.defer(self._UpdateAmmoVisuals, self)
end

return object