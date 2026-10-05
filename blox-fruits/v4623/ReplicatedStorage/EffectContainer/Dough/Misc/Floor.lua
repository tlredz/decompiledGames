local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Pool = require(ReplicatedStorage.Pool)
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local currentCamera = workspace.CurrentCamera
local _ = Util.Misc
local _ = Util.DistributedLoop
local tween = Util.Tween

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleBlob(p, value, p2)
	if not p.Parent then
		return
	end

	p.Size = (p2 or createVector(1, 1, 1)) * (value or 1)
end

local v = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))
v:setAction(function(object, p)
	local now = tick()
	local __getCount = object:__getCount()
	local models = {}
	local v2 = {}

	for _, v3 in pairs(object.Pool) do
		if not (now - v3.LastUpdate >= math.clamp(
			0.016666666666666666 * (__getCount / 1 - 1),
			0.016666666666666666,
			0.1
		)) then
			continue
		end

		local cFrame = v3.CFrame
		local v4 = now - v3.Start
		local fadeIn = v3.FadeIn
		local fadeOut = v3.FadeOut
		local lifetime = v3.Lifetime
		local segments = v3.Segments
		local count = #segments
		local scale = v3.Scale
		local arcLength = v3.ArcLength
		local elevationScale = v3.ElevationScale
		local specialHold = v3.SpecialHold
		local RNG = v3.RNG

		if v3.Destroy then
			v3.Model:Destroy()
			object:remove(v3)
		else
			if v3.Stop then
				local v5 = now - v3.Stop
				local v6 = math.min(1, v5 / fadeOut)

				for k, segment in pairs(segments) do
					local v7 = math.min(1, v5 / (fadeOut * segment.DurationInfluence))
					local back = tween.ease.out.back(v7, 0, 1, 1)
					local quad = tween.ease["in"].quad(v7, 0, 1, 1)
					local point = tween.point(scale, scale * 0, quad)
					local v8 = tween.point(scale / 1.5, scale / 1.5, quad) * arcLength * 0.75 * segment.Offset
					local point2 = tween.point(-0.1, 0, back)
					local v9 = tween.point(0, -1, back) * (elevationScale + scale * 0.025)
					local v10 = math.sin(segment.Angle) * 1
					local v11 = 6.283185307179586 * (k / count)
					scaleBlob(
						segment.Model,
						point + point * 0.1 * v10,
						segment.VectorScale * Vector3.new(1, 1, segment.Stretch)
					) -- equivalent call inferred; original call site unknown
					table.insert(models, segment.Model)
					table.insert(
						v2,
						cFrame * CFrame.Angles(0, v11 + segment.Rotation, 0) * CFrame.new(0, v9, -v8) * CFrame.Angles(
							v10 / 6 * segment.Elevation * point2 + segment.Elevation * point2,
							0,
							0
						)
					)
				end

				if v6 == 1 then
					v3.Destroy = true
				elseif v3.Sound then
					Util.Sound:FadeOut(v3.Sound, fadeOut)
					v3.Sound = nil
				end
			elseif fadeIn < v4 then
				local v5 = math.min(1, (v4 - fadeIn) / (specialHold and 1e999 or lifetime))

				if specialHold or lifetime > 0 then
					for k, segment in pairs(segments) do
						local v6 = scale / 1.5 * arcLength * 0.75 * segment.Offset
						local v7 = 6.283185307179586 * (k / count)
						local v8 = math.sin(segment.Angle) * 1
						scaleBlob(
							segment.Model,
							scale + scale * segment.SizeIncrementScale * v8,
							segment.VectorScale * Vector3.new(1, 1, segment.Stretch)
						) -- equivalent call inferred; original call site unknown
						table.insert(models, segment.Model)
						table.insert(
							v2,
							cFrame * CFrame.Angles(0, v7 + segment.Rotation, 0) * CFrame.new(0, 0, -v6) * CFrame.Angles(
								v8 / 6 * segment.Elevation * -0.1 + segment.Elevation * -0.1,
								0,
								0
							)
						)
						segment.Angle = segment.Angle % 6.283185307179586 + 2.0943951023931953 * segment.Speed * p
					end
				end

				local v6

				if specialHold then
					v6 = not lifetime:IsDescendantOf(workspace)
				else
					v6 = v5 == 1
				end

				if v6 then
					for _, segment in pairs(segments) do
						segment.DurationInfluence = RNG:NextNumber(0.75, 1)
					end

					v3.Stop = now
				end
			else
				math.min(1, v4 / fadeIn)

				for k, segment in pairs(segments) do
					local v5 = math.min(1, v4 / (fadeIn * segment.DurationInfluence))
					local v6 = math.min(1, v4 / (fadeIn * 0.25))
					local point = tween.point(0, 1, v6)
					local v7 = math.sin(segment.Angle) * point
					local back = tween.ease.out.back(v5, 0, 1, 1)
					local quad = tween.ease.out.quad(v5, 0, 1, 1)
					local point2 = tween.point(scale * 0, scale, quad)
					local v8 = tween.point(scale * 0, scale / 1.5, quad) * arcLength * 0.75 * segment.Offset
					local point3 = tween.point(1, -0.1, back)
					local v9 = 6.283185307179586 * (k / count)
					scaleBlob(
						segment.Model,
						point2 + point2 * segment.SizeIncrementScale * v7,
						segment.VectorScale * Vector3.new(1, 1, segment.Stretch)
					) -- equivalent call inferred; original call site unknown
					table.insert(models, segment.Model)
					table.insert(
						v2,
						cFrame * CFrame.Angles(0, v9 + segment.Rotation, 0) * CFrame.new(0, 0, -v8) * CFrame.Angles(
							v7 / 6 * segment.Elevation * point3 + segment.Elevation * point3,
							0,
							0
						)
					)
					segment.Angle = segment.Angle % 6.283185307179586 + 2.0943951023931953 * segment.Speed * p
				end
			end

			v3.LastUpdate = now
		end
	end

	workspace:BulkMoveTo(models, v2)
end)
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 1
	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

	if 225 + 5 * scale < magnitude then
		return
	end

	local lifetime = data.Lifetime or 0
	local fadeIn = data.FadeIn or 1
	local fadeOut = data.FadeOut or 1
	local segments = data.Segments or 10
	local material = data.Material
	local color = data.Color
	local specialHold = typeof(lifetime) == "Instance"
	local arcLength = 6.283185307179586 * (1 / segments)
	local v4 = cFrame * CFrame.Angles(0.05235987755982988, 0, 0) * CFrame.new(
		0,
		0,
		-(scale / 1.5 * arcLength * 0.75) / 1.5
	)
	local elevationScale = math.rad((math.abs(((v4.p - cFrame.p):Dot(v4.LookVector))))) + scale * 0.02
	local cFrame2 = cFrame + cFrame.UpVector * elevationScale
	local random = Random.new()
	local model = Instance.new("Model")
	model.Name = string.format("Dough/%s", script.Name)
	local count = 0
	local segments2 = {}

	for i = 1, segments do
		local v8 = 6.283185307179586 * (i / segments)
		local v9

		if segments % 3 == 0 then
			v9 = i % 3 == 0
		else
			v9 = i % 2 == 0
		end

		local v10 = v9 and count < 3

		if v10 and count < 3 then
			count += 1
		end

		local vector2 = Vector3.new(
			arcLength * random:NextNumber(v10 and 0.6 or 0.5, 0.75),
			0.1,
			arcLength * random:NextNumber(v10 and 0.75 or 0.5, 1)
		)
		local elevation = 0.5235987755982988 * random:NextNumber(0.8, 1.25)
		local rotation = random:NextNumber(-1, 1) * math.rad((random:NextNumber(0, 5)))
		local clone = dough.Models.Blob:Clone()

		if material then
			clone.Material = material
		end

		if color then
			clone.Color = color
		end

		scaleBlob(clone, scale * 0, vector2) -- equivalent call inferred; original call site unknown
		clone.CFrame = cFrame2 * CFrame.Angles(0, v8 + rotation, 0) * CFrame.new(0, 0, -scale * 0) * CFrame.Angles(
			elevation,
			0,
			0
		)
		clone.Parent = model
		table.insert(segments2, {
			Model = clone,
			VectorScale = vector2,
			Elevation = elevation,
			Rotation = rotation,
			DurationInfluence = random:NextNumber(0.5, 1),
			Angle = random:NextNumber(0, 1) * 3.141592653589793,
			Speed = random:NextNumber(2, 4),
			Offset = v10 and random:NextNumber(0.7, 0.9) or random:NextNumber(0.8, 1),
			SizeIncrementScale = v10 and random:NextNumber(0.15, 0.3) or random:NextNumber(0.15, 0.3),
			Stretch = random:NextNumber(1, 1.5)
		})
	end

	model.Parent = _WorldOrigin
	local sound

	if tick() - 0 > 0.1 then
		sound = Util.Sound:Play("Dough.DoughAmbienceLoop", cFrame2, nil, 5.287 / ((fadeIn + fadeOut) * 2))
	end

	v:add({
		Sound = sound,
		LastUpdate = 0,
		Start = tick(),
		Model = model,
		CFrame = cFrame2,
		FadeIn = fadeIn,
		FadeOut = fadeOut,
		Lifetime = lifetime,
		Segments = segments2,
		Scale = scale,
		ArcLength = arcLength,
		SpecialHold = specialHold,
		ElevationScale = elevationScale,
		RNG = random
	})
	Effect.new("Dough.Misc.Hit.Floor"):replicate({
		CFrame = cFrame2,
		Duration = (fadeIn + lifetime + fadeOut) / 2,
		Scale = scale * 1
	})
end