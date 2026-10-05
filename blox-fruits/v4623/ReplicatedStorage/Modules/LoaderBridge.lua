local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local v = {}
local v2 = {}
local v3 = {}
local serverRunner = isServer and script.ServerRunner or script.ClientRunner
local clonesByName = {}

local function enable(p)
	p.Enabled = true
end

local LoaderBridge = {}

function LoaderBridge.require(p)
	if v[p] then
		repeat
			task.wait()
		until v[p] == nil
	end

	if v3[p] then
		return v2[p]
	end

	local v4 = Signal2.new()
	v[p] = v4
	local clone = serverRunner:Clone()
	clone.Name = p.Name
	clone.Module.Value = p
	clone.Parent = isServer and game.ServerScriptService or workspace.CurrentCamera
	task.defer(enable, clone)
	clonesByName[p.Name] = clone
	local v5 = v4:Wait()
	v[p] = nil
	v4:Destroy()
	v3[p] = true
	v2[p] = v5
	return v5
end

function LoaderBridge.callback(p, ...)
	local v4 = v[p]

	if v4 then
		v4:Fire(...)
	end
end

function LoaderBridge.spawn(p: string, callMethod: string)
	local v4 = clonesByName[p]

	if v4 then
		v4:SetAttribute("CallMethod", callMethod)
	end
end

return LoaderBridge