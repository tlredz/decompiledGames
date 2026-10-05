local ContextActionService = game:GetService("ContextActionService")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local humanoid = character:WaitForChild("Humanoid")
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)

local function find()
	for _, childName in {
		"Last Resort",
		"Agility",
		"Water Body",
		"Heavenly Blood",
		"Heightened Senses",
		"Energy Core",
		"Primordial Reign"
	} do
		if localPlayer.Backpack:FindFirstChild(childName) or character:FindFirstChild(childName) then
			return true
		end
	end
end

if not find() then
	repeat
		localPlayer.Backpack.ChildAdded:Wait()
	until find()
end

local function handleAction(_, p, p2)
	if p == Enum.UserInputState.Begin and p2.UserInputState == Enum.UserInputState.Begin and humanoid.Health > 0 then
		game.ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
	end
end

MobileUIController:UnbindContextButton("BoundActionRaceAbility")
ContextActionService:UnbindAction("BoundActionRaceAbility")
local contextButton = MobileUIController:CreateContextButton(
	"BoundActionRaceAbility",
	handleAction,
	Enum.KeyCode.T,
	Enum.KeyCode.DPadUp
)

if contextButton then
	contextButton:SetAttribute("NonToolButton", true)
else
	ContextActionService:BindAction("BoundActionRaceAbility", handleAction, false, Enum.KeyCode.T, Enum.KeyCode.DPadUp)
end