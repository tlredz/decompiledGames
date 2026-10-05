local class = {}
class.__index = class
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage:WaitForChild("Director"))
local localPlayer = Players.LocalPlayer
local part = Instance.new("Part")
local v = 0
local v2 = {}
RunService.Heartbeat:Connect(function()
	local now = tick()

	if now - v >= 0.05 then
		v = now
		local position = localPlayer.Character and localPlayer.Character:GetPivot().Position

		if not position then
			return
		end

		for k, v3 in v2 do
			local loaded = (k:GetPivot().Position - position).Magnitude <= v3.Distance

			if loaded == v3.Loaded then
				continue
			end

			v3.Loaded = loaded
			v3.FocusPart.Parent = loaded and workspace.CurrentCamera or nil
		end
	end
end)

function class:Init()
	self.FocusPart = part:Clone()
	self.FocusPart.CFrame = CFrame.new(self.Instance:GetAttribute("FocusPosition") or error((`No "FocusPosition" attribute for NearbyLoDFocus object {self.Instance:GetFullName()}`)))
	self.Distance = self.Instance:GetAttribute("Distance") or 96
	v2[self.Instance] = self
end

function class:Destroy()
	self.FocusPart:Destroy()
	v2[self.Instance] = nil
end

part:AddTag("LoDPosition")
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.Transparency = 1
part.Size = vector.create(0, 0, 0)
return {
	new = function(instance, _)
		return (setmetatable({
			Instance = instance,
			Loaded = false
		}, class))
	end,
	ancestor = nil
}