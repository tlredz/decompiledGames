require(script.Parent.Parent.types.Marker)
local Markers = {}
Markers.__index = Markers

function Markers.new(list)
	local markers = table.create(#list)

	for k, v2 in list do
		table.insert(markers, {
			time = v2.time,
			name = v2.name,
			value = v2.value,
			savedIndex = k
		})
	end

	table.sort(markers, function(a, b)
		if a.time == b.time then
			return a.savedIndex < b.savedIndex
		end

		return a.time < b.time
	end)
	return (setmetatable({
		_markers = markers,
		_consumed = table.create(#markers, false)
	}, Markers))
end

function Markers:_consumeThrough(p2: number)
	for k, _marker in self._markers do
		if _marker.time <= p2 then
			self._consumed[k] = true
		else
			break
		end
	end
end

function Markers:start(p2: number, callback)
	for k, _marker in self._markers do
		if _marker.time <= p2 then
			self._consumed[k] = true
			callback(_marker.name, _marker.value, _marker.time, p2 > 0)
		else
			break
		end
	end
end

function Markers:advance(p2: number, p3: number, callback)
	if p2 < p3 then
		for k, _marker in self._markers do
			if p3 < _marker.time then
				return
			end

			if self._consumed[k] or not (p2 < _marker.time) then
				continue
			end

			self._consumed[k] = true
			callback(_marker.name, _marker.value, _marker.time, false)
		end
	end
end

function Markers:seek(p: number)
	self:_consumeThrough(p)
end

return Markers