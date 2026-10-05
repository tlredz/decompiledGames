local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
return {
	setupAll = function()
		local screenGui = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
		local loadingScreen = Players.LocalPlayer.PlayerGui:WaitForChild("LoadingGui"):WaitForChild("LoadingScreen")
		loadingScreen.Position = UDim2.new(0, 0, -1, 0)
		loadingScreen.Visible = false
		workspace.Info.Loading.Changed:Connect(function()
			if workspace.Info.Loading.Value == true then
				loadingScreen.Visible = true
				local tween = TweenService:Create(
					loadingScreen,
					TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false),
					{
						Position = UDim2.new(0, 0, 0.1, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				local tween2 = TweenService:Create(
					loadingScreen,
					TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false),
					{
						Position = UDim2.new(0, 0, 0, 0)
					}
				)
				Audio:PlayOne("Sounds.UI.Transitions.PlaceSound")
				Audio:PlayOne("Sounds.UI.Transitions.CloseSound")
				tween2:Play()
				tween2.Completed:Wait()

				if workspace.Info.GameStarted.Value == true then
					screenGui.Menu.BackgroundFrame.Visible = false
				end
			else
				local tween = TweenService:Create(
					loadingScreen,
					TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false),
					{
						Position = UDim2.new(0, 0, -1, 0)
					}
				)
				tween:Play()
				Audio:PlayOne("Sounds.UI.Transitions.Closing")
				tween.Completed:Wait()
				loadingScreen.Visible = false
			end
		end)
	end
}