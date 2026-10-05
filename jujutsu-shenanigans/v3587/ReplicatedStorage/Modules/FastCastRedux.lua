local FastCastRedux = {
	DebugLogging = false,
	VisualizeCasts = false
}
FastCastRedux.__index = FastCastRedux
FastCastRedux.__type = "FastCast"
FastCastRedux.HighFidelityBehavior = {
	Default = 1,
	Always = 3
}
local ActiveCast = require(script.ActiveCast)
local Signal = require(script.Signal)
require(script.Table)
require(script.TypeDefinitions)
ActiveCast.SetStaticFastCastReference(FastCastRedux)

function FastCastRedux.new()
	return (setmetatable({
		LengthChanged = Signal.new("LengthChanged"),
		RayHit = Signal.new("RayHit"),
		RayPierced = Signal.new("RayPierced"),
		CastTerminating = Signal.new("CastTerminating"),
		WorldRoot = workspace
	}, FastCastRedux))
end

function FastCastRedux.newBehavior()
	return {
		RaycastParams = nil,
		Acceleration = Vector3.new(),
		MaxDistance = 1000,
		CanPierceFunction = nil,
		HighFidelityBehavior = FastCastRedux.HighFidelityBehavior.Default,
		HighFidelitySegmentSize = 0.5,
		CosmeticBulletTemplate = nil,
		CosmeticBulletProvider = nil,
		CosmeticBulletContainer = nil,
		AutoIgnoreContainer = true
	}
end

local behavior = FastCastRedux.newBehavior()

function FastCastRedux.Fire(p, vector: Vector3, vector2: Vector3, p2, p3)
	if p3 == nil then
		p3 = behavior
	end

	local v = ActiveCast.new(p, vector, vector2, p2, p3)
	v.RayInfo.WorldRoot = p.WorldRoot
	return v
end

return FastCastRedux