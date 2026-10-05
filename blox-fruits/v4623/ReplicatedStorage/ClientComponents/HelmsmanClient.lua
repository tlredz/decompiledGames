local createVector = vector.create
local Boid = require(game.ReplicatedStorage.Modules.Boid)
local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local CatmullRomSpline = require(game.ReplicatedStorage.Modules.CatmullRomSpline)
local bottomHUDList = nil
local _ = {
	LINES = true
}
local color = Color3.fromRGB(202, 202, 202)
local color2 = Color3.fromRGB(0, 255, 0)
local localPlayer = game.Players.LocalPlayer
local v = Component.new({
	Tag = "HelmsmanClient",
	Ancestors = { workspace },
	Extensions = {
		{
			ShouldConstruct = function(p)
				return p.Instance:GetAttribute("OwnerId") == localPlayer.UserId
			end
		}
	}
})

local function getWheelDegree(vector2: Vector3, vector3: Vector3, min: number, max: number)
	local v2 = math.clamp(math.deg((math.acos((vector2:Dot(vector3))))), min, max)

	if v2 ~= v2 then
		return min
	end

	return v2
end

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function map(p: number, p2: number, p3: number, min: number, max: number)
	return (math.clamp((p - p2) / (p3 - p2) * (max - min) + min, min, max))
end

local function resetUI()
	bottomHUDList.Helmsman.Visible = false
	bottomHUDList.Helmsman.Helm.Visible = false
	bottomHUDList.Helmsman.Boost.Visible = false
	bottomHUDList.StartButton.Visible = false
	bottomHUDList.BoostButton.Visible = false
	bottomHUDList.Helmsman.Helm.CanvasGroup.Arrow.Rotation = 0
	bottomHUDList.Helmsman.Helm.CanvasGroup.Glow.ImageColor3 = color
	bottomHUDList.Helmsman.Helm.CanvasGroup.Arrow.ImageColor3 = color
	bottomHUDList.Helmsman.Helm.CanvasGroup.Timer.Text = ""
	bottomHUDList.Helmsman.Helm.CanvasGroup.Timer.Visible = false
	bottomHUDList.Visible = true
end

local function seagulls(position: Vector3, p)
	local parent = p.seat.Parent
	local folder = Instance.new("Folder")
	folder.Name = "HelmsmanSeagulls"
	folder.Parent = workspace._WorldOrigin
	local folder2 = Instance.new("Folder")
	folder2.Name = "Seagulls"
	folder2.Parent = folder
	local part = Instance.new("Part")
	part.Size = createVector(250, 1, 250)
	part.CanCollide = false
	part.CanTouch = false
	part.Transparency = 1
	part.Parent = folder
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {}
	local group = Boid.new()
	group.NEIGHBOR_DIST = 50
	group.RAY_LENGTH = 5
	group.TargetPosition = position
	group.RaycastParams = raycastParams
	local extentsSize = parent:GetExtentsSize()
	local v3 = math.max(50, extentsSize.Y * 0.5)
	local v4 = math.max(50, extentsSize.Y * 0.5)
	local v5 = math.max(50, extentsSize.Y)

	for i = 1, 3 do
		local clone = script.seagull:Clone()
		clone:SetPrimaryPartCFrame(CFrame.new(position + Vector3.new(i * math.random(-2, 2), 50, i * math.random(-2, 2))))
		clone.Parent = folder2
		group:AddBoid(Boid.CreateBoid(clone))
	end

	local v6 = {
		group = group,
		steer = {
			value = 0,
			min = 15,
			max = 20
		},
		velocityMul = {
			value = 0,
			min = 1.1,
			max = 1.5
		}
	}

	local function swarm(vector2: Vector3, _: number)
		return vector2
	end

	local v7 = createVector(0, 0, 0)
	local v8 = 1
	local v9 = 0

	function v6:Step(p2: number, vector2: Vector3, p3)
		if not next(group._Boids) then
			return
		end

		group.MIN_SPEED = 80
		group.MAX_SPEED = 100
		group.MAX_STEER_FORCE = 10
		group.TARGET_WEIGHT = 10
		debug.profilebegin("HelmsmanDriver: SeagullStep")
		local v10 = p.attributes.Stage == 4
		local maxSpeed = p.seat.MaxSpeed
		local targetPosition

		if v10 and group._AveragePosition then
			if (group._AveragePosition * createVector(1, 0, 1) - vector2).Magnitude <= 100 then
				if v9 >= 0.5 then
					targetPosition = vector2 + Vector3.new(0, p.seat.Position.Y + v4, 0)
				else
					targetPosition = vector2
				end

				v9 += p2
			else
				v9 = math.max(0, v9 - p2)
				local v12 = math.max(maxSpeed * 0.1, p.seat.AssemblyLinearVelocity.Magnitude)

				if p3 then
					local positionAt = CatmullRomSpline.CalculatePositionAt(p3, v8)
					local derivativeAt = CatmullRomSpline.CalculateDerivativeAt(p3, v8)

					if typeof(derivativeAt) == "Vector3" and typeof(positionAt) == "Vector3" then
						targetPosition = CFrame.new(positionAt, positionAt + derivativeAt).Position + Vector3.new(
							0,
							p.seat.Position.Y + v3,
							0
						)

						if group._AveragePosition and p.seat.CFrame.LookVector:Dot(targetPosition - p.seat.CFrame.Position) < 0 then
							v6.velocityMul.value = v6.velocityMul.max
							v6.steer.value = v6.steer.max
						end
					else
						targetPosition = vector2
					end
				else
					targetPosition = vector2
				end

				if v7 == vector2 then
					if v8 > 0 then
						local v13 = math.clamp((v12 - 0) / (maxSpeed - 0) * 1 + 0, 0, 1)
						v8 = math.max(0, v8 - p2 * 0.1 * v13)
					end
				else
					v6.velocityMul.value = v6.velocityMul.max
					v6.steer.value = v6.steer.max
					v8 = 1
				end

				local v13 = math.max(
					maxSpeed,
					v12 * math.clamp(v6.velocityMul.value, v6.velocityMul.min, v6.velocityMul.max)
				)
				group.MAX_STEER_FORCE = math.clamp(v6.steer.value, v6.steer.min, v6.steer.max)
				group.MIN_SPEED = v13
				group.MAX_SPEED = v13
			end
		else
			targetPosition = vector2 + Vector3.new(0, p.seat.Position.Y + v5, 0)
		end

		group.TargetPosition = targetPosition
		v6.steer.value -= p2
		v6.velocityMul.value -= p2 * 1.5
		debug.profileend()
		group:Step(p2)

		if group._AveragePosition then
			part.Position = Vector3.new(group._AveragePosition.X, 2, group._AveragePosition.Z)
		end

		v7 = vector2
	end

	function v6:Destroy()
		for _, list2 in pairs(group._Boids) do
			group:RemoveBoid(list2)
			list2._Instance:Destroy()
			table.clear(list2)
		end

		table.clear(self)
		folder:Destroy()
	end

	return v6
end

local function round(p: number, value: number)
	local v2 = 10 ^ (value or 1)
	return math.floor(p * v2) / v2
end

local function visualizePath(parent, object)
	local folder = Instance.new("Folder", parent)
	folder.Name = "Client"
	local folder_2 = Instance.new("Folder", folder)
	folder_2.Name = "Gates"
	local folder_3 = Instance.new("Folder", folder)
	folder_3.Name = "Checkpoints"
	local folder_4 = Instance.new("Folder", folder)
	folder_4.Name = "Barriers"
	local folder2 = Instance.new("Folder", folder)
	folder2.Name = "Lines"
	local v2 = {}

	for i = 1, 99 do
		local part = Instance.new("Part", folder2)
		part.Size = createVector(3, 0.55, 1)
		part.CastShadow = false
		part.Massless = true
		part.CanQuery = false
		part.CanTouch = false
		part.CanCollide = false
		part.Anchored = true
		part.Name = tostring(i)
		v2[i] = part
	end

	local cframes = {}

	if #v2 > 0 then
		for i = 1, 100 do
			local v3 = (i - 1) / 99
			local positionAt = object:CalculatePositionAt(v3)
			local derivativeAt = object:CalculateDerivativeAt(v3)
			cframes[i] = CFrame.new(positionAt, positionAt + derivativeAt)
		end
	end

	local function UpdateBezier()
		for k, v3 in pairs(v2) do
			local position = cframes[k].Position
			local position2 = cframes[k + 1].Position

			if k % 10 == 0 then
				v3.Color = Color3.fromRGB(0, 157, 255)
			else
				v3.Color = Color3.fromRGB(83, 123, 255)
				v3.Material = Enum.Material.Neon
			end

			v3.Size = Vector3.new(v3.Size.X, v3.Size.Y, (position2 - position).Magnitude)
			v3.CFrame = CFrame.new(0.5 * (position + position2), position2)
			v3.Name = tostring(k)
		end
	end

	UpdateBezier()
	return folder
end

function v:Construct()
	self._destroyed = false
	self.trove = Trove.new()
end

function v:Start()
	bottomHUDList = game.Players.LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("BottomHUDList")
	local instance = self.Instance
	local network = instance:WaitForChild("Network")
	local paths = instance and instance:WaitForChild("Paths")
	local boat = instance and instance:WaitForChild("Boat")

	if self._destroyed then
		return
	end

	local value = boat.Value
	local extentsSize = value:GetExtentsSize()
	local vehicleSeat = value:FindFirstChildOfClass("VehicleSeat")

	if not vehicleSeat.Occupant then
		warn("no occupant, stooooooooooooop")
		return
	end

	local attributes = instance:GetAttributes()
	local v2 = {}
	local v3 = nil
	local v4 = {
		attributes = attributes,
		seat = vehicleSeat
	}
	local v5 = nil
	local v6 = nil
	local trove = self.trove
	local v7 = nil
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanQuery = false
	part.CanCollide = false
	part.CanTouch = false
	part.Size = createVector(1, 100, 100)
	part.Transparency = 1
	part.BrickColor = BrickColor.Red()
	part.CFrame = attributes.StarterCFrame * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = workspace._WorldOrigin
	trove:Add(part)
	trove:Add(resetUI)
	trove:Add(function()
		bottomHUDList.Visible = false
	end)
	task.spawn(resetUI)
	local v8 = {
		function()
			if v6 and v6.Destroy then
				v6:Destroy()
				v6 = nil
			end
		end,
		function()
			part.Transparency = 0
			v6 = v6 or seagulls(attributes.StarterCFrame.Position, v4)
			local RunService = game:GetService("RunService")
			local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
				v6:Step(dt, attributes.StarterCFrame.Position)
			end)
			v7:Add(renderSteppedConnection)
		end,
		function()
			bottomHUDList.StartButton.Visible = true
			v6 = v6 or seagulls(attributes.StarterCFrame.Position, v4)
			local v9 = 0
			local RunService = game:GetService("RunService")
			local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
				local v10 = v9 / 2

				if (v4.seat.Position * createVector(1, 0, 1) - attributes.StarterCFrame.Position).Magnitude <= 100 then
					bottomHUDList.StartButton.Text = "START"
					v9 = math.max(0, dt - v9)
				else
					local v11 = math.floor((2 - v9) * 10) / 10
					bottomHUDList.StartButton.Text = "START (" .. v11 .. ")"
					v9 = math.min(2, dt + v9)
				end

				bottomHUDList.StartButton.TextTransparency = v10
				bottomHUDList.StartButton.Transparency = v10
				v6:Step(dt, vehicleSeat.CFrame.Position)
			end)
			v7:Add(renderSteppedConnection)
		end,
		function()
			bottomHUDList.Helmsman.Helm.Visible = true
			local now = 1
			local v9 = 0
			local RunService = game:GetService("RunService")
			local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
				if not v5 then
					v6:Step(dt, vehicleSeat.Position)
					return
				end

				if tick() - now > 0.1 then
					now = tick()
					local cFrame = vehicleSeat.CFrame
					local cFrame2 = v5.CFrame
					local v10 = math.clamp(
						math.deg((math.acos((cFrame.LookVector:Dot((cFrame2.Position - cFrame.Position).Unit))))),
						0,
						90
					)
					v9 = v10 ~= v10 and 0 or v10

					if cFrame:ToObjectSpace(CFrame.new(cFrame2.Position)).X < 0 then
						v9 = -v9
					end
				end

				local lerped = color:Lerp(color2, (math.clamp((30 - math.abs(v9)) / 30, 0, 1)))
				bottomHUDList.Helmsman.Helm.CanvasGroup.Glow.ImageColor3 = lerped
				bottomHUDList.Helmsman.Helm.CanvasGroup.Arrow.ImageColor3 = lerped
				local arrow = bottomHUDList.Helmsman.Helm.CanvasGroup.Arrow
				local rotation = bottomHUDList.Helmsman.Helm.CanvasGroup.Arrow.Rotation
				local v11 = v9
				local v12 = dt * 2
				arrow.Rotation = rotation + (v11 - rotation) * v12
				bottomHUDList.Helmsman.Helm.CanvasGroup.Wheel.Rotation = -bottomHUDList.Helmsman.Helm.CanvasGroup.Arrow.Rotation
				v6:Step(dt, v5.Position, v2[1])
			end)
			v7:Add(renderSteppedConnection)
		end
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stageChanged()
		part.Transparency = 1

		if v7 then
			self.trove:Remove(v7)
			v7 = nil
		end

		resetUI()
		v7 = self.trove:Extend()
		v8[attributes.Stage]()
	end

	trove:Add((Instance.new("NumberValue")))
	local RunService = game:GetService("RunService")
	trove:Add(RunService.Heartbeat:Connect(function(dt: number)
		local scale = bottomHUDList.Helmsman.Boost.ProgressBar.Fill.Size.X.Scale
		local boost = attributes.Boost
		local v9 = dt * 2
		local v10 = scale + (boost - scale) * v9
		bottomHUDList.Helmsman.Boost.ProgressBar.Fill.BackgroundColor3 = color:Lerp(color2, attributes.Boost)
		bottomHUDList.Helmsman.Boost.ProgressBar.Fill.Size = UDim2.fromScale(v10, 1)
	end))

	local function boostChanged()
		local visible

		if attributes.Boost > 0 then
			visible = attributes.Stage ~= 4
		else
			visible = false
		end

		bottomHUDList.BoostButton.Visible = visible
		bottomHUDList.BoostButton.BackgroundColor3 = visible and attributes.IsBoosting and color or Color3.fromRGB(
			0,
			255,
			119
		)
		local visible2 = attributes.Boost > 0 or attributes.Stage == 4
		bottomHUDList.Helmsman.Boost.Visible = visible2
		bottomHUDList.Helmsman.Visible = visible2
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function timerChanged()
		bottomHUDList.Helmsman.Helm.CanvasGroup.Timer.Visible = true
		bottomHUDList.Helmsman.Helm.CanvasGroup.Timer.Text = attributes.Timer
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function starterCFrameChanged()
		part.CFrame = attributes.StarterCFrame * CFrame.Angles(0, 0, 1.5707963267948966)
	end

	instance.AttributeChanged:Connect(function(attributeName: string)
		attributes[attributeName] = instance:GetAttribute(attributeName)

		if attributeName == "Boost" or attributeName == "IsBoosting" then
			boostChanged()
		elseif attributeName == "Stage" then
			stageChanged() -- equivalent call inferred; original call site unknown
			boostChanged()
		elseif attributeName == "Timer" then
			timerChanged() -- equivalent call inferred; original call site unknown
		elseif attributeName == "StarterCFrame" then
			starterCFrameChanged() -- equivalent call inferred; original call site unknown
		end
	end)
	task.spawn(starterCFrameChanged)
	task.spawn(boostChanged)
	task.spawn(stageChanged)
	task.spawn(timerChanged)

	local function updateTargetCheckpoint()
		local children = paths:GetChildren()
		table.sort(children, function(a, b)
			return assert((tonumber(a.Name))) < assert((tonumber(b.Name)))
		end)
		v3 = children
		local total = 0
		local v9 = {}

		for k, v10 in pairs(v3) do
			local v11 = k == 1
			local checkpoints = v10:FindFirstChild("Checkpoints")

			if not checkpoints then
				continue
			end

			local children2 = checkpoints:GetChildren()
			table.sort(children2, function(a, b)
				return assert((tonumber(a.Name))) < assert((tonumber(b.Name)))
			end)

			if v11 then
				v5 = children2[1]
			end

			total += #children2

			for i = 1, #children2 do
				table.insert(v9, children2[i])
			end
		end

		if #v9 > 0 then
			for i = #v9, 1, -1 do
				v9[i].Color = i == 1 and Color3.fromRGB(255, 179, 0) or Color3.fromRGB(255, 255, 255)
			end
		end

		table.clear(v9)
	end

	local thread = nil

	local function generatePath()
		if thread then
			task.cancel(thread)
			thread = nil
		end

		thread = task.delay(0.2, function()
			thread = nil

			if v3 then
				for _, v9 in pairs(v3) do
					local client = v9:FindFirstChild("Client")

					if not client then
						continue
					end

					warn("Destroy", client)
					client:Destroy()
				end

				for _, v9 in pairs(v2) do
					v9:Destroy()
				end

				table.clear(v2)
			end

			updateTargetCheckpoint()

			for i = 1, #v3 do
				local v9 = v3[i]
				local v10 = nil
				local v11 = nil
				local v12 = nil
				local v13 = nil

				while instance and v9.Parent and not (thread or self._destroyed) do
					v10 = v10 or v9:FindFirstChild("ControlPoints")
					v12 = v12 or v9:FindFirstChild("Checkpoints")
					v13 = v13 or v9:FindFirstChild("Gates")
					v11 = v11 or v9:FindFirstChild("Barriers")

					if v11 and v10 and v12 and v13 and #v10:GetChildren() >= 4 then
						break
					end

					print("splinesSorted: Waiting:", i, v11, v10, v12, v13, v10 and #v10:GetChildren())
					task.wait(0.1)
				end

				if not (v9.Parent or thread) then
					warn("Spline removed durring yield", v9)
					break
				end

				if thread then
					warn("Spline added durring yield")
					break
				end

				if self._destroyed then
					warn("Helmsman destroyed durring yield")
					break
				end

				local v14 = CatmullRomSpline.new(nil, 1)
				local children = v10:GetChildren()
				table.sort(children, function(a, b)
					return assert((tonumber(a.Name))) < assert((tonumber(b.Name)))
				end)

				for _, v15 in pairs(children) do
					v14:AddPoint(v15)
				end

				table.insert(v2, v14)
				local v15 = nil

				local function addCheckpoint(part2)
					if not part2:IsA("BasePart") then
						warn("Checkpoint is not a base part")
						return
					end

					local clone = script.Indicator:Clone()
					clone.Transparency = 1
					clone.Size = createVector(150, 1, 150)
					clone.Position = part2.Position
					local weldConstraint = Instance.new("WeldConstraint")
					weldConstraint.Part0 = part2
					weldConstraint.Part1 = clone
					weldConstraint.Parent = part2
					clone.Anchored = false
					clone.Parent = v15:FindFirstChild("Checkpoints")

					-- equivalent calls inferred from this helper; original call sites unknown
					local function updateColor()
						local color3 = part2.Color
						clone.Beam1.Color = ColorSequence.new(color3)
						clone.Beam2.Color = ColorSequence.new(color3)
					end

					trove:Add(part2:GetPropertyChangedSignal("Color"):Connect(updateColor))
					updateColor() -- equivalent call inferred; original call site unknown
				end

				local function addGate(part2)
					if not part2:IsA("BasePart") then
						warn("Gate is not a base part")
						return
					end

					local v16 = math.max(300, extentsSize.Z * 2)
					local v17 = math.max(60, extentsSize.Y * 1.1)

					for i2 = 1, 3 do
						local part3 = Instance.new("Part")
						part3.Name = i2 == 1 and "Left" or i2 == 2 and "Right" or i2 == 3 and "Center" or "n/a"
						part3.CanCollide = false

						if i2 == 3 then
							part3.Transparency = 0.8
							part3.Color = Color3.fromRGB(4, 255, 0)
							part3.Size = Vector3.new(v16 - 5, v17, 2)
							part3:PivotTo(part2:GetPivot() * CFrame.new(0, v17 * 0.5, 0))
						else
							part3.Transparency = 0.5
							part3.Size = Vector3.new(5, v17, 2)
							part3.Color = Color3.fromRGB(255, 0, 4)
							local pivot = part2:GetPivot()
							local v18

							if i2 == 1 then
								v18 = -v16 or v16
							else
								v18 = v16
							end

							part3:PivotTo(pivot * CFrame.new(v18 * 0.5, v17 * 0.5, 0))
						end

						local weldConstraint = Instance.new("WeldConstraint")
						weldConstraint.Part0 = part2
						weldConstraint.Part1 = part3
						weldConstraint.Parent = part2
						part3.Parent = v15:FindFirstChild("Gates")
					end
				end

				local function addBarrier(part2)
					if not part2:IsA("BasePart") then
						warn("Barrier is not a base part")
						return
					end

					local clone = part2:Clone()
					clone.CanCollide = true
					clone.Color = Color3.fromRGB(255, 0, 4)
					clone.Transparency = 0.5
					clone.Size = Vector3.new(5, math.max(50, extentsSize.Y * 1.1), 800)
					clone.CFrame = part2.CFrame * CFrame.new(0, clone.Size.Y * 0.5, 0)
					local weldConstraint = Instance.new("WeldConstraint")
					weldConstraint.Part0 = part2
					weldConstraint.Part1 = clone
					weldConstraint.Parent = part2
					clone.Anchored = false
					clone.Parent = v15:FindFirstChild("Barriers")
				end

				v15 = visualizePath(v9, v14)

				if self._destroyed then
					break
				end

				trove:Add(v11.ChildAdded:Connect(addBarrier))

				for _, child in pairs(v11:GetChildren()) do
					task.spawn(addBarrier, child)
				end

				trove:Add(v12.ChildAdded:Connect(addCheckpoint))

				for _, child in pairs(v12:GetChildren()) do
					task.spawn(addCheckpoint, child)
				end

				trove:Add(v13.ChildAdded:Connect(addGate))

				for _, child in pairs(v13:GetChildren()) do
					task.spawn(addGate, child)
				end

				v9.AncestryChanged:Connect(function(p, parent)
					if parent then
						return
					end

					v14:Destroy()
					table.remove(v2, 1)
				end)
			end
		end)
	end

	trove:Add(bottomHUDList.BoostButton.MouseButton1Down:Connect(function()
		if instance and attributes.Boost > 0 then
			network:FireServer("Boost")
		end
	end))
	trove:Add(bottomHUDList.BoostButton.MouseButton1Up:Connect(function()
		if instance then
			network:FireServer("Boost")
		end
	end))
	trove:Add(bottomHUDList.StartButton.Activated:Connect(function()
		if instance then
			network:FireServer("Start")
		end
	end))
	trove:Add(function()
		if thread then
			task.cancel(thread)
			thread = nil
		end

		for _, v9 in pairs(v2) do
			table.clear(v9.Points)
		end

		table.clear(v2)
	end)
	trove:Add(paths.ChildRemoved:Connect(updateTargetCheckpoint))
	trove:Add(paths.ChildAdded:Connect(generatePath))
	task.spawn(generatePath)
	trove:Add(function()
		if v6 and v6.Destroy then
			v6:Destroy()
			v6 = nil
		end

		table.clear(v4)
	end)
end

function v:Stop()
	self._destroyed = true
	self.trove:Destroy()
	self.trove = nil
end

return v