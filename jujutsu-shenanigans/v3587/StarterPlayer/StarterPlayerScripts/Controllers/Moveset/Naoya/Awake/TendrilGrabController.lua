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
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "TendrilGrabController"
})

function controller.KnitStart(_)
	local v3 = {
		Preview = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Naoya.TendrilGrab.Start, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Naoya.TendrilGrab.Preview, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.WideSPStrike.HitArea:Clone()
			clone.Afterimages:Destroy()
			clone.groundwaveing:Destroy()
			clone.Overlay.Color3 = Color3.new(255, 0, 0)
			clone.Prog.Overlay.Color3 = Color3.new(255, 0, 0)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(-0, -10, -0), _G.MapParams)

			if raycastResult then
				clone.Position = raycastResult.Position
				clone.Prog.Position = raycastResult.Position
			else
				clone.Position = humanoidRootPart.Position + createVector(0, -3, 0)
				clone.Prog.Position = humanoidRootPart.Position + createVector(0, -3, 0)
			end

			clone.Parent = workspace.Effects
			clone.Size = createVector(50, 0.001, 50)
			TweenService:Create(clone.Overlay, TweenInfo.new(0.25), {
				Transparency = 0.5
			}):Play()
			clone.Prog.Size = createVector(0, 0, 0)
			TweenService:Create(clone.Prog.Overlay, TweenInfo.new(0.25), {
				Transparency = 0.5
			}):Play()
			TweenService:Create(clone.Prog, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				Size = createVector(50, 0.001, 50)
			}):Play()
			Debris:AddItem(clone, 2)
			local lastTime = tick()

			while true do
				task.wait()
				local raycastResult2 = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(-0, -10, -0),
					_G.MapParams
				)

				if raycastResult2 then
					clone.Position = raycastResult2.Position
					clone.Prog.Position = raycastResult2.Position
				else
					clone.Position = humanoidRootPart.Position + createVector(0, -3, 0)
					clone.Prog.Position = humanoidRootPart.Position + createVector(0, -3, 0)
				end

				if not (tick() - lastTime > 0.5) then
					continue
				end

				v2:PlaySound(sounds.Naoya.TendrilGrab.Retrieve, humanoidRootPart, game.SoundService.Effect)
				TweenService:Create(clone.Prog.Overlay, TweenInfo.new(0.25), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone.Overlay, TweenInfo.new(0.25), {
					Transparency = 1
				}):Play()
				break
			end
		end,
		Grab = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Naoya.GrabModel:Clone()
			Debris:AddItem(clone, 6)
			local v4 = p * CFrame.new(0, -4, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
			clone:PivotTo(v4)
			clone.Parent = workspace.Effects
			v2:PlaySound(sounds.Naoya.TendrilGrab.Grab, humanoidRootPart, game.SoundService.Effect)

			for _, child in clone:GetChildren() do
				if not child:FindFirstChild("Weld") then
					continue
				end

				child:SetAttribute("OldSize", child.Size)
				child.Size = createVector(0.1, 0.1, 0.1)
			end

			local lastTime = tick()

			repeat
				task.wait()
				clone:PivotTo(v4:Lerp(p, (math.clamp((tick() - lastTime) / 0.1, 0, 1))))
			until tick() - lastTime >= 0.1

			for _, child in clone:GetChildren() do
				local weld = child:FindFirstChild("Weld")

				if not (weld and instance:FindFirstChild(weld:GetAttribute("AttachPart"))) then
					continue
				end

				child.Anchored = false
				weld.Part0 = instance[weld:GetAttribute("AttachPart")]
				TweenService:Create(child, TweenInfo.new(0.1), {
					Size = child:GetAttribute("OldSize")
				}):Play()
			end

			while true do
				task.wait()

				for _, child in clone:GetChildren() do
					if child.Name ~= "Attach" then
						continue
					end

					local child2 = clone:FindFirstChild(child:GetAttribute("Attach0"), true)
					local child3 = clone:FindFirstChild(child:GetAttribute("Attach"), true)

					if not (child2 and child3) then
						break
					end

					local worldPosition = child2.WorldPosition
					local worldPosition2 = child3.WorldPosition
					local v5 = worldPosition2 - worldPosition
					local magnitude = v5.Magnitude
					local v6 = (worldPosition + worldPosition2) * 0.5
					local vector2 = v5 / magnitude
					child.CFrame = CFrame.fromMatrix(
						v6,
						not (vector2:Cross(createVector(0, 1, 0)).Magnitude > 1e-6) and createVector(1, 0, 0) or vector2:Cross(createVector(
							0,
							1,
							0
						)).Unit or createVector(1, 0, 0),
						vector2
					)
					child.Size = Vector3.new(child.Size.X, magnitude, child.Size.Z)
				end

				if p2.Parent then
					continue
				end

				if _G.Settings.DesPHY then
					if (workspace.CurrentCamera.CFrame.Position - v4.Position).Magnitude > 150 then
						break
					end

					for _, child in clone:GetChildren() do
						for _ = 1, 2 do
							local clone2 = utils.Hiromi.GavelShard:Clone()
							clone2.Color = child.Color
							clone2.Material = child.Material
							clone2.Position = child.Position
							clone2.Size *= math.random(4, 8) / 10
							clone2.Velocity = Vector3.new(
								math.random(-30, 30),
								math.random(10, 30),
								math.random(-30, 30)
							)
							clone2.RotVelocity = Vector3.new(
								math.random(-50, 50),
								math.random(-50, 50),
								math.random(-50, 50)
							)
							clone2.Parent = workspace.Effects
							Debris:AddItem(clone2, 2)
							task.delay(1, function()
								TweenService:Create(clone2, TweenInfo.new(1), {
									Size = createVector(0, 0, 0)
								}):Play()
							end)
						end
					end
				end

				clone:Destroy()
				v2:PlaySound(sounds.Naoya.TendrilGrab.GrabEnd, humanoidRootPart, game.SoundService.Effect)
				break
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
	v = Knit.GetService("TendrilGrabService")
	v2 = Knit.GetController("FXController")
end

return controller