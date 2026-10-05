local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.Statable)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local RunService = game:GetService("RunService")
local client = RunService:IsClient() and v2.Client or v2.Server
local v3 = require3(script.Parent.Thread)
local Statable = {}
local v4 = {}
setmetatable(v4, {
	__mode = "kv"
})

function Statable.getAlarmState(p: number)
	local v5 = v4[p]

	if v5 then
		return v5
	end

	v5 = v.State(p <= workspace:GetServerTimeNow())

	if not v5:Get() then
		local connection = nil
		connection = v3.Every(1, function()
			if p <= workspace:GetServerTimeNow() then
				connection:Disconnect()
				v5:Set(true)
			end
		end)
	end

	v4[p] = v5
	return v5
end

local v5 = {}

function Statable.getReplionStatable(p: string)
	local v6 = v5[p]

	if v6 then
		return v6
	end

	v6 = v.State()
	local replion = client:GetReplion(p)

	if replion then
		v6:Set(replion)
	else
		client:AwaitReplion(p, function(p2)
			v6:Set(p2)
		end)
	end

	v5[p] = v6
	return v6
end

return Statable