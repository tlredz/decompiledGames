local vector = Vector2.new(1328, 797)
game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
Players.LocalPlayer:WaitForChild("PlayerGui", 100)
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function average(viewportSize: Vector2)
	return (viewportSize.X + viewportSize.Y) / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getScreenRatio()
	local v = average(currentCamera.ViewportSize) -- equivalent call inferred; original call site unknown
	return v / average(vector)
end

local v = {}
CollectionService:GetInstanceAddedSignal("ScreenStroke"):Connect(function(instance)
	if instance:IsA("UIStroke") then
		v[instance] = instance.Thickness
		instance.Thickness *= getScreenRatio()
	elseif instance:IsA("Frame") or instance:IsA("GuiButton") then
		v[instance] = instance.BorderSizePixel
		instance.BorderSizePixel *= getScreenRatio()
	end
end)
local UIStrokeAdjuster = {}

function UIStrokeAdjuster.TagScreenGui(_, screenGui)
	if screenGui:IsA("ScreenGui") then
		for _, descendant in ipairs(screenGui:GetDescendants()) do
			if descendant:IsA("UIStroke") and descendant:GetAttribute("Ignore") == nil then
				CollectionService:AddTag(descendant, "ScreenStroke")
			elseif (descendant:IsA("Frame") or descendant:IsA("GuiButton")) and descendant.BorderSizePixel ~= 0 and descendant:GetAttribute("Ignore") == nil then
				CollectionService:AddTag(descendant, "ScreenStroke")
			end
		end
	end
end

function UIStrokeAdjuster.TagScreenGui2(_, screenGui)
	if screenGui:IsA("ScreenGui") then
		for _, uIStroke in ipairs(screenGui:GetDescendants()) do
			if uIStroke:IsA("UIStroke") and uIStroke:GetAttribute("Ignore") == nil then
				CollectionService:AddTag(uIStroke, "ScreenStroke")
			end
		end
	end
end

return UIStrokeAdjuster