local surfaceAppearance = script.Parent:FindFirstChildOfClass("SurfaceAppearance")
local color = Color3.fromRGB(105, 90, 180)
local color2 = Color3.fromRGB(173, 216, 230)
local color3 = Color3.fromRGB(255, 182, 193)
local color4 = Color3.fromRGB(255, 255, 255)
local total = 0

local function efeitoGalaxiaSuave()
	while true do
		total += 0.02
		local midpoint = (math.sin(total * 1.2) + 1) / 2
		local midpoint2 = (math.sin((total + 1) * 1.2) + 1) / 2
		local lerped = color:Lerp(color2, midpoint):Lerp(color3, midpoint2):Lerp(color4, 0.5)

		if surfaceAppearance then
			surfaceAppearance.Color = lerped
		end

		wait(0.02)
	end
end

efeitoGalaxiaSuave()