local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local screenGui = parent:FindFirstAncestorOfClass("ScreenGui")

local function visible()
	if not screenGui.Enabled then
		return false
	end

	local parent2 = parent

	while parent2 and parent2 ~= screenGui do
		if parent2:IsA("GuiObject") and not parent2.Visible then
			return false
		else
			parent2 = parent2.Parent
		end
	end

	return not localPlayer:GetAttribute("ReducedMotion")
end

local sweeps = {}

for _, childName in ipairs({
	"Popular",
	"Animations",
	"Backgrounds",
	"Hair",
	"Clothing",
	"Accessories"
}) do
	local child = parent:WaitForChild(childName)
	local frame = Instance.new("Frame")
	frame.Name = "CategoryShine"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.ClipsDescendants = true
	frame.Active = false
	frame.ZIndex = 20
	frame.Parent = child
	local uICorner = Instance.new("UICorner", frame)
	uICorner.CornerRadius = UDim.new(0, 8)
	local frame2 = Instance.new("Frame")
	frame2.Name = "Sweep"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.Position = UDim2.fromScale(-1.2, 0)
	frame2.BackgroundColor3 = Color3.new(1, 1, 1)
	frame2.BorderSizePixel = 0
	frame2.Active = false
	frame2.ZIndex = 20
	frame2.Parent = frame
	local uIGradient = Instance.new("UIGradient", frame2)
	uIGradient.Rotation = 20
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.35, 1),
		NumberSequenceKeypoint.new(0.5, 0.78),
		NumberSequenceKeypoint.new(0.65, 1),
		NumberSequenceKeypoint.new(1, 1)
	})
	local v = false

	local function sweep()
		if v or not visible() then
			return
		end

		v = true
		frame2.Position = UDim2.fromScale(-1.2, 0)
		local tween = TweenService:Create(
			frame2,
			TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.fromScale(1.2, 0)
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			v = false
			frame2.Position = UDim2.fromScale(-1.2, 0)
		end)
	end

	child.MouseEnter:Connect(sweep)
	table.insert(sweeps, sweep)
end

task.spawn(function()
	while parent.Parent do
		for _, v in ipairs(sweeps) do
			v()
			task.wait(0.22)
		end

		task.wait(5)
	end
end)