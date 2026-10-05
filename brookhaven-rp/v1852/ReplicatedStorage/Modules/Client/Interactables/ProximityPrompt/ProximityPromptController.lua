local ProximityPromptController = {}
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local ProximityPromptShared = require(script.Parent.Parent.ProximityPromptShared)
local ProximityPromptRelevance = require(script.Parent.ProximityPromptRelevance)
local ProximityPromptUI = require(script.Parent.ProximityPromptUI)
local NEW_SYSTEM_TAG = ProximityPromptShared.NEW_SYSTEM_TAG
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local v3 = {}
local v4 = nil
local maid = Janitor.new()
local client2ClientAccept = nil
local animationPlaying = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getCollapsedMinCameraDistance(character, camera)
	if localPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
		return 5
	end

	local head = character:FindFirstChild("Head")

	if head == nil or not head:IsA("BasePart") then
		return 10
	end

	if (camera.CFrame.Position - head.Position).Magnitude <= 2.5 then
		return 5
	end

	return 10
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyPrompt(p)
	local v5 = v[p]

	if v5 == nil then
		return
	end

	v[p] = nil
	v2[p] = nil
	v3[p] = nil
	v5:Destroy()
end

local function beginFadeOut(p)
	local v5 = v[p]

	if v5 == nil or v2[p] == true then
		return
	end

	v3[p] = nil
	v2[p] = true
	v5:SetExpanded(false)
	v5:FadeOut(function()
		if v2[p] ~= true then
			return
		end

		destroyPrompt(p) -- equivalent call inferred; original call site unknown
	end)
end

local function cancelPendingFadeOut(p)
	v3[p] = nil
end

local function scheduleFadeOut(p, p2: number)
	if v2[p] == true then
		return
	end

	local v5 = v3[p]

	if v5 == nil then
		v3[p] = p2 + 0.35
	elseif v5 <= p2 then
		local v6 = v[p]

		if v6 ~= nil then
			if v2[p] == true then
				return
			end

			v3[p] = nil
			v2[p] = true
			v6:SetExpanded(false)
			v6:FadeOut(function()
				if v2[p] ~= true then
					return
				end

				destroyPrompt(p) -- equivalent call inferred; original call site unknown
			end)
		end
	end
end

local function interactFocused()
	local v5 = v4

	if v5 == nil then
		return
	end

	local v6 = InteractionPrompt:FromInstance(v5)

	if not (v6 ~= nil and v6:HasPermission()) then
		return
	end

	v6:Interact()

	if ProximityPromptShared.shouldHideInteractionUI(v5) then
		destroyPrompt(v5) -- equivalent call inferred; original call site unknown

		if v4 == v5 then
			v4 = nil
			ProximityPromptShared.setNewSystemHasFocus(false)
		end
	end
end

local function ensurePrompt(p)
	v3[p] = nil
	local v5 = v[p]

	if v5 == nil then
		local v6 = ProximityPromptUI.Create(p, ProximityPromptShared.getPromptText(p), interactFocused)

		if v6 == nil then
			return nil
		end

		v[p] = v6
		v2[p] = nil

		if v4 == p then
			v6:SetExpanded(true)
		end

		return v6
	else
		if v2[p] ~= true then
			return v5
		end

		v2[p] = nil
		v5:FadeIn()

		if v4 == p then
			v5:SetExpanded(true)
		end

		return v5
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearFocusAndPrompts()
	for k in v do
		local v5 = v[k]

		if not (v5 ~= nil and v2[k] ~= true) then
			continue
		end

		v3[k] = nil
		v2[k] = true
		v5:SetExpanded(false)
		local v6 = k
		v5:FadeOut(function()
			if v2[v6] ~= true then
				return
			end

			destroyPrompt(v6) -- equivalent call inferred; original call site unknown
		end)
	end

	v4 = nil
	ProximityPromptShared.setNewSystemHasFocus(false)
end

local function getUpdateContext()
	local character = localPlayer.Character

	if character == nil then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") or (humanoid == nil or not humanoid:IsA("Humanoid")) then
		return nil
	end

	if client2ClientAccept == nil or animationPlaying == nil then
		return nil
	end

	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return nil
	end

	return {
		character = character,
		humanoid = humanoid,
		humanoidRootPart = humanoidRootPart,
		camera = currentCamera,
		playerPosition = humanoidRootPart.Position,
		now = os.clock()
	}
end

local function canShowTarget(instance, data)
	local v5 = InteractionPrompt:FromInstance(instance)

	if v5 ~= nil and not v5:HasPermission() then
		return false
	end

	if not ProximityPromptShared.canSelectPrompt({
		character = data.character,
		humanoid = data.humanoid,
		humanoidRootPart = data.humanoidRootPart,
		instance = instance,
		client2ClientAccept = client2ClientAccept,
		animationPlaying = animationPlaying,
		localPlayer = localPlayer
	}) then
		return false
	end

	return not ProximityPromptShared.shouldHideInteractionUI(instance)
end

local function collectRankedTargets(updateContext)
	local inRange = {}
	local v6 = -1e999
	local bestTarget = nil

	for _, v8 in CollectionService:GetTagged(NEW_SYSTEM_TAG) do
		local targetPosition = ProximityPromptShared.getTargetPosition(v8)

		if targetPosition == nil then
			continue
		end

		local interactDistance = ProximityPromptShared.getInteractDistance(v8)
		local v9

		if (v[v8] ~= nil or v3[v8] ~= nil) == true then
			v9 = interactDistance + 2.5
		else
			v9 = interactDistance
		end

		if v9 < (targetPosition - updateContext.playerPosition).Magnitude or not ProximityPromptShared.isPositionOnCamera(
			targetPosition,
			updateContext.camera
		) or not canShowTarget(v8, updateContext) then
			continue
		end

		table.insert(inRange, v8)
		local score = ProximityPromptRelevance.Score(targetPosition, {
			playerPosition = updateContext.playerPosition,
			camera = updateContext.camera,
			maxDistance = interactDistance
		}, { updateContext.character }, v8)

		if not (v6 < score) then
			continue
		end

		bestTarget = v8
		v6 = score
	end

	return {
		inRange = inRange,
		bestTarget = bestTarget
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldShowPrompt(p, bestTarget, p2, collapsedMinCameraDistance: number)
	if p == bestTarget then
		return true
	end

	local targetPosition = ProximityPromptShared.getTargetPosition(p)

	if targetPosition == nil then
		return false
	end

	return collapsedMinCameraDistance <= (targetPosition - p2.camera.CFrame.Position).Magnitude
end

local function syncVisiblePrompts(p, updateContext)
	local result = {}
	local collapsedMinCameraDistance = getCollapsedMinCameraDistance(updateContext.character, updateContext.camera) -- equivalent call inferred; original call site unknown

	for _, v5 in p.inRange do
		-- equivalent call inferred; original call site unknown
		if not shouldShowPrompt(v5, p.bestTarget, updateContext, collapsedMinCameraDistance) then
			continue
		end

		result[v5] = true

		if not ProximityPromptShared.shouldHideInteractionUI(v5) then
			ensurePrompt(v5)
		end
	end

	return result
end

local function cleanupInactivePrompts(p, now: number)
	local v5 = {}

	for k in v do
		if ProximityPromptShared.shouldHideInteractionUI(k) then
			table.insert(v5, k)
		elseif p[k] ~= true and v2[k] ~= true then
			local v6 = v3[k]

			if v6 == nil then
				v3[k] = now + 0.35
			elseif v6 <= now then
				local v7 = v[k]

				if v7 ~= nil and v2[k] ~= true then
					v3[k] = nil
					v2[k] = true
					v7:SetExpanded(false)
					local v8 = k
					v7:FadeOut(function()
						if v2[v8] ~= true then
							return
						end

						destroyPrompt(v8) -- equivalent call inferred; original call site unknown
					end)
				end
			end
		end
	end

	for _, v6 in v5 do
		destroyPrompt(v6) -- equivalent call inferred; original call site unknown

		if v4 == v6 then
			v4 = nil
		end
	end
end

local function resolveEffectiveBestTarget(p)
	if p ~= nil then
		return p
	end

	if v4 == nil or v3[v4] == nil then
		return nil
	end

	return v4
end

local function updateFocusedTarget(bestTarget)
	if bestTarget == nil then
		if v4 == nil or v3[v4] == nil then
			bestTarget = nil
		else
			bestTarget = v4
		end
	end

	if v4 == bestTarget then
		if bestTarget == nil then
			ProximityPromptShared.setNewSystemHasFocus(false)
			return
		end

		local v5 = v[bestTarget]

		if v5 ~= nil then
			v5:SetPromptText(ProximityPromptShared.getPromptText(bestTarget))
		end

		ProximityPromptShared.setNewSystemHasFocus(true)
	else
		if v4 ~= nil then
			local v5 = v[v4]

			if v5 ~= nil and v2[v4] ~= true then
				v5:SetExpanded(false)
			end
		end

		if bestTarget ~= nil then
			local v5 = v[bestTarget]

			if v5 ~= nil then
				v5:SetPromptText(ProximityPromptShared.getPromptText(bestTarget))
				v5:SetExpanded(true)
			end
		end

		v4 = bestTarget
		ProximityPromptShared.setNewSystemHasFocus(bestTarget ~= nil)
	end
end

function ProximityPromptController.FrameworkInit() end

function ProximityPromptController.FrameworkStart()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local client2Client = playerGui:WaitForChild("MainGUIHandler"):WaitForChild("Client2Client")
	local player8Handler = playerGui:WaitForChild("Player8Handler")
	client2ClientAccept = client2Client:WaitForChild("Client2ClientAccept")
	animationPlaying = player8Handler:WaitForChild("AnimationPlaying")
	ProximityPromptShared.connectUpdate(ProximityPromptController.Update)
	maid:Add(CollectionService:GetInstanceRemovedSignal(NEW_SYSTEM_TAG):Connect(function(p)
		destroyPrompt(p) -- equivalent call inferred; original call site unknown

		if v4 == p then
			v4 = nil
			ProximityPromptShared.setNewSystemHasFocus(false)
		end
	end))
	maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or v4 == nil or ProximityPromptShared.shouldHideInteractionUI(v4) then
			return
		end

		if ProximityPromptShared.matchesHotkey(v4, input.KeyCode) then
			interactFocused()
		end
	end))
end

function ProximityPromptController.Update()
	if localPlayer.Character == nil then
		clearFocusAndPrompts() -- equivalent call inferred; original call site unknown
	else
		local updateContext = getUpdateContext()

		if updateContext == nil then
			return
		end

		local v5 = collectRankedTargets(updateContext)
		cleanupInactivePrompts(syncVisiblePrompts(v5, updateContext), updateContext.now)
		updateFocusedTarget(v5.bestTarget)
	end
end

return ProximityPromptController