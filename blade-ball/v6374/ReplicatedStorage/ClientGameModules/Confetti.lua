local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("Players")
local shapes = {
	Square = function()
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromOffset(30, 30)
		return frame
	end
}
local v2 = {}

for _, v3 in shapes do
	table.insert(v2, v3)
end

local v3 = {
	Color3.fromRGB(168, 100, 253),
	Color3.fromRGB(41, 205, 255),
	Color3.fromRGB(120, 255, 68),
	Color3.fromRGB(255, 113, 141),
	Color3.fromRGB(253, 255, 106)
}
local currentCamera = workspace.CurrentCamera
local v4 = {}
RunService.PostSimulation:Connect(function(dt: number)
	local viewportSize = currentCamera.ViewportSize

	for i = #v4, 1, -1 do
		local v5 = v4[i]
		local object = v5.Object
		local emitterPosition = v5.EmitterPosition
		local position = v5.Position
		local force = v5.Force
		local position2 = position - force * (viewportSize.Y / 1080)
		local force2 = force / createVector(1.09, 1.1, 0) - createVector(0, 1, 0) * dt * 60
		local color = v5.Color
		local size = v5.Size
		v5.Position = position2
		v5.Force = force2

		if force2.Y <= 0 then
			local side = v5.Side
			local side2 = size <= 0 and 1 or size >= 30 and -1 or v5.Side

			if side ~= side2 then
				local color2

				if side2 == 1 then
					color2 = v5.Color
				else
					color2 = Color3.new(color.R * 0.65, color.G * 0.65, color.B * 0.65)
				end

				if v5.IsImage then
					object.ImageColor3 = color2
				else
					object.BackgroundColor3 = color2
				end

				v5.Side = side2
			end

			local size2 = size + side2 * 2
			v5.Size = size2
			object.Size = UDim2.fromOffset(30, size2)
		end

		object.Position = UDim2.new(emitterPosition.X, position2.X, emitterPosition.Y, position2.Y)

		if not (object.AbsolutePosition.Y >= viewportSize.Y + object.AbsoluteSize.Y) then
			continue
		end

		object:Destroy()
		table.remove(v4, i)
	end
end)
local Confetti = {}
Confetti.shapes = shapes

function Confetti.createParticle(point: Vector2, point2: Vector2, parent, p, p2)
	local v5 = p2 or v3
	local v6 = p or v2
	local guiObject = v6[math.random(1, #v6)]()
	local v7 = v5[math.random(1, #v5)]
	local isImage = guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")

	if isImage then
		guiObject.ImageColor3 = v7
	else
		guiObject.BackgroundColor3 = v7
	end

	guiObject.Rotation = math.random(0, 360)
	guiObject.Parent = parent
	table.insert(v4, {
		Object = guiObject,
		IsImage = isImage,
		EmitterPosition = Vector3.new(point.X, point.Y),
		Position = createVector(0, 0, 0),
		Force = Vector3.new(point2.X, point2.Y + -math.abs(point2.X) * 0.75),
		Color = v7,
		Size = 1,
		Side = -1
	})
end

function Confetti.getProperParticlesToScreen()
	return (math.round(80 * (currentCamera.ViewportSize.Y / 1080)))
end

return Confetti