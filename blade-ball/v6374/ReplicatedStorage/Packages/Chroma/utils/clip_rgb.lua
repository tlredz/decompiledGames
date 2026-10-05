local limit = require(script.Parent:WaitForChild("limit"))

local function clip_rgb(list)
	list._clipped = false
	list._unclipped = {
		list[1],
		list[2],
		list[3],
		list[4]
	}

	for i = 1, 3 do
		if list[i] < 0 or list[i] > 255 then
			list._clipped = true
		end

		list[i] = limit(list[i], 0, 255)
	end

	list[4] = limit(list[4], 0, 1)
	return list
end

return clip_rgb