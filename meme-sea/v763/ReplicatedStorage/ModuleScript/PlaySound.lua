local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local PlaySound = {}

function PlaySound.PlaySound(player, instance)
	local character = player.Character

	if character and character.Parent then
		if typeof(instance) == "table" then
			local folder = instance.Folder
			local tool = instance.Tool
			local sound = instance.Sound
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local child = sound_Effect:FindFirstChild(folder)
			local child2 = child and humanoidRootPart and child:FindFirstChild(tool)

			if child2 then
				local child3 = child2:FindFirstChild(sound)

				if child3 and humanoidRootPart then
					local endedConnection = nil
					local clone = child3:Clone()
					clone.Parent = humanoidRootPart
					clone:Play()
					endedConnection = clone.Ended:Connect(function()
						if clone then
							clone:Destroy()
						end

						if endedConnection then
							endedConnection:Disconnect()
							endedConnection = nil
						end
					end)
				end
			end
		elseif character:FindFirstChild("HumanoidRootPart") then
			local endedConnection = nil
			local clone = instance:Clone()
			clone.Parent = character.HumanoidRootPart
			clone:Play()
			endedConnection = clone.Ended:Connect(function()
				clone:Destroy()
				endedConnection:Disconnect()
				endedConnection = nil
			end)
		end
	end
end

function PlaySound.PlaySound_RootPart(parent, instance)
	if parent and parent.Parent then
		local endedConnection = nil
		local clone = instance:Clone()
		clone.Parent = parent
		clone:Play()
		endedConnection = clone.Ended:Connect(function()
			if clone then
				clone:Destroy()
			end

			endedConnection:Disconnect()
			endedConnection = nil
		end)
	end
end

function PlaySound.PlaySound_Character(model, data)
	if model and model.Parent and typeof(data) == "table" then
		local folder = data.Folder
		local enemy = data.Enemy
		local sound = data.Sound

		if model:IsA("Model") then
			local humanoidRootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("MainPart")
			local child = sound_Effect:FindFirstChild(folder)

			if child then
				local child2 = child:FindFirstChild(enemy)
				local child3 = child:FindFirstChild(sound)

				if child2 then
					local child4 = child2:FindFirstChild(sound)

					if child4 and humanoidRootPart then
						local endedConnection = nil
						local clone = child4:Clone()
						clone.Parent = humanoidRootPart
						clone:Play()
						endedConnection = clone.Ended:Connect(function()
							if clone and clone.Parent then
								clone:Destroy()
							end

							if endedConnection then
								endedConnection:Disconnect()
								endedConnection = nil
							end
						end)
					end
				elseif child3 and humanoidRootPart then
					local endedConnection = nil
					local clone = child3:Clone()
					clone.Parent = humanoidRootPart
					clone:Play()
					endedConnection = clone.Ended:Connect(function()
						if clone and clone.Parent then
							clone:Destroy()
						end

						if endedConnection then
							endedConnection:Disconnect()
							endedConnection = nil
						end
					end)
				end
			end
		else
			local child = sound_Effect:FindFirstChild(folder)

			if child then
				local child2 = child:FindFirstChild(enemy)
				local child3 = child2 and child2:FindFirstChild(sound)

				if child3 then
					local endedConnection = nil
					local clone = child3:Clone()
					clone.Parent = model
					clone:Play()
					endedConnection = clone.Ended:Connect(function()
						if clone and clone.Parent then
							clone:Destroy()
						end

						if endedConnection then
							endedConnection:Disconnect()
							endedConnection = nil
						end
					end)
				end
			end
		end
	end
end

function PlaySound.DeleteSound(player, p)
	local character = player.Character

	if character and character.Parent then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local child = humanoidRootPart and humanoidRootPart:FindFirstChild(p.Name)

		if child then
			child:Destroy()
		end
	end
end

function PlaySound.DeleteSound_Character(instance, childName: string)
	local child = instance and instance.Parent and instance:FindFirstChild(childName)

	if child then
		child:Destroy()
	end
end

function PlaySound.FadingSound_Out(instance, duration: number, childName: string)
	local child = instance and instance.Parent and instance:FindFirstChild(childName)

	if child then
		local tween = TweenService:Create(child, TweenInfo.new(duration), {
			Volume = 0
		})
		tween:Play()
		tween.Completed:Wait()

		if child and child.Parent then
			child:Destroy()
		end
	end
end

return PlaySound