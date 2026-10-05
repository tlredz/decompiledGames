local Knit = require(game.ReplicatedStorage.Knit.Knit)
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
require(replicatedStorage.Modules.UltNames)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "BeamController"
})

function controller.KnitStart(_)
	local v4 = {
		ClashQTE = function(object, instance, instance2)
			local clone = utils.Misc.BeamQTE:Clone()
			local bar1 = clone.Health:WaitForChild("Bar1")
			bar1.BackgroundColor3 = instance:GetAttribute("BeamColor")
			local bar2 = clone.Health:WaitForChild("Bar2")
			bar2.BackgroundColor3 = instance2:GetAttribute("BeamColor")
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
			TweenService:Create(clone.Health.Center.Ball, TweenInfo.new(0.5), {
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

			local function updateBar()
				if not (instance.Parent and instance2.Parent) then
					return
				end

				local weight = instance:GetAttribute("Weight")
				local weight2 = instance2:GetAttribute("Weight")
				local v10

				if weight < 0 then
					v10 = 1 / math.abs(weight)
				else
					v10 = weight == 0 and 1 or weight
				end

				local v11

				if weight2 < 0 then
					v11 = 1 / math.abs(weight2)
				else
					v11 = weight2 == 0 and 1 or weight2
				end

				local v12 = v10 + v11
				clone.Health.Bar1.Size = UDim2.new(v10 / v12, 0, 1, 0)
			end

			updateBar()
			instance:GetAttributeChangedSignal("Weight"):Connect(updateBar)
			instance2:GetAttributeChangedSignal("Weight"):Connect(updateBar)

			repeat
				task.wait()
			until not object.Parent

			clone:Destroy()

			if inputBeganConnection then
				inputBeganConnection:Disconnect()
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
	v = Knit.GetService("BeamService")
	v3 = Knit.GetController("FXController")
	v2 = Knit.GetController("ToolController")
end

return controller