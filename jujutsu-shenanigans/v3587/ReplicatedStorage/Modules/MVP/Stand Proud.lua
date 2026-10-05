local StandProud = {}
local RunService = game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer

function StandProud.Start(_, player, list)
	if not player.Character then
		return
	end

	local clone = script.Meteor:Clone()
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
	local clone3 = script.Voice:Clone()
	clone3.SoundGroup = game.SoundService.Voice
	clone3.Parent = workspace
	table.insert(list, clone3)
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
		currentCamera.CFrame = clone.Camera.Torso.CFrame
	end))
	local v = tick() + 0.25

	repeat
		task.wait()
	until track.Length > 0 and track2.Length > 0 and clone2.IsLoaded or v < tick()

	track:AdjustSpeed(1)
	track2:AdjustSpeed(1)
	clone2:Play()
	clone3:Play()
	task.wait(3.533)
	local clone4 = script.ColorCorrection:Clone()
	clone4.Parent = game.Lighting
	table.insert(list, clone4)
	local clone5 = script.DepthOfField:Clone()
	clone5.Parent = game.Lighting
	table.insert(list, clone5)
	clone.BG.Transparency = 1
	clone.Meteor.BG.Transparency = 0
	clone.Meteor.Meteor.Transparency = 0
	clone.Meteor.BG.Beam.Enabled = true
	clone.Meteor.BG.Beam2.Enabled = true
	clone.Meteor.BG.Beam3.Enabled = true
	clone.Meteor.Sparks.Hit:Emit(200)
	clone.Meteor.Meteor.Dust:Emit(75)
	clone.Camera.Torso.Flames.Enabled = true
	task.wait(2.967)
	track:AdjustSpeed(0)
	track2:AdjustSpeed(0)
	clone.Meteor.BG.Beam.TextureSpeed = 0
	clone.Meteor.BG.Beam2.TextureSpeed = 0
	clone.Meteor.BG.Beam3.TextureSpeed = 0
	clone.Meteor.Sparks.Hit.TimeScale = 0
	clone.Camera.Torso.Flames.TimeScale = 0
	clone.Meteor.Meteor.Dust.TimeScale = 0
end

return StandProud