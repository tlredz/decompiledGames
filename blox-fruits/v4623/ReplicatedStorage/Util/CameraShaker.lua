local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local CameraShakeOffset = require(script.Parent.CameraShakeOffset)
local v = true
local Main = require(script.Main)
local v2 = Main.new(Enum.RenderPriority.Camera.Value + 1, function(p)
	if not v then
		return
	end

	CameraShakeOffset.apply(p)
end)
local RunService = game:GetService("RunService")

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false and GlobalUtil.FFlags.IsSandboxed == false then
	v2:Start()
end

function v2.SetEnabled(_, flag: boolean)
	v = flag and true or false
end

return v2