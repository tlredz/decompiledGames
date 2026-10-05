local createVector = vector.create
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
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "Mokou4Controller"
})

function controller.KnitStart(_)
	local v5 = {
		Startup = function(instance, object)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }

			for _, child in workspace.Characters:GetChildren() do
				if child ~= localPlayer.Character then
					table.insert(raycastParams.FilterDescendantsInstances, child)
				end
			end

			v2:PlaySound(sounds.Misc.M.Charm, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Misc.M.Mokou4Voice, humanoidRootPart, game.SoundService.Voice)

			repeat
				local target = v4:GetTarget(100)

				if target then
					object:FireServer(target)
				else
					local mouseLocation = UserInputService:GetMouseLocation()
					local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(
						mouseLocation.X,
						mouseLocation.Y
					)
					local raycastResult = workspace:Raycast(
						viewportPointToRay.Origin,
						viewportPointToRay.Direction * 300,
						raycastParams
					)
					local v6

					if raycastResult then
						v6 = raycastResult.Position
					else
						v6 = viewportPointToRay.Origin + viewportPointToRay.Direction * 300
					end

					object:FireServer(v6)
				end

				task.wait(0.02)
			until not object.Parent
		end,
		Barrage = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Misc.M.Barrage:Clone()
			clone.Weld.Part1 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
			v2:ArmFlash(instance["Left Arm"], Color3.fromRGB(255, 85, 0), 0.5)
			v2:ArmFlash(instance["Right Arm"], Color3.fromRGB(255, 85, 0), 0.5)
			task.wait(0.35)
			clone.Ring.Enabled = false
			clone.Slash2.Enabled = false
			clone.Attachment.Ring:Emit(8)
			clone.Attachment.Dust:Emit(40)
			clone.Attachment.Attachment.Ring:Emit(1)
		end,
		Interp = function(p, p2)
			local clone = utils.Misc.M.Talisman:Clone()
			clone.CFrame = p2 * CFrame.Angles(0, 0, math.random(0, 3.141592653589793))
			clone.Parent = workspace.Effects
			local lastTime = tick()
			local v6 = false
			local flag = false
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if p.Parent and v6 ~= true and not (tick() - lastTime > 0.4) then
					local v7 = 200 * dt
					local raycastResult = workspace:Raycast(clone.Position, clone.CFrame.LookVector * v7, _G.MapParams)

					if raycastResult then
						flag = true
						clone.Position = raycastResult.Position
						v6 = true
					else
						clone.CFrame += clone.CFrame.LookVector * v7
					end
				else
					if flag then
						local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
						TweenService:Create(clone, tweenInfo, {
							Size = createVector(0, 0, 0)
						}):Play()
						TweenService:Create(clone.Flames, tweenInfo, {
							Rate = 0
						}):Play()
						Debris:AddItem(clone, 1.5)
					else
						clone:Destroy()
					end

					steppedConnection:Disconnect()
				end
			end)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(
				sounds.Misc.M.M1:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart,
				game.SoundService.Effect
			)
			local clone = utils.Misc.M.Hit:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(
				math.random(-30, 30) / 10,
				math.random(-30, 30) / 10,
				math.random(-30, 30) / 10
			)
			clone.Parent = workspace.Effects
			clone.Sparks:Emit(20)
			TweenService:Create(clone, TweenInfo.new(0.15), {
				Size = createVector(7, 7, 7),
				Transparency = 1,
				Color = Color3.new(1, 0.333333, 0)
			}):Play()
			Debris:AddItem(clone, 0.6)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("Mokou4Service")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("HitboxController")
	v4 = Knit.GetController("ToolController")
end

return controller