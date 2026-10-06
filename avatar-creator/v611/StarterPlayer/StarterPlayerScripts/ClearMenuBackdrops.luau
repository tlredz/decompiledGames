local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {
	Root = true,
	Shield = true,
	Shade = true,
	Blocker = true,
	Overlay = true,
	Dim = true,
	Dimmer = true,
	Scrim = true,
	ModalBackdrop = true,
	MobileModalBackdrop = true,
	ResetConfirmation = true
}
local object = setmetatable({}, {
	__mode = "k"
})

local function fillsParent(p)
	local size = p.Size
	return size.X.Scale >= 0.95 and size.Y.Scale >= 0.95 and size.X.Offset >= -40 and size.Y.Offset >= -40
end

local function isMenuBackdrop(parent)
	if not (v[parent.Name] and (parent:IsA("Frame") or parent:IsA("TextButton") or parent:IsA("CanvasGroup"))) then
		return false
	end

	while parent and parent ~= playerGui do
		if parent:IsA("ScreenGui") then
			return true
		end

		if not parent:IsA("GuiObject") then
			return false
		end

		local size = parent.Size
		local v2

		if size.X.Scale >= 0.95 and size.Y.Scale >= 0.95 and size.X.Offset >= -40 then
			v2 = size.Y.Offset >= -40
		else
			v2 = false
		end

		if v2 then
			parent = parent.Parent
			continue
		end

		return false
	end

	return false
end

local function watch(guiObject)
	if object[guiObject] or not (guiObject:IsA("GuiObject") and v[guiObject.Name]) then
		return
	end

	object[guiObject] = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clear()
		if isMenuBackdrop(guiObject) then
			if guiObject.BackgroundTransparency ~= 1 then
				guiObject.BackgroundTransparency = 1
			end

			if guiObject.BorderSizePixel ~= 0 then
				guiObject.BorderSizePixel = 0
			end
		end
	end

	guiObject:GetPropertyChangedSignal("BackgroundTransparency"):Connect(clear)
	guiObject:GetPropertyChangedSignal("Size"):Connect(clear)
	guiObject.AncestryChanged:Connect(clear)
	clear() -- equivalent call inferred; original call site unknown
end

playerGui.DescendantAdded:Connect(watch)

for _, descendant in playerGui:GetDescendants() do
	watch(descendant)
end