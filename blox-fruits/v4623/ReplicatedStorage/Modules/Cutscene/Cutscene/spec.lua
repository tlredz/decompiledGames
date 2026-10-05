local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local parentModule = require(script.Parent)
local v = {
	"construction",
	"serverRun",
	"dependencyValidation",
	"replicatedEnvironmentBinding",
	"finishFadeConfig"
}
return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("TestCase", v) }, function(p: string)
	if p == "dependencyValidation" then
		return not pcall(function()
			parentModule.new({
				SkipKeyCodes = {},
				Dependencies = {
					Environments = { "a", "a" }
				}
			})
		end)
	end

	local v2 = p == "replicatedEnvironmentBinding" and "TestHouse" or "a"
	local v5 = parentModule.new({
		FadeToBlackOnFinish = p ~= "finishFadeConfig" and nil,
		SkipKeyCodes = {},
		Dependencies = {
			Environments = { v2 }
		}
	})

	if p == "construction" then
		local environments = v5._config.Dependencies.Environments
		local fadeToBlackOnFinish = parentModule.is(v5)

		if fadeToBlackOnFinish then
			if #environments == 1 and environments[1] == "a" then
				fadeToBlackOnFinish = v5._config.FadeToBlackOnFinish
			else
				fadeToBlackOnFinish = false
			end
		end

		v5:Destroy()
		return fadeToBlackOnFinish
	elseif p == "finishFadeConfig" then
		local v6 = not v5._config.FadeToBlackOnFinish
		v5:Destroy()
		return v6
	elseif p == "replicatedEnvironmentBinding" then
		local cutsceneEnvironments = game.ServerStorage:FindFirstChild("CutsceneEnvironments")
		assert(cutsceneEnvironments and cutsceneEnvironments:IsA("Folder"))
		local model = cutsceneEnvironments:FindFirstChild(v2)
		assert(model and model:IsA("Model"))
		v5:_bindReplicatedEnvironmentFolder(cutsceneEnvironments)
		local v6 = v5._environmentTemplates[v2] == model
		v5:Destroy()
		return v6
	else
		local v6 = false
		local v7

		if v5:Run(function(_)
			v6 = true
		end) == v5 then
			v7 = not v6 and v5._runCount == 0
		else
			v7 = false
		end

		v5:Destroy()
		return v7
	end
end, #v + 1)