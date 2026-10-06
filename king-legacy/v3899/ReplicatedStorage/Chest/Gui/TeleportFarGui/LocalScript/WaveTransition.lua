local WaveTransition = {}
WaveTransition.__index = WaveTransition
local v = {}

local function DefaultWaveFunction(p: number, p2: number)
	local v2 = p2 * 1.5

	if p < v2 - 0.5 then
		return 1
	end

	if v2 < p then
		return 0
	end

	return math.cos(6.283185307179586 * (p - v2 + 0.5)) * 0.5 + 0.5
end

function WaveTransition.new(instance, data)
	local width = not (data and data.width) and 10 or data.width or 10
	local size = instance.AbsoluteSize.X / width
	local height = math.ceil(instance.AbsoluteSize.Y / size)
	local v5 = {
		squares = table.create(width * height),
		percents = table.create(width * height),
		color = data and data.color and data.color or Color3.new(0, 0, 0),
		width = width,
		height = height,
		size = size,
		rotation = 45,
		waveDirection = data and data.waveDirection and data.waveDirection or Vector2.new(1, 1),
		waveFunction = data and data.waveFunction and data.waveFunction or DefaultWaveFunction
	}

	if instance ~= v then
		local v6 = 1e999
		local v7 = -1e999

		for i = 1, v5.height do
			for i2 = 1, v5.width do
				local vector = Vector2.new((i2 - 1) * v5.size, (i - 1) * v5.size)
				local frame = Instance.new("Frame")
				frame.AnchorPoint = Vector2.new(0.5, 0.5)
				frame.Size = UDim2.fromOffset(v5.size + 1, v5.size + 1)
				frame.Position = UDim2.fromOffset(vector.X + v5.size / 2, vector.Y + v5.size / 2)
				frame.BackgroundColor3 = v5.color
				frame.Rotation = v5.rotation
				frame.BorderSizePixel = 0
				frame.Parent = instance:FindFirstChild("Frame") or instance
				local dot = v5.waveDirection:Dot(vector)

				if dot < v6 then
					v6 = dot
				end

				if v7 < dot then
					v7 = dot
				end

				local v8 = (i - 1) * v5.width + i2
				v5.squares[v8] = frame
				v5.percents[v8] = dot
			end
		end

		for i, _ in ipairs(v5.squares) do
			v5.percents[i] = (v5.percents[i] - v6) / (v7 - v6)
		end
	end

	setmetatable(v5, WaveTransition)
	return v5
end

function WaveTransition:_UpdateOne(p2, p3: number, p4: number)
	local waveFunction = self.waveFunction(p3, p4)
	p2.Size = UDim2.fromOffset(waveFunction * (self.size + 1) * 1.5, waveFunction * (self.size + 1) * 1.5)
end

function WaveTransition:Update(p)
	for i, square in ipairs(self.squares) do
		self:_UpdateOne(square, self.percents[i], p)
	end
end

function WaveTransition:Destroy()
	for _, square in ipairs(self.squares) do
		square:Destroy()
	end

	self.squares = nil
	self.percents = nil
end

return WaveTransition