local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local AreaEggSlotIdentity = require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity)
local AreaEggs = require(ReplicatedStorage.Shared.Types.AreaEggs)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
local t = require(ReplicatedStorage.Packages.t)
require(ReplicatedStorage.Shared.Globals.Constants)
local EggState = require(ReplicatedStorage.Client.EggState)
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
require(ReplicatedStorage.Shared.Types.GuardAreas)
local Guards = require(ReplicatedStorage.Data.Guards)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GuardComponent = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardComponent)
require(ReplicatedStorage.Shared.Modules.GuardAreas.Types.Interface)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ForestGuardRuntime = {}
ForestGuardRuntime.__index = ForestGuardRuntime
ForestGuardRuntime.__class = "ForestGuardRuntime"
local states = AreaEggs.States
local localPlayer = Players.LocalPlayer

local function suppressGuardVisuals(folder)
	local v = {}
	local v2 = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			v[descendant] = {
				CanCollide = descendant.CanCollide,
				CanQuery = descendant.CanQuery,
				CanTouch = descendant.CanTouch,
				LocalTransparencyModifier = descendant.LocalTransparencyModifier
			}
			descendant.LocalTransparencyModifier = 1
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("BillboardGui") then
			local v3 = descendant
			local enabled = descendant.Enabled
			table.insert(v2, function()
				v3.Enabled = enabled
			end)
			descendant.Enabled = false
		end
	end

	return function()
		for k, v3 in pairs(v) do
			k.LocalTransparencyModifier = v3.LocalTransparencyModifier
			k.CanCollide = v3.CanCollide
			k.CanQuery = v3.CanQuery
			k.CanTouch = v3.CanTouch
		end

		for _, v3 in ipairs(v2) do
			v3()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stageGuardForConstruction(p, parent)
	p.Name = "ForestGuardStaging"
	local v = suppressGuardVisuals(p)
	p.Parent = parent
	return v
end

function ForestGuardRuntime.new(areaModel)
	t.strict(t.instanceIsA("Model"))(areaModel)
	assert(areaModel.Name == "Forest", "ForestGuardRuntime requires area Forest")
	local guard = areaModel.Guard
	local bounds = areaModel.Bounds
	assert(areaModel:IsDescendantOf(Workspace), "Forest area must be in Workspace before guard construction")
	assert(guard.Parent == areaModel, "Forest authored guard must belong to its area before guard construction")
	local clone = guard:Clone()
	local object = setmetatable({}, ForestGuardRuntime)
	object._areaModel = areaModel
	object._authoredGuard = guard
	object._clientEggFolder = nil
	object._droppedModelByUid = {}
	object._droppedTroveByUid = {}
	object._guardModel = clone
	object._hiddenRestore = nil
	object._registeredDroppedUids = {}
	object._registeredStolenUids = {}
	object._trove = Trove.new()
	object._wake = nil
	local v = {
		Attack = function(data)
			if data.Player ~= localPlayer or data.EggUid == nil then
				return
			end

			local v2 = {
				EggUid = data.EggUid,
				GuardCFrame = data.GuardRoot.CFrame
			}
			Remotes.GuardPatrol.ForestStrike:FireServer(v2)
		end,
		ServerOwnsPhysics = false,
		Wake = function(p)
			local _wake = object._wake

			if _wake ~= nil then
				_wake(p)
			end
		end
	}
	local v2 = nil
	local forest = nil
	local v3, v4 = xpcall(function()
		v2 = stageGuardForConstruction(clone, areaModel)
		forest = GuardComponent.new(
			"Forest",
			clone,
			bounds,
			Workspace.World.Areas.Ground,
			Guards.Directory.Forest,
			function(p)
				if p ~= localPlayer then
					return false
				end

				local rootPart = Player.FindRootPart(localPlayer)
				return rootPart ~= nil and GuardAreaGeometry.IsPastLine(
					Workspace.World.Areas.SeparationLine,
					rootPart.Position
				)
			end,
			v
		)
		assert(areaModel:IsDescendantOf(Workspace), "Forest area was removed during guard construction")
		assert(guard.Parent == areaModel, "Forest authored guard was removed during guard construction")
	end, function(p)
		return debug.traceback(tostring(p), 2)
	end)

	if not v3 then
		if forest ~= nil then
			forest:Destroy()
		end

		clone:Destroy()
		object._trove:Destroy()
		error(v4, 0)
	end

	object._component = assert(forest, "Forest shared guard component did not initialize")
	local v5 = assert(v2, "Forest guard staging did not initialize")
	object._trove:Add(clone)
	object._trove:Add(function()
		if guard.Parent ~= nil then
			guard.Name = "Guard"
		end
	end)
	guard.Name = "ForestGuardAuthored"
	clone.Name = "Guard"

	for _, descendant in ipairs(guard:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local v6 = descendant
			local localTransparencyModifier = descendant.LocalTransparencyModifier
			object._trove:Add(function()
				if v6.Parent ~= nil then
					v6.LocalTransparencyModifier = localTransparencyModifier
				end
			end)
			descendant.LocalTransparencyModifier = 1
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("BillboardGui") then
			local v6 = descendant
			local enabled = descendant.Enabled
			object._trove:Add(function()
				if v6.Parent ~= nil then
					v6.Enabled = enabled
				end
			end)
			descendant.Enabled = false
		end
	end

	v5()
	object._trove:Add(guard:GetAttributeChangedSignal("Hidden"):Connect(function()
		object:_applyHidden()
	end))
	object:_applyHidden()
	return object
end

function ForestGuardRuntime:_isOwnedForestRecord(p)
	return p.AreaId == "Forest" and AreaEggSlotIdentity.FirstAreaOwnerUserId(p.Uid) == localPlayer.UserId
end

function ForestGuardRuntime:_clearStolen(p2: string)
	if self._registeredStolenUids[p2] ~= true then
		return
	end

	self._registeredStolenUids[p2] = nil
	self._component:ClearStolenEgg(p2)
end

function ForestGuardRuntime:_registerStolen(p: string, p2: string)
	if self._registeredStolenUids[p] == true then
		return
	end

	for k in pairs(self._registeredStolenUids) do
		self:_clearStolen(k)
	end

	self._registeredStolenUids[p] = true
	self._component:RegisterStolenEgg(localPlayer, p, AssetItems.RarityRankForCategory(p2))
end

function ForestGuardRuntime:_clearDropped(p: string)
	local v = self._droppedTroveByUid[p]

	if v ~= nil then
		self._droppedTroveByUid[p] = nil
		v:Destroy()
	end

	self._droppedModelByUid[p] = nil

	if self._registeredDroppedUids[p] ~= true then
		return
	end

	self._registeredDroppedUids[p] = nil
	self._component:ClearDroppedEgg(p)
end

function ForestGuardRuntime:_tryRegisterDropped(data)
	if self._registeredDroppedUids[data.Uid] == true then
		return
	end

	local _areaModel = self._areaModel

	if not GuardAreaGeometry.IsWithinFootprint(_areaModel.Bounds, data.BoundsCFrame.Position) then
		return
	end

	local _clientEggFolder = self._clientEggFolder

	if _clientEggFolder == nil then
		return
	end

	local model = _clientEggFolder:FindFirstChild(data.Uid)

	if model == nil then
		return
	end

	assert(model:IsA("Model"), (`{_clientEggFolder:GetFullName()}.{data.Uid} must be a Model`))
	local eggSpotBottom = AreaEggSlotIdentity.NestFor(self._areaModel, data.NestId).EggSpotBottom

	if not self._component:RegisterDroppedEgg({
		EggUid = data.Uid,
		Model = model,
		DroppedPosition = data.BottomCFrame.Position,
		NestBottomCFrame = eggSpotBottom.CFrame,
		Priority = AssetItems.RarityRankForCategory(data.AssetCategory)
	}) then
		return
	end

	self._registeredDroppedUids[data.Uid] = true
	self._droppedModelByUid[data.Uid] = model
	local v = Trove.new()
	self._droppedTroveByUid[data.Uid] = v
	v:Connect(model.AncestryChanged, function(_, p)
		if p ~= nil or self._droppedModelByUid[data.Uid] ~= model then
			return
		end

		self:_clearDropped(data.Uid)
		local fieldEgg = EggState.ReadFieldEgg(data.Uid)

		if fieldEgg ~= nil and fieldEgg.State == states.Dropped then
			self:_tryRegisterDropped(fieldEgg)
		end
	end)
end

function ForestGuardRuntime:_syncRecord(data)
	if not self:_isOwnedForestRecord(data) then
		return
	end

	if data.State == states.Carried and data.CarrierUserId == localPlayer.UserId then
		self:_clearDropped(data.Uid)
		self:_registerStolen(data.Uid, data.AssetCategory)
	else
		self:_clearStolen(data.Uid)

		if data.State == states.Dropped then
			self:_tryRegisterDropped(data)
		else
			self:_clearDropped(data.Uid)
		end
	end
end

function ForestGuardRuntime:_syncSnapshot(p)
	local v = {}

	for _, record in ipairs(p.Records) do
		if not self:_isOwnedForestRecord(record) then
			continue
		end

		v[record.Uid] = true
		self:_syncRecord(record)
	end

	for k in pairs(self._registeredStolenUids) do
		if v[k] ~= true then
			self:_clearStolen(k)
		end
	end

	for k in pairs(self._registeredDroppedUids) do
		if v[k] ~= true then
			self:_clearDropped(k)
		end
	end
end

function ForestGuardRuntime:_handleRetrievalEvent(p)
	if p.Kind == "Attached" then
		local v = self._droppedModelByUid[p.EggUid]

		if v ~= nil then
			local carryAreaEgg = v:FindFirstChild("CarryAreaEgg", true)

			if carryAreaEgg ~= nil then
				assert(carryAreaEgg:IsA("ProximityPrompt"), (`{carryAreaEgg:GetFullName()} must be a ProximityPrompt`))
				carryAreaEgg:Destroy()
			end
		end

		local v2 = {
			EggUid = p.EggUid,
			Kind = "Attached"
		}
		Remotes.GuardPatrol.ForestHandoff:FireServer(v2)
	else
		local v = {
			EggUid = p.EggUid,
			Kind = "Deposited"
		}
		self._registeredDroppedUids[p.EggUid] = nil
		self._droppedModelByUid[p.EggUid] = nil
		local v2 = self._droppedTroveByUid[p.EggUid]

		if v2 ~= nil then
			self._droppedTroveByUid[p.EggUid] = nil
			v2:Destroy()
		end

		Remotes.GuardPatrol.ForestHandoff:FireServer(v)
	end
end

function ForestGuardRuntime:_applyHidden()
	local hidden = self._authoredGuard:GetAttribute("Hidden") == true
	self._guardModel:SetAttribute("Hidden", hidden or nil)
	local _hiddenRestore = self._hiddenRestore

	if hidden then
		if _hiddenRestore == nil then
			self._hiddenRestore = suppressGuardVisuals(self._guardModel)
		end
	elseif _hiddenRestore ~= nil then
		self._hiddenRestore = nil
		_hiddenRestore()
	end
end

function ForestGuardRuntime:GetGuardModel()
	return self._guardModel
end

function ForestGuardRuntime:SetWakeHandler(wake)
	t.strict(t.callback)(wake)
	self._wake = wake
end

function ForestGuardRuntime:SetEnabled(flag: boolean)
	t.strict(t.boolean)(flag)
	self._component:SetEnabled(flag)
end

function ForestGuardRuntime:Start()
	self._trove:Add(EggState.FieldRefreshed:Connect(function(p)
		self:_syncSnapshot(p)
	end))
	self._trove:Add(EggState.FieldShifted:Connect(function(p)
		self:_syncRecord(p)
	end))
	self._trove:Add(EggState.FieldGone:Connect(function(p: string)
		self:_clearStolen(p)
		self:_clearDropped(p)
	end))
	self._trove:Add(EggState.CarryChanged:Connect(function(data)
		if data.IsCarrying and data.Uid ~= nil and data.AssetCategory ~= nil and data.AreaId == "Forest" then
			self:_registerStolen(data.Uid, data.AssetCategory)
			return
		end

		for k in pairs(self._registeredStolenUids) do
			self:_clearStolen(k)
		end
	end))
	task.spawn(function()
		local areaEggSlotsClient = Workspace:WaitForChild("AreaEggSlotsClient")
		assert(areaEggSlotsClient:IsA("Folder"), "Workspace.AreaEggSlotsClient must be a Folder")

		if self._guardModel.Parent == nil then
			return
		end

		self._clientEggFolder = areaEggSlotsClient
		self._trove:Connect(areaEggSlotsClient.ChildAdded, function(instance)
			if self._clientEggFolder ~= areaEggSlotsClient or instance.Parent ~= areaEggSlotsClient then
				return
			end

			local fieldEgg = EggState.ReadFieldEgg(instance.Name)

			if fieldEgg ~= nil then
				self:_syncRecord(fieldEgg)
			end
		end)
		self:_syncSnapshot(EggState.ReadFieldEggs())
	end)
	local total = 0
	self._trove:Connect(RunService.Heartbeat, function(p: number)
		total += p

		if total < 0.03 then
			return
		end

		total = 0
		local v = self._component:Step(os.clock())

		if v ~= nil then
			self:_handleRetrievalEvent(v)
		end
	end)
	self:_syncSnapshot(EggState.ReadFieldEggs())
end

function ForestGuardRuntime:Destroy()
	self._clientEggFolder = nil

	for k in pairs(self._registeredDroppedUids) do
		self:_clearDropped(k)
	end

	for _, v in pairs(self._droppedTroveByUid) do
		if v ~= nil then
			v:Destroy()
		end
	end

	self._component:Destroy()
	self._trove:Destroy()
	table.clear(self._registeredDroppedUids)
	table.clear(self._registeredStolenUids)
	table.clear(self._droppedModelByUid)
	table.clear(self._droppedTroveByUid)
end

return ForestGuardRuntime