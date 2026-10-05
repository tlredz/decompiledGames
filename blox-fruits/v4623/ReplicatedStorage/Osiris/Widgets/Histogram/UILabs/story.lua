local RunService = game:GetService("RunService")
local Iris = require(game.ReplicatedStorage.Packages.Iris)
local MaterialIcons = require(game.ReplicatedStorage.Packages.MaterialIcons)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local v = {
	Rolls = MaterialIcons.casino,
	Control = MaterialIcons.straighten
}

local function sample(random, p: number, p2: number)
	return p + ((0 + random:NextNumber() + random:NextNumber() + random:NextNumber() + random:NextNumber()) / 4 - 0.5) * p2
end

local function buildSamples(p: number, p2: number, flag: boolean)
	local random = Random.new(p)
	local rolls = table.create(p2)

	for _ = 1, p2 do
		table.insert(rolls, (sample(random, 50, 60)))
	end

	local v3 = {
		Rolls = rolls
	}

	if not flag then
		return v3
	end

	local control = table.create(p2)

	for _ = 1, p2 do
		table.insert(control, (sample(random, 62, 30)))
	end

	v3.Control = control
	return v3
end

return (UILabs.CreateIrisStory({
	name = "Histogram",
	summary = "Distribution of raw samples, with binning, cumulative and normalised modes.",
	controls = {
		Label = "Rolls",
		Height = 260,
		SampleCount = 2000,
		BinCount = 0,
		Cumulative = false,
		Normalize = UILabs.Choose({ "Count", "Percent", "Density" }),
		SecondSet = false,
		Stacked = false,
		Reseed = false,
		BarPadding = 0.02,
		BarRounding = 0,
		LegendOnBottom = false,
		ShowIcons = true,
		NoGrid = false
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local state = Osiris.State({})
	local state2 = Osiris.State({})
	local state3 = Osiris.State(nil)
	local state4 = Osiris.State(nil)
	local v2 = 1
	local v3 = ""
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		state2:set(controls.ShowIcons:get() ~= true and {} or v)
		local v5 = math.clamp(math.floor((controls.SampleCount:get())), 1, 50000)
		local v6 = controls.SecondSet:get() == true
		local v7 = controls.Reseed:get() == true
		local formatted = `{v5}/{tostring(v6)}/{tostring(v7)}`

		if formatted == v3 then
			return
		end

		if v3 ~= "" then
			v2 += 1
		end

		v3 = formatted
		state:set((buildSamples(v2, v5, v6)))
	end)
	local connection = Osiris:Connect(function()
		Osiris.Widget.Window({
			Arguments = {
				Title = "Histogram Widget"
			}
		}, function()
			local binCount = math.floor((controls.BinCount:get()))
			local arguments = {
				Text = controls.Label:get(),
				Height = math.floor((controls.Height:get())),
				BinCount = 0,
				Cumulative = 0,
				Normalize = 0,
				Stacked = 0,
				BarPadding = 0,
				BarRounding = 0,
				LegendOnBottom = 0,
				NoGrid = 0,
				XFormat = "%.0f",
				YFormat = "%.2f"
			}

			if not (binCount > 0) then
				binCount = nil
			end

			arguments.BinCount = binCount
			arguments.Cumulative = controls.Cumulative:get() == true
			arguments.Normalize = controls.Normalize:get()
			arguments.Stacked = controls.Stacked:get() == true
			arguments.BarPadding = controls.BarPadding:get()
			arguments.BarRounding = math.floor((controls.BarRounding:get()))
			arguments.LegendOnBottom = controls.LegendOnBottom:get() == true
			arguments.NoGrid = controls.NoGrid:get() == true
			parentModule({
				Id = "StoryHistogram",
				Arguments = arguments,
				States = {
					values = state,
					icons = state2,
					hoveredMark = state3,
					clickedMark = state4
				}
			})
			local v8 = state3:get()
			local text = v8 == nil and "hovered: none" or `hovered: {v8.Key} bin {v8.Bin} ` .. `[{string.format("%.1f", v8.Min)}, {string.format("%.1f", v8.Max)}) ` .. `= {string.format("%.2f", v8.Value)} ({v8.Samples} samples)`
			Osiris.Widget.Text({
				Arguments = {
					Text = text
				}
			})
		end)
	end)
	return function()
		heartbeatConnection:Disconnect()
		connection()
	end
end))