local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "MoveModelFromABTest"
})
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local moveModelFromABTest_ExperimentName = p.Instance:GetAttribute("MoveModelFromABTest_ExperimentName")
	local moveModelFromABTest_ExperimentVariable = p.Instance:GetAttribute("MoveModelFromABTest_ExperimentVariable")
	local invert = p.Instance:GetAttribute("Invert")
	local moveModelABTest = p.Instance:GetAttribute("MoveModelABTest")
	ABTest.GetExperimentVariable(moveModelFromABTest_ExperimentName, moveModelFromABTest_ExperimentVariable):timeout(10):andThen(function(flag: boolean)
		if invert then
			flag = not flag
		end

		if flag then
			p.Instance:PivotTo(moveModelABTest)
		end
	end):catch(function(p2)
		warn("Error getting experiment variable", p2)
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v