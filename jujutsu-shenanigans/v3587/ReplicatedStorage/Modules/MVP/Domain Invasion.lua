local DomainInvasion = {}
local RunService = game:GetService("RunService")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer

function DomainInvasion.Start(_, player, list)
	if not player.Character then
		return
	end

	local clone = script.Domain:Clone()
	clone.Parent = workspace.Effects
	table.insert(list, clone)
	task.spawn(function()
		local v

		if player.Character then
			v = player.Character.Humanoid:GetAppliedDescription()
		else
			v = game.Players:GetHumanoidDescriptionFromUserId(player.UserId)
		end

		clone.Rig.Humanoid:ApplyDescriptionReset(v)
	end)
	local clone2 = script.SFX:Clone()
	clone2.SoundGroup = game.SoundService.Effect
	clone2.Parent = workspace
	table.insert(list, clone2)
	local track = clone.Rig.Humanoid:LoadAnimation(script.Character)
	local track2 = clone.Camera.Humanoid:LoadAnimation(script.Camera)
	track:Play(0, nil, 0)
	table.insert(list, track)
	track2:Play(0, nil, 0)
	table.insert(list, track2)
	task.wait(2.5)
	localPlayer.PlayerGui.Main.Enabled = false
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable
	table.insert(list, RunService.RenderStepped:Connect(function()
		currentCamera.FieldOfView = 40
		currentCamera.CFrame = clone.Camera.Torso.CFrame
		local v = currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 500
		clone.BG.BG.CFrame = CFrame.new(v, currentCamera.CFrame.Position) * CFrame.Angles(0, 3.141592653589793, 0)
	end))
	local v = tick() + 0.25

	repeat
		task.wait()
	until track.Length > 0 and track2.Length > 0 and clone2.IsLoaded or v < tick()

	track:AdjustSpeed(1)
	track2:AdjustSpeed(1)
	clone2:Play()
	local clone3 = script.DepthOfField:Clone()
	clone3.Parent = game.Lighting
	table.insert(list, clone3)
	clone.BG.BG.Clouds:Emit(200)
	clone.BG.Water.Attachment2.ShadowSpark:Emit(100)
	TweenService:Create(clone.BG.Water.Attachment.Shadow, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		TimeScale = 0.04
	}):Play()
	TweenService:Create(clone.BG.Water.Attachment2.ShadowSpark, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {
		TimeScale = 0.08,
		Rate = 0
	}):Play()
	task.wait(2)
	clone.BG.BG.Clouds:Clear()
	clone.BG.BG.Clouds:Emit(200)
	track:AdjustSpeed(0.9)
	track2:AdjustSpeed(0.9)
	task.wait(4.5)
	track:AdjustSpeed(0)
	track2:AdjustSpeed(0)
	clone.BG.BG.Clouds.TimeScale = 0
	clone.BG.Water.Attachment.Shadow.TimeScale = 0
	clone.BG.Water.Attachment2.ShadowSpark.TimeScale = 0
end

return DomainInvasion