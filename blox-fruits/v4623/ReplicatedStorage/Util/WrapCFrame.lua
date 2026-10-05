local createVector = vector.create
local WrapCFrame = {
	Angles = CFrame.Angles,
	fromMatrix = CFrame.fromMatrix,
	fromEulerAnglesXYZ = CFrame.fromEulerAnglesXYZ,
	new = function(...)
		local cframe = CFrame.new(...)

		if cframe == cframe then
			return cframe
		end

		warn("BRO", cframe)
		local v = { ... }
		cframe = CFrame.new(table.remove(v, 1) + createVector(0, 0.1, 0), table.unpack(v))
		warn("BRO2", cframe, debug.traceback())
		return cframe
	end,
	lookAt = function(p, p2)
		local cframe = CFrame.lookAt(p, p2)

		if cframe ~= cframe then
			warn("BRO", cframe)
			cframe = CFrame.new(p + createVector(0, 0.1, 0), p2)
			warn("BRO2", cframe, debug.traceback())
		end

		return cframe
	end
}

for k, v in CFrame do
	if not WrapCFrame[k] then
		WrapCFrame[k] = v
	end
end

return WrapCFrame