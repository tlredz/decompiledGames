local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local isServer = RunService:IsServer()

local function ProcessPlayer(player, p: number)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart") and RunService:GetPredictionStatus(humanoidRootPart) ~= Enum.PredictionStatus.None) then
		return
	end

	local icedSlideVelocity = humanoidRootPart:GetAttribute("IcedSlideVelocity")
	local v = typeof(icedSlideVelocity) ~= "Vector3" and createVector(0, 0, 0) or icedSlideVelocity
	local icedUntil = humanoid:GetAttribute("IcedUntil")
	local v2

	if typeof(icedUntil) == "number" then
		v2 = workspace:GetServerTimeNow() < icedUntil
	else
		v2 = false
	end

	local v3

	if v2 then
		local moveDirection = humanoid.MoveDirection
		local vector2 = Vector3.new(moveDirection.X, 0, moveDirection.Z)

		if vector2.Magnitude > 0 then
			v3 = v:Lerp(vector2.Unit * 26, 1 - math.exp(p * -10))
		else
			v3 = v * math.exp(p * -1.4)
		end

		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(v3.X, assemblyLinearVelocity.Y, v3.Z)
	else
		v3 = v.Magnitude > 0 and createVector(0, 0, 0) or v
	end

	if humanoidRootPart:GetAttribute("IcedSlideVelocity") ~= v3 then
		humanoidRootPart:SetAttribute("IcedSlideVelocity", v3)
	end
end

if ServerAuthority.isEnabled() then
	RunService:BindToSimulation(function(p: number)
		if isServer then
			for _, v in ipairs(Players:GetPlayers()) do
				ProcessPlayer(v, p)
			end
		else
			local localPlayer = Players.LocalPlayer

			if localPlayer then
				ProcessPlayer(localPlayer, p)
			end
		end
	end, Enum.StepFrequency.Hz60, 3000)
end

return table.freeze({})