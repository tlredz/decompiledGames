local createVector = vector.create
local VfxUtility = {}
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local ParticleBudget = require(ReplicatedStorage.CAM.Client.Modules.Effects.ParticleBudget)
VfxUtility.Owned = ParticleBudget.Owned
local getvaluesfolder = Utility.getvaluesfolder(game.Players.LocalPlayer, true)
local new = ColorSequence.new
local typeof2 = typeof
local colorWhitelist2 = { "DustRaycast", "dustraycast" }
local colorBlacklist2 = {
	"Ignore",
	"ignore",
	"Debree22t",
	"GroundShatter"
}

function VfxUtility.cloneAsset(instance, parent, childName: string, cframe: CFrame?, p: number?)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	local clone = child:Clone()

	if cframe and (clone:IsA("Model") or clone:IsA("BasePart")) then
		clone:PivotTo(cframe)
	end

	clone.Parent = parent

	if p then
		DebrisModule:AddItem(clone, p)
	end

	return clone
end

local RigEffectScale = require(ReplicatedStorage.CAM.Global.RigEffectScale)

function VfxUtility.GetRigEffectScale(p)
	return RigEffectScale.FromRoot(p)
end

function VfxUtility.GetDustColorSettings(color)
	if color == nil then
		return nil
	end

	if typeof2(color) == "Color3" then
		return {
			Color = color,
			ColorWhitelist = colorWhitelist2,
			ColorBlacklist = colorBlacklist2
		}
	end

	return {
		Color = color.Color,
		ColorWhitelist = colorWhitelist2,
		ColorBlacklist = colorBlacklist2
	}
end

local function GetColor(clone, instance)
	local v3 = nil

	if instance ~= nil then
		if typeof2(instance) == "Color3" then
			return new(instance)
		end

		if instance.Parent ~= nil then
			clone = clone:Clone()
			clone.Parent = instance.Parent
			task.delay(instance.Lifetime, clone.Destroy, clone)
		end

		local color = instance.Color or instance.color

		if color then
			local v4 = false
			local colorWhitelist = instance.ColorWhitelist

			if colorWhitelist == nil then
				v4 = true
			elseif typeof2(colorWhitelist) == "table" then
				for _, ancestorName in ipairs(colorWhitelist) do
					if not (clone.Name == ancestorName or clone:FindFirstAncestor(ancestorName) ~= nil) then
						continue
					end

					v4 = true
					break
				end
			else
				v4 = clone.Name == colorWhitelist or clone:FindFirstAncestor(colorWhitelist) ~= nil
			end

			if v4 then
				local v5 = false
				local colorBlacklist = instance.ColorBlacklist

				if colorBlacklist ~= nil then
					if typeof2(colorBlacklist) == "table" then
						for _, ancestorName in ipairs(colorBlacklist) do
							if not (clone.Name == ancestorName or clone:FindFirstAncestor(ancestorName) ~= nil) then
								continue
							end

							v5 = true
							break
						end
					else
						v5 = clone.Name == colorBlacklist or clone:FindFirstAncestor(colorBlacklist) ~= nil
					end
				end

				if not v5 then
					v3 = color
				end
			end
		end

		if v3 ~= nil then
			if instance.ColorChosen == nil then
				instance.ColorChosen = new(v3)
			end

			return instance.ColorChosen
		end
	end
end

function VfxUtility.DisableAllTable(descendants)
	if descendants == nil then
		return
	end

	if descendants.ClassName ~= nil then
		descendants = descendants:GetDescendants() or descendants
	end

	for _, instance in ipairs(descendants) do
		if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			instance.Enabled = false
		elseif instance:IsA("Sound") then
			TweenService:Create(instance, TweenInfo.new(0.3), {
				Volume = 0
			}):Play()
		end
	end
end

function VfxUtility.DisableAll(descendants)
	if descendants == nil then
		return
	end

	if descendants.ClassName ~= nil then
		descendants = descendants:GetDescendants() or descendants
	end

	for _, instance in ipairs(descendants) do
		if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			instance.Enabled = false
		elseif instance:IsA("Sound") then
			TweenService:Create(instance, TweenInfo.new(0.3), {
				Volume = 0
			}):Play()
		end
	end
end

function VfxUtility.PlaySound(instance, childName: string, parent, flag: boolean?)
	if instance == nil or childName == nil or parent == nil then
		return
	end

	local child = instance:FindFirstChild(childName)

	if not child then
		return nil
	end

	local clone = child:Clone()
	clone:AddTag("__forge_excludeFromEmit")
	clone.Parent = parent
	clone:Play()

	if flag then
		DebrisModule:AddItem(clone, clone.TimeLength)
	end

	return clone
end

function VfxUtility:PlayAtComboSpeed(playbackSpeed: number)
	self.PlaybackSpeed = playbackSpeed
	local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
	pitchShiftSoundEffect.Octave = 1 / playbackSpeed
	pitchShiftSoundEffect.Parent = self
	self:Play()
	return pitchShiftSoundEffect
end

function VfxUtility.ToggleWithColor(folder, flag: boolean?, color: Color3?, flag2: boolean?, p)
	if flag and ParticleBudget.Muted(p, folder) then
		flag = false
	end

	for _, sound in ipairs(folder:GetDescendants()) do
		if sound.ClassName == "ParticleEmitter" and sound.Name == "DustRaycast" and color then
			sound.Color = ColorSequence.new(color)
		end

		if sound.ClassName == "ParticleEmitter" or sound.ClassName == "Beam" or sound.ClassName == "PointLight" or sound.ClassName == "Trail" then
			if flag then
				ParticleBudget.Rate(sound, p)
			end

			sound.Enabled = flag or false
		end

		if not flag2 or not sound:IsA("Sound") or flag or not sound.IsPlaying then
			continue
		end

		sound:Stop()
	end
end

function VfxUtility.EmitAllWithColor(folder, color: Color3?, p)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if color and emitter.Name == "DustRaycast" then
			emitter.Color = ColorSequence.new(color)
		end

		local emitDelay = emitter:GetAttribute("EmitDelay")

		if emitDelay == nil then
			ParticleBudget.Emit(emitter, emitter:GetAttribute("EmitCount") or 30, p)
		else
			local v3 = emitter
			task.delay(emitDelay, function()
				ParticleBudget.Emit(v3, v3:GetAttribute("EmitCount") or 30, p)
			end)
		end
	end
end

function VfxUtility.EnableAll(folder, flag: boolean, duration, flag2: boolean?)
	if folder == nil then
		return
	end

	local owner

	if type(duration) == "table" then
		owner = duration.Owner
	end

	if flag ~= false and ParticleBudget.Muted(owner, folder) then
		flag = false
	end

	if flag ~= false and owner ~= nil then
		ParticleBudget.Stamp(folder, owner)
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
			if flag ~= false then
				ParticleBudget.Rate(descendant, owner)
			end

			descendant.Enabled = flag or false

			if duration then
				local typeName = typeof(duration)

				if typeName == "number" then
					local v3 = descendant
					task.delay(duration, function()
						if folder == nil then
							return
						end

						v3.Enabled = false
					end)
				elseif typeName == "Color" or typeName == "table" and (duration.Color or duration.color) then
					local color = GetColor(descendant, duration)

					if color ~= nil then
						descendant.Color = color
					end
				elseif typeName == "table" and duration.Timer then
					local v3 = descendant
					task.delay(duration.Timer, function()
						if folder == nil then
							return
						end

						v3.Enabled = false
					end)
				end
			end
		end

		if not flag2 or not descendant:IsA("Sound") or flag or not descendant.IsPlaying then
			continue
		end

		descendant:Stop()
	end
end

function VfxUtility.TweenBeams(folder, data)
	if folder == nil then
		return
	end

	for _, beam in ipairs(folder:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		if data.Off then
			beam.Enabled = true
			TweenService:Create(beam, TweenInfo.new(data.Time), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		else
			beam.Enabled = true
			local width0 = beam.Width0
			local width1 = beam.Width1
			beam.Width0 = 0
			beam.Width1 = 0
			TweenService:Create(beam, TweenInfo.new(data.Time), {
				Width0 = width0,
				Width1 = width1
			}):Play()

			if data.Del then
				local v3 = beam
				task.delay(data.Del, function()
					if not (folder ~= nil and v3 ~= nil) then
						return
					end

					TweenService:Create(v3, TweenInfo.new(data.DelayTimer or data.Time), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end
	end
end

function VfxUtility.TweenLight(folder, data)
	if folder == nil then
		return
	end

	for _, light in ipairs(folder:GetDescendants()) do
		if not (light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight")) then
			continue
		end

		if data.Off then
			TweenService:Create(light, TweenInfo.new(data.Time), {
				Brightness = 0,
				Range = 0
			}):Play()
		else
			light.Enabled = true
			local brightness = light.Brightness
			local range = light.Range
			light.Brightness = 0
			light.Range = 0
			TweenService:Create(light, TweenInfo.new(data.Time), {
				Brightness = brightness,
				Range = range
			}):Play()

			if data.Del then
				local v3 = light
				task.delay(data.Del, function()
					if not (folder ~= nil and v3 ~= nil) then
						return
					end

					TweenService:Create(v3, TweenInfo.new(data.DelayTimer or data.Time), {
						Brightness = 0,
						Range = 0
					}):Play()
				end)
			end
		end
	end
end

function VfxUtility.WeldConstraint(p, part)
	if not (p ~= nil and part ~= nil) then
		return
	end

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p
	weldConstraint.Part1 = part
	weldConstraint.Parent = p
	return weldConstraint
end

function VfxUtility.TweenBeamTransparency(folder, p: number, duration: number)
	if folder == nil then
		return
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.ClassName ~= "Beam" then
			continue
		end

		local numberSequenceKeypoints = {}
		local numberSequenceKeypoints2 = {}

		for _, keypoint in ipairs(descendant.Transparency.Keypoints) do
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value, keypoint.Envelope)
			)
		end

		local numberSequence = NumberSequence.new(numberSequenceKeypoints)

		for _, keypoint in ipairs(numberSequence.Keypoints) do
			table.insert(numberSequenceKeypoints2, NumberSequenceKeypoint.new(keypoint.Time, p))
		end

		local time = numberSequence.Keypoints[#numberSequence.Keypoints].Time
		local v3 = 0
		local heartbeatConnection = nil
		local v4 = tick()
		local v8 = descendant
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if folder == nil then
				heartbeatConnection:Disconnect()
				return
			end

			v3 = tick() - v4
			local v9 = math.min(time, v3) / time / duration
			local numberSequenceKeypoints3 = {}

			for i, keypoint in ipairs(numberSequence.Keypoints) do
				local v10 = keypoint.Value + (numberSequenceKeypoints2[i].Value - keypoint.Value) * v9
				table.insert(numberSequenceKeypoints3, NumberSequenceKeypoint.new(keypoint.Time, v10))
			end

			v8.Transparency = NumberSequence.new(numberSequenceKeypoints3)
		end)
		task.delay(duration, function()
			heartbeatConnection:Disconnect()
		end)
	end
end

local function EmitEffect(emitter, p)
	if emitter == nil or emitter.Parent == nil then
		return
	end

	local owner

	if type(p) == "table" then
		owner = p.Owner
	else
		owner = nil
	end

	local emitDuration = emitter:GetAttribute("EmitDuration")
	local emitDelay = emitter:GetAttribute("EmitDelay")

	if emitDuration and emitDuration ~= 0 then
		if ParticleBudget.Muted(owner, emitter) then
			return
		end

		ParticleBudget.Rate(emitter, owner)

		if emitDelay and emitDelay ~= 0 then
			task.delay(emitDelay, function()
				if emitter == nil or emitter.Parent == nil then
					return
				end

				emitter.Enabled = true
				task.wait(emitDuration)

				if emitter == nil or emitter.Parent == nil then
					return
				end

				emitter.Enabled = false
			end)
			return
		end

		emitter.Enabled = true
		task.delay(emitDuration, function()
			if emitter == nil or emitter.Parent == nil then
				return
			end

			emitter.Enabled = false
		end)
	elseif emitter:IsA("ParticleEmitter") then
		local color = GetColor(emitter, p)

		if color ~= nil then
			emitter.Color = color
		end

		if emitter:GetAttribute("EmitDelay") and emitter:GetAttribute("EmitDelay") ~= 0 then
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				if not (emitter.Parent ~= nil and emitter ~= nil) then
					return
				end

				ParticleBudget.Emit(emitter, emitter:GetAttribute("EmitCount"), owner)
			end)
		else
			ParticleBudget.Emit(emitter, emitter:GetAttribute("EmitCount"), owner)
		end
	end
end

function VfxUtility.Cam(p, duration: number, p2: number)
	TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Value = p2
	}):Play()
end

function VfxUtility.EmitAll(effect, p)
	if effect == nil then
		return
	end

	if type(p) == "table" and p.Owner ~= nil and typeof(effect) == "Instance" then
		ParticleBudget.Stamp(effect, p.Owner)
	end

	if typeof(effect) == "table" then
		for _, effect2 in ipairs(effect) do
			if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
				continue
			end

			EmitEffect(effect2, p)
		end
	else
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
			EmitEffect(effect, p)
			return
		end

		for _, effect2 in ipairs(effect:GetDescendants()) do
			if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
				continue
			end

			EmitEffect(effect2, p)
		end
	end
end

function VfxUtility.CustomEmit(p, p2, p3)
	if p == nil then
		return
	end

	ParticleBudget.Emit(p, p2, p3)
end

function VfxUtility.ShootRocks(p, p2, parent, value)
	for _ = 1, value or 3 do
		local cFrame = p2 * CFrame.new(math.random(-4, 4), math.random(-4, 4), math.random(-4, 4))
		local v4 = p2 * CFrame.new(math.random(-5, 5) * 5, 0, math.random(-5, 5) * 5)
		local rotation = v4.Rotation
		local raycastResult = workspace:Raycast(
			v4 * CFrame.new(0, 4, 0).Position,
			createVector(0, -30, 0),
			VfxUtility.RayParams.Map
		)

		if raycastResult ~= nil and raycastResult.Instance ~= nil then
			v4 = CFrame.new(raycastResult.Position) * rotation
		end

		local v5 = math.random(5, 10) / 13
		local calcvel = Utility.calcvel(v4.Position, cFrame.Position, Vector3.new(0, -workspace.Gravity * 1.2, 0), v5)
		local part = Instance.new("Part")
		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Material = p.Instance.Material
		part.MaterialVariant = p.Instance.MaterialVariant
		part.Color = p.Instance.Color
		part.CanQuery = false
		part.Massless = true
		part.Size = Vector3.new(math.random(1, 4) / 3, math.random(1, 4) / 3, math.random(1, 4) / 3)
		part.CFrame = cFrame
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		local angularVelocity = Instance.new("AngularVelocity")
		angularVelocity.Attachment0 = attachment
		angularVelocity.MaxTorque = 10000
		angularVelocity.AngularVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
		angularVelocity.Parent = part
		part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
		part.Velocity = calcvel
		part.Parent = parent
		task.delay(0.3, function()
			part.CanCollide = true
			angularVelocity:Destroy()
		end)
	end
end

local function ColorChange(p, folder)
	if not folder then
		return
	end

	if p then
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and (not emitter.Name:match("grass") or emitter.Parent.Name ~= "keep")) then
				continue
			end

			emitter.Color = ColorSequence.new(p.Color, p.Color)
		end
	else
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and (not emitter.Name:match("grass") or emitter.Parent.Name ~= "keep")) then
				continue
			end

			emitter:Destroy()
		end
	end
end

function VfxUtility.CheckForGround(p, p2, p3)
	local raycastResult = workspace:Raycast(p, p2, p3)
	local v3

	if raycastResult then
		return raycastResult.Instance
	end

	return v3
end

function VfxUtility.ChangeDustColor(p, list)
	if not list then
		return
	end

	if typeof(list) ~= "table" then
		ColorChange(p, list)
		return
	end

	for _, v3 in ipairs(list) do
		ColorChange(p, v3)
	end
end

local numberValue = nil

function VfxUtility.TweenFOV(duration: number, p: number, p2, priority: number?)
	if not numberValue or numberValue.Parent ~= getvaluesfolder then
		numberValue = Instance.new("NumberValue")
		numberValue.Name = "FOV"
		numberValue.Value = 70
		numberValue.Parent = getvaluesfolder
	end

	numberValue:SetAttribute("Priority", priority)

	if VfxUtility._fovTween then
		VfxUtility._fovTween:Cancel()
	end

	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(
			duration,
			p2 and p2.EasingStyle or Enum.EasingStyle.Sine,
			p2 and p2.EasingDirection or Enum.EasingDirection.InOut
		),
		{
			Value = p
		}
	)
	VfxUtility._fovTween = tween
	tween:Play()

	if p == 70 then
		tween.Completed:Once(function(p3)
			if VfxUtility._fovTween == tween and p3 == Enum.PlaybackState.Completed then
				VfxUtility.CancelFOV()
			end
		end)
	end

	return numberValue
end

function VfxUtility.CancelFOV()
	if VfxUtility._fovTween then
		VfxUtility._fovTween:Cancel()
		VfxUtility._fovTween = nil
	end

	if numberValue then
		numberValue:Destroy()
		numberValue = nil
	end
end

function VfxUtility.ScaleParticleDescendants(object, p: number)
	for _, v3 in object:QueryDescendants("ParticleEmitter") do
		local numberSequenceKeypoints = {}

		for k, keypoint in v3.Size.Keypoints do
			numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value * p,
				keypoint.Envelope * p
			)
		end

		v3.Size = NumberSequence.new(numberSequenceKeypoints)
		v3.Acceleration *= p
		v3.Speed = NumberRange.new(v3.Speed.Min * p, v3.Speed.Max * p)
	end
end

VfxUtility.RayParams = {}
VfxUtility.RayParams.Map = RaycastParams.new()
VfxUtility.RayParams.Map.FilterType = Enum.RaycastFilterType.Include
VfxUtility.RayParams.Map.FilterDescendantsInstances = { workspace.Map }
return VfxUtility