game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
require(game.ReplicatedStorage.Util.Tween)
return function(list)
	local v, _, v2, v3 = unpack(list)
	local _ = v * CFrame.Angles(-0.4363323129985824, 0, 0) * CFrame.new(0, v3, v3)
	local _ = currentCamera.CFrame
	wait(v2)
	currentCamera.CameraType = Enum.CameraType.Custom
end