local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local AreaEggs = require(ReplicatedStorage.Shared.Types.AreaEggs)
local AssetRoster = require(ReplicatedStorage.Client.AssetRoster)
local Assets = require(ReplicatedStorage.Data.Assets)
local v = nil
local EggState = require(ReplicatedStorage.Client.EggState)
local Signal = require(ReplicatedStorage.Packages.Signal)
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
local Player = require(ReplicatedStorage.Shared.Player)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local Save = require(ReplicatedStorage.Shared.Save)
local Trove = require(ReplicatedStorage.Packages.Trove)
local MilestoneAdapter = {}
MilestoneAdapter.__index = MilestoneAdapter
MilestoneAdapter.__class = "MilestoneAdapter"
local localPlayer = Players.LocalPlayer
local v2 = nil

local function getBackpackController(object)
	if v2 == nil and not object._backpackRequested then
		object._backpackRequested = true
		task.spawn(function()
			local Main = require(ReplicatedStorage.Controllers.GUI.BackpackController.Main)

			if object._destroyed then
				return
			end

			v2 = Main
			object:_fireChanged()
		end)
	end

	return v2
end

local world = Workspace.World
assert(world:IsA("Folder"), "Workspace.World must be a Folder")
local areas = world.Areas
assert(areas:IsA("Folder"), "Workspace.World.Areas must be a Folder")
local separationLine = areas.SeparationLine
assert(separationLine:IsA("BasePart"), "Workspace.World.Areas.SeparationLine must be a BasePart")

function MilestoneAdapter.new()
	local self = setmetatable({}, MilestoneAdapter)
	self.Changed = Signal.new()
	self._areaEggCarryState = EggState.ReadCarryState()
	self._destroyed = false
	self._backpackRequested = false
	self._hatchedEgg = false
	self._hadPlacedPet = false
	self._knownEggCount = nil
	self._treadmillIntroFinished = false
	self._trove = Trove.new()
	self:_bindObservers()
	return self
end

function MilestoneAdapter:_fireChanged()
	self.Changed:Fire()
end

function MilestoneAdapter:_getSaveData()
	return Save.Peek()
end

function MilestoneAdapter:_getEquippedTool(p: string)
	local character = localPlayer.Character

	if character == nil then
		return nil
	end

	for _, tool in ipairs(character:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute("ItemType") == p then
			return tool
		end
	end

	return nil
end

local function countUnplacedEggs(p)
	if p == nil then
		return 0
	end

	local count = 0

	for _, v3 in pairs(p.EggInventory) do
		if v3.Placement == nil then
			count += 1
		end
	end

	return count
end

local function getPlacedEggCount(p)
	if p == nil then
		return 0
	end

	local count = 0

	for _, v3 in pairs(p.EggInventory) do
		if v3.Placement ~= nil then
			count += 1
		end
	end

	return count
end

local function getTotalEggCount(p)
	if p == nil then
		return 0
	end

	local count = 0

	for _ in pairs(p.EggInventory) do
		count += 1
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEggGrowthTime(assetCategory: string)
	local v3 = Assets.Directory[assetCategory]
	assert(v3 ~= nil, (`Missing asset config for {assetCategory}`))
	return v3.Egg.GrowthTime
end

function MilestoneAdapter:_getLowestHatchTimeEggUid()
	local _getSaveData = self:_getSaveData()

	if _getSaveData == nil then
		return nil
	end

	local v3 = 1e999
	local v4 = nil

	for k, v5 in pairs(_getSaveData.EggInventory) do
		if v5.Placement ~= nil then
			continue
		end

		local eggGrowthTime = getEggGrowthTime(v5.AssetCategory) -- equivalent call inferred; original call site unknown

		if not (eggGrowthTime < v3) then
			continue
		end

		v4 = k
		v3 = eggGrowthTime
	end

	return v4
end

function MilestoneAdapter:_bindCharacterTools(instance)
	if instance == nil then
		return
	end

	self._trove:Connect(instance.ChildAdded, function(tool)
		if tool:IsA("Tool") then
			self:_fireChanged()
		end
	end)
	self._trove:Connect(instance.ChildRemoved, function(tool)
		if tool:IsA("Tool") then
			self:_fireChanged()
		end
	end)
end

function MilestoneAdapter:_bindObservers()
	local function refreshEggCount()
		local _getSaveData = self:_getSaveData()

		if _getSaveData == nil or self._destroyed then
			return
		end

		local count

		if _getSaveData == nil then
			count = 0
		else
			count = 0

			for _ in pairs(_getSaveData.EggInventory) do
				count += 1
			end
		end

		if self._knownEggCount ~= nil and count < self._knownEggCount then
			self._hatchedEgg = true
		end

		self._knownEggCount = count
		self:_fireChanged()
	end

	self._trove:Add(Save.Loaded:Connect(refreshEggCount))
	self._trove:Add(Save.Watch("EggInventory"):Connect(refreshEggCount))
	local _getSaveData = self:_getSaveData()

	if _getSaveData ~= nil and not self._destroyed then
		local count

		if _getSaveData == nil then
			count = 0
		else
			count = 0

			for _ in pairs(_getSaveData.EggInventory) do
				count += 1
			end
		end

		if self._knownEggCount ~= nil and count < self._knownEggCount then
			self._hatchedEgg = true
		end

		self._knownEggCount = count
		self:_fireChanged()
	end

	self._trove:Add(Save.Watch("Inventory"):Connect(function()
		self:_fireChanged()
	end))
	self._trove:Add(Save.Watch("Money"):Connect(function()
		self:_fireChanged()
	end))
	self._trove:Add(Save.Watch("BaseUpgradeLevel"):Connect(function()
		self:_fireChanged()
	end))
	self._trove:Add(PlotState.LocalPlotChanged:Connect(function()
		self:_fireChanged()
	end))
	self._trove:Add(AssetRoster.SnapshotRefreshed:Connect(function()
		local hadPlacedPet = next(AssetRoster.ReadOwnerPen(localPlayer.UserId)) ~= nil

		if hadPlacedPet == self._hadPlacedPet then
			return
		end

		self._hadPlacedPet = hadPlacedPet
		self:_fireChanged()
	end))
	task.spawn(function()
		local BaseUpgrade = require(ReplicatedStorage.Client.BaseUpgrade)

		if self._destroyed then
			return
		end

		v = BaseUpgrade
		local transition = BaseUpgrade.Transition
		self._trove:Add(transition.Completed:Connect(function()
			self:_fireChanged()
		end))
		self:_fireChanged()
	end)
	task.spawn(function()
		local PlacedEggRenderer = require(ReplicatedStorage.Shared.Eggs.PlacedEggRenderer)

		if self._destroyed then
			return
		end

		self._trove:Add(PlacedEggRenderer.LocalEggHatchStarted:Connect(function()
			self._hatchedEgg = true
			self:_fireChanged()
		end))
	end)
	self._trove:Add(EggState.OwnerRefreshed:Connect(function(p: number)
		if p == localPlayer.UserId then
			self:_fireChanged()
		end
	end))
	self._trove:Add(EggState.CarryChanged:Connect(function(areaEggCarryState)
		self._areaEggCarryState = areaEggCarryState
		self:_fireChanged()
	end))
	self._trove:Add(EggState.FieldRefreshed:Connect(function()
		self:_fireChanged()
	end))
	self._trove:Add(EggState.FieldShifted:Connect(function()
		self:_fireChanged()
	end))
	self._trove:Add(EggState.FieldGone:Connect(function()
		self:_fireChanged()
	end))
	local v3 = nil

	local function bindBackpack(backpack)
		if not backpack:IsA("Backpack") or backpack == v3 or self._destroyed then
			return
		end

		v3 = backpack
		self._trove:Connect(backpack.ChildAdded, function()
			self:_fireChanged()
		end)
		self._trove:Connect(backpack.ChildRemoved, function()
			self:_fireChanged()
		end)
		self:_fireChanged()
	end

	self._trove:Connect(localPlayer.ChildAdded, bindBackpack)
	local backpack = localPlayer:FindFirstChildOfClass("Backpack")

	if backpack then
		bindBackpack(backpack)
	end

	self._trove:Connect(localPlayer.CharacterAdded, function(p)
		self:_bindCharacterTools(p)
		self:_fireChanged()
	end)
	self:_bindCharacterTools(localPlayer.Character)
	self._hadPlacedPet = next(AssetRoster.ReadOwnerPen(localPlayer.UserId)) ~= nil
end

function MilestoneAdapter:HasStolenFirstEgg()
	local v3 = true
	local _getSaveData = self:_getSaveData()
	local count

	if _getSaveData == nil then
		count = 0
	else
		count = 0

		for _, v4 in pairs(_getSaveData.EggInventory) do
			if v4.Placement == nil then
				count += 1
			end
		end
	end

	if count > 0 then
		return true
	end

	local _getSaveData2 = self:_getSaveData()
	local count2

	if _getSaveData2 == nil then
		count2 = 0
	else
		count2 = 0

		for _, v4 in pairs(_getSaveData2.EggInventory) do
			if v4.Placement ~= nil then
				count2 += 1
			end
		end
	end

	return count2 > 0
end

function MilestoneAdapter:IsCarryingAreaEgg()
	local _areaEggCarryState = self._areaEggCarryState
	return _areaEggCarryState ~= nil and _areaEggCarryState.IsCarrying
end

function MilestoneAdapter.HasReturnedToPen(_)
	local rootPart = Player.FindRootPart()
	local plot = PlotState.ResolvePlot()

	if rootPart == nil or plot == nil then
		return false
	end

	if PlotState.ContainsLocalPoint(rootPart.Position) then
		return true
	end

	local petArea = plot.PetArea
	local pointToObjectSpace = petArea.CFrame:PointToObjectSpace(rootPart.Position)
	local v3 = petArea.Size * 0.5
	local vector2 = Vector3.new(
		math.clamp(pointToObjectSpace.X, -v3.X, v3.X),
		math.clamp(pointToObjectSpace.Y, -v3.Y, v3.Y),
		(math.clamp(pointToObjectSpace.Z, -v3.Z, v3.Z))
	)
	local pointToWorldSpace = petArea.CFrame:PointToWorldSpace(vector2)
	return (rootPart.Position - pointToWorldSpace).Magnitude <= 18
end

function MilestoneAdapter:HasEquippedEgg()
	return self:_getEquippedTool("AssetEgg") ~= nil
end

function MilestoneAdapter:HasPlacedEgg()
	local _getSaveData = self:_getSaveData()
	local count

	if _getSaveData == nil then
		count = 0
	else
		count = 0

		for _, v3 in pairs(_getSaveData.EggInventory) do
			if v3.Placement ~= nil then
				count += 1
			end
		end
	end

	return count > 0
end

function MilestoneAdapter.HasHatchableEgg(_)
	for k in pairs(EggState.ReadOwnerEggs(localPlayer.UserId)) do
		if EggState.IsReadyToHatch(k) then
			return true
		end
	end

	return false
end

function MilestoneAdapter:HasHatchedEgg()
	return self._hatchedEgg
end

function MilestoneAdapter:HasPlacedPet()
	return self._hadPlacedPet
end

function MilestoneAdapter:HasPetInInventory()
	if self:_getEquippedTool("Asset") ~= nil then
		return true
	end

	local _getSaveData = self:_getSaveData()
	return _getSaveData ~= nil and next(_getSaveData.Inventory) ~= nil
end

function MilestoneAdapter.IsLocalPlayerInGameplay(_)
	local rootPart = Player.FindRootPart()
	return rootPart ~= nil and GuardAreaGeometry.IsPastLine(separationLine, rootPart.Position)
end

function MilestoneAdapter.GetClosestAreaEggTarget(_)
	local rootPart = Player.FindRootPart()
	local v3 = not rootPart and createVector(0, 0, 0) or rootPart.Position
	local v4 = 1e999
	local position = nil

	for _, record in ipairs(EggState.ReadFieldEggs().Records) do
		if not (record.State == AreaEggs.States.Slot and string.find(record.Uid, "FirstAreaEgg_", 1, true) == 1) then
			continue
		end

		local magnitude = (record.BottomCFrame.Position - v3).Magnitude

		if not (magnitude < v4) then
			continue
		end

		position = record.BottomCFrame.Position
		v4 = magnitude
	end

	return position
end

function MilestoneAdapter.GetGameplayExitTarget(_)
	local v3 = separationLine.Position + createVector(0, 3, 0) - separationLine.CFrame.LookVector.Unit * 1
	local rootPart = Player.FindRootPart()

	if rootPart == nil then
		return v3
	end

	return (Vector3.new(v3.X, v3.Y, rootPart.Position.Z))
end

function MilestoneAdapter.GetGameplayEntryTarget(_)
	return separationLine.Position + createVector(0, 3, 0) + separationLine.CFrame.LookVector.Unit * 1
end

function MilestoneAdapter.GetPlotSpawnTarget(_)
	local plot = PlotState.ResolvePlot()

	if plot == nil then
		return nil
	end

	local respawnPointCFrame = plot.RespawnPointCFrame

	if respawnPointCFrame then
		return respawnPointCFrame.Position
	end

	return plot.CenterPoint.Position
end

function MilestoneAdapter.GetEggPlacementBillboardCFrame(_)
	local plot = PlotState.ResolvePlot()
	local rootPart = Player.FindRootPart()

	if plot == nil or rootPart == nil or plot.RespawnPointCFrame == nil then
		return nil
	end

	local petArea = plot.PetArea
	local respawnPointCFrame = plot.RespawnPointCFrame
	local pointToObjectSpace = petArea.CFrame:PointToObjectSpace(rootPart.Position)
	local v3 = petArea.Size * 0.5
	local vector2 = Vector3.new(
		math.clamp(pointToObjectSpace.X, -v3.X, v3.X),
		v3.Y,
		(math.clamp(pointToObjectSpace.Z, -v3.Z, v3.Z))
	)
	local pointToWorldSpace = petArea.CFrame:PointToWorldSpace(vector2)
	local v4 = respawnPointCFrame + respawnPointCFrame.LookVector * 13
	return CFrame.new(v4.Position.X, pointToWorldSpace.Y, v4.Position.Z)
end

function MilestoneAdapter.GetNearestHatchableEggTarget(_)
	local rootPart = Player.FindRootPart()
	local v3 = not rootPart and createVector(0, 0, 0) or rootPart.Position
	local v4 = 1e999
	local v5 = nil

	for k, v6 in pairs(EggState.ReadOwnerEggs(localPlayer.UserId)) do
		if not (v6.Placement ~= nil and EggState.IsReadyToHatch(k)) then
			continue
		end

		local plot = PlotState.ResolvePlot()

		if plot == nil then
			continue
		end

		local position = (plot.CenterPoint.CFrame * v6.Placement.LocalCFrame).Position
		local magnitude = (position - v3).Magnitude

		if not (magnitude < v4) then
			continue
		end

		v5 = position
		v4 = magnitude
	end

	return v5
end

function MilestoneAdapter:GetEggHotbarTarget()
	local _getLowestHatchTimeEggUid = self:_getLowestHatchTimeEggUid()
	local v3

	if _getLowestHatchTimeEggUid then
		if v2 == nil and not self._backpackRequested then
			self._backpackRequested = true
			task.spawn(function()
				local Main = require(ReplicatedStorage.Controllers.GUI.BackpackController.Main)

				if self._destroyed then
					return
				end

				v2 = Main
				self:_fireChanged()
			end)
		end

		v3 = v2
	end

	if v3 then
		return (v3:GetEggSlotFrame(_getLowestHatchTimeEggUid))
	end

	return nil
end

function MilestoneAdapter:ForceBestEggIntoHotbar()
	local _getLowestHatchTimeEggUid = self:_getLowestHatchTimeEggUid()
	local v3

	if _getLowestHatchTimeEggUid then
		if v2 == nil and not self._backpackRequested then
			self._backpackRequested = true
			task.spawn(function()
				local Main = require(ReplicatedStorage.Controllers.GUI.BackpackController.Main)

				if self._destroyed then
					return
				end

				v2 = Main
				self:_fireChanged()
			end)
		end

		v3 = v2
	end

	if v3 then
		return (v3:ForceEggIntoTutorialHotbar(_getLowestHatchTimeEggUid))
	end

	return nil
end

function MilestoneAdapter:HasPetToolEquipped()
	return self:_getEquippedTool("Asset") ~= nil
end

function MilestoneAdapter:CanAffordFirstBaseExpansion()
	local _getSaveData = self:_getSaveData()
	return _getSaveData ~= nil and v ~= nil and _getSaveData.BaseUpgradeLevel == 0 and v.IsNextTierAffordable(_getSaveData)
end

function MilestoneAdapter:HasFinishedFirstBaseExpansion()
	local _getSaveData = self:_getSaveData()
	return _getSaveData ~= nil and _getSaveData.BaseUpgradeLevel > 0 and v ~= nil and not v.Transition.IsPlaying()
end

function MilestoneAdapter.GetPlotUpgradeSignTarget(_)
	local plot = PlotState.ResolvePlot()

	if plot == nil then
		return nil
	end

	local plotUpgrade = plot.PlotFolder:FindFirstChild("PlotUpgrade")

	if plotUpgrade == nil or not plotUpgrade:IsA("Model") then
		return nil
	end

	local sign = plotUpgrade:FindFirstChild("Sign")

	if sign == nil or not sign:IsA("BasePart") then
		return nil
	end

	return sign
end

function MilestoneAdapter:HasFinishedTreadmillIntro()
	return self._treadmillIntroFinished
end

function MilestoneAdapter:MarkTreadmillIntroFinished()
	if self._treadmillIntroFinished then
		return
	end

	self._treadmillIntroFinished = true
	self:_fireChanged()
end

function MilestoneAdapter:Destroy()
	self._destroyed = true
	self._trove:Destroy()
	self.Changed:Destroy()
end

return MilestoneAdapter