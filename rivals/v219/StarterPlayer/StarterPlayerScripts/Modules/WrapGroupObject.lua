local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local WrapGroupObject = {}
WrapGroupObject.__index = WrapGroupObject

function WrapGroupObject.new(name, object, extraObjects)
	local self = setmetatable({}, WrapGroupObject)
	self.Name = name
	self.Object = object
	self.ExtraObjects = extraObjects
	self.IsDestroyed = nil
	self._cleanup = {}
	self._connections = {}
	self._tweens = {}
	self._threads = {}
	self:_Init()
	return self
end

function WrapGroupObject:IsActive()
	return self:_IsAncestryVisible()
end

function WrapGroupObject:Destroy()
	if self.IsDestroyed then
		return
	end

	self.IsDestroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, v in pairs(self._cleanup) do
		v:Destroy()
	end

	for _, _tween in pairs(self._tweens) do
		_tween:Cancel()
		_tween:Destroy()
	end

	for _, _thread in pairs(self._threads) do
		pcall(task.cancel, _thread)
	end

	self._connections = {}
	self._cleanup = {}
	self._tweens = {}
	self._threads = {}
end

function WrapGroupObject:_IsAncestryVisible()
	if self.Object:IsDescendantOf(workspace) then
		return true
	end

	if not self.Object:IsDescendantOf(playerGui) then
		return false
	end

	local parent = self.Object.Parent

	while parent and parent ~= game do
		if parent:IsA("LayerCollector") then
			return parent.Enabled
		end

		if parent:IsA("GuiBase2d") and not parent.Visible then
			return false
		else
			parent = parent.Parent
		end
	end

	return false
end

function WrapGroupObject:_Init()
	self.Object.Destroying:Connect(function()
		self:Destroy()
	end)
end

return WrapGroupObject