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
local Folders = {
	workspace.Skills,
	workspace.Region,
	workspace.Visuals,
	workspace.Location,
	workspace.Sea,
	workspace.Leaderboard,
	workspace.CameraFolder,
	workspace.SpawningPower,
	workspace.Character,
	workspace.Monster
}
local MaxwellTheCat = {}

function MaxwellTheCat.Z(p, sound: string, data)
	local duration = data.Duration or 1
	local _ = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local targetRootPart_Position = data.TargetRootPart_Position
	local moving_Speed = data.Moving_Speed

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local clone = skills[p.Name][sound]:Clone()
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = CFrame.new(rootPart_Position, targetRootPart_Position)
		clone.Parent = skills2
		Debris:AddItem(clone, duration + 0.5)
		PlaySound.PlaySound_Character(clone, {
			Folder = "Enemy",
			Enemy = p.Name,
			Sound = sound
		})

		if moving_Speed then
			local now = os.clock()
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				local now2 = os.clock()

				if not (now + duration <= now2) and Generate.CheckExist(clone) then
					clone.CFrame += CFrame.new(rootPart_Position, targetRootPart_Position).LookVector * moving_Speed * dt
					return
				end

				if clone then
					clone:Destroy()
				end

				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			end)
		end

		task.spawn(function()
			while clone and clone.Parent and clone:FindFirstChild("Floppa") and clone:FindFirstChild("Floppa").Transparency < 1 do
				local floorPart = clone:FindFirstChild("FloorPart")

				if floorPart then
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(
						floorPart.Position + createVector(0, 3, 0),
						floorPart.CFrame.UpVector * -10,
						raycastParams
					)

					if raycastResult and raycastResult.Instance then
						local clone2 = skills[p.Name][`{sound}_IceFloor`]:Clone()
						clone2.Position = raycastResult.Position + createVector(0, 1, 0)
						clone2.Parent = skills2
						clone2.Anchored = true
						Debris:AddItem(clone2, 2)
						TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Transparency = 0
						}):Play()
						task.delay(1, function()
							if clone2 and clone2.Parent then
								TweenService:Create(
									clone2,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = createVector(0, 0, 0),
										Transparency = 1
									}
								):Play()
							end
						end)
					else
						local clone2 = skills[p.Name][`{sound}_IceFloor`]:Clone()
						clone2.Position = floorPart.Position + createVector(0, 1, 0)
						clone2.Orientation = Vector3.new(1, math.random(-360, 360), 0)
						clone2.Parent = skills2
						clone2.Anchored = true
						Debris:AddItem(clone2, 2)
						TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Transparency = 0
						}):Play()
						task.delay(1, function()
							if clone2 and clone2.Parent then
								TweenService:Create(
									clone2,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = createVector(0, 0, 0),
										Transparency = 1
									}
								):Play()
							end
						end)
					end
				end

				task.wait(0.05)
			end
		end)
		local floppa = clone:FindFirstChild("Floppa")

		if floppa then
			for _, emitter in ipairs(floppa:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					Generate.SetParticle(emitter)
				end
			end
		end

		task.wait(2.5)
		local floppa2 = Generate.CheckExist(clone) and clone:FindFirstChild("Floppa")

		if floppa2 then
			for _, child in ipairs(floppa2:GetChildren()) do
				if child:IsA("ParticleEmitter") and child.Enabled then
					child.Enabled = false
				elseif child:IsA("BasePart") then
					TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
				elseif child:IsA("Decal") then
					TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
				end
			end

			TweenService:Create(floppa2, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
		end
	end
end

function MaxwellTheCat.X(p, sound: string, data)
	local duration = data.Duration or 1
	local rootPart_CFrame = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local _ = data.TargetRootPart_Position

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local _, v, _ = CFrame.new(rootPart_Position, rootPart_Position + rootPart_CFrame.LookVector):ToOrientation()
		local clone = skills[p.Name][sound]:Clone()
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = CFrame.new(rootPart_Position) * CFrame.new(0, -2, 0) * CFrame.fromOrientation(0, v, 0)
		clone.Parent = skills2
		Debris:AddItem(clone, duration + 1)
		PlaySound.PlaySound_Character(clone, {
			Folder = "Enemy",
			Enemy = p.Name,
			Sound = sound
		})
		local movingObject = clone:FindFirstChild("MovingObject")

		if movingObject then
			TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(225, 1, 225),
				Transparency = 0
			}):Play()
		end

		task.wait(2)
		local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

		if movingObject2 then
			TweenService:Create(movingObject2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(0, 1, 0),
				Transparency = 1
			}):Play()
		end
	end
end

return MaxwellTheCat