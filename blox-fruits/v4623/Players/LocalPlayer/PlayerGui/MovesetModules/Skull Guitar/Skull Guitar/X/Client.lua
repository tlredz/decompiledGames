require(game.ReplicatedStorage.MovesetTypes)
local Anims = require(game.ReplicatedStorage.Util.Anims)
return {
	onInput = function(object, _: string, _, _)
		local character = object.character
		local tool = object.tool
		object.remotes.event:FireServer(object:aim())
		local v = false
		task.spawn(function()
			while not v and (not tool or tool:IsDescendantOf(character)) do
				object.remotes.event:FireServer(object:aim())
				task.wait()
			end
		end)
		local guitarXCharge = Anims:Get(character, "GuitarXCharge")
		guitarXCharge.Looped = true
		guitarXCharge.Priority = Enum.AnimationPriority.Action4
		guitarXCharge:Play()
		task.spawn(function()
			task.wait(1)
			guitarXCharge:Stop()
			local guitarXFire = Anims:Get(character, "GuitarXFire")
			guitarXFire.Looped = false
			guitarXFire.Priority = Enum.AnimationPriority.Action4
			guitarXFire:Play()
		end)
		object.remotes.func:InvokeServer("X")
		v = true
	end
}