local createVector = vector.create
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local assets = ReplicatedStorage:WaitForChild("Assets")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skills = assets:WaitForChild("Skills")
local skills2 = workspace:WaitForChild("Skills")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
require(moduleScript:WaitForChild("Generate"))
local v = {
	"rbxassetid://7596459141",
	"rbxassetid://7596439980",
	"rbxassetid://7596441418",
	"rbxassetid://8574453387",
	"rbxassetid://7596477697",
	"rbxassetid://7596520279",
	"rbxassetid://7596536228",
	"rbxassetid://7604541151",
	"rbxassetid://7604546665",
	"rbxassetid://7604556372",
	"rbxassetid://7604566245",
	"rbxassetid://7604591195",
	"rbxassetid://7604597871",
	"rbxassetid://7604611676",
	"rbxassetid://7604683032",
	"rbxassetid://7604697467",
	"rbxassetid://7604718179",
	"rbxassetid://7604737729",
	"rbxassetid://7604724901",
	"rbxassetid://7604835358",
	"rbxassetid://7604806606",
	"rbxassetid://7604846482",
	"rbxassetid://7604902004",
	"rbxassetid://7604918864",
	"rbxassetid://7604926863",
	"rbxassetid://7604954258",
	"rbxassetid://7604948766",
	"rbxassetid://7605031118",
	"rbxassetid://7605044918"
}
return {
	Z = function(p, p2: string, data)
		local duration = data.Duration or 1
		local fall_Time = data.Fall_Time
		local _ = data.RootPart_CFrame
		local rootPart_Position = data.RootPart_Position
		local targetRootPart_Position = data.TargetRootPart_Position

		if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
			local clone = skills[p.Name][p2]:Clone()
			clone.CanCollide = false
			clone.Anchored = true
			clone.CFrame = CFrame.new(
				rootPart_Position,
				(Vector3.new(
					targetRootPart_Position.Position.X,
					rootPart_Position.Y,
					targetRootPart_Position.Position.Z
				))
			) * CFrame.new(0, 2, 0)
			clone.Parent = skills2
			Debris:AddItem(clone, duration + 2)

			for _, decal in ipairs(clone:GetChildren()) do
				if decal:IsA("Decal") then
					TweenService:Create(
						decal,
						TweenInfo.new(fall_Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
				end
			end

			local wave = clone:FindFirstChild("Wave")
			local lastTime = tick()
			task.spawn(function()
				while clone and clone.Parent and tick() - lastTime <= 2.5 do
					if not (clone and clone.Parent) then
						continue
					end

					for _, texture in ipairs(v) do
						for _, decal in ipairs(clone:GetChildren()) do
							if decal:IsA("Decal") then
								decal.Texture = texture
							end
						end

						task.wait(0.06)
					end
				end
			end)
			task.wait(fall_Time)

			if wave then
				task.spawn(function()
					while clone and clone.Parent and tick() - lastTime <= 2.5 do
						local clone2 = wave:Clone()
						clone2.Transparency = 0.1
						clone2.CFrame = clone.CFrame * CFrame.new(0, -2, 0)
						clone2.Anchored = true
						clone2.Parent = clone
						Debris:AddItem(clone2, 1)
						TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
							Size = createVector(175, 10, 175),
							Transparency = 1
						}):Play()
						task.wait(0.25)
					end
				end)
			end

			PlaySound.PlaySound_Character(clone, {
				Folder = "Enemy",
				Enemy = p.Name,
				Sound = `{p2}`
			})
			task.wait(2)

			if clone and clone.Parent then
				for _, decal in ipairs(clone:GetChildren()) do
					if decal:IsA("Decal") then
						TweenService:Create(
							decal,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end
				end

				PlaySound.FadingSound_Out(clone, 1, p2)
			end
		end
	end
}