local import = _G.import("event")
local import2 = _G.import("modelUtil")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local emitters = game.ReplicatedStorage.ReplicatedAssets.Emitters
local v = {
	ColorSequence = { ColorSequence, ColorSequenceKeypoint },
	NumberSequence = { NumberSequence, NumberSequenceKeypoint }
}
local v2 = {
	Default = function(p, p2)
		return p * p2
	end
}
local v3 = {
	Default = function(p, p2)
		return p + p2
	end
}
local v4 = {
	Default = function(_, p)
		return p
	end
}
local partsByName = {}

local function adjustSequence(sequence, fn)
	local v5, v6 = unpack(v[typeof(sequence)])
	local v7 = {}

	for _, keypoint in pairs(sequence.Keypoints) do
		table.insert(v7, v6.new(keypoint.Time, fn(keypoint)))
	end

	return v5.new(v7)
end

local function grayScaleColorSequence(p)
	return adjustSequence(p, function(p2)
		local _, _, v5 = Color3.toHSV(p2.Value)
		return Color3.fromHSV(0, 0, v5)
	end)
end

local function operate(p, p2, p3)
	return (p3[typeof(p)] or p3.Default)(p, p2)
end

local function operateSequence(p, p2, p3)
	return adjustSequence(p, function(p4)
		return operate(p4.Value, p2, p3)
	end)
end

function v4.NumberSequence(p, p2)
	return operateSequence(p, p2, v4)
end

function v3.NumberSequence(p, p2)
	return operateSequence(p, p2, v3)
end

function v2.NumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

function v2.Color3(data, data2)
	return Color3.new(data.r * data2.r, data.g * data2.g, data.b * data2.b)
end

function v2.ColorSequence(p, p2)
	return operateSequence(p, p2, v2)
end

function v2.NumberSequence(p, p2)
	return operateSequence(p, p2, v2)
end

local EffectUtil = {
	connect = function(p, p2, p3)
		if isServer then
			return
		end

		local v5 = "effect/" .. p
		import.connect(v5, p2, {
			Blocking = true,
			Returning = true
		})
		import.remoteConnect(v5, p3 or p2)
	end,
	animate = function(p, callback, value)
		local total = 0
		local v5 = 0
		local v6 = value or 0

		while total < p do
			callback(total / p, v5, total / p - v5)
			v5 = total / p
			total += task.wait(v6)
		end

		callback(1, v5)
	end,
	animateHeart = function(p, callback, _)
		local total = 0
		local v5 = nil
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if p <= total or v5 then
				heartbeatConnection:Disconnect()
			else
				callback(total / p, dt, total)
			end
		end)
		return function()
			v5 = true
		end
	end
}

local function emit(instance, duration)
	if instance.ClassName == "ParticleEmitter" then
		instance.Enabled = false
		instance:Emit(count)

		if duration == 0 then
			return
		end

		local total = 0

		while total < duration do
			total += task.wait(0.16)
			instance:Emit(1)
		end
	else
		instance.Enabled = true
		task.wait(duration)
		instance:SetAttribute("PlayCount", instance:GetAttribute("PlayCount") - 1)

		if instance:GetAttribute("PlayCount") > 0 then
			return
		else
			instance.Enabled = false
		end
	end
end

local function enable(instance, duration)
	instance.Enabled = true
	instance:SetAttribute("PlayCount", (instance:GetAttribute("PlayCount") or 0) + 1)
	task.delay(duration, function()
		instance:SetAttribute("PlayCount", instance:GetAttribute("PlayCount") - 1)

		if instance:GetAttribute("PlayCount") > 0 then
			return
		end

		instance.Enabled = false
	end)
end

function EffectUtil.emitObject(folder)
	local v5 = 0

	for _, descendant in pairs(folder:GetDescendants()) do
		local emitDelay = descendant:GetAttribute("EmitDelay") or 0
		local emitDuration = descendant:GetAttribute("EmitDuration") or 0
		local fadeOut

		if descendant.ClassName == "ParticleEmitter" then
			local v6 = emitDelay
			local v7 = descendant
			task.defer(function()
				task.wait(v6)
				v7:Emit(v7:GetAttribute("EmitCount") or 2)
			end)
			fadeOut = emitDelay + math.max(emitDuration, descendant.Lifetime.Max)
		elseif descendant.ClassName == "Beam" then
			fadeOut = emitDelay + emitDuration
		elseif descendant.ClassName == "PointLight" then
			fadeOut = descendant:GetAttribute("FadeOut")

			if fadeOut then
				TweenService:Create(descendant, TweenInfo.new(fadeOut), {
					Brightness = 0
				}):Play()
			else
				fadeOut = emitDelay
			end
		else
			fadeOut = emitDelay
		end

		if emitDuration > 0 then
			local v6 = descendant
			local v7 = emitDuration
			task.delay(emitDelay, function()
				enable(v6, v7)
			end)
		end

		if fadeOut < v5 then
			v5 = v5 or fadeOut
		else
			v5 = fadeOut
		end
	end

	return v5
end

function EffectUtil.particles(p, parent, cframe)
	local folder = type(p) == "userdata" and p or partsByName[p]:Clone()

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
	end

	folder.Transparency = 1
	folder.Anchored = true
	folder.CanCollide = false

	if cframe then
		local model = Instance.new("Model")
		folder.Parent = model
		model.PrimaryPart = folder
		model:SetPrimaryPartCFrame(cframe)
	end

	if parent then
		folder.Parent = parent
	end

	return folder
end

function EffectUtil.emit(p, p2, p3)
	local particles = EffectUtil.particles(p, p2, p3)
	Debris:AddItem(particles, (EffectUtil.emitObject(particles)))
	return particles
end

local function runParticleDescendants(folder, fn)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant.ClassName == "ParticleEmitter" or descendant.ClassName == "Trail" or descendant.ClassName == "Beam" then
			fn(descendant)
		end
	end
end

function EffectUtil.mult(p, items)
	runParticleDescendants(p, function(instance)
		for attributeName, item in pairs(items) do
			if instance:GetAttribute(attributeName) then
				instance:SetAttribute(attributeName, operate(instance:GetAttribute(attributeName), item, v2))
			else
				local v5 = attributeName
				local v6 = item
				pcall(function()
					local v7 = instance
					local v9 = instance[v5]
					local v11 = v2
					v7[v5] = (v11[typeof(v9)] or v11.Default)(v9, v6)
				end)
			end
		end
	end)
end

function EffectUtil.add(p, items)
	runParticleDescendants(p, function(p2)
		for k, item in pairs(items) do
			local v5 = k
			local v6 = item
			pcall(function()
				local v7 = p2
				local v9 = p2[v5]
				local v11 = v3
				v7[v5] = (v11[typeof(v9)] or v11.Default)(v9, v6)
			end)
		end
	end)
end

function EffectUtil:scale(p)
	EffectUtil.mult(self, {
		Size = p,
		Squash = p,
		Acceleration = p,
		Speed = p,
		CurveSize0 = p,
		CurveSize1 = p,
		TextureLength = p,
		Width0 = p,
		Width1 = p
	})

	if not self:IsA("BasePart") then
		return
	end

	local parent = self.Parent
	local model = Instance.new("Model")
	model.PrimaryPart = self
	model.Parent = parent
	self.Parent = model
	import2.scale(model, p)
	self.Parent = parent
	model:Destroy()
end

function EffectUtil.scaleTransparency(p, p2)
	runParticleDescendants(p, function(p3)
		p3.Transparency = adjustSequence(p3.Transparency, function(p4)
			return 1 + (p4.Value - 1) / p2
		end)
	end)
end

function EffectUtil.set(p, items)
	runParticleDescendants(p, function(instance)
		for attributeName, item in pairs(items) do
			local v5 = attributeName
			local v6 = item
			local success, _ = pcall(function()
				local v7 = instance
				local v9 = instance[v5]
				local v11 = v4
				v7[v5] = (v11[typeof(v9)] or v11.Default)(v9, v6)
			end)

			if not success then
				instance:SetAttribute(attributeName, operate(instance:GetAttribute(attributeName), item, v4))
			end
		end
	end)
end

function EffectUtil.grayscale(p)
	runParticleDescendants(p, function(p2)
		p2.Color = adjustSequence(p2.Color, function(p3)
			local _, _, v5 = Color3.toHSV(p3.Value)
			return Color3.fromHSV(0, 0, v5)
		end)
	end)
end

function EffectUtil.recolor(folder, color)
	EffectUtil.grayscale(folder)
	EffectUtil.mult(folder, {
		Color = color
	})

	for _, light in pairs(folder:GetDescendants()) do
		if light:IsA("PointLight") then
			light.Color = color
		end
	end
end

EffectUtil.runParticleDescendants = runParticleDescendants

for _, part in pairs(emitters:GetDescendants()) do
	if part:IsA("BasePart") then
		partsByName[part.Name] = part
	end
end

return EffectUtil