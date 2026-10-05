local StarterPlayer = game:GetService("StarterPlayer")
local SharedTreatEvents = require(StarterPlayer.StarterPlayerScripts.HalloweenLocal.SharedTreatEvents)
local v = {}
local Events = {}

for _, moduleScript in ipairs(script:GetDescendants()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	v[name] = module
end

function Events.GetEvent(_, p: string)
	return v[p] or function()
		task.wait(5333)
	end
end

for k, sharedTreatEvent in SharedTreatEvents do
	v[k] = sharedTreatEvent.Client
end

return Events