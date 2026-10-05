local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)

local function getKey(p: string)
	return (`CNYEvent{p}`)
end

local SinglePassFFlags = {}

function SinglePassFFlags.GetKey(_, p: string)
	return (`CNYEvent{p}`)
end

function SinglePassFFlags.Get(_, p: string, p2)
	return v.GetFFlag(`CNYEvent{p}`, p2)
end

return SinglePassFFlags