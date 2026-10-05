local createVector = vector.create
local _ = Vector3.new
local _ = math.abs
local _ = math.cos
local _ = math.sin
local _ = Vector2.new
local _ = math.rad
return {
	ConvertTo3D = function(_, p, p2)
		if p == nil then
			return
		end

		local screenPointToRay = game.Workspace.CurrentCamera:ScreenPointToRay(p.X, p.Y, p2)
		local _ = screenPointToRay.Origin
		local v = (p2 == nil or not (p2 > 0)) and createVector(0, 0, 0) or screenPointToRay.Direction * p2
		return screenPointToRay.Origin + v
	end
}