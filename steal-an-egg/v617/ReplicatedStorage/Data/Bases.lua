local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local t = require(ReplicatedStorage.Packages.t)
local Bases = {}
local v = {
	1000,
	1000000,
	75000000,
	500000000,
	1000000000,
	50000000000,
	500000000000,
	1000000000000,
	25000000000000,
	100000000000000,
	500000000000000,
	5000000000000000
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getBaseModelIfServer(p: string)
	t.strict(t.string)(p)

	if Constants.IS_SERVER then
		return ServerStorage.Assets.Models.Bases.Main[p]
	end

	return nil
end

local baseModelIfServer = getBaseModelIfServer("1") -- equivalent call inferred; original call site unknown
local baseModelIfServer2 = getBaseModelIfServer("1") -- equivalent call inferred; original call site unknown
local BASES = {
	[0] = {
		MaxAssets = 7,
		Model = baseModelIfServer,
		Cost = 0
	},
	[1] = {
		MaxAssets = 7,
		Model = baseModelIfServer2,
		Cost = v[1]
	}
}
local baseModelIfServer3 = getBaseModelIfServer("2") -- equivalent call inferred; original call site unknown
BASES[2] = {
	MaxAssets = 9,
	Model = baseModelIfServer3,
	Cost = v[2]
}
local baseModelIfServer4 = getBaseModelIfServer("3") -- equivalent call inferred; original call site unknown
BASES[3] = {
	MaxAssets = 10,
	Model = baseModelIfServer4,
	Cost = v[3]
}
local baseModelIfServer5 = getBaseModelIfServer("4") -- equivalent call inferred; original call site unknown
BASES[4] = {
	MaxAssets = 11,
	Model = baseModelIfServer5,
	Cost = v[4]
}
local baseModelIfServer6 = getBaseModelIfServer("5") -- equivalent call inferred; original call site unknown
BASES[5] = {
	MaxAssets = 12,
	Model = baseModelIfServer6,
	Cost = v[5]
}
local baseModelIfServer7 = getBaseModelIfServer("6") -- equivalent call inferred; original call site unknown
BASES[6] = {
	MaxAssets = 13,
	Model = baseModelIfServer7,
	Cost = v[6]
}
local baseModelIfServer8 = getBaseModelIfServer("7") -- equivalent call inferred; original call site unknown
BASES[7] = {
	MaxAssets = 14,
	Model = baseModelIfServer8,
	Cost = v[7]
}
local baseModelIfServer9 = getBaseModelIfServer("8") -- equivalent call inferred; original call site unknown
BASES[8] = {
	MaxAssets = 15,
	Model = baseModelIfServer9,
	Cost = v[8]
}
local baseModelIfServer10 = getBaseModelIfServer("9") -- equivalent call inferred; original call site unknown
BASES[9] = {
	MaxAssets = 16,
	Model = baseModelIfServer10,
	Cost = v[9]
}
local baseModelIfServer11 = getBaseModelIfServer("10") -- equivalent call inferred; original call site unknown
BASES[10] = {
	MaxAssets = 17,
	Model = baseModelIfServer11,
	Cost = v[10]
}
local baseModelIfServer12 = getBaseModelIfServer("11") -- equivalent call inferred; original call site unknown
BASES[11] = {
	MaxAssets = 18,
	Model = baseModelIfServer12,
	Cost = v[11]
}
local baseModelIfServer13 = getBaseModelIfServer("12") -- equivalent call inferred; original call site unknown
BASES[12] = {
	MaxAssets = 19,
	Model = baseModelIfServer13,
	Cost = v[12]
}
Bases.BASES = BASES
Bases.SKINS = {}
Bases.MIN_ASSET_EQUIP_CAPACITY = Bases.BASES[0].MaxAssets
Bases.MAX_ASSET_EQUIP_CAPACITY = Bases.BASES[#Bases.BASES].MaxAssets

function Bases.GetMaxBaseLevel()
	local v17 = 0

	for k in pairs(Bases.BASES) do
		if v17 < k then
			v17 = k
		end
	end

	return v17
end

function Bases.GetBaseConfigFor(p: number, p2: string?)
	t.strict(t.number)(p)
	t.strict(t.optional(t.string))(p2)
	local v17 = math.max(0, (math.floor(p)))
	local v18 = nil

	for k in pairs(Bases.BASES) do
		if k <= v17 and (not v18 or v18 < k) then
			v18 = k
		end
	end

	if v18 and p2 then
		return Bases.BASES[v18], Bases.SKINS[p2]
	end

	if v18 then
		return Bases.BASES[v18]
	end

	return nil
end

function Bases.GetAssetEquipCapacity(value: number?)
	local baseConfigFor = Bases.GetBaseConfigFor(value or 0)
	return baseConfigFor and baseConfigFor.MaxAssets or Bases.MIN_ASSET_EQUIP_CAPACITY
end

if Constants.IS_STUDIO then
	assert(#v >= #Bases.BASES, "Not enough costs for the number of bases")

	for k, v17 in pairs(Bases.BASES) do
		local v18

		if v17.Cost == v[k] then
			v18 = true
		elseif k == 0 then
			v18 = v17.Cost == 0
		else
			v18 = false
		end

		assert(v18, (`Cost for base index {k} does not match expected cost from COSTS table`))

		if Constants.IS_SERVER then
			local model = v17.Model
			local v19

			if typeof(model) == "Instance" then
				v19 = model:IsA("Model")
			else
				v19 = false
			end

			assert(v19, (`Model for base index {k} is not a valid Model instance`))
			assert(
				model.PrimaryPart and model.PrimaryPart.Name == "CenterPoint",
				(`Model for base index {k} must have a PrimaryPart named "CenterPoint"`)
			)
			local toUpdate = model:FindFirstChild("ToUpdate")
			local primaryPart = toUpdate and toUpdate:IsA("Model") and toUpdate.PrimaryPart

			if primaryPart then
				if toUpdate.PrimaryPart.Name == "CenterPoint" then
					primaryPart = toUpdate:FindFirstChild("PetArea")
				else
					primaryPart = false
				end
			end

			assert(
				primaryPart,
				(`Model for base index {k} must have a child Model named "ToUpdate" with a PrimaryPart named "CenterPoint"`)
			)
		end

		local v19

		if typeof(v17.MaxAssets) == "number" then
			v19 = v17.MaxAssets == Bases.GetAssetEquipCapacity(k)
		else
			v19 = false
		end

		assert(v19, (`MaxAssets for base index {k} must match asset equip capacity`))
	end
end

if Constants.IS_STUDIO and Constants.IS_SERVER then
	for k, v17 in pairs(Bases.SKINS) do
		local v18

		if typeof(v17.FirstFloor) == "Instance" then
			v18 = v17.FirstFloor:IsA("Model")
		else
			v18 = false
		end

		assert(v18, (`Model for base skin index {k} is not a valid Model instance`))
	end
end

local maxAssets = {}

for k, v17 in Bases.BASES do
	maxAssets[k] = v17.MaxAssets
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
Bases.BASES = require(ReplicatedStorage2.Shared.Flags.BalanceConfig).Bind("Game.Balance.Bases", Bases.BASES, {
	Cost = true,
	MaxAssets = true
}, true, function(items)
	for k, item in items do
		local v17

		if item.MaxAssets % 1 == 0 and item.MaxAssets >= 1 then
			v17 = item.MaxAssets <= maxAssets[k]
		else
			v17 = false
		end

		assert(v17)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshCapacityLimits()
	Bases.MIN_ASSET_EQUIP_CAPACITY = Bases.BASES[0].MaxAssets
	Bases.MAX_ASSET_EQUIP_CAPACITY = Bases.BASES[Bases.GetMaxBaseLevel()].MaxAssets
end

refreshCapacityLimits() -- equivalent call inferred; original call site unknown
local BalanceConfig = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
BalanceConfig.Changed:Connect(refreshCapacityLimits)
return Bases