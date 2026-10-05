local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local Pool = require(game.ReplicatedStorage:WaitForChild("Pool"))
local tweenModel = Util.TweenModel
local misc = Util.Misc
local debris = Util.Debris
local _ = Util.Rock2
local FX = require(game.ReplicatedStorage.FX)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local reference = FX:WaitForChild("Dough").Explosions.Spikywave.Reference
local scaleCF = misc.scaleCF

function buildModel(p, value, value2, value3)
	local v = value or 10
	local v2 = value3 or 8
	local v3 = value2 or 0
	local model = Instance.new("Model")
	model:SetAttribute("Scale", v)
	model:SetAttribute("Fold", v3)
	model.Name = "WindSpokes"
	local clone = reference.TallSpoke:Clone()
	clone:SetPrimaryPartCFrame(p * CFrame.new(0, v / 10, 0))
	model.PrimaryPart = clone.PrimaryPart
	clone.Parent = model
	local clones = {}
	local result = {}

	for i = 1, v2 do
		local v4 = 6.283185307179586 * (i / v2)
		local clone2 = reference.Spoke:Clone()
		clone2:SetPrimaryPartCFrame(model.PrimaryPart.CFrame * CFrame.Angles(0, v4, 0) * CFrame.new(0, 0, -v / 5))
		clone2.Parent = model
		table.insert(clones, clone2)
	end

	for _, descendant in pairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant ~= model.PrimaryPart then
			result[descendant] = {
				Offset = model.PrimaryPart.CFrame:ToObjectSpace(descendant.CFrame),
				PrimaryPart = model.PrimaryPart
			}
		end

		if descendant:IsA("Attachment") and not descendant:GetAttribute("Position") then
			descendant:SetAttribute("Position", descendant.Position)
			result[descendant] = {
				Position = descendant.Position,
				CFrame = descendant.CFrame
			}
		end

		if descendant:IsA("Beam") then
			result[descendant] = {
				CurveSize0 = descendant.CurveSize0,
				CurveSize1 = descendant.CurveSize1,
				Width0 = descendant.Width0,
				Width1 = descendant.Width1,
				Transparency = descendant.Transparency
			}
		end

		if not descendant:IsA("ParticleEmitter") then
			continue
		end

		local v4 = {
			Size = descendant.Size.Keypoints,
			Speed = descendant.Speed,
			Acceleration = descendant.Acceleration,
			Lifetime = descendant.Lifetime
		}
		Util.Misc.ScaleParticle(descendant, v / 10, v4)
		result[descendant] = v4
	end

	foldModel(model, result, clones, v3)
	scaleModel(model, result, clones, v)
	translate(model, p, result, clones, v)
	model.Parent = _WorldOrigin
	return model, result, clones
end

function translate(instance, p, items, _, p2)
	local fold = instance:GetAttribute("Fold")
	local v = fold < (fold or 0)
	local v2 = Util.Tween.ease.out[v and "sine" or "quad"](fold, 0, 1, 1)
	local v3 = Util.Tween.ease.out[v and "circ" or fold > 1 and "quad" or "circ"](fold, 1, -1, 1)

	for part, item in pairs(items) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CFrame = item.PrimaryPart.CFrame * scaleCF(item.Offset, p2 / 10 * v2)

		if part.Parent.Name == "Spoke" and part.Parent.PrimaryPart ~= part then
			part.CFrame *= CFrame.Angles(1.5707963267948966 * v3, 0, 0)
		end
	end

	instance:SetPrimaryPartCFrame(p * CFrame.new(0, p2 / 10, 0))
end

function scaleModel(instance, items, _, scale)
	instance:SetAttribute("Scale", scale)
	local fold = instance:GetAttribute("Fold")
	local v = fold < (fold or 0)
	local v2 = Util.Tween.ease.out[v and "sine" or "quad"](fold, 0, 1, 1)
	Util.Tween.ease.out[v and "sine" or fold > 1 and "quad" or "circ"](fold, 1, -1, 1)

	for instance2, item in pairs(items) do
		if instance2:IsA("Beam") then
			if not v then
				instance2.CurveSize0 = Util.Tween.point(
					not v and 0 or 0.5 * v2 or 0,
					item.CurveSize0,
					(math.min(1, v2))
				) * (scale / 10)
				instance2.CurveSize1 = Util.Tween.point(
					not v and 0 or 0.5 * v2 or 0,
					item.CurveSize1,
					(math.min(1, v2))
				) * (scale / 10)

				if instance2.Parent.Parent.Name == "TallSpoke" then
					instance2.Width0 = Util.Tween.point(0, item.Width0, v2) * (scale / 10)
					instance2.Width1 = item.Width1 * (scale / 10)
				else
					instance2.Width0 = Util.Tween.point(0, item.Width0, v2) * (scale / 10)
					instance2.Width1 = Util.Tween.point(0, item.Width1, v2) * (scale / 10)
				end
			end
		elseif instance2:IsA("Attachment") then
			if not v then
				if instance2.Name == "Tip" then
					instance2.Position = item.Position * (scale / 10) * Util.Tween.point(
						not v and 0 or 1.5 * v2 or 0,
						1,
						v2
					)
				else
					instance2.Position = item.Position * (scale / 10)
				end
			end
		elseif instance2:IsA("ParticleEmitter") and not v then
			Util.Misc.ScaleParticle(instance2, scale / 10, item)
		end
	end
end

function foldModel(instance, items, _, fold)
	instance:SetAttribute("Fold", fold)
	local v = fold < (instance:GetAttribute("Fold") or 0)
	Util.Tween.ease.out[v and "sine" or "quad"](fold, 0, 1, 1)
	local v2 = Util.Tween.ease.out[v and "sine" or fold > 1 and "quad" or "circ"](fold, 1, -1, 1)

	for beam, item in pairs(items) do
		if beam:IsA("Beam") then
			beam.Transparency = NumberSequence.new(
				Util.Tween.point(
					1,
					v and Util.Tween.point(item.Transparency.Keypoints[1].Value, 1, (math.max(0, v2))) or item.Transparency.Keypoints[1].Value,
					(math.max(0, v2))
				),
				Util.Tween.point(item.Transparency.Keypoints[1].Value, 1, (math.max(0, v2)))
			)
		end
	end
end

local v = Pool.new(string.format("Dough/%s/%s", script.Parent.name, script.Name))
v:setAction(function(object, _)
	local now = tick()

	for _, v2 in pairs(object.Pool) do
		local v3 = math.min(1, (now - v2.Start) / v2.Duration)
		local object2 = v2.Model.Object
		local spokes = v2.Model.Spokes
		local data = v2.Model.Data
		local scale = 0
		local v4 = 0

		if object2 and object2:IsDescendantOf(workspace) then
			if v2.Method == "FadeOut" then
				v4 = Util.Tween.point(1, 0, v3)
				scale = v2.Model.Scale
			elseif v2.Method == "Lifetime" then
				v4 = Util.Tween.point(0.5, 1, v3)
				scale = v2.Model.Scale
			elseif v2.Method == "FadeIn" then
				scale = v2.Model.Scale * v3
				v4 = Util.Tween.point(0, 0.5, v3)
			end

			foldModel(object2, data, spokes, v4)
			scaleModel(object2, data, spokes, scale)
			translate(object2, v2.Model.CFrame, data, spokes, scale)

			if v2.Method == "FadeOut" and v3 == 1 then
				object:remove(v2)
			end
		else
			object:remove(v2)
		end
	end
end)
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 10
	local fadeIn = data.FadeIn or 0.15
	local lifetime = data.Lifetime or 0.5
	local fadeOut = data.FadeOut or 0.25
	local cFrame2 = cFrame * CFrame.new(0, -scale / 10 * 0.75, 0)
	local clone = reference.Core:Clone()
	clone.Size = Vector3.new(2 * scale, 1, 2 * scale)
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	local v3 = 0

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			local v4 = 0.65 / (fadeIn + lifetime)
			descendant.Lifetime = NumberRange.new(descendant.Lifetime.Min * v4, descendant.Lifetime.Max * v4)
			v3 = math.max(v3, descendant.Lifetime.Max)
			Util.Misc.ScaleParticle(descendant, scale / 10 * 1.25, {
				ZOffset = descendant.ZOffset + 0.5
			})
			local enable = descendant:GetAttribute("Enable")
			local emitCount = descendant:GetAttribute("EmitCount")

			if not descendant.Name:find("Beam") and (descendant.Parent.Name ~= "Center" or descendant.Name ~= "Balls") and emitCount then
				descendant:Emit(emitCount)
			end

			if enable then
				descendant.Enabled = true
				local v5 = descendant
				task.delay(fadeIn + lifetime, function()
					v5.Enabled = false
				end)
			end
		end

		if descendant:IsA("Attachment") then
			descendant.Position *= scale / 10
		end
	end

	local model, v4, spokes = buildModel(cFrame2, scale, 0, 8)

	for emitter, v6 in pairs(v4) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v7 = 0.65 / (fadeIn + lifetime)
		emitter.Lifetime = NumberRange.new(v6.Lifetime.Min * v7, v6.Lifetime.Max * v7)
		v3 = math.max(v3, emitter.Lifetime.Max)
	end

	local random = Random.new()
	task.delay(fadeIn / 2, function()
		local v6 = scale * 1.5
		tweenModel(reference.WindRings, {
			CFrame = cFrame2 * CFrame.Angles(0, random:NextNumber(-1, 1) * 3.141592653589793, 0),
			Scale = v6 * 0.5,
			Size = createVector(2, 1, 2),
			Transparency = 0.3
		}, {
			Tween = TweenInfo.new(fadeIn + lifetime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			CFrame = CFrame.new(0, v6 / 2, 0) * CFrame.Angles(0, 3.14, 0),
			Size = createVector(1.25, 0.5, 1.2),
			Scale = v6 * 1.25,
			Transparency = 1
		})
		task.delay(fadeIn / 2, function()
			tweenModel(reference.WindRings, {
				CFrame = cFrame2 * CFrame.new(0, v6 / 2, 0) * CFrame.Angles(
					0,
					random:NextNumber(-1, 1) * 3.141592653589793,
					0
				),
				Scale = v6 * 0.5,
				Size = createVector(1.5, 1.25, 1.5),
				Transparency = 0.3
			}, {
				Tween = TweenInfo.new(fadeIn + lifetime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				CFrame = CFrame.new(0, v6 / 4, 0) * CFrame.Angles(0, 3.14, 0),
				Size = createVector(0.25, 2, 0.25),
				Scale = v6 * 1.25,
				Transparency = 1
			})
		end)
	end)

	for emitter, _ in pairs(v4) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if not emitCount then
			continue
		end

		emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min / 2, emitter.Lifetime.Max / 2)
		emitter:Emit(emitCount)
	end

	local v6 = v:add({
		Model = {
			CFrame = cFrame2,
			Scale = scale,
			Object = model,
			Spokes = spokes,
			Data = v4
		},
		Method = "FadeIn",
		Duration = fadeIn,
		Start = tick()
	})
	task.wait(fadeIn)

	for emitter, v7 in pairs(v4) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if not emitCount then
			continue
		end

		emitter.Speed = v7.Speed
		emitter.Lifetime = v7.Lifetime
		emitter:Emit(emitCount)
	end

	v6.Duration = lifetime
	v6.Start = tick()
	v6.Method = "Lifetime"
	task.wait(lifetime)
	TweenService:Create(clone, TweenInfo.new(fadeOut, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Size = createVector(1, 1, 1)
	}):Play()
	tweenModel(reference.WindRing, {
		CFrame = cFrame2 * CFrame.new(0, scale * 0.25, 0) * CFrame.Angles(
			0,
			random:NextNumber(-1, 1) * 3.141592653589793,
			0
		),
		Scale = scale * 1.75,
		Size = createVector(2, 0, 2),
		Transparency = 0.8
	}, {
		Tween = TweenInfo.new(fadeOut, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		CFrame = CFrame.new(0, scale * 0.1, 0) * CFrame.Angles(0, 3.14, 0),
		Size = createVector(0.5, 2, 0.5),
		Scale = scale * 1,
		Transparency = 1
	})
	task.delay(fadeOut / 1.75, function()
		for _, emitter in pairs(clone:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter.Name == "Particles") then
				continue
			end

			local v10 = emitter.Lifetime.Min / emitter.Lifetime.Max
			emitter.Lifetime = NumberRange.new(
				math.max(emitter.Lifetime.Min, fadeOut * v10),
				(math.max(emitter.Lifetime.Min, fadeOut * v10))
			)
			local enable = emitter:GetAttribute("Enable")
			local emitCount = emitter:GetAttribute("EmitCount")

			if emitCount then
				emitter:Emit(emitCount)
			end

			if not enable then
				continue
			end

			emitter.Enabled = true
			local v11 = emitter
			task.delay(fadeOut, function()
				v11.Enabled = false
			end)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and (emitter.Name:find("Beam") or emitter.Parent.Name == "Center" and emitter.Name == "Balls")) then
				continue
			end

			local emitCount = emitter:GetAttribute("EmitCount")

			if emitCount then
				emitter:Emit(emitCount)
			end
		end

		tweenModel(reference.WindRings, {
			CFrame = cFrame2 * CFrame.new(0, 0, 0) * CFrame.Angles(0, random:NextNumber(-1, 1) * 3.141592653589793, 0),
			Scale = scale * 0.5,
			Size = createVector(2, 1.25, 2),
			Transparency = 0.15
		}, {
			Tween = TweenInfo.new(fadeOut + lifetime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			CFrame = CFrame.new(0, scale / 2, 0) * CFrame.Angles(0, 3.14, 0),
			Size = createVector(0.25, 2, 0.25),
			Scale = scale * 1.25,
			Transparency = 1
		})
		task.wait(fadeOut - fadeOut / 1.75)
		tweenModel(reference.WindRings, {
			CFrame = cFrame2 * CFrame.new(0, scale / 2, 0) * CFrame.Angles(
				0,
				random:NextNumber(-1, 1) * 3.141592653589793,
				0
			),
			Scale = scale * 0.5,
			Size = createVector(1.5, 1.25, 1.5),
			Transparency = 0.15
		}, {
			Tween = TweenInfo.new((fadeOut + lifetime) / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			CFrame = CFrame.new(0, scale, 0) * CFrame.Angles(0, 3.14, 0),
			Size = createVector(0.125, 2, 0.125),
			Scale = scale * 1.25,
			Transparency = 1
		})
	end)
	v6.Duration = fadeOut
	v6.Start = tick()
	v6.Method = "FadeOut"
	debris:AddItem(model, fadeOut + v3, function()
		v4 = {}
		spokes = {}
		clone:Destroy()
	end)
end