game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent.Parent
local Promise = require(parent.Promise)
local Enums = require(script.Parent.Parent.Enums)
local ABTest = {
	_cache = {},
	_remote = nil,
	_initialized = false
}

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(p)
	error("[GameSdk - ABTest] " .. p)
end

local function _assertInitialized(flag: boolean, p: string)
	if ABTest._initialized ~= flag then
		erroro(p) -- equivalent call inferred; original call site unknown
	end
end

local function onClientEvent(cache)
	ABTest._cache = cache
end

function ABTest.Init()
	if ABTest._initialized ~= false then
		error("[GameSdk - ABTest] Already initialized")
	end

	ABTest._remote = ReplicatedStorage:WaitForChild("GameSdkAbTestEvent", 20)

	if ABTest._remote == nil then
		error("[GameSdk - ABTest] Failed to find remote event")
	end

	ABTest._remote.OnClientEvent:Connect(onClientEvent)
	ABTest._remoteFetch = ReplicatedStorage:WaitForChild("GameSdkAbTestFunction", 20)

	if ABTest._remoteFetch == nil then
		error("[GameSdk - ABTest] Failed to find remote function")
	end

	ABTest._initialized = true
end

function ABTest.GetExperimentVariables(p: string)
	if ABTest._initialized ~= true then
		error("[GameSdk - ABTest] Tried to get experiment variables before module is initialized, call initialize first")
	end

	return Promise.new(function(callback, callback2)
		local v

		if ABTest._cache == nil then
			v = false
		else
			v = ABTest._cache[p] ~= nil
		end

		if not v then
			local v2, v3 = ABTest._remoteFetch:InvokeServer(p)

			if v2 == nil then
				if v3 == Enums.ExperimentAccess.UNREGISTERED then
					erroro("Experiment is not registered: " .. p) -- equivalent call inferred; original call site unknown
				end

				callback2()
				return
			else
				ABTest._cache[p] = v2
			end
		end

		callback(ABTest._cache[p])
	end)
end

function ABTest.GetExperimentVariable(p: string, p2: string)
	return ABTest.GetExperimentVariables(p):andThen(function(p3)
		if p3 == nil then
			return nil
		end

		return p3[p2]
	end)
end

return ABTest