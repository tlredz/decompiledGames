local _ = game.Players.LocalPlayer
local explorerPanel = script.Parent.Parent.Parent.Parent:WaitForChild("ExplorerPanel")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rigEditScriptFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("RigEditScriptFolder")
local flag = true
local humanoidRootPart = nil

for _, child in pairs(script.Parent:GetChildren()) do
	if child.Name:sub(-19) ~= "CheckboxImageButton" then
		continue
	end

	local v = child
	child.Activated:Connect(function()
		if flag then
			flag = false
			local v2 = explorerPanel.GetSelection:Invoke()[1]

			if v2 then
				local humanoid = v2:FindFirstChild("Humanoid") or v2.Parent and (v2.Parent:FindFirstChild("Humanoid") or v2.Parent.Parent and (v2.Parent.Parent:FindFirstChild("Humanoid") or v2.Parent.Parent.Parent and v2.Parent.Parent.Parent:FindFirstChild("Humanoid")))

				if humanoid then
					if v.Image:sub(-8) == "48138491" then
						v.Image = "rbxassetid://48138474"

						if humanoid.Parent:FindFirstChild(v.Name:sub(1, -20)) then
							humanoid.Parent:FindFirstChild(v.Name:sub(1, -20)):Destroy()
						end

						if v.Name:sub(1, -20) == "zNPC" then
							humanoidRootPart = humanoid.Parent:WaitForChild("HumanoidRootPart", 2)

							if humanoidRootPart and humanoidRootPart:FindFirstChild("AlignOrientation") then
								humanoidRootPart.AlignOrientation:Destroy()
							end
						end
					else
						v.Image = "rbxassetid://48138491"
						local clone = rigEditScriptFolder:WaitForChild(v.Name:sub(1, -20)):Clone()
						clone.Parent = humanoid.Parent
						clone.Enabled = true

						if v.Name:sub(-26, -20) == "Script" then
							if not humanoid.Parent:FindFirstChild("AnimateScript") then
								local clone_2 = rigEditScriptFolder:WaitForChild("AnimateScript"):Clone()
								clone_2.Parent = humanoid.Parent
							end

							if not humanoid.Parent:FindFirstChild("HealthScript") then
								local clone_3 = rigEditScriptFolder:WaitForChild("HealthScript"):Clone()
								clone_3.Parent = humanoid.Parent
							end

							if not humanoid.Parent:FindFirstChild("RbxNpcSoundsScript") then
								local clone_4 = rigEditScriptFolder:WaitForChild("RbxNpcSoundsScript"):Clone()
								clone_4.Parent = humanoid.Parent
							end
						elseif v.Name:sub(1, -20) == "zNPC" then
							if not humanoid.Parent:FindFirstChild("AnimateScript") then
								local clone_5 = rigEditScriptFolder:WaitForChild("AnimateScript"):Clone()
								clone_5.Parent = humanoid.Parent
							end

							if not humanoid.Parent:FindFirstChild("HealthScript") then
								local clone_6 = rigEditScriptFolder:WaitForChild("HealthScript"):Clone()
								clone_6.Parent = humanoid.Parent
							end

							if not humanoid.Parent:FindFirstChild("RbxNpcSoundsScript") then
								local clone_7 = rigEditScriptFolder:WaitForChild("RbxNpcSoundsScript"):Clone()
								clone_7.Parent = humanoid.Parent
							end

							if not humanoid.Parent:FindFirstChild("Animations") then
								local clone_8 = rigEditScriptFolder:WaitForChild("Animations"):Clone()
								clone_8.Parent = humanoid.Parent
							end

							if not humanoid.Parent:FindFirstChild("Configuration") then
								local clone_9 = rigEditScriptFolder:WaitForChild("Configuration"):Clone()
								clone_9.Parent = humanoid.Parent
							end

							humanoidRootPart = humanoid.Parent:WaitForChild("HumanoidRootPart", 2)

							if humanoidRootPart then
								humanoidRootPart:SetAttribute("SL_Anchored", false)

								if not humanoidRootPart:FindFirstChild("AlignOrientation") then
									local alignOrientation = Instance.new("AlignOrientation")
									alignOrientation.Parent = humanoidRootPart
								end
							end
						end
					end
				else
					warn("(scripts) Select a rig, or build one.")
				end
			else
				warn("(scripts) Select a rig, or build one.")
			end

			task.wait(0.5)
			flag = true
		end
	end)
end