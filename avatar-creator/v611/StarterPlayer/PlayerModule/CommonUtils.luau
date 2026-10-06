local CommonUtils = {
	_mocks = {}
}

function CommonUtils.mock(p, p2)
	CommonUtils._mocks[p] = p2
end

function CommonUtils.get(childName: string)
	if CommonUtils._mocks[childName] then
		return require(CommonUtils._mocks[childName])
	end

	if script:FindFirstChild(childName) then
		return require(script:FindFirstChild(childName))
	end

	assert(false, "Util does not exist: " .. childName)
end

return CommonUtils