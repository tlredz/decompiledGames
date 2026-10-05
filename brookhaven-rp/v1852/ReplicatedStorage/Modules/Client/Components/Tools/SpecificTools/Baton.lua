game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
require(ReplicatedStorage.Modules.Client.PlayerController.CameraShakeController)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "Baton",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = self._Janitor:Add(Janitor.new())
	self._isEquipped = false
end

function v:_onEquipped()
	if self._isEquipped then
		return
	end

	local parent = self.Instance.Parent

	if localPlayer.Character ~= parent then
		return
	end

	self._isEquipped = true
	self._equipJanitor:Add(self.Instance.Activated:Connect(function()
		Remotes.fireServerComponent(self.Instance, "Swing")
	end))
	self._equipJanitor:Add(Remotes.connectComponentRemote(self.Instance, "Swing", function() end))
end

function v:_onUnequipped()
	self._isEquipped = false
	self._equipJanitor:Cleanup()
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:_onEquipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:_onUnequipped()
	end))

	if localPlayer.Character and self.Instance.Parent == localPlayer.Character then
		self:_onEquipped()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v