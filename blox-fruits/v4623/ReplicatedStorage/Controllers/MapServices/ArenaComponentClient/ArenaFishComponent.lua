local Component = require(game.ReplicatedStorage.Modules.Component)
require(game.ReplicatedStorage.Util.Signal2)
require(game.ReplicatedStorage.Types.SlappingArenaTypes)
require(game.ReplicatedStorage.Util.Maid)
require(game.ReplicatedStorage.Util.IsTransformed)
local v = Component.new({
	Tag = "ArenaFishComponent",
	Ancestors = { game.ReplicatedStorage, game.Workspace }
})

function v.Construct(p)
	print("Construct ArenaFish", p.Instance)
end

function v:Start()
	print("start ArenaFish", self.Instance)
	self.bonePointer = self.Instance:WaitForChild("bonePointer")
	self.handPointer = self.Instance:WaitForChild("handPointer")
	self.primaryPart = self.Instance.PrimaryPart

	if self.Dead then
		print("it is Dead....")
		return
	end

	print("moving it", self.Instance)
	self.Instance.Parent = self.handPointer.Value.Parent
	self.Enabled = true
end

function v:Stop()
	print("Stop ArenaFish", self.Instance)
	self.Dead = true
	self.Enabled = false
end

function v.RenderSteppedUpdate(data)
	if data.Enabled then
		local v2 = data.bonePointer.Value.TransformedWorldCFrame:Inverse() * data.primaryPart.CFrame
		data.primaryPart.CFrame = data.handPointer.Value.WorldCFrame * v2 * CFrame.Angles(3.141592653589793, 0, 0)
	end
end

return v