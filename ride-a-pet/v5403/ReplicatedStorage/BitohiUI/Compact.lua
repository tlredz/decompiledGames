local Compact = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function camera()
	return workspace.CurrentCamera
end

function Compact.viewport()
	local currentCamera = camera() -- equivalent call inferred; original call site unknown
	return currentCamera and currentCamera.ViewportSize or Vector2.new(1920, 1080)
end

function Compact.isPhone(value)
	return Compact.viewport().Y < (value or 560)
end

local v = {
	{
		attr = "CompactSize",
		prop = "Size"
	},
	{
		attr = "CompactPosition",
		prop = "Position"
	},
	{
		attr = "CompactAnchor",
		prop = "AnchorPoint"
	},
	{
		attr = "CompactVisible",
		prop = "Visible"
	}
}

function Compact.bind(folder)
	local compactViewportHeight = folder:GetAttribute("CompactViewportHeight") or 560
	local v2 = {}

	local function collect(guiObject)
		if not guiObject:IsA("GuiObject") then
			return
		end

		local v3 = nil

		for _, v4 in ipairs(v) do
			local attribute = guiObject:GetAttribute(v4.attr)

			if attribute == nil then
				continue
			end

			v3 = v3 or {
				inst = guiObject,
				props = {}
			}
			v3.props[#v3.props + 1] = {
				prop = v4.prop,
				desktop = guiObject[v4.prop],
				compact = attribute
			}
		end

		if guiObject:GetAttribute("CompactDropAspect") then
			local uIAspectRatioConstraint = guiObject:FindFirstChildOfClass("UIAspectRatioConstraint")

			if uIAspectRatioConstraint then
				v3 = v3 or {
					inst = guiObject,
					props = {}
				}
				v3.aspect = uIAspectRatioConstraint
			end
		end

		if v3 then
			v2[#v2 + 1] = v3
		end
	end

	collect(folder)

	for _, descendant in ipairs(folder:GetDescendants()) do
		collect(descendant)
	end

	local v3 = {
		IsCompact = nil
	}

	local function apply(isCompact)
		if v3.IsCompact == isCompact then
			return
		end

		v3.IsCompact = isCompact

		for _, v4 in ipairs(v2) do
			if not v4.inst.Parent then
				continue
			end

			for _, v5 in ipairs(v4.props) do
				if isCompact then
					v4.inst[v5.prop] = v5.compact
				else
					v4.inst[v5.prop] = v5.desktop
				end
			end

			if not v4.aspect then
				continue
			end

			if isCompact then
				v4.aspect.Parent = nil
			else
				v4.aspect.Parent = v4.inst
			end
		end
	end

	function v3:Refresh()
		apply(Compact.viewport().Y < compactViewportHeight)
	end

	local currentCamera = camera() -- equivalent call inferred; original call site unknown
	local viewportSizeChangedConnection = currentCamera and currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		v3:Refresh()
	end)

	function v3.Stop(_)
		if viewportSizeChangedConnection then
			viewportSizeChangedConnection:Disconnect()
		end

		apply(false)
	end

	v3:Refresh()
	return v3
end

return Compact