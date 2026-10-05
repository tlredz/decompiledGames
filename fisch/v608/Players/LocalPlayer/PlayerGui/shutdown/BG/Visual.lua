script.Parent.Parent:GetPropertyChangedSignal("Enabled"):Wait()
local TweenService = game:GetService("TweenService")
TweenService:Create(
	script.Parent:WaitForChild("fish"),
	TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
	{
		Rotation = 60
	}
):Play()
local TeleportService = game:GetService("TeleportService")
TeleportService:SetTeleportGui(script.Parent.Parent)