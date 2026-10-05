local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
_G.EveryHeartbeat = {}
_G.EveryStepped = {}
_G.EveryRenderStepped = {}
_G.EveryPreRender = {}
_G.EveryPostSimulation = {}
local Every = {}

function Every.Heartbeat(_, callback, p)
	local GUID = HttpService:GenerateGUID(false)
	_G.EveryHeartbeat[GUID] = RunService.Heartbeat:Connect(function(dt)
		callback(dt, p)
	end)
	return GUID
end

function Every.Stepped(_, callback, p)
	local GUID = HttpService:GenerateGUID(false)
	_G.EveryStepped[GUID] = RunService.Stepped:Connect(function(time)
		callback(time, p)
	end)
	return GUID
end

function Every.RenderStepped(_, callback, p)
	local GUID = HttpService:GenerateGUID(false)
	_G.EveryRenderStepped[GUID] = RunService.RenderStepped:Connect(function(dt)
		callback(dt, p)
	end)
	return GUID
end

function Every.PreRender(_, callback, p)
	local GUID = HttpService:GenerateGUID(false)
	_G.EveryPreRender[GUID] = RunService.PreRender:Connect(function(dt)
		callback(dt, p)
	end)
	return GUID
end

function Every.PostSimulation(_, callback, p)
	local GUID = HttpService:GenerateGUID(false)
	_G.EveryPostSimulation[GUID] = RunService.PostSimulation:Connect(function(dt)
		callback(dt, p)
	end)
	return GUID
end

return Every