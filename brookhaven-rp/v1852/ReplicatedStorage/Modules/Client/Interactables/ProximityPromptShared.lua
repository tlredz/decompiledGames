local ProximityPromptShared = {}
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local InteractionsInfo = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionsInfo)
ProximityPromptShared.NEW_SYSTEM_TAG = "ProximityPromptTarget"
ProximityPromptShared.DEFAULT_INTERACT_DISTANCE = 10
ProximityPromptShared.DEFAULT_HOTKEY = Enum.KeyCode.E
ProximityPromptShared.DEFAULT_CONSOLE_HOTKEY = Enum.KeyCode.ButtonX
local v = {}
local v2 = 0
local v3 = false
local v4 = false

function ProximityPromptShared.connectUpdate(callback)
	table.insert(v, callback)

	if not v3 then
		v3 = true
		RunService.Heartbeat:Connect(function()
			local now = os.clock()

			if now - v2 < 0.1 then
				return
			end

			v2 = now

			for _, v5 in v do
				v5()
			end
		end)
	end

	return function()
		local index = table.find(v, callback)

		if index ~= nil then
			table.remove(v, index)
		end
	end
end

function ProximityPromptShared.setNewSystemHasFocus(flag: boolean)
	v4 = flag
end

function ProximityPromptShared.newSystemHasFocus()
	return v4
end

function ProximityPromptShared.isClaimedByNewSystem(instance)
	return CollectionService:HasTag(instance, ProximityPromptShared.NEW_SYSTEM_TAG)
end

function ProximityPromptShared.getInteractDistance(instance)
	local interactDistance = instance:GetAttribute("InteractDistance")

	if typeof(interactDistance) == "number" then
		return interactDistance
	end

	return ProximityPromptShared.DEFAULT_INTERACT_DISTANCE
end

function ProximityPromptShared.resolveAdornee(instance)
	local prompt = instance:FindFirstChild("Prompt")

	if prompt == nil then
		return instance
	end

	return prompt
end

function ProximityPromptShared.getInteractionsInfo(instance)
	local promptText = instance:GetAttribute("PromptText")

	if typeof(promptText) == "string" and promptText ~= "" then
		return {
			promptText = promptText
		}
	end

	local type = instance:GetAttribute("Type")

	if typeof(type) == "string" then
		return InteractionsInfo[type]
	end

	return nil
end

function ProximityPromptShared.getPromptText(instance)
	local interactionsInfo = ProximityPromptShared.getInteractionsInfo(instance)

	if interactionsInfo ~= nil and typeof(interactionsInfo.promptText) == "string" and interactionsInfo.promptText ~= "" then
		return interactionsInfo.promptText
	end

	local type = instance:GetAttribute("Type")

	if typeof(type) == "string" and type ~= "" then
		return type
	end

	return instance.Name
end

function ProximityPromptShared.resolveHotkey(p)
	local interactionsInfo = ProximityPromptShared.getInteractionsInfo(p)

	if interactionsInfo == nil or interactionsInfo.hotkey == nil then
		return ProximityPromptShared.DEFAULT_HOTKEY
	end

	return interactionsInfo.hotkey
end

function ProximityPromptShared.matchesHotkey(p, p2)
	local hotkey = ProximityPromptShared.resolveHotkey(p)

	if p2 == hotkey then
		return true
	end

	return hotkey == ProximityPromptShared.DEFAULT_HOTKEY and p2 == ProximityPromptShared.DEFAULT_CONSOLE_HOTKEY
end

function ProximityPromptShared.getTargetPosition(instance)
	if instance:IsA("Model") then
		return instance:GetPivot().Position
	end

	if instance:IsA("BasePart") then
		return instance.Position
	end

	if instance:IsA("Attachment") then
		return instance.WorldPosition
	end

	return nil
end

function ProximityPromptShared.isPositionOnCamera(vector: Vector3, p)
	local v5 = p or Workspace.CurrentCamera

	if v5 == nil then
		return false
	end

	local worldToViewportPoint, v6 = v5:WorldToViewportPoint(vector)
	return v6 == true and worldToViewportPoint.Z > 0
end

function ProximityPromptShared.shouldHideInteractionUI(instance)
	if instance:GetAttribute("HideInteractionUI") == true then
		return true
	end

	return Workspace.WorkspaceCom["000_AnimationMarker"].Marker.GUI.Enabled ~= true
end

function ProximityPromptShared.canSelectPrompt(data)
	local character = data.character
	local humanoid = data.humanoid
	local humanoidRootPart = data.humanoidRootPart
	local instance = data.instance
	local localPlayer = data.localPlayer

	if humanoid.WalkSpeed <= 0 or character:FindFirstChild("ClientToClient") ~= nil or data.client2ClientAccept.Visible == true or data.animationPlaying.Value == true then
		return false
	end

	local showWhileSeated = instance:GetAttribute("ShowWhileSeated") == true

	if character:FindFirstChild("NoMotorVehicleModel") ~= nil and not showWhileSeated or character:FindFirstChild(localPlayer.Name .. "Horse") ~= nil and not showWhileSeated then
		return false
	end

	local v5

	if humanoid.Sit then
		local seatWeld = instance:FindFirstChild("SeatWeld")
		v5 = seatWeld ~= nil and seatWeld.Part1 == humanoidRootPart
	else
		v5 = true
	end

	if v5 or showWhileSeated then
		return true
	end

	return false
end

return ProximityPromptShared