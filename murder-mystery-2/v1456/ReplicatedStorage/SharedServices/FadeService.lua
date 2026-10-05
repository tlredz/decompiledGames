local FadeService = {
	CreateFadeInfo = function(self)
		return {
			Start = {
				BackgroundTransparency = nil,
				BackgroundColor3 = nil
			},
			End = {
				BackgroundTransparency = nil,
				BackgroundColor3 = nil
			},
			Time = 1
		}
	end
}
FadeService.FadeIn = FadeService:CreateFadeInfo()
FadeService.FadeIn.Start.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FadeService.FadeIn.Start.BackgroundTransparency = 0
FadeService.FadeIn.End.BackgroundTransparency = 1
FadeService.FadeOut = FadeService:CreateFadeInfo()
FadeService.FadeOut.Start.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FadeService.FadeOut.Start.BackgroundTransparency = 1
FadeService.FadeOut.End.BackgroundTransparency = 0

function FadeService.PlayFade(data)
	local TweenService = game:GetService("TweenService")
	local frame = game.Players.LocalPlayer.PlayerGui:WaitForChild("Fade"):WaitForChild("Frame")
	frame.BackgroundTransparency = data.Start.BackgroundTransparency
	frame.BackgroundColor3 = data.Start.BackgroundColor3
	TweenService:Create(frame, TweenInfo.new(data.Time, Enum.EasingStyle.Linear), {
		BackgroundTransparency = data.End.BackgroundTransparency,
		BackgroundColor3 = data.End.BackgroundColor3
	}):Play()
end

return FadeService