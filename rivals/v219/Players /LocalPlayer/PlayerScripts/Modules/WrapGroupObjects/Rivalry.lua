local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._moving_textures = {}
	self:_Init()
	return self
end

function object:Update(_)
	local v = workspace:GetServerTimeNow() / 7

	for k, _moving_texture in pairs(self._moving_textures) do
		local v2 = self:_GetCameraOffset() / _moving_texture
		k.OffsetStudsU = v2.Z + v % k.StudsPerTileU
		k.OffsetStudsV = v2.Y + v % k.StudsPerTileV
	end
end

function object:_GetCameraOffset()
	return self.Object.Position - (workspace.CurrentCamera.CFrame * workspace.CurrentCamera.Focus).Position
end

function object:_Setup()
	for _, texture in pairs(self.ExtraObjects) do
		if texture:IsA("Texture") then
			self._moving_textures[texture] = texture.Name == "RibbonTexture2" and 800 or 1300
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object