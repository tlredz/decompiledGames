local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local parentModule = require(script.Parent)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
return SimpleTest.Test.new({
	SimpleTest.Parameter.Choose.new("Race", {
		"Human",
		"Rabbit",
		"Shark",
		"Angel",
		"Ghoul",
		"Cyborg",
		"Draco"
	}),
	SimpleTest.Parameter.Integer.new("Level", 1, 4, 1),
	SimpleTest.Parameter.Integer.new("A Gears", 1, 2, 1),
	SimpleTest.Parameter.Integer.new("B Gears", 1, 2, 1),
	SimpleTest.Parameter.Integer.new("C Gears", 1, 2, 1)
}, function(p: string, p2: number, p3: number, p4: number, p5: number)
	local unwrapped = ItemConfig.match(p, "Race"):unwrap()
	parentModule.solve(unwrapped.Index.ItemId, p2, p3, p4, p5)
	return true
end)