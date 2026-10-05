local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parent = script.Parent.Parent
Color3.fromRGB(255, 255, 255)
local instances = {}

for _, instance in ipairs(parent:GetDescendants()) do
	if CollectionService:HasTag(instance, "Colorable") then
		table.insert(instances, instance)
	end
end

local function updateColors()
	local v

	if localPlayer.Character then
		v = localPlayer.Character:FindFirstChild("Masterline Rod")
	end

	local v2 = v or localPlayer.Backpack:FindFirstChild("Masterline Rod")

	if not v2 then
		return
	end

	local details = v2:FindFirstChild("Details")
	local colorChanging = details and details:FindFirstChild("ColorChanging")
	local highlights = colorChanging and colorChanging:FindFirstChild("highlights")

	if not highlights then
		return
	end

	local color = highlights:FindFirstChildWhichIsA("SurfaceAppearance").Color

	for _, instance in ipairs(instances) do
		if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
			instance.BackgroundColor3 = color
			instance.ImageColor3 = color
		elseif instance:IsA("UIStroke") then
			instance.Color = color
		elseif instance:IsA("Frame") then
			instance.BackgroundColor3 = color
		elseif instance:IsA("TextLabel") then
			instance.TextColor3 = color
		end
	end
end

updateColors()