local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = Util.MasterClock
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local wings = FX:WaitForChild("Dragon2").Wings
local Wings = require(game.ReplicatedStorage.Util.Wings)
local _ = workspace._WorldOrigin
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local v = {}
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local function CreateWind(data, p)
	local size = data.Size or 1
	local color = data.Color or Util.WrapColor3Constructor(Color3.new(1, 0, 0), p, "DragonFruitVFXColor")
	local transparency = data.Transparency or 0
	return (setmetatable({
		Root = data.Root,
		Size = size,
		Color = color,
		Transparency = transparency,
		R15 = false
	}))
end

local function WindUpdate(items, p, angle, p2)
	for k, item in next, items, nil do
		if not (item and item:FindFirstChild("Trail2")) then
			continue
		end

		local motor6DWeld = item.Motor6DWeld
		local v2 = k == 1 and 1 or -1

		for i = 1, 2 do
			local v3 = i == 1 and 0 or 1
			local v4

			if i == 1 then
				v4 = item.Trail2.TrailAttach0
			else
				v4 = item.Trail2.TrailAttach1
			end

			v4.CFrame = CFrame.new(v2 * p * 2 - v3 * v2 * p * 1.25, p * 0.5, -p * 0.125)
		end

		motor6DWeld.C0 = CFrame.Angles(-1.5707963267948966, v2 * 3.141592653589793 / 2 - v2 * angle, 0) * CFrame.new(
			v2 * -0.5,
			-0.25 + p / 3.5 + (p2 and -1.25 or 0),
			-0.25 + p / 10
		)
	end
end

local function Wind(HRP, p, p2, player)
	local effects = {}
	local clones = {}

	for _ = 1, 2 do
		local clone = wings.Extra.WindTrail:Clone()

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				table.insert(effects, effect)
			end
		end

		local motor6D = Instance.new("Motor6D", clone)
		motor6D.Name = "Motor6DWeld"
		motor6D.Part0 = clone
		motor6D.Part1 = HRP
		motor6D.C0 = CFrame.Angles(-1.5707963267948966, p * 3.141592653589793 / 2, 0) * CFrame.new(
			p * -0.5,
			p2 * 0.25,
			-HRP.Size.Z / 2
		)

		for i = 1, 2 do
			local v2 = i == 1 and 0 or 1

			if i == 1 then
				clone.Trail2.TrailAttach0.CFrame = CFrame.new(p * p2 * 1.65 - v2 * p * p2 * 0.25, p2 * 0.5, -p2 * 0.125)
			else
				clone.Trail2.TrailAttach1.CFrame = CFrame.new(p * p2 * 1.65 - v2 * p * p2 * 0.25, p2 * 0.5, -p2 * 0.125)
			end
		end

		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "DragonFruitVFXColor")
		table.insert(clones, clone)
	end

	local v2 = false

	for _, v3 in pairs(effects) do
		v3.Enabled = false
	end

	return clones, {
		ChangeState = function(self, p3)
			if p3 == "Enable" then
				if v2 == false then
					v2 = true

					for _, v3 in pairs(effects) do
						v3.Enabled = true
					end
				end
			elseif p3 == "Disable" and v2 == true then
				v2 = false

				for _, v3 in pairs(effects) do
					v3.Enabled = false
				end
			end
		end
	}
end

return function(data)
	local DISTANCE_THRESHOLD = 130
	local HRP = data.HRP
	local enabled = data.Enabled
	local color = data.Color
	local player = data.player

	if enabled then
		if (workspace.CurrentCamera.CFrame.p - HRP.Position).Magnitude > 1500 then
			return
		end

		if v[HRP] then
			v[HRP] = nil
		end

		local upperTorso = HRP.Parent and HRP.Parent:FindFirstChild("UpperTorso")

		if upperTorso then
			local v2 = HRP.Parent:FindFirstChild("DragonHybrid") and 6 or 2.5
			local wings2 = Wings.Attach({
				Root = upperTorso,
				Color = color,
				Size = 1,
				Type = "DracoWings"
			}):Activate(player, true)
			wings2:SetTrailEnabled(false)
			wings2:SetRate(0)
			local ID = math.random(9999999)
			local v5 = {
				ID = ID,
				Wings = wings2,
				Angle = 0
			}
			v[HRP] = v5
			local lastTime = tick()

			while tick() - lastTime < 0.2 do
				local size = (tick() - lastTime) / 0.2
				wings2.Size = size
				wings2:Update(0, 1 - size)
				RunService.RenderStepped:Wait()
			end

			wings2.Size = 1
			wings2:Update(0, 0)
			local v6 = false
			local clone = wings.GlideModel:Clone()

			if HRP.Parent:FindFirstChild("DragonHybrid") then
				clone:ScaleTo(1.7)
			end

			local glide = clone.Glide
			Util.SetParentOverrideWithColor(glide, workspace.Terrain, player, "DragonFruitVFXColor")
			clone:Destroy()
			glide.CFrame = HRP.CFrame
			glide.WeldConstraint.Part1 = HRP
			local emitters = {}

			for _, emitter in pairs(glide:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					table.insert(emitters, emitter)
				end
			end

			local flag = false
			local v7 = tick() + 0.25
			local emitters2 = {}
			local clone2 = wings.GroundRocksModel:Clone()

			if HRP.Parent:FindFirstChild("DragonHybrid") then
				clone2:ScaleTo(1.5)
			end

			local groundRocks = clone2.GroundRocks
			clone2:Destroy()

			for _, emitter in pairs(groundRocks:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				table.insert(emitters2, emitter)
			end

			local v8 = false
			local _ = tick() + 0.25
			local emitters3 = {}
			local clone3 = wings.Effect:Clone()

			if HRP.Parent:FindFirstChild("DragonHybrid") then
				clone3:ScaleTo(1.5)
			end

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				table.insert(emitters3, emitter)
			end

			local v9 = 2 + HRP.Size.Y * 4
			local lastTime2 = tick()
			local v10 = 1
			local v11, v12 = Wind(HRP, v10, v2, player)
			local v13 = false
			local v14 = false
			local clone4 = wings.Extra.WindAuraModel:Clone()

			if v2 == 6 then
				clone4:ScaleTo(2.25)
			end

			local primaryPart = clone4.PrimaryPart
			primaryPart.CFrame = HRP.CFrame
			primaryPart.Weld.Part0 = HRP
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "DragonFruitVFXColor")
			local emitters4 = {}

			for _, emitter in pairs(primaryPart:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				table.insert(emitters4, emitter)
				emitter.Enabled = false
			end

			local v15 = 0.016666666666666666
			local v16 = nil

			while v[HRP] and v[HRP].ID == ID do
				if HRP:IsDescendantOf(workspace) then
					local v17 = false

					if HRP.Velocity.Y > -10 and HRP.Velocity.Magnitude < DISTANCE_THRESHOLD then
						local v18 = math.clamp((10 + HRP.Velocity.Y) / 2.5, 5, 40)
						v5.Angle += v15 * 0.20943951023931956 * v10 * v18

						if v5.Angle >= 1.5707963267948966 then
							v10 = -1
						elseif v5.Angle <= 0.35 then
							local _ = upperTorso.Transparency <= 0
							v10 = 1
						end

						v5.Angle = math.clamp(v5.Angle, 0.35, 1.5707963267948966)

						if tick() - lastTime2 > 0.1 then
							wings2:SetTrailEnabled(HRP.Velocity.Magnitude > DISTANCE_THRESHOLD)
							wings2:SetRate(not (HRP.Velocity.Magnitude > DISTANCE_THRESHOLD) and 0 or math.min(
								1,
								(HRP.Velocity.Magnitude - 130) / 80
							) * 0.3 + 0.7 or 0)
							v14 = HRP.Velocity.Magnitude > DISTANCE_THRESHOLD
						end

						wings2:SetAnim("Flap", v18 * 0.1 * 0.7)
					else
						local angle = v5.Angle
						local v18 = v15 * 2
						v5.Angle = angle + (1.5707963267948966 - angle) * v18

						if tick() - lastTime2 > 0.125 then
							if flag then
								wings2:SetTrailEnabled(false)
								wings2:SetRate(0)
								v14 = false
							else
								wings2:SetTrailEnabled(HRP.Velocity.Magnitude > DISTANCE_THRESHOLD)
								wings2:SetRate(not (HRP.Velocity.Magnitude > DISTANCE_THRESHOLD) and 0 or math.min(
									1,
									(HRP.Velocity.Magnitude - 130) / 80
								) * 0.3 + 0.7 or 0)
								v14 = HRP.Velocity.Magnitude > DISTANCE_THRESHOLD
							end
						end

						if HRP.Velocity.Magnitude > DISTANCE_THRESHOLD then
							wings2:SetAnim("Glide")
							v17 = true
						else
							wings2:SetAnim("Flap", 0.35)
						end
					end

					if upperTorso.Transparency < 1 then
						if v6 == false and v17 == true then
							v6 = true

							for _, v18 in pairs(emitters) do
								v18.Enabled = true
							end
						elseif v6 == true and v17 == false then
							v6 = false

							for _, v18 in pairs(emitters) do
								v18.Enabled = false
							end
						end

						if v7 - tick() <= 0 then
							v7 = tick() + 0.01
							local raycastResult = workspace:Raycast(
								HRP.Position + createVector(0, 1, 0),
								createVector(0, 1, 0) * -v9,
								raycastParams
							)

							if raycastResult then
								local v18 = raycastResult.Position + createVector(0, 1, 0)
								groundRocks.CFrame = CFrame.new(v18, v18 + HRP.CFrame.LookVector)

								if flag == false then
									flag = true

									for _, v19 in pairs(emitters2) do
										v19.Enabled = true
									end
								end

								if v8 == true then
									v8 = false

									for _, v19 in pairs(emitters3) do
										v19.Enabled = false
									end
								end

								for _, v19 in pairs(emitters2) do
									if v19:GetAttribute("Color") then
										v19.Color = ColorSequence.new(
											raycastResult.Instance.Color,
											raycastResult.Instance.Color
										)
									end
								end
							else
								if flag == true then
									flag = false

									for _, v18 in pairs(emitters2) do
										v18.Enabled = false
									end
								end

								if HRP.Position.Y < v9 * 2.5 then
									if v8 == false then
										v8 = true

										for _, v18 in pairs(emitters3) do
											v18.Enabled = true
										end
									end

									local v18 = HRP.CFrame + createVector(0, 1, 0) * (-HRP.Position.Y - 3.3)
									clone3:SetPrimaryPartCFrame(CFrame.lookAt(
										v18.Position,
										v18.Position + v18.LookVector * createVector(1, 0, 1)
									))
								elseif v8 == true then
									v8 = false

									for _, v18 in pairs(emitters3) do
										v18.Enabled = false
									end
								end
							end
						end

						if v14 == false then
							if v13 == false then
								if v16 then
									sound:FadeOut(v16, 0.1)
								end

								v16 = sound:Play("BF_V3_Untransformed_F_WindLoop_02", HRP)
								v12:ChangeState("Enable")
								v13 = true

								for _, v18 in pairs(emitters4) do
									v18.Enabled = true
								end
							end
						elseif v14 == true and v13 == true then
							if v16 then
								sound:FadeOut(v16, 0.1)
							end

							v16 = sound:Play("BF_V3_Untransformed_F_Flames_05", HRP)
							v12:ChangeState("Disable")
							v13 = false

							for _, v18 in pairs(emitters4) do
								v18.Enabled = false
							end
						end
					else
						if v6 == true then
							v6 = false

							for _, v18 in pairs(emitters) do
								v18.Enabled = false
							end
						end

						if v13 == true then
							if v16 then
								sound:FadeOut(v16, 0.1)
							end

							v12:ChangeState("Disable")
							v13 = false

							for _, v18 in pairs(emitters4) do
								v18.Enabled = false
							end
						end

						wings2:SetTrailEnabled(false)
						wings2:SetRate(0)
					end

					wings2:Update(v5.Angle)
					WindUpdate(v11, v2, v5.Angle, true)
					v15 = RunService.RenderStepped:Wait()
				else
					v[HRP] = nil
					pcall(function()
						wings2:Destroy(nil, nil, player)
					end)
					break
				end
			end

			local v17 = tick() - lastTime2 <= 0.25

			if v16 then
				sound:FadeOut(v16, 0.1)
			end

			sound:Play("SpinWooshWeak", HRP)
			local angle = v5.Angle
			v[HRP] = nil
			v12:ChangeState("Disable")

			for _, v18 in pairs(emitters) do
				v18.Enabled = false
			end

			task.spawn(function()
				if v11 then
					for _, v18 in pairs(v11) do
						v18:Destroy()
					end
				end

				for _, v18 in pairs(emitters2) do
					v18.Enabled = false
				end

				for _, v18 in pairs(emitters3) do
					v18.Enabled = false
				end

				for _, v18 in pairs(emitters4) do
					v18.Enabled = false
				end

				task.wait(0.5)
				glide:Destroy()
				task.wait(0.5)
				groundRocks:Destroy()
				clone3:Destroy()
				clone4:Destroy()
			end)
			local lastTime3 = tick()

			while tick() - lastTime3 < 0.25 do
				wings2.Size = 1 - (tick() - lastTime3) / 0.25
				wings2:Update(angle)
				RunService.RenderStepped:Wait()
			end

			wings2:SetAnim(nil)
			wings2:Destroy(not v17, nil, player)
		end
	else
		v[HRP] = nil
	end
end