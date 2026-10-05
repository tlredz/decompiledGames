local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Data.Assets)
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
local LightVsDarknessEventFlags = require(ReplicatedStorage.Shared.Flags.LightVsDarknessEventFlags)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local rings = ReplicatedStorage.Assets.Models:WaitForChild("Rings")
local guardAreas = Workspace:WaitForChild("World"):WaitForChild("Areas"):WaitForChild("GuardAreas")
local LightVsDarkness = {
	RARITIES = {
		{
			Id = "Normal",
			Weight = 53,
			Points = 10,
			Model = "NormalRing",
			Radius = 0,
			SpinSpeed = 2.4
		},
		{
			Id = "Charged",
			Weight = 30,
			Points = 50,
			Model = "ChargedRing",
			Radius = 0,
			SpinSpeed = 2
		},
		{
			Id = "Secret",
			Weight = 12,
			Points = 250,
			Model = "SecretRing",
			Radius = 0,
			SpinSpeed = 1.7
		},
		{
			Id = "Rainbow",
			Weight = 3,
			Points = 1000,
			Model = "RainbowRing",
			Radius = 0,
			SpinSpeed = 1.4
		}
	}
}
local total = 0
local v = nil

for _, v2 in LightVsDarkness.RARITIES do
	local part = rings:FindFirstChild(v2.Model)
	assert(part and part:IsA("BasePart"), (`Rings.{v2.Model} must be a BasePart`))
	v2.Radius = part.Size.Y / 2
	total += v2.Weight
end

LightVsDarkness.MILESTONES = {
	{
		Frame = "Milestone1",
		Rings = 100,
		Reward = "SpeedBoost15"
	},
	{
		Frame = "Milestone2",
		Rings = 800,
		Reward = "TeamEgg",
		Mutation = "Silver",
		TeamEggCategories = {
			Light = "Jellyfish",
			Darkness = "Dark Gargoyle"
		}
	},
	{
		Frame = "Milestone3",
		Rings = 1500,
		Reward = "Egg",
		EggCategory = "Ringlord"
	}
}

for _, v2 in LightVsDarkness.MILESTONES do
	local eggCategory = v2.EggCategory
	assert(eggCategory == nil or Assets.Directory[eggCategory] ~= nil, (`unknown milestone egg {eggCategory}`))

	for _, v3 in v2.TeamEggCategories or {} do
		assert(Assets.Directory[v3] ~= nil, (`unknown milestone egg {v3}`))
	end

	local mutation = v2.Mutation
	assert(mutation == nil or Mutations.IsKnown(mutation), (`unknown milestone mutation {mutation}`))
end

function LightVsDarkness.MilestoneEggCategory(p: number, p2: string?)
	local v2 = LightVsDarkness.MILESTONES[p]
	local teamEggCategories = v2.TeamEggCategories

	if teamEggCategories == nil then
		return v2.EggCategory
	end

	if p2 == nil then
		return nil
	end

	return teamEggCategories[p2]
end

function LightVsDarkness.MilestoneIcon(p: number, p2: string?)
	if LightVsDarkness.MILESTONES[p].Reward:match("SpeedBoost") then
		return "rbxassetid://78137530993637"
	end

	local milestoneEggCategory = LightVsDarkness.MilestoneEggCategory(p, p2)

	if milestoneEggCategory == nil then
		return nil
	end

	local egg = Assets.Directory[milestoneEggCategory].Egg

	if egg.Icon == "" then
		return Assets.BaseConfig.Egg.Icon
	end

	return egg.Icon
end

function LightVsDarkness.MilestoneQuantity(p: number)
	if LightVsDarkness.MILESTONES[p].Reward ~= "SpeedBoost" then
		return nil
	end

	local v2 = math.max(math.floor(LightVsDarknessEventFlags.MilestoneSpeedBoostSeconds:Get() / 60 + 0.5), 1)
	return (`{v2} {v2 == 1 and "min" or "mins"}`)
end

function LightVsDarkness.MilestoneKey(p: number)
	return (`Milestone{p}`)
end

function LightVsDarkness.MilestoneAttribute(p: number)
	return (`Lvd{LightVsDarkness.MilestoneKey(p)}`)
end

function LightVsDarkness.Template(p: number)
	local part = rings:FindFirstChild(LightVsDarkness.RARITIES[p].Model)
	assert(part and part:IsA("BasePart"), (`Ring template {p} missing`))
	return part
end

function LightVsDarkness.RollRarity(object)
	local number = object:NextNumber(0, total)

	for k, v2 in LightVsDarkness.RARITIES do
		number -= v2.Weight

		if number <= 0 then
			return k
		end
	end

	return #LightVsDarkness.RARITIES
end

function LightVsDarkness.Zones()
	local v2 = v

	if v2 then
		return v2
	end

	local areaBounds = GuardAreaGeometry.ReadAreaBounds(guardAreas)
	table.sort(areaBounds, function(a, b)
		return a.Bounds.Position.X < b.Bounds.Position.X
	end)
	v = areaBounds
	return areaBounds
end

function LightVsDarkness.ZoneIndexAt(vector: Vector3)
	local zones = LightVsDarkness.Zones()
	local v2 = 1e999
	local v3 = 1

	for k, zone in zones do
		if GuardAreaGeometry.IsWithinFootprint(zone.Bounds, vector) then
			return k
		end

		local v4 = math.abs(zone.Bounds.Position.X - vector.X)

		if not (v4 < v2) then
			continue
		end

		v3 = k
		v2 = v4
	end

	return v3
end

function LightVsDarkness.EncodeRings(list)
	local buf = buffer.create(#list * 13)
	local total2 = 0

	for _, v2 in list do
		buffer.writef32(buf, total2, v2.X)
		buffer.writef32(buf, total2 + 4, v2.Y)
		buffer.writef32(buf, total2 + 8, v2.Z)
		buffer.writeu8(buf, total2 + 12, v2.Rarity)
		total2 += 13
	end

	return buf
end

function LightVsDarkness.DecodeRings(buf: buffer)
	local result = {}

	for i = 1, buffer.len(buf) // 13 do
		local v2 = (i - 1) * 13
		result[i] = {
			X = buffer.readf32(buf, v2),
			Y = buffer.readf32(buf, v2 + 4),
			Z = buffer.readf32(buf, v2 + 8),
			Rarity = buffer.readu8(buf, v2 + 12)
		}
	end

	return result
end

return LightVsDarkness