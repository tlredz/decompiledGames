require(game.ReplicatedStorage.MovesetTypes)
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local RunService = game:GetService("RunService")
local isRunning = RunService:IsRunning()
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
		local player = data.player
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
		local v3 = {
			Origin = rootPart.Position,
			Stage = 1,
			Character = character,
			Holding = data.holdingInstance,
			Player = player
		}
		local new = Effect.new
		local v4

		if isRunning then
			v4 = game.ReplicatedStorage.EffectContainer.Pain.C
		else
			v4 = require(game.ReplicatedStorage.EffectContainer.Pain.C)
		end

		new(v4):play(v3)
		local painCHold = Anims:Get(character, "PainCHold")
		painCHold:Play()
		local v5 = false
		spawn(function()
			while toolActive() and not v5 do
				v:Set(CFrame.new(rootPart.Position, aim()))
				data.remotes.event:FireServer(aim())
				wait()
			end
		end)
		spawn(function()
			if data.holdingInstance.Value then
				data.holdingInstance.Changed:Wait()
			end

			v5 = true
			task.wait(0.6)

			if painCHold then
				painCHold:Stop()
			end

			Anims:Get(character, "PainCFire"):Play()
		end)
		data.remotes.func:InvokeServer("C")
		v5 = true
		data2.Cooldown.C = ogCooldown.C * (runtime.LASTSTAND and lastStandCdBuff or character:GetAttribute("PainAura") == true and auraCdBuff or 1)

		if painCHold then
			painCHold:Stop()
		end

		v:Destroy()
		v2:Destroy()
		humanoid.AutoRotate = true
	end
}