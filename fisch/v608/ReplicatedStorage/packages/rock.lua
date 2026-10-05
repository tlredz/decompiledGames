local createVector = vector.create
local Rock = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local parent = nil

local function CheckDebrisFolder()
	if workspace:FindFirstChild("Debris") then
		parent = workspace:FindFirstChild("Debris")
		return
	end

	parent = Instance.new("Folder")
	parent.Name = "Debris"
	parent.Parent = workspace
end

function Rock.Crater(cframe: CFrame, value: number, value2: number, value3: number, flag: boolean)
	local v2 = value or 7
	local v3 = value2 or 7
	local v4 = value3 or 10
	local v5 = flag == nil or flag

	if workspace:FindFirstChild("Debris") then
		parent = workspace:FindFirstChild("Debris")
	else
		parent = Instance.new("Folder")
		parent.Name = "Debris"
		parent.Parent = workspace
	end

	local raycastParams = RaycastParams.new()
	local filterDescendantsInstances = { parent }

	for _, v7 in pairs(Players:GetPlayers()) do
		local character = v7.Character

		if character then
			table.insert(filterDescendantsInstances, character)
		end
	end

	for _, instance in pairs(game.Workspace:GetDescendants()) do
		local CollectionService = game:GetService("CollectionService")

		if CollectionService:HasTag(instance, "RockModuleIgnore") then
			table.insert(filterDescendantsInstances, instance)
		end
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(cframe.Position, cframe.UpVector * -1000, raycastParams)

	if raycastResult then
		local v7 = math.round((math.random(v3, v4)))
		local cframe2 = CFrame.new(raycastResult.Position)
		local total = 0

		for _ = 1, v7 do
			local part = Instance.new("Part")
			part.Parent = parent
			part.Name = "GroundSlam"
			part.Size = Vector3.new(math.random(3, 5), math.random(2, 3), math.random(2, 4))
			part.CFrame = cframe2 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, -v2) + createVector(
				0,
				-5,
				0
			)
			part.CFrame = CFrame.lookAt(part.Position, raycastResult.Position)
			local raycastResult2 = workspace:Raycast(
				part.CFrame.Position + createVector(0, 7, 0),
				createVector(-0, -1000, -0),
				raycastParams
			)

			if raycastResult2 then
				part.Color = raycastResult2.Instance.Color
				part.Material = raycastResult2.Instance.Material
				part.Transparency = raycastResult2.Instance.Transparency
			else
				part.Color = raycastResult.Instance.Color
				part.Material = raycastResult.Instance.Material
				part.Transparency = raycastResult.Instance.Transparency
			end

			if v5 == false then
				part.CollisionGroup = "RockDebris"
			end

			part.Anchored = true
			part.CanCollide = true
			local Debris = game:GetService("Debris")
			Debris:AddItem(part, 30)
			TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Position = part.Position + createVector(0, 4.5, 0)
			}):Play()
			task.spawn(function()
				task.wait(math.random(650, 950) / 100)
				TweenService:Create(part, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Position = part.Position + createVector(0, -5, 0),
					Size = createVector(1, 1, 1)
				}):Play()
			end)
			total += 360 / v7
		end
	end
end

function Rock.Explosion(cFrame: CFrame, value: number, value2: number, value3: number, flag: boolean)
	local v2 = value or 7
	local v3 = value2 or 0.5
	local v4 = value3 or 2.5
	local v5 = flag or false

	if workspace:FindFirstChild("Debris") then
		parent = workspace:FindFirstChild("Debris")
	else
		parent = Instance.new("Folder")
		parent.Name = "Debris"
		parent.Parent = workspace
	end

	local raycastParams = RaycastParams.new()
	local filterDescendantsInstances = { parent }

	for _, v7 in pairs(Players:GetPlayers()) do
		local character = v7.Character

		if character then
			table.insert(filterDescendantsInstances, character)
		end
	end

	for _, instance in pairs(game.Workspace:GetDescendants()) do
		local CollectionService = game:GetService("CollectionService")

		if CollectionService:HasTag(instance, "RockModuleIgnore") then
			table.insert(filterDescendantsInstances, instance)
		end
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -100, raycastParams)

	if raycastResult then
		for _ = 1, v2 do
			local part = Instance.new("Part")
			part.Name = "ExplosionPart"
			part.Parent = parent
			local v7 = math.random(v3 * 100, v4 * 100) / 100

			if math.random(1, 5) == 3 then
				part.Size = Vector3.new(v7 * 2, 0.15, v7 * 2)
			else
				part.Size = Vector3.new(v7, v7, v7)
			end

			part.CFrame = cFrame
			part.Color = raycastResult.Instance.Color
			part.Material = raycastResult.Instance.Material
			part.Anchored = false
			part.Orientation = Vector3.new(math.random(-359, 359), math.random(-359, 359), math.random(-359, 359))
			part.Transparency = raycastResult.Instance.Transparency
			part.CanCollide = true

			if v5 == false then
				part.CollisionGroup = "RockDebris"
			end

			local Debris = game:GetService("Debris")
			Debris:AddItem(part, 4.5)
			local vector2 = Vector3.new(math.random(-32, 32), 22, math.random(-32, 32))
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = vector2
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.P = 5000
			bodyVelocity.Parent = part
			local Debris2 = game:GetService("Debris")
			Debris2:AddItem(bodyVelocity, 0.25)
			task.spawn(function()
				task.wait(4)
				TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
					Size = createVector(0.1, 0.1, 0.1),
					Transparency = 1
				}):Play()
			end)
		end
	end
end

function Rock.CraterRows(cframe: CFrame, value: number, value2: number, value3: number, value4: number, value5: number, flag: boolean)
	local v2 = flag == nil or flag
	local v3 = value or 7
	local v4 = value4 or 7
	local v5 = value5 or 10
	local v6 = value3 or 4

	for i = 1, value2 or 3 do
		Rock.Crater(cframe, v3, v4 * i, v5 * i, v2)
		v3 += v6
	end
end

function Rock.ClearDebris(flag: boolean)
	if workspace:FindFirstChild("Debris") then
		parent = workspace:FindFirstChild("Debris")
	else
		parent = Instance.new("Folder")
		parent.Name = "Debris"
		parent.Parent = workspace
	end

	if flag then
		for _, part in pairs(parent:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
				Size = createVector(0.1, 0.1, 0.1),
				Transparency = 1
			}):Play()
			local Debris = game:GetService("Debris")
			Debris:AddItem(part, 1)
		end
	else
		for _, child in pairs(parent:GetChildren()) do
			child:Destroy()
		end
	end
end

return Rock