local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ships = workspace:WaitForChild("Ships")
local parent = workspace:FindFirstChild("PhysicInstances")

if not parent then
	parent = Instance.new("Folder")
	parent.Name = "PhysicInstances"
	parent.Parent = workspace
end

local localPlayer = Players.LocalPlayer
local _ = workspace.CurrentCamera
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local v2 = {}
local v3 = {}
local v4 = {}
local connectionsByInstance = {}
local v5 = { Enum.HumanoidStateType.Seated }
local physicReplication = ReplicatedStorage:WaitForChild("Chest").Remotes.Events.PhysicReplication
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules")
require(ReplicatedStorage.Chest.Modules.HighlightModule)

function SetPlayersCollision(collisionGroup)
	for _, v6 in pairs(Players:GetPlayers()) do
		local _ = v6 == localPlayer
		local character2 = v6.Character

		if not character2 then
			continue
		end

		for _, part in pairs(character2:GetChildren()) do
			if part:IsA("BasePart") then
				part.CollisionGroup = collisionGroup
			end
		end
	end
end

function SetEnabledPrompt(enabled)
	for _, proximityPrompt in pairs(ships:GetDescendants()) do
		if proximityPrompt:IsA("ProximityPrompt") then
			proximityPrompt.Enabled = enabled
		end
	end
end

function SetupHumanoidState()
	for _, connection in pairs(v3) do
		connection:Disconnect()
	end

	table.clear(v3)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	humanoid.StateChanged:Connect(function(p, p2)
		if p == Enum.HumanoidStateType.Seated then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			SetPlayersCollision("Player")
			SetEnabledPrompt(true)
		else
			if p2 ~= Enum.HumanoidStateType.Seated then
				return
			end

			SetPlayersCollision("ShipPhysic")
			SetEnabledPrompt(false)
		end
	end)
end

SetupHumanoidState()
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	SetupHumanoidState()
end)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Island") }

function IsOnIsland()
	if workspace:Raycast(humanoidRootPart.Position, createVector(0, -99, 0), raycastParams) then
		return true
	end
end

function CreatePhysicHitbox()
	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Name = HttpService:GenerateGUID(false)
	part.Parent = parent
	return part
end

function AddShipPhysic(instance)
	if not (instance and instance:IsDescendantOf(ships)) or v4[instance] or not instance.PrimaryPart then
		return
	end

	local v6 = CreatePhysicHitbox()
	v6.Size = instance:GetAttribute("PhysicSize") or instance:GetExtentsSize()
	v6.CFrame = instance.PrimaryPart.CFrame
	v4[instance] = v6
	CollectionService:AddTag(v6, "Physic")

	if connectionsByInstance[instance] then
		return true
	end

	local connections = {}
	connectionsByInstance[instance] = connections
	local shipHealth = instance:WaitForChild("ShipHealth", 6)
	local healthBoard = instance:WaitForChild("HealthBoard", 6)

	if shipHealth and healthBoard then
		local function UpdateHealthBoard()
			local value = shipHealth.Health.Value
			local value2 = shipHealth.MaxHealth.Value
			local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
			local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
			local v7 = {
				Size = UDim2.new(math.clamp(value / value2, 0, 1), 0, 1, 0)
			}
			TweenService:Create(healthBoard.Frame.Frame, tweenInfo, v7):Play()
			TweenService:Create(healthBoard.Frame.UnderFrame, tweenInfo2, v7):Play()
			local v8 = math.floor(value)
			local v9 = math.floor(value2)

			if v8 and v8 > 0 then
				healthBoard.Frame.HealthText.Text = v8 .. "/" .. v9
			else
				healthBoard.Frame.HealthText.Text = "Destroyed"
			end
		end

		UpdateHealthBoard()
		table.insert(connections, shipHealth.Health:GetPropertyChangedSignal("Value"):Connect(function()
			UpdateHealthBoard()
		end))
	end

	return true
end

function RemoveShipPhysic(p)
	if not v4[p] then
		return
	end

	local v6 = v4[p]

	if v6 then
		CollectionService:RemoveTag(v6, "Physic")

		if v2[v6] then
			v2[v6] = nil
		end
	end

	v4[p]:Destroy()
	v4[p] = nil
end

ships.ChildAdded:Connect(function(child)
	wait()
	local v6 = AddShipPhysic(child)

	if not v6 then
		local v7 = 3

		while v7 > 0 and not v6 do
			task.wait(1)
			v6 = AddShipPhysic(child)
			v7 -= 1
		end
	end
end)
ships.ChildRemoved:Connect(function(child)
	wait()
	RemoveShipPhysic(child)
end)
local v6 = {}

for _, model in pairs(ships:GetChildren()) do
	if model:IsA("Model") then
		AddShipPhysic(model)
	end
end

function UpdatePhysicsHitbox()
	for model, v7 in pairs(v4) do
		if model:IsA("Model") and model.PrimaryPart then
			v7.CFrame = model.PrimaryPart.CFrame
		end
	end
end

function UpdatePhysicsCFrames()
	for model, v7 in pairs(v4) do
		if model:IsA("Model") and model.PrimaryPart then
			v2[v7] = v7.CFrame
		end
	end
end

function IsInPhysicPart()
	local tagged = CollectionService:GetTagged("Physic")

	for _, part in pairs(tagged) do
		if not part:IsA("BasePart") then
			continue
		end

		local abs = (part.CFrame:Inverse() * humanoidRootPart.Position):Abs()

		if abs.X < part.Size.X / 2 and abs.Y < part.Size.Y / 2 and abs.Z < part.Size.Z / 2 then
			return part
		end
	end
end

function GetPhysicPartOwner(p)
	for k, v7 in pairs(v4) do
		if v7 == p then
			return k
		end
	end
end

local lastTime = os.clock()

function UpdateCharacterPhysics()
	local v7 = IsInPhysicPart()

	if v7 and not (table.find(v5, humanoid:GetState()) or IsOnIsland()) then
		local cFrame = v7.CFrame
		local cframe = v2[v7] or cFrame
		local objectSpace = cFrame:Inverse():ToObjectSpace(cframe:Inverse())
		humanoidRootPart.CFrame = objectSpace * humanoidRootPart.CFrame

		if not humanoidRootPart:FindFirstChild("DashBV") and (humanoidRootPart.AssemblyLinearVelocity * createVector(
			1,
			0,
			1
		)).Magnitude > humanoid.WalkSpeed * 1.99 then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		end

		local physicPart = GetPhysicPartOwner(v7)

		if physicPart then
			physicReplication:FireServer({
				PhysicPart = physicPart,
				ObjectSpace = humanoidRootPart.CFrame:ToObjectSpace(cFrame)
			})
		end
	elseif not v7 and os.clock() - lastTime > 0.1 and not character:GetAttribute("OutPhysic") then
		lastTime = os.clock()
		physicReplication:FireServer(nil)
	end

	for k, v8 in pairs(v6) do
		if k:IsDescendantOf(Players) then
			local character2 = k.Character

			if character2 then
				local humanoid2 = character2:FindFirstChild("Humanoid")
				local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

				if humanoid2 and humanoidRootPart2 and v8 then
					local physicPart = v8.PhysicPart
					local objectSpace = v8.ObjectSpace

					if physicPart then
						local v9 = v4[physicPart]

						if v9 and not table.find(v5, humanoid2:GetState()) then
							humanoidRootPart2.CFrame = v9.CFrame * objectSpace:Inverse()
						end
					end
				end
			end
		else
			v6[k] = nil
		end
	end

	UpdatePhysicsCFrames()
end

RunService:BindToRenderStep("PhysicRenderer", Enum.RenderPriority.Camera.Value - 1, function()
	UpdatePhysicsHitbox()
	UpdateCharacterPhysics()
end)
physicReplication.OnClientEvent:Connect(function(p, p2)
	if p == localPlayer then
		return
	end

	v6[p] = p2
end)
Players.PlayerRemoving:Connect(function(player)
	v6[player] = nil
end)