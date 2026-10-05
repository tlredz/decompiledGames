local RunService = game:GetService("RunService")
local VisualHelper = {
	BeamsFlipBook = require(script.BeamsFlipBook),
	Tween = function(self, ...)
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(...)
		tween:Play()
		return tween
	end,
	VFXVisible = function(_, vector: Vector3)
		return (workspace.CurrentCamera.CFrame.Position - vector).Magnitude < 1200
	end
}
local v = {}
local heartbeatConnection = nil

local function StepBezierMovers(p: number)
	for i = #v, 1, -1 do
		local v2 = v[i]
		v2.Elapsed += p
		local v3 = math.min(v2.Elapsed / v2.Duration, 1)
		local v4 = v3 >= 1

		if v2.Attachment.Parent then
			local v5 = math.sin(v3 * 3.141592653589793 * 0.5)
			local v6 = 1 - v5
			v2.Attachment.WorldPosition = v6 ^ 3 * v2.P0 + v6 ^ 2 * 3 * v5 * v2.C1 + v6 * 3 * v5 ^ 2 * v2.C2 + v5 ^ 3 * v2.P1
		else
			v4 = true
		end

		if not v4 then
			continue
		end

		table.remove(v, i)

		if v2.OnComplete then
			task.spawn(v2.OnComplete)
		end
	end

	if #v == 0 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

function VisualHelper.MoveAlongBezierTrail(_, attachment, duration: number, vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3, onComplete)
	table.insert(v, {
		Attachment = attachment,
		Elapsed = 0,
		Duration = duration,
		P0 = vector,
		C1 = vector2,
		C2 = vector3,
		P1 = vector4,
		OnComplete = onComplete
	})

	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(StepBezierMovers)
	end
end

function VisualHelper.BlinkHideModel(_, folder)
	local result = {}

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			if descendant.Name ~= "HumanoidRootPart" and descendant:GetAttribute("NoCanVisible") ~= true then
				descendant.LocalTransparencyModifier = 1
			end
		elseif (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam")) and descendant.Enabled and descendant:GetAttribute("NoCanVisible") ~= true then
			result[descendant] = true
			descendant.Enabled = false
		end
	end

	return result
end

function VisualHelper.BlinkShowModel(_, folder, items)
	for _, descendant in folder:GetDescendants() do
		if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Name ~= "HumanoidRootPart" and descendant:GetAttribute("NoCanVisible") ~= true) then
			continue
		end

		descendant.LocalTransparencyModifier = 0
	end

	if items then
		for k in items do
			if k.Parent then
				k.Enabled = true
			end
		end
	end
end

function VisualHelper:BuildUniqueName(p, p2: string)
	return (`{p}-{p2}`)
end

function VisualHelper.OwnerName(_, value)
	if typeof(value) == "Instance" then
		return value.Name
	end

	if type(value) ~= "table" then
		return "Unknown"
	end

	if type(value.Name) == "string" then
		return value.Name
	end

	if typeof(value.Character) == "Instance" then
		return value.Character.Name
	end

	return "Unknown"
end

function VisualHelper:FindByUniqueName(p, p2: string, p3)
	return (p3 or p):FindFirstChild(self:BuildUniqueName(p, p2))
end

function VisualHelper:TweenNumberValue(p: number, p2, callback, value: number?)
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

function VisualHelper:TweenCFrameValue(cframe: CFrame, p, callback, cframe2: CFrame?)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = cframe2 or CFrame.identity
	self:Tween(cFrameValue, p, {
		Value = cframe
	})

	if callback then
		cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			callback(cFrameValue.Value)
		end)
	end

	task.delay(p.Time * (p.Reverses and 2 or 1) + 0.5, function()
		cFrameValue:Destroy()
	end)
	return cFrameValue
end

function VisualHelper:TweenModel(folder, p, cframe)
	if RunService:IsStudio() and typeof(folder) == "Instance" then
		local flag = false

		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("ManualWeld") or descendant:IsA("Weld") or descendant:IsA("Motor6D")) then
				continue
			end

			flag = true
			break
		end

		if flag then
			warn("RED ALERT!!!", folder, "is has welds inside and is being TweenModel'd. needs manual fixing")
			folder:PivotTo(cframe)
			return
		end
	end

	return self:TweenCFrameValue(cframe, p, function(cframe2)
		folder:PivotTo(cframe2)
	end, folder:GetPivot())
end

function VisualHelper:TweenScale(folder, p, p2: number)
	if RunService:IsStudio() and typeof(folder) == "Instance" then
		local flag = false

		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("ManualWeld") or descendant:IsA("Weld") or descendant:IsA("Motor6D")) then
				continue
			end

			flag = true
			break
		end

		if flag then
			warn("RED ALERT!!!", folder, "is has welds inside and is being TweenScale'd. needs manual fixing")
			folder:ScaleTo(p2)
			return
		end
	end

	local now = 0
	return self:TweenNumberValue(p2, p, function(p3)
		if os.clock() - now > 0.016666666666666666 or p3 == p2 then
			now = os.clock()
			folder:ScaleTo(p3)
		end
	end, folder:GetScale())
end

function VisualHelper:ModelParts(folder, callback, flag: boolean?, list)
	for _, descendant in folder:GetDescendants() do
		if not ((flag and descendant:IsA("Decal") or descendant:IsA("BasePart")) and descendant:GetAttribute("NoCanVisible") ~= true) then
			continue
		end

		if list and table.find(list, descendant.Name) or descendant.Name == "HumanoidRootPart" then
			continue
		end

		callback(descendant)
	end
end

function VisualHelper.ObjectScaleTo(_, p, p2: number)
	local parent = p.Parent
	local model = Instance.new("Model", parent)
	p.Parent = model
	model:ScaleTo(p2)
	p.Parent = parent
	model:Destroy()
end

function VisualHelper:ModelTransparency(instance, p: number, ...)
	local v2 = { ... }
	local v3 = v2[1] == nil or v2[1]
	local v4 = instance:FindFirstChild("Humanoid") ~= nil
	self:ModelParts(instance, function(instance2)
		local usualControlTransparency = p

		if v4 then
			if not instance2:GetAttribute("UsualControlTransparency") then
				instance2:SetAttribute("UsualControlTransparency", instance2.Transparency)
			end

			if usualControlTransparency < 1 then
				usualControlTransparency = instance2:GetAttribute("UsualControlTransparency")
			end
		end

		if instance2.Transparency ~= usualControlTransparency then
			instance2.Transparency = usualControlTransparency
		end
	end, v3, ...)

	if v4 then
		if p >= 1 then
			if (instance:GetAttribute("UsualControlTransparency") or 0) >= 1 then
				return
			end

			instance:SetAttribute("UsualControlTransparency", 1)
			local CharacterTransparency = require(game.ReplicatedStorage.CharacterTransparency)
			local v5 = CharacterTransparency:AddStack(instance, "ControlInvis", 2)
			instance:GetAttributeChangedSignal("UsualControlTransparency"):Once(function()
				v5:Destroy()
			end)
		else
			instance:SetAttribute("UsualControlTransparency", 0)
		end
	end
end

function VisualHelper:Emit(instance, color: Color3?)
	instance.Color = color or instance.Color
	local delay = instance:GetAttribute("Delay") or instance:GetAttribute("EmitDelay")
	local emit = instance:GetAttribute("Emit") or instance:GetAttribute("EmitCount")

	if delay then
		task.delay(delay, function()
			instance:Emit(emit)
		end)
	elseif emit then
		instance:Emit(emit)
	end
end

function VisualHelper:EmitAll(folder, flag: boolean?, parent, color: Color3?)
	for _, clone in typeof(folder) == "table" and folder or flag and folder:GetChildren() or folder:GetDescendants(), nil, nil do
		if not clone:IsA("ParticleEmitter") then
			continue
		end

		if parent then
			clone = clone:Clone()
			clone.Parent = parent
		end

		self:Emit(clone, color)
	end
end

function VisualHelper.SetEnableAll(_, folder, enabled: boolean, flag: boolean?, list)
	for _, v2 in typeof(folder) == "table" and folder or flag and folder:GetChildren() or folder:GetDescendants(), nil, nil do
		if not table.find({ "ParticleEmitter", "Trail", "Beam" }, v2.ClassName) or list and table.find(list, v2.Name) then
			continue
		end

		v2.Enabled = enabled
	end
end

function VisualHelper.CapEmitterRates(_, folder, rate: number, flag: boolean?)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") or emitter.Rate <= rate then
			continue
		end

		local v2 = emitter.Rate / rate
		emitter.Rate = rate

		if (emitter.Lifetime.Min + emitter.Lifetime.Max) / 2 < 0.05 or not (flag or not (emitter:GetAttribute("Emit") or emitter:GetAttribute("EmitCount"))) then
			continue
		end

		local numberSequenceKeypoints = {}

		for _, keypoint in emitter.Transparency.Keypoints do
			local v3 = math.clamp(1 - keypoint.Value, 0, 1)
			local v4

			if emitter.LightEmission >= 0.5 then
				v4 = math.min(1, v3 * v2)
			else
				v4 = 1 - (1 - v3) ^ v2
			end

			local v5 = 1 - v4
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(keypoint.Time, v5, (math.min(keypoint.Envelope, v5, 1 - v5)))
			)
		end

		emitter.Transparency = NumberSequence.new(numberSequenceKeypoints)
	end
end

function VisualHelper.ThinEmitBursts(_, folder, value: number?, value2: number?)
	local v2 = value or 40
	local v3 = value2 or 80

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter:GetAttribute("Emit") and "Emit" or emitter:GetAttribute("EmitCount") and "EmitCount"

		if not v4 then
			continue
		end

		local attribute = emitter:GetAttribute(v4)

		if type(attribute) ~= "number" or attribute <= 1 then
			continue
		end

		local v5 = 0

		for _, keypoint in emitter.Size.Keypoints do
			v5 = math.max(v5, keypoint.Value)
		end

		if v5 < v2 then
			continue
		end

		local v6

		if v3 <= v5 then
			v6 = math.ceil(attribute / 3)
		else
			v6 = math.ceil(attribute / 2)
		end

		emitter:SetAttribute(v4, v6)
	end
end

function VisualHelper.MoonCameraAnimation(_, state, instance, reference, value: number?, flag: boolean?, callback)
	local v2 = {
		Camera = state,
		LastCamerCFrame = state.CFrame,
		LastCameraType = state.CameraType,
		Speed = 1,
		Fps = value or 60,
		Frame = 0,
		Reference = reference
	}
	v2.Camera.CameraType = Enum.CameraType.Scriptable

	function v2:Release(flag2: boolean?)
		self.Connection:Disconnect()

		if flag2 then
			return
		end

		local camera = self.Camera
		local camera2 = self.Camera
		local lastCameraType = self.LastCameraType
		local lastCamerCFrame = self.LastCamerCFrame
		camera.CameraType = lastCameraType
		camera2.CFrame = lastCamerCFrame

		if callback then
			return callback(self.LastCamerCFrame)
		end
	end

	function v2:AdjustSpeed(speed: number)
		self.Speed = speed
	end

	local RunService2 = game:GetService("RunService")
	v2.Connection = RunService2.PreSimulation:Connect(function(dt)
		v2.Frame += dt * v2.Fps * v2.Speed
		local child = instance:FindFirstChild((tostring((math.ceil(v2.Frame)))))

		if child then
			state.CFrame = (typeof(reference) == "CFrame" and reference or reference.CFrame) * child.Value
		else
			v2:Release(flag)
		end
	end)
	return v2
end

function VisualHelper:Fade(flag: boolean)
	local Players = game:GetService("Players")
	local fade = Players.LocalPlayer.PlayerGui:FindFirstChild("Fade")

	if not fade then
		return
	end

	local top = fade.Top
	local back = fade.Back
	local position = top.Position
	local position2 = back.Position

	if flag then
		fade.Enabled = true
		local uDim = UDim2.new(0.5, 0, top.Position.Y.Scale - 0.1, 0)
		local uDim2 = UDim2.new(0.5, 0, back.Position.Y.Scale + 0.1, 0)
		top.Position = uDim
		back.Position = uDim2
		self:Tween(top, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Position = position
		})
		self:Tween(back, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Position = position2
		})
	else
		self:Tween(top, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Position = UDim2.new(0.5, 0, top.Position.Y.Scale - 0.1, 0)
		})
		self:Tween(back, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Position = UDim2.new(0.5, 0, back.Position.Y.Scale + 0.1, 0)
		})
		task.wait(0.3)
		top.Position = position
		back.Position = position2
		fade.Enabled = false
	end
end

function VisualHelper:ImpactFrame(duration: number, duration2: number, p: number, value: number?, saturation: number?, value2: number?, value3: number?)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = game:GetService("Lighting")
	return colorCorrectionEffect, task.defer(function()
		saturation = saturation or -1
		value2 = value2 or -2

		if duration > 0 then
			self:Tween(colorCorrectionEffect, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
				Saturation = saturation,
				Contrast = value2
			})
			task.wait(duration)
		else
			local v3 = colorCorrectionEffect
			local contrast = value2
			colorCorrectionEffect.Saturation = saturation
			v3.Contrast = contrast
		end

		for i = 1, p do
			colorCorrectionEffect.Contrast = i % 2 == 0 and value2 or value3 or 1
			task.wait((value or 1) / p)
		end

		if duration2 > 0 then
			self:Tween(colorCorrectionEffect, TweenInfo.new(duration2), {
				Saturation = 0,
				Contrast = 0
			})
			task.wait(duration2)
		end

		colorCorrectionEffect:Destroy()
	end)
end

function VisualHelper.Flipbook(_, items, instance, value: number?, value2: number?, flag: boolean?)
	local v2 = 1 / (value or 25)
	local v3

	if instance:IsA("Decal") or instance:IsA("Texture") then
		v3 = "Texture"
	elseif instance:IsA("SpecialMesh") then
		v3 = "TextureId"
	elseif instance:IsA("MeshPart") then
		v3 = "TextureID"
	else
		v3 = "Image"
	end

	local function Render()
		for _, item in items do
			if not instance or instance.Parent == nil then
				return true
			end

			instance[v3] = `rbxassetid://{item}`
			task.wait(v2)
		end
	end

	return (task.spawn(function()
		if flag then
			while not Render() do

			end
		else
			for _ = 1, value2 or 1 do
				if Render() then
					break
				end
			end
		end
	end))
end

function VisualHelper.EmitParticlesByRate(_, items)
	local nows = {}
	local RunService2 = game:GetService("RunService")
	return RunService2.Heartbeat:Connect(function()
		for _, item in items do
			if not (tick() - (nows[item] or 0) > 1 / item.Rate) then
				continue
			end

			item:Emit(1)
			nows[item] = tick()
		end
	end)
end

function VisualHelper:TweenBeamTransparency(items, callback, p, p2: number?, value: number?)
	return self:TweenNumberValue(value or 1, p, function(p3: number)
		for _, item in items do
			item.Transparency = callback(p3, item)
		end
	end, p2)
end

return VisualHelper