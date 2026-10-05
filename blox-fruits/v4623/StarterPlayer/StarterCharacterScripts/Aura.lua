local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local character = game.Players.LocalPlayer.Character
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)

local function handleAction(_, p, p2)
	if p == Enum.UserInputState.Begin and p2.UserInputState == Enum.UserInputState.Begin and character:HasTag("Buso") then
		game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
	end
end

MobileUIController:UnbindContextButton("BoundActionBuso")
ContextActionService:UnbindAction("BoundActionBuso")
local connection = nil

local function instanceAdded(character2)
	if character2 == character then
		if connection then
			connection:Disconnect()
			connection = nil
		end

		if MobileUIController:CreateContextButton(
			"BoundActionBuso",
			handleAction,
			Enum.KeyCode.J,
			Enum.KeyCode.DPadDown
		) then
			return
		else
			ContextActionService:BindAction(
				"BoundActionBuso",
				handleAction,
				false,
				Enum.KeyCode.J,
				Enum.KeyCode.DPadDown
			)
		end
	end
end

if character:HasTag("Buso") then
	instanceAdded(character)
else
	connection = CollectionService:GetInstanceAddedSignal("Buso"):Connect(instanceAdded)
end

local function reflectHasAura()
	local v = character:FindFirstChild("HasBuso") ~= nil
	local contextButton = MobileUIController:GetContextButton("BoundActionBuso")

	if contextButton then
		contextButton:SetAttribute("Selected", v)
	end
end

character.ChildRemoved:Connect(reflectHasAura)
character.ChildAdded:Connect(reflectHasAura)