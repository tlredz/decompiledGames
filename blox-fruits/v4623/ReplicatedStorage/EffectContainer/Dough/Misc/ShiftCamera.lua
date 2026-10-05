local Util = require(game.ReplicatedStorage.Util)
local currentCamera = workspace.CurrentCamera
local v = {}
return function(instance)
	local holding = instance.Holding
	local humanoid = instance.Humanoid or game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local duration = instance.Duration or 0.25
	local offset = instance.Offset or Vector3.new()
	local maxDistance = instance.MaxDistance or 1e999
	humanoid.Destroying:Connect(function()
		v[humanoid] = nil
	end)

	if not v[humanoid] then
		v[humanoid] = {
			Index = 1,
			Playing = 1
		}
	end

	if v[humanoid].Playing ~= v[humanoid].Index then
		repeat
			wait(0.03333333333333333)
		until v[humanoid].Playing == v[humanoid].Index
	end

	local cameraOffset = humanoid.CameraOffset
	Util.DistributedLoop:add(function(p, _)
		if holding and not (holding:IsDescendantOf(workspace) and holding.Value) then
			return true
		end

		local v2 = math.min(p / duration, 1)
		local ease = Util.Tween.ease
		local _ = offset.Magnitude == 0
		local v4 = ease.out[offset.Magnitude == 0 and "back" or "circ"](v2, 0, 1, 1)
		local v5 = math.min(1, (currentCamera.CFrame.p - currentCamera.Focus.p).Magnitude / maxDistance)
		local v6 = offset

		if offset.Magnitude > 0 then
			v6 *= Util.Tween.ease.out.sine(1 - v5, 0, 1, 1)
		end

		humanoid.CameraOffset = cameraOffset:Lerp(v6, v4)

		if v2 ~= 1 or offset.Magnitude ~= 0 and v[humanoid].Playing == v[humanoid].Index then
			return
		end

		humanoid.CameraOffset = offset
		return true
	end)
	v[humanoid].Index = v[humanoid].Index % 100 + 1
	v[humanoid].Playing = v[humanoid].Index
end