local RunService = game:GetService("RunService")
local v = {}
local v2 = 0
local heartbeatConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function drawFrame(data)
	local imageRectSize = data.Image.ImageRectSize
	local v3 = data.Frame % data.Cells.X
	local v4 = math.floor(data.Frame / data.Cells.X)
	data.Image.ImageRectOffset = Vector2.new(imageRectSize.X * v3, imageRectSize.Y * v4)
end

local function step(p: number)
	for _, v3 in pairs(v) do
		v3.Elapsed += p

		if v3.Elapsed < v3.SecondsPerFrame then
			continue
		end

		local v4 = math.floor(v3.Elapsed / v3.SecondsPerFrame)
		v3.Elapsed -= v4 * v3.SecondsPerFrame
		v3.Frame = (v3.Frame + v4) % (v3.Cells.X * v3.Cells.Y)
		drawFrame(v3) -- equivalent call inferred; original call site unknown
	end
end

return {
	Bind = function(self)
		assert(
			self:IsA("ImageLabel") or self:IsA("ImageButton"),
			(`{self:GetFullName()} must be an ImageLabel or ImageButton to play a sprite sheet`)
		)
		local spriteCells = self:GetAttribute("SpriteCells")
		local v3

		if typeof(spriteCells) == "Vector2" and spriteCells.X >= 1 then
			v3 = spriteCells.Y >= 1
		else
			v3 = false
		end

		assert(v3, (`{self:GetFullName()} needs a SpriteCells Vector2 attribute holding (columns, rows)`))
		local spriteFPS = self:GetAttribute("SpriteFPS") or 24
		local v4

		if typeof(spriteFPS) == "number" then
			v4 = spriteFPS > 0
		else
			v4 = false
		end

		assert(v4, (`{self:GetFullName()} SpriteFPS must be a number above zero`))
		local v5 = {
			Cells = spriteCells,
			Elapsed = 0,
			Frame = 0,
			Image = self,
			OriginalOffset = self.ImageRectOffset,
			SecondsPerFrame = 1 / spriteFPS
		}
		v[self] = v5
		v2 += 1
		drawFrame(v5) -- equivalent call inferred; original call site unknown

		if heartbeatConnection == nil then
			heartbeatConnection = RunService.Heartbeat:Connect(step)
		end

		return function()
			if v[self] == nil then
				return
			end

			v[self] = nil
			v2 -= 1
			self.ImageRectOffset = v5.OriginalOffset

			if v2 == 0 and heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end
	end
}