local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(player)
	local stage = player.Stage

	if stage == 1 then
		local character = player.Character or nil
		local _ = player.HoldValue or nil
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
				return
			end

			Util.Sound:Play("DodgeQuick2", humanoidRootPart.Position, nil, 1 + math.random(-20, 20) / 100, 1)
			local lastTime = tick()

			while tick() - lastTime < 0.4 do
				local clone = script.ThinRing:Clone()
				clone.Size *= 0.5
				clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone.Parent = workspace._WorldOrigin
				local tween = TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {
					Size = createVector(21, 0.5, 21),
					Transparency = 1
				})
				tween.Completed:Connect(function()
					clone:Destroy()
				end)
				tween:Play()

				for _ = 1, 2 do
					local color = math.random() > 0.5 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
					local v2 = 15 + math.random() * 10
					local part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.CFrame = humanoidRootPart.CFrame * CFrame.new(math.random(-4, 4), math.random(-4, 4), 0)
					part.Size = createVector(1, 1, 1)
					part.Color = color
					part.Transparency = 0
					part.Material = "Neon"
					local specialMesh = Instance.new("SpecialMesh")
					specialMesh.MeshType = "Sphere"
					specialMesh.Scale = createVector(0.04, 0.04, 1) * v2
					specialMesh.Parent = part
					part.Parent = _WorldOrigin
					local tween2 = TweenService:Create(specialMesh, TweenInfo.new(0.15 + math.random() * 0.1), {
						Scale = Vector3.new(),
						Offset = Vector3.new(0, 0, math.random(20, 30))
					})
					tween2.Completed:Connect(function()
						part:Destroy()
					end)
					tween2:Play()
				end

				wait()
			end
		end
	elseif stage == 3 then
		local attackerChar = player.AttackerChar
		local attackerHum = player.AttackerHum
		local victimChar = player.VictimChar
		local victimHum = player.VictimHum
		local grabExists = player.GrabExists
		local rightFoot = attackerChar:FindFirstChild("RightFoot")
		local humanoidRootPart = attackerChar:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart2 = victimChar:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 and grabExists then
			local play = Util.Sound:Play("BuddhaGrab", humanoidRootPart2.Position, nil, 2, 1)
			play.TimePosition = 0.2
			local attachment = Instance.new("Attachment", humanoidRootPart)
			local clone = script.Ring:Clone()
			clone.Parent = attachment
			clone:Emit(1)
			tick()

			while RunService.RenderStepped:Wait() and grabExists and grabExists.Parent and humanoidRootPart and humanoidRootPart2 and humanoidRootPart.Parent and humanoidRootPart.Parent and attackerHum and victimHum and not (victimHum.Health <= 0 or attackerHum.Health <= 0) do
				humanoidRootPart2.CFrame = rightFoot.CFrame * CFrame.new(-0.5, 0, 0) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
			end

			wait(1)
			attachment:Destroy()
		end
	elseif stage == 5 then
		local cFrame = player.CFrame

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
			return
		end

		for i = 1, 3 do
			local clone = script.ThinRing:Clone()
			clone.CFrame = cFrame
			clone.Size = createVector(0, 8, 0)
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone, TweenInfo.new(i / 6 + 0.2, Enum.EasingStyle.Exponential), {
				Size = createVector(26, 0, 26) * i,
				CFrame = clone.CFrame + clone.CFrame.UpVector * (i * 15),
				Transparency = 1
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end

		for _ = 1, 11 do
			local color = math.random() > 0.5 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
			local v = 25 + math.random() * 25
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = cFrame * CFrame.Angles(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
			part.Size = createVector(1, 1, 1)
			part.Color = color
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = createVector(0.1, 1, 0.1) * v
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			local tween = TweenService:Create(specialMesh, TweenInfo.new(0.2 + math.random() * 0.2), {
				Scale = Vector3.new(),
				Offset = Vector3.new(0, math.random(15, 60), 0)
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end
	end
end