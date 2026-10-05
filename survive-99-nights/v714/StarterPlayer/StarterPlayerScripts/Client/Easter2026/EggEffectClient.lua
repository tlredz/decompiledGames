local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")
local EggEffectClient = {}
local localPlayer2 = game.Players.LocalPlayer
require(localPlayer2.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")

function EggEffectClient.FlashRed(parent)
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.fromRGB(255, 60, 60)
	highlight.Parent = parent
	task.spawn(function()
		for _ = 1, 3 do
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineTransparency = 0
			task.wait(0.06)
			highlight.OutlineColor = Color3.fromRGB(255, 40, 40)
			task.wait(0.06)
		end

		local tween = TweenService:Create(
			highlight,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				OutlineTransparency = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
		highlight:Destroy()
	end)
end

local function createBillboard(instance)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(1.8, 0, 1.8, 0)
	billboardGui.StudsOffset = createVector(0, -0.3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Active = true
	billboardGui.LightInfluence = 1
	billboardGui.ClipsDescendants = true
	billboardGui.Adornee = instance.PrimaryPart
	billboardGui.Parent = instance.PrimaryPart
	return billboardGui
end

function EggEffectClient.FlashGreenTick(parent)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(80, 255, 80)
	highlight.FillTransparency = 0
	highlight.OutlineColor = Color3.fromRGB(150, 255, 150)
	highlight.OutlineTransparency = 0
	highlight.Parent = parent
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(1.8, 0, 1.8, 0)
	billboardGui.StudsOffset = createVector(0, -0.3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Active = true
	billboardGui.LightInfluence = 1
	billboardGui.ClipsDescendants = true
	billboardGui.Adornee = parent.PrimaryPart
	billboardGui.Parent = parent.PrimaryPart
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://94736445340460"
	imageLabel.ImageColor3 = Color3.new(0.235, 1, 0)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.Size = UDim2.new(0.2, 0, 0.2, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Parent = billboardGui
	task.spawn(function()
		local tween = TweenService:Create(
			imageLabel,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(1, 0, 1, 0)
			}
		)
		tween:Play()
		task.wait(0.15)
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.2
		task.wait(0.08)
		highlight.FillColor = Color3.fromRGB(80, 255, 80)
		highlight.FillTransparency = 0.1
		TweenService:Create(highlight, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			FillTransparency = 1,
			OutlineTransparency = 0.5
		}):Play()
		tween.Completed:Wait()
		task.wait(3)
		local tween2 = TweenService:Create(
			imageLabel,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				ImageTransparency = 1,
				Size = UDim2.new(0.2, 0, 0.2, 0)
			}
		)
		tween2:Play()
		TweenService:Create(highlight, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			OutlineTransparency = 1
		}):Play()
		tween2.Completed:Wait()
		billboardGui:Destroy()
		highlight:Destroy()
	end)
end

function EggEffectClient.FlashRedCross(parent)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 50, 50)
	highlight.FillTransparency = 0
	highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
	highlight.OutlineTransparency = 0
	highlight.Parent = parent
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(1.8, 0, 1.8, 0)
	billboardGui.StudsOffset = createVector(0, -0.3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Active = true
	billboardGui.LightInfluence = 1
	billboardGui.ClipsDescendants = true
	billboardGui.Adornee = parent.PrimaryPart
	billboardGui.Parent = parent.PrimaryPart
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://117942301671297"
	imageLabel.ImageColor3 = Color3.new(1, 0, 0)
	imageLabel.Rotation = 45
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.Size = UDim2.new(0.2, 0, 0.2, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Parent = billboardGui
	task.spawn(function()
		local tween = TweenService:Create(
			imageLabel,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(1, 0, 1, 0)
			}
		)
		tween:Play()
		task.wait(0.15)
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.2
		task.wait(0.08)
		highlight.FillColor = Color3.fromRGB(255, 50, 50)
		highlight.FillTransparency = 0.1
		TweenService:Create(highlight, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			FillTransparency = 1,
			OutlineTransparency = 0.5
		}):Play()
		tween.Completed:Wait()
		task.wait(5)
		local tween2 = TweenService:Create(
			imageLabel,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				ImageTransparency = 1,
				Size = UDim2.new(0.2, 0, 0.2, 0)
			}
		)
		tween2:Play()
		TweenService:Create(highlight, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			OutlineTransparency = 1
		}):Play()
		tween2.Completed:Wait()
		billboardGui:Destroy()
		highlight:Destroy()
	end)
end

function EggEffectClient.Init() end

return EggEffectClient