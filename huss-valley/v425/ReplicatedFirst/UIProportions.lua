local UIProportions = {
	Reference = Vector2.new(2130, 933)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function loadingPresentation(p)
	return p and (p.Name == "ScreenOverlay" or p.Name == "TeleportOverlay")
end

local function proximityPresentation(parent)
	while parent do
		if parent.Name == "ProximityPrompts" or parent:GetAttribute("ProximityPromptUI") == true then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function excluded(parent)
	local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")

	if proximityPresentation(parent) or screenGui and (screenGui.Name == "ScreenOverlay" or screenGui.Name == "TeleportOverlay") or screenGui and (screenGui.Name == "AbilityControls" or screenGui.Name == "GearControls") then
		return true
	end

	while parent and parent ~= screenGui do
		if parent:GetAttribute("UIProportionalExclude") == true then
			return true
		end

		if screenGui and screenGui.Name == "HUD" and (parent.Name == "CatchButton" or parent.Name == "BoostButton" or parent.Name == "MeleeButton") then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

function UIProportions.factor(p, p2)
	local v = p2 or UIProportions.Reference

	if p.X <= 0 or p.Y <= 0 then
		return 1
	end

	return (math.min(p.X / v.X, p.Y / v.Y))
end

local function referenceSize(guiObject, vector)
	local size = guiObject.Size

	if guiObject.SizeConstraint == Enum.SizeConstraint.RelativeXX then
		vector = Vector2.new(vector.X, vector.X)
	elseif guiObject.SizeConstraint == Enum.SizeConstraint.RelativeYY then
		vector = Vector2.new(vector.Y, vector.Y)
	end

	return Vector2.new(size.X.Scale * vector.X + size.X.Offset, size.Y.Scale * vector.Y + size.Y.Offset)
end

function UIProportions:bind(callback)
	assert(self:IsA("GuiObject"), "A proportional group must be a GuiObject")
	local screenGui = self:FindFirstAncestorWhichIsA("ScreenGui")
	assert(screenGui, "A proportional group must belong to a ScreenGui")

	if excluded(self) then
		for _, uIScale in self:GetChildren() do
			if uIScale:IsA("UIScale") and uIScale.Name == "ProportionalScale" then
				uIScale:Destroy()
			end
		end

		self:SetAttribute("UIAppliedScale", nil)
		return {
			resize = function() end,
			destroy = function() end
		}
	else
		local uIReferenceViewport = screenGui:GetAttribute("UIReferenceViewport") or UIProportions.Reference
		local size = self.Size
		local sizeConstraint = self.SizeConstraint
		local v = referenceSize(self, uIReferenceViewport)
		local uIScale = Instance.new("UIScale")
		uIScale.Name = "ProportionalScale"
		local reveal = self:FindFirstChild("Reveal")

		if not (reveal and reveal:IsA("NumberValue")) then
			reveal = nil
		end

		local v2 = {
			connections = {},
			alive = true
		}

		local function resize(p)
			if not v2.alive then
				return
			end

			local v3 = p or callback and callback() or screenGui.AbsoluteSize

			if v3.X <= 0 or v3.Y <= 0 then
				return
			end

			local absoluteSize = self.Parent.AbsoluteSize

			if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
				return
			end

			self.Size = UDim2.fromScale(v.X / absoluteSize.X, v.Y / absoluteSize.Y)
			local factor = UIProportions.factor(v3, uIReferenceViewport)
			uIScale.Scale = factor * (reveal and reveal.Value or 1)
			self:SetAttribute("UIAppliedScale", factor)
		end

		self.SizeConstraint = Enum.SizeConstraint.RelativeXY
		self.Size = UDim2.fromOffset(v.X, v.Y)
		uIScale.Parent = self

		function v2.resize(_, p)
			resize(p)
		end

		function v2.destroy()
			if not v2.alive then
				return
			end

			v2.alive = false

			for _, connection in ipairs(v2.connections) do
				connection:Disconnect()
			end

			uIScale:Destroy()
			self.Size = size
			self.SizeConstraint = sizeConstraint
			self:SetAttribute("UIAppliedScale", nil)
		end

		table.insert(v2.connections, screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			resize()
		end))

		if self.Parent ~= screenGui then
			table.insert(v2.connections, self.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				resize()
			end))
		end

		if reveal then
			table.insert(v2.connections, reveal.Changed:Connect(function()
				resize()
			end))
		end

		resize()
		return v2
	end
end

function UIProportions.prepareTeleport(folder, p)
	if loadingPresentation(folder) then
		return
	end

	local uIReferenceViewport = folder:GetAttribute("UIReferenceViewport") or UIProportions.Reference
	local factor = UIProportions.factor(p, uIReferenceViewport)

	for _, guiObject in ipairs(folder:GetDescendants()) do
		if not guiObject:IsA("GuiObject") or guiObject:GetAttribute("UIProportionalGroup") ~= true or excluded(guiObject) then
			continue
		end

		local v = referenceSize(guiObject, uIReferenceViewport)
		guiObject.SizeConstraint = Enum.SizeConstraint.RelativeXY
		guiObject.Size = UDim2.fromOffset(v.X, v.Y)
		local uIScale = Instance.new("UIScale")
		uIScale.Name = "ProportionalScale"
		uIScale.Scale = factor
		uIScale.Parent = guiObject
	end
end

function UIProportions.watch(folder)
	local v = {}
	local connections = {}

	local function add(guiObject)
		if v[guiObject] or not guiObject:IsA("GuiObject") or guiObject:GetAttribute("UIProportionalGroup") ~= true then
			return
		end

		if guiObject:FindFirstAncestorWhichIsA("ScreenGui") and not excluded(guiObject) then
			v[guiObject] = UIProportions.bind(guiObject)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function remove(k)
		local v2 = v[k]

		if v2 then
			v[k] = nil
			v2.destroy()
		end
	end

	table.insert(connections, folder.DescendantAdded:Connect(add))
	table.insert(connections, folder.DescendantRemoving:Connect(remove))

	for _, descendant in ipairs(folder:GetDescendants()) do
		add(descendant)
	end

	return function()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		for k in pairs(v) do
			remove(k) -- equivalent call inferred; original call site unknown
		end
	end
end

return UIProportions