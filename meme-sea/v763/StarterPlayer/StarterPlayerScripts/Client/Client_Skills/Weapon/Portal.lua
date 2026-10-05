local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local _ = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local skills = workspace:WaitForChild("Skills")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
return {
	Z = {
		Release = function(enemy: string, sound: string, _: string, data)
			local releaser_Id = data.Releaser_Id
			local portal_Duration = data.Portal_Duration
			local duration = data.Duration
			local new_Location = data.New_Location
			local target_RootPart = data.Target_RootPart

			if data.Type == "Open" then
				local rootPart_CFrame = data.RootPart_CFrame
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = rootPart_CFrame * CFrame.new(0, 13, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration)

				if Generate.CheckExist(target_RootPart) then
					PlaySound.PlaySound_Character(target_RootPart.Parent, {
						Folder = "Weapon_Sound",
						Enemy = enemy,
						Sound = sound
					})
					target_RootPart.CFrame = new_Location * CFrame.new(0, 3, -5)
				end

				task.wait(duration - 1)
				local portal = Generate.CheckExist(clone) and clone:FindFirstChild("Portal")

				if portal then
					for _, part in ipairs(portal:GetChildren()) do
						if not part:IsA("BasePart") then
							continue
						end

						TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()

						for _, child in ipairs(part:GetChildren()) do
							if child:IsA("Decal") or child:IsA("Texture") then
								TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
									Transparency = 1
								}):Play()
							end
						end
					end
				end
			else
				local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}`))

				if child and child:GetAttribute("Active") then
					child:SetAttribute("Last_Teleport", tick())

					if Generate.CheckExist(target_RootPart) then
						PlaySound.PlaySound_Character(target_RootPart.Parent, {
							Folder = "Weapon_Sound",
							Enemy = enemy,
							Sound = sound
						})
						target_RootPart.CFrame = new_Location * CFrame.new(0, 3, -10)
					end
				else
					local clone = skillFolder[enemy][sound]:Clone()
					clone.Name = `{releaser_Id}_{enemy}_{sound}`
					clone.CanCollide = false
					clone.Anchored = true
					clone.CFrame = new_Location * CFrame.new(0, 13, 0)
					clone.Parent = skills
					clone:SetAttribute("Active", true)
					clone:SetAttribute("Last_Teleport", tick())
					Debris:AddItem(clone, duration)

					if Generate.CheckExist(target_RootPart) then
						PlaySound.PlaySound_Character(target_RootPart.Parent, {
							Folder = "Weapon_Sound",
							Enemy = enemy,
							Sound = sound
						})
						target_RootPart.CFrame = new_Location * CFrame.new(0, 3, -10)
					end

					local lastTime = tick()

					while Generate.CheckExist(clone) and tick() - clone:GetAttribute("Last_Teleport") < portal_Duration and tick() - lastTime < duration do
						task.wait(0.1)
					end

					if Generate.CheckExist(clone) then
						clone:SetAttribute("Active", nil)
						local portal = clone:FindFirstChild("Portal")

						if portal then
							for _, part in ipairs(portal:GetChildren()) do
								if not part:IsA("BasePart") then
									continue
								end

								TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
									Transparency = 1
								}):Play()

								for _, child2 in ipairs(part:GetChildren()) do
									if child2:IsA("Decal") or child2:IsA("Texture") then
										TweenService:Create(child2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
											Transparency = 1
										}):Play()
									end
								end
							end
						end

						task.wait(1)

						if Generate.CheckExist(clone) then
							clone:Destroy()
						end
					end
				end
			end
		end
	}
}