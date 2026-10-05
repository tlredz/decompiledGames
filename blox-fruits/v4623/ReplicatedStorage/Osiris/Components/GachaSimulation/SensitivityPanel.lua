local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Analysis = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Analysis)
local BarGraph = require(game.ReplicatedStorage.Osiris.Widgets.BarGraph)
local PieChart = require(game.ReplicatedStorage.Osiris.Widgets.PieChart)
local Present = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Present)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Store)
local Treemap = require(game.ReplicatedStorage.Osiris.Widgets.Treemap)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Types)

local function drawDiff(p, p2, p3)
	local v = {}

	for _, entry in p.Entries do
		local left = p2.Chances[entry.ItemId] or 0
		local right = p3.Chances[entry.ItemId] or 0

		if left <= 0 and right <= 0 then
			continue
		end

		local ratio = not (left > 0) and 1e999 or right / left

		if not (left > 0 and math.abs(ratio - 1) < 0.05) then
			table.insert(v, {
				ItemId = entry.ItemId,
				Label = entry.Label,
				Left = left,
				Right = right,
				Ratio = ratio
			})
		end
	end

	if #v == 0 then
		Present.note("Nothing moved by more than 5% between these two.")
		return
	end

	table.sort(v, function(a, b)
		local v2 = a.Ratio == 1e999 and 1e999 or math.abs((math.log((math.max(a.Ratio, 1e-9)))))
		local v3 = b.Ratio == 1e999 and 1e999 or math.abs((math.log((math.max(b.Ratio, 1e-9)))))

		if v2 == v3 then
			return a.Right > b.Right
		end

		return v3 < v2
	end)
	Osiris.Widget.Table({
		Arguments = {
			NumColumns = 4,
			Header = true,
			RowBackground = true,
			OuterBorders = true,
			InnerBorders = true
		}
	}, function(p4)
		p4.SetHeaderColumnIndex(1)

		for _, text in {
			"item",
			p2.Name,
			p3.Name,
			"change"
		} do
			Osiris.Widget.Text({
				Arguments = {
					Text = text
				}
			})
			p4.NextColumn()
		end

		for k, v2 in v do
			if k > 14 then
				break
			end

			local v4 = p.ById[v2.ItemId]
			local v5 = v2
			Osiris.Widget.SameLine({}, function()
				if v4 ~= nil then
					Present.icon(v4.Sprite, 16)
				end

				Osiris.Widget.Text({
					Arguments = {
						Text = v5.Label
					}
				})
			end)
			p4.NextColumn()
			Osiris.Widget.Text({
				Arguments = {
					Text = Present.formatChance(v2.Left)
				}
			})
			p4.NextColumn()
			Osiris.Widget.Text({
				Arguments = {
					Text = Present.formatChance(v2.Right)
				}
			})
			p4.NextColumn()
			local GOOD, text

			if v2.Left <= 0 then
				GOOD = Present.GOOD
				text = "newly possible"
			elseif v2.Right <= 0 then
				GOOD = Present.BAD
				text = "removed"
			else
				text = string.format("%.2fx", v2.Ratio)

				if v2.Ratio > 1 then
					GOOD = Present.GOOD
				else
					GOOD = Present.WARN
				end
			end

			Osiris.Widget.Text({
				Arguments = {
					Text = text,
					Color = GOOD
				}
			})
			p4.NextColumn()
		end
	end)
end

return function(p)
	local store = p.Store
	local height = p.Height or store.Arguments.ChartHeight or 240
	local v = store.pool:get()
	local v2 = store.scenarios:get()
	local state = Osiris.State({})
	local state2 = Osiris.State({})
	local state3 = Osiris.State({})
	local state4 = Osiris.State({})
	local state5 = Osiris.State(nil)
	local state6 = Osiris.State({})
	local state7 = Osiris.State({})
	local state8 = Osiris.State({})
	local state9 = Osiris.State({})
	local state10 = Osiris.State({})
	local state11 = Osiris.State({})

	if v == nil then
		Present.note("Solving the box...")
		return
	end

	if #v2 == 0 then
		Present.note("Nothing pinned yet. Dial a configuration in the setup window, press \"pin scenario\", change something, and pin again: every pin is a full solve of the box under those inputs.")
		return
	end

	local v3 = store.groupByRarity:get()
	local v4

	if v3 then
		v4 = store.drill:get()
	end

	local v5 = v4 ~= nil

	if Present.drillBar(v4, v.BoxName, store.groupByRarity) then
		store.drill:set(nil)
		v4 = nil
	end

	local v6 = math.clamp(store.scenarioIndex:get(), 1, #v2)

	if v6 ~= store.scenarioIndex:get() then
		store.scenarioIndex:set(v6)
	end

	local series = Analysis.buildSeries(v, v4, v3)
	Osiris.Widget.SameLine({}, function()
		for k, v7 in v2 do
			local v8 = k == v6 and "[*] " or "[ ] "

			if not Osiris.Widget.SmallButton({
				Arguments = {
					Text = `{v8}{v7.Name}`
				}
			}).clicked() then
				continue
			end

			store.scenarioIndex:set(k)
		end
	end)
	local v7 = v2[v6]
	Present.note((`{v7.Name}: {v7.Note}`))

	if v7.BoxName ~= v.BoxName then
		Osiris.Widget.Text({
			Arguments = {
				Text = `This scenario was pinned on "{v7.BoxName}", the pool shown is "{v.BoxName}".`,
				Color = Present.WARN,
				Wrapped = true
			}
		})
	end

	if Present.dirty((`{tostring(v2)}|{v6}|{tostring(v4)}|{v3}|{tostring(v)}`)) then
		local scenarioSeries, v8, v9 = Analysis.scenarioSeries(series, v2)
		state:set(scenarioSeries)
		state2:set(v8)
		state3:set(v9)
		state4:set(Analysis.scenarioLabels(v2))
		local v10 = {}

		for k, v11 in Analysis.aggregate(series, v7.Chances) do
			if v11 > 0 then
				v10[k] = v11 * 100
			end
		end

		state6:set(v10)
		state7:set(series.Colors)
		state8:set(series.Labels)
		state9:set(series.Icons)
		state10:set(Analysis.chanceTree(v, v7.Chances))
		state11:set({})
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Scenarios side by side"
		}
	})
	BarGraph({
		Id = "GachaSimSensitivityBars",
		Arguments = {
			Height = height,
			ValueFormat = "%.2f%%",
			ValueTicks = 5,
			BarPadding = 0.25,
			BarRounding = 2,
			LegendOnBottom = true,
			LegendIconSize = 16
		},
		States = {
			values = state,
			categories = state2,
			colors = state3,
			labels = state4,
			clickedMark = state5
		}
	})
	Present.note(v3 and v4 == nil and "One bar per pinned configuration. Click a rarity to open it and see which items inside it moved." or "One bar per pinned configuration, one group per item.")
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = `Where a pull goes: {v7.Name}`
		}
	})
	PieChart({
		Id = "GachaSimSensitivityPie",
		Arguments = {
			Height = height,
			Donut = 0.45,
			ShowPercentages = true,
			ValueFormat = "%.2f%%",
			LegendOnBottom = true,
			LegendIconSize = 16
		},
		States = {
			values = state6,
			colors = state7,
			labels = state8,
			icons = state9
		}
	})
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Chance mass"
		}
	})
	Treemap({
		Id = "GachaSimSensitivityTree",
		Arguments = {
			Height = height + 60,
			MaxDepth = 2,
			ShowValues = true,
			ValueFormat = "%.2f%%",
			LegendOnBottom = true,
			LegendIconSize = 16
		},
		States = {
			root = state10,
			path = state11
		}
	})
	Present.note("Area is chance. The long tail of a box is much easier to see here than on an axis.")

	if #v2 > 1 then
		local v8 = v2[v6 == 1 and 2 or 1]
		Osiris.Widget.SeparatorText({
			Arguments = {
				Text = `What moved: {v8.Name} to {v7.Name}`
			}
		})
		drawDiff(v, v8, v7)
	else
		Present.note("Pin a second configuration to get a side by side difference.")
	end

	local v8 = state5:get()

	if v8 ~= nil then
		state5:set(nil)

		if v3 and not v5 then
			local key = series.Keys[v8.Index]
			local v9

			if key ~= nil then
				v9 = series.Rarity[key]
			end

			if v9 ~= nil then
				store.drill:set(v9)
			end
		end
	end
end