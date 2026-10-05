local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._charm_attachment_parent = self._charm_pivot_attachment and self._charm_pivot_attachment.Parent
	self:_Init()
	return self
end

function object.AbsorbedHit(object2)
	object2:CreateSound("rbxassetid://131693414206770", 1, 0.9 + 0.2 * math.random(), true, 5)
end

function object.ShieldBroken(object2)
	object2:CreateSound("rbxassetid://113753363821942", 1, 0.9 + 0.2 * math.random(), true, 5)
end

function object:_UpdateAmmoVisual()
	if self._destroyed then
		return
	end

	local v = self.ClientItem:Get("Ammo") > 0
	self:HideSubModel("Body", v and 0 or 1e999)
	self._charm_pivot_attachment.Parent = v and self._charm_attachment_parent or nil
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