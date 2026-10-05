local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage.Util.TransformationController)
return function(instance)
	local _ = instance.Multiplier
	local duration = instance.Duration
	local HRP = instance.HRP
	local humanoid = instance.Humanoid
	local NPC = instance.NPC
	workspace:WaitForChild("_WorldOrigin")

	if (workspace.CurrentCamera.CFrame.p - HRP.Position).Magnitude > 750 or HRP.Parent:GetAttribute("ControlDisassemble") then
		return
	end

	local Util = require(ReplicatedStorage:WaitForChild("Util"))
	local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
	local movementDash = Effect.new("Movement.Dash")
	local direction = instance.Direction or humanoid.MoveDirection

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		if instance.Direction and instance.Direction == createVector(0, 1, 0) then
			Effect.new("Gas.Transformed.Jump"):replicate({
				Root = HRP,
				Origin = HRP.Position
			})
		else
			Effect.new("Gas.Transformed.Dash"):replicate({
				Root = HRP,
				Origin = HRP.Position,
				Direction = direction
			})
		end
	end

	if NPC then
		direction = (HRP.Velocity * createVector(1, 0, 1)).Unit
	end

	if HRP.Parent:FindFirstChild("MagnetRig") then
		if instance.Direction and instance.Direction == createVector(0, 1, 0) then
			local magnetTransformedDash = Effect.new("Magnet.Transformed.Dash")
			local v = {
				Stage = 2,
				Root = HRP,
				Origin = HRP.Position,
				Player = 0
			}
			local Players = game:GetService("Players")
			v.Player = Players:GetPlayerFromCharacter(HRP.Parent)
			magnetTransformedDash:play(v)
		else
			local magnetTransformedDash = Effect.new("Magnet.Transformed.Dash")
			local v = {
				Stage = 1,
				Root = HRP,
				Origin = HRP.Position,
				Player = 0,
				Direction = 0
			}
			local Players = game:GetService("Players")
			v.Player = Players:GetPlayerFromCharacter(HRP.Parent)
			v.Direction = direction
			magnetTransformedDash:play(v)
		end
	elseif HRP.Parent:FindFirstChild("Mammoth") then
		Effect.new("Mammoth.Transformed.GEPPO_DASH"):replicate({
			Character = HRP.Parent,
			RootPart = HRP,
			stage = direction.Y > 0.999 and 1 or 2,
			CFrame = CFrame.new(HRP.Position, HRP.Position + direction)
		})
	elseif HRP.Parent:FindFirstChild("DragonHybrid") then
		if instance.Direction and instance.Direction == createVector(0, 1, 0) then
			Effect.new("Dragon2.Hybrid.Jump"):replicate({
				Root = HRP,
				Origin = HRP.Position,
				player = game.Players:GetPlayerFromCharacter(HRP.Parent)
			})
		else
			Effect.new("Dragon2.Hybrid.Dash"):replicate({
				Root = HRP,
				Origin = HRP.Position,
				Direction = direction,
				player = game.Players:GetPlayerFromCharacter(HRP.Parent)
			})
		end
	elseif HRP.Parent:FindFirstChild("__Room") and HRP.Parent:GetAttribute("AuraActive") then
		if instance.Direction and instance.Direction == createVector(0, 1, 0) then
			Effect.new("ControlRework.Dodge"):play({
				Root = HRP,
				Stage = 1,
				Origin = HRP.Position - HRP.CFrame.LookVector * 5,
				Character = HRP.Parent,
				Humanoid = humanoid
			})
		else
			Effect.new("ControlRework.Dodge"):play({
				Root = HRP,
				Stage = 2,
				Origin = HRP.Position - HRP.CFrame.LookVector * 5,
				Character = HRP.Parent,
				Humanoid = humanoid
			})
		end
	else
		local yetiRig = HRP.Parent:FindFirstChild("YetiRig")

		if yetiRig then
			if instance.Direction and instance.Direction == createVector(0, 1, 0) then
				if yetiRig:GetAttribute("Fiend") == true then
					Effect.new("FiendYeti.Transformed.Dash"):replicate({
						Stage = 1,
						Root = HRP,
						Origin = HRP.Position
					})
				else
					Effect.new("Yeti.Transformed.Dash"):replicate({
						Stage = 1,
						Root = HRP,
						Origin = HRP.Position
					})
				end
			elseif yetiRig:GetAttribute("Fiend") == true then
				Effect.new("FiendYeti.Transformed.Dash"):replicate({
					Stage = 2,
					Root = HRP,
					Origin = HRP.Position,
					Direction = direction
				})
			else
				Effect.new("Yeti.Transformed.Dash"):replicate({
					Stage = 2,
					Root = HRP,
					Origin = HRP.Position,
					Direction = direction
				})
			end
		else
			local tigerRig = HRP.Parent:FindFirstChild("TigerRig")

			if tigerRig then
				if instance.Direction and instance.Direction == createVector(0, 1, 0) then
					Effect.new("Tiger.Awakened.Dash"):replicate({
						Stage = 1,
						Root = HRP,
						Origin = HRP.Position,
						Awakened = tigerRig:GetAttribute("Awakened")
					})
				else
					Effect.new("Tiger.Awakened.Dash"):play({
						Stage = 2,
						Root = HRP,
						Origin = HRP.Position,
						Direction = direction,
						Awakened = tigerRig:GetAttribute("Awakened")
					})
				end
			elseif HRP.Parent:FindFirstChild("PainTransformed") then
				if instance.Direction and instance.Direction == createVector(0, 1, 0) then
					Effect.new("Pain.Dash"):replicate({
						Player = game.Players:GetPlayerFromCharacter(HRP.Parent),
						Stage = 1,
						Root = HRP,
						Origin = HRP.Position
					})
				else
					Effect.new("Pain.Dash"):replicate({
						Player = game.Players:GetPlayerFromCharacter(HRP.Parent),
						Stage = 2,
						Root = HRP,
						Origin = HRP.Position,
						Direction = direction
					})
				end
			elseif HRP.Parent:FindFirstChild("GasRig") then
				return deduplicatedTail()
			elseif HRP.Parent:FindFirstChild("GasRig") then
				return deduplicatedTail()
			else
				local kitsune = HRP.Parent:FindFirstChild("Kitsune")
				local tRex = HRP.Parent:FindFirstChild("TRex")
				local painTransformed = HRP.Parent:FindFirstChild("PainTransformed")
				local kitsuneTail3

				if not kitsune then
					kitsuneTail3 = HRP.Parent:FindFirstChild("KitsuneTail3")
				end

				if not (kitsune or kitsuneTail3 or tRex or painTransformed or HRP.Parent:FindFirstChild("__Room") and HRP.Parent:GetAttribute("AuraActive")) then
					Util.Sound:Play(instance.Direction and "DodgeQuick" or "Dodge", HRP)
				end

				local parent = HRP and HRP.Parent

				if instance.Mink or instance.Super then
					local v = not instance.Timestamp and 0 or math.max(
						0.25,
						workspace:GetServerTimeNow() - instance.Timestamp
					)
					Effect.new("Shared.LightningTP"):replicate({
						Character = parent,
						Duration = duration + 0.05 + v,
						CFrame = CFrame.new(HRP.Position, HRP.Position + direction),
						Super = instance.Super
					})
				elseif HRP.Parent:FindFirstChild("TRex") then
					if instance.Direction and instance.Direction == createVector(0, 1, 0) then
						Effect.new("Dino.Transformed.Jump"):replicate({
							Root = HRP,
							Origin = HRP.Position - HRP.CFrame.LookVector * 5
						})
					else
						Effect.new("Dino.Transformed.Dash"):replicate({
							Root = HRP,
							Origin = HRP.Position + (HRP.CFrame.LookVector * -5 + direction * -5),
							Direction = direction,
							LeftRight = math.random(0, 1)
						})
					end
				elseif kitsune or kitsuneTail3 then
					if instance.Direction and instance.Direction == createVector(0, 1, 0) then
						Effect.new("Kitsune.Jump"):replicate({
							hrp = HRP,
							originPos = HRP.Position + (not kitsune and createVector(0, 0, 0) or HRP.CFrame.LookVector * -5 or createVector(
								0,
								0,
								0
							)),
							trailDisabled = kitsune and true or false,
							player = game.Players:GetPlayerFromCharacter(HRP.Parent)
						})
					else
						Effect.new("Kitsune.QAerial"):replicate({
							hrp = HRP,
							originPos = HRP.Position + (not kitsune and createVector(0, 0, 0) or HRP.CFrame.LookVector * -5 + direction * -5 or createVector(
								0,
								0,
								0
							)),
							travelDir = direction,
							trailDisabled = kitsune and true or false,
							player = game.Players:GetPlayerFromCharacter(HRP.Parent)
						})
					end
				else
					local v = HRP.Size.Y * 0.5 + humanoid.HipHeight + 0.5
					local rayCastWhitelist = Util.RayCastWhitelist(
						HRP.Position,
						Vector3.new(0, -(v + HRP.Size.Y), 0),
						{ workspace:FindFirstChild("Map") }
					)
					local magnetArmFunctions = parent:FindFirstChild("MagnetArmFunctions")

					if magnetArmFunctions then
						local folder = Instance.new("Folder")
						folder.Name = "EnableBoost"
						folder.Parent = magnetArmFunctions
						Util.Debris:AddItem(folder, 0.33)
					end

					if rayCastWhitelist then
						movementDash:replicate({ HRP.Parent, duration })
						return
					end

					local v2 = 0.5 + HRP.Size.Z * 0.5
					Effect.new("Shared.AirDash"):replicate({
						CFrame = CFrame.new(HRP.Position, HRP.Position + direction),
						Width = 2 * v2 * 1.4,
						Length = 4 * v2 * 1.4,
						Root = HRP,
						Character = parent
					})
				end
			end
		end
	end
end