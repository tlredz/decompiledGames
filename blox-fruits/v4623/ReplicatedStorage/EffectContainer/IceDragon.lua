local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
return function(data)
	local cFrame = data.CFrame
	local targetCFrame = data.TargetCFrame
	local speed = data.Speed or 220
	local _ = data.Material
	local _ = data.Color

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	Util.Sound:Play("Throw", cFrame)
	local v = math.min(700, (cFrame.p - targetCFrame.p).magnitude)
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local v2 = cframe * CFrame.new(0, 0, -v)
	local cframe2 = CFrame.Angles(-1.4835298641951802, 0.08726646259971647, -2.181661564992912)
	local clone = game.ReplicatedStorage.Assets.Models.IceDragonHead:Clone()
	clone.CFrame = cframe
	clone.Material = "Neon"
	clone.Color = Color3.fromRGB(139, 195, 255)
	clone.Parent = workspace._WorldOrigin

	local function segment(cframe3, magnitude)
		local part = Instance.new("Part")
		part.Name = "Segment"
		part.Color = Color3.fromRGB(139, 195, 255)
		part.Material = "Neon"
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(8, 8, magnitude)
		part.CFrame = cframe3 * CFrame.new(0, 0, -magnitude / 2)
		part.Parent = clone
		local v3 = {}

		for _ = 1, 1 do
			local v4 = math.random() * 3.141592653589793 * 2
			local part2 = Instance.new("Part")
			part2.Name = "Segment"
			part2.Color = Color3.fromRGB(139, 195, 255)
			part2.Material = "Neon"
			part2.Anchored = true
			part2.CanCollide = false
			part2.Size = Vector3.new(8.25 + math.random(), 8.25 + math.random(), magnitude + v4 / 3.141592653589793)
			part2.CFrame = cframe3 * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(0, 0, v4)
			part2.Parent = clone
			table.insert(v3, { part2, v4 })
		end

		task.delay(0.125, function()
			part.Material = "Glass"

			for _, v4 in pairs(v3) do
				v4[1].Material = "Glass"
			end
		end)
		table.insert(v3, { part, 0 })
		return {
			SetCFrame = function(p)
				for _, v4 in pairs(v3) do
					v4[1].CFrame = p * CFrame.Angles(0, 0, v4[2])
				end
			end,
			SetLength = function(p)
				for _, v4 in pairs(v3) do
					v4[1].Size = Vector3.new(v4[1].Size.X, v4[1].Size.Y, p + v4[2] / 3.141592653589793)
				end
			end
		}
	end

	local function fn(cframe3, p, p2)
		local clone2 = ReplicatedStorage.Assets.Models.IceSpearShockwave:Clone()
		clone2.CFrame = cframe3 * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966)
		clone2.Mesh.Scale = createVector(1, 1, 1) * p / 250
		clone2.Parent = _WorldOrigin
		local tween = TweenService:Create(clone2, TweenInfo.new(0.3), {
			Transparency = 1
		})
		local tween2 = TweenService:Create(clone2.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Scale = clone2.Mesh.Scale * createVector(2, 3, 2)
		})
		tween.Completed:Connect(function()
			if not p2 then
				wait(clone2.Dust.Lifetime.Max + 0.1)
			end

			clone2:Destroy()
		end)
		tween:Play()
		tween2:Play()

		if not p2 then
			clone2.Dust:Emit(7)
		end
	end

	local function lerp(object, p, p2)
		return object:lerp(p, p2)
	end

	local v3 = v / 20
	local random = Random.new()
	local v4 = cframe:Lerp(v2, 0.3333333333333333) * CFrame.new(random:NextNumber(-8, 8) * v3, 125, 0)
	local v5 = cframe:Lerp(v2, 0.6666666666666666) * CFrame.new(random:NextNumber(-8, 8) * v3, 125, 0)

	local function cubicBezier(p, cframe3, object, object2, p2)
		local lerped = cframe3:lerp(object, p)
		local lerped2 = object:lerp(object2, p)
		local lerped3 = object2:lerp(p2, p)
		return (lerped:lerp(lerped2, p):lerp(lerped2:lerp(lerped3, p), p))
	end

	local v6 = masterClock:GetTime() - data.Timestamp
	local v7 = math.max(v / speed - v6, 0.3)
	local cFrame2 = clone.CFrame
	local lastTime = tick()
	local v8 = nil
	local now = 0

	while tick() - lastTime < v7 do
		local v9 = math.min(1, (tick() - lastTime) / v7)
		local v10 = cubicBezier(v9, cframe, v4, v5, v2)
		local v11 = v9 <= 0.0001 and cframe * CFrame.new(0, 0, 1) or clone.CFrame
		local cframe3 = CFrame.new(v10.p, v10.p - (v11.p - v10.p).unit)
		clone.CFrame = cframe3 * cframe2

		if v8 then
			local magnitude = (cframe3.p - cFrame2.p).Magnitude
			local cframe4 = CFrame.new(cframe3.p, cFrame2.p)
			v8.SetLength(magnitude)
			v8.SetCFrame(cframe4 * CFrame.new(0, 0, -magnitude / 2))
		end

		if tick() - now > 0.05 then
			now = tick()
			v8 = segment(CFrame.new(cframe3.p, cFrame2.p), (cframe3.p - cFrame2.p).Magnitude)
			fn(cframe3, 24)
			cFrame2 = cframe3
		end

		RunService.RenderStepped:Wait()
	end

	local v9 = (v2.p - cFrame2.p).Magnitude + 6
	local cframe3 = CFrame.new(v2.p, cFrame2.p)
	v8.SetLength(v9)
	v8.SetCFrame(cframe3 * CFrame.new(0, 0, -v9 / 2))
	Util.Sound:Play("CannonFire", v2.p)
	coroutine.resume(coroutine.create(function()
		for _ = 1, 7 do
			Effect.new("IceRockExplosion"):replicate({
				CFrame = targetCFrame,
				Scale = 60
			})
			wait()
		end
	end))
	clone.Dust.Enabled = false
	task.delay(1.8, function()
		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local tween = TweenService:Create(part, TweenInfo.new(0.1 + math.random() * 0.4, Enum.EasingStyle.Quad), {
				Size = part.Size * createVector(0, 0, 1),
				CFrame = part.CFrame
			})
			local v10 = part
			tween.Completed:Connect(function()
				v10:Destroy()
			end)
			tween:Play()
		end
	end)
	local tween = TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		Size = createVector(0.05, 0.05, 0.05),
		CFrame = clone.CFrame
	})
	tween.Completed:Connect(function()
		clone.Transparency = 1
		wait(2.3)
		clone:Destroy()
	end)
	tween:Play()
	Util.Sound:Play("DragonExplosion", targetCFrame)
	local ray = Util.Ray
	local v10 = targetCFrame.p + createVector(0, 5, 0)
	local v11 = { workspace.Enemies, workspace.Characters, workspace.Boats }
	local v12, vector2, v13 = ray(v10, createVector(0, -15, 0), v11)
	local v14 = ({ GetWaterHeightAtLocation(vector2) })[1]

	if v12 or vector2.Y < v14 then
		if vector2.Y < v14 then
			vector2 = Vector3.new(vector2.X, v14, vector2.Z)
		end

		local cFrame3 = CFrame.new(vector2, vector2 + (not v12 and createVector(0, 1, 0) or v13)) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		Effect.new("Ice.Age"):replicate({
			CFrame = cFrame3,
			Scale = 25.520833333333332,
			Offset = 37.8984375,
			Radius = 75.796875,
			Duration = 0.15
		})
	end
end