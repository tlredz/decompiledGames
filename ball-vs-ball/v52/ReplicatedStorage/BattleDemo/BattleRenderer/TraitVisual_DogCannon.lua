local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TraitVisualDogCannon = {}
TraitVisualDogCannon.__index = TraitVisualDogCannon

-- equivalent calls inferred from this helper; original call sites unknown
local function bindChargeModelToBall(templateModel, attachment, cframe: CFrame)
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if templateModel.Parent == nil or attachment.Parent == nil then
			heartbeatConnection:Disconnect()
		else
			templateModel:PivotTo(CFrame.new(attachment.WorldPosition) * cframe)
		end
	end)
end

function TraitVisualDogCannon.new(ctx)
	local self = setmetatable({}, TraitVisualDogCannon)
	self._ctx = ctx
	self.beamModels = {}
	self.beamParts = {}
	self.chargeModels = {}
	return self
end

function TraitVisualDogCannon:_setModelVisibility(folder, enabled: boolean)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local originalTransparency = descendant:GetAttribute("OriginalTransparency")
			descendant.Transparency = not enabled and 1 or typeof(originalTransparency) == "number" and originalTransparency or descendant.Transparency or 1
		elseif descendant:IsA("Beam") then
			descendant.Enabled = enabled
		end
	end
end

function TraitVisualDogCannon:_ensureBeamModel(battleOwnerSlotId: string)
	local beamModel = self.beamModels[battleOwnerSlotId]
	local beamPart = self.beamParts[battleOwnerSlotId]

	if beamModel and beamPart then
		return beamModel, beamPart
	end

	local clone = self._ctx.dogCannonTemplate:Clone()
	clone.Name = string.format("%s_DogCannonBeam", battleOwnerSlotId)
	clone:SetAttribute("BattleOwnerSlotId", battleOwnerSlotId)
	local firstChild = clone:FindFirstChild("碰撞箱")
	assert(firstChild, "大狗光炮克隆缺少碰撞箱")
	firstChild.Anchored = true
	firstChild.CanCollide = false
	firstChild.CanQuery = false
	firstChild.CanTouch = false
	firstChild:SetAttribute("OriginalTransparency", firstChild.Transparency)
	clone.PrimaryPart = firstChild
	clone.Parent = self._ctx.rootFolder
	local beamModels = self.beamModels
	local beamParts = self.beamParts
	beamModels[battleOwnerSlotId] = clone
	beamParts[battleOwnerSlotId] = firstChild
	return clone, firstChild
end

function TraitVisualDogCannon:update(p)
	local _ctx = self._ctx
	local dogCannon = p.traits and p.traits.DogCannon
	local v

	if dogCannon == nil or dogCannon.phase ~= "Beam" or dogCannon.beamStart == nil then
		v = false
	else
		v = dogCannon.beamEnd ~= nil
	end

	if v then
		local _ensureBeamModel, v2 = self:_ensureBeamModel(p.id)
		local ballMarkerHeight = _ctx.getBallMarkerHeight(p.id)
		local worldFromArena = _ctx.worldFromArena(dogCannon.beamStart, ballMarkerHeight)
		local worldFromArena2 = _ctx.worldFromArena(dogCannon.beamEnd, ballMarkerHeight)
		local magnitude = (worldFromArena2 - worldFromArena).Magnitude

		if magnitude <= 0.05 then
			self:_setModelVisibility(_ensureBeamModel, false)
			return
		end

		v2.Size = Vector3.new(v2.Size.X, v2.Size.Y, magnitude)
		v2.CFrame = CFrame.lookAt((worldFromArena + worldFromArena2) * 0.5, worldFromArena)
		self:_setModelVisibility(_ensureBeamModel, true)
	else
		local beamModel = self.beamModels[p.id]

		if beamModel then
			self:_setModelVisibility(beamModel, false)
		end
	end
end

function TraitVisualDogCannon:playChargePulse(p2: string)
	local _ctx = self._ctx
	local ballPart = _ctx.getBallPart(p2)

	if not ballPart then
		return
	end

	local attachment = ballPart:FindFirstChild("发射点")
	assert(attachment and attachment:IsA("Attachment"), "大狗球碰撞箱缺少发射点")
	local chargeModel = self.chargeModels[p2]

	if chargeModel then
		chargeModel:Destroy()
		self.chargeModels[p2] = nil
	end

	local templateModel, v = _ctx.cloneTemplateModel(
		_ctx.dogChargeTemplateBundle,
		string.format("%s_DogCannonCharge", p2)
	)
	templateModel.Parent = _ctx.rootFolder
	self.chargeModels[p2] = templateModel
	local attachment2 = v:FindFirstChild("朝向标记")
	assert(attachment2 and attachment2:IsA("Attachment"), "大狗蓄力素材缺少朝向标记")
	local v2 = _ctx.effectArenaRotation * attachment2.CFrame:Inverse()
	templateModel:PivotTo(CFrame.new(attachment.WorldPosition) * v2)
	bindChargeModelToBall(templateModel, attachment, v2) -- equivalent call inferred; original call site unknown
	local particleEmitCount = _ctx.config.particleEmitCount or 12
	local v3 = 0

	for _, descendant in ipairs(templateModel:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant:Emit(particleEmitCount)
			v3 = math.max(v3, descendant.Lifetime.Max)
		elseif descendant:IsA("Sound") then
			descendant.TimePosition = 0
			DuelAudioController.prepare(descendant)
			descendant:Play()
			v3 = math.max(v3, descendant.TimeLength > 0 and descendant.TimeLength or 1)
		end
	end

	Debris:AddItem(templateModel, math.max(v3, 0.1) + 0.2)
end

function TraitVisualDogCannon:playBeamStart(p: string)
	local _, v = self:_ensureBeamModel(p)
	local sound = v:FindFirstChild("音效")

	if sound and sound:IsA("Sound") then
		sound.TimePosition = 0
		DuelAudioController.prepare(sound)
		sound:Play()
	end
end

function TraitVisualDogCannon:playBeamEnd(p: string)
	local beamModel = self.beamModels[p]

	if beamModel then
		self:_setModelVisibility(beamModel, false)
	end
end

function TraitVisualDogCannon:cleanupBall(p: string)
	local beamModel = self.beamModels[p]

	if beamModel then
		beamModel:Destroy()
	end

	local beamModels = self.beamModels
	local beamParts = self.beamParts
	beamModels[p] = nil
	beamParts[p] = nil
	local chargeModel = self.chargeModels[p]

	if chargeModel then
		chargeModel:Destroy()
	end

	self.chargeModels[p] = nil
end

function TraitVisualDogCannon:reset()
	for k in self.beamModels do
		self:cleanupBall(k)
	end

	for k in self.chargeModels do
		self:cleanupBall(k)
	end
end

return TraitVisualDogCannon