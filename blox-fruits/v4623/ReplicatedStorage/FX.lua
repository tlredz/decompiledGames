local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return game.ServerStorage.FX
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local xisd = require(ReplicatedStorage:WaitForChild("xisd"))
local v2 = {}
local v3 = {}
local xisd2 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("xisd")
local worldModel = Instance.new("WorldModel", ReplicatedStorage)

local function getFX(p: string)
	if v3[p] then
		repeat
			task.wait()
		until v3[p] == nil
	end

	local v4 = v2[p]

	if v4 then
		return v4
	end

	v3[p] = true
	local v5, v6 = xisd2:InvokeServer("FX", p)

	if not v5 then
		v3[p] = nil
		return nil
	end

	local now = os.clock()
	local v7 = xisd.de(v6)
	v2[p] = v7
	v7.Parent = worldModel
	task.wait()
	v7.Parent = ReplicatedStorage.FX
	now = os.clock() - now
	v3[p] = nil
	return v7
end

return (setmetatable({
	FX_REMOVAL_LIFETIME = 60,
	FX_UNLOADING_ENABLED = false,
	WaitForChild = function(self, p: string)
		return (getFX(p))
	end,
	Get = function(_, p: string)
		return (getFX(p))
	end,
	Return = function(_, p: string)
		local v4 = v2[p]

		if v4 then
			v4:Destroy()
			v2[p] = nil
		end
	end
}, {
	__index = function(_, p)
		error(("Attempt to get FX::%s (not a valid member)"):format((tostring(p))), 2)
	end,
	__newindex = function(_, p, _)
		error(("Attempt to set FX::%s (not a valid member)"):format((tostring(p))), 2)
	end
}))