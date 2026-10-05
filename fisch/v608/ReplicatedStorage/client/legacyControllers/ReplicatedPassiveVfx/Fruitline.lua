local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SaneDebris = require(ReplicatedStorage.shared.modules.SaneDebris)
local fishing = ReplicatedStorage.resources.replicated.fishing
local sparkles = ReplicatedStorage.resources.replicated.fx:FindFirstChild("sparkles")
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 108, 128)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 214, 92)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(126, 217, 87))
})
return {
	Collect = function(_, _, _: string, position: Vector3?)
		if typeof(position) ~= "Vector3" then
			return
		end

		local clone = fishing.splash:Clone()
		clone.Position = position
		clone.Parent = workspace.active.debrisfx

		if sparkles then
			local clone2 = sparkles:Clone()
			clone2.Enabled = false
			clone2.Color = colorSequence
			clone2.Parent = clone
			clone2:Emit(18)
		end

		SaneDebris:AddItem(clone, 3)
	end
}