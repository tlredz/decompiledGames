if not script.Parent:IsA("Actor") then
	return
end

local event = script.Parent.Event
game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local smartbone = game.ReplicatedStorage.Services.Core.smartbone
local dependencies = smartbone:WaitForChild("Dependencies")
local Config = require(dependencies:WaitForChild("Config"))
local module = require(smartbone)
local CameraUtil = require(dependencies:WaitForChild("CameraUtil"))
local debug2 = Config.Debug
local clock = os.clock
local now = clock()
local v = 60
local nows = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function roundNumber(p)
	return math.floor(p * 1000 + 0.5) / 1000
end

local function smoothDelta()
	local now2 = clock()

	for i = #nows, 1, -1 do
		local v2 = nows
		local v3 = i + 1
		local v4 = nows[i]
		local v5

		if now2 - 1 <= v4 then
			v5 = nows[i] or nil
		end

		v2[v3] = v5
	end

	nows[1] = now2
	v = math.floor(clock() - now >= 1 and #nows or #nows / (clock() - now))
	return roundNumber(v * (1 / v) ^ 2 + 0.001)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Initialize(p, p2)
	local v2 = module.new(p, p2)
	local total = 0
	v2.SimulationConnection = RunService.Heartbeat:ConnectParallel(function(_: number)
		local v3 = smoothDelta()
		total += v3
		local position = workspace.CurrentCamera.CFrame.Position
		local position2 = v2.RootPart.Position
		local throttleDistance = v2.Settings.ThrottleDistance
		local magnitude = (position - position2).Magnitude
		local activationDistance = v2.Settings.ActivationDistance
		local v4 = math.floor((math.clamp(
			(1 - math.clamp(math.clamp(magnitude - throttleDistance, 0, activationDistance) / activationDistance, 0, 1)) * v2.Settings.UpdateRate,
			1,
			v2.Settings.UpdateRate
		)))
		local withinViewport = CameraUtil.WithinViewport(v2.RootPart)
		local v5 = total

		if 1 / v4 <= v5 then
			if magnitude < activationDistance and withinViewport then
				local v6 = total
				total = 0
				debug.profilebegin("SmartBone")

				if v2.InRange == false then
					v2.InRange = true
				end

				v2:UpdateBones(v6, v4)
				debug.profileend()
				task.synchronize()
				debug.profilebegin("SmartBoneTransform")

				for _, particleTree in v2.ParticleTrees do
					v2:TransformBones(particleTree, v6)

					if debug2 then
						v2:DEBUG(particleTree, v6)
					end
				end

				debug.profileend()
				task.desynchronize()
			elseif v2.InRange == true then
				v2.InRange = false

				for _, particleTree in v2.ParticleTrees do
					v2:ResetParticles(particleTree)
				end

				task.synchronize()

				for _, particleTree in v2.ParticleTrees do
					v2:ResetTransforms(particleTree, v3)
				end

				task.desynchronize()
			end
		end
	end)
	return v2
end

function event.OnInvoke(p, p2)
	return Initialize(p, p2)
end