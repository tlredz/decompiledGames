local surfaceAppearance = script.Parent:FindFirstChildOfClass("SurfaceAppearance")
local color = Color3.fromRGB(150, 255, 0)
local color2 = Color3.fromRGB(255, 255, 255)
local total = 0

local function pulsarNuclear()
	while true do
		total += 0.02
		local lerped = color:Lerp(color2, (math.sin(total * 3) + 1) / 2)

		if surfaceAppearance then
			surfaceAppearance.Color = lerped
		end

		wait(0.02)
	end
end

pulsarNuclear()