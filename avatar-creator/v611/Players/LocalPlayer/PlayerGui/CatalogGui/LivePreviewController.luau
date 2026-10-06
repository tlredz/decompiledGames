local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local avatar = parent.Root.LivePreview.Avatar
local camera = Instance.new("Camera")
camera.FieldOfView = 34
camera.Parent = avatar
avatar.CurrentCamera = camera
local worldModel = Instance.new("WorldModel")
worldModel.Parent = avatar
local v = nil
local v2 = {}
local v3 = {}
local humanoidRootPart = nil
local total = 0
local v4 = false
local v5 = nil
local X = nil
local connections = {}

local function aim()
	if not v then
		return
	end

	local boundingBox, v6 = v:GetBoundingBox()
	local v7 = math.max(0.15, avatar.AbsoluteSize.X / math.max(1, avatar.AbsoluteSize.Y))
	local v8 = math.max(v6.Y, v6.X / v7) / (math.tan((math.rad(camera.FieldOfView / 2))) * 2) + v6.Z * 0.65
	camera.CFrame = CFrame.lookAt(
		boundingBox.Position + Vector3.new(math.sin(total) * v8, 0.15, -math.cos(total) * v8),
		boundingBox.Position
	)
end

local function refresh()
	if not parent.Enabled then
		return
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	avatar:SetAttribute("RefreshCount", (avatar:GetAttribute("RefreshCount") or 0) + 1)
	local archivable = character.Archivable
	character.Archivable = true
	local clone = character:Clone()
	character.Archivable = archivable

	if not clone then
		return
	end

	v2 = {}
	v3 = {}
	humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local pair

	pair = function(instance, instance2)
		if instance:IsA("BasePart") then
			table.insert(v2, { instance, instance2 })
		elseif instance:IsA("Bone") then
			table.insert(v3, { instance, instance2 })
		end

		local v6 = {}

		for _, child in ipairs(instance:GetChildren()) do
			for _, child2 in ipairs(instance2:GetChildren()) do
				if v6[child2] or child.Name ~= child2.Name or child.ClassName ~= child2.ClassName then
					continue
				end

				v6[child2] = true
				pair(child, child2)
				break
			end
		end
	end

	pair(character, clone)

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("Tool") or descendant:IsA("Sound") or descendant:IsA("BillboardGui") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
		end
	end

	if v then
		v:Destroy()
	end

	v = clone
	clone.Parent = worldModel
	clone:PivotTo(CFrame.new())

	if humanoidRootPart then
		local cFrame = humanoidRootPart.CFrame

		for _, v6 in ipairs(v2) do
			if not (v6[1].Parent and v6[2].Parent) then
				continue
			end

			local objectSpace = cFrame:ToObjectSpace(v6[1].CFrame)

			if v6[3] == objectSpace then
				continue
			end

			v6[2].CFrame = objectSpace
			v6[3] = objectSpace
		end
	end

	aim()
end

local RunService = game:GetService("RunService")
RunService.PreRender:Connect(function()
	if not (parent.Enabled and v and humanoidRootPart and humanoidRootPart.Parent) then
		return
	end

	local cFrame = humanoidRootPart.CFrame

	for _, v6 in ipairs(v2) do
		if not (v6[1].Parent and v6[2].Parent) then
			continue
		end

		local objectSpace = cFrame:ToObjectSpace(v6[1].CFrame)

		if v6[3] == objectSpace then
			continue
		end

		v6[2].CFrame = objectSpace
		v6[3] = objectSpace
	end

	for _, transforms in ipairs(v3) do
		if not (transforms[1].Parent and transforms[2].Parent) then
			continue
		end

		local transform = transforms[1].Transform

		if transforms[3] == transform then
			continue
		end

		transforms[2].Transform = transform
		transforms[3] = transform
	end
end)
local count = 0

local function schedule(value)
	count += 1
	local v6 = count
	task.delay(value or 0.15, function()
		if v6 == count then
			refresh()
		end
	end)
end

local function bind(instance)
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connections = {}
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if humanoid then
		table.insert(connections, humanoid.ApplyDescriptionFinished:Connect(function()
			count += 1
			local v6 = count
			task.delay(0.05, function()
				if v6 == count then
					refresh()
				end
			end)
		end))
	end

	table.insert(connections, instance.ChildAdded:Connect(function(instance2)
		if instance2:IsA("Accessory") or instance2:IsA("Clothing") or instance2:IsA("BasePart") then
			count += 1
			local v6 = count
			task.delay(0.08, function()
				if v6 == count then
					refresh()
				end
			end)
		end
	end))
	table.insert(connections, instance.ChildRemoved:Connect(function(instance2)
		if instance2:IsA("Accessory") or instance2:IsA("Clothing") or instance2:IsA("BasePart") then
			count += 1
			local v6 = count
			task.delay(0.08, function()
				if v6 == count then
					refresh()
				end
			end)
		end
	end))
	count += 1
	local v6 = count
	task.delay(0.05, function()
		if v6 == count then
			refresh()
		end
	end)
end

avatar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v4 = true
		v5 = input.UserInputType == Enum.UserInputType.Touch and input or nil
		X = input.Position.X
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not (v4 and parent.Enabled) then
		return
	end

	if v5 and input == v5 or not v5 and input.UserInputType == Enum.UserInputType.MouseMovement then
		total += (input.Position.X - X) * 0.012
		X = input.Position.X
		aim()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input == v5 or input.UserInputType == Enum.UserInputType.MouseButton1 then
		v4 = false
		v5 = nil
	end
end)
avatar:GetPropertyChangedSignal("AbsoluteSize"):Connect(aim)
parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	v4 = false

	if parent.Enabled then
		refresh()
	end
end)
localPlayer.CharacterAdded:Connect(bind)

if localPlayer.Character then
	task.spawn(bind, localPlayer.Character)
end