local FrogGateClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.UnlockGateAnimation:Connect(function(instance)
	if not (instance and instance.Parent) then
		return
	end

	task.wait(0.5)

	for _, child in pairs(instance.Functional:GetChildren()) do
		if child.Name ~= "FrogLock" then
			continue
		end

		local key = child.Key
		local v2 = key:GetPivot()
		Client.TweenModule.new(function(p)
			key:PivotTo(v2 * CFrame.Angles(0, 0, -1.5707963267948966 * p))
		end, 1):Play()
	end

	if instance:FindFirstChild("Functional") and instance.Functional:FindFirstChild("TouchZone") then
		instance.Functional.TouchZone.Unlock:Play()
	end

	task.wait(1.25)
	local pivot = instance:GetPivot()
	Client.TweenModule.new(function(p)
		instance:PivotTo(pivot + Vector3.new(0, 14 * p, 0))
	end, 5):Play()

	if instance:FindFirstChild("Functional") and instance.Functional:FindFirstChild("TouchZone") then
		instance.Functional.TouchZone.Opening:Play()
	end
end)

function AddLock(object)
	object:GetAttributeChangedSignal("Unlocked"):Connect(function()
		for _, descendant in pairs(object.Key:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name ~= "Main" then
				descendant.Transparency = 0
			elseif descendant:IsA("PointLight") then
				descendant.Enabled = true
			end
		end
	end)
end

local v = {}

function GetEmptyLock(instance)
	local functional = instance:WaitForChild("Functional")

	for _, child in pairs(functional:GetChildren()) do
		if child.Name == "FrogLock" and not (child:GetAttribute("Unlocked") or v[child]) then
			return child
		end
	end
end

function ConnectFrogGate(instance)
	instance:WaitForChild("Functional"):WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		local parent = otherPart.Parent
		local v2 = GetEmptyLock(instance)

		if parent:GetAttribute("Owner") and parent:GetAttribute("Owner") ~= localPlayer.UserId or not v2 or v[parent] or v2:GetAttribute("Unlocked") then
			return
		end

		if parent:GetAttribute("Destroyed") then
			return
		end

		if parent.Name == "Frog Key" then
			local function undo()
				v[parent] = nil
				v[v2] = nil
				parent.Parent = workspace.Items

				if not v2:GetAttribute("Unlocked") then
					for _, descendant in pairs(v2.Key:GetDescendants()) do
						if descendant:IsA("BasePart") then
							descendant.Transparency = 1
						elseif descendant:IsA("PointLight") then
							descendant.Enabled = false
						end
					end
				end
			end

			v[parent] = true
			v[v2] = true
			parent.Parent = game.ReplicatedStorage.TempStorage

			for _, descendant in pairs(v2.Key:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.Name ~= "Main" then
					descendant.Transparency = 0
				elseif descendant:IsA("PointLight") then
					descendant.Enabled = true
				end
			end

			if instance:FindFirstChild("Functional") and instance.Functional:FindFirstChild("TouchZone") then
				instance.Functional.TouchZone.KeyAdded:Play()
			end

			local v3 = Client.Events.RequestAddFrogKey:InvokeServer(parent, v2)

			if not (v3 and v3.Success) then
				task.spawn(function()
					wait(0.5)
					undo()
				end)
			end
		end
	end)
end

function AddLockOld(instance)
	local touchZone = instance:WaitForChild("TouchZone")
	local flag = false
	local touchedConnection = nil
	instance:GetAttributeChangedSignal("Unlocked"):Connect(function()
		touchedConnection:Disconnect()

		for _, descendant in pairs(instance.Key:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name ~= "Main" then
				descendant.Transparency = 0
			elseif descendant:IsA("PointLight") then
				descendant.Enabled = true
			end
		end
	end)
	touchedConnection = touchZone.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if flag or parent:GetAttribute("BeingUsed") or instance:GetAttribute("Unlocked") or parent:GetAttribute("Destroyed") then
			return
		end

		if parent.Name == "Frog Key" then
			local function undo()
				parent:SetAttribute("BeingUsed", nil)
				parent.Parent = workspace.Items

				if not instance:GetAttribute("Unlocked") then
					for _, descendant in pairs(instance.Key:GetDescendants()) do
						if descendant:IsA("BasePart") then
							descendant.Transparency = 1
						elseif descendant:IsA("PointLight") then
							descendant.Enabled = false
						end
					end
				end
			end

			flag = true
			parent:SetAttribute("BeingUsed", true)
			parent.Parent = game.ReplicatedStorage.TempStorage

			for _, descendant in pairs(instance.Key:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.Name ~= "Main" then
					descendant.Transparency = 0
				elseif descendant:IsA("PointLight") then
					descendant.Enabled = true
				end
			end

			local v2 = Client.Events.RequestAddFrogKey:InvokeServer(parent, instance)

			if not (v2 and v2.Success) then
				task.spawn(function()
					wait(0.5)
					undo()
					wait(1)
					flag = false
				end)
			end
		end
	end)
end

function FrogGateAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local functional = instance:WaitForChild("Functional")

	for _, child in pairs(functional:GetChildren()) do
		if child.Name == "FrogLock" then
			AddLock(child)
		end
	end

	ConnectFrogGate(instance)
end

function FrogGateClient.Init()
	Client.Utility.ForAllTagged("FrogGate", FrogGateAdded)
end

return FrogGateClient