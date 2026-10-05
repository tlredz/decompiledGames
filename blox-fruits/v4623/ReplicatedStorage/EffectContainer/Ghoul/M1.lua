local createVector = vector.create
local _ = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local ghoulM1 = FX:WaitForChild("Ghoul").M1.GhoulM1
local _WorldOrigin = workspace._WorldOrigin
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://13804833394"

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function TrailCurve(folder, cFrame, position, list, cframe, cframe2, p, p2)
	local v = list[1].CFrame * list[2].Position
	folder.CFrame = CFrame.new(position, v)
	local lastTime = tick()
	local v2 = 12 / p / 60
	local v3 = (12 / p + p) / 60
	local v4 = false

	while tick() - lastTime < v2 do
		local v5 = (tick() - lastTime) / v2
		local v6 = list[1].CFrame * list[2].Position
		local v7 = (position - v6) / 2
		local position2 = CFrame.new(CFrame.new(position) * (v7 / -1.5)).Position
		local position3 = CFrame.new(CFrame.new(v6) * (v7 / 1.5)).Position
		local v8 = CFrame.new(position2, position2 + cFrame.LookVector) * cframe.Position
		local v9 = CFrame.new(position3, position3 + cFrame.LookVector) * cframe2.Position
		local v10 = cubicBezier(v5, position, v8, v9, v6)
		folder.CFrame = folder.CFrame:Lerp(CFrame.new(v10, v6), v5)

		if v4 == false then
			if tick() - lastTime < v3 * 0.6 then
				local v11 = (tick() - lastTime) / v3
				local v12 = cubicBezier(v11, position, v8, v9, v6)
				folder.CFrame = CFrame.new(folder.Position, v12)
			else
				v4 = true

				if p2 == true then
					for _, part in pairs(folder:GetDescendants()) do
						if part:IsA("MeshPart") then
							part.Transparency = 1
						end
					end
				end
			end
		end

		RunService.Heartbeat:Wait()
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
return function(p)
	local root = p.Root

	if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 400 then
		return
	end

	local combo = p.Combo
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 2)
	local cFrame = root.CFrame
	local v = math.clamp(1 + (root.Size.Y / 2.1 - 1), 1, 5) * 0.975

	local function CFramenew(p2, p3, p4)
		return CFrame.new(Vector3.new(p2, p3, p4) * v)
	end

	Util.Sound:Play("SanguineM1_" .. combo, root)

	if combo == 1 then
		local clone = ghoulM1.Trail:Clone()
		clone.CFrame = cFrame * CFrame.new(createVector(6, 0, 0) * v)
		clone.Parent = folder
		local position = clone.Position
		local cframe = CFrame.new(createVector(-2, 0, -11) * v)
		local cframe2 = CFrame.new(createVector(8, 15, -5) * v)
		local cframe3 = CFrame.new(createVector(4, -2, -7) * v)

		for _, emitter in pairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		clone.Ghoul_tentacle["Cube.013"].Transparency = 1
		task.delay(0.1, function()
			clone.Ghoul_tentacle["Cube.013"].Transparency = 0
		end)
		task.spawn(function()
			local cframe4 = CFrame.new(createVector(3, 1.5, -13) * v)
			local v3 = CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(0, 0, 0.17453292519943295)
			local clone2 = ghoulM1.StartSlash:Clone()
			clone2.Parent = folder
			clone2.CFrame = cFrame * cframe4 * v3

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.wait(0.1)
			local cframe5 = CFrame.new(createVector(10, 1.5, -13) * v)
			local clone3 = ghoulM1.SlashImpact:Clone()
			clone3.Parent = folder
			clone3.CFrame = cFrame * cframe5 * v3

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		TrailCurve(clone, cFrame, position, { root, cframe }, cframe2, cframe3, 1.75)
		TrailCurve(
			clone,
			cFrame,
			clone.Position,
			{ root, (CFrame.new(createVector(-8, 1, -3) * v)) },
			CFrame.new(createVector(-3, -5, -5) * v),
			CFrame.new(createVector(-6, 3, -1) * v),
			1,
			true
		)

		for _, emitter in pairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone.Ghoul_tentacle["Cube.013"].Transparency = 1
	elseif combo == 2 then
		local clone = ghoulM1.Trail:Clone()
		clone.CFrame = cFrame * CFrame.new(createVector(-8, 1, 1) * v)
		clone.Parent = folder
		local position = clone.Position
		local cframe = CFrame.new(createVector(-2, 0, -11) * v)
		local cframe2 = CFrame.new(createVector(-7, 15, -2) * v)
		local cframe3 = CFrame.new(createVector(-3, -2, -5) * v)

		for _, emitter in pairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		clone.Ghoul_tentacle["Cube.013"].Transparency = 1
		task.delay(0.1, function()
			clone.Ghoul_tentacle["Cube.013"].Transparency = 0
		end)
		task.spawn(function()
			local cframe4 = CFrame.new(createVector(-0.25, 2, -12) * v)
			local v3 = CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.Angles(0, 0, -0.2617993877991494)
			local clone2 = ghoulM1.StartSlash:Clone()
			clone2.Parent = folder
			clone2.CFrame = cFrame * cframe4 * v3

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.wait(0.1)
			local cframe5 = CFrame.new(createVector(-6, 2, -12) * v)
			local clone3 = ghoulM1.SlashImpact:Clone()
			clone3.Parent = folder
			clone3.CFrame = cFrame * cframe5 * v3

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		TrailCurve(clone, cFrame, position, { root, cframe }, cframe2, cframe3, 1.75)
		TrailCurve(
			clone,
			cFrame,
			clone.Position,
			{ root, (CFrame.new(createVector(6, 1, -1) * v)) },
			CFrame.new(createVector(0, -7, -5) * v),
			CFrame.new(createVector(5, 15, -2) * v),
			1,
			true
		)

		for _, emitter in pairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone.Ghoul_tentacle["Cube.013"].Transparency = 1
	elseif combo == 3 then
		task.spawn(function()
			local clone = ghoulM1.Trail:Clone()
			clone.CFrame = cFrame * CFrame.new(createVector(-6, 3, 0) * v)
			clone.Parent = folder
			local position = clone.Position
			local cframe = CFrame.new(createVector(-4, -2, -15) * v)
			local cframe2 = CFrame.new(createVector(-10, -2, -3) * v)
			local cframe3 = CFrame.new(createVector(-5, -3, -5) * v)

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			clone.Ghoul_tentacle["Cube.013"].Transparency = 1
			task.delay(0.1, function()
				clone.Ghoul_tentacle["Cube.013"].Transparency = 0
			end)
			task.spawn(function()
				local cframe4 = CFrame.new(createVector(0, 0, -14) * v)
				local v3 = CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(0, 0, -0.7853981633974483)
				local clone2 = ghoulM1.StartSlash:Clone()
				clone2.Parent = folder
				clone2.CFrame = cFrame * cframe4 * v3

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				task.wait(0.175)
				local cframe5 = CFrame.new(createVector(0, 0, -14) * v)
				local clone3 = ghoulM1.SlashImpact:Clone()
				clone3.Parent = folder
				clone3.CFrame = cFrame * cframe5 * v3

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			TrailCurve(clone, cFrame, position, { root, cframe }, cframe2, cframe3, 1.75)
			TrailCurve(
				clone,
				cFrame,
				clone.Position,
				{ root, (CFrame.new(createVector(7, 7, -10) * v)) },
				CFrame.new(createVector(0, -5, 0) * v),
				CFrame.new(createVector(1, 3, -1) * v),
				1,
				true
			)

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone.Ghoul_tentacle["Cube.013"].Transparency = 1
		end)
		task.spawn(function()
			local clone = ghoulM1.Trail:Clone()
			clone.CFrame = cFrame * CFrame.new(createVector(6, 3, 0) * v)
			clone.Parent = folder
			local position = clone.Position
			local cframe = CFrame.new(createVector(4, -2, -15) * v)
			local cframe2 = CFrame.new(createVector(10, -2, -3) * v)
			local cframe3 = CFrame.new(createVector(5, -3, -5) * v)

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			clone.Ghoul_tentacle["Cube.013"].Transparency = 1
			task.delay(0.1, function()
				clone.Ghoul_tentacle["Cube.013"].Transparency = 0
			end)
			task.spawn(function()
				local cframe4 = CFrame.new(createVector(0, 0, -14) * v)
				local v3 = CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.Angles(0, 0, 0.7853981633974483)
				local clone2 = ghoulM1.StartSlash:Clone()
				clone2.Parent = folder
				clone2.CFrame = cFrame * cframe4 * v3

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				task.wait(0.175)
				local cframe5 = CFrame.new(createVector(0, 0, -14) * v)
				local clone3 = ghoulM1.SlashImpact:Clone()
				clone3.Parent = folder
				clone3.CFrame = cFrame * cframe5 * v3

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			TrailCurve(clone, cFrame, position, { root, cframe }, cframe2, cframe3, 1.75)
			TrailCurve(
				clone,
				cFrame,
				clone.Position,
				{ root, (CFrame.new(createVector(-7, 7, -10) * v)) },
				CFrame.new(createVector(0, -5, 0) * v),
				CFrame.new(createVector(-1, 3, -1) * v),
				1,
				true
			)

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone.Ghoul_tentacle["Cube.013"].Transparency = 1
		end)
	elseif combo == 4 then
		local clone = ghoulM1.FinalTrail:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		clone.Ghoul_tentacle.AnimationController:LoadAnimation(animation):Play()
		local descendants = clone:GetDescendants()

		for _, instance in pairs(descendants) do
			if instance:IsA("ParticleEmitter") then
				instance.Enabled = true
			elseif instance:IsA("MeshPart") then
				local transparency = instance.Transparency
				instance.Transparency = 1
				local v2 = instance
				task.spawn(function()
					task.wait(0.05)
					v2.Transparency = transparency
				end)
			end
		end

		local lastTime = tick()

		while tick() - lastTime < 0.25 do
			local v2 = (tick() - lastTime) / 0.25
			clone.CFrame = cFrame:Lerp(root.CFrame * CFrame.new(createVector(0, 0, -11) * v), v2)
			task.wait()
		end

		clone.CFrame = root.CFrame * CFrame.new(createVector(0, 0, -11) * v)

		for _, instance in pairs(descendants) do
			if instance:IsA("ParticleEmitter") then
				instance.Enabled = false
			elseif instance:IsA("MeshPart") then
				instance.Transparency = 1
			end
		end

		local clone2 = ghoulM1.SmallTentacleImpact:Clone()
		clone2.CFrame = clone.CFrame * CFrame.new(0, 0, -7)
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end
end