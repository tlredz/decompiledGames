local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Modules.Component)
local BonusMomentInteraction = require(ReplicatedStorage.Util.BonusMomentInteraction)
local Maid = require(ReplicatedStorage.Util.Maid)
local Net = require(ReplicatedStorage.Modules.Net)
local remoteEvent = Net:RemoteEvent("UseZipline")
local remoteEvent2 = Net:RemoteEvent("ZiplineInteractionBlocked")
local v = {
	TAG = "ZiplinePair",
	RIDER_TAG = "ZiplineActiveRider",
	ENDPOINT_NAME = "zipline",
	PRIMARY_PART_NAME = "Cube.003",
	PROMPT_NAME = "ZiplinePrompt",
	PROMPT_DISTANCE = 12,
	VISUAL_NAME = "RepairedZipline",
	BEAM_COLOR = Color3.fromRGB(90, 76, 66),
	BEAM_WIDTH = 0.25,
	RIDER_VISUAL_NAME = "ZiplineRiderHint",
	RIDER_VISUAL_HALF_LENGTH = 32,
	RIDER_VISUAL_OFFSET = -3
}
local v2 = Component.new({
	Tag = v.TAG
})
local v3 = false
remoteEvent2.OnClientEvent:Connect(function(p)
	if BonusMomentInteraction.isTransformedReason(p) then
		BonusMomentInteraction.notifyTransformed()
	end
end)

local function getEndpoints(instance)
	local models = {}

	for _, model in instance:GetChildren() do
		if not (model:IsA("Model") and model.Name == v.ENDPOINT_NAME) then
			continue
		end

		local primaryPart = model.PrimaryPart

		if not primaryPart or primaryPart.Name ~= v.PRIMARY_PART_NAME then
			return nil
		end

		table.insert(models, model)
	end

	if #models == 2 then
		return models
	end

	return nil
end

local function createBeam(name: string, attachment, attachment2)
	local beam = Instance.new("Beam")
	beam.Name = name
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.Color = ColorSequence.new(v.BEAM_COLOR)
	beam.CurveSize0 = 0
	beam.CurveSize1 = 0
	beam.FaceCamera = true
	beam.Segments = 1
	beam.Transparency = NumberSequence.new(0)
	beam.Width0 = v.BEAM_WIDTH
	beam.Width1 = v.BEAM_WIDTH
	beam.Enabled = true
	return beam
end

local function createRepairedVisual(endpoints)
	local maid = Maid.new()
	local folder = Instance.new("Folder")
	folder.Name = v.VISUAL_NAME
	folder.Parent = endpoints[1].Parent
	maid:GiveTask(folder)
	local v4 = {}

	for k, v5 in endpoints do
		local attachment = Instance.new("Attachment")
		attachment.Name = `{v.VISUAL_NAME}Attachment{k}`
		attachment.Parent = v5.PrimaryPart
		maid:GiveTask(attachment)
		table.insert(v4, attachment)
	end

	local beam = createBeam(v.VISUAL_NAME, v4[1], v4[2])
	beam.Parent = folder
	return maid
end

local function createRiderVisual(model)
	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil
	end

	local maid = Maid.new()
	local attachment = Instance.new("Attachment")
	local attachment2 = Instance.new("Attachment")
	local RIDER_VISUAL_OFFSET = v.RIDER_VISUAL_OFFSET
	local RIDER_VISUAL_HALF_LENGTH = v.RIDER_VISUAL_HALF_LENGTH
	attachment.Name = `{v.RIDER_VISUAL_NAME}Attachment0`
	attachment.Position = Vector3.new(0, RIDER_VISUAL_OFFSET, -RIDER_VISUAL_HALF_LENGTH)
	attachment.Parent = humanoidRootPart
	attachment2.Name = `{v.RIDER_VISUAL_NAME}Attachment1`
	attachment2.Position = Vector3.new(0, RIDER_VISUAL_OFFSET, RIDER_VISUAL_HALF_LENGTH)
	attachment2.Parent = humanoidRootPart
	maid:GiveTask(attachment)
	maid:GiveTask(attachment2)
	local beam = createBeam(v.RIDER_VISUAL_NAME, attachment, attachment2)
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.7),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(0.8, 0.7),
		NumberSequenceKeypoint.new(1, 1)
	})
	beam.Parent = humanoidRootPart
	maid:GiveTask(beam)
	return maid
end

local function startRiderVisual(p, model)
	local _observerMaid = p._observerMaid
	local playerFromCharacter

	if model:IsA("Model") then
		playerFromCharacter = Players:GetPlayerFromCharacter(model)
	end

	if p._repaired or not _observerMaid or _observerMaid[model] or not model:IsA("Model") or not model:HasTag(v.RIDER_TAG) or not playerFromCharacter or playerFromCharacter == Players.LocalPlayer then
		return
	end

	local maid = Maid.new()
	local v4 = nil
	_observerMaid[model] = maid

	local function tryCreateVisual()
		if maid._visual then
			return
		end

		local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return
		end

		local riderVisual = createRiderVisual(model)

		if riderVisual then
			v4 = humanoidRootPart
			maid._visual = riderVisual
		end
	end

	if not maid._visual then
		local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
		local visual = humanoidRootPart and humanoidRootPart:IsA("BasePart") and createRiderVisual(model)

		if visual then
			v4 = humanoidRootPart
			maid._visual = visual
		end
	end

	maid:GiveTask(model.ChildAdded:Connect(function(child)
		if child.Name == "HumanoidRootPart" then
			if maid._visual then
				return
			end

			local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				if not humanoidRootPart:IsA("BasePart") then
					return
				end

				local riderVisual = createRiderVisual(model)

				if riderVisual then
					v4 = humanoidRootPart
					maid._visual = riderVisual
				end
			end
		end
	end))
	maid:GiveTask(model.ChildRemoved:Connect(function(child)
		if child == v4 then
			v4 = nil
			maid._visual = nil

			if maid._visual then
				return
			end

			local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				if not humanoidRootPart:IsA("BasePart") then
					return
				end

				local riderVisual = createRiderVisual(model)

				if riderVisual then
					v4 = humanoidRootPart
					maid._visual = riderVisual
				end
			end
		end
	end))
end

local function bindRiderVisuals(state)
	local _observerMaid = state._observerMaid

	if not _observerMaid or state._repaired then
		return
	end

	for _, v4 in CollectionService:GetTagged(v.RIDER_TAG) do
		startRiderVisual(state, v4)
	end

	_observerMaid:GiveTask(CollectionService:GetInstanceAddedSignal(v.RIDER_TAG):Connect(function(p)
		startRiderVisual(state, p)
	end))
	_observerMaid:GiveTask(CollectionService:GetInstanceRemovedSignal(v.RIDER_TAG):Connect(function(instance)
		if not instance:HasTag(v.RIDER_TAG) then
			_observerMaid[instance] = nil
		end
	end))
end

function v2:setRepaired(flag: boolean)
	v3 = flag
	self._repaired = flag

	if self._prompts then
		for _, _prompt in self._prompts do
			_prompt.Enabled = flag
		end
	end

	local _visualMaid = self._visualMaid
	local _observerMaid = self._observerMaid

	if not (_visualMaid and _observerMaid) then
		return
	end

	_visualMaid:DoCleaning()
	_observerMaid:DoCleaning()

	if not flag then
		bindRiderVisuals(self)
		return
	end

	local endpoints = getEndpoints(self.Instance)

	if endpoints then
		_visualMaid:GiveTask((createRepairedVisual(endpoints)))
	elseif self._retrySetup then
		self._retrySetup()
	end
end

function v2.setDefaultRepaired(object, flag: boolean)
	v3 = flag

	for _, v4 in object:GetAll() do
		v4:setRepaired(flag)
	end
end

function v2:Start()
	local repaired = v3

	if self._maid then
		self._maid:Destroy()
	end

	local maid = Maid.new()
	local observerMaid = Maid.new()
	local visualMaid = Maid.new()
	local maid2 = Maid.new()
	local prompts = {}
	self._maid = maid
	self._observerMaid = observerMaid
	self._visualMaid = visualMaid
	self._prompts = prompts
	self._repaired = repaired
	maid:GiveTask(observerMaid)
	maid:GiveTask(visualMaid)
	maid:GiveTask(maid2)

	local function hasLivePrompts(endpoints)
		if #prompts ~= #endpoints then
			return false
		end

		for _, v8 in prompts do
			if not v8:IsDescendantOf(self.Instance) then
				return false
			end
		end

		return true
	end

	local v8 = false

	local function trySetupEndpoints()
		local endpoints = getEndpoints(self.Instance)

		if not endpoints then
			return false
		end

		local v9

		if hasLivePrompts(endpoints) then
			v9 = false
		else
			maid2:DoCleaning()
			table.clear(prompts)
			v9 = true

			for _, endpoint in endpoints do
				local child = endpoint.PrimaryPart and endpoint.PrimaryPart:FindFirstChild(v.PROMPT_NAME)

				if child then
					child:Destroy()
				end

				local proximityPrompt = Instance.new("ProximityPrompt")
				proximityPrompt:AddTag("ProximityPrompt")
				proximityPrompt.Name = v.PROMPT_NAME
				proximityPrompt.ActionText = "Use Zipline"
				proximityPrompt.ObjectText = "Zipline"
				proximityPrompt.MaxActivationDistance = v.PROMPT_DISTANCE
				proximityPrompt.RequiresLineOfSight = false
				proximityPrompt.Enabled = false
				proximityPrompt.Parent = endpoint.PrimaryPart
				table.insert(prompts, proximityPrompt)
				maid2:GiveTask(proximityPrompt)
				local v10 = endpoint
				maid2:GiveTask(proximityPrompt.Triggered:Connect(function()
					if not self._repaired then
						return
					end

					if BonusMomentInteraction.isTransformed(Players.LocalPlayer.Character) then
						BonusMomentInteraction.notifyTransformed()
					else
						remoteEvent:FireServer(self.Instance, v10)
					end
				end))
			end
		end

		if v9 or v8 then
			v8 = false
			self:setRepaired(self._repaired)
		end

		return true
	end

	maid._endpointRetry = self.Instance.DescendantAdded:Connect(function(descendant)
		if descendant.Name == v.ENDPOINT_NAME or descendant.Name == v.PRIMARY_PART_NAME then
			trySetupEndpoints()
		end
	end)

	function self._retrySetup()
		v8 = true
	end

	if not trySetupEndpoints() then
		self:setRepaired(repaired)
	end
end

function v2:Stop()
	if self._maid then
		self._maid:Destroy()
	end

	self._maid = nil
	self._observerMaid = nil
	self._visualMaid = nil
	self._prompts = nil
	self._retrySetup = nil
	self._repaired = false
end

return v2