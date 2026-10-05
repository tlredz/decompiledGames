local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
localPlayer:WaitForChild("PlayerGui")
gui_Circle_effect_tweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = localPlayer.PlayerGui
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1
frame.Parent = screenGui
local GuiEffects = {
	y_ting = workspace.CurrentCamera.ViewportSize.Y - frame.AbsoluteSize.Y
}
frame:Destroy()
screenGui:Destroy()
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))

function GuiEffects.Circle(_, parent, _, imageColor, p, p2)
	if not (Platform_Handler.Platform.Id ~= 2 and script:FindFirstChild("Circle") ~= nil) then
		return
	end

	if parent ~= nil then
		local v = mouse.X - parent.AbsolutePosition.X
		local v2 = mouse.Y - parent.AbsolutePosition.Y
		local clone = script.Circle:Clone()

		if imageColor ~= nil then
			clone.ImageColor3 = imageColor
		end

		clone.Position = p2 or UDim2.new(0, v, 0, v2 + ((p == nil or not p) and 0 or p), 0)
		clone.Size = UDim2.new(0, 41.25, 0, 41.25)
		clone.Parent = parent
		game.TweenService:Create(clone, gui_Circle_effect_tweeninfo, {
			Size = UDim2.new(0, 55, 0, 55),
			ImageTransparency = 1
		}):Play()
		DebrisModule:AddItem(clone, 0.25)
	end
end

function GuiEffects.Click(_, parent)
	local click_Select = script:FindFirstChild("Click_Select")

	if click_Select ~= nil then
		local clone = click_Select:Clone()
		clone.Parent = parent
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
	end
end

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

function GuiEffects.gloss(_, parent, p)
	for _ = 1, math.random(1, 2) do
		local clone = script.Folder:GetChildren()[math.random(1, #script.Folder:GetChildren())]:Clone()
		clone.Parent = parent
		clone.UICorner.CornerRadius = p or UDim.new(1, 0)
		DebrisModule:AddItem(clone, 0.9)
		clone.UIGradient.Offset = Vector2.new(-0.5, 0)
		TweenService:Create(clone.UIGradient, tweenInfo, {
			Offset = Vector2.new(1.4 * (math.random(2, 4) / 2), 0)
		}):Play()
		wait(0.05, 0.12)
	end
end

return GuiEffects