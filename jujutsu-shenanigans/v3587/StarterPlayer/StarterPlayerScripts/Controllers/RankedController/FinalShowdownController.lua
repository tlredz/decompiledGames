local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
require(replicatedStorage.Modules.Icon)
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(localPlayer.PlayerScripts.PlayerModule)
require(replicatedStorage.Modules.MVP)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "FinalShowdownController"
})

function controller.Start(_)
	task.spawn(function()
		local roulette = localPlayer.PlayerGui:WaitForChild("Roulette")
		local spectate = roulette.Gamemode_Items.Spectate
		roulette.Enabled = true
		workspace:GetAttributeChangedSignal("Timer"):Connect(function()
			if workspace:GetAttribute("Timer") == nil then
				roulette.Time.Visible = false
				return
			end

			roulette.Time.Text = workspace:GetAttribute("Timer")
			roulette.Time.Size = UDim2.new(1, 0, 0.15, 0)
			roulette.Time.AnchorPoint = Vector2.new(0.5, 0.2)
			roulette.Time.Rotation = 5
			roulette.Time.Visible = true
			TweenService:Create(roulette.Time, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0.1, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Rotation = 0
			}):Play()
		end)
		local buttons = localPlayer.PlayerGui.Roulette.Gamemode_Items.Buttons
		buttons.AFK.Visible = false
		RunService.RenderStepped:Connect(function(dt)
			roulette.Load.WaitSpin.Rotation += 30 * dt
			spectate.Static.Position = UDim2.new(math.random(-100, 0) / 100, 0, math.random(-100, 0) / 100, 0)
			local v3 = false

			if localPlayer.Team and localPlayer.Team.Name == "Lobby" then
				localPlayer.PlayerGui.Main.Enabled = false
				buttons.Visible = true
			else
				localPlayer.PlayerGui.Main.Enabled = true
				buttons.Visible = false
				v3 = true
			end

			if workspace.Effects:FindFirstChild("WaitAmbience") then
				if v3 == false then
					workspace.Effects.WaitAmbience.Volume = workspace.Effects.WaitAmbience.Vol.Value
				else
					workspace.Effects.WaitAmbience.Volume = 0
				end
			end
		end)
		local v3 = 1
		localPlayer:GetAttributeChangedSignal("Spectate"):Connect(function()
			v3 = 1
			spectate.Visible = localPlayer:GetAttribute("Spectate")

			if localPlayer:GetAttribute("Spectate") ~= true then
				local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
				workspace.CurrentCamera.CameraSubject = character:WaitForChild("Humanoid", 1)
			end
		end)
		localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
			localPlayer:SetAttribute("Spectate", nil)
		end)
		buttons.Spectate.MouseButton1Down:Connect(function()
			v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
			v2:PlaySound(sounds.Misc.UI.SpectateStart, workspace, game.SoundService.Effect)
			localPlayer:SetAttribute("Spectate", localPlayer:GetAttribute("Spectate") == nil or nil)
		end)
		spectate.CycleLeft.MouseButton1Down:Connect(function()
			local v4 = {}

			for _, v5 in game.Players:GetPlayers() do
				if v5 == localPlayer then
					table.insert(v4, v5)
				elseif v5.Team.Name ~= "Lobby" then
					table.insert(v4, v5)
				end
			end

			table.sort(v4, function(a, _)
				return a == localPlayer
			end)
			v3 -= 1

			if v3 < 1 then
				v3 = #v4
			end

			local cameraSubject

			if v4[v3].Character then
				cameraSubject = v4[v3].Character:FindFirstChild("Head") or localPlayer.Character.Humanoid
			end

			workspace.CurrentCamera.CameraSubject = cameraSubject
			spectate.Spectating.Spectating.Text = v4[v3].Name
			spectate.Static.ImageTransparency = 0
			TweenService:Create(spectate.Static, TweenInfo.new(1), {
				ImageTransparency = 1
			}):Play()
			v2:PlaySound(sounds.Misc.UI.SpectateStart, workspace, game.SoundService.Effect)
		end)
		spectate.CycleRight.MouseButton1Down:Connect(function()
			local v4 = {}

			for _, v5 in game.Players:GetPlayers() do
				if v5 == localPlayer then
					table.insert(v4, v5)
				elseif v5.Team.Name ~= "Lobby" then
					table.insert(v4, v5)
				end
			end

			table.sort(v4, function(a, _)
				return a == localPlayer
			end)
			v3 += 1

			if v3 > #v4 then
				v3 = 1
			end

			local cameraSubject

			if v4[v3].Character then
				cameraSubject = v4[v3].Character:FindFirstChild("Head") or localPlayer.Character.Humanoid
			end

			workspace.CurrentCamera.CameraSubject = cameraSubject
			spectate.Spectating.Spectating.Text = v4[v3].Name
			spectate.Static.ImageTransparency = 0
			TweenService:Create(spectate.Static, TweenInfo.new(1), {
				ImageTransparency = 1
			}):Play()
			v2:PlaySound(sounds.Misc.UI.SpectateStart, workspace, game.SoundService.Effect)
		end)
	end)
	local v3 = {
		PipeShoot = function()
			local pipePoint = workspace.Map.Core.Pipe.Core.PipePoint

			for _, child in pipePoint.Wind:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			sounds.Misc.Pipe.PlaybackSpeed = math.random(14, 20) / 10
			v2:PlaySound(sounds.Misc.Pipe, pipePoint, game.SoundService.Effect)
		end,
		Transition = function(text)
			local load = localPlayer.PlayerGui:WaitForChild("Roulette"):WaitForChild("Load")
			load.Gamemode.Text = text
			load.WaitTime.Size = UDim2.new(0, 0, 0, 10)
			v2:PlaySound(sounds.Misc.UI.Load1, workspace, game.SoundService.Effect)
			local tweenInfo = TweenInfo.new(0.5)
			TweenService:Create(load, tweenInfo, {
				BackgroundTransparency = 0,
				ImageTransparency = 0
			}):Play()
			TweenService:Create(load.WaitSpin, tweenInfo, {
				ImageTransparency = 0
			}):Play()
			TweenService:Create(load.WaitTime, tweenInfo, {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(load.WaitTime, TweenInfo.new(1), {
				Size = UDim2.new(1, 0, 0, 10)
			}):Play()
			TweenService:Create(load.Gamemode, tweenInfo, {
				TextTransparency = 0
			}):Play()

			repeat
				task.wait()
			until not workspace:GetAttribute("Loading")

			local tweenInfo2 = TweenInfo.new(1)
			v2:PlaySound(sounds.Misc.UI.Load2, workspace, game.SoundService.Effect)
			TweenService:Create(load, tweenInfo2, {
				BackgroundTransparency = 1,
				ImageTransparency = 1
			}):Play()
			TweenService:Create(load.WaitSpin, tweenInfo2, {
				ImageTransparency = 1
			}):Play()
			TweenService:Create(load.WaitTime, tweenInfo2, {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(load.Gamemode, tweenInfo2, {
				TextTransparency = 1
			}):Play()
		end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitStart(_) end

function controller.KnitInit(_)
	v = Knit.GetService("FinalShowdownService")
	v2 = Knit.GetController("FXController")
end

return controller