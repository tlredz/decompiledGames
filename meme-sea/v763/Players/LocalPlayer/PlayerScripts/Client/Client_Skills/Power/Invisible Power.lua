local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("Modules")
ReplicatedStorage:WaitForChild("OtherEvent")
ReplicatedStorage:WaitForChild("SkillFolder")
workspace:WaitForChild("Skills")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
return {
	Z = {
		Invisible = function(enemy: string, sound: string, _: string, p3)
			local DISTANCE_THRESHOLD = 1500
			local _ = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser

			if Generate.CheckIfAlive(skill_Releaser) then
				local playerData = localPlayer:FindFirstChild("PlayerData")
				local country = playerData and playerData:FindFirstChild("Country")

				if country then
					if country.Value == "🇹🇭" then
						PlaySound.PlaySound_Character(skill_Releaser, {
							Folder = "Power_Sound",
							Enemy = enemy,
							Sound = `{sound}_TH`
						})
					else
						PlaySound.PlaySound_Character(skill_Releaser, {
							Folder = "Power_Sound",
							Enemy = enemy,
							Sound = sound
						})
					end
				end

				if skill_Releaser:GetAttribute("Using_Aura") then
					local auraColor_Folder = skill_Releaser:FindFirstChild("AuraColor_Folder")

					for _, child in ipairs(auraColor_Folder:GetChildren()) do
						child:SetAttribute("Original_Transparency", child.Transparency)

						if (child.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
							TweenService:Create(
								child,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						else
							child.Transparency = 1
						end
					end
				end

				for _, child in ipairs(skill_Releaser:GetChildren()) do
					if child:IsA("BasePart") or child:IsA("MeshPart") and child.Transparency < 1 then
						child:SetAttribute("Original_Transparency", child.Transparency)

						if (child.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
							TweenService:Create(
								child,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()

							if child.Name == "Head" then
								local face = child:FindFirstChild("face")

								if face and face:IsA("Decal") then
									face:SetAttribute("Original_Transparency", face.Transparency)
									TweenService:Create(
										face,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end
							end
						else
							child.Transparency = 1

							if child.Name == "Head" then
								local face = child:FindFirstChild("face")

								if face and face:IsA("Decal") then
									face:SetAttribute("Original_Transparency", face.Transparency)
									face.Transparency = 1
								end
							end
						end
					elseif child:IsA("Accessory") then
						local handle = child:FindFirstChild("Handle")

						if handle then
							if handle.Transparency < 1 then
								handle:SetAttribute("Original_Transparency", handle.Transparency)

								if (handle.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
									TweenService:Create(
										handle,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								else
									handle.Transparency = 1
								end
							end

							for _, descendant in pairs(handle:GetDescendants()) do
								if descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation") or descendant:IsA("Decal") and descendant.Transparency < 1 then
									descendant:SetAttribute("Original_Transparency", descendant.Transparency)

									if (descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) and (descendant.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
										TweenService:Create(
											descendant,
											TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Transparency = 1
											}
										):Play()
									else
										descendant.Transparency = 1
									end
								elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Fire") or descendant:IsA("Beam") or descendant:IsA("Trail") and descendant.Enabled then
									descendant.Enabled = false
								end
							end
						end
					end
				end
			end
		end,
		Visible = function(enemy: string, p2: string, _: string, p3)
			local DISTANCE_THRESHOLD = 1500
			local _ = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser

			if Generate.CheckIfAlive(skill_Releaser) then
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = `{p2}_Visible`
				})

				for _, child in ipairs(skill_Releaser:GetChildren()) do
					if child:IsA("BasePart") or child:IsA("MeshPart") and child:GetAttribute("Original_Transparency") then
						if (child.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
							TweenService:Create(
								child,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = child:GetAttribute("Original_Transparency")
								}
							):Play()

							if child.Name == "Head" then
								local face = child:FindFirstChild("face")

								if face and face:IsA("Decal") and face:GetAttribute("Original_Transparency") then
									TweenService:Create(
										face,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = face:GetAttribute("Original_Transparency")
										}
									):Play()
									face:SetAttribute("Original_Transparency", nil)
								end
							end
						else
							child.Transparency = child:GetAttribute("Original_Transparency")

							if child.Name == "Head" then
								local face = child:FindFirstChild("face")

								if face and face:IsA("Decal") and face:GetAttribute("Original_Transparency") then
									face.Transparency = face:GetAttribute("Original_Transparency")
									face:SetAttribute("Original_Transparency", nil)
								end
							end
						end

						child:SetAttribute("Original_Transparency", nil)
					elseif child:IsA("Accessory") then
						local handle = child:FindFirstChild("Handle")

						if handle then
							if handle:GetAttribute("Original_Transparency") then
								if (handle.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
									TweenService:Create(
										handle,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = handle:GetAttribute("Original_Transparency")
										}
									):Play()
								else
									handle.Transparency = handle:GetAttribute("Original_Transparency")
								end

								handle:SetAttribute("Original_Transparency", nil)
							end

							for _, descendant in pairs(handle:GetDescendants()) do
								if descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation") or descendant:IsA("Decal") and descendant:GetAttribute("Original_Transparency") then
									if (descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) and (descendant.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
										TweenService:Create(
											descendant,
											TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Transparency = descendant:GetAttribute("Original_Transparency")
											}
										):Play()
									else
										descendant.Transparency = descendant:GetAttribute("Original_Transparency")
									end

									descendant:SetAttribute("Original_Transparency", nil)
								elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Fire") or descendant:IsA("Beam") or descendant:IsA("Trail") and not descendant.Enabled then
									descendant.Enabled = true
								end
							end
						end
					end
				end

				if skill_Releaser:GetAttribute("Using_Aura") then
					local auraColor_Folder = skill_Releaser:FindFirstChild("AuraColor_Folder")

					for _, child in ipairs(auraColor_Folder:GetChildren()) do
						if not child:GetAttribute("Original_Transparency") then
							continue
						end

						if (child.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
							if string.find(child.Name, "_AuraColor") then
								local v = child
								task.delay(0.75, function()
									TweenService:Create(
										v,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = v:GetAttribute("Original_Transparency")
										}
									):Play()
								end)
							else
								local v = child
								task.delay(0.5, function()
									TweenService:Create(
										v,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = v:GetAttribute("Original_Transparency")
										}
									):Play()
								end)
							end
						elseif string.find(child.Name, "_AuraColor") then
							local v = child
							task.delay(0.75, function()
								v.Transparency = v:GetAttribute("Original_Transparency")
							end)
						else
							local v = child
							task.delay(0.5, function()
								v.Transparency = v:GetAttribute("Original_Transparency")
							end)
						end
					end
				end
			end
		end
	}
}