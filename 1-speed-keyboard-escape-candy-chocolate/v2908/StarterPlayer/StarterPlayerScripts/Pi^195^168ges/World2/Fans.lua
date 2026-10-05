local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local parts = {}

for _, part in ipairs(CollectionService:GetTagged("Fans")) do
	if part:IsA("BasePart") then
		table.insert(parts, part)
	end
end

CollectionService:GetInstanceAddedSignal("Fans"):Connect(function(part)
	if part:IsA("BasePart") then
		table.insert(parts, part)
	end
end)
RunService.RenderStepped:Connect(function(dt)
	for _, v in ipairs(parts) do
		if v and v.Parent then
			v.CFrame *= CFrame.Angles(math.rad(180 * dt), 0, 0)
		end
	end
end)