local GamepadPages = require(script.Parent.GamepadPages)
local ButtonActions = require(script.Parent.ButtonActions)
local v = {
	A = "ButtonA",
	B = "ButtonB"
}

local function hint(parent, p)
	local selected = parent:FindFirstChild("手柄" .. p) or parent:FindFirstChild("手柄按键提示")

	if not selected then
		selected = Instance.new("ImageLabel")
		selected.BackgroundTransparency = 1
		selected.AnchorPoint = Vector2.new(1, 0.5)
		selected.Position = UDim2.fromScale(0.96, 0.5)
		selected.SizeConstraint = Enum.SizeConstraint.RelativeYY
		selected.Size = UDim2.fromScale(0.45, 0.45)
		selected.ZIndex = parent.ZIndex + 2
		selected.Parent = parent
	end

	selected.Name = "手柄" .. p
	selected.Image = "rbxasset://textures/ui/Controls/XboxController/" .. v[p] .. "@2x.png"
	selected:SetAttribute("PromptMode", nil)
	return selected
end

return {
	new = function(p, options)
		local options2 = options or {}
		GamepadPages.Observe(p, {
			available = options2.isOpen,
			defaultButton = options2.directA,
			scroll = options2.scroll
		})
		return {
			handles = {},
			options = options2,
			Bind = function(p2, parent, p4, _, p5)
				parent.Active = p5 ~= false
				parent.Interactable = p5 ~= false
				parent.Selectable = p5 ~= false

				if parent == options2.closeButton then
					hint(parent, "B")
				elseif parent == options2.directA then
					hint(parent, "A")
				end

				local v3 = ButtonActions.Bind(parent, p4)
				p2.handles[parent] = v3
				GamepadPages.Invalidate(p)
				GamepadPages.Refresh()
				return v3
			end,
			Unbind = function(p2, p3)
				local handle = p2.handles[p3]

				if handle then
					handle:Disconnect()
					p2.handles[p3] = nil
				end
			end,
			Refresh = function(_)
				GamepadPages.Refresh()
			end
		}
	end
}