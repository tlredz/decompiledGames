local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").Z.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local LightningBoltShafi = require(game.ReplicatedStorage.Util.LightningBoltShafi)

local function ShafiBolt(player, ...)
	local v = LightningBoltShafi.new(...)
	v.Color = Util.WrapColor3Constructor(Color3.new(0.411765, 0.952941, 1), player, "LightningFruitVFXColor")
	return v
end

Util.ResizeModel(assets.Phase1.Projectile, 0.4)
Util.ResizeModel(assets.Phase1.Spark, 0.6)
Util.ResizeModel(assets.Phase1.Explosion, 0.6)
Util.ResizeModel(assets.Phase2.GroundBurn, 0.65)
return function(data)
	local player = data.player

	if (currentCamera.CFrame.p - data.Origin).Magnitude > 1000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		return
	end

	if stage == 2 then
		local hitbox = data.Hitbox

		if not (hitbox and hitbox:IsDescendantOf(workspace)) then
			return
		end

		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Debris:AddItem(folder, 15)
		local startCFrame = data.StartCFrame
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame * CFrame.new(0, 0, -3)
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		Util.Sound:Play("BF_Thunder_RumbleDragon_01_Cast_V2_0" .. tostring(math.random(1, 3)), clone.Position)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		local clone2 = assets.Phase1.Projectile:Clone()
		clone2.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
		clone2.Anchored = false
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(9000000000, 9000000000, 9000000000)
		bodyVelocity.P = 10000
		bodyVelocity.Velocity = clone2.CFrame.LookVector * data.Speed
		Util.SetParentOverrideWithColor(bodyVelocity, clone2, player, "LightningFruitVFXColor")
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(9000000000, 9000000000, 9000000000)
		bodyGyro.D = 2000
		bodyGyro.P = 5000
		bodyGyro.CFrame = startCFrame
		Util.SetParentOverrideWithColor(bodyGyro, clone2, player, "LightningFruitVFXColor")
		local v = Util.Sound:Play("BF_Thunder_RumbleDragon_01_TravelLoop_01", clone2)
		TweenService:Create(v, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()

		for _, effect in pairs(clone2:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
				continue
			end

			effect.Enabled = true

			if effect:IsA("ParticleEmitter") then
				effect:Emit(1)
			end
		end

		local v2 = false
		local v3 = {}
		local flag = true
		task.spawn(function()
			local now = tick()

			repeat
				if now - tick() <= 0 then
					now = tick() + 0.035
					local v4 = clone2.Position + Vector3.new(math.random(-25, 25), 0, math.random(-25, 25))
					local raycastResult = workspace:Raycast(
						v4 + createVector(0, 1, 0),
						createVector(-0, -25, -0),
						raycastParams
					)

					if raycastResult then
						for _ = 1, math.random(1, 2) do
							local v5 = raycastResult
							task.spawn(function()
								local clone3 = FX:WaitForChild("Lightning2").Z.Part:Clone()
								clone3.CFrame = CFrame.new(clone2.Position, v5.Position)
								Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")
								clone3.Anchored = false
								clone3.Weld.Part1 = clone2
								clone3.Massless = true
								clone3.Attach1:SetAttribute("Pos", v5.Position)
								local shafiBolt = ShafiBolt(
									player,
									clone3.Attach0,
									clone3.Attach1,
									10,
									math.random(5, 10) / 15,
									folder
								)
								v3[clone3.Attach1] = shafiBolt

								if flag then
									task.wait(0.05 * math.random() + 0.1)
								else
									task.wait(0.125 * math.random() + 0.075)
								end

								if v3[clone3.Attach1] == nil then
									return
								end

								v3[clone3.Attach1] = nil
								shafiBolt:Destroy()
							end)
						end
					end
				end

				for k, _ in pairs(v3) do
					local pos = k:GetAttribute("Pos")

					if k:GetAttribute("Dontmove") == nil then
						k.WorldPosition = CFrame.new(pos, clone2.Position) * createVector(0, 0, -5)
					else
						k.WorldPosition = pos
					end
				end

				task.wait()
			until v2 == true
		end)

		while true do
			local v4 = task.wait()

			if hitbox:GetAttribute("Targeting") then
				local targeting = hitbox:GetAttribute("Targeting")
				local magnitude = (targeting - clone2.Position).Magnitude
				bodyVelocity.Velocity = bodyVelocity.Velocity.unit:Lerp(
					(targeting - clone2.CFrame.Position).Unit,
					v4 * ((1 - magnitude / 75) * 22)
				) * data.Speed
				bodyGyro.CFrame = CFrame.new(clone2.CFrame.Position, clone2.CFrame.Position + bodyVelocity.Velocity)
			end

			if not (not hitbox:IsDescendantOf(workspace) or hitbox:GetAttribute("Exploding")) then
				continue
			end

			clone2.Anchored = true
			local _ = clone2.CFrame.Position

			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			flag = false

			for k, v5 in pairs(v3) do
				v5:Destroy()
				v3[k] = nil
			end

			local clone3 = assets.Phase1.Spark:Clone()
			clone3.CFrame = clone2.CFrame
			Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")
			clone3.CFrame = clone2.CFrame
			Util.Sound:Play("BF_Thunder_RumbleDragon_01_Explosion_V2_0" .. tostring(math.random(1, 3)), clone3.Position)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					if v5:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v5:GetAttribute("EmitDelay"))
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Destroy()
				end
			end

			v2 = true
			task.wait(0.1)
			local clone4 = assets.Phase1.Explosion:Clone()
			clone4.CFrame = clone2.CFrame
			Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
			DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					if v5:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v5:GetAttribute("EmitDelay"))
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			local raycastResult = workspace:Raycast(clone2.Position, clone2.CFrame.LookVector * 5, raycastParams)
			local raycastResult2 = workspace:Raycast(clone2.Position, createVector(-0, -5, -0), raycastParams)

			if raycastResult or raycastResult2 then
				local v5 = raycastResult or raycastResult2
				local clone5 = assets.Phase2.GroundBurn:Clone()
				Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
				clone5.CFrame = AlignCFrame(CFrame.new(v5.Position), v5.Normal) + v5.Normal * 0.01
				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end

			if (workspace.CurrentCamera.CFrame.p - clone2.Position).Magnitude < 100 then
				Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.8)
				local Effect = require(game.ReplicatedStorage.Effect)
				Effect.new("ColorCorrection"):replicate({
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(156, 215, 255),
						player,
						"LightningFruitVFXColor"
					),
					Brightness = 0.3,
					Saturation = 0.1,
					Contrast = 0.1,
					FadeIn = 0,
					FadeOut = 0.1,
					Lifetime = 0.1
				})
			end

			return
		end
	elseif stage == 3 then
		return
	end
end