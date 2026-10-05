local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local Effect = require(ReplicatedStorage.Effect)
local Util = require(ReplicatedStorage.Util)
local doughMiscDripGeneric = Effect.new("Dough.Misc.Drip.Generic")
local misc = Util.Misc
local tween = Util.Tween
local _ = Util.DistributedLoop
local _ = misc.invertCF
local scaleCF = misc.scaleCF
local point = tween.point

local function findBusoFromLimb(humanoid, childName)
	local v = {}
	local child = humanoid.Parent:FindFirstChild(childName)
	local child2 = humanoid:FindFirstChild(childName .. "_BusoLayer1")
	local child3 = humanoid:FindFirstChild(childName .. "_BusoLayer2")

	if child then
		table.insert(v, {
			Part = child,
			Transparency = child.Transparency
		})
	end

	if child2 then
		table.insert(v, {
			Part = child2,
			Transparency = child2.Transparency
		})
	end

	if child3 then
		table.insert(v, {
			Part = child3,
			Transparency = child3.Transparency
		})
	end

	if #v > 0 then
		table.sort(v, function(a, b)
			return a.Part.Size.Magnitude > b.Part.Size.Magnitude
		end)
		local v2 = v[1]
		return child, v, v2, child == v2.Part
	end
end

local function createLimb(part, busoFromLimb)
	local clone = part:Clone()
	local motor6D = clone:FindFirstChildOfClass("Motor6D") or clone:FindFirstChildOfClass("ManualWeld")
	clone.Name = "Dough"
	clone.Material = "Ice"
	clone.TextureID = ""
	clone.Transparency = 1
	clone.Color = Color3.new(1, 1, 1)
	clone.Size = part.Size * 1.005
	clone.CFrame = part.CFrame
	motor6D.Part0 = busoFromLimb
	motor6D.Part1 = clone
	motor6D.C0 = CFrame.new()
	motor6D.C1 = CFrame.new()

	for _, child in pairs(clone:GetChildren()) do
		if child ~= motor6D then
			child:Destroy()
		end
	end

	local clones = {}

	for _, child in pairs(dough.Particles.Misc.ShapeShift:GetChildren()) do
		local clone2 = child:Clone()
		local lifetime = clone2.Lifetime
		misc.ScaleParticle(clone2, clone.Size.Magnitude * 0.5)
		clone2.Lifetime = NumberRange.new(lifetime.Min * 0.3, lifetime.Max)
		clone2.Enabled = false
		clone2.Parent = clone
		table.insert(clones, clone2)
	end

	return clone, motor6D, clones
end

local function scaleLimb(p, p2, value, p3)
	p.Size = (p2 or createVector(1, 1, 1)) * (value or 1) * 1.005 * (p3 or createVector(1, 1, 1))
end

local v = {}
local v2 = {}
return function(player)
	local character = player.Character
	local v3

	if character then
		if typeof(character) == "Instance" then
			v3 = character:IsA("Model")
		else
			v3 = false
		end
	else
		v3 = character
	end

	assert(v3, string.format("Please make sure to apply the proper instance for the Character"))
	local delay = player.Delay or 0
	local fadeIn = player.FadeIn or 0.5
	local fadeOut = player.FadeOut or 0.75
	local lifetime = player.Lifetime or 0
	local hideAfter = player.HideAfter
	local side = player.Side
	local armature = player.Armature or {
		{ "UpperArm", 0.5, true },
		{ "LowerArm", 1 },
		{ "Hand", 1 }
	}
	local v4 = typeof(lifetime) == "Instance"
	local v5 = typeof(delay) == "Instance"
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local v6

	if humanoid then
		if typeof(humanoid) == "Instance" then
			v6 = humanoid:IsA("Humanoid")
		else
			v6 = false
		end
	else
		v6 = humanoid
	end

	assert(v6, string.format("Please make sure the character owns a humanoid"))

	if not v2[character] then
		v2[character] = {}
	end

	local flag = false

	for _, v8 in pairs(armature) do
		local v9 = side and side .. v8[1] or v8[1]

		if not v2[character][v9] then
			continue
		end

		flag = true
		break
	end

	if flag then
		return
	end

	for _, v8 in pairs(armature) do
		local v9 = side and side .. v8[1] or v8[1]

		if not v2[character][v9] then
			v2[character][v9] = true
		end
	end

	local v8 = {}

	for _, v9 in pairs(armature) do
		local v10 = v9[1]

		if side then
			v10 = side .. v10 or v10
		end

		local busoFromLimb, limbs, largest = findBusoFromLimb(humanoid, v10)

		if not limbs then
			continue
		end

		local limb, joint, particles = createLimb(largest.Part, busoFromLimb)
		limb.Parent = character
		table.insert(v8, {
			Limbs = limbs,
			Largest = largest,
			IgnoreTransparency = v9[3],
			Dough = {
				Particles = particles,
				Scale = v9[2] or 1,
				Part = limb,
				Joint = joint,
				C0 = joint.C0,
				C1 = joint.C1
			}
		})
	end

	for _, v9 in pairs(v8) do
		if v9.IgnoreTransparency then
			continue
		end

		for _, limb in pairs(v9.Limbs) do
			limb.Part.Transparency = 1
		end
	end

	if not hideAfter then
		if v5 then
			while delay:IsDescendantOf(workspace) and delay:GetAttribute("Delay") do
				task.wait(0.016666666666666666)
			end
		elseif delay > 0 then
			wait(delay)
		end
	end

	local v9 = false

	for _, v10 in pairs(v8) do
		for _, limb in pairs(v10.Limbs) do
			if not limb.Part:GetAttribute("DoughWheelInvisibleActive") then
				continue
			end

			v9 = true
			break
		end
	end

	if not v9 then
		for i = 1, #v8 do
			local dough2 = v8[i].Dough
			local size = v8[i].Largest.Part.Size
			local v10 = size * Vector3.new(1, dough2.Scale, 1)
			local magnitude = (size - v10).Magnitude
			local Y = v10.Y
			dough2.Part.Size = (v10 or createVector(1, 1, 1)) * 1 * 1.005 * createVector(1, 0, 1)
			local v11 = point(1, 1, 0)
			local part = dough2.Part
			local vector2 = Vector3.new(v11, 0, v11) or createVector(1, 1, 1)
			part.Size = (v10 or createVector(1, 1, 1)) * 1 * 1.005 * vector2
			dough2.Joint.C0 = scaleCF(dough2.C0, 0, "Y") * CFrame.new(0, -1 * -Y / 2, 0)
			dough2.Part.Transparency = 0

			for _, particle in pairs(dough2.Particles) do
				particle:Emit(5)
				particle.Enabled = true
			end

			local v12 = fadeIn / #v8
			local lastTime = tick()
			local now = 0

			while true do
				local v13 = math.min(1, (tick() - lastTime) / v12)
				local sine = tween.ease.out.sine(v13, 0, 1, 1)
				local quad = tween.ease.out.quad(v13, 0, 1, 1)
				local v14 = Y * sine
				local v15 = magnitude * sine
				local v16 = point(1, 1, sine)
				local part2 = dough2.Part
				local vector3 = Vector3.new(v16, sine, v16) or createVector(1, 1, 1)
				part2.Size = (v10 or createVector(1, 1, 1)) * 1 * 1.005 * vector3
				local _ = dough2.Part.Size
				dough2.Part.Transparency = point(1, 0, quad)
				dough2.Joint.C0 = scaleCF(dough2.C0, v14, "Y") * CFrame.new(0, -1 * (-Y / 2 + v14 / 2 + v15 / 2), 0)

				if #v8 - 1 <= i and tick() - now > 0.06666666666666667 then
					doughMiscDripGeneric:replicate({
						Type = "Generic",
						Root = dough2.Part,
						DropLifetime = 2,
						Velocity = createVector(0, 0.25, 0),
						Gravity = Random.new():NextNumber(0.15, 0.3)
					})
					now = tick()
				end

				if v13 == 1 then
					break
				else
					RunService.RenderStepped:Wait()
				end
			end
		end
	end

	if v4 or lifetime > 0 then
		local lastTime = tick()
		local now = 0

		while true do
			local v10 = math.min(1, (tick() - lastTime) / (v4 and 1e999 or lifetime))

			if tick() - now > 0.06666666666666667 then
				local v11 = v8[#v8 - 1] or v8[#v8]

				if v11 then
					doughMiscDripGeneric:replicate({
						Type = "Generic",
						Root = v11.Dough.Part,
						DropLifetime = 2,
						Velocity = createVector(0, 0.25, 0),
						Gravity = Random.new():NextNumber(0.15, 0.3)
					})
				end

				now = tick()
			end

			local v11

			if v4 then
				v11 = not (lifetime:IsDescendantOf(workspace) and lifetime:GetAttribute("Lifetime"))
			else
				v11 = v10 == 1
			end

			if v11 then
				break
			else
				RunService.RenderStepped:Wait()
			end
		end
	end

	for _, v10 in pairs(v8) do
		for _, limb in pairs(v10.Limbs) do
			if not limb.Part:GetAttribute("DoughWheelInvisibleActive") then
				continue
			end

			v9 = true
			break
		end
	end

	for _, v10 in pairs(v8) do
		if hideAfter then
			v10.Dough.Part.Transparency = 1
		end

		if hideAfter then
			continue
		end

		for _, limb in pairs(v10.Limbs) do
			if not v9 then
				limb.Part.Transparency = limb.Transparency
			end
		end
	end

	if not hideAfter then
		for _, v10 in pairs(armature) do
			local v11 = side and side .. v10[1] or v10[1]
			v2[character][v11] = nil
		end
	end

	if not v[character] then
		v[character] = character.AncestryChanged:connect(function(p, p2)
			if p ~= character then
				return
			end

			if not (p2 and character:IsDescendantOf(workspace)) then
				v[character]:Disconnect()
				v[character] = nil
			end
		end)
	end

	if hideAfter then
		for _, v10 in pairs(v8) do
			for _, particle in pairs(v10.Dough.Particles) do
				particle.Enabled = false
			end

			v10.Dough.Part.Transparency = 1
		end

		if v5 then
			while delay:IsDescendantOf(workspace) and delay:GetAttribute("Delay") do
				task.wait(0.016666666666666666)
			end
		elseif delay > 0 then
			wait(delay)
		end

		for _, v10 in pairs(v8) do
			for _, limb in pairs(v10.Limbs) do
				if not limb.Part:GetAttribute("DoughWheelInvisibleActive") then
					continue
				end

				v9 = true
				break
			end
		end

		if not v9 then
			for i = 1, #v8 do
				local dough2 = v8[i].Dough
				local size = v8[i].Largest.Part.Size
				local v10 = size * Vector3.new(1, dough2.Scale, 1)
				local magnitude = (size - v10).Magnitude
				local Y = v10.Y
				dough2.Part.Size = (v10 or createVector(1, 1, 1)) * 1 * 1.005 * createVector(1, 0, 1)
				local v11 = point(1, 1, 0)
				local part = dough2.Part
				local vector2 = Vector3.new(v11, 0, v11) or createVector(1, 1, 1)
				part.Size = (v10 or createVector(1, 1, 1)) * 1 * 1.005 * vector2
				dough2.Joint.C0 = scaleCF(dough2.C0, 0, "Y") * CFrame.new(0, -1 * -Y / 2, 0)
				dough2.Part.Transparency = 0

				for _, particle in pairs(dough2.Particles) do
					particle.Enabled = true
				end

				local v12 = fadeOut / 2 / #v8
				local lastTime = tick()
				local now = 0

				while true do
					local v13 = math.min(1, (tick() - lastTime) / v12)
					local sine = tween.ease.out.sine(v13, 0, 1, 1)
					local quad = tween.ease.out.quad(v13, 0, 1, 1)
					local v14 = Y * sine
					local v15 = magnitude * sine
					local v16 = point(1, 1, sine)
					local part2 = dough2.Part
					local vector3 = Vector3.new(v16, sine, v16) or createVector(1, 1, 1)
					part2.Size = (v10 or createVector(1, 1, 1)) * 1 * 1.005 * vector3
					local _ = dough2.Part.Size
					dough2.Part.Transparency = point(1, 0, quad)
					dough2.Joint.C0 = scaleCF(dough2.C0, v14, "Y") * CFrame.new(0, -1 * (-Y / 2 + v14 / 2 + v15 / 2), 0)

					if #v8 - 1 <= i and tick() - now > 0.06666666666666667 then
						doughMiscDripGeneric:replicate({
							Type = "Generic",
							Root = dough2.Part,
							DropLifetime = 2,
							Velocity = createVector(0, 0.25, 0),
							Gravity = Random.new():NextNumber(0.15, 0.3)
						})
						now = tick()
					end

					if v13 == 1 then
						break
					else
						RunService.RenderStepped:Wait()
					end
				end
			end
		end

		for _, v10 in pairs(v8) do
			for _, limb in pairs(v10.Limbs) do
				if not v9 then
					limb.Part.Transparency = limb.Transparency
				end
			end
		end

		for _, v10 in pairs(armature) do
			local v11 = side and side .. v10[1] or v10[1]
			v2[character][v11] = nil
		end
	else
		for _, v10 in pairs(v8) do
			for _, limb in pairs(v10.Limbs) do
				if not limb.Part:GetAttribute("DoughWheelInvisibleActive") then
					continue
				end

				v9 = true
				break
			end
		end
	end

	if not v9 then
		for i = #v8, 1, -1 do
			local dough2 = v8[i].Dough
			local size = v8[i].Largest.Part.Size
			local v10 = size * Vector3.new(1, dough2.Scale, 1)
			local magnitude = (size - v10).Magnitude
			local Y = v10.Y

			for _, particle in pairs(dough2.Particles) do
				particle.Enabled = false
			end

			local v11 = fadeOut / (hideAfter and 2 or 1) / #v8
			local lastTime = tick()

			while true do
				local v12 = math.min(1, (tick() - lastTime) / v11)
				local sine = tween.ease["in"].sine(v12, 1, -1, 1)
				local sine2 = tween.ease["in"].sine(v12, 0, 1, 1)
				local v13 = Y * sine
				local v14 = magnitude * sine
				local v15 = point(1, 1, sine2)
				local part = dough2.Part
				local vector2 = Vector3.new(v15, sine, v15) or createVector(1, 1, 1)
				part.Size = (v10 or createVector(1, 1, 1)) * 1 * 1.005 * vector2
				local _ = dough2.Part.Size
				dough2.Part.Transparency = point(0, 1, sine2)
				dough2.Joint.C0 = scaleCF(dough2.C0, v13, "Y") * CFrame.new(0, -1 * (-Y / 2 + v13 / 2 + v14 / 2), 0)

				if v12 == 1 then
					break
				end

				RunService.RenderStepped:Wait()
			end
		end
	end

	for _, v10 in pairs(v8) do
		local v11 = 0

		for _, particle in pairs(v10.Dough.Particles) do
			v11 = math.max(particle.Lifetime.Max, v11)
		end

		Util.Debris:AddItem(v10.Dough.Part, v11 + 0.1)
	end
end