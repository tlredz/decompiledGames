local ReplicatedStorage = game:GetService("ReplicatedStorage")
local uilabs = require(ReplicatedStorage.packages["ui-labs"])
local region = require(ReplicatedStorage.client.ui.apps.region)
local vide = require(ReplicatedStorage.packages.vide)
local state = require(ReplicatedStorage.client.ui.state)
return uilabs.CreateVideStory({
	vide = vide,
	controls = {
		region = "test"
	}
}, function(p)
	state.region = p.controls.region
	return region()
end)