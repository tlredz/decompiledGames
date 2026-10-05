local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Analysis = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Analysis)
local Graph = require(game.ReplicatedStorage.Osiris.Widgets.Graph)
local Histogram = require(game.ReplicatedStorage.Osiris.Widgets.Histogram)
local Present = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Present)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Store)

local function summarise(list)
	if #list == 0 then
		return 0, 0, 0
	end

	local clone = table.clone(list)
	table.sort(clone)
	local total = 0

	for _, v in clone do
		total += v
	end

	local v = clone[math.ceil(#clone / 2)]
	return total / #clone, v, clone[#clone]
end

return function(p)
	local store = p.Store
	local height = p.Height or store.Arguments.ChartHeight or 240
	local v = store.pool:get()
	local v2 = store.result:get()
	local state = Osiris.State({})
	local state2 = Osiris.State({})
	local state3 = Osiris.State({})
	local state4 = Osiris.State({})
	local state5 = Osiris.State({})
	local state6 = Osiris.State(nil)
	local state7 = Osiris.State({})
	local state8 = Osiris.State({})
	local state9 = Osiris.State({})
	local state10 = Osiris.State({})

	if v == nil then
		Present.note("Solving the box...")
		return
	end

	if v2 == nil or v2.PullsDone == 0 then
		Present.note("Run a simulation to watch the box change as a player works through it.")
		return
	end

	local config = v2.Config

	if config.FreshPlayer then
		Osiris.Widget.Text({
			Arguments = {
				Text = "This run reset the player before every pull, so nothing carries and these lines are flat by construction. Turn off \"fresh player each pull\" to see pity and a shrinking pool at work.",
				Color = Present.WARN,
				Wrapped = true
			}
		})
	end

	local v3 = store.groupByRarity:get()
	local v4

	if v3 then
		v4 = store.drill:get()
	end

	if Present.drillBar(v4, v.BoxName, store.groupByRarity) then
		store.drill:set(nil)
		v4 = nil
	end

	local series = Analysis.buildSeries(v, v4, v3)
	local pickerOptions, v5 = Present.pickerOptions(v)

	if v5[store.journeyItem:get()] == nil and #pickerOptions > 0 then
		store.journeyItem:set(Present.pickerLabel(v.Entries[#v.Entries]))
	end

	local v6 = v5[store.journeyItem:get()]

	if store.focusItemId:get() ~= v6 then
		store.focusItemId:set(v6)
	end

	Present.stat("soft pity", (`{config.SoftPity} at the start, {v2.EndSoftPity} at the end`))
	Present.stat("hard pity", (`{config.HardPity} at the start, {v2.EndHardPity} at the end`))

	if config.AccumulateOwned and not config.FreshPlayer then
		Present.stat("items collected", (`{#v2.OwnedGained} new over the run`))
	end

	Present.stat("wall clock", string.format("%.2fs for %d pulls", v2.Elapsed, v2.PullsDone))
	local formatted = `{tostring(v2)}|{tostring(v4)}|{v3}|{tostring(v)}|{tostring(v6)}|{#v2.Snapshots}`

	if Present.dirty(formatted) then
		local journey, v7 = Analysis.journey(series, v2)
		state:set(journey)
		state2:set(v7)
		state3:set(series.Colors)
		state4:set(series.Labels)
		state5:set(series.Icons)
		local gapsByLabel = {}

		if v6 ~= nil then
			local gaps = Analysis.gaps(v2, v6)

			if #gaps > 0 then
				local v8 = v.ById[v6]
				local label

				if v8 == nil then
					label = `#{v6}`
				else
					label = v8.Label
				end

				gapsByLabel[label] = gaps
				local v10

				if v8 == nil then
					v10 = Color3.new(1, 1, 1)
				else
					v10 = v8.Color
				end

				state8:set({
					[label] = v10
				})
				state9:set({
					[label] = label
				})
				state10:set((v8 == nil or v8.Sprite == nil) and {} or {
					[label] = v8.Sprite
				})
			end
		end

		state7:set(gapsByLabel)
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Chances as the player pulls"
		}
	})
	Graph({
		Id = "GachaSimJourneyGraph",
		Arguments = {
			Height = height,
			Resolution = 400,
			NoPoints = true,
			BaselineZero = true,
			XFormat = "pull %d",
			YFormat = "%.2f%%",
			XTicks = 6,
			YTicks = 5,
			LegendOnBottom = true,
			LegendIconSize = 16
		},
		States = {
			values = state,
			xValues = state2,
			colors = state3,
			labels = state4,
			icons = state5,
			hoveredMark = state6
		}
	})
	local v7 = state6:get()

	if v7 == nil then
		local v8 = math.max(1, (math.floor(v2.PullsDone / math.max(1, #v2.Snapshots))))
		Present.note((`{#v2.Snapshots} snapshots, one every {v8} pulls. A rising line is soft pity, a step down is an item leaving the pool.`))
	else
		Present.stat(series.Labels[v7.Key] or v7.Key, string.format("%.3f%% at pull %d", v7.Y, (math.floor(v7.X))))
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "How long between wins"
		}
	})
	Osiris.Widget.ComboArray({
		Arguments = {
			Text = "item"
		},
		States = {
			index = store.journeyItem
		},
		Extra = {
			selectionArray = pickerOptions
		}
	})
	Osiris.Widget.Checkbox({
		Arguments = {
			Text = "cumulative"
		},
		States = {
			isChecked = store.cumulativeGaps
		}
	})

	if v6 ~= nil then
		local gaps = Analysis.gaps(v2, v6)

		if #gaps == 0 then
			local v8 = v2.BaseChances[v6] or 0
			local label = Present.labelOf(v, v6)
			Present.note((`{label} never dropped in {v2.PullsDone} pulls. At {Present.formatChance(v8)} that is {Present.formatOdds(v8)}, so this may just be a short run.`))
		else
			local v8, v9, v10 = summarise(gaps)
			Present.stat("wins", (`{#gaps}`))
			Present.stat("mean gap", string.format("%.1f pulls", v8))
			Present.stat("median gap", (`{v9} pulls`))
			local stat = Present.stat
			local formatted2 = `{v10} pulls`
			local v12

			if v9 * 4 < v10 then
				v12 = Present.WARN
			end

			stat("worst drought", formatted2, v12)
			Histogram({
				Id = "GachaSimJourneyGaps",
				Arguments = {
					Height = height,
					Cumulative = store.cumulativeGaps:get(),
					Normalize = "Percent",
					XFormat = "%d",
					YFormat = "%.0f%%",
					XTicks = 6,
					YTicks = 5,
					BarRounding = 2,
					LegendOnBottom = true,
					LegendIconSize = 16
				},
				States = {
					values = state7,
					colors = state8,
					labels = state9,
					icons = state10
				}
			})
			Present.note("Pulls between one win and the next, counting from the start of the run. Cumulative turns it into \"what share of players have it by pull N\", which is the number to quote when someone asks how long the grind is.")
		end
	end
end