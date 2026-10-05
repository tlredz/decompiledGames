local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LiveConfig = require(ReplicatedStorage.CAM.Global.LiveConfig)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local SeasonRewards = require(ReplicatedStorage.CAM.Global.SeasonRewards)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local localPlayer = Players.LocalPlayer
local TitleController = {
	Updated = simplesignal.new()
}
local flag = false
local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function fire()
	if flag2 then
		return
	end

	flag2 = true
	task.defer(function()
		flag2 = false
		TitleController.Updated:Fire()
	end)
end

function TitleController.start()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local _, v, v2 = Utility.GetData(localPlayer, true)
		v.PlayerTitles.Unlocked.ChildAdded:Connect(fire)
		v.PlayerTitles.Unlocked.ChildRemoved:Connect(fire)

		for _, child in v.slots:GetChildren() do
			child.EquippedTitles.Vanity:GetPropertyChangedSignal("Value"):Connect(fire)

			for _, child2 in child.EquippedTitles.Boost:GetChildren() do
				child2:GetPropertyChangedSignal("Value"):Connect(fire)
			end
		end

		v2:GetPropertyChangedSignal("Value"):Connect(fire)
		fire() -- equivalent call inferred; original call site unknown
	end)
	LiveConfig.listen(Titles.Live.KEY, fire)
end

function TitleController.IsUnlocked(childName: string)
	local _, v = Utility.GetData(localPlayer)
	return v ~= nil and v.PlayerTitles.Unlocked:FindFirstChild(childName) ~= nil
end

function TitleController.Vanity()
	local data = Utility.GetData(localPlayer)
	local selected = data == nil and "" or data.EquippedTitles.Vanity.Value

	if selected == "" or Titles.Get(selected) == nil then
		return nil
	end

	return selected
end

function TitleController.Boost()
	local data = Utility.GetData(localPlayer)
	local result = {}

	if data == nil then
		return result
	end

	for i = 1, Titles.BoostSlots do
		local value = data.EquippedTitles.Boost[`Slot{i}`].Value

		if value == "" or Titles.Get(value) == nil then
			value = nil
		end

		result[i] = value
	end

	return result
end

function TitleController.Progress(p: string)
	local result = {}
	local v = Titles.Get(p)

	if v == nil then
		return result
	end

	local _, v2 = Utility.GetData(localPlayer)

	for _, requirement in v.requirements do
		local child

		if v2 ~= nil then
			child = v2.PlayerTitles.Progress:FindFirstChild(requirement.counter)
		end

		local current = child == nil and 0 or child.Value
		result[#result + 1] = {
			counter = requirement.counter,
			current = current,
			threshold = requirement.threshold,
			met = requirement.threshold <= current
		}
	end

	return result
end

local function all()
	local all2 = Titles.GetAll()
	local _, v = Utility.GetData(localPlayer)

	for _, v2 in v == nil and {} or v.PlayerTitles.Unlocked:GetChildren() do
		if Titles.Definitions[v2.Name] == nil then
			all2[v2.Name] = Titles.Get(v2.Name)
		end
	end

	return all2
end

function TitleController.List()
	local vanity = TitleController.Vanity()
	local boost = TitleController.Boost()
	local result = {}

	for k, def in all() do
		local isUnlocked = TitleController.IsUnlocked(k)

		if not (def.hidden ~= true or isUnlocked) then
			continue
		end

		local boost2 = nil

		for i = 1, Titles.BoostSlots do
			if boost[i] == k then
				boost2 = i
			end
		end

		local prerequisite

		if not (def.prerequisite == nil or TitleController.IsUnlocked(def.prerequisite)) then
			local v3 = Titles.Get(def.prerequisite)

			if v3 == nil then
				prerequisite = def.prerequisite
			else
				prerequisite = v3.displayName
			end
		end

		result[#result + 1] = {
			Id = k,
			Def = def,
			Unlocked = isUnlocked,
			Progress = TitleController.Progress(k),
			Prerequisite = prerequisite,
			Vanity = vanity == k,
			Boost = boost2
		}
	end

	for _, v in SeasonRewards.Previews() do
		result[#result + 1] = {
			Id = v.Id,
			Def = v.Def,
			Unlocked = false,
			Progress = {},
			Vanity = false
		}
	end

	table.sort(result, function(a, b)
		local index = table.find(Rarities.Order, a.Def.rarity) or 0
		local index2 = table.find(Rarities.Order, b.Def.rarity) or 0

		if index == index2 then
			return a.Def.displayName < b.Def.displayName
		end

		return index2 < index
	end)
	return result
end

function TitleController.Totals()
	local count = 0
	local result = {}

	for _, v in all() do
		count += 1
		result[v.category] = (result[v.category] or 0) + 1
	end

	for _, v in SeasonRewards.Previews() do
		count += 1
		result[v.Def.category] = (result[v.Def.category] or 0) + 1
	end

	return count, result
end

function TitleController.Collection()
	local count = 0
	local count2 = 0
	local result = {}

	for k, v in all() do
		count += 1

		if not TitleController.IsUnlocked(k) then
			continue
		end

		count2 += 1

		for _, v2 in v.collection or {} do
			result[v2.stat] = (result[v2.stat] or 0) + v2.amount
		end
	end

	return count2, count, result
end

function TitleController.EquipVanity(titleId: string)
	SignalEvent.ToServer("TitleRequest", {
		action = "equipVanity",
		titleId = titleId
	})
end

function TitleController.UnequipVanity()
	SignalEvent.ToServer("TitleRequest", {
		action = "unequipVanity"
	})
end

function TitleController.EquipBoost(titleId: string, slot: number)
	SignalEvent.ToServer("TitleRequest", {
		action = "equipBoost",
		titleId = titleId,
		slot = slot
	})
end

function TitleController.UnequipBoost(slot: number)
	SignalEvent.ToServer("TitleRequest", {
		action = "unequipBoost",
		slot = slot
	})
end

return TitleController