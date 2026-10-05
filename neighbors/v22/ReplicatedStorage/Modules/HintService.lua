local HintService = {}
local clone = script.Assets:WaitForChild("Hints"):Clone()
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local v = {
	"\n",
	"\r",
	"\t",
	"\11",
	"\f"
}
local Signal = require(script.Plugins:WaitForChild("Signal"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
clone.Parent = localPlayer:WaitForChild("PlayerGui")
clone.Archivable = false
HintService.__index = HintService
HintService.HintAdded = Signal.Create()
HintService.HintRemoving = Signal.Create()
GuiService.MenuOpened:Connect(function()
	clone.Enabled = false
end)
GuiService.MenuClosed:Connect(function()
	clone.Enabled = true
end)

function HintService.new(p, flag: boolean)
	local self = setmetatable({}, HintService)
	local v2

	if flag then
		v2 = script.Assets:WaitForChild("HintMsgCopyable"):Clone()
	else
		v2 = script.Assets:WaitForChild("HintMsg"):Clone()
	end

	self._ = v2
	local hintsFrame = clone.HintsFrame

	if p == Enum.TextXAlignment.Center then
		self._.Parent = hintsFrame.CenterFrame
	elseif p == Enum.TextXAlignment.Left then
		self._.Parent = hintsFrame.LeftFrame
	elseif p == Enum.TextXAlignment.Right then
		self._.Parent = hintsFrame.RightFrame
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end

	self.DestroyOnFinished = true
	self.VisibleTime = 12
	return self
end

function HintService:setCallback(callback)
	local textButton = Instance.new("TextButton")
	textButton.Size = UDim2.new(1, 0, 1, 0)
	textButton.BackgroundTransparency = 1
	textButton.Text = ""
	textButton.Name = "Button"
	textButton.Parent = self._
	textButton.MouseButton1Down:connect(function()
		return callback()
	end)
end

function HintService:setLabel(value: string)
	local text = value or ""

	for _, v3 in pairs(v) do
		if string.find(text, v3) then
			error("Whitespaces are not allowed.")
		end
	end

	self._.Text = text
end

function HintService:setLabelColor(color: Color3)
	local textColor = color or Color3.fromRGB(255, 255, 255)
	self._.TextColor3 = textColor
end

function HintService:setVisibleTime(value: number)
	local _ = self._
	self.VisibleTime = value or 12
end

function HintService:setRichText(flag: boolean)
	self._.RichText = flag or false
end

function HintService:setDestroyOnFinish(flag: boolean)
	local _ = self._
	self.DestroyOnFished = flag or true
end

function HintService:setHintBackgroundColor(backgroundColor: Color3)
	self._.BackgroundColor3 = backgroundColor
end

function HintService:setHintBackgroundCornerRadius(cornerRadius: UDim)
	self._.UICorner.CornerRadius = cornerRadius
end

function HintService:setHintBackgroundStroke(thickness: number, color: Color3, lineJoinMode)
	local borderUIStroke = self._.BorderUIStroke
	borderUIStroke.Color = color
	borderUIStroke.LineJoinMode = lineJoinMode
	borderUIStroke.Thickness = thickness
	borderUIStroke.Enabled = true
end

function HintService:setLabelStroke(thickness: number, color: Color3, lineJoinMode)
	local textUIStroke = self._.TextUIStroke
	textUIStroke.Color = color
	textUIStroke.LineJoinMode = lineJoinMode
	textUIStroke.Thickness = thickness
	textUIStroke.Enabled = true
end

function HintService:Destroy()
	self.VisibleTime = 0
end

function HintService:activateHint(flag: boolean)
	local function activateHint()
		local v2 = self._
		v2.Visible = true
		local lastTime = os.clock()
		HintService.HintAdded:Fire()
		TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		}):Play()
		TweenService:Create(
			v2:WaitForChild("BorderUIStroke"),
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Transparency = 0.2
			}
		):Play()
		TweenService:Create(
			v2:WaitForChild("TextUIStroke"),
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Transparency = 0
			}
		):Play()

		while os.clock() - lastTime < self.VisibleTime - 1 do
			wait()
		end

		HintService.HintRemoving:Fire()
		TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		TweenService:Create(
			v2:WaitForChild("BorderUIStroke"),
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
		TweenService:Create(
			v2:WaitForChild("TextUIStroke"),
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()

		if self.DestroyOnFinished == true then
			task.wait(1)
			v2:Destroy()
		end
	end

	if flag then
		activateHint()
	else
		task.spawn(activateHint)
	end
end

return HintService