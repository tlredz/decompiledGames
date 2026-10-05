local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local RocksModule2 = require(game.ReplicatedStorage.Util.RocksModule2)
local FX = require(ReplicatedStorage.FX)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function debrisPart(hit, pos, norm)
	local v = math.random(20, 44) / 10
	local v2 = math.random(27, 48) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Material = hit.Material
	part.Transparency = hit.Transparency
	part.Reflectance = hit.Reflectance
	part.Color = hit.Color
	part.Size = Vector3.new(v, v2, v)
	part.CFrame = CFrame.new(pos, pos + norm) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * Vector3.new(
		math.random(100, 130),
		math.random(70, 100),
		math.random(100, 120)
	)
	part.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	return part
end

local mammoth = FX:WaitForChild("Mammoth")

local function jump(character, rootPart, CF, stage, rayData)
	local _ = rootPart.Size.Y * 0.5 + rootPart.Parent.Humanoid.HipHeight + 5
	local mammoth2 = character:FindFirstChild("Mammoth").Mammoth
	local _ = mammoth2["body4.002"]

	if stage == 1 then
		if character == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(3, 6, 0.1, 0.6, createVector(2, 3, 2), createVector(3, 2, 3))
		end

		mammoth2["body4.002"].FLIGHT.Enabled = true
		mammoth2["body4.002"].FLIGHT2.Enabled = true
		Util.Sound:Play("MammothBlast", rootPart.Position, 25, 1 + math.random(-10, 10) / 100, 1.33)
		task.spawn(function()
			local clone = mammoth.JumpEmit:Clone()
			local hit = rayData.hit
			local _ = rayData.pos
			local _ = rayData.norm
			clone.CFrame = CF
			clone.Parent = _WorldOrigin
			Util.Debris:AddItem(clone, 2.5)
			clone.Jump.SMOKE.Color = ColorSequence.new(hit.Color)
			RocksModule2.Ground(
				clone.Position + createVector(0, 1, 0),
				32,
				createVector(10, 5.5, 10),
				nil,
				12,
				false,
				3
			)
			task.spawn(function()
				local descendants = clone:GetDescendants()
				local v = {}

				for k, emitter in pairs(descendants) do
					if emitter:IsA("ParticleEmitter") then
						v[k] = {
							count = emitter:GetAttribute("EmitCount") or 0,
							delay = emitter:GetAttribute("EmitDelay") or 0
						}
					end
				end

				for k, descendant in pairs(descendants) do
					if not v[k] then
						continue
					end

					if v[k].delay > 0 then
						local v2 = k
						local v3 = descendant
						task.spawn(function()
							task.wait(v[v2].delay)
							v3:Emit(v[v2].count)
						end)
					else
						descendant:Emit(v[k].count)
					end
				end
			end)
		end)
		task.wait(0.2)
		mammoth2["body4.002"].FLIGHT.Enabled = false
		mammoth2["body4.002"].FLIGHT2.Enabled = false
	elseif stage == 2 then
		Util.Sound:Play("MammothFallCrush", rootPart, 25, 1 + math.random(-5, 5) / 100, 1.5)
		task.spawn(function()
			local clone = mammoth.LandSmash:Clone()
			local hit = rayData.hit
			local pos = rayData.pos
			local norm = rayData.norm
			task.spawn(function()
				for _ = 1, 16 do
					debrisPart(hit, pos, norm)
				end
			end)
			local _ = rootPart.CFrame
			clone.CFrame = CF
			clone.Parent = _WorldOrigin
			Util.Debris:AddItem(clone, 3)
			clone.Attachment.SMOKE.Color = ColorSequence.new(hit.Color)
			TweenService:Create(
				clone,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(83, 0.03, 83)
				}
			):Play()
			TweenService:Create(
				clone.Decal,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
				{
					Color3 = Color3.new(0, 0, 0)
				}
			):Play()
			TweenService:Create(
				clone.Decal,
				TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
				{
					Transparency = 1
				}
			):Play()
			RocksModule2.Ground(
				clone.Position + createVector(0, 1, 0),
				62,
				createVector(13, 7.5, 13),
				nil,
				17,
				false,
				3
			)
			RocksModule2.Ground(clone.Position + createVector(0, 1, 0), 47, createVector(10, 5, 10), nil, 14, false, 3)
			local descendants = clone:GetDescendants()
			local v = {}

			for k, emitter in pairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					v[k] = {
						count = emitter:GetAttribute("EmitCount") or 0,
						delay = emitter:GetAttribute("EmitDelay") or 0
					}
				end
			end

			for k, descendant in pairs(descendants) do
				if not v[k] then
					continue
				end

				if v[k].delay > 0 then
					local v2 = k
					local v3 = descendant
					task.spawn(function()
						task.wait(v[v2].delay)
						v3:Emit(v[v2].count)
					end)
				else
					descendant:Emit(v[k].count)
				end
			end
		end)

		if character == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(8, 9, 0.1, 0.8, createVector(4, 4, 4), createVector(3, 2, 3))
			local clone = script.LTN:Clone()
			clone.Parent = game.Lighting
			Util.Debris:AddItem(clone, 2)
			TweenService:Create(clone, TweenInfo.new(0.013), {
				TintColor = Color3.fromRGB(0, 0, 0),
				Brightness = 0.3,
				Contrast = -1,
				Saturation = 30
			}):Play()
			task.wait()
			TweenService:Create(clone, TweenInfo.new(0.01), {
				TintColor = Color3.fromRGB(255, 16, 16),
				Brightness = 1,
				Contrast = 10,
				Saturation = -1
			}):Play()
			task.wait()
			TweenService:Create(clone, TweenInfo.new(0.01), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
			Util.Debris:AddItem(clone, 1)
		end
	end
end

return function(player)
	local rootPart = player.RootPart or nil
	local CF = player.CF
	local character = player.Character or nil
	local stage = player.stage

	if (CF.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	jump(character, rootPart, CF, stage, player.RayData)
end