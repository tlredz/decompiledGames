local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectPlayer = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("EffectPlayer"))
return function(data)
	local model = data.effectAssetRoot:FindFirstChild("通用撞墙效果")

	if not (model and model:IsA("Model")) then
		warn(string.format("[撞墙特效] 素材缺失：%s", "通用撞墙效果"))
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