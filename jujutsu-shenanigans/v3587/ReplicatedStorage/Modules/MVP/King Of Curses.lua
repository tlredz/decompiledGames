local KingOfCurses = {}
local RunService = game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer

function KingOfCurses.Start(_, player, list)
	if not player.Character then
		return
	end

	local clone = script.Innate:Clone()
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
	local clone2 = script.Voice:Clone()
	clone2.SoundGroup = game.SoundService.Voice
	clone2.Parent = workspace
	table.insert(list, clone2)
	local track = clone.Rig.Humanoid:LoadAnimation(script.Character)
	local track2 = clone.Camera.Humanoid:LoadAnimation(script.Camera)
	track:Play(0, nil, 0)
	table.insert(list, track)
	track2:Play(0, nil, 0)
	table.insert(list, track2)
	task.spawn(function()
		RunService:BindToRenderStep("Focus", 301, function()
			workspace.CurrentCamera.Focus = clone.Camera.Torso.CFrame
		end)
		task.wait(3)
		RunService:UnbindFromRenderStep("Focus")
	end)
	task.wait(1)
	local clone3 = script.SukunaAtmo:Clone()
	clone3.Parent = game.Lighting
	table.insert(list, clone3)
	task.wait(1.5)
	local clone4 = script.DepthOfField:Clone()
	clone4.Parent = game.Lighting
	table.insert(list, clone4)
	localPlayer.PlayerGui.Main.Enabled = false
	local currentCamera = workspace.CurrentCamera
	currentCamera.FieldOfView = 41
	currentCamera.CameraType = Enum.CameraType.Scriptable
	table.insert(list, RunService.RenderStepped:Connect(function()
		currentCamera.CFrame = clone.Camera.Torso.CFrame
	end))
	local v = tick() + 0.25

	repeat
		task.wait()
	until track.Length > 0 and track2.Length > 0 and clone2.IsLoaded or v < tick()

	track:AdjustSpeed(1)
	track2:AdjustSpeed(1)
	clone2:Play()
	clone.Dust.Dust:Emit(300)
	task.wait(0.7)
	task.wait(3.5)
	task.wait(2.3)
	track:AdjustSpeed(0)
	track2:AdjustSpeed(0)
	clone.Dust.Dust.TimeScale = 0
end

return KingOfCurses