local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = RunService:IsStudio() or v.isDevPlaceGame() or v.isTestGame()

local function noop() end

local function format(...)
	local v3 = { ... }

	for k, v4 in v3 do
		v3[k] = tostring(v4)
	end

	return table.concat(v3, " ")
end

local StudioLogger = {}

function StudioLogger.print(p: string?)
	if not v2 then
		return noop
	end

	if p then
		return function(...)
			print(p, ...)
		end
	end

	return print
end

function StudioLogger.warn(p: string?)
	if not v2 then
		return noop
	end

	if p then
		return function(...)
			warn(p, ...)
		end
	end

	return warn
end

function StudioLogger.trace(...)
	if v2 then
		print(debug.traceback(format(...), 2))
	end
end

function StudioLogger.traceWarn(...)
	if v2 then
		warn(debug.traceback(format(...), 2))
	end
end

return StudioLogger