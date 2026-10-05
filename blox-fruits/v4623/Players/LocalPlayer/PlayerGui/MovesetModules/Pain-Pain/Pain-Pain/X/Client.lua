local createVector = vector.create
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
		local v2 = BodyMover.new(character):Create("BodyVelocity", {
			Velocity = createVector(0, 0, 0)
		})
		humanoid.AutoRotate = false
		rootPart.CFrame = CFrame.new(rootPart.Position, aim())
		local new = Effect.new
		local v3

		if isRunning then
			v3 = game.ReplicatedStorage.EffectContainer.Pain.X
		else
			v3 = require(game.ReplicatedStorage.EffectContainer.Pain.X)
		end

		new(v3):play({
			Player = player,
			Origin = rootPart.Position,
			Stage = 1,
			Character = character,
			Holding = data.holdingInstance
		})
		local painXHold = Anims:Get(character, "PainXHold")
		painXHold.Looped = true
		painXHold:Play()
		local childAddedConnection = nil
		local v4 = false
		spawn(function()
			while toolActive() and not v4 do
				v:Set(CFrame.new(rootPart.Position, aim()))
				data.remotes.event:FireServer(aim())
				wait()
			end
		end)
		task.spawn(function()
			childAddedConnection = character.ChildAdded:Connect(function(child)
				if child.Name == "PainXGrab" then
					v4 = true
					childAddedConnection:Disconnect()
					local v5 = tick() + 2
					aim()
					local now = tick()
					local v6 = aim()
					local flag = false

					while tick() < v5 do
						local position = aim()
						local cframe = CFrame.lookAt(rootPart.Position, position)

						if (position - cframe.Position).Magnitude >= 150 then
							position = (cframe * CFrame.new(0, 0, -150)).Position
						end

						if not flag and child and child:GetAttribute("SlowDown") then
							v5 = tick() + 0.7
							v6 = position
							flag = true
						end

						if flag then
							local now2 = tick()
							local v7 = now2 - now
							local magnitude = (position - v6).Magnitude

							if magnitude > 0 then
								position = v6:Lerp(position, (math.clamp(200 * v7 / magnitude, 0.1, 1)))
							end

							v6 = position
							now = now2
						else
							v6 = position
						end

						data.remotes.event:FireServer(position)
						v:Set(CFrame.new(rootPart.Position, position))
						task.wait()
					end
				end
			end)
		end)
		spawn(function()
			if data.holdingInstance.Value then
				data.holdingInstance.Changed:Wait()
			end

			v4 = true
			task.wait(0.05)

			if painXHold then
				painXHold:Stop()
			end

			local painXDash = Anims:Get(character, "PainXDash")
			painXDash.Priority = Enum.AnimationPriority.Movement
			painXDash:Play()
		end)
		data.remotes.func:InvokeServer("X")
		v4 = true
		data2.Cooldown.X = ogCooldown.X * (runtime.LASTSTAND and lastStandCdBuff or character:GetAttribute("PainAura") == true and auraCdBuff or 1)

		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		v:Destroy()
		v2:Destroy()
		humanoid.AutoRotate = true
	end
}