local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "AnkleCutterController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Haruta.AnkleCutterWhoosh, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(0.745098, 0, 0.0117647))
			v2:PlaySound(sounds.Haruta.AnkleCutterHit, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 5 do
				BloodyZee:Blood(instance["Right Leg"].CFrame * CFrame.new(0, 0.5, 0), -math.random(20, 70), 25, 25)
			end

			for _ = 1, 5 do
				BloodyZee:Blood(instance["Left Leg"].CFrame * CFrame.new(0, 0.5, 0), -math.random(20, 70), 25, 25)
			end
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (150 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Dash = function(p, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			RunService.Stepped:Wait()
			local v5 = CFrame.new(p2, humanoidRootPart.Position) * CFrame.new(0, -2.25, 0)
			local magnitude = (p2 - humanoidRootPart.Position).Magnitude
			local clone = utils.Mahito.Dash:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.5)
			Debris:AddItem(model, 0.2)
			clone.CFrame = v5 + v5.LookVector * magnitude / 2
			clone.Size = Vector3.new(1.5, 1.5, magnitude)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = Vector3.new(0, 0, magnitude),
				CFrame = clone.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			Debris:AddItem(clone, 0.2)
			local model2 = Instance.new("Model")
			local clone2 = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0) * CFrame.new(0, -2.25, 0)
			clone2.Parent = model2
			model2.Parent = workspace.Effects
			model2:ScaleTo(0.4)
			clone2.Ring:Emit(7)
			clone2.Dash1.Dash:Emit(1)
			clone2.Dash2.Dash:Emit(1)
			Debris:AddItem(model2, 2)
			local clone3 = utils.Itadori.Shock:Clone()
			clone3.CFrame = v5 * CFrame.Angles(1.5707963267948966, 0, 0)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.3), {
				Size = createVector(7, 0, 7),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone3, 0.3)
			task.delay(0.075, function()
				local clone4 = utils.Itadori.Shock:Clone()
				clone4.CFrame = v5 * CFrame.Angles(1.5707963267948966, 0, 0) + v5.LookVector * 3
				clone4.Parent = workspace.Effects
				TweenService:Create(clone4, TweenInfo.new(0.2), {
					Size = createVector(5, 0, 5),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone4, 0.2)
				task.wait(0.075)
				local clone5 = utils.Itadori.Shock:Clone()
				clone5.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.25, 0) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone5.Parent = workspace.Effects
				TweenService:Create(clone5, TweenInfo.new(0.2), {
					Size = createVector(5, 0, 5),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone5, 0.2)
			end)
			v2:PlaySound(sounds.Nanami.BluntCut.Dash, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("AnkleCutterService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller