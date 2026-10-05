local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local DebugTracing = {}
local log
require(script.Parent:WaitForChild("ReactFiberLane"))
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local enableDebugTracing = shared2.ReactFeatureFlags.enableDebugTracing
local log2 = nil
local v = {}
local v2 = 0

function decimalToBinaryString(p: number)
	local v3 = ""

	repeat
		local v4
		p, v4 = math.modf(p / 2)
		v3 = math.ceil(v4) .. v3
	until p == 0

	local v4 = 31 - string.len(v3)
	return string.rep("0", v4) .. v3
end

local function formatLanes(p)
	return "0b" .. decimalToBinaryString(p)
end

local function group(...)
	for _, v3 in { ... } do
		table.insert(v, v3)
	end

	if log2 == nil then
		log2 = console.log
		console.log = log
	end
end

local function groupEnd()
	table.remove(v, 1)

	while v2 > #v do
		console.groupEnd()
		v2 -= 1
	end

	if #v == 0 then
		console.log = log2
		log2 = nil
	end
end

log = function(...)
	if v2 < #v then
		for i = v2 + 1, #v do
			local v3 = v[i]
			console.group(v3)
		end

		v2 = #v
	end

	if typeof(log2) == "function" then
		log2(...)
	else
		console.log(...)
	end
end

function DebugTracing.logCommitStarted(p)
	if _G.__DEV__ and enableDebugTracing then
		group(string.format("* commit (%s)", "0b" .. decimalToBinaryString(p)), "", "", "")
	end
end

function DebugTracing.logCommitStopped()
	if _G.__DEV__ and enableDebugTracing then
		groupEnd()
	end
end

function DebugTracing.logComponentSuspended(p: string, object)
	if _G.__DEV__ and enableDebugTracing then
		log(string.format("* %s suspended", p))
		object:andThen(function()
			log(string.format("* %s resolved", p))
		end, function()
			log(string.format("* %s rejected", p))
		end)
	end
end

function DebugTracing.logLayoutEffectsStarted(p)
	if _G.__DEV__ and enableDebugTracing then
		group(string.format("* layout effects (%s)", "0b" .. decimalToBinaryString(p)))
	end
end

function DebugTracing.logLayoutEffectsStopped()
	if _G.__DEV__ and enableDebugTracing then
		groupEnd()
	end
end

function DebugTracing.logPassiveEffectsStarted(p)
	if _G.__DEV__ and enableDebugTracing then
		group(string.format("* passive effects (%s)", "0b" .. decimalToBinaryString(p)))
	end
end

function DebugTracing.logPassiveEffectsStopped()
	if _G.__DEV__ and enableDebugTracing then
		groupEnd()
	end
end

function DebugTracing.logRenderStarted(p)
	if _G.__DEV__ and enableDebugTracing then
		group(string.format("* render (%s)", "0b" .. decimalToBinaryString(p)))
	end
end

function DebugTracing.logRenderStopped()
	if _G.__DEV__ and enableDebugTracing then
		groupEnd()
	end
end

function DebugTracing.logForceUpdateScheduled(p: string, p2)
	if _G.__DEV__ and enableDebugTracing then
		log(string.format("* %s forced update (%s)", p, "0b" .. decimalToBinaryString(p2)))
	end
end

function DebugTracing.logStateUpdateScheduled(p: string, p2, _)
	if _G.__DEV__ and enableDebugTracing then
		log(string.format("* %s updated state (%s)", p, "0b" .. decimalToBinaryString(p2)))
	end
end

return DebugTracing