local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")

local function CanShowEffects()
	return not (module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"])
end

local function FadeParts(items, p: number)
	for _, item in items do
		item.Instance.Transparency = 1 - (1 - item.Transparency) * p
	end
end

local function PrepareEffect(folder)
	module.Utils.Particles:DisableAll(folder)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)
	local result = {}

	for _, part in descendants do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		table.insert(result, {
			Instance = part,
			Transparency = part.Transparency
		})
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopShake(state)
	if not state.ActiveShake then
		return
	end

	state.ActiveShake:Stop()
	state.ActiveShake = nil
end

local function ClearEffects(state)
	StopShake(state) -- equivalent call inferred; original call site unknown

	if state.KickShake then
		state.KickShake:Stop()
		state.KickShake = nil
	end

	if state.RikaAnimation then
		state.RikaAnimation:Stop(0)
		state.RikaAnimation:Destroy()
		state.RikaAnimation = nil
	end

	for _, v in {
		"Rika",
		"Ball",
		"Blaster",
		"ImpactEffect",
		"BlurEffect"
	} do
		local v2 = state[v]

		if not v2 then
			continue
		end

		v2:Destroy()
		state[v] = nil
	end
end

local function PrepareBlaster(clonesByChildName)
	local pivot = clonesByChildName.Blaster:GetPivot()
	clonesByChildName.BlasterGeometry = {}
	clonesByChildName.BlasterBeams = {}
	local blasterMinZ = 1e999
	local v2 = -1e999

	for _, blasterPart in clonesByChildName.BlasterParts do
		local instance = blasterPart.Instance
		local objectSpace = pivot:ToObjectSpace(instance.CFrame)
		local v3 = {
			Instance = instance,
			Relative = objectSpace,
			Size = instance.Size,
			Attachments = {}
		}
		blasterMinZ = math.min(blasterMinZ, objectSpace.Position.Z - instance.Size.Z / 2)
		v2 = math.max(v2, objectSpace.Position.Z + instance.Size.Z / 2)

		for _, attachment in instance:GetChildren() do
			if attachment:IsA("Attachment") then
				table.insert(v3.Attachments, {
					Instance = attachment,
					Position = attachment.Position
				})
			end
		end

		table.insert(clonesByChildName.BlasterGeometry, v3)
	end

	clonesByChildName.BlasterMinZ = blasterMinZ
	clonesByChildName.BlasterLength = v2 - blasterMinZ

	for _, beam in clonesByChildName.Blaster:GetDescendants() do
		if beam:IsA("Beam") then
			table.insert(clonesByChildName.BlasterBeams, {
				Instance = beam,
				Width0 = beam.Width0,
				Width1 = beam.Width1
			})
		end
	end
end

local function UpdateBlaster(data, position: Vector3, p: number)
	local cframe = CFrame.lookAt(position, position - data.Direction)
	local v = math.max(p, 0.001)

	for _, v2 in data.BlasterGeometry do
		local position2 = v2.Relative.Position
		v2.Instance.Size = Vector3.new(v2.Size.X * v, v2.Size.Y * v, v2.Size.Z)
		v2.Instance.CFrame = cframe * CFrame.new(position2.X * v, position2.Y * v, position2.Z - data.BlasterMinZ) * v2.Relative.Rotation

		for _, attachment in v2.Attachments do
			local position3 = attachment.Position
			attachment.Instance.Position = Vector3.new(position3.X * v, position3.Y * v, position3.Z)
		end
	end

	for _, blasterBeam in data.BlasterBeams do
		blasterBeam.Instance.Width0 = blasterBeam.Width0 * v
		blasterBeam.Instance.Width1 = blasterBeam.Width1 * v
	end
end

local function UpdateCamera(state, p: number)
	if not state.CameraStarted then
		return
	end

	local v = p - state.CameraStarted

	if state.ImpactEffect then
		local v2 = math.clamp(1 - math.max(0, v - 0.035) / 0.15, 0, 1) * state.CameraFalloff
		state.ImpactEffect.TintColor = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(218, 185, 255), v2)
		state.ImpactEffect.Brightness = 0.35 * v2
		state.ImpactEffect.Contrast = 0.6 * v2
		state.ImpactEffect.Saturation = -0.3 * v2

		if v2 <= 0 then
			state.ImpactEffect:Destroy()
			state.ImpactEffect = nil
		end
	end

	if state.BlurEffect then
		local v2

		if v < 0.03 then
			v2 = v / 0.03
		else
			v2 = math.clamp(1 - math.max(0, v - 0.05) / 0.18, 0, 1)
		end

		state.BlurEffect.Size = 8 * v2 * state.CameraFalloff

		if v2 <= 0 and v > 0.03 then
			state.BlurEffect:Destroy()
			state.BlurEffect = nil
		end
	end
end

local function StartCamera(state, cameraStarted: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local falloff = module.Utils.Math.Falloff((currentCamera.CFrame.Position - state.HRP.Position).Magnitude, 80)

	if falloff <= 0 then
		return
	end

	state.CameraFalloff = falloff
	state.CameraStarted = cameraStarted
	state.ImpactEffect = Instance.new("ColorCorrectionEffect")
	state.ImpactEffect.Name = "YutoImpact"
	state.ImpactEffect.Parent = currentCamera
	state.BlurEffect = Instance.new("BlurEffect")
	state.BlurEffect.Name = "YutoBlur"
	state.BlurEffect.Size = 0
	state.BlurEffect.Parent = currentCamera
	UpdateCamera(state, cameraStarted)
end

local function StartStage(state, stage: number, elapsed: number)
	StopShake(state) -- equivalent call inferred; original call site unknown
	state.Stage = stage

	if stage == 1 then
		state.Ball.Parent = state.EffectParent
		module.Utils.Particles:EnableAll(state.Ball)
		state.ActiveShake = module.Utils.CameraShake:Play({
			Position = state.HRP.Position,
			Amplitude = 0.12,
			Frequency = 0.08,
			FadeInTime = 0.2,
			SustainTime = math.max(0, 1.6833333333333333 - elapsed - 0.2),
			FadeOutTime = 0.1
		})
	elseif stage == 2 then
		state.Ball.Parent = state.EffectParent
		state.Blaster.Parent = state.EffectParent
		module.Utils.Particles:EnableAll(state.Ball)
		module.Utils.Particles:EnableAll(state.Blaster)

		if elapsed - 1.6833333333333333 < 0.2 then
			module.Utils.Particles:Emit(state.Ball)
			StartCamera(state, elapsed)
			state.KickShake = module.Utils.CameraShake:Play({
				Position = state.HRP.Position,
				Amplitude = 1.2,
				Frequency = 0.05,
				FadeOutTime = 0.18
			})
		end

		state.ActiveShake = module.Utils.CameraShake:Play({
			Position = state.HRP.Position,
			Amplitude = 0.3,
			Frequency = 0.07,
			FadeInTime = 0.08,
			SustainTime = math.max(0, 3.1166666666666667 - elapsed - 0.08),
			FadeOutTime = 0.15
		})
	elseif stage == 3 then
		module.Utils.Particles:DisableAll(state.Ball)
		module.Utils.Particles:DisableAll(state.Blaster)
	end
end

local YutoKatana = {}

function YutoKatana:Setup()
	self.Stage = 0
	self.EffectParent = workspace:FindFirstChild("Cache") or workspace
	table.insert(self.Resources, function()
		ClearEffects(self)
	end)

	if module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"] then
		return
	end

	local yutoKatana = module.Assets.Effects.Weapons:FindFirstChild("Yuto Katana")
	local skill = yutoKatana and yutoKatana:FindFirstChild("Skill")
	local weaponAnimation = module.Utils.Weapons.GetWeaponAnimation("Yuto Katana", "UltimateRika")

	if not (skill and weaponAnimation) then
		return
	end

	for _, childName in { "Rika", "Ball", "Blaster" } do
		local child = skill:FindFirstChild(childName)

		if child then
			self[childName] = child:Clone()
		else
			ClearEffects(self)
			return
		end
	end

	self.RikaParts = PrepareEffect(self.Rika)
	self.BlasterParts = PrepareEffect(self.Blaster)
	PrepareEffect(self.Ball)

	for _, rikaPart in self.RikaParts do
		rikaPart.Instance.Transparency = 1 - (1 - rikaPart.Transparency) * 0
	end

	for _, blasterPart in self.BlasterParts do
		blasterPart.Instance.Transparency = 1 - (1 - blasterPart.Transparency) * 0
	end

	PrepareBlaster(self)
	local animSaves = self.Rika:FindFirstChild("AnimSaves")

	if animSaves then
		animSaves:Destroy()
	end

	local rootPart = self.Rika:FindFirstChild("RootPart")
	local animator = self.Rika:FindFirstChildWhichIsA("Animator", true)
	self.MouthBone = rootPart and rootPart:FindFirstChild("Bone.011", true)

	if not (self.MouthBone and animator) then
		ClearEffects(self)
		return
	end

	self.MouthOffset = self.MouthBone.WorldCFrame:ToObjectSpace(rootPart.CFrame * CFrame.new(createVector(0, 4.3, 1)))
	self.Rika.Parent = self.EffectParent
	self.RikaAnimation = animator:LoadAnimation(weaponAnimation)
	self.RikaAnimation.Looped = false
	self.RikaAnimation.Priority = Enum.AnimationPriority.Action4
	self.RikaAnimation:Play(0)
end

function YutoKatana.Update(data)
	if module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"] then
		ClearEffects(data)
		return
	end

	if not (data.Rika and data.Rika.Parent) then
		return
	end

	local elapsed = data.Elapsed

	for i = 1, data.Index - 1 do
		elapsed += data.Skill.Phases[i].Duration
	end

	local rikaAnimation = data.RikaAnimation

	if rikaAnimation.Length > 0 and math.abs(rikaAnimation.TimePosition - elapsed) > 0.05 then
		rikaAnimation.TimePosition = math.clamp(elapsed, 0, rikaAnimation.Length)
	end

	local v = math.min(math.clamp(elapsed / 0.2, 0, 1), (math.clamp((3.933333333333333 - elapsed) / 0.2, 0, 1)))

	for _, rikaPart in data.RikaParts do
		rikaPart.Instance.Transparency = 1 - (1 - rikaPart.Transparency) * v
	end

	local cframe = CFrame.lookAt(data.Origin, data.Origin + data.Direction)
	data.Rika:PivotTo(cframe * CFrame.new(createVector(0, 1, 4)) * CFrame.Angles(0, 3.141592653589793, 0))
	local position = (data.MouthBone.TransformedWorldCFrame * data.MouthOffset).Position
	data.Ball:PivotTo(CFrame.new(position))
	local v2

	if elapsed >= 3.1166666666666667 then
		v2 = 3
	elseif elapsed >= 1.6833333333333333 then
		v2 = 2
	elseif elapsed >= 0.8 then
		v2 = 1
	else
		v2 = 0
	end

	local v3

	if v2 == 2 then
		v3 = math.clamp((elapsed - 1.6833333333333333) / 0.08, 0.001, 1)
	else
		v3 = v2 ~= 3 and 0 or math.clamp(1 - (elapsed - 3.1166666666666667) / 0.15, 0, 1)
	end

	UpdateBlaster(data, position, v3)

	for _, blasterPart in data.BlasterParts do
		blasterPart.Instance.Transparency = 1 - (1 - blasterPart.Transparency) * v3
	end

	if v2 ~= data.Stage then
		StartStage(data, v2, elapsed)
	end

	UpdateCamera(data, elapsed)
end

function YutoKatana.Clear(p)
	ClearEffects(p)
end

return YutoKatana