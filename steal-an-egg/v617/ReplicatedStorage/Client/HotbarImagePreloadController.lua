local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.Shared.Types.AreaEggs)
local Areas = require(ReplicatedStorage.Data.Areas)
local AssetIconShape = require(ReplicatedStorage.Client.UI.AssetIconShape)
local Assets = require(ReplicatedStorage.Data.Assets)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local EggState = require(ReplicatedStorage.Client.EggState)
require(ReplicatedStorage.Shared.Types.Eggs)
local GuardChasePolicy = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardChasePolicy)
local GuardEscape = require(ReplicatedStorage.Shared.Utils.GuardEscape)
local GuardEscapePrediction = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardEscapePrediction)
local Guards = require(ReplicatedStorage.Data.Guards)
local HotbarImagePreloadPolicy = require(ReplicatedStorage.Client.HotbarImagePreloadPolicy)
local ImagePreloader = require(ReplicatedStorage.Client.ImagePreloader)
local Log = require(ReplicatedStorage.Packages.Log)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Player = require(ReplicatedStorage.Shared.Player)
local SpeedPowerProjection = require(ReplicatedStorage.Client.SpeedPowerProjection)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = {
	[10650210095] = true,
	[10737944401] = true
}
local localPlayer = Players.LocalPlayer
local v2 = Log.new()
local areas = Workspace:WaitForChild("World"):WaitForChild("Areas")
local guardAreas = areas:WaitForChild("GuardAreas")
local separationLine = areas:WaitForChild("SeparationLine")
assert(guardAreas:IsA("Folder"), "Workspace.World.Areas.GuardAreas must be a Folder")
assert(separationLine:IsA("BasePart"), "Workspace.World.Areas.SeparationLine must be a BasePart")

local function showDebugNotification(p: string)
	if not v[game.GameId] then
		return
	end

	Toast.Show({
		Text = `[DEBUG]: {p}`,
		Seconds = 1.5,
		Color = Color3.fromRGB(100, 200, 255),
		Unique = true
	})
end

local function getAreaModel(childName: string)
	local model = guardAreas:FindFirstChild(childName)

	if model == nil or not model:IsA("Model") then
		return nil
	end

	return model
end

local function getGuardRoot(instance)
	local guard = instance:FindFirstChild("Guard")

	if guard == nil or not guard:IsA("Model") then
		return nil
	end

	local humanoidRootPart = guard:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return nil
	end

	return humanoidRootPart
end

local function resolveRequiredSpeedPower(instance)
	local guardRoot = getGuardRoot(instance)

	if guardRoot == nil then
		return nil
	end

	local success, result = pcall(function()
		local v3 = Areas.Directory[instance.Name]
		local v4 = Guards.Directory[v3.GuardId]
		local bounds = instance:FindFirstChild("Bounds")
		local closestExitPoint = instance:FindFirstChild("ClosestExitPoint")
		local v5

		if bounds == nil then
			v5 = false
		else
			v5 = bounds:IsA("BasePart")
		end

		assert(v5, (`{instance:GetFullName()}.Bounds must be a BasePart`))
		local v6

		if closestExitPoint == nil then
			v6 = false
		else
			v6 = closestExitPoint:IsA("BasePart")
		end

		assert(v6, (`{instance:GetFullName()}.ClosestExitPoint must be a BasePart`))
		local exitDirection = -separationLine.CFrame.LookVector
		return GuardEscape.RequiredSpeedPower({
			BaseGuardWalkSpeed = v4.WalkSpeed,
			ExitDirection = exitDirection,
			ExitDistance = GuardEscapePrediction.ResolveExitDistance(
				bounds.CFrame,
				bounds.Size,
				closestExitPoint.Position,
				exitDirection
			),
			FlatRadius = v4.FlatRadius,
			GuardStartPosition = guardRoot.Position,
			HitDistance = GuardChasePolicy.ResolveHitDistance(v4.HitDistance),
			PlayerStartPosition = closestExitPoint.Position
		})
	end)

	if success then
		return result
	end

	v2:AtWarning():Log((`Unable to resolve guard escape requirement for {instance.Name}: {result}`))
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheRequiredSpeedPower(p, model)
	local requiredSpeedPower = resolveRequiredSpeedPower(model)

	if requiredSpeedPower ~= nil then
		p.RequiredSpeedPowerByAreaId[model.Name] = requiredSpeedPower
	end
end

local function getRequiredSpeedPower(p, childName: string)
	local v3 = p.RequiredSpeedPowerByAreaId[childName]

	if v3 ~= nil then
		return v3
	end

	local model = guardAreas:FindFirstChild(childName)

	if model == nil or not model:IsA("Model") then
		model = nil
	end

	if model == nil then
		return nil
	end

	cacheRequiredSpeedPower(p, model) -- equivalent call inferred; original call site unknown
	return p.RequiredSpeedPowerByAreaId[childName]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDistanceToClaimLine()
	local part = Player.FindRootPart(localPlayer)

	if part == nil or not part:IsA("BasePart") then
		return nil
	end

	return HotbarImagePreloadPolicy.GetShortestDistanceToClaimLine(separationLine, part.Position)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requestEggIcon(p: string)
	local v3 = Assets.Directory[p]

	if ImagePreloader.Request(v3.Egg.Icon) then
		showDebugNotification(`Preloading image for {v3.DisplayName} egg`)
	end
end

local function requestPetIcons(ownerEgg)
	local assetItemData = EggRecords.ToAssetItemData(ownerEgg)
	local images = AssetIconShape.ResolveImages(assetItemData)
	local rainbowOverlays = { images.Icon }

	if images.RainbowOverlay ~= nil then
		rainbowOverlays[#rainbowOverlays + 1] = images.RainbowOverlay
	end

	if ImagePreloader.RequestAll(rainbowOverlays) > 0 then
		showDebugNotification(`Preloading image for {Assets.Directory[ownerEgg.AssetCategory].DisplayName} pet`)
	end
end

local function scanReadyEggs(state)
	if state.Destroyed then
		return
	end

	local ownerEggs = EggState.ReadOwnerEggs(localPlayer.UserId)

	for k, ownerEgg in ownerEggs do
		if state.ReadyPreloadedByUid[k] or ownerEgg.Placement == nil or not EggState.IsReadyToHatch(k) then
			continue
		end

		state.ReadyPreloadedByUid[k] = true
		requestPetIcons(ownerEgg)
	end

	for k in state.ReadyPreloadedByUid do
		if ownerEggs[k] == nil then
			state.ReadyPreloadedByUid[k] = nil
		end
	end
end

local function handleCarryState(state, data)
	state.CarryGeneration += 1
	state.CarryTrove:Clean()

	if not data.IsCarrying or data.AreaId == nil or data.AssetCategory == nil then
		return
	end

	local carryGeneration = state.CarryGeneration
	local areaId = data.AreaId
	local assetCategory = data.AssetCategory
	local v3 = state.RequiredSpeedPowerByAreaId[areaId]

	if v3 == nil then
		local model = guardAreas:FindFirstChild(areaId)

		if model == nil or not model:IsA("Model") then
			model = nil
		end

		if model == nil then
			v3 = nil
		else
			cacheRequiredSpeedPower(state, model) -- equivalent call inferred; original call site unknown
			v3 = state.RequiredSpeedPowerByAreaId[areaId]
		end
	end

	local projected = SpeedPowerProjection.ReadProjected()
	local distanceToClaimLine = getDistanceToClaimLine() -- equivalent call inferred; original call site unknown

	if not HotbarImagePreloadPolicy.ShouldPreloadCarriedEgg(projected, v3, distanceToClaimLine) then
		state.CarryTrove:Add(Timer.Simple(0.1, function()
			if state.Destroyed or state.CarryGeneration ~= carryGeneration then
				return
			end

			local distanceToClaimLine2 = getDistanceToClaimLine() -- equivalent call inferred; original call site unknown

			if distanceToClaimLine2 == nil or not HotbarImagePreloadPolicy.IsWithinClaimPreloadDistance(distanceToClaimLine2) then
				return
			end

			requestEggIcon(assetCategory) -- equivalent call inferred; original call site unknown
			state.CarryTrove:Clean()
		end))
		return
	end

	requestEggIcon(assetCategory) -- equivalent call inferred; original call site unknown
end

local frozen = table.freeze({
	Start = function(state)
		assert(not state.Started, "HotbarImagePreloadController already started")
		assert(not state.Destroyed, "HotbarImagePreloadController is destroyed")
		state.Started = true

		for _, model in guardAreas:GetChildren() do
			if not model:IsA("Model") then
				continue
			end

			cacheRequiredSpeedPower(state, model) -- equivalent call inferred; original call site unknown
		end

		state.Trove:Connect(guardAreas.ChildAdded, function(model)
			if model:IsA("Model") then
				cacheRequiredSpeedPower(state, model) -- equivalent call inferred; original call site unknown
			end
		end)
		state.Trove:Connect(guardAreas.ChildRemoved, function(p)
			state.RequiredSpeedPowerByAreaId[p.Name] = nil
		end)
		state.Trove:Add(EggState.CarryChanged:Connect(function(p)
			handleCarryState(state, p)
		end))
		state.Trove:Add(EggState.OwnerRefreshed:Connect(function(p: number)
			if p == localPlayer.UserId then
				scanReadyEggs(state)
			end
		end))
		state.Trove:Add(Timer.Simple(0.25, function()
			scanReadyEggs(state)
		end))
		scanReadyEggs(state)
	end,
	Destroy = function(self)
		if self.Destroyed then
			return
		end

		self.Destroyed = true
		self.CarryGeneration += 1
		self.Trove:Destroy()
	end
})
local frozen2 = table.freeze({
	__index = frozen
})
return table.freeze({
	new = function()
		local trove = Trove.new()
		return (setmetatable({
			CarryGeneration = 0,
			CarryTrove = trove:Extend(),
			Destroyed = false,
			ReadyPreloadedByUid = {},
			RequiredSpeedPowerByAreaId = {},
			Started = false,
			Trove = trove
		}, frozen2))
	end,
	IsA = function(self)
		return type(self) == "table" and getmetatable(self) == frozen2
	end,
	Assert = function(p)
		local v3

		if type(p) == "table" then
			v3 = getmetatable(p) == frozen2
		else
			v3 = false
		end

		assert(v3, "Expected HotbarImagePreloadController")
		return p
	end
})