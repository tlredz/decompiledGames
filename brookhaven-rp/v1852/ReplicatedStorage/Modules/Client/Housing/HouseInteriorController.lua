local HouseInteriorController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local HouseInteriorConstants = require(ReplicatedStorage.Modules.Shared.Housing.HouseInteriorConstants)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = {}
local v2 = {}
local localPlayer = Players.LocalPlayer
local v3 = true

local function getLotId(instance)
	local attribute = instance:GetAttribute(HouseInteriorConstants.LotIdAttribute)

	if type(attribute) == "number" then
		return attribute
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getInteriorGui()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if playerGui == nil then
		return nil
	end

	return (playerGui:FindFirstChild("HouseInteriors"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unload(state)
	if state.stragglerConnection ~= nil then
		state.stragglerConnection:Disconnect()
		state.stragglerConnection = nil
	end

	if state.holder ~= nil then
		if state.holder.Parent ~= nil then
			state.holder:Destroy()
		end

		state.holder = nil
	end

	state.guid = nil
end

local function stillWaitingForGuid(p: number, p2: string)
	if v2[p] == p2 then
		return true
	end

	local v4 = v[p]
	return v4 ~= nil and v4.guid == p2
end

local function findClone(p: string)
	local interiorGui = getInteriorGui() -- equivalent call inferred; original call site unknown

	if interiorGui == nil then
		return nil
	end

	for _, child in interiorGui:GetChildren() do
		if child:GetAttribute("interiorGuid") == p then
			return child
		end
	end

	return nil
end

local function awaitClone(p: number, p2: string)
	while true do
		local v4

		if v2[p] == p2 then
			v4 = true
		else
			local v5 = v[p]

			if v5 == nil then
				v4 = false
			else
				v4 = v5.guid == p2
			end
		end

		if not v4 then
			return (findClone(p2))
		end

		local clone = findClone(p2)

		if clone ~= nil then
			return clone
		end

		task.wait()
	end
end

local function loadInterior(state, instance, p: string)
	if state.guid ~= p then
		return
	end

	local model = Instance.new("Model")
	model.Name = "LazyInterior"
	model.Parent = state.model
	state.holder = model
	local reparentInstancesPerSecond = HouseInteriorConstants.ReparentInstancesPerSecond
	local v4 = math.max(1, (math.ceil(reparentInstancesPerSecond / 30)))
	local v5 = v4 / reparentInstancesPerSecond

	local function isActive()
		return state.guid == p and state.holder == model and model.Parent ~= nil and state.model.Parent ~= nil
	end

	state.stragglerConnection = instance.ChildAdded:Connect(function(child)
		local v6

		if state.guid == p and state.holder == model and model.Parent ~= nil then
			v6 = state.model.Parent ~= nil
		else
			v6 = false
		end

		if v6 then
			child.Parent = model
		end
	end)
	instance.Destroying:Once(function()
		if state.stragglerConnection ~= nil then
			state.stragglerConnection:Disconnect()
			state.stragglerConnection = nil
		end
	end)
	local count = 0

	for _, child in instance:GetChildren() do
		local v6

		if state.guid == p and state.holder == model and model.Parent ~= nil then
			v6 = state.model.Parent ~= nil
		else
			v6 = false
		end

		if not v6 then
			break
		end

		child.Parent = model
		count += 1

		if not (v4 <= count) then
			continue
		end

		task.wait(v5)
		count = 0
	end
end

local v4 = {}

local function tryLoadPending(p: number)
	local guid = v2[p]
	local v6 = v[p]

	if guid == nil or v6 == nil or v6.guid == guid then
		return
	end

	local v7 = (v4[p] or 0) + 1
	v4[p] = v7
	unload(v6) -- equivalent call inferred; original call site unknown
	v6.guid = guid
	local v8 = awaitClone(p, guid)

	if v4[p] ~= v7 then
		return
	end

	if v8 == nil then
		if v6.guid == guid then
			v6.guid = nil
		end
	else
		if v2[p] == guid then
			v2[p] = nil
		end

		if v6.guid ~= guid then
			return
		end

		loadInterior(v6, v8, guid)
	end
end

local function onInteriorToClient(p: number, p2: string)
	v2[p] = p2
	tryLoadPending(p)
end

local function onUnloadInterior(p: number)
	if v3 ~= true then
		return
	end

	v2[p] = nil
	local v5 = v[p]

	if v5 ~= nil then
		unload(v5) -- equivalent call inferred; original call site unknown
	end
end

local registerHouse

registerHouse = function(model)
	if not model:IsA("Model") then
		return
	end

	local attribute = model:GetAttribute(HouseInteriorConstants.LotIdAttribute)

	if type(attribute) ~= "number" then
		attribute = nil
	end

	if attribute == nil then
		local connection = nil
		connection = model:GetAttributeChangedSignal(HouseInteriorConstants.LotIdAttribute):Connect(function()
			local attribute2 = model:GetAttribute(HouseInteriorConstants.LotIdAttribute)

			if type(attribute2) ~= "number" then
				attribute2 = nil
			end

			if attribute2 == nil then
				return
			end

			if connection ~= nil then
				connection:Disconnect()
				connection = nil
			end

			registerHouse(model)
		end)
		model.Destroying:Once(function()
			if connection ~= nil then
				connection:Disconnect()
				connection = nil
			end
		end)
	else
		if v[attribute] ~= nil and v[attribute].model == model then
			return
		end

		v[attribute] = {
			model = model,
			holder = nil,
			guid = nil,
			stragglerConnection = nil
		}
		tryLoadPending(attribute)
	end
end

local function unregisterHouse(p)
	for k, v5 in v do
		if v5.model ~= p then
			continue
		end

		v2[k] = nil
		unload(v5) -- equivalent call inferred; original call site unknown
		v[k] = nil
	end
end

function HouseInteriorController.FrameworkInit() end

function HouseInteriorController.FrameworkStart()
	Remotes.connect(HouseInteriorConstants.InteriorToClient, onInteriorToClient)
	Remotes.connect(HouseInteriorConstants.UnloadInterior, onUnloadInterior)

	for _, v5 in CollectionService:GetTagged(HouseInteriorConstants.HouseTag) do
		registerHouse(v5)
	end

	CollectionService:GetInstanceAddedSignal(HouseInteriorConstants.HouseTag):Connect(registerHouse)
	CollectionService:GetInstanceRemovedSignal(HouseInteriorConstants.HouseTag):Connect(unregisterHouse)
	ABTest.GetExperimentVariable(HouseInteriorConstants.ABTestExperiment, HouseInteriorConstants.ABTestVariable):timeout(10):andThen(
		function(p)
			v3 = p == true
		end,
		function(p)
			warn("houses-lazy-loading AB test failed: " .. tostring(p))
			v3 = true
		end
	)
end

return HouseInteriorController