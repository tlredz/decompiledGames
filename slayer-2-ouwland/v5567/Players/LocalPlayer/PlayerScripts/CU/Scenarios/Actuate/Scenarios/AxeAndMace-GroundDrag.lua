local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ScenariosType)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
require(ReplicatedStorage.RemotePlus.Handlers.Utility)
game.ReplicatedStorage.Player_Service.Values:WaitForChild(game.Players.LocalPlayer.Name)
local v = 0
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5)
local clock = os.clock
local AxeAndMaceGroundDrag = {}
AxeAndMaceGroundDrag.Activators = {
	EquippedAccessory = "Stone Breathing Weapon"
}

function AxeAndMaceGroundDrag.Do(_, instance)
	local v2 = math.random(1, 99999)
	v = v2
	local stoneBreathingWeapon = instance.Tool_Accessories:FindFirstChild("Stone Breathing Weapon")
	local humanoid = instance:FindFirstChild("Humanoid")

	if stoneBreathingWeapon ~= nil and stoneBreathingWeapon:WaitForChild("RootPart", 0.2) ~= nil then
		if v2 ~= v then
			return
		end

		local primaryPart = instance.PrimaryPart
		local ball = stoneBreathingWeapon.RootPart:FindFirstChild("Ball")

		if ball ~= nil and primaryPart ~= nil then
			task.spawn(function()
				local clone = script.DragPart:Clone()
				clone.Parent = workspace.Debree
				local pointLight = clone.Sparks.PointLight
				local playbackSpeed = clone.Sound.PlaybackSpeed
				local flag = false
				local instance2 = nil
				local v3

				while v2 == v and instance.Parent ~= nil and ball ~= nil and ball.Parent ~= nil and primaryPart ~= nil and primaryPart.Parent ~= nil and humanoid ~= nil and humanoid.Parent ~= nil do
					local transformedWorldCFrame = ball.TransformedWorldCFrame
					local raycastResult = workspace:Raycast(
						transformedWorldCFrame.Position + createVector(0, 4, 0),
						createVector(0, -7.25, 0),
						RaycastHelper.Crater
					)

					if raycastResult == nil or raycastResult.Position == nil or not (vector.magnitude(humanoid.MoveDirection) > 0.05) or not (vector.magnitude(primaryPart.AssemblyLinearVelocity) > 2) or not (clock() - Combat_presets.Last_Punched > Combat_presets.combo_duration) or not (clock() - Combat_presets.lastRunHit) or instance:FindFirstChild("SHC") ~= nil and instance.SHC.Value ~= "" then
						if flag then
							local v4 = math.random(1, 999)
							v3 = v4
							TweenService:Create(clone.Sound, tweenInfo, {
								Volume = 0
							}):Play()
							TweenService:Create(pointLight, tweenInfo, {
								Brightness = 0,
								Range = 0
							}):Play()
							task.delay(tweenInfo.Time, function()
								if v3 ~= v4 then
									return
								end

								clone.Sound:Stop()
							end)
							Ouwmit.Enable(clone, false)
							flag = false
						end
					else
						clone.CFrame = CFrame.new(raycastResult.Position) * primaryPart.CFrame.Rotation * CFrame.new(
							0,
							0.05,
							0
						)

						if flag == false then
							flag = true
							v3 = 0
							clone.Sound.Volume = 0
							clone.Sound:Play()
							TweenService:Create(clone.Sound, tweenInfo, {
								Volume = script.DragPart.Sound.Volume
							}):Play()
							TweenService:Create(pointLight, tweenInfo, {
								Brightness = script.DragPart.Sparks.PointLight.Brightness,
								Range = script.DragPart.Sparks.PointLight.Range
							}):Play()
							Ouwmit.Enable(clone, true, Ouwmit.Owned(instance, {
								Color = raycastResult.Instance.Color,
								ColorBlacklist = "Sparks"
							}))
							instance2 = raycastResult.Instance
						elseif instance2 ~= raycastResult.Instance then
							instance2 = raycastResult.Instance

							for _, emitter in ipairs(clone:GetChildren()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
								end
							end
						end

						local playbackSpeed2 = humanoid.WalkSpeed / 16

						if playbackSpeed2 > 1 then
							playbackSpeed2 = 1 + (playbackSpeed2 - 1) * 0.5
						end

						if playbackSpeed ~= playbackSpeed2 then
							TweenService:Create(clone.Sound, tweenInfo, {
								PlaybackSpeed = playbackSpeed2
							}):Play()
							playbackSpeed = playbackSpeed2
						end
					end

					task.wait(0.05)
				end

				v3 = 0
				TweenService:Create(pointLight, tweenInfo, {
					Brightness = 0,
					Range = 0
				}):Play()
				TweenService:Create(clone.Sound, tweenInfo, {
					Volume = 0
				}):Play()
				Ouwmit.Enable(clone, false)
				DebrisModule:AddItem(clone, 1)
			end)
		end
	end
end

function AxeAndMaceGroundDrag:Stop(_)
	v = 0
end

return AxeAndMaceGroundDrag