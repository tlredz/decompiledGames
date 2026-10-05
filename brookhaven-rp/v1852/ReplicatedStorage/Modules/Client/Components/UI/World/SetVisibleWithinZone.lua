local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "SetVisibleWithinZone"
})
local v2 = false
local SignalWhenInZoneBVH = require(ReplicatedStorage.Modules.Client.Components.Triggers.SignalWhenInZoneBVH)
local VisibilityController = require(ReplicatedStorage.Modules.Client.UI.VisibilityController)

function v:Construct()
	self._Janitor = Janitor.new()
	self._visibilityJanitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v2 = PanelController
	self.signalWhenInZoneBVH = SignalWhenInZoneBVH:WaitForInstance(self.Instance:WaitForChild("VisibilityZone").Value):expect()
	self.ticket = nil
end

function v:Entered()
	if self.ticket ~= nil then
		return
	end

	self.ticket = self._Janitor:Add(VisibilityController.AddShowTicket(self.Instance))
	v2.Close("MainGUIHandler", "StarterInstructions")
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:WaitForChild("Humanoid", 10)

	if not humanoid then
		return
	end

	self._visibilityJanitor:Add(humanoid.Died:Connect(function()
		self:Exited()
	end))
end

function v:Exited()
	if self.ticket then
		self.ticket()
		self.ticket = nil
	end
end

function v:Start()
	self._Janitor:Add(self.signalWhenInZoneBVH.OnLocalPlayerEntered:Connect(function()
		self:Entered()
	end))
	self._Janitor:Add(self.signalWhenInZoneBVH.OnLocalPlayerExited:Connect(function()
		self:Exited()
	end))
end

function v:Stop()
	self._visibilityJanitor:Destroy()
	self._Janitor:Destroy()
end

return v