local Iris = require(game.ReplicatedStorage.Packages.Iris)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local v = {
	"EU",
	"NA",
	"SEA",
	"OCE"
}

local function buildSamples(p: number, p2: number, flag: boolean)
	local random = Random.new(p)
	local result = {}

	for k, v2 in v do
		local v3 = 40 + k * 25
		local v4 = 10 + k * 12
		local v5 = table.create(p2)

		for _ = 1, p2 do
			table.insert(
				v5,
				v3 + ((0 + random:NextNumber() + random:NextNumber() + random:NextNumber()) / 3 - 0.5) * v4 * 2
			)
		end

		if flag then
			table.insert(v5, v3 + v4 * 6)
			table.insert(v5, v3 - v4 * 5)
		end

		result[v2] = v5
	end

	return result
end

return (UILabs.CreateIrisStory({
	name = "BoxPlot",
	summary = "Box and whiskers per data set, with quartiles, outliers and an optional mean.",
	controls = {
		Label = "Latency",
		Height = 280,
		SampleCount = 400,
		Outliers = true,
		Horizontal = false,
		ShowOutliers = true,
		ShowMean = true,
		WhiskerRange = 1.5,
		BoxPadding = 0.4,
		LegendOnBottom = false,
		NoGrid = false
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local state = Osiris.State({})
	local state2 = Osiris.State({})
	local state3 = Osiris.State(nil)
	local state4 = Osiris.State(nil)
	local connection = Osiris:Connect(function()
		state:set((buildSamples(
			11,
			math.clamp(math.floor((controls.SampleCount:get())), 1, 20000),
			controls.Outliers:get() == true
		)))
		Osiris.Widget.Window({
			Arguments = {
				Title = "BoxPlot Widget"
			}
		}, function()
			parentModule({
				Id = "StoryBoxPlot",
				Arguments = {
					Text = controls.Label:get(),
					Height = math.floor((controls.Height:get())),
					Horizontal = controls.Horizontal:get() == true,
					ShowOutliers = controls.ShowOutliers:get() == true,
					ShowMean = controls.ShowMean:get() == true,
					WhiskerRange = controls.WhiskerRange:get(),
					BoxPadding = controls.BoxPadding:get(),
					LegendOnBottom = controls.LegendOnBottom:get() == true,
					NoGrid = controls.NoGrid:get() == true,
					ValueFormat = "%.0f"
				},
				States = {
					values = state,
					stats = state2,
					hoveredMark = state3,
					clickedMark = state4
				}
			})
			local v2 = state2:get()

			for _, v3 in v do
				local v4 = v2[v3]

				if v4 ~= nil then
					Osiris.Widget.Text({
						Arguments = {
							Text = `{v3}: median {string.format("%.1f", v4.Median)}, ` .. `IQR {string.format("%.1f", v4.Q3 - v4.Q1)}, ` .. `{#v4.Outliers} outliers`
						}
					})
				end
			end

			local v3 = state3:get()
			Osiris.Widget.Text({
				Arguments = {
					Text = v3 == nil and "hovered: none" or `hovered: {v3.Key}{v3.Outlier == nil and "" or ` outlier {string.format("%.1f", v3.Outlier)}`}`
				}
			})
		end)
	end)
	return function()
		connection()
	end
end))