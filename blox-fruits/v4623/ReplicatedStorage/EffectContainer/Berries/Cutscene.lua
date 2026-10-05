local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local SkinVFX = require(game.ReplicatedStorage.Util.SkinVFX)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Skin = require(game.ReplicatedStorage.Definitions.Skin)
local debris = Util.Debris
local v = 1
return function(state)
	task.spawn(function()
		local index = state.Index or 1
		local cFrame = state.CFrame

		if cFrame and (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 500 then
			return
		end

		if index < 3 then
			local color1 = state.Color1 or Color3.fromRGB(30, 235, 37)
			local color2 = state.Color2 or Color3.fromRGB(255, 248, 48)
			local serverTime = state.ServerTime or workspace:GetServerTimeNow()

			if index == 1 then
				local clone = script.InsertFXSpawn:Clone()
				debris:AddItem(clone, 1.5)
				clone.CFrame = cFrame
				clone.Parent = _WorldOrigin
				local children = clone.Attachment:GetChildren()

				for _, emitter in ipairs(children) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if emitter.Name ~= "Smoke" and emitter.Name ~= "Wave" and emitter.Name ~= "Lines" then
						emitter.Color = ColorSequence.new(color1, color2 or color1)
					end

					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			elseif index == 2 then
				v += 1
				local v2 = v
				local v3 = math.max(0.1, workspace:GetServerTimeNow() - serverTime)
				local v4 = math.max(0.1, (state.Duration or 2) - v3)
				local clone = script.JuiceFXSpawn:Clone()
				debris:AddItem(clone, 5)
				clone.CFrame = cFrame
				clone.Parent = _WorldOrigin
				local descendants = clone:GetDescendants()
				local v5 = {}

				for _, emitter in ipairs(descendants) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Color = ColorSequence.new(color1, color2 or color1)
					v5[emitter] = {
						emitter:GetAttribute("EmitCount") or 1,
						emitter:GetAttribute("EmitDelay") or 0.2,
						os.clock()
					}
				end

				local lastTime = os.clock()

				while v2 == v and not (v4 < os.clock() - lastTime) do
					for k, nows in pairs(v5) do
						if not (os.clock() - nows[3] > nows[2]) then
							continue
						end

						k:Emit(nows[1])
						nows[3] = os.clock()
					end

					RunService.Heartbeat:Wait()
				end
			end
		elseif index == 3 then
			local v2 = assert(state.UserId)
			local playerByUserId = game.Players:GetPlayerByUserId(v2)
			local character = playerByUserId and playerByUserId.Character

			if not character then
				print("No character", v2, playerByUserId, character)
				return
			end

			local color1 = state.Color1 or Color3.fromRGB(30, 235, 37)
			local color2 = state.Color2 or Color3.fromRGB(255, 248, 48)
			Effect.new("Berries.DrinkJuice"):play({
				Color = ColorSequence.new(color1, color2),
				RootPart = character:FindFirstChild("HumanoidRootPart"),
				Shaded = true,
				DrinkDelay = 1.07
			})
			local forceStop = state.ForceStop
			local track = nil

			function state.ForceStop()
				if track then
					track:Stop()
				end

				if forceStop then
					task.spawn(forceStop)
				end
			end

			if character then
				local unwrapped = ItemConfig.match(state.StorageName, "Skin"):unwrap()
				local unwrapped2 = ItemConfig.match(Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()):unwrap()
				local child = game.ReplicatedStorage.Assets.Models.Chalices:FindFirstChild(unwrapped2.Index.StorageKey)
				local rightGripAttachment = character:FindFirstChild("RightGripAttachment", true)

				if child and rightGripAttachment then
					local clone = child:Clone()
					SkinVFX.applySkin(unwrapped.Index.ItemId, {
						[clone] = `Chalices.{unwrapped2.Index.StorageKey}`
					})
					local v3 = nil
					local model = Instance.new("Model")
					model.Name = "_Chalice"

					local function fn()
						if v3 then
							v3()
							v3 = nil
						end

						if model then
							model:Destroy()
							model = nil
						end
					end

					task.delay(8, fn)
					local v4 = assert(clone:FindFirstChild("Handle"), "No handle Found")
					local part = Instance.new("Part")
					part.Transparency = 1
					part.CanCollide = false
					part.CanTouch = true
					part.Massless = false
					local boundingBox, size = clone:GetBoundingBox()
					part.Size = size
					part.CFrame = boundingBox
					part.Parent = model
					model.PrimaryPart = part
					part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.2, 1, 0.3, 2)
					local weldConstraint = Instance.new("WeldConstraint")
					weldConstraint.Part0 = part
					weldConstraint.Part1 = v4
					weldConstraint.Parent = part
					local mass = part:GetMass()

					for _, part2 in pairs(clone:GetChildren()) do
						part2.Parent = model

						if not part2:IsA("BasePart") then
							continue
						end

						part2.CanCollide = false
						part2.Anchored = false
						part2.CanQuery = false
						part2.Massless = true
						part2.CanTouch = false

						if part2 ~= v4 then
							part2.Transparency = 0
						end
					end

					clone:Destroy()
					local weldConstraint2 = Instance.new("WeldConstraint")
					weldConstraint2.Name = "_RigidHandle"
					local worldCFrame = rightGripAttachment.WorldCFrame
					model:PivotTo(worldCFrame)
					weldConstraint2.Part0 = v4
					weldConstraint2.Part1 = rightGripAttachment.Parent
					weldConstraint2.Parent = v4
					model.Parent = workspace._WorldOrigin
					local nullable = Skin.Definition.Appearance.match(unwrapped.Index.ItemId):asNullable()

					if unwrapped.Skin and unwrapped.Skin.Type == "Aura" and nullable then
						v3 = SkinVFX.applyChaliceColor(model, nullable)
					end

					local touchedConnection = nil
					touchedConnection = part.Touched:Connect(function(otherPart)
						if otherPart.Name == "DrinkHitPart" then
							part.CanCollide = true
							touchedConnection:Disconnect()
							touchedConnection = nil
							local Util2 = require(game.ReplicatedStorage.Util)
							Util2.Sound:Play("BaristaCutscene.CupHit", v4)
						end
					end)

					if playerByUserId == game.Players.LocalPlayer then
						track = state.Track
					else
						local humanoid = character:FindFirstChildOfClass("Humanoid")
						local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

						if animator then
							local Util2 = require(game.ReplicatedStorage.Util)
							local raw = Util2.Anims:GetRaw("JuiceMachineDrink")

							if raw then
								track = animator:LoadAnimation(raw)
							else
								warn("Animation not found")
							end
						end
					end

					if track then
						track:GetMarkerReachedSignal("Drop"):Once(function()
							if weldConstraint2 and weldConstraint2.Parent then
								weldConstraint2:Destroy()
								v4:ApplyImpulse(-playerByUserId.Character.PrimaryPart.CFrame.LookVector * mass * workspace.Gravity * 0.2)
							end
						end)
						track:Play()
					else
						task.delay(5.5, fn)
					end
				else
					state.ForceStop()

					if not child then
						print("No chalice for skin", state.Item)
					end
				end
			else
				state.ForceStop()
			end
		end
	end)
end