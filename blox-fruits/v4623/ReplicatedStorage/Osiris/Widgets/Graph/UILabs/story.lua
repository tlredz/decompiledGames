local RunService = game:GetService("RunService")
local Iris = require(game.ReplicatedStorage.Packages.Iris)
local MaterialIcons = require(game.ReplicatedStorage.Packages.MaterialIcons)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local v = { "Damage", "Healing", "Shield" }
local v2 = {
	Damage = MaterialIcons.whatshot,
	Healing = MaterialIcons.healing,
	Shield = MaterialIcons.shield
}

local function buildSeries(p: number, total: number)
	local result = table.create(p)

	for i = 1, p do
		table.insert(result, (i - 1) / (p - 1) * 10)
	end

	local result2 = {}

	for k, v3 in v do
		local v4 = table.create(p)

		for i = 1, p do
			table.insert(v4, math.sin(result[i] * 0.9 + total + k) * (3 + k) + k * 4 + 8)
		end

		result2[v3] = v4
	end

	return result2, result
end

return (UILabs.CreateIrisStory({
	name = "Graph",
	summary = "Multi data set line graph with an explicit X axis and a legend.",
	controls = {
		Label = "Signal",
		Height = 260,
		PointCount = 240,
		Resolution = 100,
		Animate = true,
		BaselineZero = false,
		LegendOnBottom = false,
		NoGrid = false,
		NoPoints = false,
		NoLines = false,
		NoXAxis = false,
		NoYAxis = false,
		ShowIcons = true,
		IconSize = 16
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local state = Osiris.State({})
	local state2 = Osiris.State({})
	local state3 = Osiris.State({
		Damage = Color3.fromRGB(235, 92, 92)
	})
	local state4 = Osiris.State({
		Healing = "Healing (hp/s)"
	})
	local state5 = Osiris.State({})
	local state6 = Osiris.State(nil)
	local state7 = Osiris.State(nil)
	local count = 0
	local total = 0
	local v3 = -1
	local v4 = nil
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		local v5 = controls.ShowIcons:get() == true

		if v5 ~= v4 then
			v4 = v5
			state5:set(v5 and {
				Damage = v2.Damage,
				Healing = v2.Healing
			} or {})
		end

		local v6 = math.clamp(math.floor((controls.PointCount:get())), 2, 5000)
		local v7 = controls.Animate:get() == true

		if not v7 and v6 == v3 then
			return
		end

		if v7 then
			total += dt
		end

		v3 = v6
		local series, v8 = buildSeries(v6, total)
		state:set(series)
		state2:set(v8)
	end)
	local connection = Osiris:Connect(function()
		Osiris.Widget.Window({
			Arguments = {
				Title = "Graph Widget"
			}
		}, function()
			if parentModule({
				Id = "StoryGraph",
				Arguments = {
					Text = controls.Label:get(),
					Height = math.floor((controls.Height:get())),
					Resolution = math.floor((controls.Resolution:get())),
					BaselineZero = controls.BaselineZero:get() == true,
					LegendOnBottom = controls.LegendOnBottom:get() == true,
					NoGrid = controls.NoGrid:get() == true,
					NoPoints = controls.NoPoints:get() == true,
					NoLines = controls.NoLines:get() == true,
					NoXAxis = controls.NoXAxis:get() == true,
					NoYAxis = controls.NoYAxis:get() == true,
					LegendIconSize = math.floor((controls.IconSize:get())),
					XFormat = "%.1fs",
					YFormat = "%.1f",
					XTicks = 6,
					YTicks = 5
				},
				States = {
					values = state,
					xValues = state2,
					colors = state3,
					labels = state4,
					icons = state5,
					hoveredMark = state6,
					clickedMark = state7
				}
			}).clicked() then
				count += 1
			end

			local v5 = state6:get()
			local text

			if v5 == nil then
				text = "hovered: none"
			else
				local v7 = string.format("%.2f", v5.X)
				local v8 = string.format("%.2f", v5.Y)
				text = `hovered: {v5.Key} #{v5.Index} ({v7}, {v8})`
			end

			Osiris.Widget.Text({
				Arguments = {
					Text = text
				}
			})
			local v7 = state7:get()
			local v8 = v7 == nil and "clicked: nothing" or `clicked: {v7.Key} #{v7.Index} ({string.format("%.2f", v7.Y)})`
			Osiris.Widget.Text({
				Arguments = {
					Text = `{v8} | clicks: {count}`
				}
			})
		end)
	end)
	return function()
		heartbeatConnection:Disconnect()
		connection()
	end
end))