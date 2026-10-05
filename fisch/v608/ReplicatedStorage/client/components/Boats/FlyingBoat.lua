local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "FlyingBoat"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	if p.Instance:GetAttribute("OwnerUserId") ~= localPlayer.UserId then
		local function onObject(part)
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end

		p.trove:Add(p.Instance.DescendantAdded:Connect(onObject))

		for _, descendant in p.Instance:GetDescendants() do
			task.spawn(onObject, descendant)
		end
	end
end

function v.Stop(p)
	p.trove:Clean()
end

return v