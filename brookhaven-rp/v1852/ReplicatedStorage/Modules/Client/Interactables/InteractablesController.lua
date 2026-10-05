local createVector = vector.create
local InteractablesController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local InteractblesUIGenerator = require(script.Parent.InteractblesUIGenerator)
local ProximityPromptShared = require(script.Parent.ProximityPromptShared)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local localPlayer = Players.LocalPlayer
local client2ClientAccept = nil
local animationPlaying = nil
local v = nil
local DEFAULT_HOTKEY = ProximityPromptShared.DEFAULT_HOTKEY
local options = {}
local scope = Fusion.scoped({
	Value = Fusion.Value,
	Hydrate = Fusion.Hydrate
})
local adornee = scope:Value(nil)
local enabled = scope:Value(false)
local v2 = Janitor.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getInteractionOffset(p: number, p2: number)
	if p2 == 1 then
		return createVector(0, 4, 0)
	end

	return (Vector3.new((p - (p2 + 1) / 2) * 5, (p == 1 or p == p2) and 3 or 4, 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearCurrentInteractable()
	adornee:set(nil)
	enabled:set(false)
	v = nil
	options = {}
	v2:Cleanup()
end

function InteractablesController.FrameworkInit() end

function InteractablesController.FrameworkStart()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local client2Client = playerGui:WaitForChild("MainGUIHandler"):WaitForChild("Client2Client")
	local player8Handler = playerGui:WaitForChild("Player8Handler")
	client2ClientAccept = client2Client:WaitForChild("Client2ClientAccept")
	animationPlaying = player8Handler:WaitForChild("AnimationPlaying")
	ProximityPromptShared.connectUpdate(InteractablesController.Update)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or ProximityPromptShared.newSystemHasFocus() then
			return
		end

		for k, v3 in options do
			if v3.hotkey ~= input.KeyCode then
				continue
			end

			InteractablesController.Interact(k)
			break
		end
	end)
end

function InteractablesController.Interact(p: number?)
	if v then
		v:Interact(p)
	end
end

function InteractablesController:InteractWithOverride()
	self:Interact()
end

function InteractablesController.Update()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid and client2ClientAccept and animationPlaying) then
		return
	end

	local v3 = 1e999
	local v4 = nil

	for _, v5 in InteractionPrompt:GetAll() do
		if ProximityPromptShared.isClaimedByNewSystem(v5.Instance) or not v5:HasPermission() then
			continue
		end

		local targetPosition = ProximityPromptShared.getTargetPosition(v5.Instance)

		if targetPosition == nil then
			targetPosition = v5.Instance:GetPivot().Position
		end

		local magnitude = (targetPosition - humanoidRootPart.Position).Magnitude

		if ProximityPromptShared.getInteractDistance(v5.Instance) < magnitude or v3 < magnitude or not ProximityPromptShared.isPositionOnCamera(targetPosition) then
			continue
		end

		v4 = v5
		v3 = magnitude
	end

	if v4 == v then
		return
	end

	if v4 and ProximityPromptShared.canSelectPrompt({
		character = character,
		humanoid = humanoid,
		humanoidRootPart = humanoidRootPart,
		instance = v4.Instance,
		client2ClientAccept = client2ClientAccept,
		animationPlaying = animationPlaying,
		localPlayer = localPlayer
	}) then
		local type = v4.Instance:GetAttribute("Type")
		local interactionsInfo = ProximityPromptShared.getInteractionsInfo(v4.Instance)

		if interactionsInfo == nil then
			warn("No promptText or interactionsInfo found for type:", type)
			return
		end

		v2:Cleanup()
		options = {}

		local function setupInteractOption(p, p2: number, p3: number)
			local extentsOffset = v4.Instance:GetAttribute("ExtentsOffset")
			local interactionOffset = getInteractionOffset(p2, p3) -- equivalent call inferred; original call site unknown

			if typeof(extentsOffset) == "Vector3" then
				interactionOffset += extentsOffset
			end

			local hotkey = p.hotkey or DEFAULT_HOTKEY
			local v5, v6, v7 = InteractblesUIGenerator(interactionOffset, function()
				InteractablesController.Interact(p2)
			end, hotkey)
			scope:Hydrate(v5)({
				Adornee = adornee,
				Parent = localPlayer.PlayerGui,
				Enabled = enabled
			})
			v2:Add(v5)
			local promptText = p.promptText or type

			if hotkey == Enum.KeyCode.E then
				v7:SetAttribute("ConsoleGlyphKeyCode", "ButtonX")

				if not CollectionService:HasTag(v7, "ConsoleGlyphImage") then
					CollectionService:AddTag(v7, "ConsoleGlyphImage")
				end
			else
				if CollectionService:HasTag(v7, "ConsoleGlyphImage") then
					CollectionService:RemoveTag(v7, "ConsoleGlyphImage")
				end

				v7:SetAttribute("ConsoleGlyphKeyCode", nil)
			end

			v6.Text = promptText
			v7.Text = UserInputService:GetStringForKeyCode(hotkey)
		end

		v2:Cleanup()

		if interactionsInfo.options then
			for k, option in interactionsInfo.options do
				setupInteractOption(option, k, #interactionsInfo.options)
			end

			options = interactionsInfo.options
		else
			local v5 = {
				promptText = interactionsInfo.promptText,
				hotkey = interactionsInfo.hotkey or DEFAULT_HOTKEY
			}
			setupInteractOption(v5, 1, 1)
			options = { v5 }
		end

		if ProximityPromptShared.shouldHideInteractionUI(v4.Instance) then
			adornee:set(nil)
			enabled:set(false)
		else
			adornee:set(ProximityPromptShared.resolveAdornee(v4.Instance))
			enabled:set(true)
		end

		v = v4
	else
		clearCurrentInteractable() -- equivalent call inferred; original call site unknown
	end
end

return InteractablesController