local Iris = require(game.ReplicatedStorage.Packages.Iris)
local MaterialIcons = require(game.ReplicatedStorage.Packages.MaterialIcons)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local v = {
	Common = MaterialIcons.circle,
	Legendary = MaterialIcons.emoji_events
}
return (UILabs.CreateIrisStory({
	name = "PieChart",
	summary = "Pie and donut chart drawn from angular slivers, with polar hit testing.",
	controls = {
		Label = "Rarity split",
		Height = 300,
		Donut = 0,
		StartAngle = -90,
		Clockwise = true,
		SliceGap = 0,
		ShowPercentages = true,
		LabelMinShare = 0.05,
		IncludeTiny = true,
		LegendOnBottom = false,
		ShowIcons = true
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local state = Osiris.State({})
	local state2 = Osiris.State({})
	local state3 = Osiris.State({
		Legendary = Color3.fromRGB(240, 190, 80)
	})
	local state4 = Osiris.State({})
	local state5 = Osiris.State(nil)
	local state6 = Osiris.State(nil)
	local connection = Osiris:Connect(function()
		local v2 = {
			Common = 620,
			Uncommon = 240,
			Rare = 90,
			Epic = 38,
			Legendary = 11
		}

		if controls.IncludeTiny:get() == true then
			v2.Mythic = 1
		end

		state:set(v2)
		state2:set(controls.ShowIcons:get() ~= true and {} or v)
		Osiris.Widget.Window({
			Arguments = {
				Title = "PieChart Widget"
			}
		}, function()
			parentModule({
				Id = "StoryPie",
				Arguments = {
					Text = controls.Label:get(),
					Height = math.floor((controls.Height:get())),
					Donut = controls.Donut:get(),
					StartAngle = controls.StartAngle:get(),
					Clockwise = controls.Clockwise:get() == true,
					SliceGap = controls.SliceGap:get(),
					ShowPercentages = controls.ShowPercentages:get() == true,
					LabelMinShare = controls.LabelMinShare:get(),
					LegendOnBottom = controls.LegendOnBottom:get() == true,
					ValueFormat = "%.0f"
				},
				States = {
					values = state,
					colors = state3,
					icons = state2,
					shares = state4,
					hoveredMark = state5,
					clickedMark = state6
				}
			})
			local v3 = state5:get()
			Osiris.Widget.Text({
				Arguments = {
					Text = v3 == nil and "hovered: none" or `hovered: {v3.Key} = {string.format("%.1f", v3.Share * 100)}% ` .. `({string.format("%.0f", v3.StartAngle)}° to {string.format("%.0f", v3.EndAngle)}°)`
				}
			})
			local v4 = state6:get()
			Osiris.Widget.Text({
				Arguments = {
					Text = v4 == nil and "clicked: nothing" or `clicked: {v4.Key}`
				}
			})
		end)
	end)
	return function()
		connection()
	end
end))