local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local gearSelect = FX:WaitForChild("DracoRace").GearSelect
local waitForStream = Util.WaitForStream
local islandModel = waitForStream.workspace.Map.Waterfall.IslandModel()
local folder = waitForStream[islandModel].Firepit()
local v = waitForStream[folder].Fire()
local maid = Util.Maid.new()

local function cubicBezier(p, p2, p3, p4, p5)
	local v2 = 1 - p5
	return v2 ^ 3 * p + 3 * v2 ^ 2 * p5 * p2 + 3 * v2 * p5 ^ 2 * p3 + p5 ^ 3 * p4
end

function quadBezier(p, p2, p3, p4)
	local p5 = p2.p
	local p6 = p3.p
	local p7 = p4.p
	return (CFrame.new((1 - p) ^ 2 * p5 + 2 * (1 - p) * p * p6 + p ^ 2 * p7, (p4 * CFrame.new(0, 0, -25)).p))
end

local function getBezierDistance(p, p2, p3, p4)
	local v2 = p
	local total = 0

	for i = 0, 1, 0.001 do
		if i == 0 then
			continue
		end

		local v3 = 1 - i
		local v4 = v3 ^ 3 * p + 3 * v3 ^ 2 * i * p2 + 3 * v3 * i ^ 2 * p3 + i ^ 3 * p4
		total += (v4 - v2).Magnitude
		v2 = v4
	end

	return total
end

local function travelBezierDistance(p: number, p2: number, position, position2, position3, position4)
	local v2 = 1 - p
	local v3 = v2 ^ 3 * position + 3 * v2 ^ 2 * p * position2 + 3 * v2 * p ^ 2 * position3 + p ^ 3 * position4
	local v4 = p + 0.001
	local v5 = 1 - v4
	local v6 = (v5 ^ 3 * position + 3 * v5 ^ 2 * v4 * position2 + 3 * v5 * v4 ^ 2 * position3 + v4 ^ 3 * position4 - v3).Magnitude < p2 and 0.001 or 0.00001
	local v7 = p2
	local total = 0

	for i = p, 1, v6 do
		if i == p then
			continue
		end

		local v8 = 1 - i
		local v9 = v8 ^ 3 * position + 3 * v8 ^ 2 * i * position2 + 3 * v8 * i ^ 2 * position3 + i ^ 3 * position4
		total += (v9 - v3).Magnitude
		local v10 = math.abs(p2 - total)

		if v7 < v10 then
			if i == p + v6 then
				return v9, i
			end

			return v3, i - v6
		else
			v7 = v10
			v3 = v9
		end
	end

	return v3, 1
end

local function TravelBezier(clone, position, position2, position3, position4, p, p2)
	if typeof(position) == "CFrame" then
		position = position.Position
	end

	if typeof(position2) == "CFrame" then
		position2 = position2.Position
	end

	if typeof(position3) == "CFrame" then
		position3 = position3.Position
	end

	if typeof(position4) == "CFrame" then
		position4 = position4.Position
	end

	getBezierDistance(position, position2, position3, position4)
	clone.CFrame = CFrame.new(
		position,
		0.8573749999999999 * position + 0.135375 * position2 + 0.007125 * position3 + 0.00012500000000000003 * position4
	)
	clone.Parent = workspace._WorldOrigin
	local v2 = 0

	while v2 < 1 do
		local v3 = task.wait()
		local v4 = v3 * p + p2 * v3 * v3 / 2
		p = math.max(p + p2 * v3, 11)
		local v5
		v5, v2 = travelBezierDistance(v2, v4, position, position2, position3, position4)
		local magnitude = (clone.CFrame.Position - v5).Magnitude
		local _ = v4 - magnitude

		if magnitude < 0.01 then
			clone.CFrame += v5 - clone.CFrame.Position
		else
			clone.CFrame = CFrame.new(clone.CFrame.Position, v5) * CFrame.new(0, 0, -magnitude)
		end
	end

	return p
end

local function calculateControlPoints(p, p2, p3)
	local magnitude = (p2 - p).Magnitude
	local magnitude2 = (p3 - p2).Magnitude
	return
		p2 - 0.5 * magnitude / (magnitude + magnitude2) * (p3 - p),
		p2 + 0.5 * magnitude2 / (magnitude + magnitude2) * (p3 - p)
end

local function getBeziers(...)
	local positions = { ... }

	if #positions == 1 then
		positions = positions[1]
	end

	for k, v2 in pairs(positions) do
		if typeof(v2) ~= "Vector3" then
			positions[k] = v2.Position
		end
	end

	local result = {}

	for i = 1, #positions, 2 do
		local v2 = positions[i]
		local v3 = positions[i + 2]
		local v4 = positions[i + 1]

		if not v3 then
			break
		end

		local magnitude = (v4 - v2).Magnitude
		local magnitude2 = (v3 - v4).Magnitude
		table.insert(result, {
			v2,
			v4 - 0.5 * magnitude / (magnitude + magnitude2) * (v3 - v2),
			v4 + 0.5 * magnitude2 / (magnitude + magnitude2) * (v3 - v2),
			v3
		})
	end

	return result
end

local v2 = {}

for _, effect in pairs(folder:GetDescendants()) do
	if effect.Parent.Name == "Blast" then
		continue
	end

	if effect:IsA("Beam") then
		v2[effect] = {
			TextureSpeed = effect.TextureSpeed,
			Transparency = effect.Transparency
		}
	elseif effect:IsA("ParticleEmitter") then
		v2[effect] = {
			Enabled = effect.Enabled,
			Speed = effect.Speed,
			Acceleration = effect.Acceleration,
			Drag = effect.Drag,
			Lifetime = effect.Lifetime,
			Transparency = effect.Transparency,
			Size = effect.Size,
			Squash = effect.Squash,
			Brightness = effect.Brightness,
			LockedToPart = effect.LockedToPart,
			TimeScale = effect.TimeScale
		}
		effect.LockedToPart = true
	end
end

local v3 = {}

local function UpdateScale(effect, p, p2)
	if effect.Texture == "rbxassetid://13128514350" and effect.Parent.Name == "Attach_4" then
		p *= 2
	end

	if not v3[effect] then
		v3[effect] = 1
		effect.Destroying:Once(function()
			v3[effect] = nil
		end)
	end

	local keypoints = effect.Size.Keypoints
	local numberSequenceKeypoints = {}

	for _, keypoint in pairs(keypoints) do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value / v3[effect] * p,
				keypoint.Envelope / v3[effect] * p
			)
		)
	end

	effect.Size = NumberSequence.new(numberSequenceKeypoints)

	if not p2 then
		effect.Speed = NumberRange.new(effect.Speed.Min / v3[effect] * p, effect.Speed.Max / v3[effect] * p)
		effect.Acceleration = effect.Acceleration / v3[effect] * p
		effect.Drag = effect.Drag / v3[effect] * p
	end

	v3[effect] = p
end

local v4 = false

local function EaseIn(p)
	local bindable = p.Bindable
	local spriteColors = p.SpriteColors

	if not v4 then
		folder.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
		v4 = true
	end

	for beam, _ in pairs(v2) do
		if beam:IsA("Beam") then
			beam.TextureSpeed = 0
		else
			TweenService:Create(beam, TweenInfo.new(2), {
				TimeScale = 0
			}):Play()
		end
	end

	maid:GiveTask(function()
		for k, v5 in pairs(v2) do
			for k2, timeScale in pairs(v5) do
				if k2 == "TimeScale" then
					TweenService:Create(k, TweenInfo.new(0.01), {
						TimeScale = timeScale
					}):Play()
				else
					k[k2] = timeScale
				end
			end
		end
	end)
	local texture = Instance.new("Texture")
	texture.Texture = "http://www.roblox.com/asset/?id=1599553587"
	texture.Color3 = Color3.fromRGB(0, 0, 0)
	maid:GiveTask(texture)
	local meshesdragondojo_Plane010 = islandModel:WaitForChild("Meshes/dragondojo_Plane.010")
	local v5 = {
		"Top",
		"Bottom",
		"Right",
		"Left",
		"Front",
		"Back"
	}
	local clones = {}

	for _, childName in pairs({
		"Meshes/dragondojo_Plane.008",
		"Meshes/dragondojo_Plane",
		"Meshes/dragondojo_Cube",
		"Meshes/dragondojo_Plane.013",
		"Meshes/dragondojo_Plane.010"
	}) do
		local child = islandModel:FindFirstChild(childName)

		if not child then
			continue
		end

		for _, v6 in pairs(v5) do
			local clone = texture:Clone()
			clone.Transparency = 0
			clone.Face = Enum.NormalId[v6]
			clone.Parent = child
			table.insert(clones, clone)
			maid:GiveTask(clone)
		end
	end

	local sound = Util.Sound
	local Players = game:GetService("Players")
	sound:Play("BF_Dojo_Gear_Selector_Activate_01", Players.LocalPlayer)
	local v6 = false
	task.spawn(function()
		local currentCamera = workspace.CurrentCamera
		local cFrame = folder.Fire.CFrame
		local cFrame2 = currentCamera.CFrame
		local v7 = cFrame * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.new(0, 10, 30)
		local v8 = cFrame2:Lerp(v7, 0.5) * CFrame.new(0, 0, 10)
		currentCamera.CameraType = Enum.CameraType.Scriptable
		local v9 = 0

		while v9 < 1 do
			v9 = math.min(v9 + task.wait() * 1.6, 1)
			currentCamera.CFrame = quadBezier(v9, cFrame2, v8, v7)
		end

		local cFrame3 = currentCamera.CFrame

		while not v6 do
			if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
				cFrame3 = currentCamera.CFrame
			else
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.CFrame = cFrame3
			end

			task.wait()
		end
	end)
	maid:GiveTask(function()
		v6 = true
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		task.wait()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
	local total = 40
	local v7 = {}
	local v8 = {}

	while total < 1500 do
		local v9 = task.wait()
		total += 1000 * v9

		if total > 300 then
			local v10 = math.min(math.floor((total - 300) / 10), 201)

			for i = 1, v10 do
				if i == 201 then
					break
				end

				if i < v10 and v7[i] then
					v7[i].Transparency -= v9 * 0.4

					if v7[i].Transparency <= 0.8 and i < 30 then
						v7[i].Transparency = 1
						table.insert(v8, v7[i])
						v7[i] = false
					elseif v7[i].Transparency <= 0.8 then
						v7[i].Transparency = 0
					end
				end

				if v7[i + 1] ~= nil then
					continue
				end

				local clone = v8[1]

				if clone then
					table.remove(v8, 1)
				else
					clone = gearSelect.Inverted:Clone()
					clone.Parent = workspace._WorldOrigin
					maid:GiveTask(clone)
				end

				clone.Transparency = 0.965
				clone.Size = gearSelect.Inverted.Size + createVector(1, 1, 1) * i / 2
				clone.CFrame = v.CFrame * CFrame.new(4.98738003, 3.31114197, -0.273704529)
				table.insert(v7, clone)
			end
		end

		for _, v10 in pairs(clones) do
			v10.StudsPerTileU = total
			v10.StudsPerTileV = total
			v10.OffsetStudsU = total / 2 + total / 800 * 7
			v10.OffsetStudsV = total / 2 - total / 800 * 12.5
		end
	end

	local humanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
	folder:GetPivot()
	folder:GetPivot():ToObjectSpace(humanoidRootPart.CFrame)
	local part = Instance.new("Part", workspace._WorldOrigin)
	part.Anchored = true
	part.Color = Color3.fromRGB(0, 0, 0)
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.CFrame = meshesdragondojo_Plane010.CFrame + createVector(0, 1800, 0)
	part.Size = createVector(400, 0.286, 400)
	maid:GiveTask(part)

	for i = 0, 270, 90 do
		local clone = part:Clone()
		clone.CFrame = part.CFrame * CFrame.new(0, 200, 0) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			0,
			(math.rad(i))
		) * CFrame.new(0, -200, 0)
		clone.Parent = workspace._WorldOrigin
		maid:GiveTask(clone)
	end

	local clone = part:Clone()
	clone.CFrame = part.CFrame * CFrame.new(0, 400, 0) * CFrame.Angles(3.141592653589793, 0, 0)
	clone.Parent = workspace._WorldOrigin
	maid:GiveTask(clone)
	local v9 = {
		Color = game.Lighting.BaseAtmosphere.Color,
		Haze = game.Lighting.BaseAtmosphere.Haze,
		Density = game.Lighting.BaseAtmosphere.Density,
		Offset = game.Lighting.BaseAtmosphere.Offset
	}
	game.Lighting.BaseAtmosphere.Color = Color3.fromRGB(0, 0, 0)
	game.Lighting.BaseAtmosphere.Haze = 10
	game.Lighting.BaseAtmosphere.Density = 0
	game.Lighting.BaseAtmosphere.Offset = 0
	maid:GiveTask(function()
		for k, v10 in pairs(v9) do
			game.Lighting.BaseAtmosphere[k] = v10
		end
	end)
	local pivot = folder:GetPivot()
	local objectSpace = meshesdragondojo_Plane010.CFrame:ToObjectSpace(folder:GetPivot())
	folder:PivotTo(part.CFrame * objectSpace)
	workspace.CurrentCamera.CFrame = folder.Fire.CFrame * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.new(
		0,
		10,
		30
	)
	maid:GiveTask(function()
		folder:PivotTo(pivot)
	end)
	task.spawn(function()
		local _ = workspace.CurrentCamera
		local cFrame = folder.Fire.CFrame
		local v10 = cFrame * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.new(0, 10, 30)
		local v11 = cFrame * CFrame.new(
			-7.47627354,
			9.91968727,
			0,
			-0.0161826909,
			0.756921649,
			-0.653305411,
			-1.49011612e-8,
			0.653391004,
			0.757020772,
			0.999869108,
			0.012250632,
			-0.0105736256
		)
		local v12 = v10:Lerp(v11, 0.5) * CFrame.new(0, 30, 40)
		local v13 = 0

		while v13 < 1 do
			v13 = math.min(v13 + task.wait() / (3 - (1.3 - v13) ^ 2), 1)
			workspace.CurrentCamera.CFrame = quadBezier(v13, v10, v12, v11)
		end
	end)
	Util.CameraShaker:ShakeOnce(9, 4, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 5))

	for _, child in pairs(folder.Fire.Blast:GetChildren()) do
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(child, TweenInfo.new(0.01), {
			TimeScale = 0.3
		}):Play()
		child:Emit(child:GetAttribute("EmitCount"))
	end

	task.spawn(function()
		local lastTime = os.clock()

		while lastTime + 0.6 > os.clock() and task.wait() do
			local v10 = math.log10(math.min((os.clock() - lastTime) / 0.6, 1) * 9 + 1)

			for effect in pairs(v2) do
				if effect:IsA("ParticleEmitter") then
					local keypoints = v2[effect].Transparency.Keypoints
					local numberSequenceKeypoints = {}

					for _, keypoint in pairs(keypoints) do
						table.insert(
							numberSequenceKeypoints,
							NumberSequenceKeypoint.new(
								keypoint.Time,
								math.max(v10 * 1.3, keypoint.Value),
								keypoint.Envelope
							)
						)
					end

					effect.Transparency = NumberSequence.new(numberSequenceKeypoints)
					local keypoints2 = v2[effect].Squash.Keypoints
					local numberSequenceKeypoints2 = {}

					for _, keypoint in pairs(keypoints2) do
						table.insert(
							numberSequenceKeypoints2,
							NumberSequenceKeypoint.new(keypoint.Time, (1 - keypoint.Value) * v10 * 2, keypoint.Envelope)
						)
					end

					effect.Squash = NumberSequence.new(numberSequenceKeypoints2)
					local keypoints3 = v2[effect].Size.Keypoints
					local numberSequenceKeypoints3 = {}

					for _, keypoint in pairs(keypoints3) do
						table.insert(
							numberSequenceKeypoints3,
							NumberSequenceKeypoint.new(
								keypoint.Time,
								keypoint.Value * (1 - v10 * 0.4),
								keypoint.Envelope
							)
						)
					end

					effect.Size = NumberSequence.new(numberSequenceKeypoints3)
					effect.Brightness = v2[effect].Brightness * math.max(1 - v10 * 1.6, 0)

					if effect.TimeScale == 0 then
						effect.Drag = 1000000000
						effect.TimeScale = 0.0002
					elseif effect.Drag == 1000000000 then
						effect.Drag = 0
						effect.Acceleration = createVector(0, 10000000000, 0)
					elseif effect.Acceleration.Y == 10000000000 then
						effect.Acceleration = createVector(0, 0, 0)
					end
				elseif effect:IsA("Beam") then
					local keypoints = v2[effect].Transparency.Keypoints
					local numberSequenceKeypoints = {}

					for _, keypoint in pairs(keypoints) do
						table.insert(
							numberSequenceKeypoints,
							NumberSequenceKeypoint.new(
								keypoint.Time,
								math.max(v10 * 1.3, keypoint.Value),
								keypoint.Envelope
							)
						)
					end

					effect.Transparency = NumberSequence.new(numberSequenceKeypoints)
				end
			end
		end
	end)
	local v10 = v.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
	local v11 = {
		getBeziers(
			v10 * CFrame.new(-0.2627, -0.6867, -1.218),
			v10 * CFrame.new(-11.6627, -0.6867, 20.882),
			v10 * CFrame.new(-21.0627, 11.3133, 20.882),
			v10 * CFrame.new(-26.5627, 20.6133, 11.382),
			v10 * CFrame.new(-24.0627, 11.3133, -0.318),
			v10 * CFrame.new(-18.3627, 2.5133, -8.318),
			v10 * CFrame.new(0.0373, 11.3133, -16.218),
			v10 * CFrame.new(15.9373, 27.7133, -11.218),
			v10 * CFrame.new(5.4373, 11.3133, 16.282),
			v10 * CFrame.new(-3.9627, 6.8133, 20.182),
			v10 * CFrame.new(-13.0627, 11.3133, 11.082),
			v10 * CFrame.new(-9.3627, 14.1133, -1.718),
			v10 * CFrame.new(0.3303, 3, -1.195)
		),
		getBeziers(
			v10 * CFrame.new(-2.6627, -0.6153, 8.982),
			v10 * CFrame.new(-2.6627, 5.6847, 29.882),
			v10 * CFrame.new(21.0373, 11.1847, 20.582),
			v10 * CFrame.new(26.4373, 14.7847, 7.582),
			v10 * CFrame.new(15.9373, 17.8847, -5.318),
			v10 * CFrame.new(7.0373, 17.3811, -10.118),
			v10 * CFrame.new(-7.6627, 9.7847, -8.718),
			v10 * CFrame.new(-17.9627, 6.5847, -3.818),
			v10 * CFrame.new(-23.5627, 9.7847, 6.382),
			v10 * CFrame.new(-23.5627, 14.1847, 17.982),
			v10 * CFrame.new(-5.4627, 21.2847, 27.582),
			v10 * CFrame.new(8.6373, 28.7847, 22.982),
			v10 * CFrame.new(8.1373, 33.1847, 14.882),
			v10 * CFrame.new(-6.8627, 36.8847, -8.218),
			v10 * CFrame.new(-15.9627, 23.4847, 5.182),
			v10 * CFrame.new(-15.7627, 19.5847, 12.782),
			v10 * CFrame.new(-8.2627, 17.9847, 19.182),
			v10 * CFrame.new(8.6373, 18.6847, 21.882),
			v10 * CFrame.new(13.2373, 19.3847, 10.9127),
			v10 * CFrame.new(10.6373, 17.3, 3.5127),
			v10 * CFrame.new(4, 3, -0.3)
		),
		getBeziers(
			v10 * CFrame.new(-1.3627, -0.575, 2.382),
			v10 * CFrame.new(16.1373, -0.575, -6.518),
			v10 * CFrame.new(14.3373, 7.125, -22.718),
			v10 * CFrame.new(0.1373, 14.525, -32.318),
			v10 * CFrame.new(-16.3627, 10.425, -21.118),
			v10 * CFrame.new(-21.0627, 7.925, -8.818),
			v10 * CFrame.new(-16.3627, 14.025, 13.182),
			v10 * CFrame.new(-7.3627, 18.225, 23.382),
			v10 * CFrame.new(10.1373, 9.825, 19.382),
			v10 * CFrame.new(20.1373, 0.125, 7.182),
			v10 * CFrame.new(0.5693, 10.1003, 3.0386),
			v10 * CFrame.new(-4.1627, 9.9133, 3.082),
			v10 * CFrame.new(-5.1307, 3, 0.405)
		),
		getBeziers(
			v10 * CFrame.new(0.6373, 0.2133, 2.382),
			v10 * CFrame.new(-15.0627, -1.3867, -8.318),
			v10 * CFrame.new(-5.1627, 4.4133, -14.418),
			v10 * CFrame.new(10.3373, 11.2133, -14.418),
			v10 * CFrame.new(16.0373, 8.1133, -1.718),
			v10 * CFrame.new(14.3373, 6.8133, 3.382),
			v10 * CFrame.new(4.5465, 7.0133, 13.682),
			v10 * CFrame.new(-3.6535, 10.9133, 22.882),
			v10 * CFrame.new(11.2465, 23.2133, 17.382),
			v10 * CFrame.new(24.1465, 32.0133, 2.982),
			v10 * CFrame.new(-2.2535, 23.2133, -10.318),
			v10 * CFrame.new(-15.4535, 18.6133, -8.918),
			v10 * CFrame.new(-11.5535, 18.3133, 5.882),
			v10 * CFrame.new(-1.4535, 18.3133, 15.182),
			v10 * CFrame.new(11.2465, 18.3133, 9.682),
			v10 * CFrame.new(17.0465, 15.5133, 0.682),
			v10 * CFrame.new(6.7465, 13.2133, -4.518),
			v10 * CFrame.new(4.5465, 11.5133, -5.218),
			v10 * CFrame.new(1.7583, 4, -4.691)
		),
		getBeziers(
			v10 * CFrame.new(-2.5627, -0.0654, 2.382),
			v10 * CFrame.new(-6.1627, 4.0346, -9.618),
			v10 * CFrame.new(1.7373, 6.1346, -9.618),
			v10 * CFrame.new(11.1373, 7.5346, -0.918),
			v10 * CFrame.new(11.1373, 9.4346, 12.782),
			v10 * CFrame.new(-0.8539, 12.8346, 19.082),
			v10 * CFrame.new(-8.8539, 16.9346, 12.682),
			v10 * CFrame.new(-10.3539, 21.6346, 3.482),
			v10 * CFrame.new(-2.4539, 24.7346, -8.418),
			v10 * CFrame.new(2.3461, 23.5346, -10.818),
			v10 * CFrame.new(5.1461, 18.6346, -4.918),
			v10 * CFrame.new(3.0461, 11.6346, 2.682),
			v10 * CFrame.new(-1.4539, 9.1346, 2.782),
			v10 * CFrame.new(-5.3539, 6.9346, -0.118),
			v10 * CFrame.new(-2.5539, 4.0302, -5.118)
		)
	}

	for k, v12 in pairs(v11) do
		local v13 = k
		local v14 = v12
		task.spawn(function()
			local clone2 = gearSelect.FireSpriteColors:FindFirstChild(spriteColors[v13] or "Black"):Clone()
			maid:GiveTask(clone2)
			local v15 = { clone2.Attach_4.Particle_1, clone2.Attach_4.Particle_2 }
			v15[1].Enabled = false
			v15[2].Enabled = false
			task.spawn(function()
				local v16 = false
				clone2.Destroying:Once(function()
					v16 = true
				end)

				while not v16 do
					task.wait(clone2.Attach_4.Particle_1:GetAttribute("EmitDelay"))

					if not clone2.Parent then
						continue
					end

					v15[1]:Emit(1)
					v15[2]:Emit(1)
				end
			end)
			clone2.CFrame = folder.Fire.CFrame * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(0, 0, 20)
			local v16 = false
			task.delay(1.4, function()
				local total2 = 0

				while total2 < 1 do
					total2 += task.wait() * 1.5

					for i, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							if effect.Texture ~= "rbxassetid://13128514350" or effect.Parent.Name ~= "Attach_4" then
								effect.Enabled = false
							end

							UpdateScale(effect, 1 - ((v13 == 5 or v13 == 4) and 0.9 or 0.8) * total2, true)
						elseif effect:IsA("Trail") then
							effect.WidthScale = NumberSequence.new(1 - total2, 0)
						end
					end
				end

				v16 = true
			end)
			local v17 = {}
			local v18 = 0

			for k2, v19 in pairs(v14) do
				v17[k2] = getBezierDistance(v19[1], v19[2], v19[3], v19[4])
				v18 += v17[k2]
			end

			local v19 = v18 * -3 / 6.5
			os.clock()

			for k2, v20 in pairs(v14) do
				v18 = TravelBezier(clone2, v20[1], v20[2], v20[3], v20[4], v18, v19)
			end

			while not v16 do
				task.wait()
			end

			v15[1]:SetAttribute("Color", v15[1].Color.Keypoints[1].Value)
			v15[2]:SetAttribute("Color", v15[2].Color.Keypoints[1].Value)
			local count = 0
			local object = setmetatable({
				_Hover = 0,
				_Originals = { v15[1].Size, v15[2].Size },
				UpdateView = function(self)
					local color = v15[1]:GetAttribute("Color")
					local color2 = v15[2]:GetAttribute("Color")

					if (spriteColors[v13] or "Black") ~= "Black" then
						v15[1].Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), self.Hover / 4))
						v15[2].Color = ColorSequence.new(color2:Lerp(Color3.new(1, 1, 1), self.Hover / 4))
					end

					self:UpdateSize(1)
					self:UpdateSize(2)
				end,
				UpdateSize = function(self, p3)
					local keypoints = self._Originals[p3].Keypoints
					local numberSequenceKeypoints = {}

					for k2, keypoint in pairs(keypoints) do
						table.insert(
							numberSequenceKeypoints,
							NumberSequenceKeypoint.new(
								keypoint.Time,
								keypoint.Value * (1 + self._Hover),
								keypoint.Envelope * (1 + self._Hover)
							)
						)
					end

					v15[p3].Size = NumberSequence.new(numberSequenceKeypoints)
				end,
				ColorTask = 0,
				LerpColor = function(self, p2, duration)
					spriteColors[v13] = p2
					self.ColorTask += 1
					local colorTask = self.ColorTask
					local particle_1 = gearSelect.FireSpriteColors[p2].Attach_4.Particle_1
					local particle_2 = gearSelect.FireSpriteColors[p2].Attach_4.Particle_2
					local color = v15[1]:GetAttribute("Color")
					local color2 = v15[2]:GetAttribute("Color")
					local value = particle_1.Color.Keypoints[1].Value
					local value2 = particle_2.Color.Keypoints[1].Value
					TweenService:Create(v15[1], TweenInfo.new(duration), {
						Brightness = particle_1.Brightness,
						LightEmission = particle_1.LightEmission
					}):Play()
					TweenService:Create(v15[2], TweenInfo.new(duration), {
						Brightness = particle_2.Brightness,
						LightEmission = particle_2.LightEmission
					}):Play()
					local v20 = 0

					while self.ColorTask == colorTask do
						v20 = math.min(v20 + task.wait() / duration, 1)

						if self.ColorTask ~= colorTask then
							break
						end

						v15[1]:SetAttribute("Color", color:Lerp(value, v20))
						v15[2]:SetAttribute("Color", color2:Lerp(value2, v20))
						self:UpdateView()

						if v20 >= 1 then
							break
						end
					end
				end
			}, {
				__index = function(p2, p3)
					return (rawget(p2, "_" .. p3))
				end,
				__newindex = function(p2, p3, p4)
					p2["_" .. p3] = p4
					task.spawn(p2.UpdateView, p2)
				end
			})
			maid:GiveTask(bindable.Event:Connect(function(p2, p3, ...)
				if p3 ~= v13 then
					return
				end

				count += 1

				if p2 == "Hover" then
					local v20 = count

					while v20 == count do
						local v21 = task.wait()

						if v20 ~= count then
							return
						end

						object.Hover = math.min(object.Hover + v21, 0.3)

						if object.Hover >= 0.3 then
							return
						end
					end
				elseif p2 == "StopHover" then
					local v20 = count

					while v20 == count do
						local v21 = task.wait()

						if v20 ~= count then
							return
						end

						object.Hover = math.max(object.Hover - v21, 0)

						if object.Hover <= 0 then
							return
						end
					end
				elseif p2 == "ChangeColor" then
					local sound2 = Util.Sound
					local Players2 = game:GetService("Players")
					sound2:Play("BF_Dojo_Gear_Selector_Select_01", Players2.LocalPlayer)
					object:LerpColor(...)
				end
			end))
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone2, TweenInfo.new(0.5), {
				CFrame = CFrame.new(clone2.CFrame.Position) * CFrame.Angles(3.141592653589793, 0, 0) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
			}):Play()
			task.wait(0.2)
			bindable:Fire("FinishedEffect", v13, clone2)
		end)
	end
end

return function(p)
	if p.Enabled then
		EaseIn(p)
	else
		maid:DoCleaning()
	end
end