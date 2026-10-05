local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local death_Effect = ReplicatedStorage:WaitForChild("VisualFX"):WaitForChild("Death_Effect")
local skills = workspace:WaitForChild("Skills")
require(moduleScript:WaitForChild("Generate"))
local v = { "Head", "LowerTorso" }

local function CheckIfAlive(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent then
		return true
	end

	return false
end

miscEvents:WaitForChild("Died").OnClientEvent:Connect(function(instance)
	if instance and (instance.HumanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 400 then
		local v2 = Players:GetPlayerFromCharacter(instance) and true or nil
		instance.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		if v2 then
			if (instance.HumanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 250 then
				instance.HumanoidRootPart.Anchored = true

				for _, child in ipairs(instance:GetChildren()) do
					if child:IsA("Accessory") and child:FindFirstChild("Handle") then
						child.Handle.Anchored = true
						child.Handle.CFrame *= CFrame.Angles(
							math.rad((math.random(-360, 360))),
							math.rad((math.random(-360, 360))),
							(math.rad((math.random(-360, 360))))
						)
						local handle2 = child:FindFirstChild("Handle")

						if handle2:IsA("BasePart") then
							handle2:ClearAllChildren()

							for _, descendant in ipairs(handle2:GetDescendants()) do
								if not (descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("Decal")) then
									continue
								end

								TweenService:Create(
									descendant,
									TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end
						end

						TweenService:Create(
							child.Handle,
							TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = child.Handle.CFrame * CFrame.new(0, 0, 5) * CFrame.Angles(
									math.rad((math.random(-360, 360))),
									math.rad((math.random(-360, 360))),
									(math.rad((math.random(-360, 360))))
								),
								Transparency = 1
							}
						):Play()
					elseif child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
						child.Anchored = true
						child.CFrame *= CFrame.Angles(
							math.rad((math.random(-360, 360))),
							math.rad((math.random(-360, 360))),
							(math.rad((math.random(-360, 360))))
						)
						child:ClearAllChildren()
						TweenService:Create(
							child,
							TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = child.CFrame * CFrame.new(0, 0, 5) * CFrame.Angles(
									math.rad((math.random(-360, 360))),
									math.rad((math.random(-360, 360))),
									(math.rad((math.random(-360, 360))))
								),
								Transparency = 1
							}
						):Play()
					end
				end
			end
		else
			instance.HumanoidRootPart.Anchored = true
			instance.HumanoidRootPart:ClearAllChildren()

			for _, child in ipairs(instance:GetChildren()) do
				if child:IsA("Accessory") then
					local handle = child:FindFirstChild("Handle")

					if handle then
						handle.Transparency = 1
					end
				elseif child:IsA("Model") then
					child:Destroy()
				elseif child:IsA("BasePart") and child.Transparency < 1 then
					child.Transparency = 1

					for _, child2 in ipairs(child:GetChildren()) do
						if not (child2:IsA("Decal") or child2:IsA("Texture") and child2.Transparency < 1) then
							continue
						end

						child2.Transparency = 1
					end

					if table.find(v, child.Name) then
						local clone = death_Effect:Clone()
						clone.CFrame = CFrame.new(child.Position)
						clone.Anchored = true
						clone.Parent = skills
						Debris:AddItem(clone, 2)
						local death_Particle = clone:FindFirstChild("Death_Particle")

						if death_Particle then
							death_Particle:Emit(1)
						end
					end
				end
			end
		end
	end
end)