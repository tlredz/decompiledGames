local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("ContextActionService")
local General = require(ReplicatedStorage2:WaitForChild("GameServices"):WaitForChild("General"))
local PetRenderer = require(script.Parent:WaitForChild("PetRenderer"))
local placePet = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("PlacePet")
local localPlayer = Players.LocalPlayer
local SoundService = game:GetService("SoundService")
local SFX = SoundService:WaitForChild("SFX")
local v = 0
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMessage(p)
	pcall(function()
		local Handler = require(localPlayer.PlayerGui.Reusable.GameMessages.Handler)
		Handler:AddMessage(p)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OpenPetsTracker()
	pcall(function()
		local petsTracker = localPlayer.PlayerGui.Main.PetsTracker

		if petsTracker:GetAttribute("Open") ~= true then
			petsTracker.OpenRequest:Fire()
		end
	end)
end

local function IsOnOwnPlot()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local plot = General:GetPlot(localPlayer)
	local baseplate = plot and plot:FindFirstChild("Baseplate")

	if not (humanoidRootPart and baseplate) then
		return false
	end

	local pointToObjectSpace = baseplate.CFrame:PointToObjectSpace(humanoidRootPart.Position)
	return math.abs(pointToObjectSpace.X) <= baseplate.Size.X / 2 and math.abs(pointToObjectSpace.Z) <= baseplate.Size.Z / 2
end

local function TryPlace(tool)
	if GamepadUI.UsingGamepad() and GamepadUI.GameplayBlocked() or localPlayer:GetAttribute("TutorialPlaceLocked") == true then
		return
	end

	local now = os.clock()

	if now - v < 0.4 or (not tool.Parent or tool.Parent ~= localPlayer.Character) then
		return
	end

	local petKey = tool:GetAttribute("PetKey")

	if not (petKey and IsOnOwnPlot()) then
		return
	end

	local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local maxPets = localPlayer:GetAttribute("MaxPets") or 5
	local count = 0

	for _, v3 in pairs(PetRenderer.GetAll()) do
		if v3.OwnerUserId == localPlayer.UserId and v3.Model.Parent then
			count += 1
		end
	end

	if maxPets <= count then
		SFX.Error:Play()
		ShowMessage(string.format("Max %d/%d On Ranch", maxPets, maxPets)) -- equivalent call inferred; original call site unknown
	else
		v = now
		local position = (humanoidRootPart.CFrame * CFrame.new(0, 0, -5)).Position
		v2[petKey] = true
		PetRenderer.Build({
			OwnerUserId = localPlayer.UserId,
			PetKey = petKey,
			PetName = tool:GetAttribute("PetName") or tool.Name,
			Weight = tool:GetAttribute("Weight") or 1,
			Age = tool:GetAttribute("Age") or 1,
			Mutation = tool:GetAttribute("Mutation"),
			SpawnMutation = tool:GetAttribute("SpawnMutation"),
			Position = position,
			CollectTime = workspace:GetServerTimeNow(),
			Effects = true
		})
		placePet:FireServer(petKey, position)
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid:UnequipTools()
		end

		OpenPetsTracker() -- equivalent call inferred; original call site unknown
		task.delay(3, function()
			if v2[petKey] then
				v2[petKey] = nil
				PetRenderer.Remove(localPlayer.UserId, petKey)
			end
		end)
	end
end

local function HookTool(tool)
	if not (tool:IsA("Tool") and tool:HasTag("Pet")) or tool:GetAttribute("PlaceHooked") then
		return
	end

	tool:SetAttribute("PlaceHooked", true)
	tool.Activated:Connect(function()
		TryPlace(tool)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HookCharacter(character)
	character.ChildAdded:Connect(HookTool)

	for _, child in character:GetChildren() do
		HookTool(child)
	end
end

localPlayer.CharacterAdded:Connect(HookCharacter)

if localPlayer.Character then
	HookCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

placePet.OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" then
		return
	end

	if data.Action == "Place" then
		local owner = data.Owner
		local userId = typeof(owner) == "Instance" and owner.UserId or tonumber(owner)

		if not userId or typeof(data.PetKey) ~= "string" then
			return
		end

		local v3

		if userId == localPlayer.UserId then
			v3 = v2[data.PetKey]
		else
			v3 = false
		end

		if v3 then
			v2[data.PetKey] = nil
			local v4 = PetRenderer.Get(userId, data.PetKey)

			if v4 then
				v4.BirthTime = tonumber(data.BirthTime) or v4.BirthTime
				v4.BaseWeight = tonumber(data.BaseWeight) or v4.BaseWeight
			end
		end

		PetRenderer.Build({
			OwnerUserId = userId,
			PetKey = data.PetKey,
			PetName = data.PetName,
			Weight = data.Weight,
			Age = data.Age,
			Position = data.Position,
			CollectTime = data.CollectTime,
			BirthTime = data.BirthTime,
			BaseWeight = data.BaseWeight,
			Mutation = data.Mutation,
			SpawnMutation = data.SpawnMutation,
			Effects = data.Effects and not v3
		})
	elseif data.Action == "Remove" then
		local owner = tonumber(data.Owner)

		if not owner then
			return
		end

		if typeof(data.PetKey) == "string" then
			PetRenderer.Remove(owner, data.PetKey)
		else
			PetRenderer.RemoveAllFrom(owner)
		end
	end
end)