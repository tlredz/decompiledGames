require(game.ReplicatedStorage.MovesetTypes)
local RunService = game:GetService("RunService")
return {
	onInput = function(object, _: string, _, _)
		if RunService:IsClient() then
			return true
		end

		local aim = object:aim()
		object.remotes.event:FireServer(aim)
		return object.remotes.func:InvokeServer("TAP", aim)
	end
}