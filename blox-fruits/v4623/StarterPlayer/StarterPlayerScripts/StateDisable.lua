game:GetService("RunService")
local v = {}
task.spawn(function()
	while task.wait(5) do
		for k, v2 in pairs(v) do
			if v2:IsDescendantOf(workspace) then
				if v2:GetState() == Enum.HumanoidStateType.FallingDown then
					v2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					v2:ChangeState(Enum.HumanoidStateType.Running)
				end
			else
				v[k] = nil
			end
		end
	end
end)

local function HandleHumanoidCharacterAdded(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid then
		v[humanoid] = humanoid
		return
	end

	local childAddedConnection = nil
	childAddedConnection = instance.ChildAdded:Connect(function(humanoid2)
		if humanoid2:IsA("Humanoid") then
			v[humanoid2] = humanoid2
			humanoid2.StateChanged:Connect(function(_, p)
				if p == Enum.HumanoidStateType.FallingDown then
					humanoid2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					humanoid2:ChangeState(Enum.HumanoidStateType.Running)
				end
			end)
			childAddedConnection:Disconnect()
		end
	end)
end

for _, child in workspace.Enemies:GetChildren() do
	local humanoid = child:FindFirstChildOfClass("Humanoid")

	if humanoid then
		v[humanoid] = humanoid
	else
		local childAddedConnection = nil
		childAddedConnection = child.ChildAdded:Connect(function(humanoid2)
			if humanoid2:IsA("Humanoid") then
				v[humanoid2] = humanoid2
				humanoid2.StateChanged:Connect(function(_, p)
					if p == Enum.HumanoidStateType.FallingDown then
						humanoid2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
						humanoid2:ChangeState(Enum.HumanoidStateType.Running)
					end
				end)
				childAddedConnection:Disconnect()
			end
		end)
	end
end

for _, child in workspace.NPCs:GetChildren() do
	local humanoid = child:FindFirstChildOfClass("Humanoid")

	if humanoid then
		v[humanoid] = humanoid
	else
		local childAddedConnection = nil
		childAddedConnection = child.ChildAdded:Connect(function(humanoid2)
			if humanoid2:IsA("Humanoid") then
				v[humanoid2] = humanoid2
				humanoid2.StateChanged:Connect(function(_, p)
					if p == Enum.HumanoidStateType.FallingDown then
						humanoid2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
						humanoid2:ChangeState(Enum.HumanoidStateType.Running)
					end
				end)
				childAddedConnection:Disconnect()
			end
		end)
	end
end

workspace.NPCs.ChildAdded:Connect(HandleHumanoidCharacterAdded)
workspace.Enemies.ChildAdded:Connect(HandleHumanoidCharacterAdded)