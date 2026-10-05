local ObjectService = {}
ObjectService.__index = ObjectService
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Welding = require(script.Parent.Welding)
local mesh_emit = require(ReplicatedStorage.Resources.mesh_emit)

-- equivalent calls inferred from this helper; original call sites unknown
local function ChangeDescendantsProperties(folder, className, p, p2)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA(className) then
			descendant[p] = p2
		end
	end
end

local function SetTrailEnabled(folder, p)
	ChangeDescendantsProperties(folder, "Trail", "Enabled", p) -- equivalent call inferred; original call site unknown
end

local function EmitMeshes(folder)
	for _, model in pairs(folder:GetDescendants()) do
		if model:IsA("Model") and model:GetAttribute("AttributesAdded") == true then
			mesh_emit.new(model):Emit(model:GetPivot())
		end
	end
end

local function SetParticleEnabled(object, p)
	ChangeDescendantsProperties(object, "ParticleEmitter", "Enabled", p) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddOriginals(parent)
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Name = "OriginalSize"
	vector3Value.Parent = parent
	vector3Value.Value = parent.Size
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "OriginalTransparency"
	numberValue.Parent = parent
	numberValue.Value = parent.Transparency
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddOriginalsV2(parent)
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Name = "OriginalScale"
	vector3Value.Parent = parent
	vector3Value.Value = parent.scale
end

function ObjectService.SetCollision(p, canCollide: boolean)
	if not p.Object or p.Type == "Attachment" then
		return
	end

	if p.Type == "FullMesh" or p.Type == "ParticlePart" then
		p.Object.CanCollide = canCollide
	else
		ChangeDescendantsProperties(p.Object, "BasePart", "CanCollide", canCollide)
	end
end

function ObjectService.SetSize(p, size: Vector3)
	if not p.Object or p.Type == "Attachment" then
		return
	end

	p.Object.Size = size
end

function ObjectService.SetTransparency(p, transparency: number)
	if not p.Object or p.Type == "Attachment" then
		return
	end

	if p.Type == "FullMesh" or p.Type == "ParticlePart" then
		p.Object.Transparency = transparency
	else
		ChangeDescendantsProperties(p.Object, "BasePart", "Transparency", transparency)
	end
end

function ObjectService:SetCFrame(cFrame: CFrame)
	if not self.Object or self.Type == "Attachment" then
		return
	end

	if self.Type == "FullMesh" or self.Type == "ParticlePart" then
		self.Object.CFrame = cFrame
	else
		self.Object:PivotTo(cFrame)
	end
end

function ObjectService.SetOrientation(p, orientation: Vector3)
	if not p.Object or p.Type == "Attachment" or p.Type == "Model" then
		return
	end

	p.Object.Orientation = orientation
end

function ObjectService.SetAttachmentCFrame(p, flag: boolean, cframe: CFrame)
	if not p.Object or p.Type ~= "Attachment" then
		return
	end

	if flag then
		p.Object.WorldCFrame = cframe
	else
		p.Object.CFrame = cframe
	end
end

function ObjectService.SetAttachmentPosition(p, flag: boolean, vector: Vector3)
	if not p.Object or p.Type ~= "Attachment" then
		return
	end

	if flag then
		p.Object.WorldPosition = vector
	else
		p.Object.Position = vector
	end
end

function ObjectService:ParentTo(parent)
	if not self.Object then
		return
	end

	self.Object.Parent = parent
end

function ObjectService:SetOriginals()
	if not self.Object or self.Type == "Attachment" then
		return
	end

	if self.Type == "Model" then
		for _, descendant in pairs(self.Object:GetDescendants()) do
			if descendant:IsA("BasePart") then
				AddOriginals(descendant) -- equivalent call inferred; original call site unknown
			end

			if not descendant:IsA("SpecialMesh") then
				continue
			end

			AddOriginalsV2(descendant) -- equivalent call inferred; original call site unknown
		end
	else
		if self.Type == "MeshPart" then
			for _, specialMesh in pairs(self.Object:GetDescendants()) do
				if not specialMesh:IsA("SpecialMesh") then
					continue
				end

				AddOriginalsV2(specialMesh) -- equivalent call inferred; original call site unknown
			end
		end

		AddOriginals(self.Object) -- equivalent call inferred; original call site unknown
	end
end

function ObjectService:Destroy(duration: number)
	if not self.Object then
		return
	end

	if duration == nil or duration <= 0 then
		self.Object:Destroy()
	else
		task.delay(duration, function()
			self.Object:Destroy()
		end)
	end
end

function ObjectService:Emit()
	if not self.Object then
		return
	end

	EmitMeshes(self.Object)

	for _, descendant in pairs(self.Object:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			local v = descendant
			task.delay(descendant:GetAttribute("EmitDelay"), function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		if descendant:IsA("Sound") then
			descendant:Play()
		end
	end
end

function ObjectService.EmitV2(p)
	if not p.Object then
		return
	end

	for _, emitter in pairs(p.Object:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitDuration")) then
			continue
		end

		local v = emitter
		task.delay(emitter:GetAttribute("EmitDelay"), function()
			if v:GetAttribute("EmitDuration") > 0 then
				v.Enabled = true
				task.delay(v:GetAttribute("EmitDuration"), function()
					v.Enabled = false
				end)
			end
		end)
	end
end

function ObjectService:SelectiveEmit(p: string)
	if not self.Object then
		return
	end

	for _, emitter in pairs(self.Object:GetDescendants()) do
		if emitter.Name ~= p then
			continue
		end

		if emitter:IsA("ParticleEmitter") then
			local v = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		else
			self:Emit()
		end
	end
end

function ObjectService.Enable(p)
	if not p.Object then
		return
	end

	SetParticleEnabled(p.Object, true)
end

function ObjectService.Disable(p)
	if not p.Object then
		return
	end

	SetParticleEnabled(p.Object, false)
end

function ObjectService.EnableBeams(p, _, duration)
	if not p.Object then
		return
	end

	for _, effect in pairs(p.Object:GetDescendants()) do
		if effect:IsA("Beam") then
			effect.Enabled = true
			local brightness = effect.Brightness
			local lightEmission = effect.LightEmission
			effect.Brightness = 0
			effect.LightEmission = 1
			local tweenInfo = TweenInfo.new(duration)
			local TweenService = game:GetService("TweenService")
			TweenService:Create(effect, tweenInfo, {
				LightEmission = lightEmission,
				Brightness = brightness
			}):Play()
		end

		if effect:IsA("Trail") then
			effect.Enabled = true
		end
	end
end

local v = {
	Linear = function(p)
		return p
	end,
	Quad = function(p)
		return p * p
	end,
	Cubic = function(p)
		return p * p * p
	end,
	Quart = function(p)
		return p * p * p * p
	end,
	Quint = function(p)
		return p * p * p * p * p
	end,
	Sine = function(p)
		return 1 - math.cos(p * 3.141592653589793 / 2)
	end,
	Exp = function(p)
		if p == 0 then
			return 0
		end

		return (math.pow(2, 10 * (p - 1)))
	end
}

local function ApplyEasing(p, callback, p2)
	if p2 == "In" then
		return callback(p)
	elseif p2 == "Out" then
		return 1 - callback(1 - p)
	end

	if p2 ~= "InOut" then
		return p
	end

	if p < 0.5 then
		return callback(p * 2) / 2
	end

	return 1 - callback((1 - p) * 2) / 2
end

function ObjectService.DisableBeams(p, p2, value, value2)
	if not p.Object then
		return
	end

	local v2 = value2 or "Out"
	local v3 = v[value or "Linear"] or v.Linear

	for _, beam in pairs(p.Object:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v4 = beam
		task.spawn(function()
			local transparency = v4.Transparency
			local v5 = v4
			local keypoints = v5.Transparency.Keypoints
			local v6 = {}

			for i, keypoint in ipairs(keypoints) do
				v6[i] = keypoint.Value
			end

			local lastTime = tick()

			while true do
				local v7 = math.clamp((tick() - lastTime) / p2, 0, 1)
				local applyEasing = ApplyEasing(v7, v3, v2)
				local numberSequenceKeypoints = {}

				for i, keypoint in ipairs(keypoints) do
					local v9 = v6[i] + (1 - v6[i]) * applyEasing
					numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(keypoint.Time, v9)
				end

				v5.Transparency = NumberSequence.new(numberSequenceKeypoints)
				task.wait()

				if not (v7 >= 1) then
					continue
				end

				v5.Enabled = false
				v5.Transparency = transparency
				warn("Beam effect completed")
				break
			end
		end)
	end
end

function ObjectService.SlowBeams(p, p2, p3, p4, p5, p6)
	if not p.Object then
		return
	end

	for _, beam in pairs(p.Object:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local tweenProperty = TweeningModule.TweenProperty
		local textureSpeed

		if p6 then
			textureSpeed = beam.TextureSpeed / p5
		else
			textureSpeed = p5
		end

		tweenProperty(beam, p2, p3, p4, {
			TextureSpeed = textureSpeed
		}):Play()
	end
end

function ObjectService.EnableBeamsV2(p, p2, value, value2, value3)
	if not p.Object then
		return
	end

	local v2 = value2 or "Out"
	local v3 = v[value or "Linear"] or v.Linear

	for _, beam in pairs(p.Object:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v4 = beam
		task.spawn(function()
			local v5 = v4
			local keypoints = v5.Transparency.Keypoints
			local v6 = typeof(value3) == "NumberSequence"
			local keypoints2 = v6 and value3.Keypoints or nil
			local numberSequenceKeypoints = {}
			local numberSequenceKeypoints2 = {}

			for i, keypoint in ipairs(keypoints) do
				numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(keypoint.Time, 1)
				local value4

				if typeof(value3) == "number" then
					value4 = value3
				elseif v6 and keypoints2[i] then
					value4 = keypoints2[i].Value
				else
					value4 = keypoint.Value
				end

				numberSequenceKeypoints2[i] = NumberSequenceKeypoint.new(keypoint.Time, value4)
			end

			v5.Transparency = NumberSequence.new(numberSequenceKeypoints)
			v5.Enabled = true
			local lastTime = tick()

			while true do
				local v7 = math.clamp((tick() - lastTime) / p2, 0, 1)
				local applyEasing = ApplyEasing(v7, v3, v2)
				local numberSequenceKeypoints3 = {}

				for i = 1, #numberSequenceKeypoints do
					local value4 = numberSequenceKeypoints[i].Value
					local v9 = value4 + (numberSequenceKeypoints2[i].Value - value4) * applyEasing
					numberSequenceKeypoints3[i] = NumberSequenceKeypoint.new(numberSequenceKeypoints[i].Time, v9)
				end

				v5.Transparency = NumberSequence.new(numberSequenceKeypoints3)
				task.wait()

				if not (v7 >= 1) then
					continue
				end

				v5.Transparency = NumberSequence.new(numberSequenceKeypoints2)
				break
			end
		end)
	end
end

function ObjectService.EnableTrails(p, p2)
	if not p.Object then
		return
	end

	SetTrailEnabled(p2, true)
end

function ObjectService.DisableTrails(p, p2)
	if not p.Object then
		return
	end

	SetTrailEnabled(p2, false)
end

function ObjectService.WeldTo(p, p2, p3, p4)
	if not p.Object or p.Type == "Attachment" then
		return
	end

	local v2 = nil

	if p3 == "Normal" then
		return (Welding.NormalWeld(p2, p.Object, p4, p2.Name))
	elseif p3 == "Constraint" then
		return (Welding.WeldConstraint(p2, p.Object, p2.Name))
	elseif p3 == "Motor6D" then
		return (Welding.Motor6D(p2, p.Object, p4, p2.Name))
	end

	return v2
end

function ObjectService.CreateEffect(p, instance, p2, p3)
	local self = setmetatable({
		Type = p,
		Object = instance:Clone()
	}, ObjectService)
	self:SetCFrame(p2)
	self:ParentTo(p3)
	self:SetOriginals()
	return self
end

return ObjectService