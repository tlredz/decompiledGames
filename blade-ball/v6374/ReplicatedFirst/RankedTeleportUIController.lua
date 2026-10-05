local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local arrivingTeleportGui = TeleportService:GetArrivingTeleportGui()

if arrivingTeleportGui and arrivingTeleportGui.Name == "RankedTeleportUI" then
	arrivingTeleportGui.Parent = playerGui

	if not game.Loaded then
		game.Loaded:Wait()
	end

	if not localPlayer.Character then
		localPlayer.CharacterAdded:Wait()
	end

	task.wait(1)
	arrivingTeleportGui.VFX.Circle.Visible = true
	arrivingTeleportGui.VFX.Glow.Visible = true
	arrivingTeleportGui.VFX.Visible = true
	local tween = TweenService:Create(
		arrivingTeleportGui.VFX,
		TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{
			Size = UDim2.fromScale(4, 4)
		}
	)
	local tween2 = TweenService:Create(
		arrivingTeleportGui.VFX.Circle,
		TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		{
			BackgroundTransparency = 1
		}
	)
	local tween3 = TweenService:Create(
		arrivingTeleportGui.VFX.Glow,
		TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		{
			ImageTransparency = 1
		}
	)
	tween:Play()
	tween.Completed:Wait()
	arrivingTeleportGui.BlackoutBottom.Visible = false
	arrivingTeleportGui.BlackoutTop.Visible = false
	arrivingTeleportGui.Header.Visible = false
	arrivingTeleportGui.Loading.Visible = false
	arrivingTeleportGui.MapButton.Visible = false
	arrivingTeleportGui.Box.Visible = false
	arrivingTeleportGui.MapImage.Visible = false
	task.wait(1)
	tween2:Play()
	tween3:Play()
	tween3.Completed:Wait()
	arrivingTeleportGui.VFX.Circle.Visible = false
	arrivingTeleportGui.VFX.Glow.Visible = false
	arrivingTeleportGui:Destroy()
end