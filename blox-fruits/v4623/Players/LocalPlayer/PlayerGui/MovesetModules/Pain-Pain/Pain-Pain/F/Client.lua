local createVector = vector.create
require(game.ReplicatedStorage.MovesetTypes)
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local RunService = game:GetService("RunService")
local isRunning = RunService:IsRunning()
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
local Ray = require(game.ReplicatedStorage.Util.Ray)
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
		local ghostProxyStorage = runtime.GhostProxyStorage
		local closestGhostInRange = runtime.closestGhostInRange
		local flag = false
		local v = false
		local cFrame = rootPart.CFrame
		local v2 = aim()
		local v3 = math.min(160, (cFrame.Position - v2).magnitude)
		local v4 = CFrame.new(rootPart.Position, v2) * CFrame.new(0, 0, -v3)
		local cframe = CFrame.new(v4.Position, v4.Position + v4.lookVector * createVector(1, 0, 1))
		local v5 = {
			Origin = rootPart.Position,
			Stage = 1,
			Character = character,
			Holding = data.holdingInstance,
			Player = player
		}
		local new = Effect.new
		local v6

		if isRunning then
			v6 = game.ReplicatedStorage.EffectContainer.Pain.F
		else
			v6 = require(game.ReplicatedStorage.EffectContainer.Pain.F)
		end

		new(v6):play(v5)
		local v7 = BodyMover.new(character):Create("BodyGyro", {
			CFrame = CFrame.new(rootPart.Position, aim())
		})
		local v8 = BodyMover.new(character):Create("BodyVelocity", {
			Velocity = createVector(0, 0, 0)
		})
		local v9 = false
		spawn(function()
			while toolActive() and not v9 do
				v7:Set(CFrame.new(rootPart.Position, aim()))
				data.remotes.event:FireServer(aim())
				wait()
			end

			if not flag then
				if v7 then
					v7:Destroy()
				end

				if v8 then
					v8:Destroy()
				end
			end
		end)
		task.spawn(function()
			local flag2 = false

			while toolActive() and not v do
				if character:FindFirstChild("PainFBG") then
					flag2 = true
				elseif flag2 == true then
					if not v7 then
						break
					end

					v7:Destroy()
					break
				end

				if flag2 then
					v7:Set((CFrame.new(rootPart.CFrame.Position, aim() + Vector3.new(0, rootPart.Size.Y * 1.5, 0))))
					data.remotes.event:FireServer(aim())
				end

				task.wait()
			end
		end)
		local v10 = false
		local v11 = false
		task.spawn(function()
			if data.holdingInstance.Value then
				local thread = task.delay(0.2, function()
					flag = true
					v10 = true
				end)
				data.holdingInstance.Changed:Wait()
				v10 = true
				v11 = true
				task.cancel(thread)
				v9 = true

				if flag then
					task.spawn(function()
						local v12 = tick() + 1.5

						while not (v12 < tick()) do
							data.remotes.event:FireServer(aim())
							task.wait()
						end
					end)
				else
					rootPart:SetAttribute("Tapped", true)
					v2 = aim()
					local v12, v13 = Ray(cFrame.Position, v2 - cFrame.Position, {
						ghostProxyStorage,
						workspace._WorldOrigin,
						workspace.Characters,
						workspace.Enemies
					})

					if v12 then
						v2 = v13
					end

					v3 = math.min(160, (cFrame.Position - v2).magnitude)
					local v14 = CFrame.new(rootPart.Position, v2) * CFrame.new(0, 0, -v3)
					cframe = CFrame.new(v14.Position, v14.Position + v14.lookVector * createVector(1, 0, 1))
					local v15 = {
						Origin = rootPart.Position,
						Player = player,
						Stage = 2,
						Character = character,
						StartCFrame = CFrame.new(rootPart.Position, cframe.Position),
						EndPos = cframe.Position,
						Holding = data.holdingInstance
					}
					local new2 = Effect.new
					local v16

					if isRunning then
						v16 = game.ReplicatedStorage.EffectContainer.Pain.F
					else
						v16 = require(game.ReplicatedStorage.EffectContainer.Pain.F)
					end

					new2(v16):play(v15)
					local v17 = closestGhostInRange(cframe.Position, 8)

					if v17 then
						v17:SetAttribute("Active", false)
					end

					rootPart.CFrame = CFrame.new(cframe.Position + Vector3.new(0, rootPart.Size.Y * 1.5, 0)) * (cframe - cframe.Position)
				end
			end

			v11 = true
		end)
		tick()

		while not (v11 or v10) do
			task.wait()
		end

		if flag then
		end

		data.remotes.func:InvokeServer("F", cFrame, rootPart.CFrame, flag)
		v = true

		if v7 then
			v7:Destroy()
		end

		if v8 then
			v8:Destroy()
		end

		v9 = true
		humanoid.AutoRotate = true
	end
}