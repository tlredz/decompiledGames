local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local v = nil
local controller = Knit.CreateController({
	Name = "TutorialController"
})
local Info_Tutorial = require(replicatedStorage.Modules.Info_Tutorial)

function controller.KnitStart(_)
	local menus = localPlayer.PlayerGui:WaitForChild("Menus")
	local tutorial_Info = menus.Group.Tutorial_Info
	tutorial_Info:SetAttribute("Loaded", true)

	local function selecta(p, p2)
		v:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)

		for _, button in tutorial_Info.Items:GetChildren() do
			if not button:IsA("TextButton") then
				continue
			end

			if button == p2 then
				button.BackgroundTransparency = 0.5
			else
				button.BackgroundTransparency = 1
			end
		end

		local description = tutorial_Info.Description
		local v2 = Info_Tutorial[p]
		description.CanvasPosition = Vector2.new(0, 0)
		description.Title.Text = v2[2]
		description.Video.Video = "rbxassetid://" .. v2[3]
		description.Description.Text = ""

		for _, v3 in v2[4] do
			description.Description.Text = description.Description.Text .. v3 .. [[


]]
		end
	end

	tutorial_Info.Return.MouseButton1Down:Connect(function()
		tutorial_Info.Visible = false
	end)
	tutorial_Info:GetPropertyChangedSignal("Visible"):Connect(function()
		if tutorial_Info.Visible == true then
			for k, v2 in Info_Tutorial do
				local clone = menus.Preset.ItemBox:Clone()
				clone.Name = v2[1]
				clone.LayoutOrder = k
				clone.Text = v2[1]
				clone.Parent = tutorial_Info.Items

				if k == 1 then
					selecta(1, clone)
				end

				local v3 = k
				clone.MouseButton1Down:Connect(function()
					selecta(v3, clone)
				end)
			end

			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if tutorial_Info.Visible == false then
					renderSteppedConnection:Disconnect()
					return
				end

				tutorial_Info.Description.Video.Playing = false
				tutorial_Info.Description.Video.Playing = true
			end)
		else
			for _, button in tutorial_Info.Items:GetChildren() do
				if button:IsA("TextButton") then
					button:Destroy()
				end
			end

			tutorial_Info.Description.Video.Video = ""
		end
	end)
	tutorial_Info.Description.Video:GetPropertyChangedSignal("IsLoaded"):Connect(function()
		if tutorial_Info.Description.Video.IsLoaded then
			TweenService:Create(tutorial_Info.Description.Video.Fade, TweenInfo.new(0.4), {
				BackgroundTransparency = 1
			}):Play()
		else
			TweenService:Create(tutorial_Info.Description.Video.Fade, TweenInfo.new(0), {
				BackgroundTransparency = 0
			}):Play()
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetController("FXController")
end

return controller