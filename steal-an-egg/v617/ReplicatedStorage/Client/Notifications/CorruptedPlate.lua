local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local corruptedPlate = ReplicatedStorage.Assets.UI.Notifs.CorruptedPlate
local v = {
	{
		Color = Color3.fromRGB(115, 255, 77),
		Drift = -1
	},
	{
		Color = Color3.fromRGB(179, 58, 255),
		Drift = 1
	}
}

local function startsWith(value: string, list: string)
	return string.sub(value, 1, #list) == list
end

local function makeGhost(instance, instance2, color: Color3, drift: number)
	local clone = instance:Clone(instance2)
	clone.Name = "SignalGhost"
	clone.ZIndex = instance2.ZIndex - 1

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("UIStroke") then
			descendant.Enabled = false
		elseif descendant:IsA("ImageLabel") then
			descendant.ImageTransparency = 1
		end
	end

	local labelsByLabel = {}

	for _, label in instance2:GetChildren() do
		local label2 = clone:FindFirstChild(label.Name)

		if not (label:IsA("TextLabel") and label2 ~= nil and label2:IsA("TextLabel")) then
			continue
		end

		label2.RichText = false
		label2.Text = label.ContentText
		label2.TextColor3 = color
		label2.TextStrokeTransparency = 1
		label2.TextTransparency = 1
		labelsByLabel[label] = label2
	end

	clone.Parent = instance2.Parent
	return {
		Row = clone,
		Drift = drift,
		Labels = labelsByLabel
	}
end

return table.freeze({
	Attach = function(parent, instance)
		local v3 = Trove.new()
		v3:AttachToInstance(parent)
		local clone = v3:Clone(corruptedPlate)
		clone.ZIndex = instance.ZIndex - 2
		clone.Parent = parent

		local function stop()
			v3:Clean()
		end

		local scale = clone.Size.Y.Scale

		local function fitWidth()
			local X = parent.AbsoluteSize.X

			if X <= 0 then
				return
			end

			local total = 0

			for _, label in instance:GetChildren() do
				if label:IsA("TextLabel") and label.Visible then
					total += label.AbsoluteSize.X
				end
			end

			local v4 = math.clamp(total / X + 0.2, 0.3, 1)
			clone.Size = UDim2.fromScale(v4, scale)
		end

		fitWidth()

		if GuiService.ReducedMotionEnabled then
			v3:Connect(RunService.RenderStepped, fitWidth)
			return stop
		end

		local guiObjects = {}
		local guiObjects2 = {}
		local v4 = {}

		for _, guiObject in clone:GetChildren() do
			if string.sub(guiObject.Name, 1, 9) == "ChargeArc" and guiObject:IsA("ImageLabel") then
				table.insert(guiObjects, guiObject)
			elseif string.sub(guiObject.Name, 1, 10) == "ChargeGlow" and guiObject:IsA("ImageLabel") then
				table.insert(guiObjects2, guiObject)
			elseif string.sub(guiObject.Name, 1, 10) == "SignalTear" and guiObject:IsA("GuiObject") then
				table.insert(v4, {
					Frame = guiObject,
					Position = guiObject.Position
				})
			end
		end

		local v5 = {}

		for _, v6 in v do
			table.insert(v5, (makeGhost(v3, instance, v6.Color, v6.Drift)))
		end

		local scan = clone:FindFirstChild("Scan")
		local v6 = scan == nil and 0 or scan.Position.Y.Scale
		local v7 = 1 - v6 * 2
		local position = instance.Position
		local total = 0
		local v8 = -1
		v3:Connect(RunService.RenderStepped, function(p: number)
			total += p
			fitWidth()
			local v9 = math.floor(total * 14)

			if v9 ~= v8 then
				v8 = v9

				for _, v10 in guiObjects do
					local cells = v10:GetAttribute("Cells")

					if not (typeof(cells) == "Vector2" and cells.X > 0 and cells.Y > 0) then
						continue
					end

					local v11 = v9 + (v10:GetAttribute("Phase") or 0) * 5
					v10.ImageRectOffset = Vector2.new(
						v10.ImageRectSize.X * (v11 % cells.X),
						v10.ImageRectSize.Y * (math.floor(v11 / cells.X) % cells.Y)
					)
				end
			end

			local v10 = total % 1.45
			local v11 = not (v10 < 0.23) and 0 or 1 - v10 / 0.23
			local v12 = math.sin(total * 173) * v11

			for _, v13 in v5 do
				local v14 = v13.Drift * (math.abs(v12) * 0.007 + 0.004)
				v13.Row.Position = position + UDim2.fromScale(v14, 0)

				for k, label in v13.Labels do
					if label.Text ~= k.ContentText then
						label.Text = k.ContentText
					end

					label.TextSize = k.TextSize
					label.TextScaled = k.TextScaled
					label.TextWrapped = k.TextWrapped
					label.TextTransparency = 1 - v11 * 0.53
				end
			end

			for _, v13 in v4 do
				local drift = v13.Frame:GetAttribute("Drift") or 1
				local phase = v13.Frame:GetAttribute("Phase") or 0
				v13.Frame.Position = v13.Position + UDim2.fromScale(v12 * 0.017 * drift, 0)
				v13.Frame.BackgroundTransparency = 0.67 - v11 * 0.43 + math.sin(total * 2 + phase) * 0.12
			end

			for _, v13 in guiObjects2 do
				local phase = v13:GetAttribute("Phase") or 0
				v13.ImageTransparency = math.sin(total * 2.2 + phase) * 0.035 + 0.9
			end

			if scan ~= nil then
				scan.Position = UDim2.fromScale(scan.Position.X.Scale, v6 + total * 0.45 % 1 * v7)
			end
		end)
		return stop
	end
})