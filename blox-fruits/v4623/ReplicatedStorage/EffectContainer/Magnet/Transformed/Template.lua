game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("TweenService")
local _ = workspace.CurrentCamera
require(ReplicatedStorage.Util)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("Z_Repel")
local _ = workspace._WorldOrigin
return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	local _ = data.Player
	local _ = data.Stage
end