local ContextActionService = game:GetService("ContextActionService")
game:GetService("UserInputService")
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character

repeat
	task.wait(0.1)
until character:FindFirstChild("CharacterReady")

local function handleAction(_, p, p2)
	if p == Enum.UserInputState.Begin and p2.UserInputState == Enum.UserInputState.Begin then
		local Global = require(game.ReplicatedStorage.Global)
		local setRunning = Global.SetRunning
		local Global2 = require(game.ReplicatedStorage.Global)
		setRunning(not Global2.Running)
	end
end

ContextActionService:UnbindAction("BoundActionRun")
ContextActionService:BindAction("BoundActionRun", handleAction, false, Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonL3)
MobileUIController:UnbindContextButton("BoundActionRun")
local contextButton = MobileUIController:CreateContextButton("BoundActionRun", handleAction)
local vector = Vector2.new(428, 0)
local vector2 = Vector2.new(535, 0)
local v = true
AttributeCounter.connect(localPlayer, "FORCED_WALKING_STATE", function(_)
	local Global = require(game.ReplicatedStorage.Global)
	Global.SetRunning(v)
end)
local Global = require(game.ReplicatedStorage.Global)

function Global.SetRunning(running)
	v = running

	if AttributeCounter.get(localPlayer, "FORCED_WALKING_STATE") > 0 then
		running = false
	end

	local Global2 = require(game.ReplicatedStorage.Global)
	Global2.Running = running

	if contextButton then
		contextButton.Button.Icon.ImageRectOffset = running and vector or vector2
	end
end

local Global2 = require(game.ReplicatedStorage.Global)
Global2.SetRunning(true)