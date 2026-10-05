local v = nil

local function IsTradePlaza()
	if v ~= nil then
		return v
	end

	local selected = table.find({ 95655505523303, 78575977164594, 99519129453387 }, game.PlaceId) ~= nil
	v = selected
	return selected
end

return IsTradePlaza