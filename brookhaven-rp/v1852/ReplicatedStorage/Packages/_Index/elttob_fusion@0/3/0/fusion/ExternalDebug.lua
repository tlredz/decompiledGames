local parent = script.Parent
require(parent.Types)
local v = nil
local ExternalDebug = {}

function ExternalDebug.setDebugger(p)
	local v2 = v

	if v2 ~= nil then
		v2.stopDebugging()
	end

	v = p

	if p ~= nil then
		p.startDebugging()
	end

	return v2
end

function ExternalDebug.trackScope(p)
	if v == nil then
		return
	end

	v.trackScope(p)
end

function ExternalDebug.untrackScope(p)
	if v == nil then
		return
	end

	v.trackScope(p)
end

return ExternalDebug