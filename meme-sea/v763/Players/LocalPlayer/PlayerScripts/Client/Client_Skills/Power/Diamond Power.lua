local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("Debris")
local _ = Players.LocalPlayer
local _ = RunService.Heartbeat
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("Modules")
ReplicatedStorage:WaitForChild("OtherEvent")
ReplicatedStorage:WaitForChild("SkillFolder")
workspace:WaitForChild("Skills")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local _ = {
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
return {
	Z = {
		Release = function(enemy: string, sound: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local type = p3.Type

			if Generate.CheckIfAlive(skill_Releaser) then
				if type == "Transform" and skill_Releaser:GetAttribute("Transform") then
					PlaySound.PlaySound_Character(skill_Releaser, {
						Folder = "Power_Sound",
						Enemy = enemy,
						Sound = sound
					})

					for _, child in ipairs(skill_Releaser:GetChildren()) do
						if child:IsA("MeshPart") and child.Transparency < 1 then
							child:SetAttribute("Old_Texture", child.TextureID)
							child.TextureID = "rbxassetid://18231265025"
						elseif child:IsA("Shirt") then
							if child.ShirtTemplate ~= "" then
								child:SetAttribute("Old_ShirtTemplate", child.ShirtTemplate)
								child.ShirtTemplate = "http://www.roblox.com/asset/?id=0"
							end
						elseif child:IsA("Pants") then
							if child.PantsTemplate ~= "" then
								child:SetAttribute("Old_PantsTemplate", child.PantsTemplate)
								child.PantsTemplate = "http://www.roblox.com/asset/?id=0"
							end
						elseif child:IsA("ShirtGraphic") then
							if child.Graphic ~= "" then
								child:SetAttribute("Old_TShirtTemplate", child.Graphic)
								child.Graphic = "http://www.roblox.com/asset/?id=0"
							end
						elseif child:IsA("Accessory") then
							local handle = child:FindFirstChild("Handle")

							if handle then
								if handle.Transparency < 1 then
									if not handle.Massless then
										handle.Massless = true
									end

									handle:SetAttribute("Old_Color", handle.Color)
									handle:SetAttribute("Old_Material", handle.Material)

									if handle:IsA("MeshPart") then
										handle:SetAttribute("Old_Texture", handle.TextureID)
										handle.TextureID = "rbxassetid://18231265025"
									end

									handle.Material = Enum.Material.Plastic
									TweenService:Create(
										handle,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Color = Color3.fromRGB(61, 252, 255)
										}
									):Play()
								end

								for _, descendant in pairs(handle:GetDescendants()) do
									if (descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) and descendant.Transparency < 1 then
										if not descendant.Massless then
											descendant.Massless = true
										end

										descendant:SetAttribute("Old_Color", descendant.Color)
										descendant:SetAttribute("Old_Material", descendant.Material)

										if descendant:IsA("MeshPart") then
											descendant:SetAttribute("Old_Texture", descendant.TextureID)
											descendant.TextureID = "rbxassetid://18231265025"
										end

										descendant.Material = Enum.Material.Plastic
										TweenService:Create(
											descendant,
											TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Color = Color3.fromRGB(61, 252, 255)
											}
										):Play()
									elseif descendant:IsA("Decal") and descendant.Transparency < 1 then
										if descendant.Texture ~= "" then
											descendant:SetAttribute("Old_Color", descendant.Color3)
											descendant:SetAttribute("Old_Texture", descendant.Texture)
											TweenService:Create(
												descendant,
												TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
												{
													Color3 = Color3.fromRGB(255, 255, 255)
												}
											):Play()
											descendant.Texture = "rbxassetid://18231265025"
										end
									elseif descendant:IsA("SpecialMesh") then
										descendant:SetAttribute("Old_Texture", descendant.TextureId)
										descendant.TextureId = "rbxassetid://18231265025"
									elseif descendant:IsA("SurfaceAppearance") then
										local folder = Instance.new("Folder")
										folder.Name = "SurfaceAppearance_Folder"
										folder.Parent = handle

										if descendant.Parent and descendant.Parent == handle then
											descendant:SetAttribute("Old_Parent", descendant.Parent.Name)
											descendant.Parent = folder
										end
									end
								end
							end
						end
					end
				elseif type == "Untransform" and not skill_Releaser:GetAttribute("Transform") then
					for _, child in ipairs(skill_Releaser:GetChildren()) do
						if child:IsA("MeshPart") and child.Transparency < 1 and child:GetAttribute("Old_Texture") then
							child.TextureID = child:GetAttribute("Old_Texture")
							child:SetAttribute("Old_Texture", nil)
						elseif child:IsA("Shirt") then
							if child.ShirtTemplate ~= "" and child:GetAttribute("Old_ShirtTemplate") then
								child.ShirtTemplate = child:GetAttribute("Old_ShirtTemplate")
								child:SetAttribute("Old_ShirtTemplate", nil)
							end
						elseif child:IsA("Pants") then
							if child.PantsTemplate ~= "" and child:GetAttribute("Old_PantsTemplate") then
								child.PantsTemplate = child:GetAttribute("Old_PantsTemplate")
								child:SetAttribute("Old_PantsTemplate", nil)
							end
						elseif child:IsA("ShirtGraphic") and child:GetAttribute("Old_TShirtTemplate") then
							if child.Graphic ~= "" then
								child.Graphic = child:GetAttribute("Old_TShirtTemplate")
								child:SetAttribute("Old_TShirtTemplate", nil)
							end
						elseif child:IsA("Accessory") then
							local handle = child:FindFirstChild("Handle")

							if handle then
								if handle.Transparency < 1 then
									if handle:IsA("MeshPart") and handle:GetAttribute("Old_Texture") then
										handle.TextureID = handle:GetAttribute("Old_Texture")
										handle:SetAttribute("Old_Texture", nil)
									end

									if handle:GetAttribute("Old_Material") then
										handle.Material = handle:GetAttribute("Old_Material")
										handle:SetAttribute("Old_Material", nil)
									end

									if handle:GetAttribute("Old_Color") then
										TweenService:Create(
											handle,
											TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Color = handle:GetAttribute("Old_Color")
											}
										):Play()
										handle:SetAttribute("Old_Color", nil)
									end
								end

								for _, descendant in pairs(handle:GetDescendants()) do
									if (descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) and descendant.Transparency < 1 then
										if descendant:IsA("MeshPart") and descendant:GetAttribute("Old_Texture") then
											descendant.TextureID = descendant:GetAttribute("Old_Texture")
											descendant:SetAttribute("Old_Texture", nil)
										end

										if descendant:GetAttribute("Old_Material") then
											descendant.Material = descendant:GetAttribute("Old_Material")
											descendant:SetAttribute("Old_Material", nil)
										end

										if descendant:GetAttribute("Old_Color") then
											TweenService:Create(
												descendant,
												TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
												{
													Color = descendant:GetAttribute("Old_Color")
												}
											):Play()
											descendant:SetAttribute("Old_Color", nil)
										end
									elseif descendant:IsA("Decal") and descendant.Transparency < 1 then
										if descendant.Texture ~= "" then
											if descendant:GetAttribute("Old_Color") then
												TweenService:Create(
													descendant,
													TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
													{
														Color3 = descendant:GetAttribute("Old_Color")
													}
												):Play()
												descendant:SetAttribute("Old_Color", nil)
											end

											if descendant:GetAttribute("Old_Texture") then
												descendant.Texture = descendant:GetAttribute("Old_Texture")
												descendant:SetAttribute("Old_Texture", nil)
											end
										end
									elseif descendant:IsA("SpecialMesh") then
										if descendant:GetAttribute("Old_Texture") then
											descendant.TextureId = descendant:GetAttribute("Old_Texture")
											descendant:SetAttribute("Old_Texture", nil)
										end
									elseif descendant:IsA("SurfaceAppearance") then
										local surfaceAppearance_Folder = handle:FindFirstChild("SurfaceAppearance_Folder")

										if descendant.Parent and surfaceAppearance_Folder and descendant:GetAttribute("Old_Parent") and descendant.Parent == surfaceAppearance_Folder then
											descendant.Parent = handle
											descendant:SetAttribute("Old_Parent", nil)
											surfaceAppearance_Folder:Destroy()
										end
									end
								end
							end
						end
					end
				end
			end
		end
	}
}