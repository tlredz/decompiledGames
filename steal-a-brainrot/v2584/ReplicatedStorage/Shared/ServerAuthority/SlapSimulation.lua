local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local isServer = RunService:IsServer()
local v = {}
local v2 = {}

local function getActivateAction(instance)
	local toolInputContext = instance:FindFirstChild("ToolInputContext")
	local toolActivate = toolInputContext and toolInputContext:FindFirstChild("ToolActivate")

	if toolActivate and toolActivate:IsA("InputAction") then
		return toolActivate
	end

	return nil
end

local function processPlayer(player)
	local character = player.Character

	if not character then
		v[player] = false
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		v[player] = false
		return
	end

	local toolInputContext = player:FindFirstChild("ToolInputContext")
	local toolActivate = toolInputContext and toolInputContext:FindFirstChild("ToolActivate")

	if not (toolActivate and toolActivate:IsA("InputAction")) then
		toolActivate = nil
	end

	if not toolActivate then
		return
	end

	local v3 = toolActivate:GetState() == true
	local v4 = v[player] or false
	v[player] = v3

	if not v3 or v4 then
		return
	end

	local tool = character:FindFirstChildWhichIsA("Tool")

	if not (tool and tool:GetAttribute("PredictedSwing")) then
		return
	end

	local swingCooldown = tool:GetAttribute("SwingCooldown") or 0
	local now = os.clock()

	if now - (v2[player] or -1e999) < swingCooldown then
		return
	end

	v2[player] = now
	humanoidRootPart:SetAttribute("SlapSwingTick", (humanoidRootPart:GetAttribute("SlapSwingTick") or 0) + 1)
end

if ServerAuthority.isEnabled() then
	RunService:BindToSimulation(function()
		if isServer then
			for _, v3 in Players:GetPlayers() do
				processPlayer(v3)
			end
		else
			local localPlayer = Players.LocalPlayer

			if localPlayer then
				processPlayer(localPlayer)
			end
		end
	end)
end

Players.PlayerRemoving:Connect(function(player)
	v[player] = nil
	v2[player] = nil
end)
return {
	SwingAttribute = "SlapSwingTick",
	ToolAttribute = "PredictedSwing",
	CooldownAttribute = "SwingCooldown",
	register = function(instance, swingCooldown: number)
		assert(isServer, "SlapSimulation.register is server-only")
		instance:SetAttribute("PredictedSwing", true)
		instance:SetAttribute("SwingCooldown", swingCooldown)
	end
}