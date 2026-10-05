local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
local Resolve = require(ReplicatedStorage.CAM.Global.Powers.Resolve)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local FightingStyles2 = require(ReplicatedStorage.CAM.Global.Collectibles.FightingStyles)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local isServer = RunService:IsServer()
local v = {
	Name = "Blocking",
	Key = "F",
	CoolDown = 1,
	icon = "http://www.roblox.com/asset/?id=12529007524"
}
local CustomPower = {
	MARKER = "CustomPower",
	SOURCES = {
		Breathings,
		DemonArts,
		FightingStyles,
		Items
	}
}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function kitName(p)
	return (`CustomPower:{p.UserId}`)
end

local function findRow(p: string)
	for _, v3 in CustomPower.SOURCES do
		for _, v4 in v3 do
			if not (type(v4) == "table" and v4[CustomPower.MARKER] ~= true and type(v4.Skills) == "table") then
				continue
			end

			for _, skill in v4.Skills do
				if skill.Name == p then
					return skill, v4, v3 == Breathings
				end
			end
		end
	end

	return nil, nil, false
end

function CustomPower.Lane(p: string)
	local skillInfo = Stats.GetSkillInfo(p)

	if skillInfo ~= nil and (skillInfo.CategoryType == "Weapon" or skillInfo.CategoryType == "Clan") then
		return nil
	end

	local _, v3, v4 = findRow(p)

	if not v4 then
		return "Fist"
	end

	if v3 == nil or v3.Category == nil then
		return "Breathing"
	end

	return v3.Category
end

function CustomPower.CanUse(p, p2: string, p3: number)
	local skillInfo = Stats.GetSkillInfo(p2)
	local category

	if skillInfo ~= nil then
		category = skillInfo.Category or nil
	end

	local categoryType

	if skillInfo ~= nil then
		categoryType = skillInfo.CategoryType or nil
	end

	if category == nil or categoryType == nil then
		return false
	end

	local data = Utility.GetData(p)
	local inventory

	if data ~= nil then
		inventory = data:FindFirstChild("Inventory") or nil
	end

	local v3

	if inventory ~= nil then
		v3 = inventory:FindFirstChild("Inventory") or nil
	end

	if v3 == nil then
		return false
	end

	local v4 = false

	if categoryType == "Weapon" then
		v4 = Utility.HeldItem(data, category) ~= nil

		if not v4 then
			for _, v6 in Utility.HeldEntries(data) do
				local item = Items[v6.Name]

				if not (item ~= nil and item.SkillCategory == category) then
					continue
				end

				v4 = true
				break
			end
		end
	elseif categoryType == "Breathing" or categoryType == "Evil Art" then
		local v5 = categoryType == "Breathing" and "Breathing" or "DemonArt"
		local v6

		if categoryType == "Breathing" then
			v6 = Breathings
		else
			v6 = DemonArts
		end

		local v7 = v6[category]

		for _, v9 in Utility.HeldEntries(data) do
			local item = Items[v9.Name]
			local v10

			if item ~= nil then
				v10 = item[v5] or nil
			end

			if not (v10 ~= nil and Resolve.LaneCarries(v10, category) and (v7 == nil or v7.Category == nil or v7.Category == item.Category)) then
				continue
			end

			v4 = true
			break
		end
	elseif categoryType == "Fighting Style" then
		if FightingStyles2.For(p) == category then
			v4 = true
		else
			v4 = false
		end
	end

	if not v4 then
		return false
	end

	local requirements = Stats.GetRequirements(p, p2)
	return (requirements == nil and 0 or requirements.Mastery or 0) <= p3
end

function CustomPower.Install(p: string, items)
	v2[p] = table.clone(items)
	local skills = { v }
	local skills2 = { v }

	for _, item in items do
		local lane = CustomPower.Lane(item.Name)

		if lane == nil then
			continue
		end

		local row = findRow(item.Name)

		if row == nil then
			warn((`[CustomPower] no authored row for skill "{item.Name}" — skipped`))
		else
			local clone = table.clone(row)

			if lane ~= "Breathing" and lane ~= "Fist" then
				clone.ToolCategory = lane
			end

			local skills3

			if lane == "Fist" then
				skills3 = skills
			else
				skills3 = skills2
			end

			table.insert(skills3, clone)
		end
	end

	DemonArts[p] = {
		Icon = "rbxassetid://74166650843382",
		Skills = skills,
		Mastery = false,
		[CustomPower.MARKER] = true
	}
	Breathings[p] = {
		Icon = "rbxassetid://74166650843382",
		Skills = skills2,
		Mastery = false,
		[CustomPower.MARKER] = true
	}
end

function CustomPower.Grant(instance, picks)
	if not isServer then
		return false
	end

	if instance:GetAttribute("SaveDisabled") ~= true and instance:GetAttribute("SaveDisabledSlot") ~= true then
		warn("[CustomPower] refusing to grant a kit to a saveable player:", instance)
		return false
	end

	local data = Utility.GetData(instance)

	if data == nil then
		return false
	end

	instance:SetAttribute(Stats.LOADOUT_CHANGED_AT, os.clock())
	local name = kitName(instance) -- equivalent call inferred; original call site unknown
	CustomPower.Install(name, picks)
	data.Race.Value = "Hybrid"
	SignalEvent.ToClient(instance, "CustomPowerKit", {
		Name = name,
		Picks = picks
	})
	data.Powers.DemonArt.Value = name
	data.Powers.Breathing.Value = name

	for _, item in picks do
		if select(2, Stats.GetRequirements(instance, item.Name)) then
			continue
		end

		warn((`[CustomPower] "{item.Name}" needs more mastery than this run has — it will not cast`))
	end

	return true
end

function CustomPower.Kit(p)
	return v2[`CustomPower:{p.UserId}`] or {}
end

function CustomPower.Holds(p, p2: string)
	for _, v3 in CustomPower.Kit(p) do
		if v3.Name == p2 then
			return true
		end

		local row = findRow(v3.Name)

		if not (row ~= nil and row.State == true) then
			continue
		end

		for _, v4 in row do
			if type(v4) == "table" and v4.Name == p2 then
				return true
			end
		end
	end

	return false
end

function CustomPower.Add(p, p2)
	local lane = CustomPower.Lane(p2.Name)
	local clone = table.clone(CustomPower.Kit(p))

	for k, v3 in clone do
		local v4

		if lane == nil or v3.Key ~= p2.Key then
			v4 = false
		else
			v4 = CustomPower.Lane(v3.Name) == lane
		end

		if not (v3.Name == p2.Name or v4) then
			continue
		end

		clone[k] = p2
		return CustomPower.Grant(p, clone)
	end

	table.insert(clone, p2)
	return CustomPower.Grant(p, clone)
end

function CustomPower.Remove(p, p2: string)
	local clone = table.clone(CustomPower.Kit(p))

	for k, v3 in clone do
		if v3.Name ~= p2 then
			continue
		end

		table.remove(clone, k)
		return CustomPower.Grant(p, clone)
	end

	return false
end

function CustomPower.Forget(p)
	local v3 = kitName(p) -- equivalent call inferred; original call site unknown
	v2[v3] = nil
	DemonArts[v3] = nil
	Breathings[v3] = nil
end

return CustomPower