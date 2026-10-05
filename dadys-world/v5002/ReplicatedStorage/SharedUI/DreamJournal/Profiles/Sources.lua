local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Achievements = require(ReplicatedStorage.SharedData.Achievements)
local Titles = require(ReplicatedStorage.SharedData.Titles)
local Stickers = require(ReplicatedStorage.SharedData.Stickers)
local ProfileStats = require(ReplicatedStorage.SharedData.ProfileStats)
local ProfileBackgrounds = require(ReplicatedStorage.SharedData.ProfileBackgrounds)
local ProfileFrames = require(ReplicatedStorage.SharedData.ProfileFrames)
local ProfileBackdrops = require(ReplicatedStorage.SharedData.ProfileBackdrops)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local ProfileCardConfig = require(ReplicatedStorage.SharedData.ProfileCardConfig)
local Sources = {}

local function extractName(value)
	if type(value) == "string" then
		return value
	end

	if type(value) == "table" then
		local selected = value[1] or value.Name

		if type(selected) == "string" then
			return selected
		end
	end

	return nil
end

local function ownedNameSet(items)
	local result = {}

	if type(items) ~= "table" then
		return result
	end

	for _, item in pairs(items) do
		if type(item) ~= "string" then
			if type(item) == "table" then
				item = item[1] or item.Name

				if type(item) ~= "string" then
					item = nil
				end
			else
				item = nil
			end
		end

		if item then
			result[item] = true
		end
	end

	return result
end

local function researchedNames(p)
	local result = {}
	local research = p.Research

	if type(research) ~= "table" then
		return result
	end

	for _, v in pairs(research) do
		if type(v) ~= "table" then
			continue
		end

		local name = v.Name or v[1]
		local amount = v.Amount or v[2]

		if not (type(name) == "string" and (type(amount) ~= "number" or amount > 0)) then
			continue
		end

		result[name] = true
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sortEntries(sortEntries2)
	table.sort(sortEntries2, function(a, b)
		if a.Owned ~= b.Owned then
			return a.Owned
		end

		if a.SortKey == b.SortKey then
			return a.Id < b.Id
		end

		return a.SortKey < b.SortKey
	end)
end

local v = {
	Toons = function(p, p2)
		local sortEntries2 = {}

		if p2 and p2.IgnoreOwnership then
			local success, result = pcall(function()
				return TowerLUT:GetChildren()
			end)

			if success and type(result) == "table" then
				for _, moduleScript in ipairs(result) do
					if moduleScript:IsA("ModuleScript") then
						table.insert(sortEntries2, {
							Id = moduleScript.Name,
							Owned = true,
							SortKey = moduleScript.Name
						})
					end
				end
			end

			sortEntries(sortEntries2) -- equivalent call inferred; original call site unknown
			return sortEntries2
		else
			local v2 = ownedNameSet(p.Towers)

			for k in pairs(v2) do
				if TowerLUT:GetTower(k) then
					table.insert(sortEntries2, {
						Id = k,
						Owned = true,
						SortKey = k
					})
				end
			end

			sortEntries(sortEntries2) -- equivalent call inferred; original call site unknown
			return sortEntries2
		end
	end,
	Twisteds = function(p)
		local v2 = researchedNames(p)
		local sortEntries2 = {}
		local monsterData = ReplicatedStorage:FindFirstChild("MonsterData")

		if not monsterData then
			return sortEntries2
		end

		for _, moduleScript in ipairs(monsterData:GetChildren()) do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local owned = v2[moduleScript.Name] == true
			table.insert(sortEntries2, {
				Id = moduleScript.Name,
				Owned = owned,
				SortKey = moduleScript.Name
			})
		end

		sortEntries(sortEntries2) -- equivalent call inferred; original call site unknown
		return sortEntries2
	end,
	Trinkets = function(p)
		local v2 = ownedNameSet(p.Trinkets)
		local sortEntries2 = {}
		local trinketData = ReplicatedStorage:FindFirstChild("TrinketData")

		if not trinketData then
			return sortEntries2
		end

		for childName in pairs(v2) do
			if trinketData:FindFirstChild(childName) then
				table.insert(sortEntries2, {
					Id = childName,
					Owned = true,
					SortKey = childName
				})
			end
		end

		sortEntries(sortEntries2) -- equivalent call inferred; original call site unknown
		return sortEntries2
	end,
	Medals = function(p)
		local sortEntries2 = {}
		local standard = Achievements.All and Achievements.All.Standard

		if type(standard) ~= "table" then
			return sortEntries2
		end

		local dreamJournal = p.DreamJournal
		local achievements = dreamJournal and dreamJournal.Achievements or {}

		for k, v2 in pairs(standard) do
			local v3

			if type(achievements) == "table" then
				v3 = achievements[k] or nil
			end

			local v4 = (type(v3) ~= "table" or type(v3.Progress) ~= "number") and 0 or v3.Progress or 0
			local v5 = type(v2.Requirement) ~= "number" and 0 or v2.Requirement or 0
			local owned

			if v5 > 0 then
				owned = v5 <= v4
			else
				owned = false
			end

			if not (owned or not v2.Hidden) then
				continue
			end

			local v7 = type(v2.NumericIndex) ~= "number" and 999 or v2.NumericIndex or 999
			table.insert(sortEntries2, {
				Id = k,
				Owned = owned,
				SortKey = string.format("%04d", v7)
			})
		end

		sortEntries(sortEntries2) -- equivalent call inferred; original call site unknown
		return sortEntries2
	end,
	Titles = function(p)
		local titles = p.Titles
		local sortEntries2 = {}

		if type(titles) ~= "table" then
			return sortEntries2
		end

		for k in pairs(titles) do
			if Titles[k] then
				table.insert(sortEntries2, {
					Id = k,
					Owned = true,
					SortKey = Titles[k].DisplayName or k
				})
			end
		end

		sortEntries(sortEntries2) -- equivalent call inferred; original call site unknown
		return sortEntries2
	end,
	Stats = function()
		local sortEntries2 = {}

		for i, id in ipairs(ProfileStats.GetEnabledOrdered()) do
			table.insert(sortEntries2, {
				Id = id,
				Owned = true,
				SortKey = string.format("%04d", i)
			})
		end

		return sortEntries2
	end
}

function Sources.HasArt(p: string)
	local sticker = Stickers[p]
	return type(sticker) == "table" and (sticker.DisplayImage and sticker.DisplayImage ~= "" and true or sticker.Image and sticker.Image ~= "")
end

function Sources.IsTextOnly(p: string)
	return Stickers[p] ~= nil and not Sources.HasArt(p)
end

function Sources.StickerText(p: string)
	local sticker = Stickers[p]

	if type(sticker) ~= "table" then
		return ""
	end

	local text = sticker.Text

	if type(text) == "string" and text ~= "" then
		return text
	end

	return type(sticker.DisplayName) == "string" and sticker.DisplayName or ""
end

function v.Stickers(p, p2)
	local stickersOwned = p.StickersOwned
	local sortEntries2 = {}

	if type(stickersOwned) ~= "table" then
		return sortEntries2
	end

	local v2

	if p2 == nil then
		v2 = false
	else
		v2 = p2.IncludeTextOnly == true
	end

	local v3 = {}

	for _, id in ipairs(stickersOwned) do
		if v3[id] then
			continue
		end

		v3[id] = true
		local sticker = Stickers[id]

		if not (type(sticker) == "table" and (Sources.HasArt(id) or v2)) then
			continue
		end

		table.insert(sortEntries2, {
			Id = id,
			Owned = true,
			SortKey = sticker.DisplayName or id
		})
	end

	sortEntries(sortEntries2) -- equivalent call inferred; original call site unknown
	return sortEntries2
end

function v.Backgrounds(p)
	local v2 = ownedNameSet(p.BackgroundsOwned)
	local sortEntries2 = {}

	for _, id in ipairs(ProfileBackgrounds.GetOrdered()) do
		local v4 = ProfileBackgrounds.Get(id)

		if not v4 then
			continue
		end

		local owned = not ProfileBackgrounds.RequiresOwnership(id) or v2[id] == true
		local unlock = v4.Unlock

		if owned and unlock then
			owned = Sources.Has(p, unlock.Type, unlock.Id)
		end

		table.insert(sortEntries2, {
			Id = id,
			Owned = owned,
			SortKey = v4.DisplayName
		})
	end

	return sortEntries2
end

function v.Frames(p)
	local v2 = ownedNameSet(p.FramesOwned)
	local sortEntries2 = {}

	for _, id in ipairs(ProfileFrames.GetOrdered()) do
		local v4 = ProfileFrames.Get(id)

		if v4 then
			table.insert(sortEntries2, {
				Id = id,
				Owned = not ProfileFrames.RequiresOwnership(id) or v2[id] == true,
				SortKey = v4.DisplayName
			})
		end
	end

	return sortEntries2
end

function v.Backdrops(p)
	local v2 = ownedNameSet(p.BackdropsOwned)
	local sortEntries2 = {}

	for _, id in ipairs(ProfileBackdrops.GetOrdered()) do
		local v4 = ProfileBackdrops.Get(id)

		if v4 then
			table.insert(sortEntries2, {
				Id = id,
				Owned = not ProfileBackdrops.RequiresOwnership(id) or v2[id] == true,
				SortKey = v4.DisplayName
			})
		end
	end

	return sortEntries2
end

function Sources.ForType(p, p2: string, p3)
	local v2 = v[p2]

	if not v2 or type(p) ~= "table" then
		return {}
	end

	local success, result = pcall(v2, p, p3)

	if success and type(result) == "table" then
		return result
	end

	return {}
end

function Sources.SkinOwner(p)
	local success, result = pcall(require, p)

	if success and type(result) == "table" and type(result.TowerName) == "string" and result.TowerName ~= "" then
		return result.TowerName
	end

	return p.Parent and p.Parent.Name or nil
end

function Sources.SubjectVariants(p, value: string)
	local result = {}

	if type(p) ~= "table" or type(value) ~= "string" or value == "" then
		return result
	end

	local tower = TowerLUT:GetTower(value)
	local name

	if tower then
		local success, result2 = pcall(require, tower)

		if success and type(result2) == "table" and result2.Name then
			name = result2.Name
		else
			name = value
		end
	else
		name = value
	end

	table.insert(result, {
		Id = ProfileCardConfig.SubjectImageOption,
		Label = name .. " (Image)"
	})
	table.insert(result, {
		Id = ProfileCardConfig.SubjectDefaultSkin,
		Label = name
	})
	local skins = p.Skins

	if type(skins) ~= "table" then
		return result
	end

	local v2 = {}

	for _, skin in pairs(skins) do
		if type(skin) ~= "string" then
			if type(skin) == "table" then
				skin = skin[1] or skin.Name

				if type(skin) ~= "string" then
					skin = nil
				end
			else
				skin = nil
			end
		end

		if not skin or v2[skin] then
			continue
		end

		v2[skin] = true
		local skin2 = TowerLUT:GetSkin(value, skin)

		if not (skin2 and Sources.SkinOwner(skin2) == value) then
			continue
		end

		local success, result2 = pcall(require, skin2)
		local label

		if success and type(result2) == "table" then
			label = result2.Name or skin
		else
			label = skin
		end

		table.insert(result, {
			Id = skin,
			Label = label
		})
	end

	table.sort(result, function(a, b)
		local v3 = a.Id == ProfileCardConfig.SubjectImageOption or a.Id == ProfileCardConfig.SubjectDefaultSkin
		local v4 = b.Id == ProfileCardConfig.SubjectImageOption or b.Id == ProfileCardConfig.SubjectDefaultSkin

		if v3 ~= v4 then
			return v3
		end

		if v3 and v4 then
			return a.Id == ProfileCardConfig.SubjectImageOption
		end

		return a.Label < b.Label
	end)
	return result
end

function Sources.Has(p, p2: string, p3: string)
	for _, v2 in ipairs(Sources.ForType(p, p2)) do
		if v2.Id == p3 then
			return v2.Owned
		end
	end

	return false
end

return Sources