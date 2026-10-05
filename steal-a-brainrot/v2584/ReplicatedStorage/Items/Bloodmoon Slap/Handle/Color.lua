local parent = script.Parent
local surfaceAppearance = parent:FindFirstChildOfClass("SurfaceAppearance")
local color = Color3.fromRGB(200, 25, 25)
local color2 = Color3.fromRGB(155, 25, 25)
local color3 = Color3.fromRGB(125, 25, 25)
local color4 = Color3.fromRGB(75, 25, 25)
local total = 0

local function pulsarCores()
	while true do
		total += 0.02
		local midpoint = (math.sin(total * 10) + 1) / 2
		local lerped = color:Lerp(color2, midpoint)
		local lerped2 = color3:Lerp(color2, midpoint)
		local lerped3 = color2:Lerp(color4, midpoint)

		if surfaceAppearance then
			surfaceAppearance.Color = lerped
		end

		local highlight = parent:FindFirstChildOfClass("Highlight")

		if highlight then
			highlight.FillColor = lerped2
			highlight.OutlineColor = lerped3
		end

		wait(0.02)
	end
end

pulsarCores()