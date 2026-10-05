local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._registered_ammo_visuals = {}
	self._charm_attachment_parent = self._charm_pivot_attachment and self._charm_pivot_attachment.Parent
	self:_Init()
	return self
end

function object:_UpdateAmmoVisual()
	if self._destroyed then
		return
	end

	for k, _registered_ammo_visual in pairs(self._registered_ammo_visuals) do
		local v = _registered_ammo_visual <= self.ClientItem:Get("Ammo") or self:IsAnimationPlaying("Reload")
		self:_LocalTransparencyModifier(k, "AmmoVisual", v and 0 or 1)

		if not (_registered_ammo_visual == 1 and self._charm_pivot_attachment) then
			continue
		end

		local _charm_pivot_attachment = self._charm_pivot_attachment
		local parent

		if v then
			parent = self._charm_attachment_parent or nil
		end

		_charm_pivot_attachment.Parent = parent
	end
end

function object:_RegisterAmmoVisual(p2, p3)
	self._registered_ammo_visuals[p2] = p3
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