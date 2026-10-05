local Knit = require(game.ReplicatedStorage.Knit.Knit)
local UserInputService = game:GetService("UserInputService")
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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "FinalJudgementController"
})

function controller.KnitStart(_)
	local v4 = {
		Charge = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(85, 255, 127), 1)
			v3:PlaySound(sounds.Hakari.OverLuck.Charge, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = v3:PlaySound(sounds.Hiromi.Sprint, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				local numberValue = Instance.new("NumberValue", parent)
				numberValue.Value = 0
				TweenService:Create(numberValue, TweenInfo.new(1), {
					Value = 65
				}):Play()
				parent:GetAttributeChangedSignal("Swing"):Connect(function()
					TweenService:Create(
						numberValue,
						TweenInfo.new(0.4, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
						{
							Value = 0
						}
					):Play()
				end)

				repeat
					parent.Velocity = humanoidRootPart.CFrame.LookVector * numberValue.Value
					RunService.Stepped:Wait()
				until not (parent.Parent and humanoidRootPart.Parent)

				if v5 and v5.Playing then
					v5:Destroy()
				end
			end
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hiromi.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Dodge = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hiromi.Dodges, humanoidRootPart, game.SoundService.Effect)
		end,
		Miss = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Damage.HitGlow:Clone()

			if instance:GetScale() ~= 1 then
				clone:ScaleTo(instance:GetScale())
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)

			for _, child in clone:GetChildren() do
				local child2 = instance:FindFirstChild(child.Name)

				if child2 then
					child.CFrame = child2.CFrame
				end

				child.Color = Color3.new(0, 0, 0)
				child.Anchored = true
				TweenService:Create(child, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end

			v3:PlaySound(sounds.Itadori.ManjiKick.Dodge, humanoidRootPart, game.SoundService.Effect)
		end,
		Parry = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = sounds.Misc.Block["Block" .. math.random(1, 3)]
			v5.Pitch = math.random(90, 110) / 100
			v3:PlaySound(v5, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Damage.BlockHit:Clone()
			clone.Parent = instance.Torso
			clone:Emit(1)
			Debris:AddItem(clone, 0.3)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(
				sounds.Itadori.M1:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart,
				game.SoundService.Effect
			)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Grab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Charged = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local execSword = instance.SetAssets:FindFirstChild("ExecSword")

			if not execSword then
				return
			end

			v3:PlaySound(sounds.Hiromi.Execution.Flash, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hiromi.SwordBuild.ChargeEmit:Clone()
			Debris:AddItem(clone, 1)
			clone.Parent = execSword

			for _, child in clone:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end,
		RealHit = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 0.498039), 1)
			v3:PlaySound(sounds.Hiromi.Stab, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 40 do
				BloodyZee:Blood(instance.Torso.CFrame, math.random(-150, -5), 25, 25)
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		Drag = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hiromi.SwordPull, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 8 do
				BloodyZee:Blood(instance.Torso.CFrame, math.random(5, 25), 25, 25)
			end
		end,
		QTE = function(object)
			local clone = utils.Hiromi.QTE:Clone()
			clone.Parent = localPlayer.PlayerGui
			TweenService:Create(clone.Health, TweenInfo.new(0.5), {
				BackgroundTransparency = 0.5
			}):Play()
			TweenService:Create(clone.Health.Bar1, TweenInfo.new(0.5), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Health.Bar2, TweenInfo.new(0.5), {
				BackgroundTransparency = 0
			}):Play()
			local v5 = {
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.D,
				Enum.KeyCode.ButtonX,
				Enum.KeyCode.ButtonY,
				Enum.KeyCode.ButtonB
			}
			local v6 = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.D }
			local v7 = {
				{ Enum.KeyCode.ButtonX, "rbxassetid://8981031512" },
				{ Enum.KeyCode.ButtonY, "rbxassetid://8981031340" },
				{ Enum.KeyCode.ButtonB, "rbxassetid://8981032988" }
			}
			local v8 = {
				{ Enum.KeyCode.ButtonX, "rbxassetid://126768975062846" },
				{ Enum.KeyCode.ButtonY, "rbxassetid://140161712330460" },
				{ Enum.KeyCode.ButtonB, "rbxassetid://137275294114393" }
			}
			local v9 = nil

			local function updateKeycode()
				local lastInput = v2.LastInput

				if lastInput == "Keyboard" then
					v9 = v6[math.random(1, #v6)]
					clone.QTE_PC.Text = v9.Name
				elseif lastInput == "Xbox" or lastInput == "Playstation" then
					local v10 = (lastInput == "Xbox" and v7 or v8)[math.random(1, #v7)]
					v9 = v10[1]
					clone.QTE_CONSOLE.ImageContent = Content.fromUri(v10[2])
				end
			end

			updateKeycode()
			clone.QTE_MOBILE.Position = UDim2.new(math.random(20, 70) / 100, 0, math.random(20, 70) / 100, 0)
			clone.QTE_MOBILE.MouseButton1Down:Connect(function()
				clone.QTE_MOBILE.Position = UDim2.new(math.random(20, 70) / 100, 0, math.random(20, 70) / 100, 0)
				v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
				object:FireServer(true)
			end)
			local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed or not table.find(v5, input.KeyCode) then
					return
				end

				if input.KeyCode == v9 then
					object:FireServer(true)
					v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
					v3:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
					clone.QTE_PC.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
					clone.QTE_PC.Size = UDim2.new(0, 65, 0, 65)
					TweenService:Create(clone.QTE_PC, TweenInfo.new(0.5), {
						BackgroundColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(0, 75, 0, 75)
					}):Play()
					clone.QTE_CONSOLE.ImageColor3 = Color3.fromRGB(0, 255, 127)
				else
					object:FireServer()
					v3:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
					clone.QTE_PC.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					clone.QTE_PC.Size = UDim2.new(0, 65, 0, 65)
					TweenService:Create(clone.QTE_PC, TweenInfo.new(0.5), {
						BackgroundColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(0, 75, 0, 75)
					}):Play()
					clone.QTE_CONSOLE.ImageColor3 = Color3.fromRGB(170, 0, 0)
				end

				clone.QTE_CONSOLE.Size = UDim2.new(0, 65, 0, 65)
				TweenService:Create(clone.QTE_CONSOLE, TweenInfo.new(0.5), {
					ImageColor3 = Color3.new(1, 1, 1),
					Size = UDim2.new(0, 75, 0, 75)
				}):Play()
				updateKeycode()
			end)

			repeat
				task.wait()
			until not object.Parent

			clone:Destroy()

			if inputBeganConnection then
				inputBeganConnection:Disconnect()
			end
		end,
		QTE2 = function(p, p2)
			local QTE = localPlayer.PlayerGui:FindFirstChild("QTE")

			if not QTE then
				return
			end

			local v5

			if p < 0 then
				v5 = 1 / math.abs(p)
			else
				v5 = p == 0 and 1 or p
			end

			local v6

			if p2 < 0 then
				v6 = 1 / math.abs(p2)
			else
				v6 = p2 == 0 and 1 or p2
			end

			local v7 = v5 + v6
			QTE.Health.Bar1.Size = UDim2.new(v5 / v7, 0, 1, 0)
		end,
		Haiyah = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Feint = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hiromi.Grapple.Start, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Itadori.CounterHit.Feint:Clone()

			for _, child in clone:GetChildren() do
				child.Color = ColorSequence.new(Color3.fromRGB(255, 195, 134))
				child.TimeScale = 0.75
			end

			clone.Parent = humanoidRootPart
			clone.Sparks:Emit(10)
			clone.Ring:Emit(3)
			Debris:AddItem(clone, 1)
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
	v = Knit.GetService("FinalJudgementService")
	v2 = Knit.GetController("ToolController")
	v3 = Knit.GetController("FXController")
end

return controller