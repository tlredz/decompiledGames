local PetAging = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local General = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local String = require(ReplicatedStorage2:WaitForChild("Services"):WaitForChild("String"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Main = require(ReplicatedStorage3:WaitForChild("Services"):WaitForChild("FormatNumber"):WaitForChild("Main"))
PetAging.MaxAge = 100
PetAging.GrowthPerAge = 0.01
PetAging.WeightStandardKG = 10
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local Pets = require(ReplicatedStorage4:WaitForChild("GameData"):WaitForChild("Pets"))
PetAging.RequirementVersion = 3

local function Parameters(options)
	local v = options or {}
	local petName = v.PetName or v.Model and v.Model.Name
	local v2 = petName and Pets[petName]
	local rarity = v.Rarity or v2 and v2.Rarity or "Common"
	local rarityLevelRequirementMultiplier = General.RarityLevelRequirementMultiplier
	local v3 = rarityLevelRequirementMultiplier[rarity] or rarityLevelRequirementMultiplier.Common
	local baseWeight = tonumber(v.BaseWeight)

	if not baseWeight then
		local v4 = math.clamp(tonumber(v.Age) or 1, 1, PetAging.MaxAge)
		baseWeight = (tonumber(v.Weight) or PetAging.WeightStandardKG) / (1 + PetAging.GrowthPerAge * (v4 - 1))
	end

	return v3, (math.max(baseWeight / PetAging.WeightStandardKG, 0.01))
end

function PetAging.RequirementFor(p, p2)
	local v, v2 = Parameters(p2)
	return v * math.clamp(tonumber(p) or 1, 1, PetAging.MaxAge) ^ (1.7 + 0.15 * (v2 - 1))
end

function PetAging.CumulativeFor(p, p2)
	local total = 0

	for i = 1, math.min(p, PetAging.MaxAge) - 1 do
		total += PetAging.RequirementFor(i, p2)
	end

	return total
end

function PetAging.StateFrom(p, p2, p3)
	local v = p2 or os.time()
	local v2 = math.max(v - (tonumber(p) or v), 0)
	local total = 0

	for i = 1, PetAging.MaxAge - 1 do
		local requirementFor = PetAging.RequirementFor(i, p3)

		if v2 + 1e-6 < total + requirementFor then
			return i, math.max(v2 - total, 0), requirementFor
		else
			total += requirementFor
		end
	end

	local requirementFor = PetAging.RequirementFor(PetAging.MaxAge, p3)
	return PetAging.MaxAge, requirementFor, requirementFor
end

function PetAging:MigrateProfile(p2)
	local petRequirementVersion = tonumber(self.PetRequirementVersion) or 1

	if PetAging.RequirementVersion <= petRequirementVersion then
		return false
	end

	local v = p2 or os.time()

	for _, v2 in { "Inventory", "Plot" } do
		local v3 = self[v2]
		local pets

		if type(v3) == "table" then
			pets = v3.Pets
		else
			pets = false
		end

		if type(pets) ~= "table" then
			continue
		end

		for _, pet in pairs(pets) do
			if not (type(pet) == "table" and pet.PetName) then
				continue
			end

			local age = math.clamp(math.floor(tonumber(pet.Age) or 1), 1, PetAging.MaxAge)
			local v5 = 0

			if tonumber(pet.BirthTime) then
				-- equivalent calls inferred from this helper; original call sites unknown
				local v6 = pet

				local function PreviousRequirement(p3)
					if petRequirementVersion < 2 then
						return 10 * p3 * p3
					end

					local v7, v8 = Parameters(v6)
					return v7 * p3 ^ (1.5 + 0.1633 * (v8 - 1))
				end

				local v7 = math.max(v - tonumber(pet.BirthTime), 0)
				age = 1
				local total = 0

				while age < PetAging.MaxAge do
					local previousRequirement = PreviousRequirement(age) -- equivalent call inferred; original call site unknown

					if v7 + 1e-6 < total + previousRequirement then
						v5 = math.max(v7 - total, 0) / previousRequirement
						break
					else
						total += previousRequirement
						age += 1
					end
				end
			end

			if not tonumber(pet.BaseWeight) then
				pet.BaseWeight = (tonumber(pet.Weight) or PetAging.WeightStandardKG) / PetAging.MultiplierFor(tonumber(pet.Age) or age)
			end

			pet.BirthTime = v - (PetAging.CumulativeFor(age, pet) + v5 * PetAging.RequirementFor(age, pet))
			pet.Age = age
			pet.Weight = PetAging.WeightFor(pet.BaseWeight, age)
		end
	end

	self.PetRequirementVersion = PetAging.RequirementVersion
	return true
end

function PetAging.MultiplierFor(p)
	local v = math.clamp(tonumber(p) or 1, 1, PetAging.MaxAge)
	return 1 + PetAging.GrowthPerAge * (v - 1)
end

function PetAging.WeightFor(p, p2)
	return math.floor((tonumber(p) or 1) * PetAging.MultiplierFor(p2) * 100 + 0.5) / 100
end

function PetAging.SpeedMultiplierFor(p)
	local petSpeedWeight = General.PetSpeedWeight or {}
	local speedWeightStepKG = tonumber(petSpeedWeight.SpeedWeightStepKG) or 10
	local speedPerWeightStep = tonumber(petSpeedWeight.SpeedPerWeightStep) or 0.2
	local minSpeedMultiplier = tonumber(petSpeedWeight.MinSpeedMultiplier) or 0.5

	if speedWeightStepKG <= 0 then
		return 1
	end

	return (math.max(
		1 + ((tonumber(p) or PetAging.WeightStandardKG) - PetAging.WeightStandardKG) / speedWeightStepKG * speedPerWeightStep,
		minSpeedMultiplier
	))
end

function PetAging.InflateSpeed(p)
	local petSpeedDisplay = General.PetSpeedDisplay
	local v = math.max(tonumber(p) or 0, 0)

	if type(petSpeedDisplay) ~= "table" or #petSpeedDisplay < 2 then
		return v
	end

	local function Between(p2, p3, p4, p5, p6)
		if p4 == p2 then
			return p3
		end

		local v2 = (p6 - p2) / (p4 - p2)
		return 10 ^ (math.log10(p3) + (math.log10(p5) - math.log10(p3)) * v2)
	end

	local v2 = petSpeedDisplay[1]
	local v3 = petSpeedDisplay[#petSpeedDisplay]

	if v <= v2.Walk then
		local v4 = petSpeedDisplay[2]
		local walk = v2.Walk
		local shown = v2.Shown
		local walk2 = v4.Walk
		local shown2 = v4.Shown

		if walk2 ~= walk then
			local v5 = (v - walk) / (walk2 - walk)
			shown = 10 ^ (math.log10(shown) + (math.log10(shown2) - math.log10(shown)) * v5)
		end

		return (math.max(shown, 1))
	elseif v3.Walk <= v then
		local v4 = petSpeedDisplay[#petSpeedDisplay - 1]
		local walk = v4.Walk
		local shown = v4.Shown
		local walk2 = v3.Walk
		local shown2 = v3.Shown

		if walk2 == walk then
			return shown
		end

		local v5 = (v - walk) / (walk2 - walk)
		return 10 ^ (math.log10(shown) + (math.log10(shown2) - math.log10(shown)) * v5)
	else
		for i = 1, #petSpeedDisplay - 1 do
			local v4 = petSpeedDisplay[i]
			local v5 = petSpeedDisplay[i + 1]

			if not (v4.Walk <= v and v <= v5.Walk) then
				continue
			end

			local walk = v4.Walk
			local shown = v4.Shown
			local walk2 = v5.Walk
			local shown2 = v5.Shown

			if walk2 == walk then
				return shown
			end

			local v6 = (v - walk) / (walk2 - walk)
			return 10 ^ (math.log10(shown) + (math.log10(shown2) - math.log10(shown)) * v6)
		end

		return v
	end
end

local function InterpolateAnchors(eggAnchors, p, p2, p3)
	if type(eggAnchors) ~= "table" or #eggAnchors < 2 then
		return p
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Between(p4, p5, p6)
		if p5[p2] == p4[p2] then
			return p4[p3]
		end

		local v = (p6 - p4[p2]) / (p5[p2] - p4[p2])
		return 10 ^ (math.log10(p4[p3]) + (math.log10(p5[p3]) - math.log10(p4[p3])) * v)
	end

	local v = eggAnchors[1]
	local v2 = eggAnchors[#eggAnchors]

	if p <= v[p2] then
		local between = Between(v, eggAnchors[2], p) -- equivalent call inferred; original call site unknown
		return (math.max(between, 1))
	elseif v2[p2] <= p then
		local v3 = eggAnchors[#eggAnchors - 1]

		if v2[p2] == v3[p2] then
			return v3[p3]
		end

		local v4 = (p - v3[p2]) / (v2[p2] - v3[p2])
		return 10 ^ (math.log10(v3[p3]) + (math.log10(v2[p3]) - math.log10(v3[p3])) * v4)
	else
		for i = 1, #eggAnchors - 1 do
			local v3 = eggAnchors[i]
			local v4 = eggAnchors[i + 1]

			if not (v3[p2] <= p and p <= v4[p2]) then
				continue
			end

			if v4[p2] == v3[p2] then
				return v3[p3]
			end

			local v5 = (p - v3[p2]) / (v4[p2] - v3[p2])
			return 10 ^ (math.log10(v3[p3]) + (math.log10(v4[p3]) - math.log10(v3[p3])) * v5)
		end

		return p
	end
end

function PetAging.InflateEggWeight(p)
	local weightDisplay = General.WeightDisplay or {}
	return (InterpolateAnchors(weightDisplay.EggAnchors, math.max(tonumber(p) or 0, 0), "Real", "Shown"))
end

function PetAging.InflatePetWeight(p)
	local petPerEggKG = tonumber((General.WeightDisplay or {}).PetPerEggKG) or 10
	local v = math.max(tonumber(p) or 0, 0)
	return PetAging.InflateEggWeight(v / petPerEggKG) * petPerEggKG
end

function PetAging.FormatWeight(p, p2)
	local v

	if p2 then
		v = PetAging.InflatePetWeight(p)
	else
		v = PetAging.InflateEggWeight(p)
	end

	return String:AddComma((math.floor(v + 0.5))) .. " KG"
end

function PetAging.SpeedBonusFor(p, p2)
	local petSpeedBonus = General.PetSpeedBonus or {}
	local walkSpeedPerTenfold = tonumber(petSpeedBonus.WalkSpeedPerTenfold) or 10
	local maxBonus = tonumber(petSpeedBonus.MaxBonus) or 30
	local v = PetAging.SpeedMultiplierFor(p) * math.max(tonumber(p2) or 1, 0)

	if v <= 1 then
		return 0
	end

	return (math.min(walkSpeedPerTenfold * math.log10(v), maxBonus))
end

local v = {}

for _, v2 in General.PetSpeedDisplay do
	table.insert(v, {
		Walk = v2.Walk,
		Shown = v2.Shown
	})
end

local ReplicatedStorage5 = game:GetService("ReplicatedStorage")

for _, v2 in require(ReplicatedStorage5:WaitForChild("GameData"):WaitForChild("Pets")) do
	if type(v2.Speed) ~= "number" then
		continue
	end

	local inflateSpeed = PetAging.InflateSpeed(v2.Speed)
	local v3 = false

	for _, v5 in v do
		if not (math.abs(v5.Shown - inflateSpeed) <= math.max(inflateSpeed, 1) * 1e-12) then
			continue
		end

		v5.Walk = v2.MovementSpeed or v2.Speed
		v3 = true
		break
	end

	if not v3 then
		table.insert(v, {
			Walk = v2.MovementSpeed or v2.Speed,
			Shown = inflateSpeed
		})
	end
end

table.sort(v, function(a, b)
	return a.Shown < b.Shown
end)

function PetAging.RealSpeedFor(p, p2, p3)
	local v2 = math.max(PetAging.DisplaySpeedFor(p, p2, p3), 1)
	local v3 = v
	local v4 = tonumber(p) or 0

	if type(v3) == "table" and #v3 >= 2 then
		local v5 = v3[1]
		local v6 = v3[2]

		for i = 1, #v3 - 1 do
			v5 = v3[i]
			v6 = v3[i + 1]

			if v2 <= v6.Shown then
				break
			end
		end

		local v7 = math.log10(v5.Shown)
		local v8 = math.log10(v6.Shown)

		if v7 < v8 then
			local v9 = (math.log10(v2) - v7) / (v8 - v7)
			v4 = v5.Walk + (v6.Walk - v5.Walk) * v9
		end
	end

	local petMovementSpeed = General.PetMovementSpeed or {}
	local v5 = math.max(tonumber(petMovementSpeed.MaxSpeed) or 270, 1)
	local v6 = math.clamp(tonumber(petMovementSpeed.SoftCapStart) or 240, 0, v5)

	if v6 < v4 then
		local v7 = v5 - v6

		if v7 > 0 then
			v4 = v6 + v7 * (1 - math.exp(-(v4 - v6) / v7))
		else
			v4 = v5
		end
	end

	return (math.clamp(v4, 1, v5))
end

function PetAging.DisplaySpeedFor(p, p2, p3)
	return PetAging.InflateSpeed(p) * PetAging.SpeedMultiplierFor(p2) * math.max(tonumber(p3) or 1, 0)
end

local precision = Main.NumberFormatter.with():Notation(Main.Notation.compactWithSuffixThousands({
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp"
})):Precision(Main.Precision.maxSignificantDigits(3))

function PetAging.FormatSpeed(p)
	return precision:Format((math.floor(tonumber(p) or 0)))
end

PetAging.OfflineSecondsPerTick = 60
PetAging.OfflineMaxHours = 24

function PetAging.OfflineIncomeFor(p, p2, p3, p4, p5)
	local v2 = tonumber(p) or 0

	if v2 <= 0 then
		return 0
	end

	local stateFrom = PetAging.StateFrom(p3 or os.time(), nil, p5)
	return (math.floor(math.floor(v2 * (PetAging.WeightFor(p2 or PetAging.WeightStandardKG, stateFrom) / PetAging.WeightStandardKG)) * math.max(
		tonumber(p4) or 1,
		0
	)))
end

function PetAging.OfflinePerHour(p)
	return (math.floor((tonumber(p) or 0) * (3600 / PetAging.OfflineSecondsPerTick)))
end

function PetAging.OfflinePerDay(p)
	return (math.floor((tonumber(p) or 0) * (PetAging.OfflineMaxHours * 3600 / PetAging.OfflineSecondsPerTick)))
end

function PetAging.BirthTimeForAge(p, p2, p3)
	return (p2 or os.time()) - PetAging.CumulativeFor(math.clamp(tonumber(p) or 1, 1, PetAging.MaxAge), p3)
end

return PetAging