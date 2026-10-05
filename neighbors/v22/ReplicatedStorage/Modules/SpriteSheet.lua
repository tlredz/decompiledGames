local RunService = game:GetService("RunService")
local vector = Vector2.new(1024, 1024)

-- equivalent calls inferred from this helper; original call sites unknown
local function getFrameSize(data)
	local imageSize = data.ImageSize or vector
	return Vector2.new(imageSize.X / data.Columns, imageSize.Y / data.Rows)
end

local SpriteSheet = {}

function SpriteSheet:ApplyFrame(p, data, p2: number)
	local frameSize = getFrameSize(data) -- equivalent call inferred; original call site unknown
	local v = (p2 - 1) % data.Columns
	local v2 = (p2 - 1) // data.Columns
	p.ImageRectSize = frameSize
	p.ImageRectOffset = Vector2.new(v * frameSize.X, v2 * frameSize.Y)
end

function SpriteSheet:Play(p, data)
	local frames = data.Frames or data.Rows * data.Columns
	local lastTime = os.clock()
	local v = 1
	self:ApplyFrame(p, data, v)
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v2 = math.floor((os.clock() - lastTime) * data.Framerate) % frames + 1

		if v2 ~= v then
			v = v2
			self:ApplyFrame(p, data, v2)
		end
	end)
	return function()
		heartbeatConnection:Disconnect()
		p.ImageRectSize = Vector2.zero
		p.ImageRectOffset = Vector2.zero
	end
end

return SpriteSheet