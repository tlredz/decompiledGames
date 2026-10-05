local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Log = require(ReplicatedStorage.Packages.Log)
local Plots = require(ReplicatedStorage.Shared.Types.Plots)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local Streamable = require(ReplicatedStorage.Packages.Streamable)
local streamable = Streamable.Streamable
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.instanceIsA("Player"))
local strict2 = t.strict(t.Vector3)
local strict3 = t.strict(t.instanceIsA("BasePart"))
local strict4 = t.strict(t.instanceIsA("Attachment"))
local strict5 = t.strict(t.instanceIsA("BillboardGui"))
local strict6 = t.strict(t.instanceIsA("Folder"))
local v = Log.new()
local localPlayer = Players.LocalPlayer
local v2 = {}
local revisions = {}
local v3 = {}
local v4 = {}
local v5 = nil
local PlotState = {
	LocalPlotChanged = Signal.new(),
	PlotChanged = Signal.new(),
	FolderChanged = Signal.new()
}
local v6 = streamable.new(Workspace, "Plots")

local function localSlot()
	for k, v8 in v2 do
		if v8 == localPlayer.UserId then
			return k
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function announce(p: number)
	PlotState.PlotChanged:Fire(p, v2[p])
	local v7 = nil

	for k, v9 in v2 do
		if v9 ~= localPlayer.UserId then
			continue
		end

		v7 = k
		break
	end

	if v7 == p then
		PlotState.LocalPlotChanged:Fire(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function follow(p, p2: string, maid, fn)
	local v7 = streamable.new(p, p2)
	maid:Add(function()
		v7:Destroy()
	end)
	v7:Observe(fn)
end

local function watchSlot(name: number, instance)
	if v4[name] then
		return
	end

	local maid = Trove.new()
	local plot = streamable.new(instance, (tostring(name)))
	local v8 = {
		plot = plot,
		trove = maid
	}
	v4[name] = v8
	maid:Add(function()
		plot:Destroy()
	end)
	maid:Add(function()
		if v4[name] == v8 then
			v4[name] = nil
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ping()
		announce(name) -- equivalent call inferred; original call site unknown
	end

	maid:Add(plot:Observe(function(instance2, object)
		if not (instance2:IsA("Folder") or instance2:IsA("Model")) then
			return
		end

		ping() -- equivalent call inferred; original call site unknown
		object:Add(ping)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn(p, object2)
			strict3(p)
			ping() -- equivalent call inferred; original call site unknown
			object2:Add(ping)
		end

		follow(instance2, "CenterPoint", object, fn) -- equivalent call inferred; original call site unknown

		local function fn2(p, maid2)
			strict3(p)
			v3[name] = p.CFrame + createVector(0, 0, 0)
			ping() -- equivalent call inferred; original call site unknown
			maid2:Add(function()
				if v4[name] == v8 then
					ping() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		follow(instance2, "SpawnPoint", object, fn2) -- equivalent call inferred; original call site unknown

		local function fn3(model, object2)
			if model:IsA("Model") then
				ping() -- equivalent call inferred; original call site unknown
				object2:Add(ping)

				local function fn4(p, object3)
					fn(p, object3) -- equivalent call inferred; original call site unknown
				end

				follow(model, "PetArea", object2, fn4) -- equivalent call inferred; original call site unknown
			end
		end

		follow(instance2, "ToUpdate", object, fn3) -- equivalent call inferred; original call site unknown

		local function fn4(p, object2)
			ping() -- equivalent call inferred; original call site unknown
			object2:Add(ping)

			local function fn5(p2, object3)
				strict4(p2)
				ping() -- equivalent call inferred; original call site unknown
				object3:Add(ping)

				local function fn6(p3, object4)
					strict5(p3)
					ping() -- equivalent call inferred; original call site unknown
					object4:Add(ping)
				end

				follow(p2, "YourBase", object3, fn6) -- equivalent call inferred; original call site unknown
			end

			follow(p, "Attachment", object2, fn5) -- equivalent call inferred; original call site unknown
		end

		follow(instance2, "PlotSign", object, fn4) -- equivalent call inferred; original call site unknown

		local function fn5(p, object2)
			ping() -- equivalent call inferred; original call site unknown
			object2:Add(ping)

			local function fn6(_, object3)
				ping() -- equivalent call inferred; original call site unknown
				object3:Add(ping)
			end

			follow(p, "Sign", object2, fn6) -- equivalent call inferred; original call site unknown
		end

		follow(instance2, "BaseUpgrade", object, fn5) -- equivalent call inferred; original call site unknown
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forgetSlot(p: number)
	local v7 = v4[p]

	if v7 ~= nil then
		v3[p] = nil
		v4[p] = nil
		v7.trove:Destroy()
	end
end

local function forgetEverySlot()
	local v7 = {}

	for k in v4 do
		table.insert(v7, k)
	end

	for _, v8 in v7 do
		forgetSlot(v8) -- equivalent call inferred; original call site unknown
	end
end

local function slotFor(p)
	local v7 = p or localPlayer
	strict(v7)
	local v8

	if v7 == localPlayer then
		for k, v10 in v2 do
			if v10 ~= localPlayer.UserId then
				continue
			end

			v8 = k
			break
		end
	end

	for k, v9 in v2 do
		if v8 == nil and v9 == v7.UserId then
			v8 = k
		end
	end

	return v8, v7
end

function PlotState.ReadOwners()
	return table.clone(v2)
end

function PlotState.LookupOwner(p: number)
	return v2[p]
end

function PlotState.ResolveLocalSlot()
	for k, v8 in v2 do
		if v8 == localPlayer.UserId then
			return k
		end
	end

	return nil
end

function PlotState.ResolveFolder()
	return v5
end

function PlotState.ResolvePlot(p)
	local slot = slotFor(p)
	local v8 = v5
	local child

	if not (slot == nil or v8 == nil) then
		child = v8:FindFirstChild((tostring(slot)))
	end

	local toUpdate

	if child ~= nil then
		toUpdate = child:FindFirstChild("ToUpdate")
	end

	local petArea

	if not (toUpdate == nil or not toUpdate:IsA("Model")) then
		petArea = toUpdate:FindFirstChild("PetArea")
	end

	local centerPoint

	if child ~= nil then
		centerPoint = child:FindFirstChild("CenterPoint")
	end

	local v9

	if petArea == nil then
		v9 = false
	else
		v9 = petArea:IsA("BasePart")

		if v9 then
			if centerPoint == nil then
				v9 = false
			else
				v9 = centerPoint:IsA("BasePart")
			end
		end
	end

	if not v9 then
		return nil
	end

	local spawnPoint = child:FindFirstChild("SpawnPoint")
	local v10 = v3
	local v11

	if spawnPoint == nil or not spawnPoint:IsA("BasePart") then
		v11 = v3[slot]
	else
		v11 = spawnPoint.CFrame + createVector(0, 0, 0)
	end

	v10[slot] = v11
	return {
		Slot = slot,
		PlotFolder = child,
		PetArea = petArea,
		CenterPoint = centerPoint,
		RespawnPointCFrame = v3[slot]
	}
end

function PlotState.FindLocalBaseSign()
	local plot = PlotState.ResolvePlot()
	local plotSign

	if plot then
		plotSign = plot.PlotFolder:FindFirstChild("PlotSign")
	end

	local attachment

	if plotSign then
		attachment = plotSign:FindFirstChild("Attachment")
	end

	local yourBase

	if not (attachment == nil or not attachment:IsA("Attachment")) then
		yourBase = attachment:FindFirstChild("YourBase")
	end

	if yourBase == nil or not yourBase:IsA("BillboardGui") then
		return nil
	end

	return yourBase
end

function PlotState.FindRespawnCFrame(p)
	local v7 = slotFor(p)

	if v7 == nil then
		return nil
	end

	return v3[v7]
end

function PlotState.ContainsLocalPoint(vector2: Vector3)
	strict2(vector2)
	local plot = PlotState.ResolvePlot()

	if not plot then
		return false
	end

	local boundingBox, v7 = plot.PlotFolder:GetBoundingBox()
	local pointToObjectSpace = boundingBox:PointToObjectSpace(vector2)
	local v8 = v7 * 0.5
	return math.abs(pointToObjectSpace.X) <= v8.X and math.abs(pointToObjectSpace.Z) <= v8.Z
end

-- equivalent calls inferred from this helper; original call sites unknown
local function adoptOwner(p: number, p2: number?)
	local v7 = nil

	for k, v9 in v2 do
		if v9 ~= localPlayer.UserId then
			continue
		end

		v7 = k
		break
	end

	v2[p] = p2
	PlotState.PlotChanged:Fire(p, p2)

	if p2 == localPlayer.UserId or v7 == p then
		PlotState.LocalPlotChanged:Fire(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function acceptUpdate(data)
	local v7 = revisions[data.Slot]

	if v7 == nil or v7 < data.Revision then
		revisions[data.Slot] = data.Revision
		adoptOwner(data.Slot, data.UserId) -- equivalent call inferred; original call site unknown
	end
end

local function acceptSnapshot(result)
	local v7 = {}

	for k, v8 in result.OwnersBySlot do
		local v9 = assert(tonumber(k), (`plot snapshot carried a non-numeric slot: {k}`))
		v7[v9] = true
		local v10 = revisions[v9]

		if not (v10 == nil or v10 < result.Revision) then
			continue
		end

		revisions[v9] = result.Revision
		adoptOwner(v9, v8) -- equivalent call inferred; original call site unknown
	end

	local v8 = {}

	for k in revisions do
		table.insert(v8, k)
	end

	for _, v9 in v8 do
		local v10

		if v7[v9] == true then
			v10 = false
		else
			v10 = revisions[v9] < result.Revision
		end

		local v11 = v10 and v2[v9] ~= nil
		local v12 = revisions
		local v13

		if v10 then
			v13 = result.Revision
		else
			v13 = revisions[v9]
		end

		v12[v9] = v13

		if not v11 then
			continue
		end

		local v14 = nil

		for k, v16 in v2 do
			if v16 ~= localPlayer.UserId then
				continue
			end

			v14 = k
			break
		end

		v2[v9] = nil
		PlotState.PlotChanged:Fire(v9, nil)

		if localPlayer.UserId == nil or v14 == v9 then
			PlotState.LocalPlotChanged:Fire(v9)
		end
	end
end

local function askState()
	return Remotes.Homestead.AskState:InvokeServer()
end

local function pullSnapshot()
	local success, result = pcall(askState)

	if not success then
		return false, (tostring(result))
	end

	local plotStateSnapshot, v7 = Plots.SchemaValidation.PlotStateSnapshot(result)

	if not plotStateSnapshot then
		return false, (`plot snapshot failed validation: {v7}`)
	end

	acceptSnapshot(result)
	return true
end

local pullUntilAnswered

pullUntilAnswered = function()
	local success, result = pcall(askState)
	local v7, v8

	if success then
		local plotStateSnapshot, v9 = Plots.SchemaValidation.PlotStateSnapshot(result)

		if plotStateSnapshot then
			acceptSnapshot(result)
			v7 = true
		else
			v8 = `plot snapshot failed validation: {v9}`
			v7 = false
		end
	else
		v8 = tostring(result)
		v7 = false
	end

	if not v7 then
		v:AtError():Log((`plot snapshot request did not land, retrying: {v8}`))
		task.delay(5, pullUntilAnswered)
	end
end

Remotes.Homestead.StateShifted.OnClientEvent:Connect(function(data)
	local plotStateUpdate, v7 = Plots.SchemaValidation.PlotStateUpdate(data)

	if plotStateUpdate then
		acceptUpdate(data) -- equivalent call inferred; original call site unknown
	else
		v:AtError():Log((`plot state update failed validation: {v7}`))
	end
end)
v6:Observe(function(instance, maid)
	strict6(instance)
	v5 = instance
	PlotState.FolderChanged:Fire(instance)
	maid:Add(function()
		if v5 == instance then
			v5 = nil
		end

		forgetEverySlot()
		PlotState.FolderChanged:Fire(nil)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchIfNumbered(p)
		local name = tonumber(p.Name)

		if name ~= nil then
			watchSlot(name, instance)
		end
	end

	for _, child in instance:GetChildren() do
		watchIfNumbered(child) -- equivalent call inferred; original call site unknown
	end

	maid:Connect(instance.ChildAdded, function(p)
		watchIfNumbered(p) -- equivalent call inferred; original call site unknown
		PlotState.FolderChanged:Fire(instance)
	end)
	maid:Connect(instance.ChildRemoved, function(p)
		local name = tonumber(p.Name)

		if name ~= nil then
			forgetSlot(name) -- equivalent call inferred; original call site unknown
		end

		PlotState.FolderChanged:Fire(instance)
	end)
end)
task.spawn(pullUntilAnswered)

local function onNearbyPurchase(p: number)
	Storefront.Prompt(p, true)
end

Remotes.Homestead.AskNearbyPurchase.OnClientEvent:Connect(onNearbyPurchase)
return PlotState