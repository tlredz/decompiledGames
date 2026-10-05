local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local flag = false
local v = false
local v2 = true

local function resolveEnabled()
	if flag then
		return v2
	end

	while v and not flag do
		task.wait()
	end

	if flag then
		return v2
	end

	v = true

	while not ABTest._initialized do
		task.wait(0.05)
	end

	if ABTest._initialized then
		local v3, v4 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()

		if v3 and typeof(v4) == "boolean" then
			v2 = v4
		end
	end

	flag = true
	v = false
	return v2
end

return {
	ShouldConstruct = function()
		return (resolveEnabled())
	end
}