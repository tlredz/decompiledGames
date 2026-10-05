local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "SprayCanTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
end

function v:StartListeningToUsage()
	self._equipJanitor:Cleanup()
	local mouse = Players.LocalPlayer:GetMouse()
	self._equipJanitor:Add(mouse.Button1Down:Connect(function()
		Remotes.fireServerComponent(self.Instance, "MouseDown")
	end))
	self._equipJanitor:Add(mouse.Button1Up:Connect(function()
		Remotes.fireServerComponent(self.Instance, "MouseUp")
	end))
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:StartListeningToUsage()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self._equipJanitor:Cleanup()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v