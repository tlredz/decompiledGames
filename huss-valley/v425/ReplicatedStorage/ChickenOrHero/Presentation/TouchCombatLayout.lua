local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local TouchCombatLayout = {
	rectangles = function(p, _, data)
		local v = math.min(data.w, data.h) * 0.75
		local v2 = math.max(6, v * 0.08)
		local v3 = data.x + data.w
		local v4 = data.x + (data.w - v) / 2
		local v5 = data.y + (data.h - v) / 2
		local v6 = v4 - v2 - v
		local v7 = v5 - v2 - v
		local v8 = v * 226 / 88
		local v9 = v7 - v2 - v
		local ability, v11

		if v8 * 2 + v2 <= v3 - 8 then
			ability = {
				x = v3 - v8,
				y = v9,
				w = v8,
				h = v
			}
			v11 = {
				x = v3 - v8 * 2 - v2,
				y = v9,
				w = v8,
				h = v
			}
		else
			local v12 = math.min(v8, p - 16)
			local v13 = v12 * 88 / 226
			local v14 = v7 - v2 - v13
			ability = {
				x = math.max(8, v3 - v12),
				y = v14,
				w = v12,
				h = v13
			}
			v11 = {
				x = ability.x,
				y = v14 - v2 - v13,
				w = v12,
				h = v13
			}
		end

		return {
			Catch = {
				x = v4,
				y = v5,
				w = v,
				h = v
			},
			Melee = {
				x = v6,
				y = v7,
				w = v,
				h = v
			},
			Ability = ability,
			Item = v11
		}
	end
}

function TouchCombatLayout.place(p, folder, p2)
	folder:SetAttribute("UIProportionalExclude", true)
	folder:SetAttribute("UIProportionalGroup", nil)

	for _, uIScale in folder:GetDescendants() do
		if uIScale:IsA("UIScale") and uIScale.Name == "ProportionalScale" then
			uIScale:Destroy()
		end
	end

	if not UserInputService.TouchEnabled then
		return false
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return false
	end

	local HUD = localPlayer.PlayerGui:FindFirstChild("HUD")
	local absoluteSize = HUD and HUD.AbsoluteSize or currentCamera.ViewportSize
	local v = math.min(absoluteSize.X, absoluteSize.Y) <= 500
	local v2 = v and 70 or 120
	local v3 = {
		x = absoluteSize.X - (v2 * 1.5 - 10),
		y = absoluteSize.Y - (v and v2 + 20 or v2 * 1.75),
		w = v2,
		h = v2
	}
	local v4 = TouchCombatLayout.rectangles(absoluteSize.X, absoluteSize.Y, v3)[p]
	local screenGui = folder:FindFirstAncestorWhichIsA("ScreenGui")
	local guiInset = screenGui and not screenGui.IgnoreGuiInset and GuiService:GetGuiInset() or Vector2.zero
	folder.AnchorPoint = Vector2.zero
	folder.Position = UDim2.fromOffset(v4.x - guiInset.X, v4.y - guiInset.Y)

	if p2 then
		p2.Scale = v4.w / 226
	else
		folder.Size = UDim2.fromOffset(v4.w, v4.h)
	end

	return true
end

return TouchCombatLayout