local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._visibility_delayed = nil
	self._registered_ammo_visuals = {}
	self:_Init()
	return self
end

function object:_UpdateRocket()
	if self._destroyed then
		return
	end

	local v = self.ClientItem:Get("Ammo") > 0 or self:IsAnimationPlaying("Reload")

	if v and not self._visibility_delayed then
		self._visibility_delayed = true
		wait(0.1)
		self:_UpdateRocket()
	else
		local v2 = v and 0 or 1

		for _, _registered_ammo_visual in pairs(self._registered_ammo_visuals) do
			self:_LocalTransparencyModifier(_registered_ammo_visual, "AmmoVisual", v2)
		end

		self._visibility_delayed = nil
	end
end

function object:_RegisterAmmoVisual(p2)
	table.insert(self._registered_ammo_visuals, p2)
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateRocket()
	end)
	self.AnimationPlayed:Connect(function(p)
		if p == "Reload" then
			self:_UpdateRocket()
		end
	end)
	self.AnimationStopped:Connect(function(p)
		if p == "Reload" then
			self:_UpdateRocket()
		end
	end)
	task.spawn(self._UpdateRocket, self)
end

return object