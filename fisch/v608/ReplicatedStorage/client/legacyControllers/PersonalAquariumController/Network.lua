game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local WaitFor = require(packages.WaitFor)
return {
	waitForModelAsync = function(p: string, p2, p3: number)
		local v = p3 / 2
		local v2, v3 = WaitFor.Child(p2, p, v):await()

		if not (v2 and v3) then
			return false
		end

		local v4, _ = WaitFor.PrimaryPart(v3, v):await()

		if not v4 then
			return false
		end

		task.wait(0.2)
		return true
	end
}