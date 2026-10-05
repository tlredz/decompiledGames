local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
local Reparent = require(ReplicatedStorage.Reparent)
local localPlayer = Players.LocalPlayer
local fakeIslands = ReplicatedStorage:WaitForChild("FakeIslands")
local v = {}
local v2 = {}
local v3 = nil
local vector2 = createVector(0, 0, 0)
local flag = false
local renderSteppedConnection = nil

local function handleFakeIsland(instance)
	if v2[instance] or flag then
		return
	end

	v2[instance] = true

	for _, v4 in instance:QueryDescendants("BasePart") do
		v4.CanCollide = false
		v4.CanQuery = false
		v4.Anchored = true
	end

	local child = workspace.Map:WaitForChild(instance.Name, 999999)

	if flag then
		return
	end

	local map = Reparent.CreateMap(child)
	local boundingBox, v4 = child:GetBoundingBox()
	v[instance] = {
		Instances = map,
		Position = boundingBox.Position,
		MinimumFrameTime = instance:GetAttribute("MinimumFrameTime") or 0.00025,
		MaximumFrameTime = instance:GetAttribute("MaximumFrameTime") or 0.016,
		MinDistance = instance:GetAttribute("MinDistance") or math.max(v4.X, v4.Z) * 0.5 + 4096,
		MaxDistance = instance:GetAttribute("MaxDistance") or 512,
		CurrentState = true,
		CurrentlyLoading = false
	}
end

local function shutdown()
	if flag then
		return
	end

	flag = true

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	for k in v do
		k:Destroy()
	end

	for _, child in fakeIslands:GetChildren() do
		child:Destroy()
	end

	table.clear(v)
	table.clear(v2)
end

ReplicatedStorage.Remotes.ClientLoDPosition.OnClientEvent:Connect(function(position: Vector3, duration: number)
	local part = Instance.new("Part")
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.CFrame = CFrame.new(position)
	part.Size = createVector(0, 0, 0)
	part:AddTag("LoDPosition")
	part.Parent = workspace.CurrentCamera
	task.delay(duration, part.Destroy, part)
end)

if not workspace.CurrentCamera.CameraSubject then
	repeat
		task.wait()
	until workspace.CurrentCamera.CameraSubject
end

if workspace:GetAttribute("IslandLODDisabled") then
	shutdown()
	return
end

workspace:GetAttributeChangedSignal("IslandLODDisabled"):Connect(function()
	if workspace:GetAttribute("IslandLODDisabled") then
		shutdown()
	end
end)
fakeIslands.ChildAdded:Connect(handleFakeIsland)
renderSteppedConnection = RunService.RenderStepped:Connect(function()
	if localPlayer.Character == nil then
		return
	end

	local position = localPlayer.Character:GetPivot().Position

	if (vector2 - position).Magnitude >= 400 then
		local v4 = 4000
		local v5 = nil

		for k, v6 in v do
			local magnitude = ((v6.Position - position) * createVector(1, 0, 1)).Magnitude

			if not (magnitude < v4) then
				continue
			end

			v5 = k
			v4 = magnitude
		end

		if v5 then
			local v6 = v[v5]

			if v6.CurrentState == false or v6.CurrentlyLoading then
				Reparent.Parent(v6.Instances, 1e999, function(p)
					if p then
						v5.Parent = nil
					end
				end)
			end
		end

		vector2 = position
	else
		vector2 = position
		local v4 = next(v, v3)

		if v4 then
			local v5 = v[v4]
			local vector3 = vector2
			local currentState = ((vector2 - v5.Position) * createVector(1, 0, 1)).Magnitude <= v5.MinDistance

			if ({ GetWaterHeightAtLocation(vector2) })[1] < -100 then
				currentState = v5.CurrentState
			end

			if not currentState then
				for _, instance in CollectionService:GetTagged("LoDPosition") do
					if not instance:IsDescendantOf(workspace) then
						continue
					end

					local worldPosition = nil

					if instance:IsA("Attachment") then
						worldPosition = instance.WorldPosition
					elseif instance:IsA("PVInstance") then
						worldPosition = instance:GetPivot().Position
					else
						error((`[NewIslandLOD]: Invalid point of interest class "{instance.ClassName}" located at {instance:GetFullName()}`))
					end

					currentState = ((worldPosition - v5.Position) * createVector(1, 0, 1)).Magnitude <= v5.MinDistance

					if not currentState then
						continue
					end

					vector3 = worldPosition
					break
				end
			end

			if currentState ~= v5.CurrentState then
				v5.CurrentState = currentState

				if currentState then
					v5.CurrentlyLoading = true
					task.spawn(Reparent.Parent, v5.Instances, function()
						if vector3 == vector2 then
							return (math.lerp(
								v5.MinimumFrameTime,
								v5.MaximumFrameTime,
								(math.clamp(
									(v5.MinDistance - ((vector3 - v5.Position) * createVector(1, 0, 1)).Magnitude) / v5.MaxDistance,
									0,
									1
								))
							))
						end

						return 0.0015
					end, function(p)
						v5.CurrentlyLoading = false

						if p then
							v4.Parent = nil
						end
					end)
				else
					v4.Parent = workspace
					task.spawn(Reparent.Unparent, v5.Instances, v5.MinimumFrameTime)
				end
			end
		end

		v3 = v4
	end
end)

for _, child in fakeIslands:GetChildren() do
	task.spawn(handleFakeIsland, child)
end