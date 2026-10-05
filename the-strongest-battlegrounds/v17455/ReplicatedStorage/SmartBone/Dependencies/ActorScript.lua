if not script.Parent:IsA("Actor") then
	return
end

local event = script.Parent.Event
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = { ReplicatedStorage, Players.LocalPlayer:WaitForChild("PlayerScripts") }
local v2 = nil

for _, v4 in pairs(v) do
	local smartBone = v4:FindFirstChild("SmartBone", true)

	if not (smartBone and smartBone:IsA("ModuleScript")) then
		continue
	end

	v2 = smartBone
	break
end

if not v2 then
	warn("SmartBone was not found!")
	return
end

local dependencies = v2:WaitForChild("Dependencies")
local Config = require(dependencies:WaitForChild("Config"))
local module = require(v2)
local CameraUtil = require(dependencies:WaitForChild("CameraUtil"))
local debug2 = Config.Debug
local clock = os.clock
local now = clock()
local v4 = 60
local nows = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function roundNumber(p)
	return math.floor(p * 1000 + 0.5) / 1000
end

local function smoothDelta()
	local now2 = clock()

	for i = #nows, 1, -1 do
		local v5 = nows
		local v6 = i + 1
		local v7 = nows[i]
		local v8

		if now2 - 1 <= v7 then
			v8 = nows[i] or nil
		end

		v5[v6] = v8
	end

	nows[1] = now2
	v4 = math.floor(clock() - now >= 1 and #nows or #nows / (clock() - now))
	return roundNumber(v4 * (1 / v4) ^ 2 + 0.001)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Initialize(p, p2)
	local v5 = module.new(p, p2)
	local total = 0
	v5.SimulationConnection = RunService.Heartbeat:ConnectParallel(function(_: number)
		local v6 = smoothDelta()
		total += v6
		local position = workspace.CurrentCamera.CFrame.Position
		local position2 = v5.RootPart.Position
		local throttleDistance = v5.Settings.ThrottleDistance
		local magnitude = (position - position2).Magnitude
		local activationDistance = v5.Settings.ActivationDistance
		local v7 = math.floor((math.clamp(
			(1 - math.clamp(math.clamp(magnitude - throttleDistance, 0, activationDistance) / activationDistance, 0, 1)) * v5.Settings.UpdateRate,
			1,
			v5.Settings.UpdateRate
		)))
		local withinViewport = CameraUtil.WithinViewport(v5.RootPart)
		local v8 = total

		if 1 / v7 <= v8 then
			if magnitude < activationDistance and withinViewport then
				local v9 = total
				total = 0
				debug.profilebegin("SoftBone")

				if v5.InRange == false then
					v5.InRange = true
				end

				v5:UpdateBones(v9, v7)
				debug.profileend()
				task.synchronize()
				debug.profilebegin("SoftBoneTransform")

				for _, particleTree in v5.ParticleTrees do
					v5:TransformBones(particleTree, v9)

					if debug2 then
						v5:DEBUG(particleTree, v9)
					end
				end

				debug.profileend()
				task.desynchronize()
			elseif v5.InRange == true then
				v5.InRange = false

				for _, particleTree in v5.ParticleTrees do
					v5:ResetParticles(particleTree)
				end

				task.synchronize()

				for _, particleTree in v5.ParticleTrees do
					v5:ResetTransforms(particleTree, v6)
				end

				task.desynchronize()
			end
		end
	end)
	return v5
end

function event.OnInvoke(p, p2)
	return Initialize(p, p2)
end