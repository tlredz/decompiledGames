function fix(instance)
	if not instance.Name:match("Leviathan") then
		return
	end

	local animator = instance:WaitForChild("Humanoid"):WaitForChild("Animator")
	local v = {
		instance.Animations.RingSnakeMotion.AnimationId,
		instance.Animations.TailIdle.AnimationId,
		instance.Animations.HeadIdle.AnimationId
	}
	local ContentProvider = game:GetService("ContentProvider")
	ContentProvider:PreloadAsync(v)
	local SyncAnims = require(game.ReplicatedStorage.Util.SyncAnims)
	SyncAnims(animator, v)
	task.spawn(function()
		while instance.Parent and task.wait(10) do
			local SyncAnims2 = require(game.ReplicatedStorage.Util.SyncAnims)
			SyncAnims2(animator, v)
		end
	end)
end

workspace:WaitForChild("SeaBeasts").ChildAdded:Connect(fix)

for _, child in pairs(workspace.SeaBeasts:GetChildren()) do
	fix(child)
end