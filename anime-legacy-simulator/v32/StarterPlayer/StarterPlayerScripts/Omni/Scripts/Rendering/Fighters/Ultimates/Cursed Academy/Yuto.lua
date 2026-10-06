local createVector = vector.create

local function HasTarget(data)
	local v = not (data.Finished or data.Fighter.Destroyed)

	if not v then
		return v
	end

	if data.Model.Parent == nil or data.HRP.Parent == nil or data.Fighter.Target ~= data.Enemy or data.Enemy == nil then
		return false
	else
		v = not data.Enemy.Destroyed

		if v then
			if data.EnemyHRP == nil then
				return false
			else
				return data.EnemyHRP.Parent ~= nil
			end
		end
	end

	return v
end

local function PrepareEffect(instance, folder)
	instance:Disable(folder)
	local result = {}
	local v = 0

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			table.insert(result, {
				Instance = descendant,
				Transparency = descendant.Transparency
			})
		elseif descendant:IsA("ParticleEmitter") then
			v = math.max(v, descendant.Lifetime.Max)
			local numberSequenceKeypoints = {}

			for _, keypoint in descendant.Size.Keypoints do
				table.insert(
					numberSequenceKeypoints,
					NumberSequenceKeypoint.new(
						keypoint.Time,
						keypoint.Value * instance.EffectScale,
						keypoint.Envelope * instance.EffectScale
					)
				)
			end

			descendant.Size = NumberSequence.new(numberSequenceKeypoints)
			descendant.Speed = NumberRange.new(
				descendant.Speed.Min * instance.EffectScale,
				descendant.Speed.Max * instance.EffectScale
			)
			descendant.Acceleration *= instance.EffectScale
		end
	end

	if not folder:IsA("BasePart") then
		return result, v + 0.1
	end

	folder.Anchored = true
	folder.CanCollide = false
	folder.CanTouch = false
	folder.CanQuery = false
	return result, v + 0.1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FadeParts(blasterParts, p: number)
	for _, item in blasterParts do
		item.Instance.Transparency = 1 - (1 - item.Transparency) * p
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopShake(object)
	if object.ActiveShake then
		object.ActiveShake:Stop()
		object.ActiveShake = nil
	end
end

local function UpdateCamera(instance)
	if not instance.CameraStarted then
		return
	end

	local v = os.clock() - instance.CameraStarted

	if instance.ImpactEffect then
		local v2 = math.clamp(1 - math.max(0, v - 0.035) / 0.15, 0, 1) * instance.CameraFalloff
		instance.ImpactEffect.TintColor = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(218, 185, 255), v2)
		instance.ImpactEffect.Brightness = 0.35 * v2
		instance.ImpactEffect.Contrast = 0.6 * v2
		instance.ImpactEffect.Saturation = -0.3 * v2

		if v2 <= 0 then
			instance:Destroy(instance.ImpactEffect)
			instance.ImpactEffect = nil
		end
	end

	if instance.BlurEffect then
		local v2 = v < 0.03 and v / 0.03 or math.clamp(1 - math.max(0, v - 0.05) / 0.18, 0, 1)
		instance.BlurEffect.Size = 8 * v2 * instance.CameraFalloff

		if v2 <= 0 and v > 0.03 then
			instance:Destroy(instance.BlurEffect)
			instance.BlurEffect = nil
		end
	end
end

local function StartCamera(object)
	if object.LowMode then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local falloff = object.Omni.Utils.Math.Falloff((currentCamera.CFrame.Position - object.HRP.Position).Magnitude, 80)

	if falloff <= 0 then
		return
	end

	object.CameraFalloff = falloff
	object.CameraStarted = os.clock()
	object.ImpactEffect = object:Track(Instance.new("ColorCorrectionEffect"))
	object.ImpactEffect.Name = "YutoImpact"
	object.ImpactEffect.Parent = currentCamera
	object.BlurEffect = object:Track(Instance.new("BlurEffect"))
	object.BlurEffect.Name = "YutoBlur"
	object.BlurEffect.Size = 0
	object.BlurEffect.Parent = currentCamera
	UpdateCamera(object)
end

local function PrepareBlaster(instance)
	local pivot = instance.Blaster:GetPivot()
	instance.BlasterGeometry = {}
	local blasterMinZ = 1e999
	local v2 = -1e999

	for _, blasterPart in instance.BlasterParts do
		local instance2 = blasterPart.Instance
		local objectSpace = pivot:ToObjectSpace(instance2.CFrame)
		local v3 = {
			Instance = instance2,
			Relative = objectSpace,
			Size = instance2.Size,
			Attachments = {}
		}
		blasterMinZ = math.min(blasterMinZ, objectSpace.Position.Z - instance2.Size.Z / 2)
		v2 = math.max(v2, objectSpace.Position.Z + instance2.Size.Z / 2)

		for _, attachment in instance2:GetChildren() do
			if attachment:IsA("Attachment") then
				table.insert(v3.Attachments, {
					Instance = attachment,
					Position = attachment.Position
				})
			end
		end

		table.insert(instance.BlasterGeometry, v3)
	end

	instance.BlasterMinZ = blasterMinZ
	instance.BlasterLength = v2 - blasterMinZ
	instance.BlasterBeams = {}

	for _, beam in instance.Blaster:GetDescendants() do
		if beam:IsA("Beam") then
			table.insert(instance.BlasterBeams, {
				Instance = beam,
				Width0 = beam.Width0,
				Width1 = beam.Width1
			})
		end
	end
end

local function UpdateBlaster(data, position: Vector3, p: number)
	local v = data.EnemyHRP.Position - position
	local v2 = data.BlasterLength * data.Scale
	local unit = v.Magnitude > 0.001 and v.Unit or data.HRP.CFrame.LookVector
	local cframe = CFrame.lookAt(position, position - unit)
	local v3 = v2 / data.BlasterLength
	local v4 = math.max(p, 0.001) * data.EffectScale

	for _, v5 in data.BlasterGeometry do
		local position2 = v5.Relative.Position
		v5.Instance.Size = Vector3.new(v5.Size.X * v4, v5.Size.Y * v4, v5.Size.Z * v3)
		v5.Instance.CFrame = cframe * CFrame.new(
			position2.X * v4,
			position2.Y * v4,
			(position2.Z - data.BlasterMinZ) * v3
		) * v5.Relative.Rotation

		for _, attachment in v5.Attachments do
			local position3 = attachment.Position
			attachment.Instance.Position = Vector3.new(position3.X * v4, position3.Y * v4, position3.Z * v3)
		end
	end

	for _, blasterBeam in data.BlasterBeams do
		blasterBeam.Instance.Width0 = blasterBeam.Width0 * v4
		blasterBeam.Instance.Width1 = blasterBeam.Width1 * v4
	end
end

local function UpdatePose(data)
	local position = data.EnemyHRP.Position
	local position2 = data.HRP.Position
	local v = (position - position2) * createVector(1, 0, 1)
	local unit = v.Magnitude > 0.001 and v.Unit or createVector(0, 0, -1)
	local pointToWorldSpace = CFrame.lookAt(position2, position2 + unit):PointToWorldSpace(createVector(0, 1, 4) * data.Scale)
	data.Rika:PivotTo(CFrame.lookAt(pointToWorldSpace, (Vector3.new(position.X, pointToWorldSpace.Y, position.Z))) * CFrame.Angles(
		0,
		3.141592653589793,
		0
	))
	local position3 = (data.MouthBone.TransformedWorldCFrame * data.MouthOffset).Position
	data.Ball:PivotTo(CFrame.new(position3))

	if data.Stage >= 2 then
		local v2 = data.Stage == 2 and math.clamp((os.clock() - data.FireStarted) / 0.08, 0.001, 1) or math.clamp(
			1 - (os.clock() - data.FireEnded) / 0.15,
			0,
			1
		)
		UpdateBlaster(data, position3, v2)
		FadeParts(data.BlasterParts, data.LowMode and 0 or v2) -- equivalent call inferred; original call site unknown
	end
end

local function RetireEffects(object)
	for _, v in { "Ball", "Blaster" } do
		local v2 = object[v]

		if not v2 then
			continue
		end

		object:Disable(v2)
		object:Debris(v2, object[v .. "Lifetime"] or 3)
	end
end

local function Cleanup(instance)
	instance.Finished = true

	if instance.MotionConnection then
		instance.MotionConnection:Disconnect()
		instance.MotionConnection = nil
	end

	StopShake(instance) -- equivalent call inferred; original call site unknown

	if instance.Stage < 3 then
		instance:StopSounds()
	end

	if instance.KickShake then
		instance.KickShake:Stop()
		instance.KickShake = nil
	end

	if instance.RikaAnimation then
		instance.RikaAnimation:Stop(0)
		instance.RikaAnimation:Destroy()
		instance.RikaAnimation = nil
	end

	if instance.Animation.IsPlaying then
		instance.Animation:Stop(0)
	end

	if instance.BlasterParts then
		for _, blasterPart in instance.BlasterParts do
			blasterPart.Instance.Transparency = 1 - (1 - blasterPart.Transparency) * 0
		end
	end

	RetireEffects(instance)
end

return {
	Setup = function(instance)
		instance.Stage = 0
		instance.Scale = instance.Model:GetScale()
		instance.EffectScale = instance.Scale * 1
		instance.LowMode = instance.Omni.Data.Settings["Low Mode"] == true
		instance:OnCleanup(function()
			Cleanup(instance)
		end)
		instance.Rika = instance:Clone("Rika")
		instance.Ball = instance:Clone("Ball")
		instance.Blaster = instance:Clone("Blaster")

		if not (instance.Rika and instance.Ball and instance.Blaster) then
			return
		end

		instance.Rika:ScaleTo(instance.Rika:GetScale() * instance.Scale)
		instance.Ball.Size *= instance.EffectScale
		instance.RikaParts = PrepareEffect(instance, instance.Rika)
		local blasterParts, blasterLifetime = PrepareEffect(instance, instance.Blaster)
		instance.BlasterParts = blasterParts
		instance.BlasterLifetime = blasterLifetime
		local _, ballLifetime = PrepareEffect(instance, instance.Ball)
		instance.BallLifetime = ballLifetime

		for _, rikaPart in instance.RikaParts do
			rikaPart.Instance.Transparency = 1 - (1 - rikaPart.Transparency) * 0
		end

		for _, blasterPart in instance.BlasterParts do
			blasterPart.Instance.Transparency = 1 - (1 - blasterPart.Transparency) * 0
		end

		PrepareBlaster(instance)
		local animSaves = instance.Rika:FindFirstChild("AnimSaves")

		if animSaves then
			animSaves:Destroy()
		end

		instance.MouthBone = instance.Rika.RootPart:FindFirstChild("Bone.011", true)

		if not instance.MouthBone then
			return
		end

		instance.MouthOffset = instance.MouthBone.WorldCFrame:ToObjectSpace(instance.Rika.RootPart.CFrame * CFrame.new(createVector(
			0,
			4.3,
			1
		) * instance.Scale))
		local characterAnimation = instance.Omni.Utils.Characters.GetCharacterAnimation(
			instance.SourceInfo.Name,
			"UltimateRika"
		)

		if not characterAnimation then
			return
		end

		UpdatePose(instance)
		instance:Cache(instance.Rika)
		instance.RikaAnimation = instance.Rika.AnimationController.Animator:LoadAnimation(characterAnimation)
		instance.RikaAnimation.Looped = false
		instance.RikaAnimation.Priority = Enum.AnimationPriority.Action4
		instance.MotionConnection = instance.Omni.Services.RunService.RenderStepped:Connect(function()
			if not (HasTarget(instance) and instance.Animation.IsPlaying) then
				instance:CleanupAll()
				return
			end

			if not instance.RikaStarted then
				instance.RikaStarted = true
				instance.RikaAnimation:Play(0)
			end

			if instance.RikaAnimation.Length > 0 and math.abs(instance.RikaAnimation.TimePosition - instance.Animation.TimePosition) > 0.05 then
				instance.RikaAnimation.TimePosition = instance.Animation.TimePosition
			end

			local v4 = math.min(
				math.clamp(instance.Animation.TimePosition / 0.2, 0, 1),
				(math.clamp((instance.Animation.Length - instance.Animation.TimePosition) / 0.2, 0, 1))
			)

			for _, rikaPart in instance.RikaParts do
				rikaPart.Instance.Transparency = 1 - (1 - rikaPart.Transparency) * v4
			end

			UpdatePose(instance)
			UpdateCamera(instance)
		end)
	end,
	OnMarker = {
		BlasterOpenStart = function(object)
			if not HasTarget(object) or not object.MotionConnection or object.Stage ~= 0 then
				return
			end

			object.Stage = 1
			object:Sound("Charge")
			UpdatePose(object)
			object:Cache(object.Ball)
			object:Enable(object.Ball)
			object.ActiveShake = object:Shake({
				Position = object.HRP.Position,
				Amplitude = 0.12,
				Frequency = 0.08,
				FadeInTime = 0.2,
				SustainTime = 0.683333,
				FadeOutTime = 0.1
			})
		end,
		BlasterOpenEnd = function(object)
			if not HasTarget(object) or object.Stage ~= 1 then
				return
			end

			object.Stage = 2
			object.FireStarted = os.clock()
			object:Sound("Beam")
			StopShake(object) -- equivalent call inferred; original call site unknown
			UpdatePose(object)
			object:Cache(object.Blaster)
			object:Enable(object.Blaster)
			object:Emit(object.Ball)
			StartCamera(object)
			object.KickShake = object:Shake({
				Position = object.HRP.Position,
				Amplitude = 1.2,
				Frequency = 0.05,
				FadeOutTime = 0.18
			})
			object.ActiveShake = object:Shake({
				Position = object.HRP.Position,
				Amplitude = 0.3,
				Frequency = 0.07,
				FadeInTime = 0.08,
				SustainTime = 1.353334,
				FadeOutTime = 0.15
			})
		end,
		BlasterEnd = function(object)
			if not HasTarget(object) or object.Stage ~= 2 then
				return
			end

			object.Stage = 3
			object.FireEnded = os.clock()
			StopShake(object) -- equivalent call inferred; original call site unknown
			object:Disable(object.Ball)
			object:Disable(object.Blaster)
		end
	}
}