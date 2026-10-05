local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local orbs = FX:WaitForChild("DracoRace").Orbs
local _ = Util.Sound
local _ = Util.Debris

local function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function charInRange(vector2: Vector3, p: number)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local magnitude = (humanoidRootPart.Position - vector2).magnitude

		if magnitude <= p then
			return magnitude
		end
	end

	return false
end

local v = {}

local function unhookCharacter(p)
	if v[p] then
		local v2 = v[p]

		if v2.OrbsChanged then
			v2.OrbsChanged:Disconnect()
			v2.OrbsChanged = nil
		end

		if v2.CharChanged then
			v2.CharChanged:Disconnect()
			v2.CharChanged = nil
		end

		if v2.Orbs and #v2.Orbs > 0 then
			for _, orb in ipairs(v2.Orbs) do
				Util.Debris:AddItem(orb, 2)
			end

			v2.Orbs = nil
		end

		v[p] = nil
	end
end

local sizesByName = {}

for _, child in pairs(orbs.Dracorb.Attach.Normal:GetChildren()) do
	sizesByName[child.Name] = child.Size
end

local function hookCharacter(parent, player)
	if parent and parent:IsDescendantOf(workspace) then
		v[parent] = {
			Valid = true,
			Hidden = false,
			Orbs = {},
			OrbVal = parent:GetAttribute("DracoOrbs") or 0,
			OrbsChanged = nil,
			CharChanged = nil
		}

		for _ = 1, 4 do
			local clone = orbs.Dracorb:Clone()
			clone.CFrame = CFrame.new(0, 99999999, 0)
			clone.Size = Vector3.new()
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "DracoRaceVFXColors", true)
			Util.SyncColorsOnChange(clone, player, "DracoRaceVFXColors")
			table.insert(v[parent].Orbs, clone)
		end

		local ancestryChangedConnection = nil
		ancestryChangedConnection = parent.AncestryChanged:Connect(function(_, instance)
			if not instance or instance:IsDescendantOf(workspace) then
				if v[parent] then
					v[parent].Valid = false
				end

				ancestryChangedConnection:Disconnect()
			end
		end)
		local dracoOrbsChangedConnection = parent:GetAttributeChangedSignal("DracoOrbs"):Connect(function()
			if v[parent] then
				local v2 = v[parent]
				local dracoOrbs = parent:GetAttribute("DracoOrbs")

				if dracoOrbs then
					if dracoOrbs ~= v2.OrbVal then
						local v3 = dracoOrbs - v2.OrbVal

						if v3 ~= 0 then
							for i = 1, #v2.Orbs do
								if i < dracoOrbs then
									v2.Orbs[i].Size = createVector(1.5, 1.5, 1.5)
									v2.Orbs[i].Transparency = 0

									if v3 > 1 then
										for _, descendant in ipairs(v2.Orbs[i]:GetDescendants()) do
											if descendant.Parent.Name == "GainEffect" then
												descendant:Emit(descendant:GetAttribute("EmitCount"))
											end
										end

										Util.Sound:Play("SetFire", v2.Orbs[i], nil, 1, 0.5)
										Util.Sound:Play("ElectricPowerup", v2.Orbs[i], nil, 1.5, 0.3)
										Util.Sound:Play("ThrowFireball", v2.Orbs[i], nil, 1, 0.7)
									end

									for _, descendant in ipairs(v2.Orbs[i]:GetDescendants()) do
										if descendant.Parent.Name == "FullEffect" then
											descendant.Enabled = true
										elseif descendant.Parent.Name == "Normal" then
											descendant.Enabled = false
										end
									end
								elseif i < dracoOrbs + 0.999 then
									local v4 = dracoOrbs < 1 and dracoOrbs or dracoOrbs - i + 1
									v2.Orbs[i].Size = createVector(0.25, 0.25, 0.25) + createVector(1.25, 1.25, 1.25) * v4
									v2.Orbs[i].Transparency = 0

									for _, descendant in ipairs(v2.Orbs[i]:GetDescendants()) do
										if descendant.Parent.Name == "FullEffect" then
											descendant.Enabled = false
										elseif descendant.Parent.Name == "Normal" then
											local numberSequenceKeypoints = {}

											for _, keypoint in next, sizesByName[descendant.Name].Keypoints, nil do
												table.insert(
													numberSequenceKeypoints,
													NumberSequenceKeypoint.new(
														keypoint.Time,
														keypoint.Value * v4,
														keypoint.Envelope * v4
													)
												)
											end

											descendant.Size = NumberSequence.new(numberSequenceKeypoints)
											descendant.Enabled = true
										end
									end
								else
									v2.Orbs[i].Transparency = 1

									for _, emitter in ipairs(v2.Orbs[i]:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end
							end

							v[parent].OrbVal = dracoOrbs
						end
					end
				else
					for i = 1, #v2.Orbs do
						for _, emitter in ipairs(v2.Orbs[i]:GetDescendants()) do
							if emitter.Parent.Name == "Blast" then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							elseif emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
								emitter:Clear()
							end

							v2.Orbs[i].Transparency = 1
						end

						v2.Orbs[i].Size = Vector3.new()
					end

					local humanoidRootPart = parent and parent:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						Util.Sound:Play("SandCWind", humanoidRootPart.Position, nil, math.random(10, 15) / 10, 0.35)
						Util.Sound:Play(
							"ShortExplosion3_2",
							humanoidRootPart.Position,
							nil,
							math.random(9, 17) / 10,
							0.45
						)
						local position = humanoidRootPart.Position
						local character = game.Players.LocalPlayer.Character
						local humanoidRootPart2 = character ~= nil and character:FindFirstChild("HumanoidRootPart")
						local magnitude

						if humanoidRootPart2 then
							magnitude = (humanoidRootPart2.Position - position).magnitude

							if not (magnitude <= 50) then
								magnitude = false
							end
						else
							magnitude = false
						end

						if magnitude then
							Util.CameraShaker:ShakeOnce(5, 5, 0.05, 0.3)
						end
					end

					unhookCharacter(parent)
				end
			end
		end)
		v[parent].CharChanged = ancestryChangedConnection
		v[parent].OrbsChanged = dracoOrbsChangedConnection
		parent:SetAttribute("DracoOrbs", (parent:GetAttribute("DracoOrbs") or 0) + 0.00001)
	end
end

local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function trigger()
	if not v2 then
		v2 = true
		local v3 = 0.016666666666666666
		task.spawn(function()
			while next(v) do
				local _ = v3 * 60
				local _ = workspace.CurrentCamera.CFrame.Position

				for k, v4 in pairs(v) do
					if k == nil or not k:IsDescendantOf(workspace) then
						v4.Valid = false
					elseif not k:FindFirstChildOfClass("Humanoid") or k:FindFirstChildOfClass("Humanoid").Health <= 0 then
						v4.Valid = false
					end

					if v4.Valid then
						local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart then
							for k2, orb in pairs(v4.Orbs) do
								local v5 = 6.283185307179586 * k2 / 4
								orb.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(
									math.cos(v5 + os.clock()) * 10,
									0,
									math.sin(v5 + os.clock()) * 10
								))
							end
						end
					else
						unhookCharacter(k)
					end
				end

				v3 = RunService.Heartbeat:Wait()
			end

			v2 = false
			v = {}
		end)
	end
end

return function(p)
	local root = p.Root
	local parent = root.Parent
	local player = p.player

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	if parent and parent:IsA("Model") and not v[parent] then
		hookCharacter(parent, player)
		trigger() -- equivalent call inferred; original call site unknown
	end
end