local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.ServerInfo)
require(ReplicatedStorage.Shared.FastUtils)
local localPlayer = Players.LocalPlayer
local v = {}
RunService.PostSimulation:Connect(function(_: number)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	for _, v2 in v do
		if not ((v2.Position - humanoidRootPart.Position).Magnitude <= (v2.Size.Magnitude - 2) * 0.5) then
			continue
		end

		humanoidRootPart.AssemblyLinearVelocity = ((humanoidRootPart.Position - v2.Position).Unit + createVector(
			0,
			0.5,
			0
		)) * 100
		break
	end
end)
return Observers.observeTag("BallForceFieldBounce", function(p)
	table.insert(v, p)
	return function()
		local index = table.find(v, p)

		if index then
			table.remove(v, index)
		end
	end
end, { workspace })