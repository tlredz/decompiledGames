local Iris = require(game.ReplicatedStorage.Packages.Iris)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local MockDriver = require(script.Parent.MockDriver)
return (UILabs.CreateIrisStory({
	name = "QATasks",
	summary = "Browse the QA task tree, complete tasks, and add custom ones.",
	controls = {
		Rank = UILabs.Choose({ "QAAdmin", "QATester", "None" }),
		Latency = 0.2
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local v = controls.Rank:get()
	local new = MockDriver.new

	if v == "None" then
		v = nil
	end

	local driver = new(v, controls.Latency:get())
	local connection = Osiris:Connect(function()
		parentModule.Component({
			Driver = driver,
			Arguments = {
				Title = "QA Tasks (story)"
			}
		})
	end)
	return function()
		connection()
	end
end))