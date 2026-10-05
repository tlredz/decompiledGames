local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage:WaitForChild("Models").ToolsExtras
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
require(packages.Debounce)
local parent = script.Parent
local parent2 = parent.Parent.Parent
local mainHighlight = workspace:WaitForChild("MainHighlight")
local v = nil

local function GetNearestPlayer()
	local character = parent2.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = 1e999
	local v3 = nil

	for _, v4 in Players:GetPlayers() do
		if v4 == parent2 then
			continue
		end

		local character2 = v4.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 then
			continue
		end

		local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

		if not (magnitude <= 20 and magnitude < v2) then
			continue
		end

		v3 = character2
		v2 = magnitude
	end

	return v3, Players:GetPlayerFromCharacter(v3)
end

parent.Activated:Connect(function()
	Net:RemoteEvent("UseItem"):FireServer(v)
end)
parent.Equipped:Connect(function()
	RunService:UnbindFromRenderStep("FireExtinguisher")
	mainHighlight.Adornee = script
	v = nil
	RunService:BindToRenderStep("FireExtinguisher", Enum.RenderPriority.Character.Value + 1, function()
		if parent:GetAttribute("CooldownTime") then
			mainHighlight.Adornee = script
			v = nil
		else
			local adornee, v3 = GetNearestPlayer()

			if adornee and adornee ~= v then
				mainHighlight.Adornee = adornee
				v = v3
			else
				mainHighlight.Adornee = script
				v = nil
			end
		end
	end)
end)
parent.Unequipped:Connect(function()
	RunService:UnbindFromRenderStep("FireExtinguisher")
	mainHighlight.Adornee = script
	v = nil
end)