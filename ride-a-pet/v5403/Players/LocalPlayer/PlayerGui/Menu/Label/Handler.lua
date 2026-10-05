local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local gameServices = ReplicatedStorage:WaitForChild("GameServices")
local General = require(gameServices:WaitForChild("General"))
local PetAging = require(gameServices:WaitForChild("PetAging"))
local DayNight = require(gameServices:WaitForChild("DayNight"))
local Eggs = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))
local General2 = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local Pets = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Pets"))
local Rebirths = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Rebirths"))
local Mutations = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))
local String = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("String"))
local PetRenderer = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("Game"):WaitForChild("Pets"):WaitForChild("PetRenderer"))
local parent = script.Parent
local rebirths = localPlayer:WaitForChild("SavedData"):WaitForChild("Rebirths")

local function HasGrowingEgg()
	local plot = General:GetPlot(localPlayer)
	local eggs = plot and plot:FindFirstChild("Eggs")

	if not eggs then
		return false
	end

	for _, child in eggs:GetChildren() do
		local egg = Eggs[child.Name]
		local eggData = child:FindFirstChild("EggData")
		local placeTime = eggData and eggData:FindFirstChild("PlaceTime")

		if not (egg and placeTime and placeTime.Value > 0) then
			continue
		end

		local weight = eggData:FindFirstChild("Weight")

		if General2.GrowthTimeFor(egg.GrowthTime, weight and weight.Value or 1) - DayNight.GrowthElapsed(placeTime.Value) > 0 then
			return true
		end
	end

	return false
end

local function OfflineIncomePerDay()
	local total = 0

	for _, v in pairs(PetRenderer.GetAll()) do
		if not (v.OwnerUserId == localPlayer.UserId and v.Model and v.Model.Parent) then
			continue
		end

		local pet = Pets[v.Model.Name]
		total += PetAging.OfflineIncomeFor(
			pet and pet.Income,
			v.BaseWeight,
			v.BirthTime,
			Mutations.CombinedFactor(v.Mutation, v.SpawnMutation),
			v
		)
	end

	local v = math.floor(total * Rebirths.GetMultiplier(rebirths.Value))
	return PetAging.OfflinePerDay(v)
end

local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function Update()
	local text = HasGrowingEgg() and "Your Egg Hatches Offline" or string.format(
		"You Earn $%s/Day Offline",
		String:AddComma(OfflineIncomePerDay())
	)

	if text ~= v then
		v = text
		parent.Text = text
	end
end

local text2 = HasGrowingEgg() and "Your Egg Hatches Offline" or string.format(
	"You Earn $%s/Day Offline",
	String:AddComma(OfflineIncomePerDay())
)

if text2 ~= v then
	v = text2
	parent.Text = text2
end

while true do
	task.wait(1)
	Update() -- equivalent call inferred; original call site unknown
end