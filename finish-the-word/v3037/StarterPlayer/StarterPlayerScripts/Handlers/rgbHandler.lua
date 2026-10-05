local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local function rgb()
	local v = os.clock() * 360 * 0.2 % 360 / 360
	local color = Color3.fromHSV(v, 1, 1)

	for _, instance in pairs(CollectionService:GetTagged("RGB")) do
		if instance:IsA("Part") then
			instance.Color = color
		elseif instance:IsA("Highlight") then
			instance.FillColor = color
		end
	end
end

return {
	Priority = 1,
	Run = function()
		RunService.RenderStepped:Connect(rgb)
	end
}