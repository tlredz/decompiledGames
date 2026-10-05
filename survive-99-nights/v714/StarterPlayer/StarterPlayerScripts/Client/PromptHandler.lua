local PromptHandler = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local UserInputService = game:GetService("UserInputService")
local v = "Keyboard"
local E = Enum.KeyCode.E
local buttonX = Enum.KeyCode.ButtonX
local v2 = {}
local v3 = {}
local v4 = {}
local flag = false
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}

function v4.OpenFurnitureShop(_, _)
	return "Buy furniture"
end

function v4.CanBeBagged(_, _)
	return "Put in sack"
end

function v4.Revive(_, _)
	return "Revive with bandages"
end

function v4.AnimalTrap(_, _)
	return "Set Trap"
end

function v4.FireSource(instance, _)
	local quantity = instance:GetAttribute("Quantity") or 1
	return not (quantity > 1) and "Add to fire" or instance.Name .. " (" .. quantity .. ")"
end

function v4.Door(instance, p)
	if instance.Parent.Parent:GetAttribute("Stronghold") then
		return "Cultist Stronghold"
	end

	local function updatePrompt()
		local doorOpen = instance:GetAttribute("DoorOpen")
		local isGate = instance:GetAttribute("IsGate")

		if doorOpen then
			if isGate then
				p.SetLabelText("Close Gate")
			else
				p.SetLabelText("Close Door")
			end
		elseif isGate then
			p.SetLabelText("Open Gate")
		else
			p.SetLabelText("Open Door")
		end
	end

	table.insert(v3[instance], instance:GetAttributeChangedSignal("DoorOpen"):Connect(function()
		updatePrompt()
	end))
	updatePrompt()
	return nil
end

function PromptHandler.HideAllPrompts(value)
	v8[value or "Default"] = true

	if flag then
		return
	end

	flag = true

	for k, _ in pairs(v6) do
		if not k.Enabled then
			continue
		end

		k.Enabled = false
		v5[k] = true
	end
end

function PromptHandler.ShowAllPrompts(value)
	v8[value or "Default"] = nil

	if not flag or next(v8) then
		return
	end

	flag = false
	local v9 = {}

	for k, _ in pairs(v5) do
		if k.Parent == nil or k.Parent.Parent == nil then
			table.insert(v9, k)
		else
			k.Enabled = true
		end
	end

	v5 = {}

	for _, v10 in pairs(v9) do
		v6[v10] = nil
	end
end

function MakeCustomPromptLabel(_, _) end

function MakeInteractionLabel(instance, p, p2)
	local v9 = {
		CustomLabel = MakeCustomPromptLabel(instance),
		SetLabelText = function(actionText)
			p.ActionText = actionText
		end
	}
	local interactLabel = instance:GetAttribute("InteractLabel") or "Interact"

	if v4[p2] then
		interactLabel = v4[p2](instance, v9)
	end

	if interactLabel then
		p.ActionText = interactLabel
	end

	DestroyLabel(instance)
	v2[instance] = v9
end

UserInputService.LastInputTypeChanged:Connect(function(p)
	local v9 = v

	if p == Enum.UserInputType.Keyboard then
		v = "Keyboard"
	elseif p == Enum.UserInputType.Gamepad1 then
		v = "Gamepad"
	elseif p == Enum.UserInputType.Touch then
		v = "Touch"
	end

	if v ~= v9 then
		print("new input type", v)
	end
end)

function OnPromptShown(_, p)
	p.Enabled = true
end

function OnPromptHidden(_, p)
	p.Enabled = false
end

function DestroyLabel(p)
	if v2[p] then
		if v2.CustomLabel then
			v2[p].CustomLabel:Destroy()
		end

		if v2[p].Connections then
			for _, connection in pairs(v2[p].Connections) do
				connection:Disconnect()
			end
		end
	end

	v2[p] = nil
end

function PromptHandler.CheckInteractionCooldown(instance)
	if instance:GetAttribute("InteractionCooldown") then
		task.spawn(function()
			local proximityAttachment = (instance.PrimaryPart or instance:FindFirstChild("PromptPart")):FindFirstChild("ProximityAttachment")
			local proximityInteraction = proximityAttachment and proximityAttachment:FindFirstChild("ProximityInteraction")

			if proximityInteraction then
				proximityInteraction.Enabled = false
				instance:SetAttribute("InteractOnCooldown", true)
				wait(instance:GetAttribute("InteractionCooldown"))
				instance:SetAttribute("InteractOnCooldown", nil)

				if flag then
					v5[proximityInteraction] = true
				else
					proximityInteraction.Enabled = true
				end
			end
		end)
	end
end

function AddInteraction(instance)
	if instance:GetAttribute("FakeItem") then
		return
	end

	if isStudio then
		task.delay(1, function()
			local _ = instance.PrimaryPart == nil
		end)
	end

	while instance.PrimaryPart == nil and instance.Parent ~= nil do
		wait(1)
	end

	if instance.Parent == nil then
		warn("item is no longer in workspace")
		return
	end

	local interaction = instance:GetAttribute("Interaction")
	local v9 = nil
	local proximityAttachment = (instance.PrimaryPart or instance:FindFirstChild("PromptPart")):FindFirstChild("ProximityAttachment")
	local proximityInteraction = proximityAttachment and proximityAttachment:FindFirstChild("ProximityInteraction")

	if proximityInteraction == nil then
		return
	end

	task.delay(0.1, function()
		proximityInteraction.KeyboardKeyCode = E
		proximityInteraction.GamepadKeyCode = buttonX
	end)
	local connections = {}
	v3[instance] = connections

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ProcessInteraction()
		PromptHandler.CheckInteractionCooldown(instance)
		Client.InteractionHandler.ProcessInteraction(instance, interaction, v9)
	end

	table.insert(connections, proximityInteraction.Triggered:Connect(function()
		ProcessInteraction() -- equivalent call inferred; original call site unknown
	end))
	table.insert(connections, proximityInteraction.PromptShown:Connect(function()
		v9 = MakeInteractionLabel(instance, proximityInteraction, interaction)
	end))
	table.insert(connections, proximityInteraction.PromptHidden:Connect(function()
		DestroyLabel(instance)
	end))
	v6[proximityInteraction] = true
	local v10 = time()
	proximityInteraction:GetPropertyChangedSignal("Enabled"):Connect(function()
		if proximityInteraction.Enabled and flag then
			print("toggle enabled not allowed")

			if time() - v10 > 0.5 then
				proximityInteraction.Enabled = false
				v5[proximityInteraction] = true
				v10 = time()
			end
		end
	end)

	if flag then
		if proximityInteraction.Enabled then
			proximityInteraction.Enabled = false
			v5[proximityInteraction] = true
		end
	elseif proximityInteraction.Enabled then
		task.spawn(function()
			proximityInteraction.Enabled = false
			wait()
			proximityInteraction.Enabled = true
		end)
	end
end

function RemoveInteraction(instance)
	local v9 = v3[instance]

	if v9 then
		for _, connection in pairs(v9) do
			connection:Disconnect()
		end

		v3[instance] = nil
	end

	local primaryPart = instance.Parent and (instance.PrimaryPart or instance:FindFirstChild("PromptPart"))

	if primaryPart then
		local proximityAttachment = primaryPart:FindFirstChild("ProximityAttachment")
		local proximityInteraction = proximityAttachment and proximityAttachment:FindFirstChild("ProximityInteraction")

		if proximityInteraction then
			v6[proximityInteraction] = nil
			v5[proximityInteraction] = nil
		end
	end

	DestroyLabel(instance)
end

function OverrideChestPromptLineOfSight(state)
	local function restore()
		local requiresLineOfSight = v7[state]

		if requiresLineOfSight == nil then
			return
		end

		state.RequiresLineOfSight = requiresLineOfSight
		v7[state] = nil
	end

	state.PromptButtonHoldBegan:Connect(function()
		if v7[state] ~= nil then
			return
		end

		v7[state] = state.RequiresLineOfSight
		state.RequiresLineOfSight = false
	end)
	state.PromptButtonHoldEnded:Connect(restore)
	state.Triggered:Connect(restore)
	state.TriggerEnded:Connect(restore)
end

function PromptHandler.Init()
	task.spawn(function()
		Client.Utility.ForAllTagged("Interaction", AddInteraction, RemoveInteraction)
	end)
	task.spawn(function()
		Client.Utility.ForAllTagged("ItemChestPrompt", OverrideChestPromptLineOfSight)
	end)
end

return PromptHandler