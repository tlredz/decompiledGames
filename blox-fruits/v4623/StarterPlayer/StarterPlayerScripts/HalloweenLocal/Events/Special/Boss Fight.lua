local createVector = vector.create
local _ = game.ReplicatedStorage.Remotes.HalloweenEvent
require(game.ReplicatedStorage.DialogueController)
local Sound = require(game.ReplicatedStorage.Util.Sound)

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayRandomSound(p: string, p2: number, position, value: number?)
	local v = math.random(1, p2)
	Sound:Play(string.format("%s_%02d", p, v), position, nil, nil, value or 2)
end

return {
	RunEarly = true,
	func = function(object, p, _, _)
		local v = p.WorldModel:GetChildren()[1]
		local cutscene = v.Cutscene
		local connections = {}

		local function SoundAdded(sound)
			if not sound:IsA("Sound") then
				return
			end

			sound:Pause()
			table.insert(connections, sound.Resumed:Connect(function()
				sound:Pause()
			end))
		end

		for _, child in pairs(workspace._WorldOrigin.Sounds.Locations:GetChildren()) do
			SoundAdded(child)
		end

		table.insert(connections, workspace._WorldOrigin.Sounds.Locations.ChildAdded:Connect(SoundAdded))

		if (object.Part.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 300 then
			local Global = require(game.ReplicatedStorage.Global)

			if not Global.ALREADYINDOOR then
				cutscene:PivotTo(workspace.CurrentCamera.CFrame + createVector(0, 10000, 0))
				cutscene.Parent = workspace
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync({
					cutscene.Animations.Wolf.AnimationId,
					cutscene.Animations.WolfCamera.AnimationId,
					game.ReplicatedStorage.Util.Sound:FindFirstChild("HalloweenWerewolfCutscene", true).SoundId
				})
				local track = cutscene["Wolf (V6)"]:FindFirstChild("Animator", true):LoadAnimation(cutscene.Animations.Wolf)
				local track2 = cutscene.CamReAdd:FindFirstChild("Animator", true):LoadAnimation(cutscene.Animations.WolfCamera)
				track:Play()
				track2:Play()
				local total = 0

				while total < 5 do
					total += task.wait()

					if not (track.TimePosition > 0 and track2.TimePosition > 0) then
						continue
					end

					local timePosition = math.min(track.TimePosition, track2.TimePosition)
					track.TimePosition = timePosition
					track2.TimePosition = timePosition
					local play = Sound:Play("HalloweenWerewolfCutscene", workspace)
					play.TimePosition = timePosition
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
					colorCorrectionEffect.Enabled = true
					colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
					local TweenService = game:GetService("TweenService")
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
						{
							TintColor = Color3.fromRGB(0, 0, 0)
						}
					):Play()
					game.Debris:AddItem(colorCorrectionEffect, 1.1)
					task.wait(0.5)
					local RunService = game:GetService("RunService")
					RunService:BindToRenderStep("WolfCam", Enum.RenderPriority.Camera.Value, function()
						workspace.CurrentCamera.CFrame = cutscene.CamReAdd.Part3.CFrame
					end)
					break
				end

				while track.TimePosition < 12 and task.wait() do

				end

				if math.random() < 0.1 then
					cutscene["Wolf (V6)"].Attachment.ParticleEmitter:Emit(1)
				end

				task.wait(2)
			end
		end

		local comm = v.comm
		comm.Parent = script
		comm.CFrame = object.Part.CFrame * CFrame.new(0, 0, -0.5)
		PlayRandomSound("Halloween_Portal_Appear", 5, comm.Position) -- equivalent call inferred; original call site unknown
		object:GetAttributeChangedSignal("BOSS_ACTIVE_SERVER"):Once(function()
			comm:Destroy()
			cutscene:Destroy()
		end)

		if p.Parent then
			comm.Parent = workspace
		end

		task.wait(0.1)

		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		for _, child in pairs(workspace._WorldOrigin.Sounds.Locations:GetChildren()) do
			child:Resume()
		end

		pcall(function()
			local RunService = game:GetService("RunService")
			RunService:UnbindFromRenderStep("WolfCam")
		end)
	end
}