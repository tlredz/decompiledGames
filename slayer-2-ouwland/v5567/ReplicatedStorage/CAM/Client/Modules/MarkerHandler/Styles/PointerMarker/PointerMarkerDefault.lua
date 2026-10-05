local createVector = vector.create
local TweenService = game:GetService("TweenService")
local PointerMarkerDefault = {
	createWeld = function(part, p, object)
		local weld = Instance.new("Weld")
		weld.Part0 = part
		weld.Part1 = p
		weld.Parent = p
		weld.C0 = CFrame.new(0, -math.min(object:GetExtentsSize().Y / 2, 3) + 0.02, 0)
	end
}

function PointerMarkerDefault.createInterface(p, _)
	if p.in3DSpace == true then
		local character = game.Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local part = Instance.new("Part")
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		part.Massless = true
		part.CanTouch = false
		part.Size = createVector(0, 0.02, 0)
		TweenService:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Size = createVector(11, 0.02, 11)
		}):Play()
		PointerMarkerDefault.createWeld(humanoidRootPart, part, character)
		local surfaceGui = Instance.new("SurfaceGui", part)
		surfaceGui.Face = "Top"
		surfaceGui.Name = "msg"
		local frame = Instance.new("Frame", surfaceGui)
		frame.Name = "Holder"
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		Instance.new("UIAspectRatioConstraint", frame)
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundTransparency = 1
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Size = UDim2.fromScale(0.6, 0.6)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Name = "Pointer"
		imageLabel.AnchorPoint = Vector2.new(0.5, 0)
		imageLabel.Position = UDim2.fromScale(0.5, 0)
		imageLabel.Image = "rbxassetid://17374675196"
		imageLabel.Parent = frame
		imageLabel.ImageColor3 = p.color or Color3.new(1, 1, 1)
		return part
	else
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Size = UDim2.fromScale(0.4, 0.4)
		}):Play()
		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.Parent = frame
		frame.Transparency = 1
		local frame2 = Instance.new("Frame")
		frame2.Size = UDim2.fromScale(1, 1)
		frame2.Parent = frame
		frame2.Position = UDim2.fromScale(0.5, 0.5)
		frame2.Name = "Holder"
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.BackgroundTransparency = 1
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Size = UDim2.fromScale(0.4, 0.4)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Name = "Pointer"
		imageLabel.AnchorPoint = Vector2.new(0.5, 0)
		imageLabel.Position = UDim2.fromScale(0.5, 0)
		imageLabel.Image = "rbxassetid://17374675196"
		imageLabel.Parent = frame2
		imageLabel.ImageColor3 = p.color or Color3.new(1, 1, 1)
		return frame
	end
end

function PointerMarkerDefault.applyOpacity(p, p2, p3)
	if p == nil or p2 == nil then
		return
	end

	local pointer

	if p3 == true then
		pointer = p.msg.Holder.Pointer
	else
		pointer = p.Holder.Pointer
	end

	if pointer:FindFirstChild("DefaultTransparency") == nil then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "DefaultTransparency"
		numberValue.Parent = pointer
		numberValue.Value = 1 - pointer.ImageTransparency
	end

	local value = pointer.DefaultTransparency.Value
	pointer.ImageTransparency = value * p2 / value
end

return PointerMarkerDefault