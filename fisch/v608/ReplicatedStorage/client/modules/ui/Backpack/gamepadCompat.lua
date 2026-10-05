local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local legacyUiLoader = require(ReplicatedStorage.client.legacy.legacyUiLoader)
require(ReplicatedStorage.shared.modules.library)
require(script.Parent.itemDisplayInfo)
local dragHelper = require(script.Parent.dragHelper)
local parentModule = require(script.Parent)
local GliderController = require(ReplicatedStorage.client.legacyControllers.Items.GliderController)
local gamepadTemplate = ReplicatedStorage.resources.ui.backpack.gamepadTemplate
local backpack = legacyUiLoader.PlayerGui.backpack
local _ = backpack.hotbar
local inventory = backpack.inventory
local backpack2 = ReplicatedStorage.client.inputs.Backpack
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local GamepadCompat = {
	setItemGrid = function(p, p2, p3)
		v = p
		v2 = p2
		v4 = p3
	end
}
local v5 = {}
local v6 = {
	none = {},
	notDragging = {
		{
			key = Enum.KeyCode.ButtonA,
			text = "Equip"
		},
		{
			key = Enum.KeyCode.ButtonY,
			text = "Favourite"
		},
		{
			key = Enum.KeyCode.ButtonX,
			text = "Move"
		},
		{
			key = Enum.KeyCode.ButtonL1,
			text = "Cycle Left"
		},
		{
			key = Enum.KeyCode.ButtonR1,
			text = "Cycle Right"
		}
	},
	dragging = {
		{
			key = Enum.KeyCode.ButtonX,
			text = "Confirm"
		},
		{
			key = Enum.KeyCode.ButtonB,
			text = "Cancel"
		},
		{
			key = Enum.KeyCode.ButtonL1,
			text = "Cycle Left"
		},
		{
			key = Enum.KeyCode.ButtonR1,
			text = "Cycle Right"
		}
	}
}

function GamepadCompat.getAvailableActions()
	if inventory.Visible and GamepadService.GamepadCursorEnabled then
		if dragHelper.getDragging() then
			return v6.dragging
		end

		return v6.notDragging
	else
		return v6.none
	end
end

function GamepadCompat.init(p)
	v3 = p

	local function getNearestSlot()
		local mouseLocation = UserInputService:GetMouseLocation()
		local v7 = 1e999
		local v8 = nil

		for _, v9 in v3 do
			local magnitude = (mouseLocation - v9.AbsolutePosition).Magnitude

			if not (magnitude < v7) then
				continue
			end

			v8 = v9
			v7 = magnitude
		end

		return table.find(v3, v8)
	end

	local function cycleEquipped(p2: number)
		local equippedItemId = parentModule.getEquippedItemId()
		local hotbarKey = parentModule.getHotbarKey(equippedItemId)

		if next(v) then
			local v7 = 0

			for k, v8 in v do
				if hotbarKey == v8 then
					v7 = tonumber(k)
				end
			end

			local v8 = nil

			for i = parentModule.getHotbarSize(), 1, -1 do
				if not v[tostring(i)] then
					continue
				end

				v8 = i
				break
			end

			local v9 = v7 + p2
			local v10

			if v9 < 1 then
				v10 = v8
			else
				v10 = v8 < v9 and 1 or v9
			end

			if p2 == 1 then
				for i = v10, v8 do
					local v11 = v[tostring(i)]

					if not (v11 and (not GliderController:IsGlider(v2[v11]) or GliderController:IsInAir())) then
						continue
					end

					v10 = i
					break
				end
			elseif p2 == -1 then
				for i = v10, 1, -1 do
					local v11 = v[tostring(i)]

					if not (v11 and (not GliderController:IsGlider(v2[v11]) or GliderController:IsInAir())) then
						continue
					end

					v10 = i
					break
				end
			end

			parentModule.handleInput(parentModule.getItemIdFromHotbarKey(v[tostring(v10)]), "equip")
		elseif equippedItemId then
			parentModule.handleInput(equippedItemId, "equip")
		end
	end

	ContextActionService:BindActionAtPriority("BackpackCancel", function(_, p2)
		if p2 ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		if v5 == v6.dragging then
			dragHelper.endDrag(true)
			return Enum.ContextActionResult.Sink
		end

		if inventory.Visible then
			inventory.Visible = false
			return Enum.ContextActionResult.Sink
		end

		if not parentModule.getEquippedItemId() then
			return Enum.ContextActionResult.Pass
		end

		parentModule.handleInput(parentModule.getEquippedItemId(), "equip")
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.Low.Value - 1, Enum.KeyCode.ButtonB)
	backpack2.EquipPrevItem.Pressed:Connect(function()
		if not inventory.Visible then
			cycleEquipped(-1)
			return
		end

		if v5 == v6.none then
			return
		end

		local v7 = getNearestSlot() - 1
		GamepadService:EnableGamepadCursor(v3[v7 == 0 and #v3 or v7])
	end)
	backpack2.EquipNextItem.Pressed:Connect(function()
		if not inventory.Visible then
			cycleEquipped(1)
			return
		end

		if v5 == v6.none then
			return
		end

		local v7 = getNearestSlot() + 1
		GamepadService:EnableGamepadCursor(v3[#v3 < v7 and 1 or v7])
	end)
	RunService.Heartbeat:Connect(function()
		if GamepadService.GamepadCursorEnabled then
			inventory.Toggles["Header-Keys"].Visible = true
			inventory.Toggles["Underline-Keys"].Visible = true
		else
			inventory.Toggles["Header-Keys"].Visible = false
			inventory.Toggles["Underline-Keys"].Visible = false
		end

		local availableActions = GamepadCompat.getAvailableActions()

		if v5 ~= availableActions then
			for _, v7 in v5 do
				local child = inventory.Toggles:FindFirstChild(v7.text)

				if child then
					child:Destroy()
				end
			end

			for k, availableAction in availableActions do
				local clone = gamepadTemplate:Clone()
				clone.Name = availableAction.text
				clone.TextLabel.Text = availableAction.text
				clone.ImageLabel:SetAttribute("ButtonKeyCode", availableAction.key.Name)
				clone.ImageLabel:AddTag("GamepadButton")
				clone.LayoutOrder = 10 + k
				clone.Parent = inventory.Toggles
			end

			v5 = availableActions
		end
	end)
	inventory:GetPropertyChangedSignal("Visible"):Connect(function()
		if not inventory.Visible and GamepadService.GamepadCursorEnabled then
			GamepadService:DisableGamepadCursor()
		end
	end)
	GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(function()
		if inventory.Visible and not GamepadService.GamepadCursorEnabled and UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
			inventory.Visible = false
		end
	end)
end

return GamepadCompat