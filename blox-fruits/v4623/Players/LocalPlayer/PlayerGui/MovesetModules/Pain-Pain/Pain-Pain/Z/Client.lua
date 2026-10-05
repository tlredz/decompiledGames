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
		local data2 = runtime.data
		local ogCooldown = runtime.ogCooldown
		local lastStandCdBuff = runtime.lastStandCdBuff
		local auraCdBuff = runtime.auraCdBuff
		data.remotes.event:FireServer(aim())
		local v = BodyMover.new(character):Create("BodyGyro", {
			CFrame = CFrame.new(rootPart.Position, aim())
		})
		local v2 = BodyMover.new(character):Create("BodyPosition", {
			Position = rootPart.Position
		})
		humanoid.AutoRotate = false
		rootPart.CFrame = CFrame.new(rootPart.Position, aim())
		local painZHold = Anims:Get(character, "PainZHold")
		painZHold.Looped = true
		painZHold:Play()
		painZHold:AdjustSpeed(0.05)

		local function applyPlaybackForFireRate()
			local painZFireRate = rootPart:GetAttribute("PainZFireRate")

			if not painZFireRate or painZFireRate <= 0 then
				return
			end

			local v3 = 1 + -0.85 * math.clamp(((math.clamp(painZFireRate, 0.15, 1) - 0.15) / 0.85) ^ 0.6, 0, 1)
			painZHold:AdjustSpeed(v3)
			print(v3)
		end

		local painZFireRateChangedConnection = rootPart:GetAttributeChangedSignal("PainZFireRate"):Connect(applyPlaybackForFireRate)
		local childAddedConnection = nil
		childAddedConnection = rootPart.ChildAdded:Connect(function(child)
			if child.Name == "PainZStarted" then
				childAddedConnection:Disconnect()
				painZHold:AdjustSpeed(1)
				painZHold.TimePosition = 0.06
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

			task.wait(0.05)
			local painZTap = Anims:Get(character, "PainZTap")
			painZTap.Priority = Enum.AnimationPriority.Action2
			painZTap:Play()

			if childAddedConnection then
				childAddedConnection:Disconnect()
			end
		end)
		data.remotes.func:InvokeServer("Z")

		if painZFireRateChangedConnection then
			painZFireRateChangedConnection:Disconnect()
		end

		data2.Cooldown.Z = ogCooldown.Z * (runtime.LASTSTAND and lastStandCdBuff or character:GetAttribute("PainAura") == true and auraCdBuff or 1)

		if painZHold then
			painZHold:Stop()
		end

		v3 = true
		v:Destroy()
		v2:Destroy()
		humanoid.AutoRotate = true
	end
}