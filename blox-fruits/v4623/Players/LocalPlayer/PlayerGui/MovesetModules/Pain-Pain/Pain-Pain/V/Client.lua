require(game.ReplicatedStorage.MovesetTypes)
local Anims = require(game.ReplicatedStorage.Util.Anims)
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
local Client = require(script.Parent.Parent.Client)
return {
	onInput = function(data, _: string, _, _)
		local runtime = Client.getRuntime(data)

		if not runtime then
			return nil
		end

		local character = data.character
		local rootPart = data.rootPart
		local humanoid = data.humanoid
		local aim = runtime.aim
		local toolActive = runtime.toolActive
		data.remotes.event:FireServer(aim())
		local v = BodyMover.new(character):Create("BodyGyro", {
			CFrame = CFrame.new(rootPart.Position, aim())
		})
		local v2 = BodyMover.new(character):Create("BodyPosition", {
			Position = rootPart.Position
		})
		humanoid.AutoRotate = false
		rootPart.CFrame = CFrame.new(rootPart.Position, aim())
		local painVHold = Anims:Get(character, "PainVHold")
		painVHold.Looped = true
		painVHold:Play()
		local flag = false
		local childAddedConnection = rootPart.ChildAdded:Connect(function(child)
			if child.Name == "PainVTrigger" then
				flag = true

				if not painVHold then
					return
				end

				if painVHold then
					painVHold:Stop()
				end

				Anims:Get(character, "PainVSpiritActivate"):Play()
				painVHold = Anims:Get(character, "PainVSpiritHold")
				painVHold.Looped = true
				painVHold.Priority = Enum.AnimationPriority.Idle
				painVHold:Play()
			end
		end)
		local v3 = false
		spawn(function()
			while toolActive() and not v3 do
				v:Set(CFrame.new(rootPart.Position, aim()))
				data.remotes.event:FireServer(aim())
				wait()
			end
		end)
		spawn(function()
			if data.holdingInstance.Value then
				data.holdingInstance.Changed:Wait()
			end

			v3 = true

			if painVHold then
				painVHold:Stop()
			end

			task.wait(0.05)

			if flag then
				Anims:Get(character, "PainVSpiritRelease"):Play()
			else
				Anims:Get(character, "PainVFire"):Play()
			end
		end)
		data.remotes.func:InvokeServer("V")
		v3 = true

		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		if painVHold then
			painVHold:Stop()
		end

		v:Destroy()
		v2:Destroy()
		humanoid.AutoRotate = true
	end
}