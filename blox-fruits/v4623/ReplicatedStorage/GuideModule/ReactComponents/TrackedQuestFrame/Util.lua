local Util = {}

function Util.valueOrDefault(p, p2)
	if p == nil then
		return p2
	end

	return p
end

function Util.mergeProps(p, items)
	local clone = table.clone(p)

	if items ~= nil then
		for k, item in pairs(items) do
			clone[k] = item
		end
	end

	return clone
end

function Util.toText(p, value: string?)
	if p == nil then
		return value or ""
	end

	return (tostring(p))
end

function Util.clamp01(value: number?)
	if value == nil then
		return 0
	end

	return (math.clamp(value, 0, 1))
end

return Util