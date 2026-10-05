local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local AssetDisplayText = require(ReplicatedStorage.Shared.Modules.AssetDisplayText)
local AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Assets2 = require(ReplicatedStorage.Data.Assets)
local personalities = Assets2.Personalities
local SwapGradient = require(ReplicatedStorage.Shared.Utils.SwapGradient)
local AssetSounds = require(ReplicatedStorage.Shared.Util.AssetSounds)
local t = require(ReplicatedStorage.Packages.t)
local data = ReplicatedStorage.Assets.Extra.Data
local vector = Vector2.new(70, 30)
local v = { "Mutations", "BaseMutation" }
local AssetInfoBillboard = {}

local function dropGradients(p)
	SwapGradient(p, nil)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showRate(perSecond, p: number)
	perSecond.Visible = p > 0
	perSecond.Text = not (p > 0) and "" or `${Simple.FormatCompact(p)}/s`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fitToAdornee(clone, CENTER)
	local size = clone.Size
	clone.Size = UDim2.fromScale(
		math.min(vector.X, size.X.Scale * (CENTER.Size.X / 0.8610000014305115)),
		(math.min(vector.Y, size.Y.Scale * (CENTER.Size.Y / 0.7670000195503235)))
	)
end

local function dressRarity(clone, p)
	local rarity = clone:FindFirstChild("Rarity")

	if rarity then
		SwapGradient(rarity, nil)
		rarity.Visible = false
		rarity.Text = ""
	end

	local odds = clone:FindFirstChild("Odds")

	if not odds then
		return
	end

	SwapGradient(odds, nil)
	local rarity2 = p.Rarity

	if rarity2 and rarity2.RarityGradient then
		local clone_2 = rarity2.RarityGradient:Clone()
		clone_2.Parent = odds
	end

	odds.Text = p.Rarity.DisplayName
	odds.Visible = true
end

function AssetInfoBillboard.LiveMutations(p, p2)
	local mutationState, v2 = AssetSounds.ReadMutationState(p, "Mutations", "BaseMutation")

	if #mutationState > 0 or v2 then
		return mutationState, v2
	end

	if p2 then
		return p2.Mutations or {}, p2.BaseMutation
	end

	return {}, nil
end

function AssetInfoBillboard.WriteTitle(instance, p: string, p2, p3: string?)
	local displayName = instance:FindFirstChild("DisplayName")

	if displayName then
		displayName.RichText = true
		displayName.Text = AssetDisplayText.Compose(p, p2, p3)
	end

	local level = instance:FindFirstChild("Level")

	if level then
		level.Visible = false
		level.Text = ""
	end
end

function AssetInfoBillboard.Range()
	return data.MaxDistance
end

function AssetInfoBillboard.SetRate(instance, p: number)
	t.strict(t.Instance)(instance)
	t.strict(t.number)(p)
	local perSecond = instance:FindFirstChild("PerSecond")
	local v2

	if perSecond == nil then
		v2 = false
	else
		v2 = perSecond:IsA("TextLabel")
	end

	assert(v2, "an info card without a PerSecond label")
	showRate(perSecond, p) -- equivalent call inferred; original call site unknown
end

function AssetInfoBillboard.Attach(parent, category: string, p2, p3: number?)
	t.strict(t.string)(category)

	if p3 ~= nil then
		t.strict(t.number)(p3)
	end

	local CENTER = parent:FindFirstChild("CENTER")

	if not (CENTER and CENTER:IsA("BasePart")) then
		return nil
	end

	if p2 then
		assert(AssetItem.AssetItemData(p2))
	end

	local clone = data:Clone()
	clone.Adornee = CENTER

	for _, childName in v do
		local child = clone:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	fitToAdornee(clone, CENTER) -- equivalent call inferred; original call site unknown
	local v2 = Assets.Directory[category]
	local displayName = clone.DisplayName
	local perSecond = clone.PerSecond
	dressRarity(clone, v2)
	local liveMutations, v3 = AssetInfoBillboard.LiveMutations(parent, p2)
	AssetInfoBillboard.WriteTitle(clone, v2.DisplayName, liveMutations, v3)

	if p3 == nil then
		local success, result = pcall(AssetEarnings.LiveRatePerSecond, p2 or {
			Category = category,
			Mutations = {},
			BaseMutation = nil,
			Scale = 1,
			Personality = personalities.Personalities.Normal,
			HasBeenFirstPlaced = true
		}, 0)
		p3 = not success and 0 or result
	end

	if perSecond then
		showRate(perSecond, p3) -- equivalent call inferred; original call site unknown
	end

	clone.Parent = parent
	return clone, displayName, perSecond
end

return AssetInfoBillboard