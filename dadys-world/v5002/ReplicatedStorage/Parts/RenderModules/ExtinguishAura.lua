local ExtinguishAura = {}
ExtinguishAura.__index = ExtinguishAura
local v = {
	fxTemplate = nil,
	attachToPart = "HumanoidRootPart",
	weldOffset = CFrame.new(0, 0, 0),
	worldLocked = false,
	ignitedParticlePath = nil,
	startIgnited = false,
	startActive = false,
	blinkInterval = 0.5,
	arrowsTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	arrowsActiveScale = 0.5,
	ringBlinkTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	ringActiveColor = Color3.fromRGB(120, 120, 120),
	ringBlinkColor = Color3.fromRGB(0, 0, 0),
	ringActiveTransparency = 0.7,
	ringIdleSnapTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	ringIdleFadeTweenInfo = TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	ringIdleColorA = Color3.fromRGB(153, 110, 67),
	ringIdleColorB = Color3.fromRGB(182, 145, 206),
	ringIdleTransparencyA = 0.8,
	ringIdleTransparencyB = 0.95,
	ringDormantColor = Color3.fromRGB(0, 0, 0),
	ringDormantTransparency = 0.8,
	ringDormantTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	lightTweenInfo = TweenInfo.new(0.25),
	lightIdleRange = 15,
	lightActiveRange = 10,
	lightEnabled = false,
	activeSound = "Sounds.Twisted.Waxwell.Extinguishing"
}
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenHelpers = require(ReplicatedStorage.SharedUtils.tweenHelpers)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

local function resolveInstance(child, ignitedParticlePath)
	if typeof(ignitedParticlePath) == "Instance" then
		return ignitedParticlePath
	end

	if type(ignitedParticlePath) ~= "string" or ignitedParticlePath == "" or child == nil then
		return nil
	end

	for childName in string.gmatch(ignitedParticlePath, "[^/%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			return nil
		end
	end

	return child
end

local function collectEmitters(folder, emitters)
	if not folder then
		return
	end

	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			table.insert(emitters, emitter)
		end
	end
end

local function setEmittersEnabled(items, enabled)
	for _, item in items do
		item.Enabled = enabled
	end
end

local function mountPackage(folder, primaryPart, part, weldOffset, isWorldLocked)
	local cframe

	if isWorldLocked then
		cframe = CFrame.new((part.CFrame * weldOffset).Position)
	else
		cframe = part.CFrame * weldOffset
	end

	folder:PivotTo(cframe)

	for _, part2 in folder:GetDescendants() do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.Anchored = false
		part2.CanCollide = false
		part2.Massless = not isWorldLocked or part2 ~= primaryPart

		if part2 == primaryPart then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = primaryPart
		weldConstraint.Part1 = part2
		weldConstraint.Parent = part2
	end

	primaryPart.Anchored = false
	local auraFollowAnchor = part:FindFirstChild("auraFollowAnchor")

	if auraFollowAnchor then
		auraFollowAnchor:Destroy()
	end

	if isWorldLocked then
		local attachment = Instance.new("Attachment")
		attachment.Name = "auraRingAnchor"
		attachment.CFrame = cframe:ToObjectSpace(primaryPart.CFrame):Inverse()
		attachment.Parent = primaryPart
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "auraFollowAnchor"
		attachment2.CFrame = CFrame.new(weldOffset.Position)
		attachment2.Parent = part
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Name = "auraFollow"
		alignPosition.Attachment0 = attachment
		alignPosition.Attachment1 = attachment2
		alignPosition.RigidityEnabled = true
		alignPosition.Parent = primaryPart
		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Name = "auraLevel"
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.Attachment0 = attachment
		alignOrientation.CFrame = CFrame.identity
		alignOrientation.RigidityEnabled = true
		alignOrientation.Parent = primaryPart
		return {
			setOffset = function(p)
				attachment2.CFrame = CFrame.new(p.Position)
			end,
			destroy = function()
				if attachment2.Parent then
					attachment2:Destroy()
				end
			end
		}
	else
		local weld = Instance.new("Weld")
		weld.Name = "auraAnchorWeld"
		weld.Part0 = part
		weld.Part1 = primaryPart
		weld.C0 = part.CFrame:ToObjectSpace(primaryPart.CFrame)
		weld.Parent = primaryPart
		local objectSpace = cframe:ToObjectSpace(primaryPart.CFrame)
		return {
			setOffset = function(p)
				weld.C0 = p * objectSpace
			end,
			destroy = function() end
		}
	end
end

function ExtinguishAura.new(instance, options)
	assert(typeof(instance) == "Instance", "extinguishAura: monsterModel is required")
	local settings = {}

	for k, v3 in v do
		settings[k] = v3
	end

	for k, v3 in options or {} do
		settings[k] = v3
	end

	if not settings.fxTemplate then
		local parts = game.ReplicatedStorage:FindFirstChild("Parts")
		local renderParts = parts and parts:FindFirstChild("RenderParts")
		local waxwell = renderParts and renderParts:FindFirstChild("Waxwell")
		local extinguishAuraFx = waxwell and waxwell:FindFirstChild("ExtinguishAuraFx")

		if extinguishAuraFx then
			settings.fxTemplate = extinguishAuraFx
		end
	end

	assert(settings.fxTemplate, "extinguishAura: config.fxTemplate is required")
	local part = instance:FindFirstChild(settings.attachToPart)
	assert(
		part and part:IsA("BasePart"),
		"extinguishAura: could not find anchor part " .. tostring(settings.attachToPart)
	)
	local object = setmetatable({}, ExtinguishAura)
	object.monsterModel = instance
	object.settings = settings
	object.isActive = settings.startActive and true or false
	object.isIgnited = settings.startIgnited and true or false
	object.isDestroyed = false
	object.ringThread = nil
	object.arrowsThread = nil
	local clone = settings.fxTemplate:Clone()
	object.fxModel = clone
	local primaryPart = clone.PrimaryPart or clone:FindFirstChild("ringPart")
	assert(
		primaryPart and primaryPart:IsA("BasePart"),
		"extinguishAura: package needs a ringPart (set it as PrimaryPart)"
	)
	object.ringPart = primaryPart
	object.arrowsPart = clone:FindFirstChild("arrowsPart")
	object.auraLight = clone:FindFirstChildWhichIsA("PointLight", true)
	object.auraLightAuthored = object.auraLight ~= nil and object.auraLight.Enabled
	object.ignitedEmitters = {}
	collectEmitters(primaryPart:FindFirstChild("plate"), object.ignitedEmitters)
	collectEmitters(primaryPart:FindFirstChild("particles"), object.ignitedEmitters)
	object.activeEmitters = {}
	local smokePart = clone:FindFirstChild("smokePart")
	local smokeAreaPart = clone:FindFirstChild("smokeAreaPart")
	collectEmitters(smokePart, object.activeEmitters)
	collectEmitters(smokeAreaPart, object.activeEmitters)
	local v4 = {}

	for _, ignitedEmitter in ipairs(object.ignitedEmitters) do
		v4[ignitedEmitter] = true
	end

	for _, activeEmitter in ipairs(object.activeEmitters) do
		v4[activeEmitter] = true
	end

	local v5 = {}

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") and not v4[descendant] then
			warn(string.format(
				"[ExtinguishAura] %s: emitter %q is in the package but in no driven bucket (ignited = plate/particles, active = smokePart/smokeAreaPart) - it will NOT track his states",
				instance.Name,
				descendant:GetFullName()
			))
		elseif descendant:IsA("Light") and descendant ~= object.auraLight then
			table.insert(
				v5,
				string.format(
					"%s %q (Enabled=%s, Brightness=%.2f)",
					descendant.ClassName,
					descendant:GetFullName(),
					tostring(descendant.Enabled),
					descendant.Brightness
				)
			)
		end
	end

	if #v5 > 0 then
		warn(string.format(
			"[ExtinguishAura] %s: %d light(s) in the package are UNGOVERNED -> %s <- EXEMPT from the blackout-only law (governed = %s; caller's rule says %s)",
			instance.Name,
			#v5,
			table.concat(v5, " | "),
			not object.auraLight and "NONE (no PointLight found in package)" or string.format(
				"%q (authored Enabled=%s)",
				object.auraLight:GetFullName(),
				(tostring(object.auraLightAuthored))
			) or "NONE (no PointLight found in package)",
			settings.lightEnabled == false and "DARK" or "LIT"
		))
	end

	object.baseDiameter = primaryPart.Size.X
	object.footprintScale = 1
	object.footprintParts = {
		[primaryPart] = primaryPart.Size
	}

	if smokeAreaPart and smokeAreaPart:IsA("BasePart") then
		object.footprintParts[smokeAreaPart] = smokeAreaPart.Size
	end

	if object.arrowsPart then
		object.arrowsIdleTransparency = object.arrowsPart.Transparency
		object.arrowsBaseSize = object.arrowsPart.Size
		object.arrowsIdleSize = object.arrowsBaseSize

		if settings.arrowsActiveScale then
			object.arrowsActiveSize = Vector3.new(
				object.arrowsIdleSize.X * settings.arrowsActiveScale,
				object.arrowsIdleSize.Y,
				object.arrowsIdleSize.Z * settings.arrowsActiveScale
			)
		else
			object.arrowsActiveSize = object.arrowsIdleSize
		end

		object.arrowsPart.Transparency = 1
	end

	object.ignitedParticle = resolveInstance(instance, settings.ignitedParticlePath)
	object.isWorldLocked = settings.worldLocked ~= false
	object.mount = mountPackage(clone, primaryPart, part, settings.weldOffset, object.isWorldLocked)
	clone.Parent = instance

	if object.isWorldLocked then
		pcall(function()
			primaryPart:SetNetworkOwner(nil)
		end)
	end

	CollectionService:AddTag(clone, "FlameTrailQualityProof")
	object:_refresh()
	return object
end

function ExtinguishAura:setIgnited(p)
	local isIgnited = p and true or false

	if self.isDestroyed or self.isIgnited == isIgnited then
		return
	end

	self.isIgnited = isIgnited
	self:_refresh()
end

function ExtinguishAura:setActive(p)
	local isActive = p and true or false

	if self.isDestroyed or self.isActive == isActive then
		return
	end

	self.isActive = isActive
	self:_refresh()
end

function ExtinguishAura:setSize(value)
	if self.isDestroyed or type(value) ~= "number" or self.baseDiameter <= 0 then
		return
	end

	local footprintScale = math.max(value, 0) / self.baseDiameter

	if math.abs(footprintScale - self.footprintScale) < 0.001 then
		return
	end

	self.footprintScale = footprintScale

	for k, footprintPart in self.footprintParts do
		if k.Parent then
			k.Size = Vector3.new(footprintPart.X * footprintScale, footprintPart.Y, footprintPart.Z * footprintScale)
		end
	end

	if not self.arrowsPart then
		return
	end

	local arrowsBaseSize = self.arrowsBaseSize
	self.arrowsIdleSize = Vector3.new(
		arrowsBaseSize.X * footprintScale,
		arrowsBaseSize.Y,
		arrowsBaseSize.Z * footprintScale
	)
	local arrowsActiveScale = self.settings.arrowsActiveScale or 1
	self.arrowsActiveSize = Vector3.new(
		self.arrowsIdleSize.X * arrowsActiveScale,
		self.arrowsIdleSize.Y,
		self.arrowsIdleSize.Z * arrowsActiveScale
	)

	if not self.isActive then
		self.arrowsPart.Size = self.arrowsIdleSize
	end
end

function ExtinguishAura.setOffset(p, p2)
	if p.isDestroyed or typeof(p2) ~= "CFrame" or not p.mount then
		return
	end

	p.mount.setOffset(p2)
end

function ExtinguishAura.setBlinkInterval(p, value)
	if p.isDestroyed or type(value) ~= "number" then
		return
	end

	p.settings.blinkInterval = math.max(value, 0.05)
end

function ExtinguishAura:destroy()
	if self.isDestroyed then
		return
	end

	self.isDestroyed = true
	self:_stopThreads()

	if self.ignitedParticle and self.ignitedParticle.Parent then
		self.ignitedParticle.Enabled = self.isIgnited
	end

	if self.mount then
		self.mount.destroy()
		self.mount = nil
	end

	if self.fxModel then
		self.fxModel:Destroy()
		self.fxModel = nil
	end
end

function ExtinguishAura:_stopThreads()
	if self.ringThread then
		task.cancel(self.ringThread)
		self.ringThread = nil
	end

	if self.arrowsThread then
		task.cancel(self.arrowsThread)
		self.arrowsThread = nil
	end
end

function ExtinguishAura:_refresh()
	if self.isDestroyed then
		return
	end

	self:_stopThreads()
	local ignitedEmitters = self.ignitedEmitters
	local isIgnited = self.isIgnited

	for _, ignitedEmitter in ignitedEmitters do
		ignitedEmitter.Enabled = isIgnited
	end

	if self.ignitedParticle and self.ignitedParticle.Parent then
		self.ignitedParticle.Enabled = self.isIgnited
	end

	local activeEmitters = self.activeEmitters
	local isActive = self.isActive

	for _, activeEmitter in activeEmitters do
		activeEmitter.Enabled = isActive
	end

	self:_applyLight()
	self:_applySound()
	self:_startArrows()
	self:_startRing()
end

function ExtinguishAura:_applySound()
	local activeSound = self.settings.activeSound
	local extinguishAuraLoop = self.ringPart and self.ringPart:FindFirstChild("ExtinguishAuraLoop")

	if self.isDestroyed or not (activeSound and self.isActive) then
		if extinguishAuraLoop then
			extinguishAuraLoop:Destroy()
		end
	else
		if extinguishAuraLoop and extinguishAuraLoop:GetAttribute("CueKey") == activeSound then
			return
		end

		if extinguishAuraLoop then
			extinguishAuraLoop:Destroy()
		end

		local v2 = Audio:Acquire(activeSound, {
			Name = "ExtinguishAuraLoop",
			Looped = true,
			Parent = self.ringPart
		})

		if v2 then
			v2:SetAttribute("CueKey", activeSound)
		end
	end
end

function ExtinguishAura:_applyLight()
	if not self.auraLight then
		return
	end

	local settings = self.settings
	local enabled = self.auraLightAuthored and settings.lightEnabled ~= false
	self.auraLight.Enabled = enabled

	if not enabled then
		return
	end

	local lightActiveRange = self.isActive and settings.lightActiveRange or settings.lightIdleRange
	tweenHelpers.playTween(self.auraLight, settings.lightTweenInfo, {
		Range = lightActiveRange
	})
end

function ExtinguishAura:setLightEnabled(p)
	local lightEnabled = p and true or false

	if self.isDestroyed or self.settings.lightEnabled == lightEnabled then
		return
	end

	self.settings.lightEnabled = lightEnabled
	self:_applyLight()
end

function ExtinguishAura:_startArrows()
	if not self.arrowsPart then
		return
	end

	local settings = self.settings

	if not self.isActive then
		tweenHelpers.playTween(self.arrowsPart, settings.arrowsTweenInfo, {
			Transparency = 1,
			Size = self.arrowsIdleSize
		})
		return
	end

	local halfBlinkInterval = settings.blinkInterval / 2
	self.arrowsThread = task.spawn(function()
		while true do
			tweenHelpers.playTween(self.arrowsPart, settings.arrowsTweenInfo, {
				Transparency = self.arrowsIdleTransparency,
				Size = self.arrowsActiveSize
			})
			task.wait(halfBlinkInterval)
			tweenHelpers.playTween(self.arrowsPart, settings.arrowsTweenInfo, {
				Transparency = 1,
				Size = self.arrowsIdleSize
			})
			task.wait(halfBlinkInterval)
		end
	end)
end

function ExtinguishAura:_startRing()
	local settings = self.settings
	local ringPart = self.ringPart

	if self.isActive then
		local halfBlinkInterval = settings.blinkInterval / 2
		self.ringThread = task.spawn(function()
			while true do
				tweenHelpers.playTween(ringPart, settings.ringBlinkTweenInfo, {
					Color = settings.ringBlinkColor,
					Transparency = settings.ringActiveTransparency
				})
				task.wait(halfBlinkInterval)
				tweenHelpers.playTween(ringPart, settings.ringBlinkTweenInfo, {
					Color = settings.ringActiveColor,
					Transparency = settings.ringActiveTransparency
				})
				task.wait(halfBlinkInterval)
			end
		end)
	elseif self.isIgnited then
		self.ringThread = task.spawn(function()
			while true do
				tweenHelpers.playTween(ringPart, settings.ringIdleSnapTweenInfo, {
					Color = settings.ringIdleColorA,
					Transparency = settings.ringIdleTransparencyA
				})
				task.wait(settings.ringIdleSnapTweenInfo.Time)
				tweenHelpers.playTween(ringPart, settings.ringIdleFadeTweenInfo, {
					Color = settings.ringIdleColorB,
					Transparency = settings.ringIdleTransparencyB
				})
				task.wait(settings.ringIdleFadeTweenInfo.Time)
			end
		end)
	else
		tweenHelpers.playTween(ringPart, settings.ringDormantTweenInfo, {
			Color = settings.ringDormantColor,
			Transparency = settings.ringDormantTransparency
		})
	end
end

return ExtinguishAura