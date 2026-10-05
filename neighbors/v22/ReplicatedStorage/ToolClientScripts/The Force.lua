local TheForce = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
require(ReplicatedStorage.Modules.Tool)
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local v = { "House Barrier", "Baseplate", "House Barrier [Roof]" }

local function performRaycast(player, handPosition: Vector3, position: Vector3)
	local v2 = (position - handPosition).Unit * 300
	local raycastResult = workspace:Raycast(handPosition, v2, player.RaycastParams)
	local isTransparent = false
	local instance, model

	if raycastResult then
		position = raycastResult.Position
		instance = raycastResult.Instance
		isTransparent = instance:IsA("BasePart") and instance.Transparency >= 0.9 and not table.find(v, instance.Name) and true or false
		model = instance:FindFirstAncestorOfClass("Model")

		if not (model and model:FindFirstChildOfClass("Humanoid")) then
			model = nil
		end
	end

	return {
		hitPosition = position,
		hitPart = instance,
		hitCharacterName = model and model.Name or nil,
		isTransparent = isTransparent
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHandPosition(character)
	local rightHand = character:FindFirstChild("RightHand")

	if rightHand then
		return rightHand.Position
	end

	return nil
end

local function updateMouse(player)
	if not player.IsToolActive or player.Tool.Parent ~= localPlayer.Character or not (mouse.Hit and mouse.Hit.Position) then
		return
	end

	local position = mouse.Hit.Position
	local v2 = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or player.Touching

	if not player.LastSentPosition or (position - player.LastSentPosition).Magnitude > 0.3 then
		if player.LastSentPosition then
			local v3 = position - player.LastSentPosition
			local v4 = math.clamp(v3.Magnitude, 0, 300)
			position = player.LastSentPosition + v3.Unit * v4
		end

		local handPosition = getHandPosition(player.Character) -- equivalent call inferred; original call site unknown

		if handPosition then
			player:FireEvent("UpdateMouse", position, v2, (performRaycast(player, handPosition, position)))
		else
			player:FireEvent("UpdateMouse", position, v2)
		end

		player.LastSentPosition = position
	end
end

local function onMouseDown(player)
	if not player.IsToolActive or player.Tool.Parent ~= localPlayer.Character then
		return
	end

	player.IsMousePressed = true

	if not mouse.Hit or not mouse.Hit.Position or os.clock() - player.LastMousePress <= 1 then
		return
	end

	player.LastMousePress = os.clock()
	local handPosition = getHandPosition(player.Character) -- equivalent call inferred; original call site unknown

	if handPosition then
		local v2 = performRaycast(player, handPosition, mouse.Hit.Position)
		player:FireEvent("UpdateMouse", mouse.Hit.Position, true, v2)
	else
		player:FireEvent("UpdateMouse", mouse.Hit.Position, true)
	end

	player.LastSentPosition = mouse.Hit.Position
end

local function onMouseUp(player)
	if not player.IsToolActive or player.Tool.Parent ~= localPlayer.Character then
		return
	end

	player.IsMousePressed = false

	if not (mouse.Hit and mouse.Hit.Position) then
		return
	end

	local handPosition = getHandPosition(player.Character) -- equivalent call inferred; original call site unknown

	if handPosition then
		local v2 = performRaycast(player, handPosition, mouse.Hit.Position)
		player:FireEvent("UpdateMouse", mouse.Hit.Position, false, v2)
	else
		player:FireEvent("UpdateMouse", mouse.Hit.Position, false)
	end

	player.LastSentPosition = mouse.Hit.Position
end

function TheForce:Initialize()
	self.IsToolActive = false
	self.IsMousePressed = false
	self.Touching = false
	self.LastMousePress = 0
	self.RaycastParams = RaycastParams.new()
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self.Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
end

function TheForce:Equipped()
	self.IsToolActive = true
	self.Character = localPlayer.Character or self.Character

	if self.ActiveJanitor then
		self.ActiveJanitor:Destroy()
	end

	self.ActiveJanitor = Janitor.new()
	local activeJanitor = self.ActiveJanitor
	self.RaycastParams.FilterDescendantsInstances = { self.Character, workspace.Terrain }
	activeJanitor:Add(localPlayer.CharacterAdded:Connect(function(character)
		self.Character = character
		self.RaycastParams.FilterDescendantsInstances = { character, workspace.Terrain }
	end))
	activeJanitor:Add(RunService.Heartbeat:Connect(function()
		updateMouse(self)
	end))
	activeJanitor:Add(mouse.Button1Down:Connect(function()
		onMouseDown(self)
	end))
	activeJanitor:Add(mouse.Button1Up:Connect(function()
		onMouseUp(self)
	end))
	activeJanitor:Add(UserInputService.TouchStarted:Connect(function()
		self.Touching = true
	end))
	activeJanitor:Add(UserInputService.TouchEnded:Connect(function()
		self.Touching = false
	end))
end

function TheForce:Unequipped()
	self.IsToolActive = false
	self.IsMousePressed = false
	self.LastSentPosition = nil

	if self.ActiveJanitor then
		self.ActiveJanitor:Destroy()
		self.ActiveJanitor = nil
	end
end

function TheForce:Destroyed()
	self:Unequipped()
end

return TheForce