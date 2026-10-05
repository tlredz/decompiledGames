local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._registered_ammo_visuals = {}
	self._visibility_delayed = nil
	self:_Init()
	return self
end

function object:_UpdateAmmoVisual()
	if self._destroyed then
		return
	end

	local v = self.ClientItem:Get("Ammo") > 0 or self:IsAnimationPlaying("Reload")

	if v and not self._visibility_delayed then
		self._visibility_delayed = true
		wait(0.1)
		self:_UpdateAmmoVisual()
	else
		self._visibility_delayed = nil

		for k in pairs(self._registered_ammo_visuals) do
			self:_LocalTransparencyModifier(k, "AmmoVisual", v and 0 or 1)
		end
	end
end

function object:_RegisterAmmoVisual(p2)
	self._registered_ammo_visuals[p2] = true
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoVisual()
	end)
	self.AnimationPlayed:Connect(function()
		self:_UpdateAmmoVisual()
	end)
	self.AnimationStopped:Connect(function()
		self:_UpdateAmmoVisual()
	end)
	task.spawn(self._UpdateAmmoVisual, self)
end

return object