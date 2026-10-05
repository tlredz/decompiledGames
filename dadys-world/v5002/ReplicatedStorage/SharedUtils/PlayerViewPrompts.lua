local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Maid = require(ReplicatedStorage.SharedUtils.Maid)
local MenuManager = require(ReplicatedStorage.SharedUtils.MenuManager)
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local CameraModeController = require(ReplicatedStorage.SharedUtils.CameraModeController)
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local zero = Vector2.zero
local color = Color3.new(1, 1, 1)
local flag = false
local localPlayer = Players.LocalPlayer
local maid = Maid.new()
local v = {}
local enabled = false
local v3 = nil
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function applyPromptKeys(p)
	local boundKeyCode = InputService:GetBoundKeyCode("ViewProfile", "Keyboard")

	if boundKeyCode then
		p.KeyboardKeyCode = boundKeyCode
	end

	local boundKeyCode2 = InputService:GetBoundKeyCode("ViewProfile", "Gamepad")

	if boundKeyCode2 then
		p.GamepadKeyCode = boundKeyCode2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearHighlight()
	if not v3 then
		return
	end

	v3 = nil
	HighlightController:ClearHighlight("ProfilePromptTarget")
end

local function setHighlight(p, character)
	if v3 == p then
		return
	end

	clearHighlight() -- equivalent call inferred; original call site unknown

	if p and character then
		v3 = p
		HighlightController:PlayHighlight(character, "Target", {
			FillColor = color,
			OutlineColor = color,
			FillTransparency = 1,
			OutlineTransparency = 0.5,
			DepthMode = Enum.HighlightDepthMode.Occluded,
			ForceColor = true,
			Priority = HighlightController.Priority.VIEW_TARGET
		}, "ProfilePromptTarget")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isLocalCharacter(character)
	return localPlayer.Character == character or Players:GetPlayerFromCharacter(character) == localPlayer
end

-- equivalent calls inferred from this helper; original call sites unknown
local function menuIsOpen()
	if MenuManager:IsAnyOpen() or v4 and v4.isAnyOpen() or InputService:IsGameplaySuspended() then
		return true
	end

	return false
end

local function shouldEnable()
	if localPlayer:GetAttribute("InLobby") == true then
		return false
	end

	return not menuIsOpen() and not CameraModeController.IsActive()
end

local function applyGate()
	local enabled2

	if localPlayer:GetAttribute("InLobby") == true or MenuManager:IsAnyOpen() or v4 and v4.isAnyOpen() or InputService:IsGameplaySuspended() then
		enabled2 = false
	else
		enabled2 = not CameraModeController.IsActive()
	end

	if enabled2 == enabled then
		return
	end

	enabled = enabled2

	if not enabled2 and v3 then
		v3 = nil
		HighlightController:ClearHighlight("ProfilePromptTarget")
	end

	for _, v6 in pairs(v) do
		if v6.prompt.Parent then
			v6.prompt.Enabled = enabled2
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openProfile(parent)
	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

	if not playerFromCharacter then
		return
	end

	local userId = playerFromCharacter.UserId
	task.spawn(function()
		local instance = MenuManager:GetInstance("DreamJournal")
		local showProfile = instance and instance.ShowProfile

		if type(showProfile) ~= "function" then
			warn("[PlayerViewPrompts] DreamJournal exposes no ShowProfile — profile UI unavailable here")
			return
		end

		local success, result = pcall(showProfile, userId)

		if not success then
			warn("[PlayerViewPrompts] ShowProfile failed:", result)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeTarget(k)
	local v5 = v[k]

	if not v5 then
		return
	end

	v[k] = nil

	if v5.prompt == v3 and v3 then
		v3 = nil
		HighlightController:ClearHighlight("ProfilePromptTarget")
	end

	v5.maid:Destroy()
end

local function addTarget(part)
	if v[part] or not part:IsA("BasePart") then
		return
	end

	local parent = part.Parent

	if not parent or isLocalCharacter(parent) then
		return
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "PlayerViewPrompt"
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt:SetAttribute("StyleKey", "LookAtPlayer")
	proximityPrompt.ActionText = ""
	proximityPrompt.ObjectText = ""
	proximityPrompt.HoldDuration = 0
	proximityPrompt.MaxActivationDistance = 14.4
	proximityPrompt.RequiresLineOfSight = true
	proximityPrompt.ClickablePrompt = true
	proximityPrompt.UIOffset = zero
	proximityPrompt:SetAttribute("NoInputSync", true)
	applyPromptKeys(proximityPrompt) -- equivalent call inferred; original call site unknown
	proximityPrompt.Enabled = enabled
	proximityPrompt.Parent = part
	local maid2 = Maid.new()
	maid2:GiveTask(proximityPrompt)
	maid2:GiveTask(proximityPrompt.Triggered:Connect(function()
		if isLocalCharacter(parent) or CameraModeController.IsActive() then
			return
		end

		openProfile(parent) -- equivalent call inferred; original call site unknown
	end))
	v[part] = {
		prompt = proximityPrompt,
		maid = maid2,
		character = parent
	}
end

return {
	setup = function()
		if flag then
			return
		end

		if not RunService:IsClient() then
			warn("[PlayerViewPrompts] setup() is client-only — ignoring server call")
			return
		end

		flag = true
		task.spawn(function()
			local modules = ReplicatedStorage:WaitForChild("Modules", 30)
			local windowHandler = modules and modules:FindFirstChild("WindowHandler")

			if not windowHandler then
				return
			end

			local success, result = pcall(require, windowHandler)

			if success and type(result) == "table" and type(result.isAnyOpen) == "function" then
				v4 = result
			else
				warn("[PlayerViewPrompts] WindowHandler has no isAnyOpen(); legacy windows will not gate prompts")
			end
		end)
		enabled = localPlayer:GetAttribute("InLobby") ~= true and not MenuManager:IsAnyOpen() and not (v4 and v4.isAnyOpen()) and not InputService:IsGameplaySuspended() and not CameraModeController.IsActive()

		for _, v6 in ipairs(CollectionService:GetTagged("LoadoutTargets")) do
			addTarget(v6)
		end

		maid:GiveTask(CollectionService:GetInstanceAddedSignal("LoadoutTargets"):Connect(addTarget))
		maid:GiveTask(CollectionService:GetInstanceRemovedSignal("LoadoutTargets"):Connect(removeTarget))
		maid:GiveTask(InputService.BindingChanged:Connect(function(p)
			if p ~= nil and p ~= "ViewProfile" then
				return
			end

			for _, v6 in pairs(v) do
				if not v6.prompt.Parent then
					continue
				end

				applyPromptKeys(v6.prompt) -- equivalent call inferred; original call site unknown
			end
		end))
		maid:GiveTask(ProximityPromptService.PromptShown:Connect(function(p)
			local v6 = p.Parent and v[p.Parent]

			if not v6 or v6.prompt ~= p then
				return
			end

			setHighlight(p, v6.character)
		end))
		maid:GiveTask(ProximityPromptService.PromptHidden:Connect(function(p)
			if p == v3 then
				clearHighlight() -- equivalent call inferred; original call site unknown
			end
		end))
		maid:GiveTask(localPlayer.CharacterAdded:Connect(function()
			for k, v6 in pairs(v) do
				if not isLocalCharacter(v6.character) then
					continue
				end

				removeTarget(k) -- equivalent call inferred; original call site unknown
			end
		end))
		local total = 0
		maid:GiveTask(RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total < 0.25 then
				return
			end

			total = 0
			local success, result = pcall(applyGate)

			if not success then
				warn("[PlayerViewPrompts] gate error:", result)
			end
		end))
	end
}