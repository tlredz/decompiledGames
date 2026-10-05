local createVector = vector.create
local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return {}
end

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService2 = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local Signal = require(packages.Signal)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("CharacterService/ResetCharacter")
local ControlModule

if RunService2:IsClient() then
	if ServerAuthority.isEnabled() then
		local StarterPlayer = game:GetService("StarterPlayer")
		ControlModule = require(StarterPlayer:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	else
		local PlayerModule = require(localPlayer.PlayerScripts:WaitForChild("PlayerModule"))
		ControlModule = PlayerModule:GetControls()
	end
end

local CharacterController = {
	OnCharacterAdded = Signal.new(),
	OnSetCFrame = Signal.new(),
	originalMoveFunction = ControlModule and ControlModule.moveFunction
}
local inverseControls = localPlayer:GetAttribute("InverseControls")
localPlayer:GetAttributeChangedSignal("InverseControls"):Connect(function()
	inverseControls = localPlayer:GetAttribute("InverseControls")
end)

if ControlModule then
	function ControlModule.moveFunction(p, p2, p3)
		if inverseControls then
			p2 = -p2
		end

		CharacterController:RequestMove(p, p2, p3)
	end

	CharacterController.originalMoveFunction = ControlModule.moveFunction
end

CharacterController.Controls = ControlModule

function CharacterController:RequestMove(instance, vector2: Vector3, flag: boolean)
	if instance:GetAttribute("FreezeLocalMovement") then
		instance:Move(createVector(0, 0, 0), false)
	else
		instance:Move(vector2, flag)
	end
end

function CharacterController.WaitForCharacter(_, p)
	local character = nil
	local v = nil
	local v2 = nil

	while not character do
		character, v, v2 = CharacterController:GetCharacter(p)
		task.wait()
	end

	return character, v, v2
end

function CharacterController:GetCharacter(p)
	local character = (p or localPlayer).Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return character, humanoid, humanoidRootPart
	end
end

function CharacterController.SetCFrame(_, cFrame: CFrame)
	local character, _, v = CharacterController:GetCharacter()

	if not character then
		return
	end

	v.CFrame = cFrame
	CharacterController.OnSetCFrame:Fire(cFrame)
end

function CharacterController.Start(_)
	local hipHeight = 2.08

	if ServerAuthority.isEnabled() then
		local bindableEvent = Instance.new("BindableEvent")
		bindableEvent.Event:Connect(function()
			remoteEvent:FireServer()
		end)
		task.spawn(function()
			while not pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", bindableEvent) do
				task.wait()
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setDeathRagdollPrediction(instance)
			if instance:IsA("BasePart") or instance:IsA("Constraint") then
				RunService2:SetPredictionMode(instance, Enum.PredictionMode.Off)
			end
		end

		local function configureCharacterPrediction(p, instance)
			local humanoid = instance:WaitForChild("Humanoid", 10)
			local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 10)

			if not (humanoid and humanoid:IsA("Humanoid") and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				return
			end

			if p ~= localPlayer then
				RunService2:SetPredictionMode(humanoidRootPart, Enum.PredictionMode.On)
			end

			local v = false
			instance.DescendantAdded:Connect(function(descendant)
				if v and (descendant:IsA("BasePart") or descendant:IsA("Constraint")) then
					RunService2:SetPredictionMode(descendant, Enum.PredictionMode.Off)
				end
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function disableDeathRagdollPrediction()
				v = true

				for _, v2 in instance:QueryDescendants("BasePart, Constraint") do
					setDeathRagdollPrediction(v2) -- equivalent call inferred; original call site unknown
				end
			end

			humanoid.Died:Connect(disableDeathRagdollPrediction)

			if humanoid.Health <= 0 then
				disableDeathRagdollPrediction() -- equivalent call inferred; original call site unknown
			end
		end

		local function onPlayerAdded(player)
			player.CharacterAdded:Connect(function(character)
				task.spawn(configureCharacterPrediction, player, character)
			end)

			if player.Character then
				task.spawn(configureCharacterPrediction, player, player.Character)
			end
		end

		Players.PlayerAdded:Connect(onPlayerAdded)

		for _, v in Players:GetPlayers() do
			task.spawn(onPlayerAdded, v)
		end

		local function SetTaggedConstraintPrediction(instance)
			local character = localPlayer.Character

			if not character then
				return
			end

			local v = false

			if instance:IsA("Constraint") then
				v = (instance.Attachment0 and instance.Attachment0:IsDescendantOf(character)) == true or (instance.Attachment1 and instance.Attachment1:IsDescendantOf(character)) == true
			elseif instance:IsA("NoCollisionConstraint") then
				v = (instance.Part0 and instance.Part0:IsDescendantOf(character)) == true or (instance.Part1 and instance.Part1:IsDescendantOf(character)) == true
			end

			if v then
				RunService2:SetPredictionMode(instance, Enum.PredictionMode.On)
			end
		end

		CollectionService:GetInstanceAddedSignal("ServerAuthorityPredicted"):Connect(SetTaggedConstraintPrediction)

		for _, v in ipairs(CollectionService:GetTagged("ServerAuthorityPredicted")) do
			SetTaggedConstraintPrediction(v)
		end
	end

	local function onCharacterAdded(instance)
		workspace.Gravity = 196.2
		CharacterController.OnCharacterAdded:Fire(instance)
		local humanoid = instance:WaitForChild("Humanoid")

		if not humanoid then
			return
		end

		hipHeight = humanoid.HipHeight

		if ServerAuthority.isEnabled() then
			local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 10)

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				-- equivalent calls inferred from this helper; original call sites unknown
				local function SetConstraintPrediction(child)
					if child:IsA("Constraint") or child:IsA("NoCollisionConstraint") then
						RunService2:SetPredictionMode(child, Enum.PredictionMode.On)
					end
				end

				humanoidRootPart.ChildAdded:Connect(SetConstraintPrediction)

				for _, child in ipairs(humanoidRootPart:GetChildren()) do
					SetConstraintPrediction(child) -- equivalent call inferred; original call site unknown
				end
			end
		else
			local v = 0
			humanoid.StateChanged:Connect(function(p, p2)
				if humanoid.Health <= 0 or ReplicatedStorage:GetAttribute("EggrotHuntEvent") or ServerData.IsJumpLTMServer() then
					return
				end

				if p == Enum.HumanoidStateType.Jumping and p2 == Enum.HumanoidStateType.Jumping or p == Enum.HumanoidStateType.Freefall and p2 == Enum.HumanoidStateType.Jumping then
					v += 1
					task.delay(60, function()
						v -= 1
					end)
					local extraJumps = localPlayer:GetAttribute("ExtraJumps") or 0
					local v2 = v

					if 5 + extraJumps <= v2 then
						humanoid.Health = 0
					end
				end
			end)
		end
	end

	localPlayer.CharacterAdded:Connect(onCharacterAdded)

	if localPlayer.Character then
		task.spawn(onCharacterAdded, localPlayer.Character)
	end

	RunService2.PreSimulation:Connect(function(_: number)
		debug.profilebegin("CharacterController")
		local character, v, _ = CharacterController:GetCharacter()

		if character and v then
			v.HipHeight = character:GetAttribute("NewHipHeight") or hipHeight
		end

		debug.profileend()
	end)
end

return CharacterController