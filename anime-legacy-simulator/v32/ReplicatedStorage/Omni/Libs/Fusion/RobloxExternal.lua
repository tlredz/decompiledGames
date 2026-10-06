local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local parent = script.Parent
local External = require(parent.External)
local RobloxExternal = {
	policies = {
		allowWebLinks = RunService:IsStudio()
	},
	doTaskImmediate = function(callback)
		task.spawn(callback)
	end,
	doTaskDeferred = function(callback)
		task.defer(callback)
	end,
	logErrorNonFatal = function(p: string)
		task.spawn(error, p, 0)
	end,
	logWarn = warn
}

local function performUpdateStep()
	External.performUpdateStep(os.clock())
end

local fn = nil

function RobloxExternal.startScheduler()
	if fn ~= nil then
		return
	end

	if RunService:IsClient() then
		local v = "FusionUpdateStep_" .. HttpService:GenerateGUID()
		RunService:BindToRenderStep(v, Enum.RenderPriority.First.Value, performUpdateStep)

		fn = function()
			RunService:UnbindFromRenderStep(v)
		end
	else
		local heartbeatConnection = RunService.Heartbeat:Connect(performUpdateStep)

		fn = function()
			heartbeatConnection:Disconnect()
		end
	end
end

function RobloxExternal.stopScheduler()
	if fn ~= nil then
		fn()
		fn = nil
	end
end

return RobloxExternal