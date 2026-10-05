local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local v = {}

local function onThrowingKnifeAdded(parent)
	local value = parent:WaitForChild("HandleLink").Value

	if not value then
		return
	end

	local bladePosition = parent:WaitForChild("BladePosition")
	local clone = value:Clone()
	clone.CFrame = bladePosition.CFrame
	local VH = clone:FindFirstChild("VH")

	if VH then
		clone.Transparency = 1
		VH.Transparency = 0
		VH:SetAttribute("VisualHandle", true)
	else
		clone.Transparency = 0
	end

	clone:SetAttribute("Direction", parent:GetAttribute("Direction"))
	clone.Anchored = true
	clone.Name = "KnifeVisual"
	clone.Parent = parent
	v[clone] = true
end

local function onUpdate(p: number)
	for k, _ in v do
		if k.Parent == nil then
			v[k] = nil
		else
			local cFrame = k.CFrame
			local direction = k:GetAttribute("Direction")
			local v2 = p * -12.566370614359172
			k.CFrame = cFrame * CFrame.Angles(v2, 0, 0) + direction * 96 * p
		end
	end
end

RunService.PreSimulation:Connect(onUpdate)
CollectionService:GetInstanceAddedSignal("ThrowingKnife"):Connect(onThrowingKnifeAdded)