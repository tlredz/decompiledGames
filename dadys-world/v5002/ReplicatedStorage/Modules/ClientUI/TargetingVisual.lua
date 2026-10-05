local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local TargetingVisual = {}

function TargetingVisual.Show(p, instance, p2)
	if typeof(p.CreateTargetVisual) == "function" then
		return p.CreateTargetVisual(instance, p2)
	end

	local targetVisual = p.TargetVisual or {}
	local billboard = {
		Label = targetVisual.text or p2 and "MACHINE" or "TARGET",
		Size = targetVisual.size or p2 and UDim2.new(16, 0, 16, 0) or UDim2.new(6, 0, 6, 0),
		TextColor = targetVisual.textColor,
		IconColor = targetVisual.iconColor,
		Image = targetVisual.image,
		ImageScaleType = targetVisual.imageScaleType,
		ImageSize = targetVisual.imageSize,
		ImagePosition = targetVisual.imagePosition,
		ImageAnchorPoint = targetVisual.imageAnchorPoint,
		ExtentsOffsetWorldSpace = targetVisual.extentsOffsetWorldSpace,
		LabelSize = targetVisual.labelSize
	}

	if p2 then
		billboard.Adornee = instance:FindFirstChild("GuiAttachPoint") or instance.PrimaryPart
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
		billboard.Adornee = humanoidRootPart

		if targetVisual.offset then
			billboard.StudsOffset = targetVisual.offset
		elseif humanoidRootPart then
			local boundingBox, v2 = instance:GetBoundingBox()
			billboard.StudsOffset = Vector3.new(
				0,
				boundingBox.Position.Y + v2.Y * 0.5 - humanoidRootPart.Position.Y + 1,
				0
			)
		end
	end

	return HighlightController:PlayHighlight(instance, "Target", {
		FillColor = targetVisual.highlightColor or Color3.fromRGB(255, 255, 255),
		FillTransparency = targetVisual.highlightTransparency or 0.85,
		OutlineColor = targetVisual.highlightColor or Color3.fromRGB(255, 255, 255),
		OutlineTransparency = 0,
		Billboard = billboard,
		Priority = HighlightController.Priority.LOCAL_ABILITY
	})
end

function TargetingVisual.Clear(instance, instance2)
	if instance then
		instance:Destroy()
	end

	if instance2 then
		instance2:Destroy()
	end
end

return TargetingVisual