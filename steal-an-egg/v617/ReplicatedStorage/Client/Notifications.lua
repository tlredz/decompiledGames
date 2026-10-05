local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local modules = {
	Reward = require(script.Reward),
	RiftSpawn = require(script.RiftSpawn),
	Toast = require(script.Toast)
}

local function channelFor(p)
	local v2 = modules[p]

	if typeof(v2) == "table" and typeof(v2.Show) == "function" then
		return v2
	end

	warn((`Alerts.Raise addressed an unknown notification channel: {tostring(p)}`))
	return nil
end

Remotes.Alerts.Raise.OnClientEvent:Connect(function(p)
	if typeof(p) ~= "table" then
		warn((`Alerts.Raise expects a request table, got {typeof(p)}`))
		return
	end

	local type = p.Type
	local v2 = modules[type]

	if typeof(v2) ~= "table" or typeof(v2.Show) ~= "function" then
		warn((`Alerts.Raise addressed an unknown notification channel: {tostring(type)}`))
		v2 = nil
	end

	if v2 ~= nil then
		local clone = table.clone(p)
		clone.Type = nil
		v2.Show(clone)
	end
end)
return table.freeze(modules)