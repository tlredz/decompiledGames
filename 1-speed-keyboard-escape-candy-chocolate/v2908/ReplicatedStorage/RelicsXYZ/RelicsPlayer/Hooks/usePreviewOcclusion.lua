local Players = game:GetService("Players")
local shared = script.Parent.Parent.Parent.Shared
local React = require(shared.React)
local parent = script.Parent
local useClock = require(parent.useClock)

local function rectsOverlap(point: Vector2, point2: Vector2, point3: Vector2, point4: Vector2)
	return point.X < point3.X + point4.X and point.X + point2.X > point3.X and point.Y < point3.Y + point4.Y and point.Y + point2.Y > point3.Y
end

local function usePreviewOcclusion(p)
	local ref = React.useRef({})
	React.useEffect(function()
		return function()
			for k, visible in ref.current do
				if k and k.Parent then
					k.Visible = visible
				end
			end

			table.clear(ref.current)
		end
	end, {})
	useClock(20, function()
		local current = p.current

		if not (current and current.Parent) then
			return
		end

		local absolutePosition = current.AbsolutePosition
		local absoluteSize = current.AbsoluteSize

		if absoluteSize.X == 0 or absoluteSize.Y == 0 then
			return
		end

		local localPlayer = Players.LocalPlayer

		if not localPlayer then
			return
		end

		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			return
		end

		local screenGui = current:FindFirstAncestorWhichIsA("ScreenGui")
		local v = not screenGui and 0 or screenGui.DisplayOrder or 0
		local v2 = {}
		local scanGuiObject

		scanGuiObject = function(guiObject)
			local v3 = ref.current[guiObject] ~= nil

			if not (v3 or guiObject.Visible) then
				return
			end

			local absolutePosition2 = guiObject.AbsolutePosition
			local absoluteSize2 = guiObject.AbsoluteSize
			local absolutePosition3 = absolutePosition
			local absoluteSize4 = absoluteSize
			local v6

			if absolutePosition2.X < absolutePosition3.X + absoluteSize4.X and absolutePosition2.X + absoluteSize2.X > absolutePosition3.X and absolutePosition2.Y < absolutePosition3.Y + absoluteSize4.Y then
				v6 = absolutePosition2.Y + absoluteSize2.Y > absolutePosition3.Y
			else
				v6 = false
			end

			if v6 then
				local absoluteSize3 = guiObject.AbsoluteSize

				if not (absoluteSize3.X * absoluteSize3.Y >= absoluteSize.X * absoluteSize.Y) then
					v2[guiObject] = true

					if not v3 then
						ref.current[guiObject] = guiObject.Visible
						guiObject.Visible = false
					end
				end
			else
				for _, guiObject2 in guiObject:GetChildren() do
					if guiObject2:IsA("GuiObject") then
						scanGuiObject(guiObject2)
					end
				end
			end
		end

		for _, screenGui2 in playerGui:GetChildren() do
			if screenGui2 == screenGui or not screenGui2:IsA("ScreenGui") or v < screenGui2.DisplayOrder then
				continue
			end

			for _, guiObject in screenGui2:GetChildren() do
				if guiObject:IsA("GuiObject") then
					scanGuiObject(guiObject)
				end
			end
		end

		local v3 = {}

		for k in ref.current do
			if not v2[k] then
				table.insert(v3, k)
			end
		end

		for _, v4 in v3 do
			if v4 and v4.Parent then
				v4.Visible = ref.current[v4] or false
			end

			ref.current[v4] = nil
		end
	end, {})
end

return usePreviewOcclusion