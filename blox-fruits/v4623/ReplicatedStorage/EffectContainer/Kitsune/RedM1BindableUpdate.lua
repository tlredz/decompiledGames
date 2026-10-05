local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
require(ReplicatedStorage:WaitForChild("FX"))
require(ReplicatedStorage:WaitForChild("Util"))
return function(data)
	local _ = data.player
	local victimHrps = data.victimHrps
	local bindable = data.bindable

	function bindable.OnInvoke()
		return victimHrps
	end

	if bindable:GetAttribute("CleanupActive") then
		return
	end

	bindable:SetAttribute("CleanupActive", true)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = bindable.AncestryChanged:Connect(function(_)
		if bindable.Parent ~= nil and (bindable:IsDescendantOf(Workspace) or bindable:IsDescendantOf(game:GetService("Players"))) then
			return
		end

		function bindable.OnInvoke() end

		table.clear(victimHrps)
		ancestryChangedConnection:Disconnect()
	end)
end