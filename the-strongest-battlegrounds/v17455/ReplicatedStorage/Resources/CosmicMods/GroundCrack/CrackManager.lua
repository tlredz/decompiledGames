local result = {}
local CrackManager = {}

function CrackManager.add(_, p)
	table.insert(result, p)
end

function CrackManager.remove(_, p)
	for i, v in ipairs(result) do
		if v ~= p then
			continue
		end

		if i ~= #result then
			result[i] = result[#result]
		end

		result[#result] = nil
		break
	end
end

function CrackManager.updateAllCameras(_)
	for _, v in ipairs(result) do
		v:updateCamera()
	end
end

function CrackManager.getActiveCracks(_)
	return result
end

function CrackManager.clearAll(_)
	for i = #result, 1, -1 do
		result[i]:Destroy()
	end

	result = {}
end

return CrackManager