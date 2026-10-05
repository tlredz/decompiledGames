local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "ItemShoppingCartBehaviour",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Activated:Connect(function()
		local mouse = localPlayer:GetMouse()

		if not mouse.Target then
			return
		end

		local target = mouse.Target

		if not target then
			return
		end

		if target:HasTag("ToolGiver") then
			Remotes.fireServerComponent(self.Instance, "AttemptPickupItem", target.Parent.Name)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v