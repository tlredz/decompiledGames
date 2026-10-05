local Iris = require(game.ReplicatedStorage.Packages.Iris)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
return (UILabs.CreateIrisStory({
	name = "GachaSimulation",
	summary = "Runs a gacha box under live conditions and reports how the pulls landed.",
	controls = {
		ChartHeight = 240,
		OpenAccuracy = true,
		OpenSensitivity = true,
		OpenJourney = true,
		GroupByRarity = false
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local connection = Osiris:Connect(function()
		parentModule({
			Arguments = {
				ChartHeight = math.floor((controls.ChartHeight:get())),
				OpenAccuracy = controls.OpenAccuracy:get() == true,
				OpenSensitivity = controls.OpenSensitivity:get() == true,
				OpenJourney = controls.OpenJourney:get() == true,
				GroupByRarity = controls.GroupByRarity:get() == true
			}
		})
	end)
	return function()
		connection()
	end
end))