local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local GamepadSupport = {}
local v = {}
local v2 = {}
local v3 = {
	["手柄按键提示"] = true,
	["手柄导航提示"] = true,
	["手柄瞄准提示"] = true
}

function GamepadSupport.IsGamepad()
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

function GamepadSupport.IsVisible(parent)
	if not (parent and parent.Parent) then
		return false
	end

	while parent do
		if parent:GetAttribute("GamepadPromptsEnabled") == false or parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("ScreenGui") and not parent.Enabled then
			return false
		else
			parent = parent.Parent
		end
	end

	return true
end

function GamepadSupport.GetModalBackground()
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
	local v4 = playerGui and playerGui:FindFirstChild("通用确认框")
	local selected = v4 and v4:FindFirstChild("背景")

	if selected and GamepadSupport.IsVisible(selected) then
		return selected
	end

	return nil
end

function GamepadSupport.IsAboveModal(instance, p)
	local v4 = p or GamepadSupport.GetModalBackground()

	if not v4 or instance:IsDescendantOf(v4) then
		return true
	end

	local screenGui = instance:FindFirstAncestorOfClass("ScreenGui")
	local screenGui2 = v4:FindFirstAncestorOfClass("ScreenGui")
	return screenGui ~= nil and screenGui2 ~= nil and screenGui ~= screenGui2 and screenGui.DisplayOrder > screenGui2.DisplayOrder
end

function GamepadSupport.CanActivate(button)
	return button and GamepadSupport.IsAboveModal(button) and button:IsA("GuiButton") and button.Active and button.Interactable and GamepadSupport.IsVisible(button) and not (GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox())
end

function GamepadSupport.IsBlocked(p)
	if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() ~= nil then
		return true
	end

	local modalBackground = GamepadSupport.GetModalBackground()
	return modalBackground ~= nil and not (p and GamepadSupport.IsAboveModal(p, modalBackground))
end

function GamepadSupport.Refresh()
	local v4 = GamepadSupport.IsGamepad() and not (GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox())
	local modalBackground = GamepadSupport.GetModalBackground()
	local selectedObject = GuiService.SelectedObject

	for k in v2 do
		if k.Parent then
			local parent = k.Parent
			local interactable = v4 and GamepadSupport.IsVisible(parent) and GamepadSupport.IsAboveModal(
				parent,
				modalBackground
			)

			if parent:IsA("GuiButton") then
				interactable = interactable and parent.Active and parent.Interactable

				if k:GetAttribute("PromptMode") ~= "Always" then
					interactable = interactable and selectedObject == parent
				end
			end

			if k.Visible ~= interactable then
				k.Visible = interactable
			end
		else
			v2[k] = nil
		end
	end
end

function GamepadSupport.WatchRoot(folder)
	if v[folder] then
		return
	end

	v[folder] = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(guiObject)
		if guiObject:IsA("GuiObject") and v3[guiObject.Name] then
			v2[guiObject] = true
			guiObject.Visible = false
		end
	end

	for _, descendant in folder:GetDescendants() do
		add(descendant) -- equivalent call inferred; original call site unknown
	end

	folder.DescendantAdded:Connect(add)
	folder.DescendantRemoving:Connect(function(descendant)
		v2[descendant] = nil
	end)
	GamepadSupport.Refresh()
end

function GamepadSupport.ScreenDirection(p, p2, data)
	local v4 = p.X * p2.Y - p2.X * p.Y

	if math.abs(v4) < 1e-6 or data.Magnitude < 0.2 then
		return nil
	end

	local vector = Vector2.new(data.X, -data.Y)
	local vector2 = Vector2.new((vector.X * p2.Y - p2.X * vector.Y) / v4, (p.X * vector.Y - vector.X * p.Y) / v4)

	if vector2.Magnitude > 1e-6 then
		return vector2.Unit
	end

	return nil
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(GamepadSupport.Refresh)
GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(GamepadSupport.Refresh)
GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(GamepadSupport.Refresh)
local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total >= 0.1 then
		total = 0
		GamepadSupport.Refresh()
	end
end)
return GamepadSupport