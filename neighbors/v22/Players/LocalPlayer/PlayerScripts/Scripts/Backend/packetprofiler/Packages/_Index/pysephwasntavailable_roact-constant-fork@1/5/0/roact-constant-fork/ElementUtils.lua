local Type = require(script.Parent.Type)
local Symbol = require(script.Parent.Symbol)

local function noop()
	return nil
end

local ElementUtils = {
	UseParentKey = Symbol.named("UseParentKey")
}

function ElementUtils.iterateElements(p)
	if Type.of(p) == Type.Element then
		local flag = false
		return function(_, _)
			if flag then
				return nil
			end

			flag = true
			return ElementUtils.UseParentKey, p
		end
	end

	local typeName = typeof(p)

	if p == nil or typeName == "boolean" then
		return noop
	end

	if typeName == "table" then
		return pairs(p)
	end

	error("Invalid elements")
end

function ElementUtils.getElementByKey(value, p)
	if value == nil or typeof(value) == "boolean" then
		return nil
	end

	if Type.of(value) == Type.Element then
		if p == ElementUtils.UseParentKey then
			return value
		end

		return nil
	else
		if typeof(value) == "table" then
			return value[p]
		end

		error("Invalid elements")
	end
end

return ElementUtils