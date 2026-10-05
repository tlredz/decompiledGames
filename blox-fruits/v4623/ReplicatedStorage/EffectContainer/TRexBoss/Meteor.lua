local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
local Util2 = require(ReplicatedStorage:WaitForChild("Util"))
local script2 = script

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

return function(player)
	local origin = player.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = player.Stage

	if not player.Root then
		local _ = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	end

	if stage == 4 then
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util2.Debris:AddItem(folder, player.Lifetime + 5)
		local cframe = CFrame.lookAt(player.StartPosition, player.EndPosition)
		local clone = script2.METEORBAMP:Clone()
		clone.Size = createVector(25, 25, 25) * (player.Raw and 1 or 0.45)
		clone.Transparency = 1
		clone.Shape = Enum.PartType.Ball
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = cframe

		if not player.Raw then
			Util2.ResizeModel(clone, 0.45, clone.Position)
		end

		clone.Parent = folder
		Util2.Sound:Play("GravFruit_M1_SkyMeteor_Release_0" .. tostring(math.random(1, 4)) .. "_V2", clone.Position)
		Util2.Sound:Play("GravFruit_SmallMeteorLoop", clone)
		emitAll(clone.BAMPLASH)
		local lastTime = os.clock()
		local v = false
		local endPosition = player.EndPosition
		local ray, v2, v3 = Util2.Ray(
			endPosition - cframe.LookVector * 0.1,
			cframe.LookVector * 10,
			{ workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		)

		if ray then
			local clone2 = script2.MeteorIndicator:Clone()
			clone2.CFrame = CFrame.new(v2, v2 + v3) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
			clone2.Parent = folder
			emitAll(clone2)
			task.delay(1.5, function()
				clone2:Destroy()
			end)
		end

		local heartbeatConnection = nil
		local RunService = game:GetService("RunService")
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if os.clock() - lastTime >= player.Lifetime or player.Proxy:GetAttribute("Exploding") then
				heartbeatConnection:Disconnect()

				if player.Proxy:GetAttribute("Exploding") then
					endPosition = player.Proxy:GetAttribute("Exploding")
				end

				if ray == nil or player.Proxy:GetAttribute("Exploding") then
					local position = endPosition
					local clone2 = script2.MeteorExplodeAir:Clone()

					if player.Raw then
						Util2.ResizeModel(clone2, 1.3)
					end

					clone2.Position = position
					clone2.Parent = _WorldOrigin
					Util2.Debris:AddItem(clone2, 5)
					emitAll(clone2)
					Util2.Sound:Play(
						"GravFruit_M1_MeteorFall_Explode_0" .. tostring(math.random(1, 3)),
						clone2.Position
					)
					clone.Meteor:Destroy()

					for _, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Beam") then
							effect.Enabled = false
						end
					end

					task.delay(1, function()
						clone:Destroy()
					end)
				else
					local cFrame = CFrame.new(v2, v2 + v3) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
					local clone2 = script2.MeteorExplodeFloor:Clone()

					if player.Raw then
						Util2.ResizeModel(clone2, 1.3)
					end

					clone2.CFrame = cFrame
					clone2.Parent = folder
					Util2.Debris:AddItem(clone2, 5)
					emitAll(clone2)
					Util2.Sound:Play(
						"GravFruit_M1_MeteorFall_Explode_0" .. tostring(math.random(1, 3)),
						clone2.Position
					)
					Util2.Sound:Play("GravFruit_GenericDebrisLayer_Medium_05", clone2.Position)
					clone.Meteor:Destroy()

					for _, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Beam") then
							effect.Enabled = false
						end
					end

					task.delay(1, function()
						clone:Destroy()
					end)
					task.spawn(function()
						local v5 = 28 * (player.Raw and 1.75 or 1)
						local v6 = 18 + (player.Raw and 4 or 0)
						local v7 = clone2.Position + createVector(0, 2, 0)

						for i = 1, v6 do
							local v8 = 360 / v6 * i
							local v9 = CFrame.new(v7, v7 + v3 * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
								0,
								math.rad(v8),
								0
							) * CFrame.new(0, 0, -v5)
							local ray2, v10, v11 = Util2.Ray(
								v9.Position,
								v9.upVector.Unit * -30,
								{ workspace.Characters, workspace.Enemies },
								false
							)

							if not ray2 then
								continue
							end

							local v12 = Rock2.new({
								FadeIn = { 0.1, 0.3 },
								Lifetime = math.random(25, 30) / 10,
								FadeOut = { 0.4, 0.5 },
								Size = Vector3.new(math.random(3, 4), 2, math.random(3, 4)) * (player.Raw and 1.33 or 1),
								Scale = { 1.2, 3 }
							})
							v12:Spawn(CFrame.new(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
								0,
								0,
								0
							))

							if not (math.random(1, 100) <= 25) then
								continue
							end

							v12.Type = "Flying"
							v12:Eject({
								Velocity = v9.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v12.Part.CFrame.lookVector * math.random(
									10,
									20
								),
								RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
							})
						end
					end)
				end
			else
				clone.CFrame *= CFrame.new(0, 0, -player.Speed * dt)

				if v == false and clone.Position.Y < -4 then
					v = true
					Effect.new("Water.Splash"):play({
						CFrame = CFrame.new(clone.Position.X, -4, clone.Position.Z),
						Scale = clone.Size.Y * 1.5,
						Duration = 1.5 * clone.Size.Y / 20
					})
					Util2.Sound:Play(
						"GravFruit_M1_Meteor_Splashdown_0" .. tostring(math.random(1, 3)),
						(Vector3.new(clone.Position.X, -4, clone.Position.Z))
					)
				end
			end
		end)
	end
end