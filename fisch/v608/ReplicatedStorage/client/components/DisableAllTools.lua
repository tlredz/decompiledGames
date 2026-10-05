local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local rods = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rods"))
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "DisableAllTools"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	p.trove:Add(p.Instance.Touched:Connect(function(otherPart)
		local character = localPlayer.Character

		if not character or otherPart ~= character.PrimaryPart then
			return
		end

		character:SetAttribute("ToolsDisabled", true)
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

RunService.PreSimulation:Connect(function()
	if not (localPlayer.Character and localPlayer.Character:GetAttribute("ToolsDisabled") and localPlayer.Character.PrimaryPart) then
		return
	end

	local primaryPart = localPlayer.Character.PrimaryPart
	local tool = localPlayer.Character:FindFirstChildWhichIsA("Tool")

	if tool and not rods[tool.Name] and tool.Name ~= "Equipment Bag" then
		tool.Parent = localPlayer.Backpack
	end

	for _, v2 in v:GetAll() do
		if (v2.Instance:GetClosestPointOnSurface(primaryPart.Position) - primaryPart.Position).Magnitude <= 0.25 then
			return
		end
	end

	localPlayer.Character:SetAttribute("ToolsDisabled", nil)
end)
return v