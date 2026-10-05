local createVector = vector.create
local Tween = require(game.ReplicatedStorage.Util.Tween)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local RenderDistance = require(game.ReplicatedStorage.Util.RenderDistance)
local v = 1 / createVector(825.3, 494.191, 631.74)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local expo = Tween.ease.out.expo
local sine = Tween.ease.out.sine
local v2 = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("GroundSmash", Enum.RenderPriority.Camera.Value, function(p)
	for k, v3 in pairs(v2) do
		local _d = v3._d
		local v4 = tick() - v3.start
		local dustClouds = v3.dustClouds
		local explosionSpike = v3.explosionSpike

		if v4 < _d then
			if v3.RenderDistance:WithinRange(p) then
				local origin = v3.origin
				local spikeScale = v3.spikeScale
				local size = v3.size
				local v5 = expo(v4, 0, 1, _d)
				local v6 = sine(v4, 0, 1, _d)
				local v7 = v4 / _d
				local transparency = v7 > 0.3 and 0.7 + (v7 - 0.2) / 0.8 * 0.3 or 0.7

				for k2, dustCloud in next, dustClouds, nil do
					local v9 = k2 % 2 == 1 and 1 or -1
					dustCloud.Part.CFrame = dustCloud.Direction * CFrame.Angles(
						v9 * math.rad(25 * v6),
						v9 * math.rad(-25 * v6),
						v9 * math.rad(-25 * v6)
					) * CFrame.new(size * -1 * v6, 0, 0)
					dustCloud.Part.Mesh.Scale = dustCloud.Scale * v5
					dustCloud.Part.Transparency = transparency
				end

				explosionSpike.Transparency = transparency
				explosionSpike.Mesh.Scale = spikeScale * v5
				explosionSpike.CFrame = origin * CFrame.Angles(-1.5707963267948966, 3.141592653589793, 0) * CFrame.new(
					0,
					size * 2 * (-0.25 + v5 * 2),
					0
				)
			end
		else
			explosionSpike:Destroy()

			for _, dustCloud in next, dustClouds, nil do
				dustCloud.Part:Destroy()
			end

			v2[k] = nil
		end
	end
end)
return function(state)
	local renderDistance = RenderDistance.new(state.Position, 330, state.Size * 6 + 330, 0.2)

	if (state.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > state.Size * 10 + 400 then
		return
	end

	state.Size /= 8
	local clone = game.ReplicatedStorage.Assets.Models.ExplosionSpike:Clone()
	local cloud = game.ReplicatedStorage.Assets.Models.Cloud
	local cframe = CFrame.new(state.Position, state.Position + state.Normal)
	clone.Color = state.Color
	clone.Transparency = 1
	clone.Mesh.Scale = Vector3.new(v.X * 2, v.Y * 1.5, v.Z * 2) * state.Size * 8
	clone.CFrame = cframe * CFrame.Angles(-1.5707963267948966, 3.141592653589793, 0) * CFrame.new(0, -state.Size * 3, 0)
	clone.Parent = _WorldOrigin
	local scale = clone.Mesh.Scale
	local v4 = math.floor(state.Size / 5 + 9)
	local dustClouds = {}

	for i = 1, v4 do
		local clone2 = cloud:Clone()
		clone2.Color = state.Color
		clone2.Transparency = 1
		clone2.Mesh.Scale = createVector(6, 4, 6) * (state.Size * 1.5 + math.random())
		clone2.CFrame = cframe * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			6.283185307179586 * (i / v4),
			0
		) * CFrame.new(0, 0, -state.Size * 1.5)
		clone2.Parent = _WorldOrigin
		dustClouds[#dustClouds + 1] = {
			Part = clone2,
			Scale = clone2.Mesh.Scale,
			Direction = clone2.CFrame
		}
	end

	if not state.Mute then
		Sound:Play("GroundSmash", state.Position)
	end

	table.insert(v2, {
		start = tick(),
		RenderDistance = renderDistance,
		_d = state.Duration,
		origin = cframe,
		size = state.Size,
		spikeScale = scale,
		dustClouds = dustClouds,
		explosionSpike = clone
	})
end