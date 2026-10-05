local TweenService = game:GetService("TweenService")
local VisualController = {}

function VisualController.Debris(_, instance, duration: number)
	return task.delay(duration, function()
		instance:Destroy()
	end)
end

function VisualController:Tween(p, p2, p3, flag: boolean?)
	local tween = TweenService:Create(p, p2, p3)

	if not flag then
		tween:Play()
	end

	return tween
end

function VisualController:TweenNumberValue(p: number, p2, callback, value: number?)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = value or 0
	self:Tween(numberValue, p2, {
		Value = p
	})

	if callback then
		numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			callback(numberValue.Value)
		end)
	end

	task.delay(p2.Time * (p2.Reverses and 2 or 1) + 0.5, function()
		numberValue:Destroy()
	end)
	return numberValue
end

function VisualController:TweenScale(instance, p, p2: number)
	return self:TweenNumberValue(math.max(p2, 0.01), p, function(p3)
		instance:ScaleTo((math.max(p3, 0.001)))
	end, instance:GetScale())
end

function VisualController:ForModelParts(folder, callback, flag: boolean?, list)
	for _, descendant in folder:GetDescendants() do
		if not ((flag and descendant:IsA("Decal") or descendant:IsA("BasePart")) and descendant:GetAttribute("TransparencyLocked") ~= true) then
			continue
		end

		if list and table.find(list, descendant.Name) then
			continue
		end

		callback(descendant)
	end
end

function VisualController:ModelTransparency(p, transparency: number)
	self:ForModelParts(p, function(decal)
		if decal:IsA("Decal") then
		end

		decal.Transparency = transparency
	end, true, { "HumanoidRootPart" })
end

function VisualController.Weld(_, p, part, cframe: CFrame?, cframe2: CFrame?)
	local weld = Instance.new("Weld")
	weld.Part0 = p
	weld.Part1 = part
	local C0 = cframe or CFrame.new()
	local C1 = cframe2 or CFrame.new()
	weld.C0 = C0
	weld.C1 = C1
	weld.Parent = p
	return weld
end

function VisualController:Emit(instance, p, p2: number?)
	instance.Color = p or instance.Color
	instance.TimeScale = p2 or instance.TimeScale
	local delay = instance:GetAttribute("Delay") or instance:GetAttribute("EmitDelay")
	local emit = instance:GetAttribute("Emit") or instance:GetAttribute("EmitCount")

	if not emit then
		return
	end

	if delay then
		task.delay(delay, function()
			instance:Emit(emit)
		end)
	end

	instance:Emit(emit)
end

function VisualController:DepthEmit(value, p: number?, p2, p3: number?)
	local emitRecursive

	emitRecursive = function(items, p4: number)
		if p and p <= p4 then
			return
		end

		for _, emitter in items do
			if emitter:IsA("ParticleEmitter") then
				self:Emit(emitter, p2, p3)
			end

			emitRecursive(emitter:GetChildren(), p4 + 1)
		end
	end

	local v

	if typeof(value) == "Instance" then
		v = value:GetChildren()
	else
		v = type(value) ~= "table" and {} or value
	end

	emitRecursive(v, 0)
end

function VisualController:Toggle(effect, enabled: boolean)
	if effect:IsA("Beam") then
		effect.Enabled = enabled
	elseif effect:IsA("ParticleEmitter") then
		effect.Enabled = enabled
	elseif effect:IsA("Trail") then
		effect.Enabled = enabled
	else
		error((`unsupported type: {effect.Class}`))
	end
end

function VisualController.RescaleTo(_, p, p2: number)
	local parent = p.Parent
	local model = Instance.new("Model")
	p.Parent = model
	model:ScaleTo(p2)
	p.Parent = parent
	model:Destroy()
	return p
end

function VisualController:DepthToggle(value, flag: boolean, p: number?, _)
	local toggleRecursive

	toggleRecursive = function(items, p2: number)
		if p and p <= p2 then
			return
		end

		for _, effect in items do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
				self:Toggle(effect, flag)
			end

			toggleRecursive(effect:GetChildren(), p2 + 1)
		end
	end

	local v

	if typeof(value) == "Instance" then
		v = value:GetChildren()
	else
		v = type(value) ~= "table" and {} or value
	end

	toggleRecursive(v, 0)
end

function VisualController.AdjustBeamTransparency(_, instance, p: number)
	if not instance:GetAttribute("BaseTransparency") then
		instance:SetAttribute("BaseTransparency", instance.Transparency)
	end

	local numberSequenceKeypoints = {}

	for _, keypoint in instance:GetAttribute("BaseTransparency").Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value + (1 - keypoint.Value) * p)
		)
	end

	instance.Transparency = NumberSequence.new(numberSequenceKeypoints)
end

return VisualController