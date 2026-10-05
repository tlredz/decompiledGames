local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("Packages"):WaitForChild("Replion"))
local v2 = require3(ReplicatedStorage2:WaitForChild("Packages"):WaitForChild("Signal"))
local v3 = require3(ReplicatedStorage2:WaitForChild("Shared"):WaitForChild("Statable"))
local FFlagClient = {}
local v4 = nil
local flag = false
FFlagClient.DataUpdatedEvent = v2.new()
v.Client:AwaitReplion("FFlags", function(object)
	v4 = object
	flag = true
	object:OnDataChange(function()
		FFlagClient.DataUpdatedEvent:Fire()
	end)
	FFlagClient.DataUpdatedEvent:Fire()
end)

function FFlagClient:WaitForData()
	if flag then
		return
	end

	FFlagClient.DataUpdatedEvent:Wait()
end

function FFlagClient:GetKey(p: string)
	FFlagClient:WaitForData()
	return v4.Data[p]
end

local v5 = {}

function FFlagClient:GetKeyState(p: string)
	local v6 = v5[p]

	if not v6 then
		v6 = v3.State(self:GetKey(p))
		v4:OnDataChange(function(_)
			v6:Set(self:GetKey(p))
		end)
		v5[p] = v6
	end

	return v6
end

function FFlagClient.IsDataReady(_)
	return flag
end

return FFlagClient