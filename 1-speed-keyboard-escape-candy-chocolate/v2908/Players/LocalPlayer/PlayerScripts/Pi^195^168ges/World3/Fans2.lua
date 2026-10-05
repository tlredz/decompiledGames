local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local parts = {}

for _, part in ipairs(CollectionService:GetTagged("Fans2")) do
	if part:IsA("BasePart") then
		table.insert(parts, part)
	end
end

CollectionService:GetInstanceAddedSignal("Fans2"):Connect(function(part)
	if part:IsA("BasePart") then
		table.insert(parts, part)
	end
end)
RunService.RenderStepped:Connect(function(dt)
	for _, v in ipairs(parts) do
		if v and v.Parent then
			v.CFrame *= CFrame.Angles(0, 0, (math.rad(180 * dt)))
		end
	end
end)