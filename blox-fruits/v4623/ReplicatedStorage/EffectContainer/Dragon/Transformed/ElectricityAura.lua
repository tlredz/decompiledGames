game:GetService("RunService")
local LightningBolt2 = require(game.ReplicatedStorage.Util.LightningBolt2)
local Tween = require(game.ReplicatedStorage.Util.Tween)
local currentCamera = workspace.CurrentCamera
local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(_)
	local now = tick()

	for k, v2 in pairs(v) do
		local v3 = now - v2.Start

		if v2.CheckDestroy and not v2.CheckDestroy.Parent or v2.Lifetime < v3 then
			v[k] = nil
		else
			if v2.Frame % v2.FrameSpawn == 0 then
				local magnitude = (currentCamera.CFrame.p - v2.CFrame.p).Magnitude
				local v4 = v3 / v2.Lifetime
				local point = Tween.point(v2.Radius[1], v2.Radius[2], v4)

				if magnitude < 100 + 10 * point then
					local rightVector = (v2.CFrame * CFrame.Angles(0, 0, 1.0471975511965976)).RightVector
					local v5 = -rightVector
					local v6 = 6.283185307179586 * Random.new():NextNumber(0, 1)
					local unit = Vector3.new(math.cos(v6), Random.new():NextNumber(-1, 1), (math.sin(v6))).Unit
					local cframe = CFrame.fromAxisAngle(unit, 2 * math.random() * 3.141592653589793)
					local worldPosition = v2.CFrame.p + unit * v2.Radius[1]
					local worldPosition2 = v2.CFrame.p + unit * v2.Radius[2]
					local v7 = {
						WorldPosition = worldPosition,
						WorldAxis = cframe * rightVector
					}
					local v8 = {
						WorldPosition = worldPosition2,
						WorldAxis = cframe * v5
					}
					local v13 = LightningBolt2.new(
						v7,
						v8,
						(math.clamp(math.max(v2.Radius[1], v2.Radius[2]) * 1.5, 7, 14))
					)
					v13.AnimationSpeed = 10
					v13.ContractFrom = 0.75
					v13.MinTransparency = v2.Transparency[1]
					v13.MaxTransparency = v2.Transparency[2]
					v13.Thickness = math.clamp((point * 0.3) ^ 0.6, 0.25, 10)
					v13.CurveSize0 = point
					v13.CurveSize1 = point
					v13.PulseSpeed = 1 / v2.Duration
					v13.PulseLength = 0.5
					v13.FadeLength = 0.25
					v13.MaxRadius = point
					v13.MinRadius = point / 4
					v13.Color = v2.Color
					v13.Frequency = 0.6
				end
			end

			v2.Frame += 1
		end
	end
end)
return function(data)
	local cFrame = data.CFrame or CFrame.new()
	local color = data.Color or Color3.new(1, 1, 1)
	local radius = data.Radius and type(data.Radius) == "number" and { 0, data.Radius } or data.Radius or { 0, 1 }
	local duration = data.Duration and type(data.Duration) == "table" and Random.new():NextNumber(
		data.Duration[1],
		data.Duration[2]
	) or data.Duration or 1
	local lifetime = data.Lifetime and type(data.Lifetime) == "table" and Random.new():NextNumber(
		data.Lifetime[1],
		data.Lifetime[2]
	) or data.Lifetime or 1
	local transparency = data.Transparency and type(data.Transparency) == "table" and data.Transparency or {
		data.Transparency,
		data.Transparency
	} or { 0, 0 }
	local frameSpawn = data.FrameSpawn or 3
	table.insert(v, {
		CheckDestroy = data.CheckDestroy,
		CFrame = cFrame,
		Color = color,
		Radius = radius,
		Duration = duration,
		Lifetime = lifetime,
		Transparency = transparency,
		FrameSpawn = frameSpawn,
		Frame = 0,
		Start = tick()
	})
end