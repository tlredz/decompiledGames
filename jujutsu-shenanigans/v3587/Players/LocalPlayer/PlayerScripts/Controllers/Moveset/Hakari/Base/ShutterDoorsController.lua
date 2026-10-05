local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
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
local controller = Knit.CreateController({
	Name = "ShutterDoorController"
})

function controller.KnitStart(_)
	local v3 = {
		Spawn = function(data, color, value)
			local v4 = value or 1
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0
			highlight.FillColor = Color3.new(2, 2, 2)
			highlight.OutlineColor = Color3.new(2, 2, 2)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = data.Doors

			if color then
				data.Doors.Door1.Color = color
				data.Doors.Door2.Color = color
				data.Doors.Door1.Stars.Color = ColorSequence.new(color)
				data.Doors.Door2.Stars.Color = ColorSequence.new(color)
			end

			data.Weld1.C1 = CFrame.new(0, 0, 4) * CFrame.Angles(1.4835298641951802, -1.5707963267948966, 0)
			data.Weld2.C1 = CFrame.new(0, 0, 4) * CFrame.Angles(
				1.4835298641951802,
				-1.5707963267948966,
				3.141592653589793
			)
			TweenService:Create(data.Weld1, TweenInfo.new(0.6 * v4, Enum.EasingStyle.Back), {
				C1 = CFrame.new(0, 0, 7) * CFrame.Angles(0, -1.5707963267948966, 0)
			}):Play()
			TweenService:Create(data.Weld2, TweenInfo.new(0.6 * v4, Enum.EasingStyle.Back), {
				C1 = CFrame.new(0, 0, 7) * CFrame.Angles(0, -1.5707963267948966, 3.141592653589793)
			}):Play()
			TweenService:Create(highlight, TweenInfo.new(0.4 * v4), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
			v2:PlaySound(sounds.Hakari.ShutterDoors.Spawn, data, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.ShutterDoors.Swing, data, game.SoundService.Effect)
			Debris:AddItem(highlight, 0.4 * v4)
			task.wait(0.2 * v4)
			data.Doors.Door1.Stars.Enabled = false
			data.Doors.Door2.Stars.Enabled = false
		end,
		Close = function(p, p2)
			v2:PlaySound(sounds.Hakari.ShutterDoors.Slam, p, game.SoundService.Effect)

			if p2 then
				TweenService:Create(p.Weld1, TweenInfo.new(0.1), {
					C1 = CFrame.new(0, 0, 3.4) * CFrame.Angles(0, -1.5707963267948966, 0)
				}):Play()
				TweenService:Create(p.Weld2, TweenInfo.new(0.1), {
					C1 = CFrame.new(0, 0, 3.4) * CFrame.Angles(0, -1.5707963267948966, 3.141592653589793)
				}):Play()
				task.wait(0.1)
				TweenService:Create(p.Weld1, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					C1 = CFrame.new(0, 0, 8) * CFrame.Angles(0, -1.5707963267948966, 0)
				}):Play()
				TweenService:Create(p.Weld2, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					C1 = CFrame.new(0, 0, 8) * CFrame.Angles(0, -1.5707963267948966, 3.141592653589793)
				}):Play()
			else
				TweenService:Create(p.Weld1, TweenInfo.new(0.1), {
					C1 = CFrame.new(0, 0, 2.4) * CFrame.Angles(0, -1.5707963267948966, 0)
				}):Play()
				TweenService:Create(p.Weld2, TweenInfo.new(0.1), {
					C1 = CFrame.new(0, 0, 2.4) * CFrame.Angles(0, -1.5707963267948966, 3.141592653589793)
				}):Play()

				if p2 == true then
					task.wait(0.1)
					TweenService:Create(
						p.Weld1,
						TweenInfo.new(0.9, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
						{
							C1 = CFrame.new(0, 0, 7) * CFrame.Angles(0, -1.5707963267948966, 0)
						}
					):Play()
					TweenService:Create(
						p.Weld2,
						TweenInfo.new(0.9, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
						{
							C1 = CFrame.new(0, 0, 7) * CFrame.Angles(0, -1.5707963267948966, 3.141592653589793)
						}
					):Play()
				end
			end
		end,
		Fade = function(p)
			for _, descendant in p.Doors:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Texture") then
					TweenService:Create(descendant, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end
			end
		end,
		Bound = function(instance)
			local CF = instance:GetAttribute("CF")

			if not CF then
				instance:SetAttribute("CF", instance.CFrame)
				CF = instance.CFrame
			end

			instance.CFrame += createVector(0, 3, 0)
			TweenService:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = CF
			}):Play()
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, instance, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.ShutterDoors.Slam, instance, game.SoundService.Effect)
		end,
		Break = function(parent)
			local clone = parent.Doors:Clone()
			clone.Door1.Color = parent.Doors.Door1.Color
			clone.Door2.Color = parent.Doors.Door2.Color
			clone.Parent = parent
			parent.Doors:Destroy()
			v2:PlaySound(sounds.Hakari.Counter.Swing, parent, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.Counter.Slam, parent, game.SoundService.Effect)
			clone.Door1.CanCollide = true
			clone.Door2.CanCollide = true
			clone.Door1.Velocity = createVector(0, -100, 0)
			clone.Door1.RotVelocity = -parent.CFrame.LookVector * 80
			clone.Door2.Velocity = createVector(0, -100, 0)
			clone.Door2.RotVelocity = parent.CFrame.LookVector * 80

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Texture") then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
				end
			end

			local clone2 = utils.Locust.Slam:Clone()
			clone2.Position = parent.Position
			clone2.Parent = workspace.Effects

			for _, child in clone2.Attachment:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			Debris:AddItem(clone2, 0.5)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
		end,
		Finisher = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
			v2:Bleed(instance)
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
	v = Knit.GetService("ShutterDoorService")
	v2 = Knit.GetController("FXController")
end

return controller