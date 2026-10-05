local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local parent = workspace:FindFirstChild("RenderedHeldPets")

if not parent then
	parent = Instance.new("Folder")
	parent.Name = "RenderedHeldPets"
	parent.Parent = workspace
end

local v2 = {}

local function BuildRig(instance)
	local model = Instance.new("Model")
	model.Name = instance.Name

	for _, child in instance:GetChildren() do
		if not (child:IsA("BasePart") or child:IsA("AnimationController") or child.Name == "Animations" or child.Name == "Data") then
			continue
		end

		local clone = child:Clone()
		clone.Parent = model
	end

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("Humanoid") then
			descendant:Destroy()
		end
	end

	for _, part in model:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end

	model.PrimaryPart = model:FindFirstChild("RootPart") or model:FindFirstChild("Handle") or model:FindFirstChildWhichIsA(
		"BasePart",
		true
	)
	return model
end

local function LoadTracks(instance, p)
	local animationController = instance:FindFirstChildOfClass("AnimationController")
	local animations = instance:FindFirstChild("Animations")

	if not (animationController and animations) then
		return {}
	end

	local v3 = animationController:FindFirstChildOfClass("Animator")

	if not v3 then
		v3 = Instance.new("Animator")
		v3.Parent = animationController
	end

	local v4 = {}
	local idle = animations:FindFirstChild("Idle")

	if idle then
		v4.Idle = v3:LoadAnimation(idle)
		v4.Idle.Looped = true
	end

	local fly = p and animations:FindFirstChild("Fly") or animations:FindFirstChild("Run") or animations:FindFirstChild("Walk") or animations:FindFirstChild("Fly")

	if fly then
		v4.Move = v3:LoadAnimation(fly)
		v4.Move.Looped = true
	end

	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HideTool(p)
	local transparenciesByChild = {}
	local Recurse

	Recurse = function(instance)
		for _, child in instance:GetChildren() do
			if not (child.Name ~= "InitialPoses" and child.Name ~= "AnimSaves") then
				continue
			end

			if child:IsA("BasePart") or child:IsA("Decal") or child:IsA("Texture") then
				transparenciesByChild[child] = child.Transparency
				child.Transparency = 1
			end

			Recurse(child)
		end
	end

	Recurse(p)
	return transparenciesByChild
end

local function RestoreTool(items)
	for k, item in items do
		if k.Parent then
			k.Transparency = item
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Unequip(p)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v2[p] = nil

	if v3.Connection then
		v3.Connection:Disconnect()
	end

	if v3.Rig then
		v3.Rig:Destroy()
	end

	for k, transparency in v3.Hidden do
		if k.Parent then
			k.Transparency = transparency
		end
	end
end

local function Equip(instance, p)
	if v2[p] then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local rig = BuildRig(p)

	if not rig.PrimaryPart then
		rig:Destroy()
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local data = rig:FindFirstChild("Data")
	local isFlying = data and data:FindFirstChild("IsFlying")
	local v4

	if isFlying == nil then
		v4 = false
	else
		v4 = isFlying.Value == true
	end

	local hidden = HideTool(p) -- equivalent call inferred; original call site unknown
	rig.Parent = parent
	local boundingBox, v6 = rig:GetBoundingBox()
	local v7 = rig:GetPivot().Position.Y - (boundingBox.Position.Y - v6.Y / 2)
	local loadTracks = LoadTracks(rig, v4)

	if loadTracks.Idle then
		loadTracks.Idle:Play()
	end

	local v9 = false
	local flag = false
	local v10 = Players:GetPlayerFromCharacter(instance) == Players.LocalPlayer
	local v11 = humanoidRootPart.Position.Y - (humanoidRootPart.Size.Y / 2 + (not humanoid and 0 or humanoid.HipHeight or 0))
	v2[p] = {
		Rig = rig,
		Connection = RunService.RenderStepped:Connect(function()
			if not (humanoidRootPart.Parent and rig.Parent) then
				return
			end

			local cFrame = humanoidRootPart.CFrame
			local lookVector = cFrame.LookVector
			local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
			local v12 = not (vector2.Magnitude > 0.001) and createVector(0, 0, -1) or vector2.Unit
			local position = (CFrame.lookAlong(cFrame.Position, v12) * CFrame.new(3.5, 0, 0.5)).Position
			local v13 = cFrame.Position.Y - (humanoidRootPart.Size.Y / 2 + (humanoid and humanoid.HipHeight or 0))
			local v14

			if v4 then
				v14 = v13 + 5 + v7
			else
				if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
					v11 = v13
				end

				v14 = v11 + v7
			end

			rig:PivotTo(CFrame.lookAlong(Vector3.new(position.X, v14, position.Z), v12) * CFrame.Angles(0, 0, 0))

			if not v10 then
				local character = Players.LocalPlayer.Character
				local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					local magnitude = (humanoidRootPart2.Position - cFrame.Position).Magnitude

					if flag or not (magnitude > 500) then
						if flag and magnitude < 470 then
							flag = false
							v9 = nil
						end
					else
						flag = true

						for _, v15 in pairs(loadTracks) do
							if v15.IsPlaying then
								v15:Stop(0)
							end
						end
					end
				end

				if flag then
					return
				end
			end

			local magnitude = (humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude
			local v15 = magnitude > 1.5

			if v15 ~= v9 then
				v9 = v15

				if v9 then
					if loadTracks.Move then
						loadTracks.Move:Play(0.2)
					end

					if loadTracks.Idle then
						loadTracks.Idle:Stop(0.2)
					end
				else
					if loadTracks.Idle then
						loadTracks.Idle:Play(0.2)
					end

					if loadTracks.Move then
						loadTracks.Move:Stop(0.2)
					end
				end
			end

			if v9 and loadTracks.Move and loadTracks.Move.IsPlaying then
				loadTracks.Move:AdjustSpeed((math.clamp(magnitude / 16, 0.6, 2)))
			end
		end),
		Hidden = hidden
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsPetTool(tool)
	return tool:IsA("Tool") and CollectionService:HasTag(tool, "Pet")
end

local function WatchCharacter(character)
	character.ChildAdded:Connect(function(tool)
		if IsPetTool(tool) then
			task.defer(Equip, character, tool)
		end
	end)
	character.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") then
			Unequip(tool) -- equivalent call inferred; original call site unknown
		end
	end)
	local tool = character:FindFirstChildOfClass("Tool")

	if tool and IsPetTool(tool) then
		task.defer(Equip, character, tool)
	end
end

local function WatchPlayer(player)
	player.CharacterAdded:Connect(WatchCharacter)

	if player.Character then
		WatchCharacter(player.Character)
	end

	player.CharacterRemoving:Connect(function(_)
		for k, v3 in v2 do
			if not v3.Rig or k.Parent then
				continue
			end

			Unequip(k) -- equivalent call inferred; original call site unknown
		end
	end)
end

Players.PlayerAdded:Connect(WatchPlayer)

for _, v3 in Players:GetPlayers() do
	v3.CharacterAdded:Connect(WatchCharacter)

	if v3.Character then
		WatchCharacter(v3.Character)
	end

	v3.CharacterRemoving:Connect(function(_)
		for k, v4 in v2 do
			if not v4.Rig or k.Parent then
				continue
			end

			Unequip(k) -- equivalent call inferred; original call site unknown
		end
	end)
end