local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "MinigameBasketball",
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
		Remotes.fireServerComponent(self.Instance, "ThrowBasketball")
	end))
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		if not instance.Parent:FindFirstChild("Humanoid") then
			return
		end

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