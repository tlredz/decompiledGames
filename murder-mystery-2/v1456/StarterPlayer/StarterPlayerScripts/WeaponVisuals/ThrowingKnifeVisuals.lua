local createVector = vector.create
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local v = {}

local function onThrowingKnifeAdded(parent)
	local handleLink = parent:WaitForChild("HandleLink", 5)

	if not handleLink then
		return
	end

	local value = handleLink.Value

	if not value then
		return
	end

	local bladePosition = parent:WaitForChild("BladePosition", 5)

	if not bladePosition then
		return
	end

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
	clone:SetAttribute("ThrowSpeed", parent:GetAttribute("ThrowSpeed"))
	clone.Anchored = true
	clone.Name = "KnifeVisual"
	local part = Instance.new("Part")
	part.Name = "TrailPart"
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	local clone2 = script:WaitForChild("Bottom"):Clone()
	local clone3 = script:WaitForChild("Top"):Clone()
	local clone4 = script:WaitForChild("Trail"):Clone()
	clone4.Attachment0 = clone3
	clone4.Attachment1 = clone2
	clone2.Parent = part
	clone3.Parent = part
	clone4.Parent = part
	part.Parent = workspace
	game.Debris:AddItem(part, 10)
	clone.Parent = parent
	parent.Destroying:Connect(function()
		v[clone] = nil
		game.Debris:AddItem(part, 1)
	end)
	v[clone] = part
end

local function onUpdate(p: number)
	for k, v2 in v do
		if k.Parent == nil then
			v[k] = nil
		else
			local cFrame = k.CFrame
			local direction = k:GetAttribute("Direction")
			local throwSpeed = k:GetAttribute("ThrowSpeed") or 96
			local v3 = p * -12.566370614359172
			local cFrame2 = cFrame * CFrame.Angles(v3, 0, 0) + direction * throwSpeed * p
			k.CFrame = cFrame2
			v2.CFrame = CFrame.new(cFrame2.Position, cFrame2.Position + direction)
		end
	end
end

RunService.PreSimulation:Connect(onUpdate)
CollectionService:GetInstanceAddedSignal("ThrowingKnife"):Connect(onThrowingKnifeAdded)