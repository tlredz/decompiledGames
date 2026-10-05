local TextService = game:GetService("TextService")
local OuwInterfaceUtilityHelper = require(script.OuwInterfaceUtilityHelper)
local Interfaceutility = {
	GetAbsoluteSize = function(p)
		local absoluteSize = p.AbsoluteSize

		if absoluteSize.X ~= 0 and absoluteSize.Y ~= 0 then
			return absoluteSize
		end

		local parent = p.Parent
		local parents = { p }

		while parent ~= nil and parent:IsA("GuiBase") and not (parent:IsA("BillboardGui") or parent:IsA("ScreenGui")) do
			local absoluteSize2 = parent.AbsoluteSize

			if absoluteSize2.X == 0 or absoluteSize2.Y == 0 then
				table.insert(parents, parent)
				parent = parent.Parent
			else
				absoluteSize = absoluteSize2
				break
			end
		end

		if absoluteSize.X == 0 or absoluteSize.Y == 0 then
			if parent == nil or not parent:IsA("BillboardGui") then
				absoluteSize = workspace.CurrentCamera.ViewportSize
			else
				absoluteSize = OuwInterfaceUtilityHelper.getBillboardGuiScreenSize(parent) or Vector2.zero
			end
		end

		for i = #parents, 1, -1 do
			local v = parents[i]
			absoluteSize = Vector2.new(
				absoluteSize.X * v.Size.X.Scale + v.Size.X.Offset,
				absoluteSize.Y * v.Size.Y.Scale + v.Size.Y.Offset
			)
			local uIAspectRatioConstraint = v:FindFirstChildWhichIsA("UIAspectRatioConstraint")

			if not uIAspectRatioConstraint then
				continue
			end

			local aspectRatio = uIAspectRatioConstraint.AspectRatio

			if uIAspectRatioConstraint.DominantAxis == Enum.DominantAxis.Width then
				absoluteSize = Vector2.new(absoluteSize.X, absoluteSize.X / aspectRatio)
			else
				absoluteSize = Vector2.new(absoluteSize.Y * aspectRatio, absoluteSize.Y)
			end
		end

		return absoluteSize
	end
}

function Interfaceutility.GetOffsetTextSize(p, point: Vector2?)
	local v = point or Interfaceutility.GetAbsoluteSize(p)
	local Y = v.Y
	local v2 = 1

	if Y < 1 then
		v2 = math.ceil(100 / Y)
		Y *= v2
	elseif Y > 100 then
		v2 = Y / 100
		Y = 100
	end

	local X = TextService:GetTextSize(p.Text, Y, p.Font, Vector2.new(1e999, Y)).X

	if v.Y < 1 then
		return X / v2
	end

	if v.Y > 100 then
		X *= v2
	end

	return X
end

function Interfaceutility.GetScaledTextSize(p, point: Vector2?)
	local v = point or Interfaceutility.GetAbsoluteSize(p)
	local absoluteSize = Interfaceutility.GetAbsoluteSize(p.Parent)
	return Interfaceutility.GetOffsetTextSize(p, v) / absoluteSize.X
end

return Interfaceutility