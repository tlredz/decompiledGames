local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.numberMin(0), t.numberMaxExclusive(1e999))
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local emitAt = VFX.EmitAt
local Log = require(ReplicatedStorage.Packages.Log)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
local MoneyPiles = {}
MoneyPiles.__index = MoneyPiles
MoneyPiles.__class = "OfflineGeneratedMoney"
local color = Color3.new(1, 1, 1)
local v = Log.new()
local buckPiles = ReplicatedStorage.Assets.Models.BuckPiles
assert(buckPiles:IsA("Folder"), "ReplicatedStorage.Assets.Models.BuckPiles must be a Folder")
local moneyCollect = ReplicatedStorage.Assets.VFX.MoneyCollect
assert(moneyCollect:IsA("Folder"), "ReplicatedStorage.Assets.VFX.MoneyCollect must be a Folder")

function MoneyPiles.new(bucketRoot, parent)
	t.strict(t.instanceIsA("BasePart"))(bucketRoot)
	t.strict(t.Instance)(parent)
	local object = setmetatable({}, MoneyPiles)
	local folder = Instance.new("Folder")
	folder.Name = "LocalOfflineGeneratedMoneyPiles"
	folder.Parent = parent
	local maid = Trove.new()
	object._trove = maid
	object._animationTrove = Trove.new()
	object._bucketRoot = bucketRoot
	object._runtimeFolder = folder
	object._stages = {}
	object._currentStageIndex = 0
	object._lastStageCenterCFrame = nil
	object._destroyed = false
	object._lastAdornee = nil
	object.BillboardAdorneeChanged = Signal.new()
	maid:Add(folder)
	maid:Add(object._animationTrove)
	maid:Add(bucketRoot:GetPropertyChangedSignal("CFrame"):Connect(function()
		for _, _stage in ipairs(object._stages) do
			MoneyPiles._pivotRootToBucket(_stage.model, _stage.rootPart, bucketRoot)
		end
	end))
	local models = {}

	for _, model in ipairs(buckPiles:GetChildren()) do
		if model:IsA("Model") then
			models[#models + 1] = model
		end
	end

	table.sort(models, function(a, b)
		return MoneyPiles._getStageSortIndex(a) < MoneyPiles._getStageSortIndex(b)
	end)
	assert(#models == 3, "BuckPiles must contain exactly three stage models")

	for _, v2 in ipairs(models) do
		object._stages[#object._stages + 1] = object:_buildStage(v2)
	end

	object:_hideAllStages()
	return object
end

function MoneyPiles._getStageSortIndex(p)
	local name = tonumber(p.Name)
	assert(name, (`BuckPiles stage {p.Name} must be numerically named`))
	return name
end

function MoneyPiles._readVector3Attribute(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)
	t.strict(t.Vector3)(attribute)
	return attribute
end

function MoneyPiles._readCFrameAttribute(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)
	t.strict(t.CFrame)(attribute)
	return attribute
end

function MoneyPiles._getVisibleTransparency(p)
	if p.Transparency >= 1 then
		return 0
	end

	return p.Transparency
end

function MoneyPiles._pivotRootToBucket(instance, p, p2)
	local pivot = instance:GetPivot()
	instance:PivotTo(p2.CFrame * p.CFrame:Inverse() * pivot)
end

function MoneyPiles._createTopAttachment(parent)
	local generatedMoneyTopAttachment = parent:FindFirstChild("GeneratedMoneyTopAttachment")

	if generatedMoneyTopAttachment then
		t.strict(t.instanceIsA("Attachment"))(generatedMoneyTopAttachment)
		return generatedMoneyTopAttachment
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "GeneratedMoneyTopAttachment"
	attachment.Parent = parent
	return attachment
end

function MoneyPiles._createHighlight(p)
	local highlight = Instance.new("Highlight")
	highlight.Name = "OfflineMoneyBucketHighlight"
	highlight.Adornee = p
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 1
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0
	highlight.Enabled = false
	highlight.Parent = p
	return highlight
end

function MoneyPiles._syncTopAttachment(data)
	local boundingBox, v2 = data.model:GetBoundingBox()
	local v3 = boundingBox.Position + boundingBox.UpVector * (v2.Y * 0.5)
	data.topAttachment.Position = data.mainPart.CFrame:PointToObjectSpace(v3)
end

function MoneyPiles._collectAnimatedParts(folder, p)
	local result = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and part ~= p) then
			continue
		end

		local v2 = part:GetAttribute("OriginalSize") ~= nil
		local v3 = part:GetAttribute("TargetSize") ~= nil
		local v4 = part:GetAttribute("OriginalCFrame") ~= nil
		local v5 = part:GetAttribute("TargetCFrame") ~= nil

		if v2 or v3 or v4 or v5 then
			result[#result + 1] = {
				part = part,
				originalSize = MoneyPiles._readVector3Attribute(part, "OriginalSize"),
				targetSize = MoneyPiles._readVector3Attribute(part, "TargetSize"),
				originalCFrame = MoneyPiles._readCFrameAttribute(part, "OriginalCFrame"),
				targetCFrame = MoneyPiles._readCFrameAttribute(part, "TargetCFrame"),
				visibleTransparency = MoneyPiles._getVisibleTransparency(part)
			}
		end
	end

	if #result == 0 then
		v:AtWarning():Log((`BuckPiles stage {folder.Name} has no animated part attributes`))
	end

	return result
end

function MoneyPiles._setStageVisible(data, enabled: boolean)
	for _, part in ipairs(data.model:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		if part == data.rootPart then
			part.Transparency = 1
		else
			local _OfflineGeneratedMoneyVisibleTransparency = part:GetAttribute("_OfflineGeneratedMoneyVisibleTransparency")
			part.Transparency = (not enabled or typeof(_OfflineGeneratedMoneyVisibleTransparency) ~= "number") and 1 or _OfflineGeneratedMoneyVisibleTransparency
		end
	end

	data.highlight.Enabled = enabled
end

function MoneyPiles._resetStageParts(p)
	local cFrame = p.rootPart.CFrame

	for _, animatedPart in ipairs(p.animatedParts) do
		animatedPart.part.Size = animatedPart.originalSize
		animatedPart.part.CFrame = cFrame * animatedPart.originalCFrame
	end

	MoneyPiles._syncTopAttachment(p)
end

function MoneyPiles._applyStageAlpha(p, value: number)
	local v2 = math.clamp(value, 0, 1)
	local cFrame = p.rootPart.CFrame

	for _, animatedPart in ipairs(p.animatedParts) do
		animatedPart.part.Size = animatedPart.originalSize:Lerp(animatedPart.targetSize, v2)
		animatedPart.part.CFrame = cFrame * animatedPart.originalCFrame:Lerp(animatedPart.targetCFrame, v2)
		animatedPart.part.Transparency = animatedPart.visibleTransparency
	end

	MoneyPiles._syncTopAttachment(p)
end

function MoneyPiles:_buildStage(instance)
	local clone = instance:Clone()
	clone.Name = `OfflineGeneratedMoneyStage{instance.Name}`
	clone.Parent = self._runtimeFolder
	local rootPart = clone:FindFirstChild("RootPart")
	t.strict(t.instanceIsA("BasePart"))(rootPart)
	local main = clone:FindFirstChild("Main")
	t.strict(t.instanceIsA("BasePart"))(main)
	clone.PrimaryPart = rootPart
	MoneyPiles._pivotRootToBucket(clone, rootPart, self._bucketRoot)

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part:SetAttribute("_OfflineGeneratedMoneyVisibleTransparency", MoneyPiles._getVisibleTransparency(part))

		if part == rootPart then
			part.Transparency = 1
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end

	local v2 = {
		index = MoneyPiles._getStageSortIndex(instance),
		model = clone,
		rootPart = rootPart,
		mainPart = main,
		highlight = MoneyPiles._createHighlight(clone),
		topAttachment = MoneyPiles._createTopAttachment(main),
		animatedParts = MoneyPiles._collectAnimatedParts(clone, rootPart)
	}
	MoneyPiles._resetStageParts(v2)
	MoneyPiles._setStageVisible(v2, false)
	return v2
end

function MoneyPiles:_hideAllStages()
	for _, _stage in ipairs(self._stages) do
		MoneyPiles._resetStageParts(_stage)
		MoneyPiles._setStageVisible(_stage, false)
	end

	self._currentStageIndex = 0

	if self._lastAdornee ~= nil then
		self._lastAdornee = nil
		self.BillboardAdorneeChanged:Fire(nil)
	end
end

function MoneyPiles:_fadeOutStages(duration: number)
	local v2 = false

	for _, _stage in ipairs(self._stages) do
		_stage.highlight.Enabled = false

		for _, part in ipairs(_stage.model:GetDescendants()) do
			if not (part:IsA("BasePart") and part ~= _stage.rootPart and part.Transparency < 1) then
				continue
			end

			local tween = TweenService:Create(
				part,
				TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			)
			self._animationTrove:Add(tween)
			tween:Play()
			v2 = true
		end
	end

	return v2
end

function MoneyPiles:_getCollectAllEffectCFrame()
	local _currentStageIndex

	if self._currentStageIndex > 0 then
		_currentStageIndex = self._currentStageIndex
	end

	local v2

	if _currentStageIndex then
		v2 = self._stages[_currentStageIndex]
	end

	if v2 then
		return v2.mainPart.CFrame
	end

	return self._lastStageCenterCFrame or self._bucketRoot.CFrame
end

function MoneyPiles._emitCollectAllCash(cframe: CFrame)
	emitAt(cframe, moneyCollect:GetChildren())
end

function MoneyPiles:_setProgress(value: number)
	local v2 = math.clamp(value, 0, 1)
	local _stages = self._stages
	local count = #_stages

	if count <= 0 then
		return
	end

	if v2 <= 0 then
		self:_hideAllStages()
		return
	end

	local v3 = v2 * count
	local currentStageIndex = math.clamp(math.floor(v3) + 1, 1, count)
	local v5 = v2 >= 1 and 1 or v3 - (currentStageIndex - 1)

	for i, _stage in ipairs(_stages) do
		local v6 = i == currentStageIndex
		MoneyPiles._setStageVisible(_stage, v6)

		if v6 then
			MoneyPiles._applyStageAlpha(_stage, v5)
		else
			MoneyPiles._resetStageParts(_stage)
		end
	end

	self._currentStageIndex = currentStageIndex
	self._lastStageCenterCFrame = _stages[currentStageIndex].mainPart.CFrame
	local topAttachment = _stages[currentStageIndex].topAttachment

	if self._lastAdornee ~= topAttachment then
		self._lastAdornee = topAttachment
		self.BillboardAdorneeChanged:Fire(topAttachment)
	end
end

function MoneyPiles:UpdateInstant(p: number, flag: boolean)
	t.strict(intersection)(p)
	t.strict(t.boolean)(flag)

	if flag and not (p <= 0) then
		self:_setProgress((math.clamp(math.max(p - 1, 0) / 999999999, 0, 1)))
	else
		self:_hideAllStages()
	end
end

function MoneyPiles:PlayCollectReset()
	self._animationTrove:Destroy()
	self._animationTrove = Trove.new()
	self._trove:Add(self._animationTrove)

	if self:_fadeOutStages(0.3) then
		MoneyPiles._emitCollectAllCash(self:_getCollectAllEffectCFrame())
	end

	self._animationTrove:Add(task.delay(0.3, function()
		if self._destroyed then
			return
		end

		self:_hideAllStages()
	end))
end

function MoneyPiles:GetBillboardAdornee()
	return self._lastAdornee
end

function MoneyPiles:Destroy()
	self._destroyed = true
	self._trove:Destroy()
end

return MoneyPiles