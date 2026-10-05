local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local misc = Util.Misc
local signal = Util.Signal
local generateID = misc.GenerateID
local tick2 = tick
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local steppedConnection = false
local isStudio = RunService:IsStudio()
local v = generateID()
local v2 = signal()
local v3 = signal()
local v4 = {}

local function onStepped(...)
	local v5 = { ... }
	local v6 = v5[#v5]
	local now = tick2()

	for k, v7 in v4 do
		local now2 = tick2()
		local v8 = v7
		local success, result = pcall(function()
			v8:Action(v6)
		end)

		if success then
			if isStudio then
				local v9 = tick2() - now2

				if 0.03333333333333333 + v6 < v9 then
					warn(string.format(
						"function for category \"%s\" running laggy in Pool routine: %.1fms",
						v7.Category,
						(tick2() - now2) * 1000
					))
				end
			end
		else
			warn(string.format("[%s] - function for category \"%s\" errored: %s", script.Name, v7.Category, result))
			table.remove(v4, k)
			break
		end
	end

	if isStudio then
		local v7 = tick2() - now

		if 0.03333333333333333 + v6 < v7 then
			warn(string.format("Pool routine running laggy: %.1fms", (tick2() - now) * 1000))
		end
	end
end

v3.Event:Connect(function()
	if not steppedConnection then
		if isServer then
			steppedConnection = RunService.Stepped:Connect(onStepped)
		else
			RunService:BindToRenderStep(v, 0, onStepped)
			steppedConnection = v
		end
	end
end)
v2.Event:Connect(function()
	local total = 0

	for _, v5 in next, v4, nil do
		total += v5:__getCount()
	end

	if total == 0 then
		if isServer then
			steppedConnection:Disconnect()
		else
			RunService:UnbindFromRenderStep(steppedConnection)
		end

		steppedConnection = false
	end
end)
local Pool = {}

function Pool.new(p, value)
	local category = p or generateID()
	local priority = value or 0
	assert(typeof(category) == "string", "Please make sure the Category provided is in string format")
	assert(typeof(priority) == "number", "Please make sure the Priority provided is a float")
	return setmetatable({
		Category = category,
		Priority = priority,
		Pool = {},
		PoolCount = 0
	}, {
		__index = Pool
	}):__create()
end

function Pool:setAction(action)
	assert(typeof(action) == "function", string.format("function expected, got %s.", (typeof(action))))
	self.Action = action
end

function Pool:add(p)
	assert(
		typeof(self.Action) == "function",
		string.format("please make sure an Action was properly set to %s", self.Category)
	)

	if self:find(p) then
		return
	end

	self.PoolCount += 1
	table.insert(self.Pool, p)
	v3:Fire()
	return p
end

function Pool.find(p, p2)
	local index = table.find(p.Pool, p2)

	if index then
		return p.Pool[index], index
	end
end

function Pool:remove(p)
	local _, v5 = self:find(p)

	if v5 then
		self.PoolCount -= 1
		table.remove(self.Pool, v5)
		v2:Fire()
	end
end

function Pool:__create()
	table.insert(v4, self)
	table.sort(v4, function(a, b)
		return a.Priority < b.Priority
	end)
	return self
end

function Pool:__destroy()
	for _, v5 in next, self.Pool, nil do
		self:remove(v5)
	end

	self.PoolCount = 0
	table.remove(v4, table.find(v4, self))
end

function Pool:__getCount()
	return self.PoolCount
end

return Pool