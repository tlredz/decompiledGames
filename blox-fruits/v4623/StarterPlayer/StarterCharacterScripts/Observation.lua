local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local humanoid = character:WaitForChild("Humanoid")
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local disableKen = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DisableKen")
local visionRadius = localPlayer:WaitForChild("VisionRadius")
local ObservationManager = require(game.ReplicatedStorage.ObservationManager)
local Anims = require(game.ReplicatedStorage.Util.Anims)
local OM = ObservationManager.new(game.Players.LocalPlayer)
local Global = require(game.ReplicatedStorage.Global)
Global.OM = OM
humanoid.Died:Connect(function()
	OM:destroy()
end)
local now = 0
local Global2 = require(game.ReplicatedStorage.Global)

if Global2.connection then
	local Global3 = require(game.ReplicatedStorage.Global)
	Global3.connection:Disconnect()
end

local Global3 = require(game.ReplicatedStorage.Global)
Global3.connection = disableKen.OnClientEvent:Connect(function()
	now = tick() + 5
	OM:setActive(false)
	OM.radius = 0
	local contextButton = MobileUIController:GetContextButton("BoundActionKen")

	if contextButton then
		contextButton:SetAttribute("Selected", false)
	end
end)

local function handleAction(p, p2, p3)
	if not OM.active and character:FindFirstChild("KenDisabled") then
		return
	end

	if p2 == Enum.UserInputState.Begin and p3.UserInputState == Enum.UserInputState.Begin and humanoid.Health > 0 and tick() - now > 0.4 then
		now = tick()
		OM.radius = 0
		OM:setActive(not OM.active)
		game.ReplicatedStorage.Remotes.CommE:FireServer("Ken", OM.active)
		local contextButton = MobileUIController:GetContextButton(p)

		if contextButton then
			contextButton:SetAttribute("Selected", OM.active)
		end
	end
end

MobileUIController:UnbindContextButton("BoundActionKen")
ContextActionService:UnbindAction("BoundActionKen")

local function refreshDodgeInfo()
	local kenMaxDodges = localPlayer:GetAttribute("KenMaxDodges") or 8
	local kenDodgesLeft = localPlayer:GetAttribute("KenDodgesLeft") or kenMaxDodges
	local contextButton = MobileUIController:GetContextButton("BoundActionKen")
	local dodgesLeftLabel = contextButton and contextButton:FindFirstChild("DodgesLeftLabel")

	if dodgesLeftLabel then
		dodgesLeftLabel.Text = string.format("%s/%s", kenDodgesLeft, kenMaxDodges)
		dodgesLeftLabel.TextLabel.Text = dodgesLeftLabel.Text
		dodgesLeftLabel.Visible = OM.active
	end
end

local connection = nil

local function instanceAdded(character2)
	if character2 == character then
		if connection then
			connection:Disconnect()
			connection = nil
		end

		for i = 1, 2 do
			Anims:Preload("Instinct" .. i .. "_" .. 1)
			Anims:Preload("Instinct" .. i .. "_" .. 2)
			Anims:Preload("Instinct" .. i .. "_" .. 3)
		end

		local contextButton = MobileUIController:CreateContextButton(
			"BoundActionKen",
			handleAction,
			Enum.KeyCode.DPadLeft,
			Enum.KeyCode.E
		)

		if contextButton then
			if contextButton:FindFirstChild("DodgesLeftLabel") then
				refreshDodgeInfo()
				localPlayer:GetAttributeChangedSignal("KenDodgesLeft"):Connect(refreshDodgeInfo)
				localPlayer:GetAttributeChangedSignal("KenMaxDodges"):Connect(refreshDodgeInfo)
				contextButton:GetAttributeChangedSignal("Selected"):Connect(refreshDodgeInfo)
			end
		else
			ContextActionService:BindAction(
				"BoundActionKen",
				handleAction,
				false,
				Enum.KeyCode.DPadLeft,
				Enum.KeyCode.E
			)
		end
	end
end

if character:HasTag("Ken") then
	instanceAdded(character)
else
	connection = CollectionService:GetInstanceAddedSignal("Ken"):Connect(instanceAdded)
end

function game.ReplicatedStorage.Events.IsObservationActive.OnInvoke()
	return OM.active
end

while task.wait(0.3) and humanoid.Health > 0 and character:IsDescendantOf(workspace) do
	OM.radius = math.clamp(OM.radius + visionRadius.Value * 0.2, 0, visionRadius.Value)
	OM:refresh()

	if OM.active and character:FindFirstChild("KenDisabled") then
		OM:setActive(false)
	end
end

OM:destroy()