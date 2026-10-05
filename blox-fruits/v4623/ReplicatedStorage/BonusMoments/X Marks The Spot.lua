local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage.Effect)
local Maid = require(ReplicatedStorage.Util.Maid)
local Sound = require(ReplicatedStorage.Util.Sound)
require(ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Config = require(script.Config)
local TreasureMapGui = require(script.TreasureMapGui)
local treasureMapAssets = script:WaitForChild("TreasureMapAssets")
local scroll = treasureMapAssets:WaitForChild("scroll")
local dirtmound = treasureMapAssets:WaitForChild("dirt mound")
local brokenMapAssets = script:WaitForChild("BrokenMapAssets")

local function requireMapPieceTemplate(childName: string)
	local part = assert(
		brokenMapAssets:WaitForChild(childName, 10),
		(`Broken map template "{childName}" is unavailable`)
	)
	assert(part:IsA("BasePart"), (`Broken map template "{childName}" is not a BasePart`))
	return part
end

local part = assert(brokenMapAssets:WaitForChild("Map", 10), "Broken map template \"Map\" is unavailable")
assert(part:IsA("BasePart"), "Broken map template \"Map\" is not a BasePart")
local part2 = assert(brokenMapAssets:WaitForChild("Map.001", 10), "Broken map template \"Map.001\" is unavailable")
assert(part2:IsA("BasePart"), "Broken map template \"Map.001\" is not a BasePart")
local part3 = assert(brokenMapAssets:WaitForChild("Map.002", 10), "Broken map template \"Map.002\" is unavailable")
assert(part3:IsA("BasePart"), "Broken map template \"Map.002\" is not a BasePart")
local part4 = assert(brokenMapAssets:WaitForChild("Map.003", 10), "Broken map template \"Map.003\" is unavailable")
assert(part4:IsA("BasePart"), "Broken map template \"Map.003\" is not a BasePart")
local frozen = table.freeze({
	part,
	part2,
	part3,
	part4
})
local localPlayer = Players.LocalPlayer
local v = {}

function v.getState(maid)
	local _xMarksTheSpotState = maid.MiscData._xMarksTheSpotState

	if _xMarksTheSpotState then
		return _xMarksTheSpotState
	end

	local mapGui = TreasureMapGui.new()
	local toolMaid = Maid.new()
	local xMarksTheSpotState = {
		maid = Maid.new(),
		toolMaid = toolMaid,
		mapGui = mapGui,
		mapTool = nil,
		completed = maid.Completed,
		stage = "Tree",
		hits = 0,
		checkpointIndex = 0,
		pickupCFrame = nil,
		mapPieceCFrame = nil,
		targetCFrame = nil,
		pickupModel = nil,
		pickupPrompt = nil,
		dropToken = 0,
		mapPieceModel = nil,
		xVisual = nil,
		xVisualFinalPivot = nil
	}
	maid.MiscData._xMarksTheSpotState = xMarksTheSpotState
	maid:GiveTask(xMarksTheSpotState.maid)
	xMarksTheSpotState.maid:GiveTask(toolMaid)
	xMarksTheSpotState.maid:GiveTask(mapGui)
	xMarksTheSpotState.maid:GiveTask(function()
		v.destroyPickup(xMarksTheSpotState)
		v.destroyMapPiece(xMarksTheSpotState)
		v.destroyXVisual(xMarksTheSpotState)
	end)
	return xMarksTheSpotState
end

function v.getContainers()
	local v2 = {}
	local backpack = localPlayer:FindFirstChildOfClass("Backpack")

	if backpack then
		table.insert(v2, backpack)
	end

	if localPlayer.Character then
		table.insert(v2, localPlayer.Character)
	end

	return v2
end

function v.findMap()
	for _, v2 in v.getContainers() do
		for _, tool in v2:GetChildren() do
			if tool:IsA("Tool") and tool:HasTag(Config.ITEM_TAG) and tool:GetAttribute(Config.ITEM_ATTRIBUTE) == Config.MAP_ITEM_TYPE then
				return tool
			end
		end
	end

	return nil
end

function v:bindMapTool(mapTool)
	if self.mapTool == mapTool then
		return
	end

	self.toolMaid:DoCleaning()
	self.mapGui:close()
	self.mapTool = mapTool

	if not mapTool then
		return
	end

	self.toolMaid:GiveTask(mapTool.Equipped:Connect(function()
		if not self.completed and (self.stage == "Map" or self.stage == "Dig") then
			self.mapGui:open()
		end
	end))
	self.toolMaid:GiveTask(mapTool.Unequipped:Connect(function()
		self.mapGui:close()
	end))
	self.toolMaid:GiveTask(mapTool.AncestryChanged:Connect(function()
		if mapTool.Parent ~= localPlayer.Character then
			self.mapGui:close()
		end
	end))

	if mapTool.Parent == localPlayer.Character and (self.stage == "Map" or self.stage == "Dig") then
		self.mapGui:open()
	end
end

function v:destroyPickup()
	local pickupModel = self.pickupModel
	self.pickupModel = nil
	self.pickupPrompt = nil
	self.dropToken += 1

	if pickupModel then
		pickupModel:Destroy()
	end
end

function v.prepareWorldVisual(folder)
	for _, part5 in folder:GetDescendants() do
		if not part5:IsA("BasePart") then
			continue
		end

		part5.Anchored = true
		part5.CanCollide = false
		part5.CanQuery = false
		part5.CanTouch = false
	end
end

function v.placeModelOnSurface(instance, cframe: CFrame, cframe2: CFrame)
	instance:PivotTo(cframe * cframe2)
	local boundingBox, v2 = instance:GetBoundingBox()
	local v3 = v2 * 0.5
	local upVector = cframe.UpVector
	local v4 = math.abs((upVector:Dot(boundingBox.RightVector))) * v3.X + math.abs((upVector:Dot(boundingBox.UpVector))) * v3.Y + math.abs((upVector:Dot(boundingBox.LookVector))) * v3.Z
	local v5 = upVector * (0.01 - (upVector:Dot(boundingBox.Position - cframe.Position) - v4))
	instance:PivotTo(CFrame.new(v5) * instance:GetPivot())
end

function v.createPickup(object, state)
	if state.pickupModel or state.completed or state.stage ~= "Pickup" or not state.pickupCFrame then
		return
	end

	local clone = scroll:Clone()
	clone.Name = Config.MAP_TOOL_NAME
	v.prepareWorldVisual(clone)
	local v2 = state.pickupCFrame * CFrame.new(0, -Config.PICKUP_SURFACE_OFFSET, 0)
	v.placeModelOnSurface(clone, v2, CFrame.Angles(1.5707963267948966, 0, 0))
	local basePart = clone:FindFirstChildWhichIsA("BasePart", true)

	if not basePart then
		clone:Destroy()
		return
	end

	local boundingBox = clone:GetBoundingBox()
	local attachment = Instance.new("Attachment")
	attachment.Name = "PromptAttachment"
	attachment.CFrame = basePart.CFrame:ToObjectSpace(boundingBox)
	attachment.Parent = basePart
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Pick Up"
	proximityPrompt.ObjectText = Config.MAP_TOOL_NAME
	proximityPrompt.MaxActivationDistance = Config.PICKUP_RANGE
	proximityPrompt.HoldDuration = 0.4
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = attachment
	proximityPrompt.Triggered:Connect(function()
		if state.completed or state.stage ~= "Pickup" then
			return
		end

		proximityPrompt.Enabled = false
		object:FireServer("PickupMap")
		task.delay(1, function()
			if proximityPrompt.Parent and not state.completed and state.stage == "Pickup" then
				proximityPrompt.Enabled = true
			end
		end)
	end)
	clone.Parent = workspace
	state.pickupModel = clone
	state.pickupPrompt = proximityPrompt
end

function v.animatePickupDrop(data, cframe: CFrame)
	local pickupModel = data.pickupModel
	local pickupPrompt = data.pickupPrompt

	if not pickupModel then
		return
	end

	local pivot = pickupModel:GetPivot()
	local dropToken = data.dropToken
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Name = "MapDrop"
	cFrameValue.Value = CFrame.new(cframe.Position) * Config.MAP_DROP_TUMBLE * pivot.Rotation
	cFrameValue.Parent = pickupModel
	pickupModel:PivotTo(cFrameValue.Value)

	if pickupPrompt then
		pickupPrompt.Enabled = false
	end

	local function isCurrent()
		return data.dropToken == dropToken and data.pickupModel == pickupModel and pickupModel.Parent ~= nil
	end

	cFrameValue.Changed:Connect(function(cframe2: CFrame)
		local v2

		if data.dropToken == dropToken and data.pickupModel == pickupModel then
			v2 = pickupModel.Parent ~= nil
		else
			v2 = false
		end

		if v2 then
			pickupModel:PivotTo(cframe2)
		end
	end)
	local tween = TweenService:Create(
		cFrameValue,
		TweenInfo.new(Config.MAP_DROP_FALL_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Value = pivot
		}
	)
	tween.Completed:Connect(function()
		local v2

		if data.dropToken == dropToken and data.pickupModel == pickupModel then
			v2 = pickupModel.Parent ~= nil
		else
			v2 = false
		end

		if not v2 then
			return
		end

		cFrameValue:Destroy()
		pickupModel:PivotTo(pivot)

		if pickupPrompt then
			pickupPrompt.Enabled = true
		end
	end)
	tween:Play()
end

function v:destroyMapPiece()
	local mapPieceModel = self.mapPieceModel
	self.mapPieceModel = nil

	if mapPieceModel then
		mapPieceModel:Destroy()
	end
end

function v.getMapPieceTemplate(p: number)
	local v2 = p - 1

	if v2 < 0 or #Config.CHECKPOINTS - 1 <= v2 then
		return nil
	end

	return frozen[v2 % #frozen + 1]
end

function v.createMapPiece(object, state)
	local mapPieceCFrame = state.mapPieceCFrame
	local v2 = state.checkpointIndex + 1

	if state.mapPieceModel and not state.mapPieceModel.Parent then
		state.mapPieceModel = nil
	end

	if state.mapPieceModel or state.completed or state.stage ~= "Map" or not mapPieceCFrame then
		return
	end

	local mapPieceTemplate = v.getMapPieceTemplate(v2)

	if not mapPieceTemplate then
		return
	end

	local model = Instance.new("Model")
	model.Name = Config.MAP_PIECE_NAME
	local clone = mapPieceTemplate:Clone()
	clone.PivotOffset = CFrame.identity
	clone.Parent = model
	model.PrimaryPart = clone
	v.prepareWorldVisual(model)
	v.placeModelOnSurface(model, mapPieceCFrame, Config.MAP_PIECE_ROTATION)
	local boundingBox = model:GetBoundingBox()
	local attachment = Instance.new("Attachment")
	attachment.Name = "PromptAttachment"
	attachment.CFrame = clone.CFrame:ToObjectSpace(boundingBox)
	attachment.Parent = clone
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Pick Up"
	proximityPrompt.ObjectText = Config.MAP_PIECE_NAME
	proximityPrompt.MaxActivationDistance = Config.MAP_PIECE_RANGE
	proximityPrompt.HoldDuration = Config.MAP_PIECE_HOLD_DURATION
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = attachment
	proximityPrompt.Triggered:Connect(function()
		if state.completed or state.stage ~= "Map" or state.mapPieceModel ~= model or state.checkpointIndex + 1 ~= v2 then
			return
		end

		proximityPrompt.Enabled = false
		object:FireServer("CollectCheckpoint")
		task.delay(1, function()
			if proximityPrompt.Parent and not state.completed and state.stage == "Map" and state.checkpointIndex + 1 == v2 then
				proximityPrompt.Enabled = true
			end
		end)
	end)
	model.Parent = workspace
	state.mapPieceModel = model
end

function v:destroyXVisual()
	local xVisual = self.xVisual
	self.xVisual = nil
	self.xVisualFinalPivot = nil

	if xVisual then
		xVisual:Destroy()
	end
end

function v.updateXVisualProgress(data)
	local xVisual = data.xVisual
	local xVisualFinalPivot = data.xVisualFinalPivot
	local targetCFrame = data.targetCFrame

	if xVisual and xVisualFinalPivot and targetCFrame then
		local v2 = (1 - math.clamp(data.hits / Config.REQUIRED_HITS, 0, 1)) * 1.2
		xVisual:PivotTo(CFrame.new(-targetCFrame.UpVector * v2) * xVisualFinalPivot)
	end
end

function v:createXVisual()
	local targetCFrame = self.targetCFrame

	if self.xVisual or not targetCFrame then
		return
	end

	local clone = dirtmound:Clone()
	clone.Name = "XMarksTheSpotVisual"
	v.prepareWorldVisual(clone)
	local v2 = targetCFrame * CFrame.new(0, -Config.TARGET_SIZE.Y * 0.5, 0)
	v.placeModelOnSurface(clone, v2, CFrame.identity)
	clone.Parent = workspace
	self.xVisual = clone
	self.xVisualFinalPivot = clone:GetPivot()
	v.updateXVisualProgress(self)
end

function v.refresh(p, data)
	if data.completed then
		v.bindMapTool(data, nil)
		v.destroyPickup(data)
		v.destroyMapPiece(data)
		v.destroyXVisual(data)
		data.mapGui:close()
	else
		if data.stage == "Pickup" then
			v.createPickup(p, data)
		else
			v.destroyPickup(data)
		end

		local map = v.findMap()
		v.bindMapTool(data, map)

		if data.stage == "Map" and map and data.mapPieceCFrame then
			v.createMapPiece(p, data)
		else
			v.destroyMapPiece(data)
		end

		if data.stage == "Dig" and map and data.targetCFrame then
			v.createXVisual(data)
		else
			v.destroyXVisual(data)
		end

		if data.stage ~= "Map" and data.stage ~= "Dig" then
			data.mapGui:close()
		end
	end
end

function v.isStage(p)
	return p == "Tree" or p == "Pickup" or p == "Map" or p == "Dig" or p == "Chest" or p == "Enemies" or p == "Completing"
end

function v:concealForeignChestInstance()
	if self:IsA("BasePart") then
		self.LocalTransparencyModifier = 1
	elseif self:IsA("ProximityPrompt") then
		self.Enabled = false
	end
end

function v.hideForeignChest(model, maid)
	if not model:IsA("Model") or model.Name ~= Config.CHEST_NAME or model:GetAttribute(Config.TARGET_OWNER_ATTRIBUTE) == localPlayer.UserId then
		return
	end

	for _, descendant in model:GetDescendants() do
		v.concealForeignChestInstance(descendant)
	end

	maid:GiveTask(model.DescendantAdded:Connect(v.concealForeignChestInstance))
end

function v.watchForeignChests(p)
	local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")

	if not _WorldOrigin then
		return
	end

	for _, child in _WorldOrigin:GetChildren() do
		v.hideForeignChest(child, p.maid)
	end

	p.maid:GiveTask(_WorldOrigin.ChildAdded:Connect(function(child)
		v.hideForeignChest(child, p.maid)
	end))
end

local XMarksTheSpot = {}
XMarksTheSpot.DataName = script.Name
XMarksTheSpot.Repeatable = false

function XMarksTheSpot.OnLoad(object)
	local state = v.getState(object)
	v.watchForeignChests(state)

	if state.completed then
		return
	end

	state.maid:GiveTask(task.spawn(function()
		while not state.completed do
			v.refresh(object, state)
			task.wait(0.15)
		end
	end))
	object:FireServer("Initialize")
end

XMarksTheSpot.RemoteEvents = {
	Setup = function(p, pickupCFrame)
		local state = v.getState(p)

		if typeof(pickupCFrame) ~= "CFrame" then
			pickupCFrame = nil
		end

		state.pickupCFrame = pickupCFrame
		v.refresh(p, state)
	end,
	State = function(p, stage, targetCFrame, value, value2, mapPieceCFrame)
		if not v.isStage(stage) then
			return
		end

		local state = v.getState(p)

		if typeof(targetCFrame) ~= "CFrame" then
			targetCFrame = nil
		end

		local hits = typeof(value) ~= "number" and 0 or math.clamp(math.floor(value), 0, Config.REQUIRED_HITS)
		local checkpointIndex = typeof(value2) ~= "number" and 0 or math.clamp(
			math.floor(value2),
			0,
			#Config.CHECKPOINTS
		)

		if typeof(mapPieceCFrame) ~= "CFrame" then
			mapPieceCFrame = nil
		end

		local v4

		if state.stage == "Dig" and stage == "Dig" and state.targetCFrame == targetCFrame then
			v4 = state.hits < hits
		else
			v4 = false
		end

		local v5 = state.checkpointIndex < checkpointIndex
		local mapPieceCFrame2 = state.mapPieceCFrame

		if state.targetCFrame ~= targetCFrame then
			v.destroyXVisual(state)
		end

		if state.checkpointIndex ~= checkpointIndex or state.mapPieceCFrame ~= mapPieceCFrame then
			v.destroyMapPiece(state)
		end

		state.stage = stage
		state.targetCFrame = targetCFrame
		state.mapPieceCFrame = mapPieceCFrame
		state.hits = hits
		state.checkpointIndex = checkpointIndex
		state.mapGui:setProgress(checkpointIndex)
		v.refresh(p, state)
		v.updateXVisualProgress(state)

		if v4 and targetCFrame then
			Sound:Play(Config.DIG_SOUNDS[math.random(#Config.DIG_SOUNDS)], targetCFrame.Position, {
				radius = 5
			})
		end

		if v5 and mapPieceCFrame2 then
			Sound:Play(Config.PIECE_PICKUP_SOUND, mapPieceCFrame2.Position)
		end
	end,
	MapDropped = function(p, p2, pickupCFrame)
		if typeof(p2) ~= "CFrame" or typeof(pickupCFrame) ~= "CFrame" then
			return
		end

		local state = v.getState(p)

		if state.completed then
			return
		end

		state.pickupCFrame = pickupCFrame
		state.stage = "Pickup"
		v.destroyPickup(state)
		v.createPickup(p, state)
		v.animatePickupDrop(state, p2)
		Sound:Play(Config.MAP_FALL_SOUND, p2.Position)
	end,
	ChestOpened = function(_, cFrame)
		if typeof(cFrame) == "CFrame" then
			Effect.new("Chests.Despawn"):play({
				CFrame = cFrame
			})
		end
	end
}

function XMarksTheSpot.OnComplete(p, flag: boolean)
	local state = v.getState(p)
	state.completed = p.Completed or flag
	state.stage = state.completed and "Completing" or "Tree"
	v.bindMapTool(state, nil)
	v.destroyPickup(state)
	v.destroyMapPiece(state)
	v.destroyXVisual(state)
	state.mapGui:close()
end

return XMarksTheSpot