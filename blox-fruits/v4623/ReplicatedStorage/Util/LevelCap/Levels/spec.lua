local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local parentModule = require(script.Parent)
return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("CompletedMoments", {
		0,
		1,
		2,
		39,
		40,
		41
	}), SimpleTest.Parameter.Choose.new("CompletedMap", { false, true }) }, function(p: number, flag: boolean)
	local v = {
		Incomplete = {
			Completed = false
		}
	}

	for i = 1, p do
		v[tostring(i)] = {
			Completed = true
		}
	end

	local v2 = math.min((p + (flag and 1 or 0)) * 5, 200)
	return parentModule.getSecretLevelsUnlocked(v, flag and {
		Sea1 = true
	} or nil) == v2
end)