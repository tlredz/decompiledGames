local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectPlayer = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("EffectPlayer"))

local function playTemplate(data, childName: string)
	local model = data.effectAssetRoot:FindFirstChild(childName)

	if not (model and model:IsA("Model")) then
		warn(string.format("[碰撞打击特效] 素材缺失：%s", childName))
		return
	end

	local clone = model:Clone()
	clone.Parent = data.rootFolder
	local play = EffectPlayer.play
	local v

	if data.arenaRotation then
		v = CFrame.new(data.worldPosition) * data.arenaRotation * model:GetPivot().Rotation
	else
		v = data.worldPosition
	end

	play(clone, v)
end

return function(p)
	if p.cameraShakeStrength and p.onCameraImpact then
		p.onCameraImpact(p.cameraShakeStrength)
	end

	playTemplate(p, "通用碰球效果")
	playTemplate(p, "打铁特效")
end