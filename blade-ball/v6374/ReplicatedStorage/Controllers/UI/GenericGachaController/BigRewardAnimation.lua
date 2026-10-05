local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v2 = require3(ReplicatedStorage2.Shared.LootboxData)
local playerGui = Players.LocalPlayer.PlayerGui
local gui = v2.ActiveGacha.Gui
local child = playerGui:WaitForChild(gui)
child:WaitForChild("MegaReward")

function getGachaIdentifier()
	return gui
end

function getCurrentGachaData()
	local gachaIdentifier = getGachaIdentifier()
	return v2.GachaEvents[gachaIdentifier]
end

return {
	DoAnimation = function(_, instance, p)
		local gachaIdentifier = getGachaIdentifier()
		local currentGachaData = getCurrentGachaData()
		local v3

		if gachaIdentifier == "ChromeGacha" or gachaIdentifier == "SoccerGacha" then
			v3 = p
		else
			v3 = currentGachaData.Items[p.RewardKey]
		end

		if not v3 then
			return
		end

		local main = instance.Parent and instance.Parent:FindFirstChild("Main")

		if main then
			main.Visible = false
		end

		local clone = instance:Clone()
		clone.Parent = instance.Parent
		local frame2 = clone:WaitForChild("Frame2")
		local frame = clone:WaitForChild("Frame")
		local yellowLines = frame:WaitForChild("YellowLines")
		local icon = frame:WaitForChild("Icon")
		local title = frame:WaitForChild("Title")
		local titleBG = frame:WaitForChild("TitleBG")
		local description = frame:WaitForChild("Description")
		local header = frame:WaitForChild("Header")
		local clickToContinue = frame:WaitForChild("ClickToContinue")
		frame2.ImageTransparency = 1
		clickToContinue.Position += UDim2.fromScale(0, 0.2)
		header.Position -= UDim2.fromScale(0, 0.2)
		icon.Position -= UDim2.fromScale(1, 0)
		title.Position += UDim2.fromScale(1, 0)
		description.Position += UDim2.fromScale(1, 0)
		titleBG.Position += UDim2.fromScale(1, 0)

		if v3.SimpleReward and v3.SimpleReward.Sword then
			local sword = v:GetSword(v3.SimpleReward.Sword)
			description.Text = sword and sword.Description or "Unknown description"
		else
			description.Text = ""
		end

		title.Text = v3.DisplayName or p.RewardKey
		local vector_2 = icon:WaitForChild("Vector")
		vector_2.Image = v3.ImageId

		local function bounceIcon()
			TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(0.275, 0.275)
			}):Play()
			local vector = icon.Vector
			local tween = TweenService:Create(
				vector,
				TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = UDim2.fromScale(1.05, 1.05)
				}
			)
			tween:Play()
			tween.Completed:Once(function()
				local tween2 = TweenService:Create(
					vector,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Size = UDim2.fromScale(0.9, 0.9)
					}
				)
				tween2:Play()
				tween2.Completed:Once(function()
					task.wait(0.1)
					local clone2 = vector:Clone()
					clone2.ZIndex = -1
					clone2.Parent = icon
					TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.fromScale(1.3, 1.3),
						ImageTransparency = 1
					}):Play()
				end)
				TweenService:Create(icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.fromScale(0.181, 0.485),
					Size = UDim2.fromScale(0.3, 0.3)
				}):Play()
			end)
		end

		local function drawYellowLines()
			TweenService:Create(
				yellowLines.YellowLine1,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = UDim2.fromScale(0.274, -0.055),
					ImageTransparency = 0
				}
			):Play()
			TweenService:Create(
				yellowLines.YellowLine2,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = UDim2.fromScale(0.102, 0.961),
					ImageTransparency = 0
				}
			):Play()
			TweenService:Create(
				yellowLines.YellowLine3,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = UDim2.fromScale(0.058, 0.782),
					ImageTransparency = 0
				}
			):Play()
			TweenService:Create(
				yellowLines.YellowLine4,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = UDim2.fromScale(0.909, 0.127),
					ImageTransparency = 0
				}
			):Play()
			TweenService:Create(
				yellowLines.YellowLine5,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = UDim2.fromScale(0.909, 0.226),
					ImageTransparency = 0
				}
			):Play()
		end

		local function mainHeaders()
			local tween = TweenService:Create(
				frame2,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageTransparency = 0
				}
			)
			local tween2 = TweenService:Create(
				header,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = header.Position + UDim2.fromScale(0, 0.2)
				}
			)
			task.delay(1.2000000000000002, function()
				TweenService:Create(
					clickToContinue,
					TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = clickToContinue.Position - UDim2.fromScale(0, 0.2)
					}
				):Play()
			end)
			tween:Play()
			tween2:Play()
			task.wait(0.4)
		end

		child.FTPCountdown.Visible = false
		clone.Visible = true
		mainHeaders()
		bounceIcon()
		task.wait(0.3)
		drawYellowLines()
		task.delay(0.8, function()
			TweenService:Create(titleBG, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.624, 0.462)
			}):Play()
			TweenService:Create(title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.499, 0.477),
				TextTransparency = 0
			}):Play()
			TweenService:Create(
				title:FindFirstChildWhichIsA("UIStroke"),
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 0
				}
			):Play()
			task.wait(0.2)
			TweenService:Create(description, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.579, 0.529),
				TextTransparency = 0
			}):Play()
			TweenService:Create(
				description:FindFirstChildWhichIsA("UIStroke"),
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 0
				}
			):Play()
		end)
		task.wait(3.3)
		clone:Destroy()
		child.FTPCountdown.Visible = true

		if main then
			main.Visible = true
		end
	end
}