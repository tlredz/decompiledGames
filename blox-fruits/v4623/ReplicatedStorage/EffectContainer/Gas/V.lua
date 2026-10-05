local _WorldOrigin = workspace._WorldOrigin
local FX = require(game.ReplicatedStorage.FX)
local transform = FX:WaitForChild("Gas").V.Transform
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local Util = require(game.ReplicatedStorage.Util)
game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, position2)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (position2 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function TrailSpin(root, folder)
	local spinTrails = transform.Phase1.SpinTrails
	local v = {}

	for _ = 1, 5 do
		local clone = spinTrails["Trail" .. tostring((math.random(1, #spinTrails:GetChildren())))]:Clone()
		clone.CFrame = root.CFrame
		clone.Parent = folder
		clone.Anchored = false
		clone.Weld.Part1 = root

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		clone.SpinTrail2.WeldConstraint.Enabled = false
		clone.SpinTrail2.CFrame = clone.CFrame * CFrame.new(
			math.random(-40, -20),
			math.random(25, 50),
			math.random(10, 25)
		)
		clone.SpinTrail2.WeldConstraint.Enabled = true
		clone.Weld.C0 = clone.Weld.C0 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		local v2 = math.random(1, 3)

		if v2 == 1 then
			clone.Trail.Color = ColorSequence.new(Color3.fromRGB(129, 74, 248), Color3.fromRGB(89, 100, 255))
		elseif v2 == 2 then
			clone.Trail.Color = ColorSequence.new(Color3.fromRGB(80, 124, 221), Color3.fromRGB(76, 115, 255))
		elseif v2 == 3 then
			clone.Trail.Color = ColorSequence.new(Color3.fromRGB(53, 64, 156), Color3.fromRGB(111, 64, 214))
		end

		local v3 = math.random(7, 15)
		clone.SpinTrail2.Attach0.Position = Vector3.new(v3, 0, 0)
		clone.SpinTrail2.Attach1.Position = Vector3.new(-v3, 0, 0)
		clone.Trail.Lifetime = math.random(15, 30) / 100
		v[clone] = math.random(12, 25)
	end

	local v2 = 0.7 + tick()

	while true do
		for k, v3 in pairs(v) do
			k.Weld.C0 = k.Weld.C0 * CFrame.new(0, 1, 0) * CFrame.Angles(0, math.rad(v3), 0)
		end

		task.wait(0.001)

		if not (v2 - tick() <= 0) then
			continue
		end

		for folder2, _ in pairs(v) do
			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end

		break
	end
end

local function GasArea(cFrame, folder)
	local clone = transform.Phase2.GasDomain:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	local clone2 = transform.Phase2.GasDomain2:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = clone

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.wait(0.75)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

return function(p)
	local root = p.Root

	if p.Toggle then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		task.delay(5, function()
			folder:Destroy()
		end)
		local cFrame = root.CFrame
		Util.Sound:Play("BF_GASFRUIT_VaporCondensation_Transform_01", root)
		task.spawn(function()
			TrailSpin(root, folder)
		end)
		task.spawn(function()
			GasArea(cFrame, folder)
		end)
		local trails = transform.Phase1.Trails
		task.spawn(function()
			local count = #trails:GetChildren()

			for _ = 1, 5 do
				task.spawn(function()
					task.wait(math.random(10, 30) / 100)
					local cFrame2 = cFrame * CFrame.new(
						math.random(-25, 25) * 3,
						math.random(0, 25) * 3,
						math.random(-25, 25) * 3
					)
					local position = cFrame.Position
					local v2 = math.random(50, 80) / 10
					local v3 = math.random(1, count)
					local clone = trails["Trail" .. tostring(v3)]:Clone()
					clone.CFrame = cFrame2
					clone.Parent = folder
					local position2 = clone.Position
					local magnitude = (position2 - position).Magnitude
					clone.CFrame = CFrame.new(position2, position)
					local v4 = (position2 - position) / 2
					local position3 = CFrame.new(CFrame.new(position2) * (v4 / -1.5)).Position
					local position4 = CFrame.new(CFrame.new(position) * (v4 / 1.5)).Position
					local v5 = magnitude / 1.25
					local v6 = position3 + Vector3.new(
						math.random(-v5, v5),
						math.random(-v5 / 2, v5),
						math.random(-v5, v5)
					)
					local v7 = position4 + Vector3.new(
						math.random(-v5, v5),
						math.random(-v5 / 2, v5),
						math.random(-v5, v5)
					)
					local lastTime = tick()
					local v8 = magnitude / v2 / 60

					while tick() - lastTime < v8 do
						local v9 = (tick() - lastTime) / v8
						local v10 = cubicBezier(v9, position2, v6, v7, position)
						clone.CFrame = clone.CFrame:Lerp(CFrame.new(v10, position), v9)
						RunService.Heartbeat:Wait()
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				task.wait(0.025)
			end
		end)
		local clone = transform.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		task.wait(0.15)
		local clone2 = transform.Phase1.StartImpact2:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			local clone3 = transform.Phase1.Start:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = folder
			local emittersByEmitter = {}

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emittersByEmitter[emitter] = emitter
			end

			local v = 0.3 + tick()

			while true do
				for _, v2 in pairs(emittersByEmitter) do
					v2:Emit(1)
				end

				task.wait(0.005)

				if not (v - tick() <= 0) then
					continue
				end

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				break
			end
		end)
		task.wait(0.35)
		local clone3 = transform.Phase2.Explosion:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end
	else
		local detransform = FX:WaitForChild("Gas").V.Detransform
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		task.delay(5, function()
			folder:Destroy()
		end)
		local cFrame = root.CFrame
		Util.Sound:Play("BF_GASFRUIT_VaporCondensation_Untransform_01", root)
		task.spawn(function()
			local clone = detransform.Phase1.Start:Clone()
			clone.CFrame = cFrame
			clone.Parent = folder
			local emittersByEmitter = {}

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emittersByEmitter[emitter] = emitter
			end

			local v = 0.3 + tick()

			while true do
				for _, v2 in pairs(emittersByEmitter) do
					v2:Emit(1)
				end

				task.wait(0.005)

				if not (v - tick() <= 0) then
					continue
				end

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				break
			end
		end)
		local clone = detransform.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		task.wait(0.15)
		local clone2 = detransform.Phase1.StartImpact2:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end
	end
end