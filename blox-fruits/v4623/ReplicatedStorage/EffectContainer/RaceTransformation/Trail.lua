function map(p, p2, p3, p4, p5)
	return p4 + (p - p2) * (p5 - p4) / (p3 - p2)
end

function ScaleNumberSequence(items, p)
	local numberSequenceKeypoints = {}

	for _, item in pairs(items) do
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(item.Time, item.Value * p))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function lerp(p, p2, p3)
	return p * (1 - p3) + p2 * p3
end

local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local Pool = require(game.ReplicatedStorage:WaitForChild("Pool"))
local FX = require(game.ReplicatedStorage.FX)
local raceTransformation = FX:WaitForChild("RaceTransformation")
local misc = Util.Misc
local debris = Util.Debris
local v = Pool.new(string.format("%s/%s", script.Parent.Name, script.Name))
v:setAction(function(object, p)
	local now = tick()

	for _, v2 in pairs(object.Pool) do
		local part = v2.Part
		local trails = v2.Trails
		local root = v2.Root
		local offset = v2.Offset
		local fadeIn = v2.FadeIn
		local fadeOut = v2.FadeOut
		local lifetime = v2.Lifetime
		local specialCase = v2.SpecialCase
		local reverse = v2.Reverse
		local speed = v2.Speed
		local direction = v2.Direction
		local height = v2.Height
		local radius = v2.Radius
		local _ = v2.Width
		local v3 = now - v2.Start
		local mapped, mapped2, v4

		if fadeIn + lifetime < v3 then
			local v5 = math.min(1, (v3 - (fadeIn + lifetime)) / fadeOut)

			if specialCase and not reverse then
				mapped = map(v5, 0, 1, lerp(height[1], height[2], 0.5), height[2])
				mapped2 = map(v5, 0, 1, lerp(radius[1], radius[2], 0.5), radius[2])
			elseif reverse then
				mapped = map(v5, 0, 1, height[2], height[1])
				mapped2 = map(v5, 0, 1, radius[2], radius[1])
			else
				mapped = height[2]
				mapped2 = radius[2]
			end

			v4 = 1 - v5 * 0.5

			if v5 == 1 then
				v2.Ready = true
			end
		elseif fadeIn < v3 then
			math.min(1, (v3 - fadeIn) / lifetime)
			mapped = height[2]
			mapped2 = radius[2]
			v4 = 1
		else
			v4 = math.min(1, v3 / fadeIn)

			if specialCase and not reverse then
				mapped = map(v4, 0, 1, height[1], lerp(height[1], height[2], 0.5))
				mapped2 = map(v4, 0, 1, radius[1], lerp(radius[1], radius[2], 0.5))
			else
				mapped = map(v4, 0, 1, height[1], height[2])
				mapped2 = map(v4, 0, 1, radius[1], radius[2])
			end
		end

		part.CFrame = root.CFrame * CFrame.new(0, mapped, 0) * CFrame.Angles(0, direction * v2.Angle, 0) * offset * CFrame.new(
			0,
			0,
			-mapped2
		) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(0, 0, 1.5707963267948966)

		for _, trail in pairs(trails) do
			trail.Object.WidthScale = ScaleNumberSequence(trail.WidthScale, v4)
		end

		if v2.Ready then
			debris:AddItem(part, fadeIn + fadeOut + lifetime + 0.5)
			object:remove(v2)
		else
			v2.Angle = v2.Angle % 6.283185307179586 + 6.283185307179586 * speed * p
		end
	end
end)
return function(data)
	local random = Random.new()
	local reference = data.Reference or raceTransformation.Effects.TrailPart
	local root = data.Root
	local player = data.player
	local race = data.race
	local offset = data.Offset or data.CFrame or CFrame.identity
	local direction = data.Direction or random:NextInteger(1, 2) == 1 and 1 or -1
	local width = data.Width or random:NextNumber(1, 2)
	local fadeIn = data.FadeIn or 0.25
	local lifetime = data.Lifetime or 0
	local fadeOut = data.FadeOut or 0.25
	local reverse = data.Reverse or false
	local specialCase = not lifetime or lifetime == 0
	local speed = data.Speed or random:NextNumber(1, 4)
	local height = data.Height or { random:NextNumber(-5, -2.5), random:NextNumber(0, 5) }
	local radius = data.Radius or { random:NextNumber(0, 5), random:NextNumber(5, 10) }
	local clone = reference:Clone()
	clone.CFrame = root.CFrame
	clone.Parent = _WorldOrigin

	if race == "Draco" then
		Util.ColorShiftObjectDescendants(clone, player, "DracoRaceVFXColors", true)
		Util.SyncColorsOnChange(clone, player, "DracoRaceVFXColors", true)
	end

	local trails = {}

	for _, child in pairs(clone:GetChildren()) do
		if child:IsA("Trail") then
			if data.Color then
				child.Color = misc.SwapColorInKeypoints(child.Color.Keypoints, Color3.new(1, 0, 0), data.Color)
			end

			table.insert(trails, {
				Object = child,
				WidthScale = child.WidthScale.Keypoints
			})
		elseif child:IsA("Attachment") then
			child.Position *= width
		end
	end

	for _, v4 in pairs(trails) do
		v4.Object.Enabled = false
	end

	local angle = random:NextNumber(-1, 1) * 3.141592653589793
	tick()
	clone.CFrame = root.CFrame * CFrame.new(0, height[1], 0) * CFrame.Angles(0, angle, 0) * offset * CFrame.new(
		0,
		0,
		-radius[1]
	) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(0, 0, 1.5707963267948966)

	for _, v5 in pairs(trails) do
		v5.Object.Lifetime = (fadeIn + fadeOut) / 2
		v5.Object.Enabled = true
	end

	v:add({
		Root = root,
		Offset = offset,
		Part = clone,
		Trails = trails,
		Direction = direction,
		Width = width,
		FadeIn = fadeIn,
		Lifetime = lifetime,
		FadeOut = fadeOut,
		Reverse = reverse,
		SpecialCase = specialCase,
		Speed = speed,
		Height = height,
		Radius = radius,
		Angle = angle,
		Start = tick()
	})
end