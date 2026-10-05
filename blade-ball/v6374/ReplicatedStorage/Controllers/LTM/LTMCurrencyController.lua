local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.Utils)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local localPlayer = Players.LocalPlayer
local replion = nil
local v2 = {
	SciFi = {
		{
			"Plasma Blaster",
			"rbxassetid://15454593129",
			{ "PlasmaBlasterRight_Handle", "PlasmaBlasterRight_Neon" }
		},
		{
			"Plasma Blasters",
			"rbxassetid://15453989190",
			{
				"PlasmaBlasterRight_Handle",
				"PlasmaBlasterRight_Neon",
				"PlasmaBlasterLeft_Handle",
				"PlasmaBlasterLeft_Neon"
			}
		},
		{
			"DualLaserblade",
			"rbxassetid://15454704400",
			{ "DualLaserBlade_Handle", "DualLaserBlade_Neon" }
		}
	}
}
local v3 = {}
local v4 = 3
local v5 = 1

local function GenerateAnimationTrack(instance, animationId)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = instance.Humanoid.Animator:LoadAnimation(animation)
	track.Looped = false
	animation:Destroy()
	return track
end

local function CheckOwnership()
	replion = v.Client:GetReplion("Data")

	for _, list in pairs(v2) do
		for k, v6 in pairs(list) do
			if not (#client:FindItems(localPlayer, "Sword", v6[1]) > 0) then
				continue
			end

			table.remove(list, k)
			v4 = #list
		end
	end
end

local function ToggleWeaponVisibility(p, list, enabled)
	local v6 = v3[p]

	for _, part in pairs(v6:GetChildren()) do
		if not (part:IsA("BasePart") and table.find(list, part.Name)) then
			continue
		end

		part.Transparency = enabled == true and 0 or 1

		for _, effect in pairs(part:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
				continue
			end

			effect.Enabled = enabled
		end
	end
end

local function LoadAndPlayAnimation(p, list)
	local v6 = v5 - 1
	local v7 = v6 <= 0 and #list or v6

	if not (list and list[v5]) then
		return
	end

	local v8 = list[v5][3]
	ToggleWeaponVisibility(p, list[v7][3], false)
	ToggleWeaponVisibility(p, v8, true)
	local v10 = list[v7][4]

	if v10 then
		v10:Stop()
	end

	local v11 = list[v5][4]

	if v11 then
		v11:Play()
	end
end

return {
	Start = function(_)
		return false
	end
}