local RunService = game:GetService("RunService")
local Ticker = {}
local v = {}
local v2 = {}
local flag = false
local heartbeatConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function run(p, p2)
	local success, result = pcall(p.fn, p2)

	if not success then
		p.alive = false
		task.spawn(error, result, 0)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connect()
	if heartbeatConnection and heartbeatConnection.Connected then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local v3 = dt > 0.1 and 0.1 or dt
		flag = true
		local count = #v
		local v4 = 1

		for i = 1, count do
			local v5 = v[i]

			if not v5.alive then
				continue
			end

			if v5.interval > 0 then
				v5.acc += v3

				if v5.acc >= v5.interval then
					local acc = v5.acc
					v5.acc = 0
					run(v5, acc) -- equivalent call inferred; original call site unknown
				end
			else
				run(v5, v3) -- equivalent call inferred; original call site unknown
			end

			if not v5.alive then
				continue
			end

			v[v4] = v5
			v4 += 1
		end

		for i = v4, count do
			v[i] = nil
		end

		flag = false

		for i = 1, #v2 do
			v[#v + 1] = v2[i]
			v2[i] = nil
		end

		if #v == 0 then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
end

local class = {}
class.__index = class

function class:Stop()
	self.rec.alive = false
end

class.Disconnect = class.Stop

local function register(fn, value)
	local rec = {
		fn = fn,
		interval = value or 0,
		acc = 0,
		alive = true
	}

	if flag then
		v2[#v2 + 1] = rec
	else
		v[#v + 1] = rec
	end

	connect() -- equivalent call inferred; original call site unknown
	return (setmetatable({
		rec = rec
	}, class))
end

function Ticker.add(fn)
	return (register(fn, 0))
end

function Ticker.every(p, fn)
	return (register(fn, p))
end

function Ticker.isShown(parent)
	while parent do
		if parent:IsA("GuiObject") then
			if not parent.Visible then
				return false
			end
		elseif parent:IsA("LayerCollector") then
			return parent.Enabled and parent.Parent ~= nil
		end

		parent = parent.Parent
	end

	return false
end

function Ticker.watchVisible(instance, callback)
	local connections = {}
	local v3 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refresh()
		local shown = Ticker.isShown(instance)

		if shown ~= v3 then
			v3 = shown
			callback(shown)
		end
	end

	local function wire()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
		local parent = instance

		while parent do
			if parent:IsA("GuiObject") then
				connections[#connections + 1] = parent:GetPropertyChangedSignal("Visible"):Connect(refresh)
			elseif parent:IsA("LayerCollector") then
				connections[#connections + 1] = parent:GetPropertyChangedSignal("Enabled"):Connect(refresh)
				break
			end

			parent = parent.Parent
		end

		refresh() -- equivalent call inferred; original call site unknown
	end

	local ancestryChangedConnection = instance.AncestryChanged:Connect(function()
		if instance.Parent ~= nil then
			wire()
			return
		end

		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
		refresh() -- equivalent call inferred; original call site unknown
	end)
	wire()
	return {
		Stop = function(self)
			ancestryChangedConnection:Disconnect()

			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end

			table.clear(connections)

			if v3 then
				v3 = false
				callback(false)
			end
		end
	}
end

function Ticker.whileVisible(p, fn, value, callback)
	local v3 = nil
	local v4 = Ticker.watchVisible(p, function(p3)
		if p3 then
			if not v3 then
				v3 = register(fn, value or 0)
			end
		else
			if v3 then
				v3:Stop()
				v3 = nil
			end

			if callback then
				callback()
			end
		end
	end)
	return {
		Stop = function(self)
			v4:Stop()

			if v3 then
				v3:Stop()
				v3 = nil
			end
		end,
		IsRunning = function(_)
			return v3 ~= nil
		end
	}
end

function Ticker.count()
	return #v + #v2
end

return Ticker