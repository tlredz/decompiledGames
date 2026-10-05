local currentCamera = workspace.CurrentCamera
local OuwInterfaceUtilityHelper = {
	getPixelsPerStud = function(p)
		local viewportSize = currentCamera.ViewportSize
		local v = p * math.tan((math.rad(currentCamera.FieldOfView / 2)))
		return viewportSize.Y / 2 / v
	end
}

function OuwInterfaceUtilityHelper.getBillboardGuiScreenSize(instance)
	if instance == nil then
		return
	end

	local adornee = instance.Adornee or instance.Parent

	if adornee == nil then
		return
	end

	local v

	if adornee:IsA("Model") then
		v = adornee:GetPivot().Position
	else
		v = adornee.Position
	end

	local v2 = math.max(
		(currentCamera.CFrame.Position - v).Magnitude,
		(math.max(instance.Size.X.Scale, instance.Size.Y.Scale))
	)
	local pixelsPerStud = OuwInterfaceUtilityHelper.getPixelsPerStud(v2)
	return (Vector2.new(instance.Size.X.Scale * pixelsPerStud, instance.Size.Y.Scale * pixelsPerStud))
end

return OuwInterfaceUtilityHelper