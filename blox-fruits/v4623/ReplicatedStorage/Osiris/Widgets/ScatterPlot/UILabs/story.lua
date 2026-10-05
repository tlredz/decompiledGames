local Iris = require(game.ReplicatedStorage.Packages.Iris)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local v = {
	"Linear",
	"Quadratic",
	"Cubic",
	"Exponential",
	"Logarithmic",
	"Power",
	"MovingAverage",
	"None"
}

local function buildPoints(p: number, p2: number, p3: number, flag: boolean)
	local random = Random.new(p)
	local vectors = table.create(p2)
	local vectors2 = table.create(p2)

	for i = 1, p2 do
		local v2 = i / p2 * 20 + 0.5
		local v3

		if flag then
			v3 = v2 * v2 * 0.35 + 4
		else
			v3 = v2 * 3.2 + 6
		end

		table.insert(vectors, Vector2.new(v2, v3 + (random:NextNumber() - 0.5) * p3))
		table.insert(vectors2, Vector2.new(v2, v2 * 1.1 + 20 + (random:NextNumber() - 0.5) * p3 * 0.6))
	end

	return {
		Spend = vectors,
		Control = vectors2
	}
end

return (UILabs.CreateIrisStory({
	name = "ScatterPlot",
	summary = "Point clouds with fitted trend lines and reported R squared.",
	controls = {
		Label = "Luck vs spend",
		Height = 280,
		PointCount = 120,
		Noise = 14,
		Curved = true,
		TrendLine = UILabs.Choose(v),
		ControlTrend = UILabs.Choose(v),
		TrendExtend = false,
		TrendThickness = 2,
		MovingAverageWindow = 9,
		PointSize = 6,
		NoPoints = false,
		LegendOnBottom = false,
		NoGrid = false
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local state = Osiris.State({})
	local state2 = Osiris.State({})
	local state3 = Osiris.State({})
	local state4 = Osiris.State({
		Control = Color3.fromRGB(120, 190, 240)
	})
	local state5 = Osiris.State(nil)
	local state6 = Osiris.State(nil)
	local connection = Osiris:Connect(function()
		state:set((buildPoints(
			7,
			math.clamp(math.floor((controls.PointCount:get())), 2, 4000),
			controls.Noise:get(),
			controls.Curved:get() == true
		)))
		state2:set({
			Control = controls.ControlTrend:get()
		})
		Osiris.Widget.Window({
			Arguments = {
				Title = "ScatterPlot Widget"
			}
		}, function()
			parentModule({
				Id = "StoryScatter",
				Arguments = {
					Text = controls.Label:get(),
					Height = math.floor((controls.Height:get())),
					TrendLine = controls.TrendLine:get(),
					TrendExtend = controls.TrendExtend:get() == true,
					TrendThickness = math.floor((controls.TrendThickness:get())),
					MovingAverageWindow = math.floor((controls.MovingAverageWindow:get())),
					PointSize = math.floor((controls.PointSize:get())),
					NoPoints = controls.NoPoints:get() == true,
					LegendOnBottom = controls.LegendOnBottom:get() == true,
					NoGrid = controls.NoGrid:get() == true,
					XFormat = "%.1f",
					YFormat = "%.0f"
				},
				States = {
					values = state,
					trends = state2,
					colors = state4,
					fits = state3,
					hoveredMark = state5,
					clickedMark = state6
				}
			})

			for _, v2 in { "Spend", "Control" } do
				local v3 = state3:get()[v2]
				local text

				if v3 == nil then
					text = `{v2}: no fit`
				else
					text = `{v2}: {v3.Kind}, R² = {string.format("%.4f", v3.RSquared)}, n = {v3.Points}`
				end

				Osiris.Widget.Text({
					Arguments = {
						Text = text
					}
				})
			end

			local v2 = state5:get()
			Osiris.Widget.Text({
				Arguments = {
					Text = v2 == nil and "hovered: none" or `hovered: {v2.Key} #{v2.Index} ({string.format("%.2f", v2.X)}, {string.format("%.2f", v2.Y)})`
				}
			})
		end)
	end)
	return function()
		connection()
	end
end))