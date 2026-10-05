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
local filterDescendantsInstances = {}
RunService.Heartbeat:Connect(function()
	local now = tick()
	local v4 = now - v

	if v4 >= 0.05 then
		v = now
		local position = localPlayer.Character and localPlayer.Character:GetPivot().Position

		if not position then
			return
		end

		table.clear(filterDescendantsInstances)
		local v5 = 1

		for k in v2 do
			filterDescendantsInstances[v5] = k
			v5 += 1
		end

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = filterDescendantsInstances
		local partBoundsInRadius = workspace:GetPartBoundsInRadius(position, 2, overlapParams)

		for k, v6 in v2 do
			local loaded = table.find(partBoundsInRadius, k) ~= nil

			if loaded == v6.Loaded then
				continue
			end

			if loaded == false then
				v6.OutOfBoxTime += v4

				if v6.OutOfBoxTime < 1 then
					continue
				else
					v6.OutOfBoxTime = 0
				end
			end

			print(k, "set to state", loaded)
			v6.Loaded = loaded
			v6.FocusPart.Parent = loaded and workspace.CurrentCamera or nil
		end
	end
end)

function class:Init()
	self.FocusPart = part:Clone()
	self.FocusPart.CFrame = CFrame.new(self.Instance:GetAttribute("FocusPosition") or error((`No "FocusPosition" attribute for LoDFocusBox object {self.Instance:GetFullName()}`)))
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
			Loaded = false,
			OutOfBoxTime = 0
		}, class))
	end,
	ancestor = nil
}