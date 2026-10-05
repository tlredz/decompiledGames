local createVector = vector.create

local function getDebugPart()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Name = "DebugPart"
	part.Transparency = 0.5
	part.Size = createVector(1, 1, 1)
	part.Shape = Enum.PartType.Ball
	part.Parent = game.Workspace
	return part
end

local DebugUtil = {}

function DebugUtil.showRaycast(position: Vector3, vector2: Vector3, p: number, raycastResult: RaycastResult?)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Name = "DebugPart"
	part.Transparency = 0.5
	part.Size = createVector(1, 1, 1)
	part.Shape = Enum.PartType.Ball
	part.Parent = game.Workspace
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(0.3, 0, 0.3)
	part.Color = Color3.fromRGB(0, 255, 0)
	part.Position = position
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.Name = "DebugPart"
	part2.Transparency = 0.5
	part2.Size = createVector(1, 1, 1)
	part2.Shape = Enum.PartType.Ball
	part2.Parent = game.Workspace
	part2.Size = Vector3.new(0.1, 0.1, p)
	part2.CFrame = CFrame.lookAt(position + vector2, position) * CFrame.new(0, 0, -p / 2)
	part2.Color = Color3.fromRGB(255, 166, 0)
	local part3 = Instance.new("Part")
	part3.Anchored = true
	part3.CanCollide = false
	part3.Name = "DebugPart"
	part3.Transparency = 0.5
	part3.Size = createVector(1, 1, 1)
	part3.Shape = Enum.PartType.Ball
	part3.Parent = game.Workspace
	part3.Shape = Enum.PartType.Ball
	part3.Size = createVector(0.3, 0, 0.3)
	part3.Color = Color3.fromRGB(255, 0, 0)
	part3.Position = position + vector2.Unit * p

	if raycastResult then
		local part4 = Instance.new("Part")
		part4.Anchored = true
		part4.CanCollide = false
		part4.Name = "DebugPart"
		part4.Transparency = 0.5
		part4.Size = createVector(1, 1, 1)
		part4.Shape = Enum.PartType.Ball
		part4.Parent = game.Workspace
		part4.Shape = Enum.PartType.Ball
		part4.Size = createVector(0.2, 0.2, 0.2)
		part4.Color = Color3.fromRGB(0, 38, 255)
		part4.Transparency = 0
		part4.Position = raycastResult.Position
		task.delay(2, function()
			part4:Destroy()
		end)
	end

	task.delay(2, function()
		part:Destroy()
		part2:Destroy()
		part3:Destroy()
	end)
end

function DebugUtil.flashPoint(position: Vector3, color: Color3?)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Name = "DebugPart"
	part.Transparency = 0.5
	part.Size = createVector(1, 1, 1)
	part.Shape = Enum.PartType.Ball
	part.Parent = game.Workspace
	part.Color = color or Color3.fromRGB(255, 0, 0)
	part.Position = position
	task.delay(1, function()
		part:Destroy()
	end)
end

function DebugUtil.debugSignalsInTable(items, p: string)
	for k, item in pairs(items) do
		if not (typeof(item) == "table" and item.ClassName == "Signal" and item.Connect) then
			continue
		end

		local v = k
		item:Connect(function(...)
			print(p, ("|%s|"):format(v), ...)
		end)
	end
end

return DebugUtil