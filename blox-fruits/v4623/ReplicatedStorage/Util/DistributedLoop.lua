local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local HttpService = game:GetService("HttpService")

local function GenerateID()
	return HttpService:GenerateGUID()
end

local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local isServer = RunService:IsServer()
local heartbeatConnection = nil
local v = {}

local function update(p)
	local now = tick()
	local v2 = false

	for k, v3 in pairs(v) do
		local v4 = now - v3.Start
		local v5 = now - v3.LastUpdate

		if v3.Tick + 0.03333333333333333 + p < v5 and isStudio then
			warn(string.format(
				"[%s] - Laggy function found in %s\nRunning at %.1fms",
				isServer and "Server" or "Client",
				v3.scriptTarget,
				v5 * 1000
			))
		end

		if v3.Tick <= v5 then
			local v7 = v3
			local v8 = v4
			local v9 = math.max(p, v5)
			local success, result = pcall(function()
				return v7:Callback(v8, v9)
			end)

			if success then
				if result then
					v[k] = nil
					continue
				else
					v3.LastUpdate = now
				end
			else
				warn(string.format("[%s] - ERROR FOUND: %s,\n%s", script.Name, v3.scriptTarget, result))
				v[k] = nil
				continue
			end
		end

		v2 = true
	end

	if not v2 and heartbeatConnection then
		if isServer then
			heartbeatConnection:Disconnect()
		else
			RunService:UnbindFromRenderStep(heartbeatConnection)
		end

		v = {}
		heartbeatConnection = nil
	end
end

local function hook()
	if not heartbeatConnection then
		if isServer then
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				update(dt)
			end)
		else
			heartbeatConnection = GenerateID()
			RunService:BindToRenderStep(heartbeatConnection, 0, function(p)
				update(p)
			end)
		end
	end
end

local RunService2 = game:GetService("RunService")

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	script.HookEvent.Event:Connect(hook)
end

return {
	add = function(_, callback, value)
		local generateID = GenerateID()
		local v2 = {
			Callback = function(self, ...)
				return callback(...)
			end
		}
		local v4 = getfenv(2)
		v2.scriptTarget = v4.script and v4.script:GetFullName() or "Console"
		v2.Tick = value or 0
		v2.Start = tick()
		v2.LastUpdate = v2.Start - v2.Tick
		v[generateID] = v2
		script.HookEvent:Fire()
	end
}