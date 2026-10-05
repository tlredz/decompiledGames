local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local ReactDebugCurrentFrame = {}
local v = nil

function ReactDebugCurrentFrame.setExtraStackFrame(p: string?)
	if ReactGlobals.__DEV__ then
		v = p
	end
end

if ReactGlobals.__DEV__ then
	ReactDebugCurrentFrame.getCurrentStack = nil

	function ReactDebugCurrentFrame.getStackAddendum()
		local v2 = ""

		if v then
			v2 ..= v
		end

		local getCurrentStack = ReactDebugCurrentFrame.getCurrentStack

		if getCurrentStack then
			return v2 .. (getCurrentStack() or "")
		end

		return v2
	end
end

return ReactDebugCurrentFrame