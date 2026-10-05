local v = 4
local v2 = 4
script.Parent.ImageRectSize = Vector2.new(204.8, 204.8)
shared.loop(function()
	v -= 1

	if v <= -1 then
		v2 -= 1
		v = 4

		if v2 <= -1 then
			v2 = 4
		end
	end

	script.Parent.ImageRectOffset = Vector2.new(v * 204.8, v2 * 204.8)
end, 24)