local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local CombatBalance = require(ReplicatedStorage.CAM.Global.CombatBalance)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local Series = require(ReplicatedStorage.CAM.Global.Series)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local ItemSources = require(ReplicatedStorage.CAM.Client.Modules.ItemSources)
local DetailPanel = require(ReplicatedStorage.CAM.Client.Components.Misc.DetailPanel)
local info = faye.Info(0.2, Enum.EasingStyle.Back)
local v = {
	{
		Key = "Stats",
		Header = "Worn"
	},
	{
		Key = "ToolbarStats",
		Header = "On Toolbar"
	},
	{
		Key = "ActiveToolStats",
		Header = "Held"
	}
}

local function linesOf(items)
	local result = {}

	if type(items) ~= "table" then
		return result
	end

	for k, item in items do
		if item == true or type(item) == "number" and item ~= 0 then
			table.insert(result, {
				stat = k,
				amount = item
			})
		end
	end

	table.sort(result, function(a, b)
		return a.stat < b.stat
	end)
	return result
end

local function percentText(value: number)
	return (`{math.round(math.clamp(value, 0, 1) * 10000) / 100}%`)
end

local v2 = {
	CatchChance = true
}

local function fishingLinesOf(items)
	local result = {}

	if type(items) ~= "table" then
		return result
	end

	for k, item in items do
		if v2[k] then
			continue
		end

		local text

		if type(item) == "string" then
			text = item
		else
			if type(item) ~= "number" then
				continue
			end

			if string.find(k, "Multiplier", 1, true) == nil then
				if string.find(k, "Chance", 1, true) == nil then
					if item > 0 then
						text = `+{item}`
					else
						text = tostring(item)
					end
				else
					text = `{math.round(item * 100)}%`
				end
			else
				text = `{item}x`
			end
		end

		table.insert(result, {
			stat = k,
			amount = item,
			text = text
		})
	end

	table.sort(result, function(a, b)
		return a.stat < b.stat
	end)
	return result
end

return function(object, p, p2, p3, p4)
	return object:State(function(callback, object2)
		local v3 = callback(p2)
		local name

		if typeof(v3) == "Instance" then
			name = v3.Name
		elseif typeof(v3) == "string" and v3 ~= "" then
			name = v3
		else
			name = nil
		end

		local v4

		if name == nil then
			v4 = nil
		else
			v4 = Items[name]
		end

		if v4 == nil or name == nil then
			return
		end

		local refineLevel

		if typeof(v3) == "Instance" then
			refineLevel = v3:FindFirstChild("RefineLevel")
		end

		local v5 = refineLevel == nil and 0 or refineLevel.Value
		local multiplier = Series.Multiplier
		local v6

		if typeof(v3) == "Instance" then
			v6 = v3
		end

		local v7 = multiplier(v6)
		local v8 = Series.SetOf(name)
		local v9

		if typeof(v3) == "Instance" and v8 ~= nil then
			v9 = `Tier {Series.TierOf(v3)}`
		else
			v9 = nil
		end

		local v10

		if v9 == nil or not (Series.TierOf(v3) >= Series.PassiveTier) then
			v10 = nil
		elseif v4.HasCombat then
			v10 = Series.Passives[v8]
		elseif v4.SeriesCapstone then
			v10 = Series.OutfitPassives[v8]
		else
			v10 = nil
		end

		local function scaled(items, flag: boolean, flag2: boolean, flag3: boolean?)
			if type(items) ~= "table" then
				return items
			end

			local clone = table.clone(items)

			for k, item in items do
				if type(item) ~= "number" then
					continue
				end

				local v11

				if flag3 == true then
					v11 = CombatBalance.IsWeighted(k)
				else
					v11 = false
				end

				local v12 = not v11 and 1 or CombatBalance.Knob(name, "Upgrades")
				local v13 = not flag and 1 or Refinement.GetStatMultiplier(name, k, v5)
				local v14 = not flag2 and 1 or v7

				if v12 ~= 1 then
					v13 = 1 + (v13 - 1) * v12
					v14 = 1 + (v14 - 1) * v12
				end

				local v15 = v13 * v14 * (not v11 and 1 or CombatBalance.Knob(name, "Stats"))

				if v15 ~= 1 then
					item = math.round(item * v15 * 10000) / 10000
				end

				clone[k] = item
			end

			return clone
		end

		local sections = {}

		for _, v12 in v do
			local v13 = v4[v12.Key]
			local v14

			if v12.Key == "ActiveToolStats" then
				v14 = true
			elseif v12.Key == "Stats" then
				v14 = v4.Refinable == true
			else
				v14 = false
			end

			local v15 = v12.Key ~= "ToolbarStats"
			local lines = linesOf(scaled(v13, v14, v15))
			local v17 = scaled(v13, v14, v15, true)

			for _, v18 in lines do
				local pvp

				if v17 ~= nil then
					pvp = v17[v18.stat]
				end

				if type(pvp) == "number" and pvp ~= v18.amount then
					v18.pvp = pvp
				end
			end

			if #lines > 0 then
				table.insert(sections, {
					Header = v12.Header,
					Lines = lines
				})
			end
		end

		if #sections == 1 then
			sections[1].Header = "Stats"
		end

		local lines2 = fishingLinesOf(scaled(v4.FishingStats, true, true))

		if #lines2 > 0 then
			table.insert(sections, {
				Header = "Fishing",
				Lines = lines2
			})
		end

		local lines3 = {}

		local function list(name2: string?, p5: string, flag: boolean?)
			for _, v14 in CombatBalance.Lines(CombatBalance.Block(name2), p5, flag) do
				table.insert(lines3, {
					stat = v14.Label,
					amount = v14.Share,
					text = `{math.round(v14.Share * 100)}%`
				})
			end
		end

		if v4.HasCombat then
			list(name, "M1 ", true)
		end

		for _, v14 in v4.Skills or {} do
			list(v14.Name, (`{v14.Name} `))
		end

		if #lines3 > 0 then
			table.insert(sections, {
				Header = "Against players",
				Lines = lines3
			})
		end

		local description

		if v10 == nil then
			description = nil
		else
			description = v10.Description
		end

		if v10 ~= nil then
			local name2 = v10.Name

			for _, v14 in CombatBalance.Lines(CombatBalance.Block(name2), (`{name2} `)) do
				description = `{description}\n{v14.Label} against players: {math.round(v14.Share * 100)}%`
			end
		end

		if p3 ~= nil then
			local lines = {}

			for _, v15 in ItemSources.Get(name) do
				table.insert(lines, {
					stat = v15.Where,
					amount = false,
					text = v15.Chance == nil and "" or `{math.round(math.clamp(v15.Chance, 0, 1) * 10000) / 100}%`
				})
			end

			if #lines > 0 then
				table.insert(sections, {
					Header = "Source",
					Lines = lines
				})
			end
		end

		local function extraRows(data)
			local v15

			if v4.Description ~= nil then
				local v16 = object2:Create("TextLabel")
				local v17 = {
					Name = "Description",
					LayoutOrder = 3,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Font = Enum.Font.SourceSansSemibold,
					Text = 0,
					TextWrapped = true,
					TextColor3 = 0,
					TextTransparency = 0.25,
					TextXAlignment = 0,
					TextYAlignment = 0,
					TextSize = 0
				}
				local text

				if v9 == nil then
					text = v4.Description
				else
					text = `{v4.Description}\n\n{v9}`
				end

				v17.Text = text
				v17.TextColor3 = Color3.new(1, 1, 1)
				v17.TextXAlignment = Enum.TextXAlignment.Left
				v17.TextYAlignment = Enum.TextYAlignment.Top
				v17.TextSize = data.bodyTextSize()
				v15 = v16(v17) or nil
			end

			local v16

			if not (v4.Description == nil or v4.Class == nil) then
				v16 = object2:Create("Frame")({
					Name = "DescriptionGap",
					LayoutOrder = 4,
					Size = data.rowHeight(data.SECTION_GAP),
					BackgroundTransparency = 1
				}) or nil
			end

			local v17

			if v4.Class ~= nil then
				v17 = object2:Create("TextLabel")({
					Name = "Class",
					LayoutOrder = 5,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Font = Enum.Font.SourceSansSemibold,
					Text = `Class: {v4.Class}`,
					TextWrapped = true,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0.25,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = data.bodyTextSize()
				}) or nil
			end

			local v18

			if v10 ~= nil then
				v18 = object2:Create("Frame")({
					Name = "PassiveGap",
					LayoutOrder = 6,
					Size = data.rowHeight(data.SECTION_GAP),
					BackgroundTransparency = 1
				}) or nil
			end

			local v19

			if v10 ~= nil then
				v19 = data.sectionHeader(`Passive: {v10.Name}`, 7) or nil
			end

			local v20

			if v10 ~= nil then
				v20 = object2:Create("TextLabel")({
					Name = "Passive",
					LayoutOrder = 8,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Font = Enum.Font.SourceSansSemibold,
					Text = description,
					TextWrapped = true,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0.25,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextSize = data.bodyTextSize()
				}) or nil
			end

			return {
				v15,
				v16,
				v17,
				v18,
				v19,
				v20
			}
		end

		local v14

		if p3 == nil then
			v14 = false
		else
			v14 = callback(p3)[name] ~= true
		end

		local v15 = not v14

		if v15 then
			if p4 == nil then
				v15 = false
			else
				v15 = callback(p4)[name] ~= true
			end
		end

		local rarity = math.clamp(v4.Rarity or 1, 1, #Rarities.Order)
		local v17 = object2:Create("Frame")
		local v18 = {
			Name = "ItemViewer",
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(1, 8, 0, 0),
			Size = object2:Animation(UDim2.fromScale(0.4, 1), info, {
				From = UDim2.fromScale(0.36000000000000004, 0.9)
			}),
			BackgroundTransparency = 1
		}
		local v21 = {
			Name = string.gsub(name, "_", " "),
			Rarity = rarity,
			Locked = v14 or v15 or nil,
			LockIcon = 0,
			Mark = 0,
			Tags = 0,
			Extra = 0,
			Sections = 0
		}
		local lockIcon

		if v15 then
			lockIcon = BunchaIcons.NotHeld
		end

		v21.LockIcon = lockIcon
		local mark

		if v4.Unique == true then
			mark = BunchaIcons.Unique
		end

		v21.Mark = mark
		v21.Tags = v4.AccountWide == true and {
			{
				Text = "Account Wide",
				Icon = BunchaIcons.AccountWide
			}
		} or nil

		if v4.Description == nil and v4.Class == nil and v10 == nil then
			extraRows = nil
		end

		v21.Extra = extraRows
		v21.Sections = sections
		do local _values = table.pack(DetailPanel(object2, p, v21)); for _k = 1, _values.n do v18[_k] = _values[_k] end end
		return v17(v18)
	end)
end