game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.Shared.Globals.Constants)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage2.Shared.Remotes)
return {
	Start = function()
		local v = {}
		local v2 = {}

		for _, moduleScript in script.Events:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local v3 = moduleScript
			xpcall(function()
				local v4 = v
				local name = v3.Name
				local module = require(v3)
				v4[name] = module
			end, function(p)
				warn((`[{script.Name}] {p}`))
			end)
		end

		Remotes.LiveEvents.Began.OnClientEvent:Connect(function(p: string, duration: number, p2)
			local v3 = os.time() + duration
			v2[p] = v3

			if not v[p] then
				return
			end

			v[p]:StartEvent(duration, p2)
			task.delay(duration, function()
				if v2[p] ~= v3 then
					return
				end

				v[p]:StopEvent()
				v2[p] = nil
			end)
		end)
		Remotes.LiveEvents.Ended.OnClientEvent:Connect(function(p: string)
			v2[p] = nil

			if not v[p] then
				return
			end

			v[p]:StopEvent()
		end)
		local v3, v4 = Remotes.LiveEvents.FetchRunning:InvokeServer()

		for k, v5 in v3 do
			if not v[k] then
				continue
			end

			local v8 = v4[k] or {}
			local v9 = k
			local v10 = v5 - Workspace:GetServerTimeNow()
			task.spawn(function()
				v8.WasInProgress = true
				v[v9]:StartEvent(v10, v8)
			end)
		end
	end
}