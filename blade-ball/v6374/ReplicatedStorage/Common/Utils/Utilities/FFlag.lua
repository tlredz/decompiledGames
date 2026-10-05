local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local v

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	v = require3(ServerScriptService.Game.CoreGameModules.FFlagServer)
else
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	v = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
end

local v2 = require3(script.Parent.Thread)

local function getFFlag(p: string, p2)
	local key = v:GetKey(p)

	if key == nil then
		return p2
	end

	return key
end

local function timeoutFFlag(p: string, duration: number, p2)
	local thread = coroutine.running()
	local thread2 = task.defer(function()
		local safeResume = v2.SafeResume
		local v4 = p2
		local key = v:GetKey(p)

		if key ~= nil then
			v4 = key
		end

		safeResume(thread, v4)
	end)
	local thread3 = task.delay(duration, function()
		v2.SafeCancel(thread2)
		v2.SafeResume(thread, p2, true)
	end)
	local v3 = coroutine.yield()
	v2.SafeCancel(thread3)
	v2.SafeCancel(thread2)
	return v3
end

local FFlag = {}
FFlag.TimeoutFFlag = timeoutFFlag
FFlag.GetFFlag = getFFlag

function FFlag.GetInstantFFlag(p: string, p2)
	if not v:IsDataReady() then
		return p2
	end

	local key = v:GetKey(p)

	if key == nil then
		return p2
	end

	return key
end

function FFlag.OnChange(onDataUpdatedEvent)
	return v.DataUpdatedEvent:Connect(onDataUpdatedEvent)
end

return FFlag