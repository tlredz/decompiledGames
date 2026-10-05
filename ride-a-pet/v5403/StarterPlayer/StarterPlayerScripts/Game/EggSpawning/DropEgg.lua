local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ContextActionService = game:GetService("ContextActionService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage2:WaitForChild("packages")
local Observers = require(packages:WaitForChild("Observers"))
local Net = require(packages:WaitForChild("Net"))
local Volcano = require(ReplicatedStorage2:WaitForChild("GameData"):WaitForChild("Volcano"))
local basketDrop = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("BasketDrop")
assert(basketDrop:IsA("RemoteEvent"), "BasketDrop must be a RemoteEvent")
local remoteEvent = Net:RemoteEvent("VolcanoDip")
local basket = localPlayer:WaitForChild("Basket")
local pop = SoundService:WaitForChild("SFX"):WaitForChild("Pop")
assert(pop:IsA("Sound"), "SFX.Pop must be a Sound")
local main = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
local actionsHolder = main:WaitForChild("ActionsHolder")
local dropEgg = main:WaitForChild("DropEgg")
assert(dropEgg:IsA("GuiButton"), "Main.DropEgg must be a GuiButton")
local dropEggVolcanoButton = actionsHolder:WaitForChild("DropEggVolcanoButton")
assert(dropEggVolcanoButton:IsA("GuiButton"), "Main.ActionsHolder.DropEggVolcanoButton must be a GuiButton")
local v = { Enum.KeyCode.G, Enum.KeyCode.DPadDown }
local v2 = {}
local visible = false
Observers.observeTag(Volcano.Tag, function(part)
	if not part:IsA("BasePart") then
		return nil
	end

	v2[part] = true
	return function()
		v2[part] = nil
	end
end, { workspace })

local function HasVolcanoFlight()
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, child in basket:GetChildren() do
		local volcanoUntil = child:GetAttribute("VolcanoUntil")

		if type(volcanoUntil) == "number" and serverTimeNow < volcanoUntil then
			return true
		end
	end

	return false
end

local function HasEligibleEgg()
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, child in basket:GetChildren() do
		if not (child:GetAttribute("VolcanoDipped") ~= true and child:GetAttribute("Delivering") ~= true) then
			continue
		end

		local volcanoUntil = child:GetAttribute("VolcanoUntil")

		if type(volcanoUntil) ~= "number" or not (serverTimeNow < volcanoUntil) then
			return true
		end
	end

	return false
end

local function IsOverAnyPool()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return false
	end

	for k in v2 do
		if Volcano.IsOver(k, humanoidRootPart.Position) then
			return true
		end
	end

	return false
end

local function DropNormally()
	if #basket:GetChildren() == 0 or localPlayer:GetAttribute("TutorialActive") == true then
		return
	end

	pop:Play()
	basketDrop:FireServer()
end

local function Drop()
	if HasVolcanoFlight() then
		return
	end

	if visible then
		remoteEvent:FireServer()
	elseif #basket:GetChildren() ~= 0 then
		if localPlayer:GetAttribute("TutorialActive") == true then
			return
		end

		pop:Play()
		basketDrop:FireServer()
	end
end

local function OnDropAction(_: string, p)
	if GamepadUI.GameplayBlocked() then
		return Enum.ContextActionResult.Pass
	end

	if p ~= Enum.UserInputState.Begin or HasVolcanoFlight() then
		return Enum.ContextActionResult.Sink
	end

	if visible then
		remoteEvent:FireServer()
	elseif #basket:GetChildren() ~= 0 and localPlayer:GetAttribute("TutorialActive") ~= true then
		pop:Play()
		basketDrop:FireServer()
	end

	return Enum.ContextActionResult.Sink
end

local v4 = false

local function Refresh()
	local v5

	if #basket:GetChildren() > 0 and localPlayer:GetAttribute("TutorialActive") ~= true then
		v5 = not HasVolcanoFlight()
	else
		v5 = false
	end

	visible = v5 and IsOverAnyPool() and HasEligibleEgg()

	if dropEgg:GetAttribute("DropAvailable") ~= v5 then
		dropEgg:SetAttribute("DropAvailable", v5)
	end

	if dropEggVolcanoButton.Visible ~= visible then
		dropEggVolcanoButton.Visible = visible
	end

	local v6 = v5 or visible

	if v6 and not v4 then
		ContextActionService:BindAction("DropCarriedEgg", OnDropAction, false, table.unpack(v))
		v4 = true
	elseif not v6 and v4 then
		ContextActionService:UnbindAction("DropCarriedEgg")
		v4 = false
	end
end

dropEgg.Activated:Connect(Drop)
dropEggVolcanoButton.Activated:Connect(Drop)
basket.ChildAdded:Connect(Refresh)
basket.ChildRemoved:Connect(Refresh)
localPlayer:GetAttributeChangedSignal("TutorialActive"):Connect(Refresh)
local total = 0
RunService.Heartbeat:Connect(function(dt: number)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0
	Refresh()
end)
Refresh()