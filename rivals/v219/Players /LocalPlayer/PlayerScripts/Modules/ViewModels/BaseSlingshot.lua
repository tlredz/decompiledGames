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

function object:_UpdateBall()
	if self._destroyed then
		return
	end

	local v = self.ClientItem:Get("Ammo") > 0 or self:IsAnimationPlaying("Reload")

	if v and not self._visibility_delayed then
		self._visibility_delayed = true
		wait(0.1)
		self:_UpdateBall()
	else
		for _ in pairs(self._registered_ammo_visuals) do
			self:_LocalTransparencyModifier(self._sphere, "AmmoVisual", v and 0 or 1)
		end

		self._visibility_delayed = nil
	end
end

function object:_RegisterAmmoVisual(p2)
	self._registered_ammo_visuals[p2] = true
	task.spawn(self._UpdateBall, self)
end

function object:_RegisterDefaultAmmoVisuals()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Ball"):WaitForChild("Sphere"))
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateBall()
	end)
	self.AnimationPlayed:Connect(function(p)
		if p == "Reload" then
			self:_UpdateBall()
		end
	end)
	self.AnimationStopped:Connect(function(p)
		if p == "Reload" then
			self:_UpdateBall()
		end
	end)
	task.spawn(self._UpdateBall, self)
end

return object