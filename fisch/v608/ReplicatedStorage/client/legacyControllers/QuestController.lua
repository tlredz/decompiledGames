local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("SoundService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages.Trove)
local Signal = require(packages.Signal)
local modules = ReplicatedStorage.shared.modules
local Quests = require(modules.Quests)
local DynamicString = require(modules.DynamicString)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local QuestShared = require(modules.QuestShared)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local RomanNumerals = require(ReplicatedStorage.shared.utils.RomanNumerals)
local TimeUtils = require(ReplicatedStorage.shared.utils.TimeUtils)
local titles = require(modules.character.titles)
local Worlds = require(modules.Worlds)
local bobbers = require(modules.fishing.bobbers)
local rods = require(modules.library.rods)
local fish = require(modules.library.fish)
local items = require(modules.library.items)
local stats = require(modules.library.stats)
local bait = require(modules.library.bait)
local charms = require(modules.library.charms)
local eventFlags = require(modules.library.localizedevents.eventFlags)
local enchants = require(modules.library.rods.enchants)
local halos = require(modules.library.halos)
local spears = require(ReplicatedStorage.shared.modules.library.spears)
local mutations = require(modules.fishing.mutations)
local vessels = require(modules.vessels)
local RodSkins = require(modules.RodSkins)
local lanterns = require(modules.library.lanterns)
local companions = require(modules.library.companions)
local skins = require(modules.library.companions.skins)
local rarities = require(modules.library.rarities)
local LocalCurrencies = require(modules.LocalCurrencies)
local statuseffects = require(modules.library.statuseffects)
local accessoryupgrades = require(modules.library.items.accessorydata.accessoryupgrades)
local harpoonGuns = require(modules.library.harpoonGuns)
local HarpoonGunSkins = require(modules.HarpoonGunSkins)
local BoatRacingTracks = require(modules.BoatRacingTracks)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local CurrencyController = require(ReplicatedStorage.client.legacyControllers.CurrencyController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
require(ReplicatedStorage.client.legacyControllers.CrewController)
local playerDataReplicator = DataController.PlayerDataReplicator
require(packages.Net)
local localPlayer = Players.LocalPlayer
local fetched = legacyLocalPlayerData.fetch()
local maid = Trove.new()
local v = {
	[true] = {
		TextColor3 = Color3.fromRGB(162, 234, 166),
		ImageColor3 = Color3.fromRGB(57, 93, 60),
		Image = "rbxassetid://18269827135"
	},
	[false] = {
		TextColor3 = Color3.fromRGB(255, 255, 255),
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		Image = "rbxassetid://17848872395"
	}
}
local QuestController = {
	CompletedSignal = Signal.new(),
	Completed = {}
}

local function ReadDataPath(value: string?)
	if value == nil then
		return fetched
	end

	local v2 = string.split(value, ".")
	local child = fetched

	for i = 1, #v2 do
		if child == nil then
			return nil
		else
			child = child:WaitForChild(v2[i], 5)
		end
	end

	return child
end

local Setup

Setup = function()
	maid:Clean()
	local quests = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("deviceinset"):WaitForChild("quests")

	local function SetupQuest(child)
		local maid2 = Trove.new()
		maid2:Add(child.Destroying:Once(function()
			maid2:Destroy()

			if QuestController.Completed[child.Name] then
				QuestController.Completed[child.Name] = nil
			end
		end))

		if Quests[child.Name].HasCustomData then
			child:WaitForChild("CustomData", 10)
		end

		local questData = QuestShared:GetQuestData(localPlayer, child.Name)

		if not (questData and child.Parent) then
			return
		end

		local match = child.Name:match("%-MASTERY$")

		if match and (not child:FindFirstChild("1") or child["1"].Value < 0) then
			return
		end

		local clone = quests:WaitForChild("questVisualizer"):WaitForChild("template"):Clone()
		local main = clone:WaitForChild("main")

		if script:FindFirstChild(child.Name) and not script[child.Name]:GetAttribute("Loaded") then
			script[child.Name]:SetAttribute("Loaded", tick())
			local module = require(script[child.Name])
			module:Start()
		end

		clone.Name = child.Name
		local title = main:WaitForChild("title")
		title.Text = questData.DisplayName

		if questData.DisplayColor then
			main.title.TextColor3 = questData.DisplayColor
		end

		main.title.icon.Image = questData.Icon
		main.title.icon.ImageColor3 = questData.IconColor

		if questData.Description then
			local subtitle_2 = main:WaitForChild("subtitle")
			subtitle_2.Text = questData.Description
		end

		local subtitle = main.subtitle
		subtitle.Visible = questData.Description ~= nil and questData.Description ~= ""
		local unixTimestamp = questData.ExpiresAt and questData.ExpiresAt.UnixTimestamp

		if not unixTimestamp and questData.HasCustomData then
			local customData = QuestShared:GetCustomData(localPlayer, child.Name)

			if customData and typeof(customData.ExpiresAt) == "number" then
				unixTimestamp = customData.ExpiresAt
			end
		end

		if questData.WishLocked then
			main.title.limited:SetAttribute("ExpiresAt", nil)
			main.title.limited.Text = "Wished"
			main.title.limited.TextColor3 = Color3.fromRGB(178, 201, 255)
			main.title.limited.icon.ImageColor3 = Color3.fromRGB(178, 201, 255)
			main.title.limited.Visible = true
		elseif unixTimestamp then
			main.title.limited:SetAttribute("ExpiresAt", unixTimestamp)
			main.title.limited.Visible = true
		end

		local v3 = {}

		for i = 1, #questData.List do
			local v4 = i
			task.spawn(function()
				local v5 = questData.List[v4]
				local clone2 = quests.questVisualizer:WaitForChild("lineTemplate"):Clone()
				clone2.LayoutOrder = v4 + 2
				clone2.Name = "Line" .. v4
				clone2.Parent = main
				local v6 = nil

				local function Update(instance)
					if match and instance.Value < 0 then
						maid2:Destroy()

						if QuestController.Completed[child.Name] then
							QuestController.Completed[child.Name] = nil
						end
					else
						local goalDescription, v7 = QuestController:GetGoalDescription(child, instance, v4)
						local v8 = v[v7]
						clone2.Text = goalDescription
						clone2.TextColor3 = v8.TextColor3
						clone2.complete.Image = v8.Image
						clone2.complete.ImageColor3 = v8.ImageColor3

						if v7 == true then
							local v9 = not instance and "" or instance.Name or ""

							if not table.find(v3, v9) then
								table.insert(v3, v9)
							end

							if instance and not QuestController.Completed[instance.Parent.Name] then
								QuestController.Completed[instance.Parent.Name] = true
								QuestController.CompletedSignal:Fire(instance.Parent.Name)
							end
						else
							local v9 = not instance and "" or instance.Name or ""
							local index = table.find(v3, v9)

							if index then
								table.remove(v3, index)
							end

							if instance and QuestController.Completed[instance.Parent.Name] then
								QuestController.Completed[instance.Parent.Name] = nil
							end
						end

						main.subtitle.Text = #v3 == #questData.List and questData.CompletedDescription or questData.Description or ""
						main.title.check.Visible = #v3 == #questData.List

						if v6 == false and #v3 == #questData.List then
							clone.shine.ImageColor3 = Color3.fromRGB(149, 234, 139)
							TweenService:Create(
								clone.shine,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									ImageColor3 = Color3.fromRGB(0, 0, 0)
								}
							):Play()
							ReplicatedStorage.resources.sounds.sfx.player.questComplete:Play()
						end

						v6 = instance and #v3 == #questData.List
					end
				end

				maid2:Add(child.ChildAdded:Connect(function(child2)
					if child2.Name == tostring(v4) then
						print("QuestController: Detected new instance", child2.Name, "for quest", child.Name)
						maid2:Add(child2.Changed:Connect(function()
							Update(child2)
						end))
						Update(child2)
					end
				end))

				local function attachUpdateToInstance(child2)
					local maid3 = Trove.new()
					maid3:AttachToInstance(child2)
					maid2:Add(child2.Changed:Connect(function()
						Update(child2)
					end))

					if v5[1] == "HaveRod" then
						maid3:Add(playerDataReplicator:Observe({ "Rods" }, function()
							Update(child2)
						end))
					end

					Update(child2)
				end

				if v5[1] == "DataInstanceValue" then
					Update(nil)
					local thread = coroutine.running()
					local readDataPath = ReadDataPath(v5[2])

					while not readDataPath do
						task.wait(0.1)
						readDataPath = ReadDataPath(v5[2])
					end

					maid2:Add(thread)
					maid2:Add(readDataPath.Changed:Connect(function()
						Update(readDataPath)
					end))
					Update(readDataPath)
				else
					local child2 = child:WaitForChild(v4, 5)

					if child2 then
						attachUpdateToInstance(child2)
					else
						warn("QuestController: Failed to find instance", v4, "for quest", child.Name)
						task.delay(1, function()
							if not child.Parent then
								return
							end

							if child:FindFirstChild(v4) then
								attachUpdateToInstance(child2)
							else
								warn("QuestController: Retry failed for instance", v4, "for quest", child.Name)
							end
						end)
					end
				end
			end)
		end

		clone.Parent = quests
		local tracking = child:WaitForChild("Tracking")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateTracking()
			clone.Visible = tracking.Value
		end

		maid2:Add(clone)
		updateTracking() -- equivalent call inferred; original call site unknown
		maid2:Add(tracking:GetPropertyChangedSignal("Value"):Connect(updateTracking))
		maid2:Add(clone:GetPropertyChangedSignal("Visible"):Connect(updateTracking))
		maid:Add(maid2, "Destroy")
	end

	for _, child in fetched:WaitForChild("QuestActive"):GetChildren() do
		SetupQuest(child)
	end

	maid:Add(fetched:WaitForChild("QuestActive").ChildAdded:Connect(function(child)
		SetupQuest(child)
	end))
	maid:Add(localPlayer.CharacterAdded:Connect(Setup))
end

local function sentenceJoin(value, value2: string)
	local v2 = value2 or "and"

	if typeof(value) == "string" then
		return value
	end

	local v3 = ""

	for k, v4 in value do
		if k > 1 then
			if #value == 2 then
				v3 ..= ` {v2} `
			elseif k == #value then
				v3 ..= `, {v2} `
			else
				v3 ..= ", "
			end
		end

		v3 ..= v4
	end

	return v3
end

local function eventFlagsDesc(eventFlags2, allEventFlags: boolean?)
	if typeof(eventFlags2) ~= "table" or #eventFlags2 == 0 then
		return ""
	end

	if #eventFlags2 == 1 then
		local eventFlag = eventFlags[eventFlags2[1]]

		if eventFlag then
			return (` {eventFlag.Prefix} {eventFlag.DisplayName}`)
		end

		warn((`[QuestController] Unknown EventFlag "{eventFlags2[1]}," please add it to the "eventFlags" library!`))
		return (` during {eventFlag[1]}`)
	else
		local v2 = {}
		local prefixes = {}
		local v3 = allEventFlags and " and " or " or "
		local v4 = allEventFlags and ", and " or ", or "
		local v5 = allEventFlags and "and " or "or "

		for _, displayName in eventFlags2 do
			local eventFlag = eventFlags[displayName]
			local prefix = "during"

			if eventFlag then
				prefix = eventFlag.Prefix
				displayName = eventFlag.DisplayName
			else
				warn((`[QuestController] Unknown EventFlag "{eventFlags2[1]}," please add it to the "eventFlags" library!`))
			end

			if v2[prefix] then
				table.insert(v2[prefix], displayName)
			else
				v2[prefix] = { displayName }
				table.insert(prefixes, prefix)
			end
		end

		local v6 = table.create((#eventFlags2 + #prefixes) * 2 + 1)
		v6[1] = " "

		for k, v7 in prefixes do
			local v8 = k == #prefixes

			if k == 1 or not (#eventFlags2 > 2) then
				if v8 and #eventFlags2 == 2 and #v2[v7] == 1 then
					table.insert(v6, v3)
				end
			else
				table.insert(v6, ", ")

				if v8 and #v2[v7] == 1 then
					table.insert(v6, v5)
				end
			end

			table.insert(v6, v7)
			table.insert(v6, " ")

			for k2, v9 in v2[v7] do
				if k2 ~= 1 then
					local v10 = v8 and k2 == #v2[v7]

					if #eventFlags2 > 2 then
						if v10 then
							table.insert(v6, v4)
						else
							table.insert(v6, ", ")
						end
					elseif v10 then
						table.insert(v6, v3)
					end
				end

				table.insert(v6, v9)
			end
		end

		return table.concat(v6)
	end
end

local function mutationDisplay(p: string)
	local mutation = mutations.Mutations[p]

	if mutation and mutation.Color then
		if typeof(mutation.Color) == "ColorSequence" then
			return FischUtils.GradientRichText(mutation.Display or p, mutation.Color)
		end

		return (`<font color='#{mutation.Color:ToHex()}'>{mutation.Display or p}</font>`)
	else
		return p
	end
end

local function attributeDisplay(data)
	local v2 = {}

	if data.ShinyOrSparkling then
		table.insert(v2, "<font color='#fff0bc'><i>Shiny</i></font> or <font color='#fff0bc'><i>Sparkling</i></font>")
	end

	if data.Shiny then
		table.insert(v2, "<font color='#fff0bc'><i>Shiny</i></font>")
	end

	if data.Sparkling then
		table.insert(v2, "<font color='#fff0bc'><i>Sparkling</i></font>")
	end

	if data.Glitched then
		table.insert(v2, "<font color='#113910'><b>Glitched</b></font>")
	end

	if data.WeightClass then
		table.insert(v2, (`<font color="#8bff89">{data.WeightClass}</font>`))
	end

	if not data.Mutation then
		return (`{table.concat(v2, " ")} `)
	end

	if typeof(data.Mutation) == "table" then
		local v3 = table.create(#data.Mutation)

		for i, v4 in ipairs(data.Mutation) do
			v3[i] = mutationDisplay(v4)
		end

		table.insert(v2, (sentenceJoin(v3, "or")))
	else
		table.insert(v2, mutationDisplay(data.Mutation))
	end

	return (`{table.concat(v2, " ")} `)
end

local function statsDisplay(biteStats)
	local v2 = {}

	for k, _ in biteStats do
		table.insert(v2, k)
	end

	table.sort(v2, function(a, b)
		local stat = stats[a]
		local stat2 = stats[b]
		return (stat and stat.Order or 10000) < (stat2 and stat2.Order or 10000)
	end)
	local v3 = table.create(#v2)

	for i, displayName in ipairs(v2) do
		local item = biteStats[displayName]
		local stat = stats[displayName]

		if item[1] and math.isfinite(item[1]) and item[2] and math.isfinite(item[2]) then
			if item[1] == item[2] then
				v3[i] = DynamicString:StatDisplay(displayName, item[1])
			else
				local statDisplayValue = DynamicString:StatDisplayValue(displayName, item[1])
				local statDisplayValue2 = DynamicString:StatDisplayValue(displayName, item[2])

				if stat then
					displayName = stat.DisplayName or displayName
				end

				v3[i] = `{statDisplayValue}–{statDisplayValue2} {displayName}`
			end
		elseif item[1] and math.isfinite(item[1]) then
			v3[i] = `at least {DynamicString:StatDisplay(displayName, item[1])}`
		elseif item[2] and math.isfinite(item[2]) then
			local statDisplayValue = DynamicString:StatDisplayValue(displayName, item[2])

			if stat then
				displayName = stat.DisplayName or displayName
			end

			v3[i] = `{statDisplayValue} or less {displayName}`
		else
			v3[i] = "???"
		end
	end

	return (sentenceJoin(v3, "and"))
end

function QuestController:GetGoalDescription(instance, instance2, p, flag: boolean?)
	local questData = QuestShared:GetQuestData(localPlayer, instance.Name) or QuestShared:ConvertLegacyQuest(instance)

	if not questData then
		warn((`Failed to find quest data for {instance.Name}`))
		return "???", false
	end

	local v2 = questData.List[p or tonumber(instance2.Name)]

	if not v2 then
		warn((`Failed to find requirement data for {instance.Name} - {p or instance2.Name}`))
		return "???", false
	end

	local v3 = ""
	local v4 = false

	if v2[1] == "SellFish" then
		local value = instance2.Value
		local v5 = v2[2]
		local _ = v5 > 1

		if value < 0 then
			value = v5
		end

		local v6

		if v2[4] and (v2[4].Mutation or v2[4].Shiny or v2[4].Sparkling) then
			local v7 = {}
			local v8 = #v7 + 1
			local v9

			if v2[4].Mutation then
				v9 = v2[4].Mutation or nil
			end

			v7[v8] = v9
			v7[#v7 + 1] = v2[4].Shiny and "Shiny" or nil
			v7[#v7 + 1] = v2[4].Sparkling and "Sparkling" or nil
			v6 = ` (Mutation: {table.concat(v7, ", ")})`
		else
			v6 = ""
		end

		v3 ..= `Sell {v5} {not v2[3] and "fish" or sentenceJoin(v2[3], "or")}{v6} ({value}/{v5})`
	elseif v2[1] == "AppraiseFish" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = math.clamp(math.floor(value), 0, v5)

		if v2[3] then
			v3 ..= `Appraise {sentenceJoin(v2[3], "or")}`
		else
			v3 ..= "Appraise any fish"
		end

		if not flag then
			v3 ..= ` ({v6}/{v5})`
		end

		v4 = v5 <= v6
	elseif v2[1] == "BaitUse" then
		local value = instance2 and instance2.Value or 0
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = math.clamp(value, 0, v5)
		local v7 = v5 > 1
		v3 ..= `Use {v2[2]} {not v2[3] and "bait" or sentenceJoin(v2[3], "or")}{v7 and "s" or ""}`

		if not flag then
			v3 ..= ` ({v6}/{v5})`
		end

		v4 = v5 <= v6
	elseif v2[1] == "TotemUse" then
		local value = instance2.Value
		local v5 = v2[2]
		local v6 = v5 > 1

		if value < 0 then
			value = v5
		end

		v3 ..= `Use {v5} {not v2[3] and "Totem" or sentenceJoin(v2[3], "or")}{v6 and "s" or ""}`

		if not flag then
			v3 ..= ` ({value}/{v5})`
		end

		v4 = v5 <= value
	elseif v2[1] == "ConceptionConch" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = math.clamp(math.floor(value), 0, v5)
		v3 ..= "Use Conception Conch"

		if not flag then
			v3 ..= ` ({v6}/{v5})`
		end

		v4 = v5 <= v6
	elseif v2[1] == "Drive" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = math.clamp(math.floor(value), 0, v5)
		v3 ..= `Drive {v5} studs`

		if not flag then
			v3 ..= ` ({v6}/{v5})`
		end

		v4 = v5 <= v6
	elseif v2[1] == "Travel" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = math.clamp(math.floor(value), 0, v5)
		v3 ..= `Travel {v5} studs`

		if not flag then
			v3 ..= ` ({v6}/{v5})`
		end

		v4 = v5 <= v6
	elseif v2[1] == "DataInstanceValue" then
		v3 ..= v2[4]

		if not flag then
			if instance2 and (instance2.ClassName == "NumberValue" or instance2.ClassName == "IntValue") then
				v3 ..= ` ({instance2.Value}/{v2[3]})`
			elseif typeof(v2[3]) == "number" then
				v3 ..= ` (0/{v2[3]})`
			end
		end

		if instance2 then
			if typeof(instance2.Value) == "number" and typeof(v2[3]) == "number" then
				v4 = v2[3] <= instance2.Value
			else
				v4 = v2[3] == instance2.Value
			end
		else
			v4 = false
		end
	elseif v2[1] == "Custom" then
		local value = instance2.Value

		if typeof(value) == "number" and value < 0 then
			value = v2[2]
		end

		if typeof(v2[3]) == "table" and typeof(instance2.Value) == "number" then
			v3 ..= v2[3][instance2.Value + 1] or v2[3][instance2.Value] or "???"
		else
			v3 ..= v2[3]

			if typeof(v2[2]) == "number" and not flag then
				v3 ..= ` ({math.floor(value)}/{v2[2]})`
			end
		end

		if instance2 then
			if typeof(v2[2]) == "number" then
				v4 = v2[2] <= value
			else
				v4 = v2[2] == instance2.Value
			end
		else
			v4 = false
		end
	elseif v2[1] == "CatchFish" or v2[1] == "CustomCatch" or v2[1] == "CatchFishAny" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = v2[5] or {}
		local v7 = v6.Perfect and "<b>Perfect</b> Catch" or v6.Direct and "<b>Directly</b> Catch" or "Catch"
		local v8 = not v2[3] and "fish" or sentenceJoin(v2[3], "or")
		local v9 = not v2[4] and "" or sentenceJoin(v2[4], "or") .. " "
		local v10 = not v2[6] and "" or " with " .. sentenceJoin(v2[6], "or")
		local v11 = v10 == " with Pinion's Aria" and v7 == "<b>Perfect</b> Catch" and "Without missing any notes, catch" or v7

		if v2[5] and v2[5].Return then
			v11 ..= " and return"
		end

		local v12 = not (v6.Mutation or v6.Shiny or v6.Sparkling or v6.Glitched or v6.WeightClass or v6.ShinyOrSparkling) and "" or attributeDisplay(v6)
		local v13 = not v2[7] and "" or " using " .. table.concat(v2[7], ", ") .. " bait"
		local v14 = ""

		if v2[9] and #v2[9] > 0 then
			local count = #v2[9]
			v14 ..= " enchanted with "

			for k, list in v2[9] do
				if k > 1 then
					if count > 2 then
						v14 ..= ","
					end

					v14 ..= " "

					if k == count then
						v14 ..= "or "
					end
				end

				if type(list) == "string" then
					v14 ..= list
				else
					v14 ..= table.concat(list, " and ")
				end
			end
		end

		v3 ..= `{v11} {v5} {v9}{v12}{v8}{v10}{v14}{v13}{not v6.Locations and "" or ` at {sentenceJoin(v6.Locations, "or")}`}{not v6.Zones and "" or ` in {sentenceJoin(v6.Zones, "or")}`}{not v6.BiteStats and "" or ` with {statsDisplay(v6.BiteStats)}`}{eventFlagsDesc(v6.EventFlags, v6.AllEventFlags)}`

		if instance2 then
			local selectedMutation = instance2.Parent:FindFirstChild("SelectedMutation")

			if selectedMutation then
				v3 ..= ` | Mutation: {selectedMutation.Value}`
			end
		end

		if not flag then
			v3 ..= ` ({value}/{v5})`
		end

		v4 = v5 <= value
	elseif v2[1] == "CatchFishWithCrabCage" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = v2[5] or {}
		local v7 = v6.Perfect and "<b>Perfect</b> Catch" or v6.Direct and "<b>Directly</b> Catch" or "Catch"
		local v8 = not v2[3] and "fish" or sentenceJoin(v2[3], "or")
		local v9 = not v2[4] and "" or sentenceJoin(v2[4], "or") .. " "

		if v2[5] and v2[5].Return then
			v7 ..= " and return"
		end

		v3 ..= `{v7} {v5} {v9}{not (v6.Mutation or v6.Shiny or v6.Sparkling or v6.WeightClass or v6.Glitched or v6.ShinyOrSparkling) and "" or attributeDisplay(v6)}{v8} with Crab Cages{not v6.Locations and "" or ` at {sentenceJoin(v6.Locations, "or")}`}{not v6.Zones and "" or ` in {sentenceJoin(v6.Zones, "or")}`}{not v6.BiteStats and "" or ` with {statsDisplay(v6.BiteStats)}`}{eventFlagsDesc(v6.EventFlags, v6.AllEventFlags)}`

		if not flag then
			v3 ..= ` ({value}/{v5})`
		end

		v4 = v5 <= value
	elseif v2[1] == "CatchFishWithSpear" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = v2[5] or {}
		local v7 = v6.Perfect and "<b>Perfect</b> Catch" or v6.Direct and "<b>Directly</b> Catch" or "Catch"
		local v8 = not v2[3] and "fish" or sentenceJoin(v2[3], "or")
		local v9 = not v2[4] and "" or sentenceJoin(v2[4], "or") .. " "
		local v10 = not v2[6] and " with a spear" or " with " .. sentenceJoin(v2[6], "or")

		if v2[5] and v2[5].Return then
			v7 ..= " and return"
		end

		v3 ..= `{v7} {v5} {v9}{not (v6.Mutation or v6.Shiny or v6.Sparkling or v6.WeightClass or v6.Glitched or v6.ShinyOrSparkling) and "" or attributeDisplay(v6)}{v8}{v10}{not v6.Locations and "" or ` at {sentenceJoin(v6.Locations, "or")}`}{not v6.Zones and "" or ` in {sentenceJoin(v6.Zones, "or")}`}{not v6.BiteStats and "" or ` with {statsDisplay(v6.BiteStats)}`}{eventFlagsDesc(v6.EventFlags, v6.AllEventFlags)}`

		if not flag then
			v3 ..= ` ({value}/{v5})`
		end

		v4 = v5 <= value
	elseif v2[1] == "CatchFishWithHarpoonGun" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = v2[5] or {}
		local v7 = v6.Perfect and "<b>Perfect</b> Catch" or v6.Direct and "<b>Directly</b> Catch" or "Catch"
		local v8 = not v2[3] and "fish" or sentenceJoin(v2[3], "or")
		local v9 = not v2[4] and "" or sentenceJoin(v2[4], "or") .. " "
		local v10 = not v2[6] and " with any Harpoon Gun" or " with " .. sentenceJoin(v2[6], "or")

		if v2[5] and v2[5].Return then
			v7 ..= " and return"
		end

		v3 ..= `{v7} {v5} {v9}{not (v6.Mutation or v6.Shiny or v6.Sparkling or v6.WeightClass or v6.Glitched or v6.ShinyOrSparkling) and "" or attributeDisplay(v6)}{v8}{v10}{not v6.Locations and "" or ` at {sentenceJoin(v6.Locations, "or")}`}{not v6.Zones and "" or ` in {sentenceJoin(v6.Zones, "or")}`}{not v6.BiteStats and "" or ` with {statsDisplay(v6.BiteStats)}`}{eventFlagsDesc(v6.EventFlags, v6.AllEventFlags)}`

		if not flag then
			v3 ..= ` ({value}/{v5})`
		end

		v4 = v5 <= value
	elseif v2[1] == "ObtainItem" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		local v6 = v2[4] or {}
		local v7 = v2[5] or {}
		local v8 = not v2[3] and "fish" or sentenceJoin(v2[3], "or")
		v3 ..= `Obtain {v5} {not (v6.Mutation or v6.Shiny or v6.Sparkling or v6.Glitched or v6.WeightClass) and "" or attributeDisplay(v6)}{v8}{not v7.Suffix and "" or ` {v7.Suffix}`}`

		if not flag then
			v3 ..= ` ({value}/{v5})`
		end

		v4 = v5 <= value
	elseif v2[1] == "HaveRod" then
		local v5 = playerDataReplicator:TryIndex({ "Rods" })

		local function sentenceJoinRods(value)
			if typeof(value) == "string" then
				return value
			end

			local v6 = ""

			for k, v7 in value do
				if k > 1 then
					if #value == 2 then
						v6 ..= " and "
					elseif k == #value then
						v6 ..= ", and "
					else
						v6 ..= ", "
					end
				end

				v6 ..= `<font color="#{(v5 and v5[v7] and Color3.fromRGB(149, 234, 139) or Color3.fromRGB(255, 255, 255)):ToHex()}">{v7}</font>`
			end

			return v6
		end

		local value = instance2.Value
		local v6 = v2[2]

		if value < 0 then
			value = v6
		end

		v3 ..= `Own {not v2[3] and "" or sentenceJoinRods(v2[3])}`

		if not flag then
			v3 ..= ` ({value}/{v6})`
		end

		v4 = v6 <= value
	elseif v2[1] == "PersonalCrewRating" then
		local value = instance2.Value
		local v5 = v2[2]

		if value < 0 then
			value = v5
		end

		v3 ..= `Get a personal crew rating of {NumberUtils:Comma(v5)}`

		if not flag then
			v3 ..= ` ({value}/{v5})`
		end

		v4 = v5 <= value
	elseif v2[1] == "BoatRace" then
		local value = instance2.Value
		local v5 = v2[2]
		local v6 = v2[3]
		local v7 = v2[4]
		local v8 = v2[5]

		if value < 0 then
			value = v5
		end

		local v9 = v5 == 1 and "" or "s"
		local v10 = v5 == 1 and "a" or tostring(v5)
		local v11

		if v8 == 1 then
			v11 = v3 .. `Win {v10} race{v9}`
		elseif v8 == nil then
			v11 = v3 .. `Complete {v10} race{v9}`
		else
			v11 = v3 .. `Place in the top {v8} in {v10} race{v9}`
		end

		if v6 then
			local boatRacingTrack = BoatRacingTracks[v6]

			if boatRacingTrack then
				v3 = v11 .. ` on the {boatRacingTrack.DisplayName or boatRacingTrack.Name} track`
			else
				v3 = v11 .. ` on the {v6} track`
			end
		else
			v3 = v11 .. " on any track"
		end

		if v7 then
			v3 ..= ` in less than {TimeUtils:B(v7)}`
		end

		if not flag and v5 > 1 then
			v3 ..= ` ({value}/{v5})`
		end

		if v5 <= value then
			v4 = true
		else
			v4 = false
		end
	end

	local v5 = ""

	if questData.CustomSufix then
		local customSufix = instance:FindFirstChild("CustomSufix")

		if customSufix then
			v5 = " " .. customSufix.Value
		end
	end

	return v3 .. v5, v4
end

function QuestController.GetGoalDescriptionFromId(_, p: string, p2: number)
	return QuestController:GetGoalDescription(
		QuestShared:GetQuestInstance(localPlayer, p),
		QuestShared:GetObjectiveInstance(localPlayer, p, p2)
	)
end

function QuestController:GetRewardDescription(list, options)
	local v2 = nil
	local icon = nil
	local v3 = options or {}

	if typeof(list[1]) == "table" then
		local v4 = ""

		for k, v5 in list do
			if k > 1 then
				if #list == 2 then
					v4 ..= " and "
				elseif k == #list then
					v4 ..= ", and "
				else
					v4 ..= ", "
				end
			end

			local rewardDescription, v6 = QuestController:GetRewardDescription(v5)
			v4 ..= rewardDescription or ""
			icon = icon or v6
		end

		return v4, icon
	else
		local v4 = list[1]

		if v4 == "Currency" then
			return
				`<font color="#{Worlds.Currencies[list[2]].LabelProperties.TextColor3:ToHex()}"><b>{NumberUtils:Comma(list[3])} {CurrencyController:GetDisplay(list[2])}</b></font>`,
				icon
		elseif v4 == "Xp" then
			return `<b>{NumberUtils:Comma(list[2])} XP</b>`, icon
		elseif v4 == "KeeperXp" then
			return `<b>{NumberUtils:Comma(list[2])} Keeper XP</b>`, icon
		end

		if v4 == "Bait" then
			local v5 = bait[list[2]]

			if not v5 then
				return
			end

			local formatted = `<b><font color="#{rarities.Rarities[v5.Rarity].Color:ToHex()}">{list[2]}</font></b>`

			if not list[2]:find("Bait") then
				formatted ..= " Bait"
			end

			if not v3.AsOne then
				formatted ..= ` ×{list[3] or 1}`
			end

			return formatted, v5.Icon
		elseif v4 == "ItemOrFish" then
			local v5 = items.Items[list[2]] or fish[list[2]]

			if not v5 then
				warn((`rewardTypeDisplays: Entry "{list[2]}" not found in Items or Fish modules`))
				return
			end

			local itemDisplay = FischUtils.ItemDisplay({
				name = list[2],
				sub = list[3]
			}, {
				rich = true,
				add_weight = false,
				disable_newlines = true,
				bold_main = true
			})

			if (not v5.OnlyBuyOne or (list[4] or 1) ~= 1) and not v3.AsOne then
				itemDisplay = `{itemDisplay} ×{list[4] or 1}`
			end

			return itemDisplay, (FischUtils.GetItemIcon(list[2], list[3]))
		else
			if v4 == "Reputation" then
				return `<b>{list[3]} {list[2]}</b> Reputation`, icon
			end

			if v4 == "Rod" then
				local rod = rods[list[2]]

				if not rod then
					warn((`rewardTypeDisplays: Rod "{list[2]}" not found in Rods module`))
					return
				end

				local v5 = {}

				if list[3] and list[3] ~= "none" then
					table.insert(
						v5,
						(`<font color="#{enchants.Enchants[list[3]].Color:ToHex()}"><b>{enchants.Enchants[list[3]].Display}</b></font>`)
					)
				end

				if list[4] and list[4] ~= 0 then
					table.insert(v5, string.format("<b>%+i%% Infusion</b>", list[4]))
				end

				local v6 = #v5 > 0 and ` ({table.concat(v5, ", ")})` or ""
				return `<b><font color="#{rod.Color:ToHex()}">{list[2]}</font></b>{v6}`, rod.Icon
			elseif v4 == "HarpoonGun" then
				local harpoonGun = harpoonGuns[list[2]]

				if harpoonGun then
					return `<b><font color="#{harpoonGun.Color:ToHex()}">{list[2]}</font></b>`, harpoonGun.Icon
				end

				warn((`rewardTypeDisplays: Harpoon Gun "{list[2]}" not found in harpoonGuns module`))
			elseif v4 == "Spear" then
				local spear = spears[list[2]]

				if spear then
					return `<b><font color="#{spear.Color:ToHex()}">{list[2]}</font></b>`, spear.Icon
				end

				warn((`rewardTypeDisplays: Spear "{list[2]}" not found in spears module`))
			elseif v4 == "Title" then
				local title = titles[list[2]]

				if not title then
					warn((`rewardTypeDisplays: Title "{list[2]}" not found in Titles module`))
					return
				end

				local textColor = title.TextColor

				if typeof(textColor) == "ColorSequence" then
					textColor = textColor.Keypoints[1].Value
				end

				local v5

				if title.CustomFont then
					local customFont = title.CustomFont
					v5 = ` family="{customFont.Family}" weight="{customFont.Weight.Value}"`
				else
					v5 = ""
				end

				local formatted = `<stroke color="#{title.StrokeColor:ToHex()}" th="1"><font color="#{textColor:ToHex()}"{v5}>{title.Text}</font></stroke>`

				if title.Bold then
					formatted = `<b>{formatted}</b>`
				end

				if title.Italic then
					formatted = `<i>{formatted}</i>`
				end

				return `"{formatted}" Title`, icon
			elseif v4 == "Skin" then
				local skin = RodSkins.Skins[list[2]]

				if not skin then
					return
				end

				local targetRod = skin.TargetRod
				local v5

				if targetRod then
					v5 = rods[targetRod]
				end

				v2 = `"<b><font color="#{RodSkins.Rarities[skin.Rarity].Color:ToHex()}">{list[2]}</font></b>" skin`
				icon = skin.Icon

				if v3.NoRodInRewards then
					return v2, icon
				end

				return v2 .. ` for <b><font color="#{v5.Color:ToHex()}">{targetRod}</font></b>`, icon
			elseif v4 == "HarpoonGunSkin" then
				local skin = HarpoonGunSkins.Skins[list[2]]

				if not skin then
					return
				end

				local targetGun = skin.TargetGun
				local v5

				if targetGun then
					v5 = harpoonGuns[targetGun]
				end

				v2 = `"<b><font color="#{HarpoonGunSkins.Rarities[skin.Rarity].Color:ToHex()}">{list[2]}</font></b>" skin`
				icon = skin.Icon

				if v3.NoRodInRewards then
					return v2, icon
				end

				return v2 .. ` for <b><font color="#{v5.Color:ToHex()}">{targetGun}</font></b>`, icon
			elseif v4 == "Bobber" then
				local bobber = bobbers.Bobbers[list[2]]

				if not bobber then
					return
				end

				local rarity = rarities.Rarities[bobber.Rarity]
				return
					`"<b>{FischUtils.GradientRichText(bobber.Name, rarity.ColorGradient or rarity.Color)}</b>" Bobber`,
					bobber.Icon
			elseif v4 == "Boat" then
				local v5 = vessels.library[list[2]]

				if v5 then
					return `<b>{list[2]}</b> Boat`, v5.Icon
				end

				warn((`rewardTypeDisplays: Boat "{list[2]}" not found in Vessels module`))
			elseif v4 == "Lantern" then
				local lantern = lanterns[list[2]]

				if not lantern then
					warn((`rewardTypeDisplays: Lantern "{list[2]}" not found in Lanterns module`))
					return
				end

				local formatted = `<b>{list[2]}</b>`

				if not list[2]:find("Lantern") then
					formatted ..= " Lantern"
				end

				return formatted, lantern.Icon
			elseif v4 == "RodEnhancement" then
				local rod = rods[list[2]]

				if not rod then
					warn((`rewardTypeDisplays: Rod "{list[2]}" not found in Rods module`))
					return
				end

				v2 = `<b>{list[4] or list[3]}</b> Enhancement`

				if v3.NoRodInRewards then
					return v2, icon
				end

				return v2 .. ` for <b><font color="#{rod.Color:ToHex()}">{list[2]}</font></b>`, icon
			elseif v4 == "RodMode" then
				local rod = rods[list[2]]

				if not rod then
					warn((`rewardTypeDisplays: Rod "{list[2]}" not found in Rods module`))
					return
				end

				local mode = rod.Modes[list[3]]
				v2 = `<b><font color="#{mode.Color:ToHex()}">{mode.DisplayName}</font></b> Mode`
				icon = mode.Icon

				if v3.NoRodInRewards then
					return v2, icon
				end

				return v2 .. ` for <b><font color="#{rod.Color:ToHex()}">{list[2]}</font></b>`, icon
			else
				if v4 == "LocalCurrency" then
					local localCurrency = LocalCurrencies[list[2]]
					return
						`<b><font color='#{not localCurrency and "ffffff" or localCurrency.Color:ToHex() or "ffffff"}'>{NumberUtils:Comma(list[3])} {localCurrency.DisplayName}</font></b>`,
						icon
				end

				if v4 == "Halo" then
					local halo = halos[list[2]]

					if not halo then
						warn((`rewardTypeDisplays: Halo "{list[2]}" not found in Halos module`))
						return
					end

					local formatted = `<b>{list[2]}</b>`

					if not list[2]:find("Halo") then
						formatted ..= " Supporter Halo"
					end

					return formatted, halo.Icon
				elseif v4 == "Companion" then
					local companion = companions.Companions[list[2]]

					if companion then
						return `<font color="#{companion.Color:ToHex()}"><b>{list[2]}</b></font>`, companion.Icon
					end

					warn((`rewardTypeDisplays: Companion "{list[2]}" not found in Companions module`))
				elseif v4 == "CompanionSkin" then
					local skin = skins.Skins[list[2]]

					if not skin then
						warn((`rewardTypeDisplays: Companion Skin "{list[2]}" not found in Companions module`))
						return
					end

					local color = skins.Rarities[skin.Rarity].Color
					local companion = companions.Companions[skin.TargetCompanion]
					return
						`<font color="#{color:ToHex()}"><b>{list[2]}</b></font> Skin for <font color="#{companion.Color:ToHex()}"><b>{skin.TargetCompanion}</b></font>`,
						skin.Icon or companion.Icon
				else
					if v4 == "CrewRating" then
						return `+{NumberUtils:Comma(list[2])} Crew Rating`, icon
					elseif v4 == "IdolFavor" then
						return `+{NumberUtils:Comma(list[2])} Idol Favor`, icon
					elseif v4 == "RandomSkin" then
						return "Random Skin", icon
					end

					if v4 == "StatusEffect" then
						local clone = table.clone(list[4] or {})

						if clone.Stack then
							clone.StackNumeral = RomanNumerals:ToRoman(clone.Stack)
						end

						return DynamicString:Format(statuseffects[list[2]].NameFormat, clone), icon
					elseif v4 == "AccessoryUpgrade" then
						local accessoryupgrade = accessoryupgrades[list[2]]

						if accessoryupgrade then
							return
								`<b><font color="#{accessoryupgrade.IconColor:ToHex()}">{accessoryupgrade.DisplayName}</font></b> Upgrade`,
								icon
						end

						warn((`Unknown AccessoryUpgrade "{list[2]}"`))
						return `"{list[2]}" Upgrade`, icon
					elseif v4 == "Charm" then
						local charm = charms[list[2]]

						if not charm then
							return v2, icon
						end

						if list[3] and not (list[3] <= 5) then
							return
								`<font color="#{charm.Color:ToHex()}"><b>{charm.Name}</b></font> Level Cap Increased ({list[3] - 5} → {list[3]})`,
								icon
						end

						return `<font color="#{charm.Color:ToHex()}"><b>{charm.Name}</b></font>`, icon
					else
						if v4 == "DisplayOnly" then
							return list[2], icon
						end

						print(list)
						v2 = "???"
						return v2, icon
					end
				end
			end
		end
	end
end

function QuestController:Start()
	Setup()

	for _, child in script:GetChildren() do
		if child:GetAttribute("Disabled") then
			continue
		end

		local module = require(child)
		module:Start()
	end
end

return QuestController