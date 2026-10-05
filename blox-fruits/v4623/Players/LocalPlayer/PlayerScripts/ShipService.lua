local createVector = vector.create
workspace:WaitForChild("Boats")
workspace:WaitForChild("Characters")
game:GetService("PhysicsService")
require(game.ReplicatedStorage.Util)
local Spring = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("Spring"))
local BodyMover = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("BodyMover"))
local IsPointInsideShipBounds = require(game.ReplicatedStorage:WaitForChild("IsPointInsideShipBounds"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Boats }
local models = {}

for _, model in workspace.Map:GetChildren() do
	if model:IsA("Model") then
		table.insert(models, model)
	end
end

local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.FilterDescendantsInstances = models
local overlapParams = OverlapParams.new()
overlapParams.FilterDescendantsInstances = { workspace.Boats }
overlapParams.CollisionGroup = "Boats"
overlapParams.RespectCanCollide = true
overlapParams.FilterType = Enum.RaycastFilterType.Include
local v = false
local v2 = {}
local v3 = {}
local seatWeld = false

local function step(p)
	local v4 = {}
	local v5 = false

	for folder, v6 in pairs(v3) do
		local pivot = folder:GetPivot()
		local v7 = pivot * v6.lastPivot:inverse()
		v6.lastPivot = pivot

		for k, v8 in pairs(v2) do
			if v4[k] then
				continue
			end

			if k == game.Players.LocalPlayer.Character then
				if not (v8.root.Position.Y < -3) and IsPointInsideShipBounds(v8.root.Position, folder) then
					local size = v6.size

					if not (size and workspace:Raycast(
						v8.root.Position,
						createVector(0, 1, 0) * -size.Y,
						raycastParams2
					) or folder and folder:FindFirstChild("Humanoid") and folder.Humanoid.Value <= 0) then
						if v5 and size then
							local raycastResult = workspace:Raycast(
								v8.root.Position,
								createVector(0, 1, 0) * -size.Y,
								raycastParams
							)

							if raycastResult then
								v8.fail = 0
							else
								print("falling")
								v8.fail = (v8.fail or 0) + 1

								if v8.fail > 30 then
									print("failed boat")
									continue
								end
							end

							if raycastResult.Instance:IsDescendantOf(v5[3]) then
								continue
							end
						end

						local seatPart = k:FindFirstChild("Humanoid") and k.Humanoid.SeatPart

						if seatPart and seatPart:IsA("VehicleSeat") and seatPart.Parent == folder and not seatWeld then
							seatWeld = seatPart:FindFirstChild("SeatWeld")

							if seatWeld then
								for _, part in folder:GetDescendants() do
									if part:IsA("BasePart") then
										part.CollisionGroup = "FakePlayer"
									end
								end

								local folder2 = folder
								seatWeld.AncestryChanged:Connect(function(p2, parent)
									if not parent then
										seatWeld = nil

										for i, part in folder2:GetDescendants() do
											if part:IsA("BasePart") then
												part.CollisionGroup = "Boat"
											end
										end
									end
								end)
							end
						end

						v4[k] = true
						v5 = {
							pivot,
							v7,
							folder,
							v6,
							k,
							v8
						}
					end
				end
			elseif v8.humanoid.SeatPart or v8.humanoid.Sit or v8.humanoid:GetAttribute("IsPassenger") then
				if not v8.toggledCollisions then
					v8.toggledCollisions = true

					if not v8.activeParts then
						local parts = {}

						for _, part in pairs(v8.humanoid.Parent:GetChildren()) do
							if part:IsA("BasePart") and part.CollisionGroup == "Players" then
								table.insert(parts, part)
							end
						end

						v8.activeParts = parts
					end

					for _, activePart in pairs(v8.activeParts) do
						activePart.CollisionGroup = "FakePlayer"
					end
				end
			else
				if v8.toggledCollisions then
					v8.toggledCollisions = false

					for _, activePart in pairs(v8.activeParts) do
						activePart.CollisionGroup = "Players"
					end
				end

				if v8.replicatedCFrame ~= nil and v8.boat == folder and not (os.clock() - v8.lastUpdate > 5) then
					local v9 = v8.replicatedCFrame - v8.replicatedCFrame.Position

					if v8.spring then
						v8.spring:SetGoal(v8.replicatedCFrame.Position)
					else
						v8.spring = Spring.new(1, 10, v8.replicatedCFrame.Position)
					end

					v8.spring:Update(p)
					local v10 = CFrame.new(v8.spring:GetPosition()) * v9
					local cFrame = pivot * v10
					local active = BodyMover:GetActive(k)

					if active then
						for _, v12 in pairs(active.BodyPosition) do
							local value = v12.value
							value:Set(value.Values.Position + (cFrame.Position - v10.Position))
						end
					end

					v8.root.CFrame = cFrame
					v4[k] = true
				end
			end
		end
	end

	local v6 = false

	if v5 and v5 then
		local cframe = v5[1]
		local v7 = v5[2]
		local v8 = v5[3]
		local v9 = v5[4]
		local v10 = v5[5]
		local v11 = v5[6]

		if not (v11.humanoid.SeatPart or v11.humanoid.Sit or v11.humanoid:GetAttribute("IsPassenger")) then
			local cFrame = v11.root.CFrame

			if v and v11.humanoid:GetAttribute("IsInControl") then
				for _, part in pairs(v9.parts) do
					for _, v12 in workspace:GetPartsInPart(part, overlapParams) do
						if v12:IsDescendantOf(v8) then
							continue
						end

						local v13 = part.Position - v12.Position
						local Global = require(game.ReplicatedStorage.Global)
						local shipFromBoat = Global.getShipFromBoat(v8)
						local movement = shipFromBoat and shipFromBoat.Movement

						if movement then
							movement.Velocity = -1
						end

						part:ApplyImpulse(v13 * part.AssemblyMass)
					end
				end
			end

			if v and v ~= v9 then
				v.fakeBoat.Parent = nil

				for _, part in pairs(v.parts) do
					part.CanCollide = part:GetAttribute("__CanCollide")
				end

				v = false
			end

			v9.fakeBoat:PivotTo(cframe)

			if not v then
				v = v9

				for _, part in pairs(v9.parts) do
					part.CanCollide = false
				end

				v9.fakeBoat.Parent = workspace._WorldOrigin
			end

			local cFrame2 = v7 * cFrame
			local objectSpace = cframe:ToObjectSpace(cFrame2)
			game.ReplicatedStorage.Remotes.ShipServiceEvent:FireServer(v8, objectSpace)
			local active = BodyMover:GetActive(v10)

			if active then
				for _, v13 in pairs(active.BodyPosition) do
					local value = v13.value
					value:Set(value.Values.Position + (cFrame2.Position - cFrame.Position))
				end
			end

			v11.root.CFrame = cFrame2
			v6 = true
		end
	end

	if not v6 and v then
		v.fakeBoat.Parent = nil

		for _, part in pairs(v.parts) do
			part.CanCollide = part:GetAttribute("__CanCollide")
		end

		game.ReplicatedStorage.Remotes.ShipServiceEvent:FireServer()
		v = false
	end
end

local function add(folder)
	task.wait(3)

	if folder.Parent ~= workspace.Boats or v3[folder] then
		return
	end

	local clone = folder:Clone()

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if descendant.CanCollide == false then
				descendant:Destroy()
			else
				descendant.Anchored = true
				descendant.Transparency = 1
				descendant.CanTouch = false
				descendant.CanQuery = false
				descendant.Velocity = createVector(0, 0, 0)
				descendant.RotVelocity = createVector(0, 0, 0)
				descendant.CollisionGroup = "FakeBoat"

				if descendant:IsA("VehicleSeat") or descendant:IsA("Seat") then
					descendant.Disabled = true
				end
			end
		elseif not descendant:IsA("Model") and not descendant:IsA("Folder") then
			descendant:Destroy()
		end
	end

	local function setProps(p)
		local parts = {}

		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CustomPhysicalProperties = PhysicalProperties.new(0.01 * (not p and 1 or p.Magnitude or 1), 0, 0)
			part:SetAttribute("__CanCollide", part.CanCollide)
			table.insert(parts, part)
		end

		return parts
	end

	local size = folder:GetAttribute("Size")
	local parts2 = setProps(createVector(1, 1, 1))
	v3[folder] = {
		lastPivot = folder:GetPivot(),
		fakeBoat = clone,
		parts = parts2,
		size = size
	}

	if not size then
		local Global = require(game.ReplicatedStorage.Global)
		Global.TestGamePrint("Boat Size Attribute not loaded, now waiting.")
		folder:GetAttributeChangedSignal("Size"):Once(function()
			if v3[folder] then
				local Global2 = require(game.ReplicatedStorage.Global)
				Global2.TestGamePrint("Boat Size Attribute loaded.")
				v3[folder].size = folder:GetAttribute("Size")

				for _, v5 in pairs(parts2) do
					v5.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0)
				end
			end
		end)
	end
end

local function remove(p)
	if not v3[p] then
		return
	end

	pcall(function()
		v3[p].fakeBoat:Destroy()
	end)
	v3[p] = nil
end

workspace.Boats.ChildAdded:Connect(add)
workspace.Boats.ChildRemoved:Connect(remove)
task.spawn(function()
	for _, child in pairs(workspace.Boats:GetChildren()) do
		add(child)
	end
end)

local function addCharacter(model)
	if v2[model] then
		return
	end

	if model:IsA("Model") and model:WaitForChild("HumanoidRootPart", 15) and model:WaitForChild("Humanoid", 15) then
		local seatPartChangedConnection

		if model == game.Players.LocalPlayer.Character then
			v = false
			seatPartChangedConnection = model.Humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
				if not model.Humanoid.SeatPart then
					local lastTime = os.clock()

					while os.clock() - lastTime < 0.1 do
						model.HumanoidRootPart.Velocity *= createVector(0, 1, 0)
						local RunService = game:GetService("RunService")
						RunService.Stepped:Wait()
					end
				end
			end)
		end

		v2[model] = {
			root = model.HumanoidRootPart,
			humanoid = model.Humanoid,
			activeParts = nil,
			toggledCollisions = false,
			tasks = {},
			connection = seatPartChangedConnection,
			lastUpdate = os.clock()
		}
	end
end

workspace.Characters.ChildAdded:Connect(addCharacter)
workspace.Characters.ChildRemoved:Connect(function(child)
	if v2[child] then
		if v2[child].connection then
			v2[child].connection:Disconnect()
		end

		v2[child] = nil
	end
end)

for _, child in pairs(workspace.Characters:GetChildren()) do
	task.spawn(addCharacter, child)
end

local function event(p, p2, replicatedCFrame)
	local Global = require(game.ReplicatedStorage.Global)
	local encoded = Global.Encode(p)
	local Global2 = require(game.ReplicatedStorage.Global)
	local encoded2 = Global2.Encode(p2)

	if not v2[encoded] then
		return
	end

	local v4 = encoded2 == nil or replicatedCFrame == nil

	if v4 then
		table.clear(v2[encoded].tasks)
	else
		local v5 = math.random(1, 9999999)
		v2[encoded].tasks[v5] = true
		task.wait(0.2)

		if not (v2[encoded] and v2[encoded].tasks[v5]) then
			return
		end

		v2[encoded].tasks[v5] = nil
	end

	if v2[encoded] then
		if v4 then
			if v2[encoded].toggledCollisions then
				v2[encoded].toggledCollisions = nil

				for _, activePart in pairs(v2[encoded].activeParts) do
					activePart.CollisionGroup = "Players"
				end
			end

			v2[encoded].boat = nil
			v2[encoded].replicatedCFrame = nil
			v2[encoded].spring = nil
		else
			v2[encoded].boat = encoded2
			v2[encoded].replicatedCFrame = replicatedCFrame
		end

		v2[encoded].lastUpdate = os.clock()
	end
end

game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShipServiceEvent").OnClientEvent:Connect(event)
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(step)