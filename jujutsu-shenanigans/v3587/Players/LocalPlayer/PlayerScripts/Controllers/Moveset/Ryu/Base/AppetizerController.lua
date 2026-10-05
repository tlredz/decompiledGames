local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "AppetizerController"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance, _)
			if instance:FindFirstChild("HumanoidRootPart") then
			end
		end,
		Fire = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.GraniteBlast.Fire, humanoidRootPart, game.SoundService.Effect)
		end,
		Fire2 = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Ryu.GraniteBeam:Clone()
			clone.Size = createVector(12, 12, 60)
			clone.Anchored = false
			clone.Massless = true
			clone.Parent = workspace.Effects

			if p then
				v2:PlaySound(sounds.Ryu.GraniteBlast.FireHard, humanoidRootPart, game.SoundService.Effect)
				clone.Color = Color3.new(1, 1, 1)
				clone.Size = createVector(6, 6, 60)
			else
				v2:PlaySound(sounds.Ryu.GraniteBlast.Fire, humanoidRootPart, game.SoundService.Effect)
			end

			local weld = Instance.new("Weld", clone)
			weld.Part0 = instance.Head
			weld.Part1 = clone
			weld.C1 = CFrame.new(0, -1, 31)
			TweenService:Create(clone, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 60)
			}):Play()
			Debris:AddItem(clone, 1)
			task.wait(0.35)
			weld:Destroy()
			clone.Anchored = true
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local clone = utils.Todo.Clap:Clone()
			clone.Color = Color3.fromRGB(128, 187, 219)
			clone.Transparency = 0
			clone.CFrame = instance.CFrame * CFrame.new(0, 0, -1)
			clone.Size = createVector(3, 3, 3)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.4)
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 0)
			}):Play()
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (180 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
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
	v = Knit.GetService("AppetizerService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller