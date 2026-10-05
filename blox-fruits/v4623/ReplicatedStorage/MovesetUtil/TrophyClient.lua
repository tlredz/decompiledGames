require(game.ReplicatedStorage.MovesetTypes)
local Anims = require(game.ReplicatedStorage.Util.Anims)
return {
	new = function(duration: number, p: number)
		return {
			onInput = function(data, _: string, _, _)
				local character = data.character
				local rootPart = data.rootPart
				local tool = data.tool
				local position = rootPart.Position

				if not Anims:GetRaw("TrophyHold") then
					local animation = Instance.new("Animation")
					animation.AnimationId = "rbxassetid://78533624465132"
					animation.Name = "TrophyHold"
					animation.Parent = game.ReplicatedStorage.Storage.Anims["0"]
				end

				local trophyHold = Anims:Get(character, "TrophyHold")
				trophyHold:Play()
				data.remotes.func:InvokeServer("Z")

				while task.wait(duration) and rootPart:IsDescendantOf(workspace) do
					local v

					if tool then
						v = tool.Parent == character
					else
						v = character.Parent ~= nil
					end

					if not v or p < (position - rootPart.Position).Magnitude then
						break
					end
				end

				trophyHold:Stop()
			end
		}
	end
}