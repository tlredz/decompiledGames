local createVector = vector.create
local name = string.format("Dough/%s/%s", script.Parent.Name, script.Name)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Pool = require(ReplicatedStorage:WaitForChild("Pool"))
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local interactiveEffects = _WorldOrigin:FindFirstChild("InteractiveEffects")

if not interactiveEffects then
	return warn("Please make a Folder in the _WorldOrigin called \"InteractiveEffects\"!")
end

local currentCamera = workspace.CurrentCamera
local misc = Util.Misc
local rayCastWhitelist = Util.RayCastWhitelist
local tween = Util.Tween
local _ = Util.Debris
local map = misc.map
local recurse = misc.recurse
local alignCFrame = misc.AlignCFrame
local calculatePosition = misc.CalculatePosition
local point = tween.point
local vector2 = Vector3.new(0, -workspace.Gravity)
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Return(p, p2)
	v2[p][p2] = true
	p2.Parent = nil
end

local function Grab(instance)
	v2[instance] = v2[instance] or {}
	local v3 = v2[instance]
	local v4, _ = next(v3)

	if not v4 then
		return instance:Clone()
	end

	v3[v4] = nil
	return v4
end

local memoize = Util.Memoize(function(instance)
	local children = {}

	for _, child in pairs(instance:GetChildren()) do
		table.insert(children, child)
	end

	return children
end)
local memoize2 = Util.Memoize(function(data)
	return {
		Size = data.Size.Keypoints,
		Speed = data.Speed,
		Acceleration = data.Acceleration,
		Lifetime = data.Lifetime
	}
end)
local memoize3 = Util.Memoize(function(parent)
	local v3 = {
		{},
		{}
	}

	for _, v4 in pairs(memoize(dough.Particles.BlobHit)) do
		local clone = v4:Clone()
		clone.Enabled = false
		clone.Parent = parent
		table.insert(v3[1], clone)
		table.insert(v3[2], v4)
	end

	return v3
end)
local memoize4 = Util.Memoize(function(parent)
	local v3 = {
		{},
		{}
	}

	for _, emitter in pairs(memoize(parent)) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = false
		emitter.Parent = parent
		table.insert(v3[1], emitter)
		table.insert(v3[2], emitter)
	end

	return v3
end)
local attachment = Instance.new("Attachment")
local blob = dough.Models.Blob
local splat = dough.Models.Splat
local v3 = Pool.new(name)

local function getBlobFromCache(parent)
	if not parent.Name == name then
		return
	end

	for k, v4 in pairs(v3.Pool) do
		if v4.Splat == parent or v4.Model == parent then
			return v4, k
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAncestorPastry(p)
	local v4 = nil
	recurse(p, function(p2, p3)
		if p2 == "Pastrified" then
			v4 = p3
		end
	end)
	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleBlob(p, value, p2)
	if not p.Parent then
		return
	end

	p.Size = (p2 or createVector(1, 1, 1)) * (value or 1)
end

local v4 = 0

local function popBlob(worldCFrame, value, value2)
	local rounded = Util.Misc.round(value or 1, 2)
	local rounded2 = Util.Misc.round(value2 or 1, 0.01)
	local magnitude = (currentCamera.CFrame.p - worldCFrame.p).Magnitude

	if 100 + 5 * rounded < magnitude or rounded < 0.75 or v4 >= 15 then
		return
	end

	v4 += 1
	local v5 = rounded or 1
	local v6 = attachment
	v2[v6] = v2[v6] or {}
	local v7 = v2[v6]
	local clone, _ = next(v7)

	if clone then
		v7[clone] = nil
	else
		clone = v6:Clone()
	end

	local v8 = memoize3(clone)
	local v9 = 0.5

	for k, v10 in pairs(v8[1]) do
		local v11 = memoize2(v8[2][k])
		v10.Lifetime = NumberRange.new(v11.Lifetime.Min * rounded2, v11.Lifetime.Max * rounded2)
		Util.Misc.ScaleParticle(v10, v5, v11)
		v9 = math.max(v9, v10.Lifetime.Max)
	end

	clone.WorldCFrame = worldCFrame
	clone.Parent = workspace.Terrain

	for _, v10 in pairs(v8[1]) do
		v10:Emit(v10:GetAttribute("Emit") or 1)
	end

	Effect.new("Dough.Misc.Hit.Floor"):replicate({
		CFrame = worldCFrame,
		Duration = value2 * 0.9,
		Scale = 2.25 * v5
	})
	task.delay(v9 + 0.1, function()
		Return(attachment, clone) -- equivalent call inferred; original call site unknown
		v4 -= 1
	end)
end

local v5 = {
	Donut = function(data)
		local model = data.Model

		if not model.Parent then
			return
		end

		assert(model, string.format("Please refer the Effect to a \"Model\" property."))
		local primaryPart = model.PrimaryPart

		if not (primaryPart and primaryPart.Parent) then
			return
		end

		assert(primaryPart, string.format("Please set a PrimaryPart to the Model"))
		local scale = data.Scale or primaryPart.Size.Magnitude * 0.1
		local magnitude = (currentCamera.CFrame.p - primaryPart.CFrame.p).Magnitude

		if 300 + 4 * scale < magnitude then
			return
		end

		local Y = primaryPart.Size.Y
		local v6 = Y / 3
		local viscocity = data.Viscocity or Random.new():NextNumber(0, 1)
		local thickness = data.Thickness or 1
		local dropLifetime = data.DropLifetime or 0.9
		local oozeDuration = data.OozeDuration or 0.25
		local pastryLifetime = data.PastryLifetime or 2
		local maxPastrySize = data.MaxPastrySize or 15
		local fadeDuration = data.FadeDuration or 0.5
		local scale2 = (scale or Y / 2 * 0.3) * Random.new():NextNumber(0.5, 1.5)
		local velocity = data.Velocity or createVector(0, 0.25, 0)
		local gravity = vector2 * (data.Gravity or Random.new():NextNumber(0.15, 0.5))
		local cFrame = primaryPart.CFrame
		local lookVector = cFrame.LookVector
		local cross = lookVector:Cross(createVector(0, 1, 0))
		local vector3 = cross.Magnitude <= 0.01 and createVector(1, 0, 0) or cross
		local cross2 = vector3:Cross(lookVector)
		local v9 = cross2.Magnitude <= 0.01 and createVector(0, 1, 0) or cross2
		local cframe = CFrame.fromMatrix(cFrame.p, vector3, v9, lookVector)
		local _ = primaryPart.Position
		local dot = (-v9):Dot(createVector(-0, -1, -0))
		local v10 = math.abs(dot)
		local mapped = map(1 - v10, 0, 1, 0.5, 1)
		local v11 = (dot > 0 and -1 or 1) * 3.141592653589793 * 2 * mapped
		local number = Random.new():NextNumber(0, v11)
		local v12 = Random.new():NextNumber(point(v6, Y * 0.8, v10), Y * 0.8) / 2
		local blobPoint = cframe * (Vector3.new(math.cos(number), (math.sin(number))) * v12)
		local speed = math.random(1, 2) == 1 and Random.new():NextNumber(15, 30) or Random.new():NextNumber(0.1, 12)
		local v15 = blob
		v2[v15] = v2[v15] or {}
		local v16 = v2[v15]
		local clone, _ = next(v16)

		if clone then
			v16[clone] = nil
		else
			clone = v15:Clone()
		end

		local particles = memoize4(clone)

		for k, v18 in pairs(particles[1]) do
			local v19 = memoize2(particles[2][k])
			misc.ScaleParticle(v18, scale2 * 0.5, v19)

			if scale2 > 0.15 then
				v18.Enabled = true
			else
				v18.Enabled = false
			end
		end

		clone.Name = name
		scaleBlob(clone, nil, createVector(0.25, 0.25, 0.35) * scale2) -- equivalent call inferred; original call site unknown
		clone.CFrame = CFrame.new(Vector3.new(), createVector(-0, -1, -0)) * CFrame.Angles(3.141592653589793, 0, 0) + blobPoint
		clone.Parent = _WorldOrigin
		v3:add({
			UpdateDelta = data.UpdateDelta,
			LastUpdate = 0,
			Rotation = CFrame.Angles(0, 0, Random.new():NextNumber(-1, 1) * 3.141592653589793),
			Particles = particles,
			Model = clone,
			Scale = scale2,
			FallVector = createVector(-0, -1, -0),
			BlobPoint = blobPoint,
			LastPosition = Vector3.new(),
			Velocity = velocity,
			Gravity = gravity,
			Speed = speed,
			Start = tick(),
			Drag = Random.new():NextNumber(2, 8),
			Data = {
				Viscocity = viscocity,
				Thickness = thickness,
				DropLifetime = dropLifetime,
				OozeDuration = oozeDuration,
				PastryLifetime = pastryLifetime,
				MaxPastrySize = maxPastrySize,
				FadeDuration = fadeDuration
			}
		})
	end,
	Generic = function(data)
		local root = data.Root or data.Reference
		local v6

		if root then
			if typeof(root) == "Instance" then
				v6 = root:IsA("BasePart")
			else
				v6 = false
			end
		else
			v6 = root
		end

		assert(v6, string.format("Please apply a BasePart Reference to the Effect"))
		local size = root.Size
		local scale = data.Scale or size.Magnitude * 0.1
		local magnitude = (currentCamera.CFrame.p - root.CFrame.p).Magnitude

		if 300 + 5 * scale < magnitude then
			return
		end

		local viscocity = data.Viscocity or Random.new():NextNumber(0, 1)
		local thickness = data.Thickness or 1
		local dropLifetime = data.DropLifetime or 0.9
		local oozeDuration = data.OozeDuration or 0.25
		local pastryLifetime = data.PastryLifetime or 2
		local maxPastrySize = data.MaxPastrySize or 15
		local fadeDuration = data.FadeDuration or 0.5
		local scale2 = (scale or size.Magnitude / 2 * 0.25) * Random.new():NextNumber(0.5, 1.5)
		local velocity = data.Velocity or createVector(0, 0.25, 0)
		local gravity = vector2 * (data.Gravity or Random.new():NextNumber(0.25, 1))
		local cFrame = root.CFrame
		local lookVector = cFrame.LookVector
		local cross = lookVector:Cross(createVector(0, 1, 0))
		local vector3 = cross.Magnitude <= 0.01 and createVector(1, 0, 0) or cross
		local cross2 = vector3:Cross(lookVector)
		local v9 = cross2.Magnitude <= 0.01 and createVector(0, 1, 0) or cross2
		local _ = root.Position
		local dot = (-v9):Dot(createVector(-0, -1, -0))
		local dot2 = lookVector:Dot(createVector(-0, -1, -0))
		local v10 = math.abs(dot)
		local v11 = math.abs(dot2)
		local random = Random.new()
		local blobPoint = CFrame.fromMatrix(cFrame.p, vector3, v9, -lookVector) * Vector3.new(
			random:NextNumber(-size.X, size.X) / 2 * v10 + random:NextNumber(-size.X, size.X) / 2 * v11,
			random:NextNumber(-size.Y, size.Y) / 2 * v11,
			random:NextNumber(-size.Z, size.Z) / 2 * v10 + random:NextNumber(-size.Z, size.Z) / 2 * v11
		)
		local speed = math.random(1, 2) == 1 and Random.new():NextNumber(15, 30) or Random.new():NextNumber(0.1, 12)
		local v14 = blob
		v2[v14] = v2[v14] or {}
		local v15 = v2[v14]
		local clone, _ = next(v15)

		if clone then
			v15[clone] = nil
		else
			clone = v14:Clone()
		end

		local particles = memoize4(clone)

		for k, v17 in pairs(particles[1]) do
			local v18 = memoize2(particles[2][k])
			misc.ScaleParticle(v17, scale2 * 0.5, v18)

			if scale2 > 0.15 then
				v17.Enabled = true
			else
				v17.Enabled = false
			end
		end

		clone.Name = name
		scaleBlob(clone, nil, createVector(0.25, 0.25, 0.35) * scale2) -- equivalent call inferred; original call site unknown
		clone.CFrame = CFrame.new(Vector3.new(), createVector(-0, -1, -0)) * CFrame.Angles(3.141592653589793, 0, 0) + blobPoint
		clone.Parent = _WorldOrigin
		v3:add({
			UpdateDelta = data.UpdateDelta,
			LastUpdate = 0,
			Rotation = CFrame.Angles(0, 0, Random.new():NextNumber(-1, 1) * 3.141592653589793),
			Particles = particles,
			Model = clone,
			Scale = scale2,
			FallVector = createVector(-0, -1, -0),
			BlobPoint = blobPoint,
			LastPosition = Vector3.new(),
			Velocity = velocity,
			Gravity = gravity,
			Speed = speed,
			Start = tick(),
			Drag = Random.new():NextNumber(2, 8),
			Data = {
				Viscocity = viscocity,
				Thickness = thickness,
				DropLifetime = dropLifetime,
				OozeDuration = oozeDuration,
				PastryLifetime = pastryLifetime,
				MaxPastrySize = maxPastrySize,
				FadeDuration = fadeDuration
			}
		})
	end,
	Trajectory = function(data)
		local cFrame = data.CFrame
		local scale = data.Scale or 1
		local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

		if 300 + 5 * scale < magnitude then
			return
		end

		local viscocity = data.Viscocity or Random.new():NextNumber(0, 1)
		local thickness = data.Thickness or 1
		local dropLifetime = data.DropLifetime or 0.9
		local oozeDuration = data.OozeDuration or 0.25
		local pastryLifetime = data.PastryLifetime or 2
		local maxPastrySize = data.MaxPastrySize or 15
		local fadeDuration = data.FadeDuration or 0.5
		local gravity = vector2 * (data.Gravity or 1)
		local velocity = data.Velocity or createVector(0, 0.25, 0)
		local _ = cFrame.p
		local scale2 = scale * Random.new():NextNumber(0.5, 1.5)
		local blobPoint = cFrame.p
		local v8 = math.random(1, 2) == 1
		local speed = data.Speed or v8 and Random.new():NextNumber(15, 30) or Random.new():NextNumber(0.1, 12)
		local v9 = blob
		v2[v9] = v2[v9] or {}
		local v10 = v2[v9]
		local clone, _ = next(v10)

		if clone then
			v10[clone] = nil
		else
			clone = v9:Clone()
		end

		local particles = memoize4(clone)

		for k, v12 in pairs(particles[1]) do
			local v13 = memoize2(particles[2][k])
			misc.ScaleParticle(v12, scale2 * 0.5, v13)

			if scale2 > 0.15 then
				v12.Enabled = true
			else
				v12.Enabled = false
			end
		end

		clone.Name = name
		scaleBlob(clone, nil, createVector(0.25, 0.25, 0.35) * scale2) -- equivalent call inferred; original call site unknown
		clone.CFrame = CFrame.new(Vector3.new(), createVector(-0, -1, -0) + velocity) * CFrame.Angles(
			3.141592653589793,
			0,
			0
		) + blobPoint
		clone.Parent = _WorldOrigin
		v3:add({
			UpdateDelta = data.UpdateDelta,
			LastUpdate = 0,
			Rotation = CFrame.Angles(0, 0, Random.new():NextNumber(-1, 1) * 3.141592653589793),
			Particles = particles,
			Model = clone,
			Scale = scale2,
			FallVector = createVector(-0, -1, -0),
			BlobPoint = blobPoint,
			LastPosition = Vector3.new(),
			Velocity = velocity,
			Gravity = gravity,
			Speed = speed,
			Start = tick(),
			Drag = data.Drag,
			Data = {
				Viscocity = viscocity,
				Thickness = thickness,
				DropLifetime = dropLifetime,
				OozeDuration = oozeDuration,
				PastryLifetime = pastryLifetime,
				MaxPastrySize = maxPastrySize,
				FadeDuration = fadeDuration
			}
		})
	end
}
v3:setAction(function(object, p)
	local now = tick()
	local __getCount = object:__getCount()
	local v6 = {}
	local v7 = {}

	for _, v8 in pairs(object.Pool) do
		if not (now - v8.LastUpdate >= math.clamp(v8.UpdateDelta * (__getCount / 20), v8.UpdateDelta, 0.1)) then
			continue
		end

		v8.LastUpdate = now
		local model = v8.Model
		local blobPoint = v8.BlobPoint
		local fallVector = v8.FallVector
		local velocity = v8.Velocity or createVector(0, 0, 0)
		local scale = v8.Scale
		local v9 = now - v8.Start
		local data = v8.Data

		if v8.Pastrified then
			local v10 = now - v8.Pastrified.Start
			local v11 = math.min(1, v10 / data.OozeDuration)
			local quad = tween.ease.out.quad(v11, 0, 1, 1)
			local circ = tween.ease["in"].circ(v11, 1, -1, 1)

			if v8.Pastrified.CollidedModel then
				if not v8.Ancestor then
					v8.Ancestor = getAncestorPastry(v8)
					v8.CurrentGrowth = v8.Ancestor.CurrentGrowth or 0
				end

				if data.OozeDuration <= v10 then
					v8.Ancestor.Merging = false
					local v12 = 0

					for _, v13 in pairs(v8.Particles[1]) do
						v12 = math.max(v13.Lifetime.Max, v12)
					end

					local v13 = v12 - data.OozeDuration
					local model2 = model
					task.delay(v13, function()
						Return(blob, model2) -- equivalent call inferred; original call site unknown
					end)
					object:remove(v8)
				else
					for _, v12 in pairs(v8.Particles[1]) do
						v12.Enabled = false
					end

					v8.Ancestor.Merging = true
					v8.Growth = scale / 2 * v11
					v8.Ancestor.CurrentGrowth = math.min(data.MaxPastrySize - scale, v8.CurrentGrowth + v8.Growth)
					local v12 = math.min(scale * 2, (v8.LastPosition - v8.Pastrified.Position).Magnitude)
					local v13 = point(0.25, 0, quad)
					local normal = v8.Ancestor.Normal
					local v14 = v8.Ancestor.Position - v8.Pastrified.Position
					local lookVector = alignCFrame(CFrame.new(createVector(0, 0, 0), v14), normal).LookVector
					local dot = lookVector:Dot(v14)
					local v15 = (v8.Ancestor.Position - lookVector * dot - v8.LastPosition) * v11
					scaleBlob(model, nil, Vector3.new(v13, v13, 0) * scale + Vector3.new(0, 0, v12 * circ)) -- equivalent call inferred; original call site unknown
					table.insert(v6, model)
					table.insert(
						v7,
						CFrame.new(createVector(0, 0, 0), fallVector) * v8.Rotation * CFrame.Angles(
							3.141592653589793,
							0,
							0
						) + v8.LastPosition + v15
					)
				end
			else
				if v8.Pastrified.Merging then
					v8.Pastrified.PastryLapse = 0
					scaleBlob(v8.Splat, nil, createVector(1, 0.075, 1) * (scale + v8.Pastrified.CurrentGrowth)) -- equivalent call inferred; original call site unknown

					for k, v13 in pairs(v8.SplatParticles[1]) do
						local v14 = memoize2(v13.SplatParticles[2][k])
						misc.ScaleParticle(v13, math.max(0.1, (scale + v13.Pastrified.CurrentGrowth) * 0.5), v14)
					end

					table.insert(v6, v8.Splat)
					table.insert(
						v7,
						alignCFrame(v8.SplatInitialRotation + v8.SplatPosition, v8.SplatNormal) * v8.SplatRotation + v8.SplatNormal * (scale + v8.Pastrified.CurrentGrowth) * 0.04
					)
				elseif data.OozeDuration <= v10 then
					if v8.Pastrified.PastryLapse >= data.PastryLifetime then
						local v12 = v8.Pastrified.PastryLapse - data.PastryLifetime
						local v13 = math.min(1, v12 / data.FadeDuration)

						for _, v14 in pairs(v8.SplatParticles[1]) do
							v14.Enabled = false
						end

						if data.FadeDuration <= v12 then
							local v14 = 0

							for _, v15 in pairs(v8.SplatParticles[1]) do
								v14 = math.max(v15.Lifetime.Max, v14)
							end

							local v15 = v14 + data.FadeDuration
							local splat2 = v8.Splat
							task.delay(v15, function()
								Return(splat, splat2) -- equivalent call inferred; original call site unknown
							end)
							object:remove(v8)
							continue
						else
							local quad2 = tween.ease.out.quad(v13, 1, -1, 1)
							scaleBlob(
								v8.Splat,
								nil,
								createVector(1, 0.075, 1) * (scale + v8.Pastrified.CurrentGrowth) * quad2
							) -- equivalent call inferred; original call site unknown
						end
					end

					v8.Pastrified.PastryLapse += p
				else
					local v12 = point(0.25, 1, quad)
					scaleBlob(v8.Splat, nil, Vector3.new(v12, 0.05, v12) * scale) -- equivalent call inferred; original call site unknown
				end

				if model and model:IsDescendantOf(workspace) then
					local v12 = math.min(scale * 2, (v8.LastPosition - v8.Pastrified.Position).Magnitude)
					local circ2 = tween.ease.out.circ(v11, 0, 1, 1)
					local v13 = point(0.25, 0, quad)

					for _, v14 in pairs(v8.Particles[1]) do
						v14.Enabled = false
					end

					scaleBlob(model, nil, Vector3.new(v13, v13, 0) * scale + Vector3.new(0, 0, v12 * circ)) -- equivalent call inferred; original call site unknown
					table.insert(v6, model)
					table.insert(v7, v8.LastCFrame + v8.LocalFallVector * v12 * circ2)

					if v11 == 1 then
						local v15 = 0

						for _, v16 in pairs(v8.Particles[1]) do
							v15 = math.max(v16.Lifetime.Max, v15)
						end

						local v16 = v15 - data.OozeDuration
						local model2 = model
						task.delay(v16, function()
							Return(blob, model2) -- equivalent call inferred; original call site unknown
						end)
						v8.Particles = nil
						v8.Model = nil
					end
				end
			end
		else
			local v10 = velocity.Magnitude > 0.1 and 0 or 1
			local v11 = calculatePosition(-fallVector * (v8.Speed / 30) * v10 + velocity, v8.Gravity, v8.Drag, v9)
			local v12 = v11 - v8.LastPosition
			local halfScale = scale / 2
			local v14 = math.max(scale * 2, halfScale)
			local v15 = math.clamp(v12.Magnitude, halfScale, v14)
			local v16 = false
			local vector3 = false
			local v17 = false

			if v12.Magnitude > 0.1 then
				fallVector = v12.Unit
			end

			if not v8.LastRayCheck then
				v8.LastRayCheck = 0
				v8.LastRayOffset = Vector3.new()
			end

			if v9 < data.DropLifetime and now - v8.LastRayCheck > 0.06666666666666667 then
				v16, vector3, v17 = rayCastWhitelist(
					blobPoint + v8.LastRayOffset,
					v8.LastPosition - v8.LastRayOffset + v12 + fallVector * v15 / 2,
					{ workspace.Map, interactiveEffects }
				)
				v8.LastRayOffset = v8.LastPosition
				v8.LastRayCheck = now
			end

			if v16 or vector3 and vector3.Y <= -4 then
				local collidedModel = v16 and getBlobFromCache(v16.Parent)

				if not v16 then
					vector3 = Vector3.new(vector3.X, -4, vector3.Z)
					v17 = createVector(0, 1, 0)
				end

				if not collidedModel then
					local cframe = CFrame.Angles(0, Random.new():NextNumber(-1, 1) * 3.141592653589793, 0)
					local v19 = splat
					v2[v19] = v2[v19] or {}
					local v20 = v2[v19]
					local clone, _ = next(v20)

					if clone then
						v20[clone] = nil
					else
						clone = v19:Clone()
					end

					clone.Name = name
					local splatParticles = memoize4(clone)

					for k, v22 in pairs(splatParticles[1]) do
						local v23 = memoize2(splatParticles[2][k])
						v22.Enabled = true
						misc.ScaleParticle(v22, math.max(0.1, scale * 0.5), v23)

						if scale > 0.15 then
							v22.Enabled = true
						else
							v22.Enabled = false
						end
					end

					scaleBlob(clone, nil, createVector(0.25, 0.075, 0.25) * scale * 0) -- equivalent call inferred; original call site unknown
					clone.Parent = interactiveEffects

					if scale > 2 then
						Util.Sound:Play(
							"Dough.DoughDrip",
							vector3,
							nil,
							(0.5 + Random.new():NextNumber(0.5, 2)) / (2.5 / scale + (data.FadeDuration + data.OozeDuration) * Random.new():NextNumber(
								0.5,
								2
							))
						)
					end

					table.insert(v6, clone)
					table.insert(
						v7,
						alignCFrame(model.CFrame - model.Position + vector3, v17) * cframe + v17 * scale * 0.04
					)
					v8.Splat = clone
					v8.SplatRotation = cframe
					v8.SplatInitialRotation = model.CFrame - model.Position
					v8.SplatPosition = vector3
					v8.SplatNormal = v17
					v8.SplatParticles = splatParticles
				end

				v8.LocalFallVector = fallVector
				v8.LastCFrame = model.CFrame
				v8.LastPosition = v8.LastCFrame.p
				v8.Pastrified = {
					Scale = scale,
					CollidedModel = collidedModel,
					Position = vector3,
					Normal = v17,
					Start = now,
					PastryLapse = 0,
					CurrentGrowth = 0
				}
				popBlob(alignCFrame(CFrame.new(vector3), v17), scale * 0.5, data.FadeDuration + data.OozeDuration)
			else
				if data.DropLifetime <= v9 then
					local v18 = math.min(1, (v9 - data.DropLifetime) / data.FadeDuration)

					for _, v19 in pairs(v8.Particles[1]) do
						v19.Enabled = false
					end

					if v18 == 1 then
						Return(blob, model) -- equivalent call inferred; original call site unknown
						object:remove(v8)
						continue
					else
						local quad = tween.ease.out.quad(v18, 1, -1, 1)
						scaleBlob(model, nil, createVector(0.25, 0.25, 0) * quad * scale + Vector3.new(0, 0, v15)) -- equivalent call inferred; original call site unknown
					end
				else
					scaleBlob(model, nil, createVector(0.25, 0.25, 0) * scale + Vector3.new(0, 0, v15)) -- equivalent call inferred; original call site unknown
				end

				table.insert(v6, model)
				table.insert(
					v7,
					CFrame.new(Vector3.new(), fallVector) * v8.Rotation * CFrame.Angles(3.141592653589793, 0, 0) + blobPoint + v11
				)
				v8.LastPosition = v8.LastPosition:Lerp(v11, (math.clamp(1 - data.Viscocity, 0.25, 1)))
			end
		end
	end

	workspace:BulkMoveTo(v6, v7)
end)
return function(data)
	local type = data.Type or "Generic"
	local viscocity = data.Viscocity
	local thickness = data.Thickness or 1
	local dropLifetime = data.DropLifetime or 0.9
	local oozeDuration = data.OozeDuration or 0.25
	local pastryLifetime = data.PastryLifetime or 0.9
	local maxPastrySize = data.MaxPastrySize or 15
	local fadeDuration = data.FadeDuration or 0.5
	assert(v5[type], string.format("Drip Type \"%s\" does not exist.", type))

	if not data.Force and v3:__getCount() >= 30 then
		return
	end

	v5[type]({
		UpdateDelta = data.UpdateDelta or 0.022222222222222223,
		Model = data.Model,
		Root = data.Root,
		Scale = data.Scale,
		CFrame = data.CFrame,
		Velocity = data.Velocity,
		Drag = data.Drag,
		Gravity = data.Gravity,
		Speed = data.Speed,
		Viscocity = viscocity,
		Thickness = thickness,
		DropLifetime = dropLifetime,
		OozeDuration = oozeDuration,
		PastryLifetime = pastryLifetime,
		MaxPastrySize = maxPastrySize,
		FadeDuration = fadeDuration
	})
end