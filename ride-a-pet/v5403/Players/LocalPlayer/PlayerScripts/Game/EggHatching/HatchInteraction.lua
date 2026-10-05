local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GameSettings = require(ReplicatedStorage2:WaitForChild("GameSettings"))
local localPlayer = Players.LocalPlayer
local General = require(ReplicatedStorage2.GameServices.General)
local General2 = require(ReplicatedStorage2.GameData.General)
local DayNight = require(ReplicatedStorage2.GameServices.DayNight)
local Eggs = require(ReplicatedStorage2.GameData.Eggs)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local character = nil
local HatchInteraction = {}
local object = setmetatable({}, {
	__mode = "k"
})

local function BlocksWorldInput(instance, playerGui)
	local parent = instance
	local v = false

	while parent and parent ~= playerGui do
		if parent:IsA("GuiObject") and not parent.Visible or parent:IsA("CanvasGroup") and parent.GroupTransparency >= 1 then
			return false
		end

		if parent:IsA("BillboardGui") or parent:IsA("SurfaceGui") then
			return false
		end

		if parent:IsA("ScreenGui") then
			if not parent.Enabled then
				return false
			end

			v = true
		end

		parent = parent.Parent
	end

	if not v then
		return false
	end

	if instance:IsA("GuiButton") or instance:IsA("TextBox") or instance.Active or instance.BackgroundTransparency < 1 then
		return true
	end

	if (instance:IsA("ImageLabel") or instance:IsA("ImageButton")) and instance.Image ~= "" and instance.ImageTransparency < 1 then
		return true
	end

	if (instance:IsA("TextLabel") or instance:IsA("TextButton")) and instance.Text ~= "" and instance.TextTransparency < 1 then
		return true
	end

	return instance:IsA("ViewportFrame")
end

function HatchInteraction.BlockedUI(p)
	if GamepadUI.UsingGamepad() and GamepadUI.GameplayBlocked() or (UserInputService:GetFocusedTextBox() or GuiService.MenuIsOpen) then
		return true
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return true
	end

	for _, v in ipairs(playerGui:GetGuiObjectsAtPosition(p.X, p.Y)) do
		if BlocksWorldInput(v, playerGui) then
			return true
		end
	end

	return false
end

function HatchInteraction.Position()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	if UserInputService:GetLastInputType().Name:find("Gamepad") then
		return currentCamera.ViewportSize / 2 + GuiService:GetGuiInset()
	end

	return HatchInteraction.TouchPosition or UserInputService:GetMouseLocation()
end

function HatchInteraction.Ready(model, p)
	local plot = General:GetPlot(localPlayer)

	if not plot or model.Parent ~= plot:FindFirstChild("Eggs") then
		return false
	end

	if not (model:IsA("Model") and model.PrimaryPart and model:GetAttribute("EggKey")) then
		return false
	end

	if not p and (model:HasTag("Hatching") or (object[model] or 0) > os.clock()) then
		return false
	end

	if localPlayer:GetAttribute("TutorialHatchLocked") == true then
		local tutorialLockedEggKey = localPlayer:GetAttribute("TutorialLockedEggKey")

		if tutorialLockedEggKey == nil or tutorialLockedEggKey == model:GetAttribute("EggKey") then
			return false
		end
	end

	local eggData = model:FindFirstChild("EggData")
	local placeTime = eggData and eggData:FindFirstChild("PlaceTime")
	local weight = eggData and eggData:FindFirstChild("Weight")
	local egg = Eggs[model.Name]

	if not egg or not placeTime or placeTime.Value <= 0 then
		return false
	end

	if (model:GetAttribute("FlatGrow") == true and workspace:GetServerTimeNow() - placeTime.Value or DayNight.GrowthElapsed(placeTime.Value)) < General2.GrowthTimeFor(
		egg.GrowthTime,
		weight and weight.Value or 1
	) then
		return false
	end

	local character2 = localPlayer.Character
	local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")
	local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")

	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		return false
	end

	local _, v = model:GetBoundingBox()
	return math.max(7, math.max(v.X, v.Y, v.Z) * 0.6 + 8) >= ((humanoidRootPart.Position - model.PrimaryPart.Position) * createVector(
		1,
		0,
		1
	)).Magnitude
end

function HatchInteraction.Target(p, p2)
	if GameSettings.DISABLETAPTOHATCH == true then
		return nil
	end

	local v = p or HatchInteraction.Position()
	local currentCamera = workspace.CurrentCamera

	if not v or not currentCamera or HatchInteraction.BlockedUI(v) then
		return nil
	end

	if character ~= localPlayer.Character then
		character = localPlayer.Character
		raycastParams.FilterDescendantsInstances = character and { character } or {}
	end

	local screenPointToRay = currentCamera:ScreenPointToRay(v.X, v.Y)
	local raycastResult = workspace:Raycast(screenPointToRay.Origin, screenPointToRay.Direction * 1000, raycastParams)

	if raycastResult then
		raycastResult = raycastResult.Instance
	end

	while raycastResult and raycastResult ~= workspace do
		if raycastResult:IsA("Model") and raycastResult:GetAttribute("EggKey") then
			return HatchInteraction.Ready(raycastResult, p2) and raycastResult or nil
		else
			raycastResult = raycastResult.Parent
		end
	end

	return nil
end

function HatchInteraction.Request(instance)
	if GameSettings.DISABLETAPTOHATCH == true then
		return false
	end

	if instance and HatchInteraction.Ready(instance) then
		object[instance] = os.clock() + 1
		ReplicatedStorage2.Remotes.Game.Hatch:FireServer({
			EggKey = instance:GetAttribute("EggKey")
		})
		return true
	else
		return false
	end
end

return HatchInteraction