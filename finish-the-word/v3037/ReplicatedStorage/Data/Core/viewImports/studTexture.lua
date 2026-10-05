local import = _G.import("romodel")
local RunService = game:GetService("RunService")
local model = import.model("ImageLabel")

function model.init()
	return {
		Image = "rbxassetid://99057321484987",
		ImageTransparency = 0.2,
		ScaleType = Enum.ScaleType.Tile
	}
end

function model.prespawn(p)
	local v = p.AbsoluteSize.X / p.AbsoluteSize.Y
	return {
		ImageRectSize = Vector2.new(500, 500 / v) * 1
	}
end

function model:spawn()
	if RunService:IsServer() or self.StudTextureCon then
		return
	end

	local vector = Vector2.new(0, 0)
	local texturePeriod = self.TexturePeriod or Vector2.new(400, 400)
	local textureSpeed = self.TextureSpeed or Vector2.new(50, 50)
	self.StudTextureCon = RunService.RenderStepped:Connect(function(dt)
		vector = Vector2.new(
			(vector.X + textureSpeed.X * dt) % texturePeriod.X,
			(vector.Y + textureSpeed.Y * dt) % texturePeriod.Y
		)
		self.ImageRectOffset = Vector2.new(math.floor(vector.X), (math.floor(vector.Y)))
	end)
end

function model:despawn()
	if not self.StudTextureCon then
		return
	end

	self.StudTextureCon:Disconnect()
	self.StudTextureCon = nil
end

return {
	StudTexture = model
}