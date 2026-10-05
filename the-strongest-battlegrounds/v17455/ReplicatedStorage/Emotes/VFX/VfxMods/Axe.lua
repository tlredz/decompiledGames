local Axe = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local able = libraryNew.Able
local _ = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local meshEmit = libraryNew.MeshEmit
local _ = script
local vfx2 = script.vfx2
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)
local Libraryyyy2 = require(game.ReplicatedStorage.Resources.Libraryyyy2)

function Axe.HitEvent(p)
	local data = p.Data
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(5, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local victim = data.Victim
	local primaryPart2 = victim.PrimaryPart
	local playingAnimationTracks = char.Humanoid:GetPlayingAnimationTracks()
	local v2 = nil

	for i = 1, #playingAnimationTracks do
		if playingAnimationTracks[i].Animation.AnimationId ~= data.Anim then
			continue
		end

		v2 = playingAnimationTracks[i]
		break
	end

	local descendants = {}
	local descendants2 = {}
	local trails = {}
	local beams = {}
	local v3 = {}
	local folder = nil
	local v4 = false
	local fn

	local function nuts()
		local clone = script.ZombieManFX:Clone()
		clone.Parent = workspace.Thrown
		clone:PivotTo(primaryPart.CFrame)
		game.Debris:AddItem(clone, 8)
		local folder2 = quickFX({
			FX = vfx2.Spinning,
			Maid = object._maid,
			Anchor = primaryPart.CFrame
		})
		local folder3 = quickFX({
			FX = vfx2.Rot4,
			Maid = object._maid,
			Anchor = primaryPart.CFrame
		})
		local rot = folder3:FindFirstChild("Rot")
		local beams2 = rot and rot:FindFirstChild("beams")
		local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(
				1,
				1
			) })

		fn = function()
			if not v4 and v2 and (not v2 or v2.IsPlaying) then
				return true
			end

			for _, v5 in ipairs(trails) do
				v5.Enabled = false
				game.Debris:AddItem(v5, 1)
			end

			for _, v5 in ipairs(beams) do
				playTween(v5, {
					Time = 0.15,
					EasingStyle = "Sine",
					Goal = {
						Transparency = numberSequence
					}
				})
				game.Debris:AddItem(v5, 0.15)
			end

			task.wait(0.5)

			if v3[folder] then
				v3[folder] = nil
				game.Debris:AddItem(folder, 0.1)
			end

			able({
				FX = folder2,
				On = false
			})
			able({
				FX = folder3,
				On = false
			})

			if folder3 then
				local parts = {}

				for _, part in ipairs(folder3:GetDescendants()) do
					if part:IsA("Part") then
						parts[#parts + 1] = part
					end
				end

				local tweenInfo = TweenInfo.new(0.3)

				for _, v5 in ipairs(parts) do
					TweenService:Create(v5, tweenInfo, {
						Transparency = 1
					}):Play()
				end
			end

			v4 = true
			return false
		end

		if not fn() then
			return
		end

		playAttachment(folder3)

		local function Beams()
			folder = quickFX({
				FX = vfx2.zxcTest2,
				Maid = object._maid,
				Anchor = CFrame.new()
			})

			if not fn() then
				return
			end

			for _, beam in ipairs(folder:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam:SetAttribute("OGT", beam.Transparency)
				beam.Transparency = numberSequence
				beams[#beams + 1] = beam
			end

			for _, v5 in ipairs(beams) do
				playTween(v5, {
					Time = 0.3,
					EasingStyle = "Sine",
					Goal = {
						Transparency = v5:GetAttribute("OGT")
					}
				})
			end

			if not fn() then
				return
			end

			local rotSpeed = object._maid:give(Instance.new("NumberValue"))
			rotSpeed.Value = 15
			TweenService:Create(rotSpeed, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Value = 1
			}):Play()
			local v6 = object._maid:give(Instance.new("NumberValue"))
			v6.Value = 0.3
			TweenService:Create(v6, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Value = 1
			}):Play()
			object._maid:giveTask(v6.Changed:Connect(function()
				folder:ScaleTo(v6.Value)
			end))
			v3[folder] = {
				RotSpeed = rotSpeed,
				StartRot = random:NextNumber(-360, 360)
			}

			if not fn() then
				return
			end

			task.delay(0.25, function()
				if not fn() then
					return
				end

				for _, v7 in ipairs(beams) do
					playTween(v7, {
						Time = 0.15,
						EasingStyle = "Sine",
						Goal = {
							Transparency = numberSequence
						}
					})
					game.Debris:AddItem(v7, 0.15)
				end

				dtwait(0.2)

				if not fn() then
					return
				end

				v3[folder] = nil
				game.Debris:AddItem(folder, 0.1)
			end)
		end

		for _, descendant in ipairs(folder2:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("ObjectValue") then
				descendants[#descendants + 1] = descendant
			end
		end

		for _, descendant in ipairs(folder3:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("ObjectValue") then
				descendants[#descendants + 1] = descendant
			elseif descendant:IsA("Beam") then
				descendant:SetAttribute("OGT", descendant.Transparency)
				descendant.Transparency = numberSequence
				descendants2[#descendants2 + 1] = descendant
			end
		end

		able({
			FX = folder2,
			On = false
		})
		able({
			FX = folder3,
			On = false
		})
		local v5 = object._maid:give(Instance.new("NumberValue"))
		v5.Value = 1

		for _, emitter in ipairs(descendants) do
			if emitter:IsA("ParticleEmitter") then
				emitter.TimeScale = v5.Value
			else
				emitter:SetAttribute("TimeScale", v5.Value)
			end
		end

		local lastTime = tick()
		task.spawn(function()
			local v6 = 0

			while tick() - lastTime < 5 and fn() do
				local now = tick()

				if now - v6 < 0.03333333333333333 then
					local RunService = game:GetService("RunService")
					RunService.Heartbeat:Wait()
				else
					local cFrame = primaryPart.CFrame
					local position = primaryPart.Position
					local value = v5.Value
					clone:PivotTo(cFrame)
					folder2:PivotTo(cFrame * CFrame.new(0, -1, 0))
					local _, v7, _ = folder3:GetPivot():ToOrientation()
					folder3:PivotTo(CFrame.new(position) * CFrame.new(0, -1.5, 0) * CFrame.Angles(
						0,
						v7 + math.rad(2 * -value),
						0
					))

					if beams2 then
						beams2.CFrame *= CFrame.Angles(0, math.rad(-2 * value), 0)
					end

					v6 = now

					for k, v8 in pairs(v3) do
						local _, v9, _ = k:GetPivot():ToOrientation()
						k:PivotTo(CFrame.new(position) * CFrame.new(0, -5, 0) * CFrame.Angles(
							0,
							v9 - math.rad(v8.RotSpeed.Value),
							0
						))
					end

					local RunService = game:GetService("RunService")
					RunService.Heartbeat:Wait()
				end
			end
		end)
		local v6 = object._maid:give(vfx2.stuff:Clone())
		local circle003 = char.Axe["Circle.003"]
		local trails2 = {}

		for _, trail in ipairs(v6:GetChildren()) do
			trail.Parent = circle003

			if trail:IsA("Trail") then
				trail.Enabled = true
				trails[#trails + 1] = trail
			end

			trails2[#trails2 + 1] = trail
			game.Debris:AddItem(trail, 6)
		end

		task.spawn(function()
			local axeslamposition = char:WaitForChild("axeslamposition", 5)

			if axeslamposition and fn() then
				local clone2 = vfx2.Plume:Clone()
				task.delay(5, function()
					if clone2 and clone2.Parent then
						clone2:Destroy()
					end
				end)
				clone2:PivotTo(axeslamposition.Value)
				clone2.Parent = EFP
				playAttachment(clone2, nil, {
					MeshIgnore = true
				})
				meshEmit.Emit(clone2)
				able({
					FX = clone2.eh.mesh,
					On = true
				})
			end
		end)
		return FrameMarker.new({
			Framerate = 60
		}):Chain({
			[0] = function()
				if not fn() then
					return
				end

				Libraryyyy2.Lighting.Highlight({
					Model = primaryPart.Parent,
					Duration = 0.6,
					FillColor = Color3.fromRGB(255, 255, 255),
					OutlineColor = Color3.fromRGB(255, 255, 255),
					DepthMode = Enum.HighlightDepthMode.Occluded,
					FadeDirection = "Out",
					InitalFillTransparency = 0.25
				})
			end,
			[34] = function()
				if not fn() then
					return
				end

				Libraryyyy2.Particles:Emit(clone.Swing)
				playAttachment(folder2)
				TweenService:Create(v5, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
					Value = 0.3
				}):Play()
			end,
			[52] = function()
				if not fn() then
					return
				end

				Libraryyyy2.Particles:Emit(clone.Hit)
				Libraryyyy2.Particles:Freeze(clone.Hit.Hit, 0.15, 0.17, 0.5)
				Libraryyyy2.Particles:Freeze(clone.Hit.Smoke, 0.4, 0.2, 0.35)
				local hit = clone.Hit.Hit
				hit.Parent = victim.Torso
				hit.CFrame = CFrame.new()
				game.Debris:AddItem(hit, 3)
				Libraryyyy2.Lighting.Highlight({
					Model = primaryPart2.Parent,
					Duration = 1,
					FillColor = Color3.fromRGB(159, 29, 29),
					OutlineColor = Color3.fromRGB(159, 29, 29),
					DepthMode = Enum.HighlightDepthMode.Occluded,
					FadeDirection = "Out",
					InitalFillTransparency = 0
				})
				object._maid:giveTask(v5.Changed:Connect(function()
					local timeScale = v5.Value

					for _, emitter in ipairs(descendants) do
						if emitter:IsA("ParticleEmitter") then
							emitter.TimeScale = timeScale
						else
							emitter:SetAttribute("TimeScale", timeScale)
						end
					end
				end))
				TweenService:Create(v5, TweenInfo.new(1.4, Enum.EasingStyle.Quad), {
					Value = 1
				}):Play()
				able({
					FX = folder3,
					On = true
				})
			end,
			[66] = function()
				if not fn() then
					return
				end

				TweenInfo.new(0.6, Enum.EasingStyle.Sine)

				for _, v7 in ipairs(descendants2) do
					playTween(v7, {
						Time = 0.6,
						EasingStyle = "Sine",
						Goal = {
							Transparency = v7:GetAttribute("OGT")
						}
					})
				end
			end,
			[80] = function()
				if not fn() then
					return
				end

				able({
					FX = folder2,
					On = true
				})
				able({
					FX = folder3,
					On = true
				})
				task.delay(0.5, function()
					for _, descendant in ipairs(folder3:GetDescendants()) do
						if descendant.Name == "Smoke" then
							descendant.Enabled = false
						end
					end
				end)
				task.delay(0.75, function()
					able({
						FX = folder2,
						On = false
					})
					able({
						FX = folder3,
						On = false
					})
				end)
			end,
			[90] = function()
				if not fn() then
					return
				end

				for _, v7 in ipairs(descendants2) do
					playTween(v7, {
						Time = 1,
						EasingStyle = "Sine",
						Goal = {
							Transparency = numberSequence
						}
					})
					game.Debris:AddItem(v7, 1)
				end
			end,
			[125] = function()
				if not fn() then
					return
				end

				for _, trail in ipairs(trails2) do
					if trail:IsA("Trail") and trail.Enabled == true then
						playTween(trail, {
							Time = 1,
							EasingStyle = "Sine",
							Goal = {
								Transparency = numberSequence
							}
						})
					end
				end
			end,
			[132] = function()
				if not fn() then
					return
				end

				Libraryyyy2.Particles:Emit(clone.Up)
			end,
			[142] = function()
				if fn() then
				end
			end,
			[178] = function()
				if fn() then
				end
			end,
			[182] = function()
				if not fn() then
					return
				end

				Libraryyyy2.Particles:Emit(clone.LastSwing.Slash)
			end,
			[185] = function() end
		})
	end

	nuts()
end

function Axe.LandEvent(_)
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(5, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local _ = game.Workspace["Zombies Man"].User.PrimaryPart
	local _ = game.Workspace["Zombies Man"].Victim.PrimaryPart
end

function Axe.FirstEvent(p)
	local data = p.Data
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(5, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local _ = data.Char.PrimaryPart
	local pos = data.Pos

	if pos then
		local v2 = quickFX({
			FX = script.vfx2.AxeHit,
			Maid = object._maid,
			Anchor = CFrame.new(pos)
		})
		v2:ScaleTo(3)
		playAttachment(v2)
	end
end

function Axe.SwingEvent(p)
	local data = p.Data
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(5, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local char = data.Char
	local _ = char.PrimaryPart
	local circle003 = char.Axe["Circle.003"]
	local v2 = object._maid:give(script.vfx2.AxeGlint:Clone())
	v2.Parent = circle003
	task.delay(0.3, function()
		playAttachment(v2)
	end)
	local v3 = object._maid:give(vfx2.stuff:Clone())
	local children = {}

	for _, child in pairs(v3:GetChildren()) do
		child.Parent = char.Axe["Circle.003"]
		table.insert(children, child)
		game.Debris:AddItem(child, 6)
	end

	task.delay(0.4, function()
		for _, trail in pairs(children) do
			if trail:IsA("Trail") and trail.Enabled == true then
				playTween(trail, {
					Time = 1,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				})
			end
		end
	end)
end

return Axe