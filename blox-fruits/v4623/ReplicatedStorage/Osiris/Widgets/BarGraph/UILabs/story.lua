local RunService = game:GetService("RunService")
local Iris = require(game.ReplicatedStorage.Packages.Iris)
local MaterialIcons = require(game.ReplicatedStorage.Packages.MaterialIcons)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local v = { "Chests", "Bosses", "Quests" }
local v2 = {
	Chests = MaterialIcons.card_giftcard,
	Bosses = MaterialIcons.military_tech,
	Quests = MaterialIcons.assignment
}
local v3 = {
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary"
}

local function buildSeries(total: number, p: number, flag: boolean)
	local result = table.create(p)

	for i = 1, p do
		table.insert(result, v3[(i - 1) % #v3 + 1] .. (not (#v3 < i) and "" or ` {i}`))
	end

	local result2 = {}

	for k, v4 in v do
		local v5 = table.create(p)

		for i = 1, p do
			local v6 = math.sin(total + i * 0.7 + k * 1.3)
			local v7 = 40 / i * (1 + k * 0.35)
			local v8

			if flag then
				v8 = v6 * v7
			else
				v8 = v7 * ((v6 + 1) * 0.4 / 2 + 0.6)
			end

			table.insert(v5, math.round(v8 * 10) / 10)
		end

		result2[v4] = v5
	end

	return result2, result
end

return (UILabs.CreateIrisStory({
	name = "BarGraph",
	summary = "Categorical bar chart with grouped, stacked and horizontal modes.",
	controls = {
		Label = "Drops",
		Height = 280,
		Categories = 5,
		Stacked = false,
		Horizontal = false,
		Negatives = false,
		ShowValues = false,
		Animate = true,
		BarPadding = 0.2,
		GroupPadding = 0.05,
		BarRounding = 2,
		LegendOnBottom = false,
		ShowIcons = true,
		IconSize = 16,
		NoGrid = false,
		NoBaseLine = false,
		NoValueAxis = false,
		NoCategoryAxis = false
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local state = Osiris.State({})
	local state2 = Osiris.State({})
	local state3 = Osiris.State({
		Chests = Color3.fromRGB(235, 176, 92)
	})
	local state4 = Osiris.State({
		Bosses = "Boss drops"
	})
	local state5 = Osiris.State({})
	local state6 = Osiris.State(nil)
	local state7 = Osiris.State(nil)
	local count = 0
	local total = 0
	local v4 = ""
	local v5 = nil
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		local v6 = controls.ShowIcons:get() == true

		if v6 ~= v5 then
			v5 = v6
			state5:set(v6 and {
				Chests = v2.Chests,
				Bosses = v2.Bosses
			} or {})
		end

		local v7 = math.clamp(math.floor((controls.Categories:get())), 1, 40)
		local v8 = controls.Negatives:get() == true
		local v9 = controls.Animate:get() == true
		local formatted = `{v7}/{tostring(v8)}`

		if not v9 and formatted == v4 then
			return
		end

		if v9 then
			total += dt
		end

		v4 = formatted
		local series, v10 = buildSeries(total, v7, v8)
		state:set(series)
		state2:set(v10)
	end)
	local connection = Osiris:Connect(function()
		Osiris.Widget.Window({
			Arguments = {
				Title = "BarGraph Widget"
			}
		}, function()
			if parentModule({
				Id = "StoryBarGraph",
				Arguments = {
					Text = controls.Label:get(),
					Height = math.floor((controls.Height:get())),
					Stacked = controls.Stacked:get() == true,
					Horizontal = controls.Horizontal:get() == true,
					ShowValues = controls.ShowValues:get() == true,
					BarPadding = controls.BarPadding:get(),
					GroupPadding = controls.GroupPadding:get(),
					BarRounding = math.floor((controls.BarRounding:get())),
					LegendOnBottom = controls.LegendOnBottom:get() == true,
					LegendIconSize = math.floor((controls.IconSize:get())),
					NoGrid = controls.NoGrid:get() == true,
					NoBaseLine = controls.NoBaseLine:get() == true,
					NoValueAxis = controls.NoValueAxis:get() == true,
					NoCategoryAxis = controls.NoCategoryAxis:get() == true,
					ValueFormat = "%.1f",
					ValueTicks = 5
				},
				States = {
					values = state,
					categories = state2,
					colors = state3,
					labels = state4,
					icons = state5,
					hoveredMark = state6,
					clickedMark = state7
				}
			}).clicked() then
				count += 1
			end

			local v6 = state6:get()
			local text

			if v6 == nil then
				text = "hovered: none"
			else
				local v8 = string.format("%.2f", v6.Value)
				text = `hovered: {v6.Key} / {v6.Category} = {v8}`
			end

			Osiris.Widget.Text({
				Arguments = {
					Text = text
				}
			})
			local v8 = state7:get()
			local v9 = v8 == nil and "clicked: nothing" or `clicked: {v8.Key} / {v8.Category} = {string.format("%.2f", v8.Value)}`
			Osiris.Widget.Text({
				Arguments = {
					Text = `{v9} | clicks: {count}`
				}
			})
		end)
	end)
	return function()
		heartbeatConnection:Disconnect()
		connection()
	end
end))