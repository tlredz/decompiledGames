local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ToolSolidPropPlacer"
})
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local instance = p.Instance
	local mouseLoc = instance:WaitForChild("MouseLoc")
	local mouseLocCone = instance:WaitForChild("MouseLocCone")

	mouseLoc.OnClientInvoke = function()
		return localPlayer:GetMouse().Hit.p
	end

	mouseLocCone.OnClientInvoke = function()
		return localPlayer:GetMouse().Target
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v