local createVector = vector.create
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local assets = ReplicatedStorage:WaitForChild("Assets")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skills = assets:WaitForChild("Skills")
local skills2 = workspace:WaitForChild("Skills")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
return {
	Z = function(p, p2: string, data)
		local duration = data.Duration or 1
		local fall_Time = data.Fall_Time
		local _ = data.RootPart_CFrame
		local rootPart_Position = data.RootPart_Position
		local _ = data.TargetRootPart_Position
		local selected_CFrame = data.Selected_CFrame

		if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
			local v = {
				20,
				28,
				4,
				1
			}
			local v2 = {
				Amount = 5,
				Size = createVector(2.5, 2.5, 2.5),
				Velocity = {
					X = {
						Min = -75,
						Max = 75
					},
					Y = {
						Min = 75,
						Max = 75
					},
					Z = {
						Min = -75,
						Max = 75
					}
				}
			}
			local clone = skills[p.Name][p2]:Clone()
			clone.CanCollide = false
			clone.Anchored = true
			clone.CFrame = selected_CFrame * CFrame.new(0, 500, 0)
			clone.Parent = skills2
			Debris:AddItem(clone, duration + fall_Time)
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(fall_Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.new(0, 504, 0):Inverse()
				}
			)
			tween:Play()
			tween.Completed:Wait()
			Generate.Generate_FlyingRock(clone.Position, v2.Amount, v2.Size, v2.Velocity)
			local clone2 = skills[p.Name][`{p2}_Explosion`]:Clone()
			clone2:PivotTo(clone.CFrame)
			clone2.Parent = skills2
			Debris:AddItem(clone2, duration)

			if clone then
				clone:Destroy()
			end

			PlaySound.PlaySound_Character(clone2, {
				Folder = "Enemy",
				Enemy = p.Name,
				Sound = `{p2}_Explosion`
			})
			local now = os.clock()
			local heartbeatConnection = nil
			local ball = clone2:FindFirstChild("Ball")

			if v then
				Generate.Generate_Ground(clone2.PrimaryPart, v[1], v[2], v[3], v[4])
			end

			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				local now2 = os.clock()

				if now + duration <= now2 or not Generate.CheckExist(ball) then
					if heartbeatConnection then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end
				elseif ball and ball.Parent then
					ball.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1 * (1 + dt), 0)
				end
			end)
			local ball2 = clone2:FindFirstChild("Ball")

			if ball2 then
				local specialMesh = ball2:FindFirstChild("SpecialMesh")
				TweenService:Create(ball2, TweenInfo.new(1, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()

				if specialMesh then
					TweenService:Create(specialMesh, TweenInfo.new(1, Enum.EasingStyle.Quad), {
						Scale = createVector(0.2, 0.2, 0.2)
					}):Play()
				end
			end
		end
	end
}