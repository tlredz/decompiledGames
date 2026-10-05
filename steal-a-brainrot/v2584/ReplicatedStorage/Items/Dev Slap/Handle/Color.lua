local surfaceAppearance = script.Parent:FindFirstChildOfClass("SurfaceAppearance")
local v = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(255, 0, 255),
	Color3.fromRGB(0, 255, 255),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(0, 0, 0)
}

local function efeitoGlitch()
	while true do
		local color = v[math.random(1, #v)]

		if surfaceAppearance then
			surfaceAppearance.Color = color
		end

		wait(0.01)
	end
end

efeitoGlitch()