local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(game.ReplicatedStorage.FX)
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local origin = data.Origin
	local target = data.Target

	if (target - workspace.CurrentCamera.CFrame.p).magnitude > 1200 or masterClock:GetTime() - data.Timestamp > 2.5 then
		return
	end

	local color = Color3.fromRGB(188, 155, 93)
	local color2 = Color3.fromRGB(170, 85, 0)
	local cframe = CFrame.new(origin, target)
	local magnitude = (origin - target).magnitude
	coroutine.resume(coroutine.create(function()
		local v = cframe * CFrame.Angles(-1.5707963267948966, 0, 0)
		local magnitude2 = magnitude
		local clone = game.ReplicatedStorage.Assets.Models.FireWind:Clone()
		clone.Parent = _WorldOrigin

		-- equivalent calls inferred from this helper; original call sites unknown
		local function iterate(fn)
			for _, child in pairs(clone:GetChildren()) do
				fn(child)
			end
		end

		local v3 = {}

		for _, child in pairs(clone:GetChildren()) do
			v3[child] = child.Size * 1.5
			child.Size = createVector(0.05, 0.05, 0.05)
		end

		clone:SetPrimaryPartCFrame(v * CFrame.new(0, 10, 0))

		local function fn(p)
			TweenService:Create(p, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Size = v3[p]
			}):Play()
		end

		iterate(fn) -- equivalent call inferred; original call site unknown
		local clone2 = game.ReplicatedStorage.Assets.Models.FireWind:Clone()
		clone2.Parent = _WorldOrigin

		-- equivalent calls inferred from this helper; original call sites unknown
		local function iterate2(fn2)
			for _, child in pairs(clone2:GetChildren()) do
				fn2(child)
			end
		end

		for _, child in pairs(clone2:GetChildren()) do
			v3[child] = child.Size * 1.5
			child.Size = createVector(0.05, 0.05, 0.05)
		end

		local function fn2(p)
			TweenService:Create(p, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = v3[p]
			}):Play()
		end

		iterate2(fn2) -- equivalent call inferred; original call site unknown
		local lastTime = tick()
		local lastTime2 = tick()
		local v4 = {}
		local v5 = {}

		while tick() - lastTime < 0.8 do
			local v6 = tick() - lastTime
			local v7 = (tick() - lastTime2) * 1.15
			clone2:SetPrimaryPartCFrame(v * CFrame.new(0, magnitude2 * v6 + 40, 0) * CFrame.Angles(
				0,
				3.141592653589793 * v6 * 6,
				0
			) * CFrame.Angles(3.141592653589793, 0, 0))

			local function fn3(instance)
				if instance.Name == "Wind" or instance.Name == "Root" then
					if not v4[instance] then
						v4[instance] = math.sign(math.random() - 0.5)
					end

					local v10 = v4[instance]
					instance.CFrame *= CFrame.Angles(0, v10 * v7 * instance.Size.X / 5, 0)
				else
					local v10 = createVector(150, 300, 150) * math.cos(v6 * 3.141592653589793 * 5) * v7
					instance.Size += v10
					instance.CFrame = instance.CFrame * CFrame.new(0, v10.Y / 2, 0) * CFrame.Angles(0, v7 * 8, 0)
				end

				if not v5[instance] then
					local HSV, v10, v11 = Color3.toHSV(instance.Color)
					v5[instance] = { HSV, v10, v11 }
				end

				local v10 = math.cos(v6 * 3.141592653589793 * 20) * v7
				instance.Color = Color3.fromHSV(v5[instance][1] + v10, v5[instance][2], v5[instance][3])
			end

			iterate(fn3) -- equivalent call inferred; original call site unknown
			lastTime2 = tick()
			RunService.RenderStepped:Wait()
		end

		local function fn3(p)
			TweenService:Create(p, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = createVector(0.05, 0.05, 0.05)
			}):Play()
		end

		iterate(fn3) -- equivalent call inferred; original call site unknown

		local function fn4(p)
			TweenService:Create(p, TweenInfo.new(0.2), {
				Size = createVector(0.05, 0.05, 0.05),
				CFrame = p.CFrame * CFrame.new(0, -magnitude2 * 0.15, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
			}):Play()
		end

		iterate2(fn4) -- equivalent call inferred; original call site unknown
		wait(0.2)
		clone:Destroy()
		clone2:Destroy()
	end))
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	part.Color = color
	part.Material = "Neon"
	part.CFrame = cframe
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = Vector3.new()
	specialMesh.Parent = part
	part.Parent = workspace._WorldOrigin
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.Size = createVector(1, 1, 1)
	part2.Color = color
	part2.Material = "Neon"
	part2.CFrame = cframe
	local specialMesh2 = Instance.new("SpecialMesh")
	specialMesh2.MeshType = "Sphere"
	specialMesh2.Scale = Vector3.new()
	specialMesh2.Parent = part2
	part2.Parent = workspace._WorldOrigin
	local part3 = Instance.new("Part")
	part3.Anchored = true
	part3.CanCollide = false
	part3.Size = createVector(1, 1, 1)
	part3.Color = color
	part3.Material = "Neon"
	part3.CFrame = cframe * CFrame.Angles(0, -1.5707963267948966, 0)
	local specialMesh3 = Instance.new("SpecialMesh")
	specialMesh3.MeshType = "Cylinder"
	specialMesh3.Scale = Vector3.new()
	specialMesh3.Parent = part3
	part3.Parent = workspace._WorldOrigin
	local beamLayerTemplate = FX:WaitForChild("BeamLayerTemplate")
	local v = {}

	for _ = 0, 360, 45 do
		local clone = beamLayerTemplate:Clone()
		clone.Color = ColorSequence.new(color2)
		clone.Enabled = false
		clone.TextureLength = 22.5
		clone.TextureSpeed = 15
		clone.Width0 = 0
		clone.Width1 = 0
		clone.Transparency = NumberSequence.new(0)
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2
		attachment.Parent = part3
		attachment2.Parent = part3
		clone.Parent = part3
		table.insert(v, {
			B = clone,
			a0 = attachment,
			a1 = attachment2
		})
	end

	for _, v2 in next, v, nil do
		v2.B.Enabled = true
	end

	local lastTime = tick()
	local v2 = {
		[part] = { Color3.toHSV(part.Color) },
		[part2] = { Color3.toHSV(part2.Color) },
		[part3] = { Color3.toHSV(part3.Color) },
		Particle = { Color3.toHSV(color2) }
	}
	local lastTime2 = tick()

	while tick() - lastTime < 0.8 do
		local v3 = math.min(1, (tick() - lastTime) / 0.8)
		local v4 = tick() - lastTime2
		local v5 = math.clamp(magnitude * v3, 0, magnitude)
		local v6 = math.clamp(v3 * 60, 0, 22) + 4 + math.sin(v3 * 40) * 4

		if v3 > 0.8 then
			v3 = math.max(0, 0.8 - (v3 - 0.8) / 0.2 * 0.8)
			v6 = v3 * 34
		end

		specialMesh.Scale = Vector3.new(v6, v6, v6)
		specialMesh.Offset = Vector3.new(0, 0, -v6 / 2)
		specialMesh2.Scale = specialMesh.Scale
		specialMesh2.Offset = Vector3.new(0, 0, -v5 - v6 / 2)
		specialMesh3.Scale = Vector3.new(v5, v6, v6)
		specialMesh3.Offset = Vector3.new(-v5 / 2 - v6 / 2, 0, 0)
		local v7 = math.cos(v3 * 3.141592653589793 * 6) * v4 * 3
		part.Color = Color3.fromHSV(v2[part][1] + v7, v2[part][2], v2[part][3])
		part2.Color = Color3.fromHSV(v2[part2][1] + v7, v2[part2][2], v2[part2][3])
		part3.Color = Color3.fromHSV(v2[part3][1] + v7, v2[part3][2], v2[part3][3])
		local width = v6 * 3.141592653589793 * 2 / 8

		for k, v9 in next, v, nil do
			local B = v9.B
			local a0 = v9.a0
			local a1 = v9.a1
			local v10 = math.rad(45 * (k - 1))
			local v11 = CFrame.new(0, 0, -v6 / 4) * CFrame.Angles(0, 0, v10) * CFrame.new(0, v6 / 2 + 0.1, 0) * CFrame.Angles(
				0,
				0,
				1.57
			)
			B.Width0 = width
			B.Width1 = B.Width0
			a0.CFrame = CFrame.Angles(0, 1.57, 0) * v11
			a1.CFrame = CFrame.Angles(0, 1.57, 0) * CFrame.new(0, 0, specialMesh3.Offset.X * 2 + v6 / 2) * v11
			B.TextureLength = v5 / 22.5
			B.Color = ColorSequence.new(Color3.fromHSV(v2.Particle[1] + v7, v2.Particle[2], v2.Particle[3]))
		end

		lastTime2 = tick()
		RunService.RenderStepped:Wait()
	end

	part3:Destroy()
	part:Destroy()
	part2:Destroy()
end