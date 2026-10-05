local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TouchCombatLayout = require(script.Parent.TouchCombatLayout)
local v = {}
local EquipmentHudLayout = {}

function EquipmentHudLayout.register(instance, scale, order)
	v[instance] = {
		scale = scale,
		order = order
	}
	instance:SetAttribute("UIProportionalExclude", true)
	instance.Destroying:Once(function()
		v[instance] = nil
	end)
end

function EquipmentHudLayout.update(instance)
	local HUD = instance:FindFirstChild("HUD")
	local mainFrame = HUD and HUD:FindFirstChild("MainFrame")
	local barMainFrame = mainFrame and mainFrame:FindFirstChild("BarMainFrame")

	if not barMainFrame then
		return
	end

	local v2 = {}

	for k, v3 in v do
		if k.Parent and k.Visible then
			table.insert(v2, {
				button = k,
				scale = v3.scale,
				order = v3.order
			})
		end
	end

	table.sort(v2, function(a, b)
		return a.order < b.order
	end)
	local count = #v2

	if count == 0 then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or HUD.AbsoluteSize

	if UserInputService.TouchEnabled then
		local absoluteSize = HUD.AbsoluteSize
		local v3 = math.min(absoluteSize.X, absoluteSize.Y) <= 500
		local v4 = v3 and 70 or 120
		local v5 = {
			x = absoluteSize.X - (v4 * 1.5 - 10),
			y = absoluteSize.Y - (v3 and v4 + 20 or v4 * 1.75),
			w = v4,
			h = v4
		}
		local melee = TouchCombatLayout.rectangles(absoluteSize.X, absoluteSize.Y, v5).Melee
		local meleeButton = HUD:FindFirstChild("MeleeButton")
		local guiInset = not HUD.IgnoreGuiInset and GuiService:GetGuiInset() or Vector2.zero
		local Y = HUD.AbsolutePosition.Y + melee.y - guiInset.Y

		if meleeButton and meleeButton.Visible and meleeButton.AbsoluteSize.Y > 0 then
			Y = meleeButton.AbsolutePosition.Y
		end

		local v6 = math.max(10, v4 * 0.75 * 0.16)
		local v7 = Y - v6
		local scale = math.min(
			v4 * 0.75 / 88 * 0.85,
			(absoluteSize.X - 16) / 226,
			math.max(1, v7 - 12 - (count - 1) * v6) / (count * 88)
		)
		local v9 = math.min(absoluteSize.X - 8, v5.x + v5.w)
		local v10 = v7 - count * 88 * scale - (count - 1) * v6

		for k, v11 in v2 do
			v11.scale.Scale = scale
			v11.button.AnchorPoint = Vector2.new(1, 0)
			local absolutePosition = v11.button.Parent.AbsolutePosition
			v11.button.Position = UDim2.fromOffset(
				v9 - absolutePosition.X,
				v10 + (k - 1) * (scale * 88 + v6) - absolutePosition.Y
			)
		end
	else
		local v3 = math.min(
			1,
			math.min(barMainFrame.AbsoluteSize.X, viewportSize.X * 0.92) / (count * 226 + (count - 1) * 10),
			viewportSize.Y * 0.14 / 88
		)
		local v4 = math.max(v3 * 88, barMainFrame.AbsolutePosition.Y - v3 * 8)
		local scale = v3 * 0.85
		local v6 = (count * 226 + (count - 1) * 10) * scale
		local v7 = math.clamp(
			barMainFrame.AbsolutePosition.X + barMainFrame.AbsoluteSize.X * 0.5 - v6 * 0.5,
			0,
			(math.max(0, viewportSize.X - v6))
		)

		for k, v8 in v2 do
			v8.scale.Scale = scale
			v8.button.AnchorPoint = Vector2.new(0, 1)
			local absolutePosition = v8.button.Parent.AbsolutePosition
			v8.button.Position = UDim2.fromOffset(
				v7 + (k - 1) * 236 * scale - absolutePosition.X,
				v4 - absolutePosition.Y
			)
		end
	end
end

return EquipmentHudLayout