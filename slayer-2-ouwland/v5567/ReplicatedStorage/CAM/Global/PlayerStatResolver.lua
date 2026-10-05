local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SkillTreeConfig = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder.SkillTreeConfig)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local Character_info_provider = require(script.Parent.Character_info_provider)
local ToolLock = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ToolLock)
local PlayerProfile = require(script.Parent.PlayerProfile)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Clans = require(ReplicatedStorage.CAM.Clans)
local MasterySource = require(ReplicatedStorage.CAM.Global.Collectibles.MasterySource)
local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
local CombatMode = require(ReplicatedStorage.CAM.Global.CombatMode)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local PlayerStatResolver = {}
local isServer = RunService:IsServer()
local v = {}
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function disposeSet(list)
	for _, connection in list do
		connection:Disconnect()
	end

	table.clear(list)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bucketKey(player)
	if not player:IsA("Player") then
		return player
	end

	if isServer then
		return player.UserId
	end

	return 0
end

local function getBucket(player)
	if player:IsA("Player") then
		player = not isServer and 0 or player.UserId
	end

	if player == 0 then
		return v
	end

	local v4 = v[player]

	if v4 == nil then
		v4 = {}
		v[player] = v4
	end

	return v4
end

local function clearBucket(player)
	if player:IsA("Player") then
		player = not isServer and 0 or player.UserId
	end

	if player == 0 then
		table.clear(v)
	else
		v[player] = nil
	end
end

local function nilStatInBucket(player, p: string)
	if player:IsA("Player") then
		player = not isServer and 0 or player.UserId
	end

	if player == 0 then
		v[p] = nil
		return
	end

	local v4 = v[player]

	if v4 then
		v4[p] = nil
	end
end

local function notifyStat(player, p: string)
	local v4 = bucketKey(player) -- equivalent call inferred; original call site unknown
	local v5 = v3[v4] and v3[v4][p]

	if not v5 then
		return
	end

	local clone = table.clone(v5)

	for _, v6 in clone do
		local stat = PlayerStatResolver.GetStat(player, p, v6.resolver, v6.data)
		task.spawn(v6.callback, stat)
	end
end

local function notifyAll(player)
	local v4 = bucketKey(player) -- equivalent call inferred; original call site unknown
	local v5 = v3[v4]

	if not v5 then
		return
	end

	local v6 = {}

	for k in v5 do
		table.insert(v6, k)
	end

	for _, v7 in v6 do
		notifyStat(player, v7)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function invalidateAndNotifyAll(player)
	local v4 = bucketKey(player) -- equivalent call inferred; original call site unknown

	if v4 == 0 then
		table.clear(v)
	else
		v[v4] = nil
	end

	notifyAll(player)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function invalidateOneAndNotify(player, p: string)
	local v4 = bucketKey(player) -- equivalent call inferred; original call site unknown

	if v4 == 0 then
		v[p] = nil
	else
		local v5 = v[v4]

		if v5 then
			v5[p] = nil
		end
	end

	notifyStat(player, p)
end

local function roundStat(value)
	if typeof(value) == "number" then
		return math.round(value * 1000) / 1000
	end

	return value
end

local v4 = {}
local v5 = {}

function PlayerStatResolver.GetActiveValueStats(p)
	local result = {}
	local player = Utility.getvaluesfolder(p)

	if player == nil or player:IsA("Player") then
		return result
	end

	local function contribute(p2: string, value)
		if result[p2] == true then
			return
		end

		if typeof(value) == "number" then
			local v6 = result[p2]
			local v7 = typeof(v6) ~= "number" and 0 or v6
			local v8 = result
			local v9

			if StatTypes.HighestOnlyStats[p2] == true then
				v9 = math.max(v7, value)
			else
				v9 = v7 + value
			end

			v8[p2] = v9
		elseif value == true then
			result[p2] = true
		end
	end

	for _, valueBase in player:GetChildren() do
		if CollectionService:HasTag(valueBase, StatTypes.ValueStatTag) then
			for k, v6 in valueBase:GetAttributes() do
				if StatTypes.IsMetaAttribute(k) then
					continue
				end

				local attributeToStat = StatTypes.AttributeToStat(k)

				if result[attributeToStat] == true then
					continue
				end

				if typeof(v6) == "number" then
					local v7 = result[attributeToStat]
					local v8 = typeof(v7) ~= "number" and 0 or v7
					local v9

					if StatTypes.HighestOnlyStats[attributeToStat] == true then
						v9 = math.max(v8, v6)
					else
						v9 = v8 + v6
					end

					result[attributeToStat] = v9
				elseif v6 == true then
					result[attributeToStat] = true
				end
			end
		elseif StatTypes.StatKeyLookup[valueBase.Name] and valueBase:IsA("ValueBase") then
			local name = valueBase.Name
			local value = valueBase.Value

			if result[name] ~= true then
				if typeof(value) == "number" then
					local v6 = result[name]
					local v7 = typeof(v6) ~= "number" and 0 or v6
					local v8

					if StatTypes.HighestOnlyStats[name] == true then
						v8 = math.max(v7, value)
					else
						v8 = v7 + value
					end

					result[name] = v8
				elseif value == true then
					result[name] = true
				end
			end
		end
	end

	for k, v6 in result do
		if typeof(v6) == "number" then
			v6 = math.round(v6 * 1000) / 1000
		end

		result[k] = v6
	end

	return result
end

local function notifyActive(player)
	local v6 = bucketKey(player) -- equivalent call inferred; original call site unknown

	if v4[v6] == nil or v5[v6] then
		return
	end

	v5[v6] = true
	task.defer(function()
		v5[v6] = nil
		local v7 = v4[v6]

		if v7 == nil then
			return
		end

		local activeValueStats = PlayerStatResolver.GetActiveValueStats(player)

		for _, callback in table.clone(v7) do
			task.spawn(callback, activeValueStats)
		end
	end)
end

local function watchSlotValue(p, valueBase, connections)
	if not valueBase:IsA("ValueBase") then
		return
	end

	local valueChangedConnection = valueBase:GetPropertyChangedSignal("Value"):Connect(function()
		invalidateAndNotifyAll(p) -- equivalent call inferred; original call site unknown
	end)
	table.insert(connections, valueChangedConnection)
	local parent = valueBase.Parent
	local parentChangedConnection = nil
	parentChangedConnection = valueBase:GetPropertyChangedSignal("Parent"):Connect(function()
		if valueBase.Parent ~= parent then
			valueChangedConnection:Disconnect()
			parentChangedConnection:Disconnect()
		end
	end)
	table.insert(connections, parentChangedConnection)
end

local function attachConfigWatchers(player, instance, connections)
	local equipped = instance:FindFirstChild("Equipped")

	if equipped and equipped:IsA("ValueBase") then
		table.insert(connections, equipped:GetPropertyChangedSignal("Value"):Connect(function()
			invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
		end))
	end

	local toolbar = instance:FindFirstChild("Toolbar")

	if toolbar then
		for _, child in toolbar:GetChildren() do
			watchSlotValue(player, child, connections)
		end

		table.insert(connections, toolbar.ChildAdded:Connect(function(child)
			invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			watchSlotValue(player, child, connections)
		end))
		table.insert(connections, toolbar.ChildRemoved:Connect(function()
			invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
		end))
	end
end

local function attachValuesFolderWatchers(player, instance, values)
	local function invalidateTagged(object)
		for k, v6 in object:GetAttributes() do
			if StatTypes.IsMetaAttribute(k) or not (typeof(v6) == "number" or typeof(v6) == "boolean") then
				continue
			end

			invalidateOneAndNotify(player, StatTypes.AttributeToStat(k)) -- equivalent call inferred; original call site unknown
		end
	end

	local function onChange(child)
		if CollectionService:HasTag(child, StatTypes.ValueStatTag) then
			invalidateTagged(child)
			local v6 = player
			local v7 = bucketKey(v6) -- equivalent call inferred; original call site unknown

			if v4[v7] ~= nil then
				if v5[v7] then
					return
				end

				v5[v7] = true
				task.defer(function()
					v5[v7] = nil
					local v8 = v4[v7]

					if v8 == nil then
						return
					end

					local activeValueStats = PlayerStatResolver.GetActiveValueStats(v6)

					for _, callback in table.clone(v8) do
						task.spawn(callback, activeValueStats)
					end
				end)
			end
		else
			invalidateOneAndNotify(player, child.Name) -- equivalent call inferred; original call site unknown

			if StatTypes.StatKeyLookup[child.Name] then
				local v7 = player
				local v8 = bucketKey(v7) -- equivalent call inferred; original call site unknown

				if v4[v8] ~= nil then
					if v5[v8] then
						return
					end

					v5[v8] = true
					task.defer(function()
						v5[v8] = nil
						local v9 = v4[v8]

						if v9 == nil then
							return
						end

						local activeValueStats = PlayerStatResolver.GetActiveValueStats(v7)

						for _, callback in table.clone(v9) do
							task.spawn(callback, activeValueStats)
						end
					end)
				end
			end
		end
	end

	local v6 = {}

	local function bindTagged(instance2)
		if v6[instance2] ~= nil then
			return
		end

		local attributeChangedConnection = instance2.AttributeChanged:Connect(function(p: string)
			if StatTypes.IsMetaAttribute(p) then
				return
			end

			invalidateOneAndNotify(player, StatTypes.AttributeToStat(p)) -- equivalent call inferred; original call site unknown
			local v8 = player
			local v9 = bucketKey(v8) -- equivalent call inferred; original call site unknown

			if v4[v9] ~= nil then
				if v5[v9] then
					return
				end

				v5[v9] = true
				task.defer(function()
					v5[v9] = nil
					local v10 = v4[v9]

					if v10 == nil then
						return
					end

					local activeValueStats = PlayerStatResolver.GetActiveValueStats(v8)

					for _, callback in table.clone(v10) do
						task.spawn(callback, activeValueStats)
					end
				end)
			end
		end)
		v6[instance2] = attributeChangedConnection
		table.insert(values, attributeChangedConnection)
		local parentChangedConnection = nil
		parentChangedConnection = instance2:GetPropertyChangedSignal("Parent"):Connect(function()
			if instance2.Parent ~= instance then
				attributeChangedConnection:Disconnect()
				parentChangedConnection:Disconnect()
				v6[instance2] = nil
			end
		end)
		table.insert(values, parentChangedConnection)
	end

	for _, instance2 in instance:GetChildren() do
		if CollectionService:HasTag(instance2, StatTypes.ValueStatTag) then
			bindTagged(instance2)
		end
	end

	table.insert(values, instance.ChildAdded:Connect(function(child)
		onChange(child)

		if CollectionService:HasTag(child, StatTypes.ValueStatTag) then
			bindTagged(child)
		end
	end))
	table.insert(values, instance.ChildRemoved:Connect(onChange))
	table.insert(values, CollectionService:GetInstanceAddedSignal(StatTypes.ValueStatTag):Connect(function(p)
		if p.Parent ~= instance then
			return
		end

		bindTagged(p)
		invalidateTagged(p)
		local v7 = player
		local v8 = bucketKey(v7) -- equivalent call inferred; original call site unknown

		if v4[v8] ~= nil then
			if v5[v8] then
				return
			end

			v5[v8] = true
			task.defer(function()
				v5[v8] = nil
				local v9 = v4[v8]

				if v9 == nil then
					return
				end

				local activeValueStats = PlayerStatResolver.GetActiveValueStats(v7)

				for _, callback in table.clone(v9) do
					task.spawn(callback, activeValueStats)
				end
			end)
		end
	end))
	table.insert(values, CollectionService:GetInstanceRemovedSignal(StatTypes.ValueStatTag):Connect(function(p)
		if p.Parent ~= instance then
			return
		end

		invalidateTagged(p)
		local v7 = player
		local v8 = bucketKey(v7) -- equivalent call inferred; original call site unknown

		if v4[v8] ~= nil then
			if v5[v8] then
				return
			end

			v5[v8] = true
			task.defer(function()
				v5[v8] = nil
				local v9 = v4[v8]

				if v9 == nil then
					return
				end

				local activeValueStats = PlayerStatResolver.GetActiveValueStats(v7)

				for _, callback in table.clone(v9) do
					task.spawn(callback, activeValueStats)
				end
			end)
		end
	end))
end

local function attachAccessoryWatchers(player, instance, connections)
	for _, child in instance:GetChildren() do
		watchSlotValue(player, child, connections)
	end

	table.insert(connections, instance.ChildAdded:Connect(function(child)
		invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
		watchSlotValue(player, child, connections)
	end))
	table.insert(connections, instance.ChildRemoved:Connect(function()
		invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
	end))
end

local function ensureWatchers(player)
	if v2[player] then
		return
	end

	local v6 = {
		main = {},
		config = {},
		values = {},
		accessory = {},
		titles = {},
		skilltree = {},
		clan = {},
		character = {}
	}
	v2[player] = v6

	if player:IsA("Player") then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindConfig(p)
			disposeSet(v6.config) -- equivalent call inferred; original call site unknown
			attachConfigWatchers(player, p, v6.config)
		end

		local items_Config = player:FindFirstChild("Items_Config") or player:FindFirstChild("Items_ConfigServer")

		if items_Config then
			bindConfig(items_Config) -- equivalent call inferred; original call site unknown
		end

		table.insert(v6.main, player.ChildAdded:Connect(function(child)
			if child.Name == "Items_Config" or child.Name == "Items_ConfigServer" then
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
				bindConfig(child) -- equivalent call inferred; original call site unknown
			end
		end))

		local function bindCharacter(character)
			disposeSet(v6.character) -- equivalent call inferred; original call site unknown
			table.insert(v6.character, character:GetAttributeChangedSignal(ToolLock.Attribute):Connect(function()
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end))
			invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
		end

		if player.Character ~= nil then
			bindCharacter(player.Character)
		end

		table.insert(v6.main, player.CharacterAdded:Connect(bindCharacter))

		for _, v7 in { player, workspace } do
			table.insert(v6.main, v7:GetAttributeChangedSignal(CombatMode.Attribute):Connect(function()
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end))
		end

		task.spawn(function()
			local folder = Utility.getvaluesfolder(player, true)

			if v2[player] ~= v6 then
				return
			end

			if folder and folder:IsA("Folder") then
				attachValuesFolderWatchers(player, folder, v6.values)
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
				local v8 = player
				local v9 = bucketKey(v8) -- equivalent call inferred; original call site unknown

				if v4[v9] ~= nil then
					if v5[v9] then
						return
					end

					v5[v9] = true
					task.defer(function()
						v5[v9] = nil
						local v10 = v4[v9]

						if v10 == nil then
							return
						end

						local activeValueStats = PlayerStatResolver.GetActiveValueStats(v8)

						for _, callback in table.clone(v10) do
							task.spawn(callback, activeValueStats)
						end
					end)
				end
			end
		end)
		local count = 0

		local function bindSlotFolders()
			count += 1
			local v7 = count
			disposeSet(v6.accessory) -- equivalent call inferred; original call site unknown
			disposeSet(v6.titles) -- equivalent call inferred; original call site unknown
			disposeSet(v6.skilltree) -- equivalent call inferred; original call site unknown
			disposeSet(v6.clan) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				local data = Utility.GetData(player, true)

				if v2[player] ~= v6 or count ~= v7 or not data then
					return
				end

				local inventory = data:WaitForChild("Inventory", 60)

				if v2[player] ~= v6 or count ~= v7 or not inventory then
					return
				end

				local toolbar = inventory:WaitForChild("Toolbar", 60)

				if v2[player] ~= v6 or count ~= v7 or not toolbar then
					return
				end

				attachAccessoryWatchers(player, toolbar, v6.accessory)
				local accessories = inventory:WaitForChild("Accessories", 60)

				if v2[player] ~= v6 or count ~= v7 or not accessories then
					return
				end

				local stats = accessories:WaitForChild("Stats", 60)

				if v2[player] ~= v6 or count ~= v7 or not stats then
					return
				end

				attachAccessoryWatchers(player, stats, v6.accessory)
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end)
			task.spawn(function()
				local data, v8 = Utility.GetData(player, true)

				if v2[player] ~= v6 or count ~= v7 or not data then
					return
				end

				local equippedTitles = data:WaitForChild("EquippedTitles", 60)

				if v2[player] ~= v6 or count ~= v7 or not equippedTitles then
					return
				end

				local boost = equippedTitles:WaitForChild("Boost", 60)

				if v2[player] ~= v6 or count ~= v7 or not boost then
					return
				end

				local unlocked = v8.PlayerTitles:WaitForChild("Unlocked", 60)

				if v2[player] ~= v6 or count ~= v7 or not unlocked then
					return
				end

				attachAccessoryWatchers(player, boost, v6.titles)
				attachAccessoryWatchers(player, unlocked, v6.titles)
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end)
			task.spawn(function()
				local data = Utility.GetData(player, true)

				if v2[player] ~= v6 or count ~= v7 or not data then
					return
				end

				local skillTreeUnlockedList = data:WaitForChild("SkillTreeUnlockedList", 60)

				if v2[player] ~= v6 or count ~= v7 or not skillTreeUnlockedList then
					return
				end

				attachAccessoryWatchers(player, skillTreeUnlockedList, v6.skilltree)
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end)
			task.spawn(function()
				local data = Utility.GetData(player, true)

				if v2[player] ~= v6 or count ~= v7 or not data then
					return
				end

				local clan2 = data:WaitForChild("Clan", 60)

				if v2[player] ~= v6 or count ~= v7 or not (clan2 and clan2:IsA("ValueBase")) then
					return
				end

				table.insert(v6.clan, clan2:GetPropertyChangedSignal("Value"):Connect(function()
					invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
				end))
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end)
			task.spawn(function()
				local data = Utility.GetData(player, true)

				if v2[player] ~= v6 or count ~= v7 or not data then
					return
				end

				local powers = data:WaitForChild("Powers", 60)

				if v2[player] ~= v6 or count ~= v7 or not powers then
					return
				end

				for _, childName in { "Breathing", "DemonArt" } do
					local valueBase = powers:FindFirstChild(childName)

					if valueBase ~= nil and valueBase:IsA("ValueBase") then
						table.insert(v6.clan, valueBase:GetPropertyChangedSignal("Value"):Connect(function()
							invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
						end))
					end
				end

				local race = data:FindFirstChild("Race")

				if race ~= nil and race:IsA("ValueBase") then
					table.insert(v6.clan, race:GetPropertyChangedSignal("Value"):Connect(function()
						invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
					end))
				end

				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end)
			task.spawn(function()
				local data = Utility.GetData(player, true)

				if v2[player] ~= v6 or count ~= v7 or not data then
					return
				end

				local progression = data:WaitForChild("Progression", 60)

				if v2[player] ~= v6 or count ~= v7 or not progression then
					return
				end

				for _, childName in PlayerProgression.Sides do
					local child = progression:FindFirstChild(childName)
					local max

					if child ~= nil then
						max = child:FindFirstChild("Max") or nil
					end

					if max ~= nil and max:IsA("ValueBase") then
						table.insert(v6.clan, max:GetPropertyChangedSignal("Value"):Connect(function()
							invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
						end))
					end
				end

				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end)
		end

		bindSlotFolders()
		task.spawn(function()
			local _, _, valueBase = Utility.GetData(player, true)

			if v2[player] ~= v6 or (valueBase == nil or not valueBase:IsA("ValueBase")) then
				return
			end

			table.insert(v6.main, valueBase:GetPropertyChangedSignal("Value"):Connect(function()
				bindSlotFolders()
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end))
		end)
		task.spawn(function()
			local _, v7 = Utility.GetData(player, true)

			if v2[player] ~= v6 or v7 == nil then
				return
			end

			local accountItems = v7:WaitForChild("AccountItems", 60)
			local inventory

			if accountItems ~= nil then
				inventory = accountItems:WaitForChild("Inventory", 60)
			end

			if v2[player] ~= v6 or inventory == nil then
				return
			end

			table.insert(v6.main, inventory.ChildAdded:Connect(function()
				invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
			end))
			invalidateAndNotifyAll(player) -- equivalent call inferred; original call site unknown
		end)
	else
		local getvaluesfolder = Utility.getvaluesfolder(player)

		if getvaluesfolder ~= nil then
			attachValuesFolderWatchers(player, getvaluesfolder, v6.values)
		end

		table.insert(v6.main, player.Destroying:Connect(function()
			PlayerStatResolver.ClearCache(player)
		end))
	end
end

local function resolveMasteryData(p, value: string)
	if p == nil or type(p.Mastery) ~= "string" then
		if p ~= nil and type(p.Mastery) == "table" then
			value = p.Mastery.Value or value
		end
	else
		value = p.Mastery
	end

	return
		value,
		p ~= nil and type(p.Mastery) == "table" and p.Mastery.IncrementAmount or gameSettings.expPerMasteryDefault
end

local function _resolveSource(player, childName: string)
	if player:IsA("Player") then
		local v6 = PlayerProfile.skill_info[childName]

		if v6 == nil or not v6.Category then
			if PlayerProfile.mastery_categories._index and PlayerProfile.mastery_categories._index[childName] then
				local masteryData, incrementAmount = resolveMasteryData(MasterySource(childName), childName)
				return "Mastery", {
					name = masteryData,
					incrementAmount = incrementAmount
				}
			else
				if PlayerProfile.mastery_name_set[childName] then
					return "Mastery", childName
				end

				local result = {}

				if SkillTreeConfig[childName] then
					result.SkillTree = true
				end

				local v7 = Character_info_provider.getEquippedItems(player) or {}
				local v8 = Character_info_provider.getEquippedAccessoryStats(player) or {}

				for _, v9 in ipairs(v7) do
					local item = Items[v9]

					if not item then
						continue
					end

					local toolbarStats = item.ToolbarStats

					if toolbarStats then
						if item.ToolbarStats[childName] == nil then
							toolbarStats = false
						else
							toolbarStats = item.ToolbarStats[childName] ~= 0
						end
					end

					if not toolbarStats and item.Skills then
						for _, skill in ipairs(item.Skills) do
							if not (skill.ToolbarStats and skill.ToolbarStats[childName] ~= nil and skill.ToolbarStats[childName] ~= 0) then
								continue
							end

							toolbarStats = true
							break
						end
					end

					if toolbarStats then
						if result.ToolbarEquipped == nil then
							result.ToolbarEquipped = {}
						end

						table.insert(result.ToolbarEquipped, v9)
					end

					if not item.Skills then
						continue
					end

					for _, skill in ipairs(item.Skills) do
						if not (skill.PerformanceStats and skill.PerformanceStats[childName] ~= nil and skill.PerformanceStats[childName] ~= 0) then
							continue
						end

						result.PerformanceStats = true
						break
					end
				end

				local slot = ToolLock.SlotOf(player)
				local entry

				if slot == nil then
					entry = Character_info_provider.Get_equipped_tool(player)
				else
					entry = Character_info_provider.getEquippedItems(player, slot)

					if typeof(entry) ~= "Instance" then
						entry = nil
					end
				end

				if entry ~= nil then
					local name = entry.Name
					local item = Items[name]

					if item then
						local activeToolStats = item.ActiveToolStats

						if activeToolStats then
							if item.ActiveToolStats[childName] == nil then
								activeToolStats = false
							else
								activeToolStats = item.ActiveToolStats[childName] ~= 0
							end
						end

						if not activeToolStats and item.Skills then
							for _, skill in ipairs(item.Skills) do
								if not (skill.ActiveToolStats and skill.ActiveToolStats[childName] ~= nil and skill.ActiveToolStats[childName] ~= 0) then
									continue
								end

								activeToolStats = true
								break
							end
						end

						if activeToolStats then
							result.ActiveTool = { name }

							if typeof(entry) == "Instance" then
								result.ActiveTool.Entry = entry
							end
						end
					end
				end

				for _, v10 in ipairs(v8) do
					local item = Items[v10]

					if not (item and item.Stats and item.Stats[childName] ~= nil and item.Stats[childName] ~= 0) then
						continue
					end

					if result.Accessory == nil then
						result.Accessory = {}
					end

					if not table.find(result.Accessory, v10) then
						table.insert(result.Accessory, v10)
					end
				end

				local data = Utility.GetData(player)
				local clan

				if data ~= nil then
					clan = data:FindFirstChild("Clan") or nil
				end

				local v10

				if clan ~= nil then
					v10 = Clans.GetClan(clan.Value) or nil
				end

				local v11

				if not (v10 == nil or v10.stats == nil) then
					v11 = v10.stats[childName] or nil
				end

				if v11 ~= nil and v11 ~= 0 then
					result.Clan = true
				end

				for _, v12 in Character_info_provider.GetEquippedPowers(player) do
					local v13 = Breathings[v12] or DemonArts[v12]
					local v14

					if not (v13 == nil or v13.Stats == nil) then
						v14 = v13.Stats[childName] or nil
					end

					if not (v14 ~= nil and v14 ~= 0) then
						continue
					end

					result.Power = true
					break
				end

				if PlayerProgression.GetStatTotal(player, childName) ~= 0 then
					result.Progression = true
				end

				local getvaluesfolder = Utility.getvaluesfolder(player)

				if getvaluesfolder ~= nil then
					if getvaluesfolder:FindFirstChild(childName) == nil then
						local statToAttribute = StatTypes.StatToAttribute(childName)

						for _, child in getvaluesfolder:GetChildren() do
							local attribute

							if CollectionService:HasTag(child, StatTypes.ValueStatTag) then
								attribute = child:GetAttribute(statToAttribute) or nil
							end

							if not (typeof(attribute) == "number" or typeof(attribute) == "boolean" or typeof(attribute) == "string") then
								continue
							end

							result.ValueFolder = true
							break
						end
					else
						result.ValueFolder = true
					end
				end

				if Titles.GetStatBonus(player, childName) ~= 0 then
					result.Titles = true
				end

				return result
			end
		else
			local category = v6.Category
			local masterySource = MasterySource(category)

			if masterySource ~= nil and masterySource.Mastery == false then
				return {}
			end

			local masteryData, incrementAmount = resolveMasteryData(masterySource, category)
			return "Mastery", {
				name = masteryData,
				incrementAmount = incrementAmount
			}
		end
	else
		local result = {}
		local attribute = player:GetAttribute(StatTypes.StatToAttribute(childName))

		if typeof(attribute) == "number" or typeof(attribute) == "boolean" then
			result.NpcStats = true
		end

		local getvaluesfolder = Utility.getvaluesfolder(player)

		if getvaluesfolder == nil then
			return result
		end

		if getvaluesfolder:FindFirstChild(childName) ~= nil then
			result.ValueFolder = true
			return result
		end

		local statToAttribute = StatTypes.StatToAttribute(childName)

		for _, child in getvaluesfolder:GetChildren() do
			local attribute2

			if CollectionService:HasTag(child, StatTypes.ValueStatTag) then
				attribute2 = child:GetAttribute(statToAttribute) or nil
			end

			if not (typeof(attribute2) == "number" or typeof(attribute2) == "boolean" or typeof(attribute2) == "string") then
				continue
			end

			result.ValueFolder = true
			return result
		end

		return result
	end
end

function getStatSource(player, p: string)
	local v6 = bucketKey(player) -- equivalent call inferred; original call site unknown
	local v7

	if v6 == 0 then
		v7 = v
	else
		v7 = v[v6]

		if v7 == nil then
			v7 = {}
			v[v6] = v7
		end
	end

	local v8 = v7[p]

	if v8 ~= nil then
		return v8[1], v8[2]
	end

	ensureWatchers(player)
	local v9, v10 = _resolveSource(player, p)
	v7[p] = { v9, v10 }
	return v9, v10
end

local solvers = {
	Accessory = require(script.Solvers.Accessory),
	Clan = require(script.Solvers.Clan),
	Power = require(script.Solvers.Power),
	NpcStats = require(script.Solvers.NpcStats),
	Mastery = require(script.Solvers.Mastery),
	SkillTree = require(script.Solvers.SkillTree),
	ToolbarEquipped = require(script.Solvers.ToolbarEquipped),
	ActiveTool = require(script.Solvers.ActiveTool),
	PerformanceStats = require(script.Solvers.PerformanceStats),
	ValueFolder = require(script.Solvers.ValueFolder),
	Titles = require(script.Solvers.Titles),
	Progression = require(script.Solvers.Progression)
}

local function computeStat(instance, p: string, p2: string?, p3, p4: string?, flag: boolean?)
	if p2 == nil then
		local statSource, v7 = getStatSource(instance, p)

		if statSource == "Mastery" then
			if p4 == "Mastery" then
				return 0
			end

			return solvers.Mastery(instance, p, v7)
		else
			if next(statSource) == nil then
				return nil
			end

			local v8 = StatTypes.HighestOnlyStats[p] == true
			local v9 = 0

			for k, v10 in statSource do
				if k == p4 then
					continue
				end

				local v11 = solvers[k]

				if not v11 then
					continue
				end

				local v12 = v11(instance, p, v10, true, flag) or 0

				if v12 == true then
					return true
				end

				if typeof(v12) ~= "number" then
					continue
				end

				if v8 then
					v9 = math.max(v9, v12)
				else
					v9 += v12
				end
			end

			return v9
		end
	else
		local v7 = solvers[p2]

		if v7 == nil then
			return 0
		end

		if p3 == nil or not p3 then
			p3 = p
		end

		return v7(instance, p, p3, true, flag) or 0
	end
end

function PlayerStatResolver.GetStat(instance, p: string, p2: string?, p3, flag: boolean?)
	if instance == nil or p == nil or typeof(instance) ~= "Instance" then
		return
	end

	local v7 = computeStat(instance, p, p2, p3, nil, flag)

	if typeof(v7) == "number" then
		return math.round(v7 * 1000) / 1000
	end

	return v7
end

function PlayerStatResolver.GetStatExcept(instance, p: string, p2: string)
	if instance == nil or p == nil or typeof(instance) ~= "Instance" then
		return
	end

	local v7 = computeStat(instance, p, nil, nil, p2)

	if typeof(v7) == "number" then
		return math.round(v7 * 1000) / 1000
	end

	return v7
end

function PlayerStatResolver.Attach(player, p: string, callback, p2, p3)
	local resolver

	if type(callback) == "function" then
		p2 = nil
	else
		resolver = callback
		callback = p3
	end

	assert(type(callback) == "function", "PlayerStatResolver.Attach requires a callback")
	local v8 = bucketKey(player) -- equivalent call inferred; original call site unknown
	local v9 = v3[v8]

	if v9 == nil then
		v9 = {}
		v3[v8] = v9
	end

	if v9[p] == nil then
		v9[p] = {}
	end

	local v10 = {
		callback = callback,
		resolver = resolver,
		data = p2
	}
	table.insert(v9[p], v10)
	ensureWatchers(player)
	task.spawn(callback, PlayerStatResolver.GetStat(player, p, resolver, p2))
	return function()
		local v11 = v3[v8] and v3[v8][p]

		if not v11 then
			return
		end

		local index = table.find(v11, v10)

		if index then
			table.remove(v11, index)
		end

		if #v11 == 0 then
			v3[v8][p] = nil
		end
	end
end

function PlayerStatResolver.AttachActiveStats(player, callback)
	assert(type(callback) == "function", "PlayerStatResolver.AttachActiveStats requires a callback")
	local v7 = bucketKey(player) -- equivalent call inferred; original call site unknown
	local callbacks = v4[v7]

	if callbacks == nil then
		callbacks = {}
		v4[v7] = callbacks
	end

	table.insert(callbacks, callback)
	ensureWatchers(player)
	task.spawn(callback, PlayerStatResolver.GetActiveValueStats(player))
	return function()
		local v8 = v4[v7]

		if v8 == nil then
			return
		end

		local index = table.find(v8, callback)

		if index then
			table.remove(v8, index)
		end

		if #v8 == 0 then
			v4[v7] = nil
		end
	end
end

function PlayerStatResolver.AttachActiveStatEvents(p, data)
	local v7 = {}
	return PlayerStatResolver.AttachActiveStats(p, function(items)
		for k, v8 in v7 do
			if items[k] == nil and data.Removed then
				task.spawn(data.Removed, k, v8)
			end
		end

		for k, item in items do
			local v8 = v7[k]

			if v8 == nil then
				if data.Added then
					task.spawn(data.Added, k, item)
				end
			elseif v8 ~= item and data.Changed then
				task.spawn(data.Changed, k, item, v8)
			end
		end

		v7 = items
	end)
end

function PlayerStatResolver.GetMovementMultiplier(p)
	local v7 = PlayerStatResolver.GetStat(p, "Movement Speed Factor") or 0
	local movementFactorFloor = gameSettings.movementFactorFloor or -0.9

	if v7 < movementFactorFloor then
		v7 = movementFactorFloor
	end

	local movementFactorSoftCap = gameSettings.movementFactorSoftCap

	if movementFactorSoftCap ~= nil and movementFactorSoftCap < v7 then
		v7 = movementFactorSoftCap + (v7 - movementFactorSoftCap) * (gameSettings.movementFactorExcessRate or 0)
	end

	local movementFactorHardCap = gameSettings.movementFactorHardCap

	if movementFactorHardCap ~= nil and movementFactorHardCap < v7 then
		v7 = movementFactorHardCap
	end

	return 1 + v7
end

function PlayerStatResolver.Invalidate(player, p: string)
	if player:IsA("Player") then
		player = not isServer and 0 or player.UserId
	end

	if player == 0 then
		v[p] = nil
		return
	end

	local v7 = v[player]

	if v7 then
		v7[p] = nil
	end
end

function PlayerStatResolver.Init(p)
	local v7 = v2[p]

	if v7 then
		for _, v8 in v7 do
			disposeSet(v8) -- equivalent call inferred; original call site unknown
		end

		v2[p] = nil
	end

	ensureWatchers(p)
end

function PlayerStatResolver.ClearCache(player)
	local v7 = bucketKey(player) -- equivalent call inferred; original call site unknown

	if v7 == 0 then
		table.clear(v)
	else
		v[v7] = nil
	end

	local v8 = v2[player]

	if v8 then
		disposeSet(v8.main) -- equivalent call inferred; original call site unknown
		disposeSet(v8.config) -- equivalent call inferred; original call site unknown
		disposeSet(v8.values) -- equivalent call inferred; original call site unknown
		disposeSet(v8.accessory) -- equivalent call inferred; original call site unknown
		disposeSet(v8.titles) -- equivalent call inferred; original call site unknown
		disposeSet(v8.skilltree) -- equivalent call inferred; original call site unknown
		disposeSet(v8.clan) -- equivalent call inferred; original call site unknown
		v2[player] = nil
	end

	if not player:IsA("Player") then
		if player:IsA("Player") then
			player = not isServer and 0 or player.UserId
		end

		v3[player] = nil
		v4[player] = nil
		v5[player] = nil
	end
end

function PlayerStatResolver.Release(player)
	PlayerStatResolver.ClearCache(player)

	if player:IsA("Player") then
		player = not isServer and 0 or player.UserId
	end

	v3[player] = nil
	v4[player] = nil
	v5[player] = nil
end

return PlayerStatResolver