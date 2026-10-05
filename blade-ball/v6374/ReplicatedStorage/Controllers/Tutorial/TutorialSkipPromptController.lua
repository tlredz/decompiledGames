local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.FastUtils)
local tutorialSkipPrompt = Players.LocalPlayer.PlayerGui:WaitForChild("TutorialSkipPrompt")
local remoteEvent = v:RemoteEvent("TutorialTeleport")
local remoteEvent2 = v:RemoteEvent("ShowTutorialSkipPrompt")
return {
	Start = function(_)
		local connection = nil

		local function exit()
			if v3:IsOpen(tutorialSkipPrompt.Name) then
				v3:Unlock(tutorialSkipPrompt.Name, true)
				v3:Close(tutorialSkipPrompt.Name)
			end

			if connection and connection.Connected then
				connection:Disconnect()
			end

			ReplicatedStorage2.Remotes.ChangedAfkMode:FireServer(false)
		end

		local buttons = tutorialSkipPrompt.Main.Buttons
		local lose = tutorialSkipPrompt.Main.Lose
		buttons.Play.Activated:Connect(function()
			remoteEvent:FireServer()
			exit()
		end)

		local function tweenIn()
			tutorialSkipPrompt.Black.BackgroundTransparency = 1
			lose.Title.Position = UDim2.fromScale(0.511, -1)
			lose.TextGlow.ImageTransparency = 1
			lose.TextGlow.Label.TextTransparency = 1
			lose.TextGlow.Label.UIStroke.Transparency = 1
			buttons.Play.Position = UDim2.fromScale(0.5, 2)
			buttons.Close.Position = UDim2.fromScale(0.5, 2)
			buttons.Play.Active = false
			buttons.Close.Active = false
			TweenService:Create(
				tutorialSkipPrompt.Black,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					BackgroundTransparency = 0.2
				}
			):Play()
			TweenService:Create(lose.Title, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.511, -0.026)
			}):Play()
			task.wait(1.25)
			TweenService:Create(
				lose.TextGlow.Label,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					TextTransparency = 0
				}
			):Play()
			TweenService:Create(
				lose.TextGlow.Label.UIStroke,
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Transparency = 0
				}
			):Play()
			TweenService:Create(lose.TextGlow, TweenInfo.new(1.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				ImageTransparency = 0
			}):Play()
			task.wait(1)
			TweenService:Create(buttons.Play, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, 0)
			}):Play()
			task.wait(0.5)
			TweenService:Create(buttons.Close, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, 0.74)
			}):Play()
			task.delay(0.75, function()
				buttons.Play.Active = true
				buttons.Close.Active = true
			end)
		end

		local function show()
			if not v3:IsOpen(tutorialSkipPrompt.Name) then
				v3:Open(tutorialSkipPrompt.Name)
				v3:Lock(tutorialSkipPrompt.Name, true)
			end

			ReplicatedStorage2.Remotes.ChangedAfkMode:FireServer(true)
			tweenIn()
			local lastTime = os.clock()
			connection = v2.Thread.Every(1, function()
				local v4 = math.max(0, 20 - (os.clock() - lastTime))
				buttons.Close.Timer.Text = `{math.ceil(v4)}s`

				if v4 == 0 then
					exit()
				end
			end)
		end

		buttons.Close.Activated:Connect(exit)
		remoteEvent2.OnClientEvent:Connect(show)
	end
}