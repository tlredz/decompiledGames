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
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "SacrilegiousController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Charles.Despair.Spin, humanoidRootPart, game.SoundService.Effect)
		end,
		Stab = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hiromi.Execution.Stab, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Dialog = function(instance, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = utils.Charles.Dialogue:Clone()
			clone.StudsOffset = p == 1 and createVector(-2.5, -0.5, 2) or createVector(2.5, -0.5, 2)
			clone.Chat.Sub.Text = p == 1 and "STOP DESECRATING THIS WORK!!" or "DID YOU EVEN READ THE ORIGINAL PROPERLY!?"
			clone.Parent = instance.Head
			local position = clone.Chat.Position
			clone.Chat.Position = position + UDim2.new(0, 0, 0.5, 0)
			TweenService:Create(clone.Chat, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Chat, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(0.8)
			Debris:AddItem(clone, 0.5)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("Frame") then
					TweenService:Create(guiObject, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = position + UDim2.new(0, 0, 0.3, 0),
						BackgroundTransparency = 1
					}):Play()
				elseif guiObject:IsA("TextLabel") then
					TweenService:Create(guiObject, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()
				end
			end
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Charles.ShutUp.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Spin = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Charles.Throw, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Charles.ShutUp.Hit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Dash = function(p, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			RunService.Stepped:Wait()
			local cframe = CFrame.new(p2, humanoidRootPart.Position)
			local magnitude = (p2 - humanoidRootPart.Position).Magnitude
			local clone = utils.Mahito.Dash:Clone()
			clone.CFrame = cframe + cframe.LookVector * magnitude / 2
			clone.Size = Vector3.new(5, 5, magnitude)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = Vector3.new(0, 0, magnitude),
				CFrame = clone.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			Debris:AddItem(clone, 0.2)
			local model = Instance.new("Model")
			local clone2 = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			clone2.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.6)
			clone2.Ring:Emit(7)
			clone2.Dash1.Dash:Emit(1)
			clone2.Dash2.Dash:Emit(1)
			Debris:AddItem(model, 2)
			local clone3 = utils.Itadori.Shock:Clone()
			clone3.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.3), {
				Size = createVector(10, 0, 10),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone3, 0.3)
			task.delay(0.075, function()
				local clone4 = utils.Itadori.Shock:Clone()
				clone4.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0) + cframe.LookVector * 3
				clone4.Parent = workspace.Effects
				TweenService:Create(clone4, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone4, 0.2)
				task.wait(0.075)
				local clone5 = utils.Itadori.Shock:Clone()
				clone5.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone5.Parent = workspace.Effects
				TweenService:Create(clone5, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone5, 0.2)
			end)
			v2:PlaySound(sounds.Yuki.Swing, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Charles.Despair.Swing, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
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

function controller.KnitInit(_)
	v = Knit.GetService("SacrilegiousService")
	v2 = Knit.GetController("FXController")
end

return controller