local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = require(ReplicatedStorage.Packages.Log)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Log.new()
local v2 = nil
local Policy = {
	Loaded = Signal.new(),
	Get = function()
		return v2
	end,
	IsLoaded = function()
		return v2 ~= nil
	end
}

function Policy.GetAsync()
	local v3 = v2

	if v3 == nil then
		return Policy.Loaded:Wait()
	end

	return v3
end

function Policy.IsEndlessContentLoadAllowed()
	local v3 = v2
	return v3 ~= nil and v3.IsEndlessContentLoadAllowed ~= false
end

task.spawn(function()
	local count = 0

	while v2 == nil do
		local success, result = pcall(function()
			return PolicyService:GetPolicyInfoForPlayerAsync(Players.LocalPlayer)
		end)

		if success and type(result) == "table" then
			local frozen = table.freeze(result)
			v2 = frozen
			Policy.Loaded:Fire(frozen)
			break
		else
			count += 1
			v:AtWarning():Log((`Failed to fetch local player policy info (attempt {count}): {result}`))
			task.wait((math.min(2 ^ (count - 1) * 2, 30)))
		end
	end
end)
return Policy