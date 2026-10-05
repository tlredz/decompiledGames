require(game.ReplicatedStorage.MovesetTypes)
local Anims = require(game.ReplicatedStorage.Util.Anims)
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
return {
	onInput = function(object, _: string, _, _)
		local character = object.character
		local rootPart = object.rootPart
		local humanoid = object.humanoid
		local tool = object.tool
		local aim = object:aim()
		object.remotes.event:FireServer(aim)
		humanoid.AutoRotate = false
		local cframe = CFrame.new(rootPart.Position, aim)
		local v = BodyMover.new(character):Create("BodyGyro", {
			CFrame = cframe
		})
		local v2 = BodyMover.new(character):Create("BodyPosition", {
			Position = rootPart.Position
		})
		local v3 = false
		task.spawn(function()
			while not v3 and (not tool or tool:IsDescendantOf(character)) do
				local aim2 = object:aim()
				object.remotes.event:FireServer(aim2)
				v:Set(CFrame.new(rootPart.Position, aim2))
				task.wait()
			end
		end)
		local guitarZCharge = Anims:Get(character, "GuitarZCharge")
		guitarZCharge.Looped = true
		guitarZCharge.Priority = Enum.AnimationPriority.Action4
		guitarZCharge:Play()
		task.spawn(function()
			if object.holdingInstance.Value then
				object.holdingInstance.Changed:Wait()
			end

			guitarZCharge:Stop()
			local guitarZFire = Anims:Get(character, "GuitarZFire")
			guitarZFire.Looped = false
			guitarZFire.Priority = Enum.AnimationPriority.Action4
			guitarZFire:Play()
		end)
		object.remotes.func:InvokeServer("Z")
		v:Destroy()
		v2:Destroy()
		humanoid.AutoRotate = true
		v3 = true
	end
}