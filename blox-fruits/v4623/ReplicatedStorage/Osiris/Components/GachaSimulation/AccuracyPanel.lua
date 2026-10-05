local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Analysis = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Analysis)
local BarGraph = require(game.ReplicatedStorage.Osiris.Widgets.BarGraph)
local BoxPlot = require(game.ReplicatedStorage.Osiris.Widgets.BoxPlot)
local Present = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Present)
local ScatterPlot = require(game.ReplicatedStorage.Osiris.Widgets.ScatterPlot)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Store)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Types)
local color = Color3.fromRGB(126, 134, 152)
local color2 = Color3.fromRGB(120, 190, 255)

local function drawVerdict(items, data, p)
	local v = nil

	for _, item in items do
		if item.Expected <= 0 or not (v == nil or math.abs(item.Z) > math.abs(v.Z)) then
			continue
		end

		v = item
	end

	Present.stat("rolls", (`{p.RollsDone} over {p.PullsDone} pulls`))
	local stat = Present.stat
	local formatted = `{data.InRange} of {data.Total}`
	local GOOD

	if data.InRange == data.Total then
		GOOD = Present.GOOD
	elseif data.InRange >= data.Total - 1 then
		GOOD = Present.WARN
	else
		GOOD = Present.BAD
	end

	stat("items within 95%", formatted, GOOD)
	local stat2 = Present.stat
	local v4 = string.format("chi2 %.1f on %d df, p = %.3f", data.ChiSquare, data.DegreesOfFreedom, data.PValue)
	local GOOD2

	if data.PValue >= 0.05 then
		GOOD2 = Present.GOOD
	elseif data.PValue >= 0.01 then
		GOOD2 = Present.WARN
	else
		GOOD2 = Present.BAD
	end

	stat2("goodness of fit", v4, GOOD2)

	if v ~= nil then
		Present.stat(
			"furthest off",
			string.format(
				"%s at %s against %s expected (%+.1f sd)",
				v.Label,
				Present.formatChance(v.Observed),
				Present.formatChance(v.Expected),
				v.Z
			),
			Present.deviationColor(v.Z)
		)
	end

	if data.Unexpected > 0 then
		Present.stat("dropped with no listed chance", `{data.Unexpected} items`, Present.WARN)
		Present.note("These had a zero chance when the run started and dropped anyway, which means soft pity or a shifting pool moved them in partway through. They are left out of the fit rather than counted as a miscalibration.")
	end

	if data.PValue < 0.01 then
		Present.note("A p value this low means the run does not look like a draw from the stated chances. With a fresh player each pull that points at the box. Without one it is usually pity and a shrinking pool doing exactly what they were asked to.")
	end
end

local function drawTable(p, outcomes)
	local clone = table.clone(outcomes)
	table.sort(clone, function(a, b)
		return math.abs(a.Z) > math.abs(b.Z)
	end)
	Osiris.Widget.Table({
		Arguments = {
			NumColumns = 6,
			Header = true,
			RowBackground = true,
			OuterBorders = true,
			InnerBorders = true
		}
	}, function(p2)
		p2.SetHeaderColumnIndex(1)

		for _, text in {
			"item",
			"expected",
			"observed",
			"count",
			"sd",
			"95% band"
		} do
			Osiris.Widget.Text({
				Arguments = {
					Text = text
				}
			})
			p2.NextColumn()
		end

		for k, v in clone do
			if k > 12 then
				break
			end

			local v2 = p.ById[v.ItemId]
			local WARN

			if v.Expected > 0 then
				WARN = Present.deviationColor(v.Z)
			else
				WARN = Present.WARN
			end

			local v4 = v
			Osiris.Widget.SameLine({}, function()
				if v2 ~= nil then
					Present.icon(v2.Sprite, 16)
				end

				Osiris.Widget.Text({
					Arguments = {
						Text = v4.Label
					}
				})
			end)
			p2.NextColumn()
			Osiris.Widget.Text({
				Arguments = {
					Text = Present.formatChance(v.Expected)
				}
			})
			p2.NextColumn()
			Osiris.Widget.Text({
				Arguments = {
					Text = Present.formatChance(v.Observed),
					Color = WARN
				}
			})
			p2.NextColumn()
			local text = Osiris.Widget.Text
			local text3

			if v.BonusCount > 0 then
				text3 = `{v.Count} (+{v.BonusCount} pity)`
			else
				text3 = `{v.Count}`
			end

			text({
				Arguments = {
					Text = text3
				}
			})
			p2.NextColumn()
			Osiris.Widget.Text({
				Arguments = {
					Text = not (v.Expected > 0) and "-" or string.format("%+.1f", v.Z),
					Color = WARN
				}
			})
			p2.NextColumn()
			local text2 = Osiris.Widget.Text
			local arguments = {
				Text = `{Present.formatChance(v.Low)} - {Present.formatChance(v.High)}`,
				Color = 0
			}
			local color3

			if v.InRange then
				color3 = Present.GOOD
			else
				color3 = Present.BAD
			end

			arguments.Color = color3
			text2({
				Arguments = arguments
			})
			p2.NextColumn()
		end
	end)
end

return function(p)
	local store = p.Store
	local height = p.Height or store.Arguments.ChartHeight or 240
	local v = store.pool:get()
	local v2 = store.result:get()
	local state = Osiris.State({})
	local state2 = Osiris.State({})
	local state3 = Osiris.State({
		Expected = color,
		Observed = color2
	})
	local state4 = Osiris.State(nil)
	local state5 = Osiris.State({})
	local state6 = Osiris.State({})
	local state7 = Osiris.State({})
	local state8 = Osiris.State({})
	local state9 = Osiris.State({})
	local state10 = Osiris.State({})
	local state11 = Osiris.State({})
	local state12 = Osiris.State({})
	local state13 = Osiris.State({})

	if v == nil then
		Present.note("Solving the box...")
		return
	end

	if v2 == nil or v2.RollsDone == 0 then
		Present.note("Run a simulation to compare what dropped against what the solver said would drop.")
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

	local series = Analysis.buildSeries(v, v4, v3)
	local outcomes, v6 = Analysis.outcomes(v, v2)
	drawVerdict(outcomes, v6, v2)

	if Present.dirty((`{tostring(v2)}|{tostring(v4)}|{v3}|{tostring(v)}`)) then
		local expectedObserved, v7 = Analysis.expectedObserved(series, v2)
		state:set(expectedObserved)
		state2:set(v7)
		state5:set(Analysis.calibrationPoints(series, v2))
		state6:set(series.Colors)
		state7:set(series.Labels)
		state8:set(series.Icons)
		state10:set(Analysis.batchSamples(series, v2))
		state11:set(series.Colors)
		state12:set(series.Labels)
		state13:set(series.Icons)
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Expected against observed"
		}
	})
	BarGraph({
		Id = "GachaSimAccuracyBars",
		Arguments = {
			Height = height,
			ValueFormat = "%.2f%%",
			ValueTicks = 5,
			BarPadding = 0.25,
			GroupPadding = 0.05,
			BarRounding = 2,
			LegendOnBottom = true,
			LegendIconSize = 16
		},
		States = {
			values = state,
			categories = state2,
			colors = state3,
			clickedMark = state4
		}
	})
	Present.note("Grey is the chance the solver reported before the first pull, blue is the share this run actually dropped.")
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Calibration"
		}
	})
	ScatterPlot({
		Id = "GachaSimAccuracyScatter",
		Arguments = {
			Height = height,
			TrendLine = "Linear",
			TrendExtend = true,
			XFormat = "%.2f%%",
			YFormat = "%.2f%%",
			XTicks = 5,
			YTicks = 5,
			MinX = 0,
			MinY = 0,
			LegendOnBottom = true,
			LegendIconSize = 16
		},
		States = {
			values = state5,
			colors = state6,
			labels = state7,
			icons = state8,
			fits = state9
		}
	})
	Present.note("One point per item: expected chance across, observed rate up. A calibrated box sits on the diagonal.")

	for _, key in series.Keys do
		local v7 = state9:get()[key]

		if v7 == nil or v7.Points < 3 then
			continue
		end

		Present.stat(
			series.Labels[key] or key,
			string.format("slope %.2f, r2 %.2f over %d items", v7.Coefficients[2] or 0, v7.RSquared, v7.Points)
		)
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Spread between batches"
		}
	})
	BoxPlot({
		Id = "GachaSimAccuracyBox",
		Arguments = {
			Height = height,
			ValueFormat = "%.2f%%",
			ValueTicks = 5,
			ShowMean = true,
			Horizontal = true,
			LegendOnBottom = true,
			LegendIconSize = 16
		},
		States = {
			values = state10,
			colors = state11,
			labels = state12,
			icons = state13
		}
	})
	Present.note((`The run cut into slices of about {v2.BatchSize} pulls, one box per slice. The width is the swing a single player should expect at this sample size, which is the difference between a rate being wrong and a session feeling unlucky.`))
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Furthest from expectation"
		}
	})
	Osiris.Widget.Checkbox({
		Arguments = {
			Text = "show the table"
		},
		States = {
			isChecked = store.showOutlierTable
		}
	})

	if store.showOutlierTable:get() then
		drawTable(v, outcomes)
	end

	local v7 = state4:get()

	if v7 ~= nil then
		state4:set(nil)

		if v3 and not v5 then
			local key = series.Keys[v7.Index]
			local v8

			if key ~= nil then
				v8 = series.Rarity[key]
			end

			if v8 ~= nil then
				store.drill:set(v8)
			end
		end
	end
end