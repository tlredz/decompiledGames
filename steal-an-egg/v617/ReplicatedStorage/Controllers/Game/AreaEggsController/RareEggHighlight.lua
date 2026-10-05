local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.Shared.Types.AreaEggResetCycle)
require(ReplicatedStorage.Shared.Types.AreaEggs)
local t = require(ReplicatedStorage.Packages.t)
local Assets = require(ReplicatedStorage.Data.Assets)
local CaptureTheEgg = require(ReplicatedStorage.Data.CaptureTheEgg)
local EggState = require(ReplicatedStorage.Client.EggState)
local Log = require(ReplicatedStorage.Packages.Log)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local WorkspaceEggVisibility = require(script.Parent.WorkspaceEggVisibility)
local rank = Rarity.Rarities.Secret.Rank
local v = Log.new()
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = nil
local flag = false
local dayStartsAt = -1e999
local v6 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getOutlineColor(p: string, p2: string)
	if Workspace:GetAttribute(CaptureTheEgg.EggUidAttribute) == p then
		return CaptureTheEgg.EggHighlightColor
	end

	local v8 = Assets.Directory[p2]
	assert(v8 ~= nil, (`Missing asset config {p2}`))
	local rarity = v8.Rarity

	if rarity.Rank < rank then
		return nil
	end

	return rarity.Color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearBinding(p: string)
	local v8 = v3[p]

	if v8 == nil then
		return
	end

	v3[p] = nil
	local destroyConnection = v8.DestroyConnection

	if destroyConnection ~= nil then
		destroyConnection:Disconnect()
	end

	if v8.Highlight.Parent ~= nil then
		v8.Highlight:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearAllBindings()
	for k in pairs(v3) do
		clearBinding(k) -- equivalent call inferred; original call site unknown
	end
end

local function bindModel(p: string, instance, outlineColor: Color3)
	local v8 = v3[p]

	if v8 ~= nil and v8.Model == instance then
		v8.Highlight.OutlineColor = outlineColor
		return
	end

	clearBinding(p) -- equivalent call inferred; original call site unknown
	local highlight = Instance.new("Highlight")
	highlight.Name = "RareAreaEggHighlight"
	highlight.Adornee = instance
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0.25
	highlight.OutlineColor = outlineColor
	highlight.Parent = instance
	local v9 = {
		Model = instance,
		Highlight = highlight,
		DestroyConnection = nil
	}
	v3[p] = v9
	v9.DestroyConnection = instance.Destroying:Connect(function()
		if v3[p] == v9 then
			v3[p] = nil
		end
	end)
end

local function syncUid(p: string)
	local v8 = v2[p]

	if v8 == nil then
		v4[p] = nil
		clearBinding(p) -- equivalent call inferred; original call site unknown
	elseif flag then
		clearBinding(p) -- equivalent call inferred; original call site unknown
	else
		local outlineColor = getOutlineColor(p, v8) -- equivalent call inferred; original call site unknown

		if outlineColor == nil then
			v4[p] = nil
			clearBinding(p) -- equivalent call inferred; original call site unknown
		else
			local v9 = v4[p]
			v4[p] = nil

			if v9 ~= nil and v9.Parent ~= nil then
				bindModel(p, v9, outlineColor)
				return
			end

			local v10 = v3[p]

			if v10 ~= nil and v10.Model.Parent ~= nil then
				v10.Highlight.OutlineColor = outlineColor
				return
			end

			local model = WorkspaceEggVisibility.ResolveModel(p)

			if model ~= nil then
				bindModel(p, model, outlineColor)
			end
		end
	end
end

local function beginResetReveal(p)
	if p.DayStartsAt <= dayStartsAt then
		return
	end

	dayStartsAt = p.DayStartsAt
	flag = true
	table.clear(v4)
	clearAllBindings() -- equivalent call inferred; original call site unknown
end

local function completeResetReveal()
	flag = false

	for k in pairs(v2) do
		syncUid(k)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRecord(fieldEgg)
	v2[fieldEgg.Uid] = fieldEgg.AssetCategory
	syncUid(fieldEgg.Uid)
end

local function applySnapshot(p)
	local v8 = {}

	for _, record in ipairs(p.Records) do
		v8[record.Uid] = true
		v2[record.Uid] = record.AssetCategory
	end

	for k in pairs(v2) do
		if not (v8[k] ~= true and k ~= v5) then
			continue
		end

		v2[k] = nil
		v4[k] = nil
		clearBinding(k) -- equivalent call inferred; original call site unknown
	end

	for k in pairs(v8) do
		syncUid(k)
	end
end

local function applyCarryState(data)
	local v8 = v5

	if data.IsCarrying then
		local v9 = assert(data.Uid, "Carried area egg state must include Uid")
		local v10 = assert(data.AssetCategory, "Carried area egg state must include AssetCategory")
		v5 = v9
		v2[v9] = v10
		syncUid(v9)
	else
		v5 = nil

		if v8 == nil then
			return
		end

		local fieldEgg = EggState.ReadFieldEgg(v8)

		if fieldEgg == nil then
			v2[v8] = nil
			v4[v8] = nil
			clearBinding(v8) -- equivalent call inferred; original call site unknown
		else
			applyRecord(fieldEgg) -- equivalent call inferred; original call site unknown
		end
	end
end

local function observeWorkspaceChild(model)
	if not model:IsA("Model") then
		return
	end

	task.defer(function()
		if flag then
			return
		end

		local name = model.Name
		local v8 = v2[name]

		if model.Parent ~= Workspace or v8 == nil then
			return
		end

		local outlineColor = getOutlineColor(name, v8) -- equivalent call inferred; original call site unknown

		if outlineColor ~= nil then
			bindModel(name, model, outlineColor)
		end
	end)
end

local v7 = {
	BindRenderedModel = function(p, p2)
		t.strict(t.table)(p)
		t.strict(t.instanceIsA("Model"))(p2)
		v2[p.Uid] = p.AssetCategory

		if flag then
			v4[p.Uid] = p2
			clearBinding(p.Uid) -- equivalent call inferred; original call site unknown
		else
			local outlineColor = getOutlineColor(p.Uid, p.AssetCategory) -- equivalent call inferred; original call site unknown

			if outlineColor ~= nil then
				bindModel(p.Uid, p2, outlineColor)
				return
			end

			clearBinding(p.Uid) -- equivalent call inferred; original call site unknown
		end
	end,
	Start = function()
		assert(not v6, "RareEggHighlight.Start may only be called once")
		v6 = true
		EggState.ResetCountdown:Connect(beginResetReveal)
		EggState.RarityPresented:Connect(completeResetReveal)
		EggState.FieldRefreshed:Connect(applySnapshot)
		EggState.FieldShifted:Connect(applyRecord)
		EggState.FieldGone:Connect(function(p: string)
			if p == v5 then
				syncUid(p)
			else
				v2[p] = nil
				v4[p] = nil
				clearBinding(p) -- equivalent call inferred; original call site unknown
			end
		end)
		EggState.CarryChanged:Connect(applyCarryState)
		Workspace.ChildAdded:Connect(observeWorkspaceChild)
		Workspace:GetAttributeChangedSignal(CaptureTheEgg.EggUidAttribute):Connect(function()
			for k in pairs(v2) do
				syncUid(k)
			end
		end)
		applySnapshot(EggState.ReadFieldEggs())
		v:AtDebug():Log("Rare area egg highlight lifecycle started")
	end
}
return table.freeze(v7)