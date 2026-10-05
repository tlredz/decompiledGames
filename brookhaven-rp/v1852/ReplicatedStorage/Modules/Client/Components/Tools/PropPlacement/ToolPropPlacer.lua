local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local CharacterUtil = require(ReplicatedStorage.Modules.Shared.Utils.CharacterUtil)
local v = Component.new({
	Tag = "ToolPropPlacer"
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

		if target:HasTag("ToolGiver") or CharacterUtil.isDescendantOfCharacter(target) then
			return
		end

		local clickDetector = target:FindFirstChildOfClass("ClickDetector") or target.Parent:FindFirstChildOfClass("ClickDetector")

		if clickDetector and clickDetector:HasTag("ClickDetectorWithTool") then
			return
		end

		Remotes.fireServerComponent(self.Instance, "AttemptPlaceProp", mouse.Hit.Position, target)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v