local FinishSend = {}
local library = require(script.Parent.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local playTween = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local dtwait = library.dtwait
local EFP = library.EFP
local playMesh = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local raiseZIndex = library.RaiseZIndex
local able = library.Able
local lifeScale = library.LifeScale
local quickFX = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local newlibrarystar = require(game.ReplicatedStorage.Resources.newlibrarystar)
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

function FinishSend.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = {}
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local bind = data.bind

	local function Cancelled()
		return not (bind and bind.Parent)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function TrackFX(p2)
		table.insert(v, p2)
		return p2
	end

	local function DisableFX(effect)
		if not effect then
			return
		end

		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = false
		end

		for _, effect2 in pairs(effect:GetDescendants()) do
			if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
				continue
			end

			effect2.Enabled = false
		end
	end

	if bind then
		bind.Destroying:Once(function()
			for _, v3 in pairs(v) do
				DisableFX(v3)
			end

			task.delay(1, Clean)
		end)
	end

	local function FirstEvent()
		if not (bind and bind.Parent) then
			return
		end

		local function Kanjos()
			task.spawn(function()
				local v3 = {}

				for i = 1, 4 do
					if bind and bind.Parent then
						local anchor

						if i == 1 then
							anchor = humanoidRootPart.CFrame * CFrame.new(3.5, 1, -2)
						elseif i == 2 then
							anchor = humanoidRootPart.CFrame * CFrame.new(3.5, -1, -2)
						elseif i == 3 then
							anchor = humanoidRootPart.CFrame * CFrame.new(-3.5, 1, -2)
						else
							anchor = humanoidRootPart.CFrame * CFrame.new(-3.5, -1, -2)
						end

						local FX = quickFX({
							FX = vfx.Kanjos:FindFirstChild(i),
							Maid = object._maid,
							Anchor = anchor
						});
						(TrackFX(FX)):ScaleTo(0.65)
						raiseZIndex({
							FX = FX,
							Count = -3
						})
						playAttachment(FX)
						table.insert(v3, FX)
						task.wait(0.25)

						if not (bind and bind.Parent) then
							for _, v6 in pairs(v3) do
								DisableFX(v6)
							end

							return
						end
					else
						for _, v4 in pairs(v3) do
							DisableFX(v4)
						end

						return
					end
				end

				task.wait(0.3)

				if bind and bind.Parent then
					for _, folder in pairs(v3) do
						if bind and bind.Parent then
							for _, emitter in pairs(folder:GetDescendants()) do
								if bind and bind.Parent then
									if emitter:IsA("ParticleEmitter") then
										TweenService:Create(emitter, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
											TimeScale = 1
										}):Play()
									end
								else
									for _, v4 in pairs(v3) do
										DisableFX(v4)
									end

									return
								end
							end
						else
							for _, v4 in pairs(v3) do
								DisableFX(v4)
							end

							return
						end
					end
				else
					for _, v4 in pairs(v3) do
						DisableFX(v4)
					end
				end
			end)
		end

		local function Wind()
			if not (bind and bind.Parent) then
				return
			end

			local model = object._maid:give(vfx.Wind:Clone());
			(TrackFX(model)):ScaleTo(1)
			playMesh({
				Model = model,
				T = 0.98,
				EndT = 1,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -3, 1) * CFrame.Angles(0, 1.5707963267948966, 0),
				Info = TweenInfo.new(1, Enum.EasingStyle.Sine)
			})

			if not (bind and bind.Parent) then
				DisableFX(model)
				return
			end

			local folder = quickFX({
				FX = vfx.pls,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			});
			(TrackFX(folder)):ScaleTo(0.05)

			for _, beam in pairs(folder:GetDescendants()) do
				if not (bind and bind.Parent) then
					DisableFX(folder)
					return
				end

				if not beam:IsA("Beam") then
					continue
				end

				local transparency = beam.Transparency
				beam.Brightness += 3
				beam.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
				playTween(beam, {
					Time = 0.4,
					EasingStyle = "Sine",
					Goal = {
						Transparency = transparency
					}
				})
				beam.TextureSpeed *= 0.1
			end

			local v4 = object._maid:give(Instance.new("NumberValue"))
			local v5 = object._maid:give(Instance.new("NumberValue"))
			v5.Value = folder:GetScale()
			v4.Value = 4
			TweenService:Create(v4, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				Value = 0
			}):Play()
			TweenService:Create(v5, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				Value = 0.2
			}):Play()
			object._maid:giveTask(v5.Changed:Connect(function()
				if bind and bind.Parent then
					folder:ScaleTo(v5.Value)
				end
			end))
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 3 do
					if not (bind and bind.Parent) then
						DisableFX(folder)
						break
					end

					folder:PivotTo(folder:GetPivot() * CFrame.Angles(0, math.rad(v4.Value), 0))
					dtwait(0.01)

					if bind and bind.Parent then
						continue
					end

					DisableFX(folder)
					break
				end
			end)
			task.delay(1.3, function()
				if not (bind and bind.Parent) then
					DisableFX(folder)
					return
				end

				for _, beam in pairs(folder:GetDescendants()) do
					if bind and bind.Parent then
						if beam:IsA("Beam") then
							playTween(beam, {
								Time = 0.9,
								EasingStyle = "Sine",
								Goal = {
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(1, 1)
									})
								}
							})
							game.Debris:AddItem(beam, 0.9)
						end
					else
						DisableFX(folder)
						break
					end
				end
			end)
		end

		Wind()

		if not (bind and bind.Parent) then
			return
		end

		local v3 = {}

		for k, part in pairs({ char["Left Arm"], char["Right Arm"] }) do
			if bind and bind.Parent then
				local v5

				if k == 1 then
					v5 = object._maid:give(vfx.WaterPalm:Clone())

					if not TrackFX(v5) then
						v5 = object._maid:give(vfx.WaterPalmRed:Clone())
						table.insert(v, v5)
					end
				else
					v5 = object._maid:give(vfx.WaterPalmRed:Clone())
					table.insert(v, v5)
				end

				local weld = Instance.new("Weld")
				weld.Part0 = v5
				weld.Part1 = part
				weld.Parent = v5
				v5.Parent = EFP
				table.insert(v3, v5)
				local v6 = k == 1 and 0 or 3.141592653589793
				local v7 = object._maid:give(vfx.SurfaceLight:Clone());
				(TrackFX(v7)):PivotTo(humanoidRootPart.CFrame * CFrame.new(k == 1 and -5 or 5, -2, 0) * CFrame.Angles(
					0,
					v6,
					0
				))
				v7.SurfaceLight.Brightness = 0
				TweenService:Create(v7.SurfaceLight, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Brightness = 10
				}):Play()
				v7.SurfaceLight.Color = k == 1 and Color3.new(0.203922, 0.588235, 1) or Color3.new(1, 0, 0)
				v7.Parent = EFP
				game.Debris:AddItem(v7, 6)
				task.delay(1.5, function()
					if bind and bind.Parent then
						TweenService:Create(v7.SurfaceLight, TweenInfo.new(1, Enum.EasingStyle.Sine), {
							Brightness = 10,
							Range = 0
						}):Play()
					else
						DisableFX(v7)
					end
				end)
				local weld2 = Instance.new("Weld")
				weld2.Part0 = v7
				weld2.Part1 = part
				weld2.Parent = v7
				v5.Parent = EFP
				local v9 = object._maid:give(Instance.new("Highlight"))
				table.insert(v, v9)
				v9.FillTransparency = 1
				v9.FillColor = k == 1 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(49, 94, 255)
				v9.OutlineTransparency = 1
				v9.DepthMode = Enum.HighlightDepthMode.Occluded
				v9.Adornee = k == 1 and char["Right Arm"] or char["Left Arm"]
				v9.Parent = char
				TweenService:Create(v9, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					FillTransparency = k == 1 and 0.5 or 0.35
				}):Play()
				task.delay(1.1, function()
					if bind and bind.Parent then
						TweenService:Create(v9, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							FillTransparency = 1
						}):Play()
					end
				end)
			else
				for _, v5 in pairs(v3) do
					DisableFX(v5)
				end

				return
			end
		end

		for k, part in pairs({ char["Left Arm"], char["Right Arm"] }) do
			if bind and bind.Parent then
				local v5

				if k == 1 then
					v5 = object._maid:give(vfx.TrailArmRed:Clone())

					if not TrackFX(v5) then
						v5 = object._maid:give(vfx.TrailArmBlue:Clone())
						table.insert(v, v5)
					end
				else
					v5 = object._maid:give(vfx.TrailArmBlue:Clone())
					table.insert(v, v5)
				end

				local weld = Instance.new("Weld")
				weld.Part0 = v5
				weld.Part1 = part
				weld.Parent = v5
				v5.Parent = EFP
				table.insert(v3, v5)
			else
				for _, v5 in pairs(v3) do
					DisableFX(v5)
				end

				return
			end
		end

		for _, folder in pairs(v3) do
			if bind and bind.Parent then
				for _, trail in pairs(folder:GetDescendants()) do
					if bind and bind.Parent then
						if trail:IsA("Trail") then
							trail.Lifetime = 1
						end
					else
						for _, v4 in pairs(v3) do
							DisableFX(v4)
						end

						return
					end
				end
			else
				for _, v4 in pairs(v3) do
					DisableFX(v4)
				end

				return
			end
		end

		task.delay(1.3, function()
			if bind and bind.Parent then
				for _, folder in pairs(v3) do
					if bind and bind.Parent then
						for _, effect in pairs(folder:GetDescendants()) do
							if bind and bind.Parent then
								if effect:IsA("Trail") then
									playTween(effect, {
										Time = 0.5,
										EasingStyle = "Sine",
										Goal = {
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 1),
												NumberSequenceKeypoint.new(1, 1)
											})
										}
									})
									game.Debris:AddItem(effect, 0.5)
								elseif effect:IsA("ParticleEmitter") then
									effect.Enabled = false
								end
							else
								for _, v4 in pairs(v3) do
									DisableFX(v4)
								end

								return
							end
						end
					else
						for _, v4 in pairs(v3) do
							DisableFX(v4)
						end

						return
					end
				end
			else
				for _, v4 in pairs(v3) do
					DisableFX(v4)
				end
			end
		end)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function FinishSend.DashEvent(p)
	local data = p.Data
	local char = data.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local bind = data.bind

	local function Cancelled()
		return not (bind and bind.Parent)
	end

	if bind then
		bind.Destroying:Once(function()
			task.delay(1, Clean)
		end)
	end

	local function DashEvent()
		if not (bind and bind.Parent) then
			return
		end

		print("DASH")

		if not (bind and bind.Parent) then
			return
		end

		local Sky_Ripping_Fist2 = require(script.Sky_Ripping_Fist2)

		if bind and bind.Parent then
			Sky_Ripping_Fist2(data)
		end
	end

	task.spawn(DashEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function FinishSend.BarrageEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = {}
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local bind = data.bind

	local function Cancelled()
		return not (bind and bind.Parent)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function TrackFX(p2)
		table.insert(v, p2)
		return p2
	end

	local function DisableFX(effect)
		if not effect then
			return
		end

		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = false
		end

		for _, effect2 in pairs(effect:GetDescendants()) do
			if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
				continue
			end

			effect2.Enabled = false
		end
	end

	if bind then
		bind.Destroying:Once(function()
			for _, v3 in pairs(v) do
				DisableFX(v3)
			end

			task.delay(1, Clean)
		end)
	end

	local function BarrageEvent()
		if not (bind and bind.Parent) then
			return
		end

		require(script.Trail)
		task.spawn(function() end)
		local v3 = {
			Blue = Color3.fromRGB(0, 145, 255),
			Red = Color3.fromRGB(255, 0, 0)
		}
		local v4 = "Blue"
		task.spawn(function()
			if not (bind and bind.Parent) then
				return
			end

			local FX = quickFX({
				FX = vfx.JustBarrage,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
			})
			table.insert(v, FX)
			able({
				FX = FX.JustBarrage.f205.gr,
				On = false
			})
			newlibrarystar.particles.slowmo(
				FX.JustBarrage.f205,
				TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				0.3
			)
			local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			if not (bind and bind.Parent) then
				DisableFX(FX)
				return
			end

			local FX2 = quickFX({
				FX = vfx.BarrageSmoke,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(
					0,
					0,
					0
				)
			})
			table.insert(v, FX2)
			able({
				FX = FX2,
				On = true
			})
			task.delay(0.1, function()
				if bind and bind.Parent then
					newlibrarystar.particles.slowmo(
						FX.JustBarrage.f205,
						TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						1
					)
				else
					DisableFX(FX)
				end
			end)
			task.delay(1.4, function()
				if bind and bind.Parent then
					return
				end

				DisableFX(FX2)
			end)

			for _, beam in pairs(FX.JustBarrage.f205.Beams:GetDescendants()) do
				if bind and bind.Parent then
					if beam:IsA("Beam") then
						beam.TextureSpeed = 0.1
					end
				else
					DisableFX(FX)
					DisableFX(FX2)
					return
				end
			end

			newlibrarystar.effects.tweenBeams(FX.JustBarrage.f205.Beams, tweenInfo, {
				Brightness = 0.3,
				LightEmission = 1,
				TextureSpeed = 5,
				Width0 = 5,
				Width1 = 43
			})
			task.delay(2.3, function()
				if bind and bind.Parent then
					able({
						FX = FX,
						On = false
					})
					able({
						FX = FX2,
						On = false
					})
					local tweenInfo2 = TweenInfo.new(0.7, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
					newlibrarystar.effects.tweenBeams(FX.JustBarrage.f205.Beams, tweenInfo2, {
						Brightness = 0,
						LightEmission = 1,
						TextureSpeed = 1,
						Width0 = 5,
						Width1 = 19
					})
				else
					DisableFX(FX)
					DisableFX(FX2)
				end
			end)
		end)
		task.spawn(function()
			if not (bind and bind.Parent) then
				return
			end

			local lastTime = tick()
			local v5 = {}

			local function ClearCloneIndex()
				for k, _ in pairs(v5) do
					v5[k] = nil
					DisableFX(k)
					k:Destroy()
				end
			end

			local count = 0

			while tick() - lastTime < 2.5 do
				if not (bind and bind.Parent) then
					ClearCloneIndex()
					return
				end

				count += 1
				local v6 = tick() - lastTime > 0.6 and 3 or 4
				local v7 = tick() - lastTime > 1.7 and 2 or v6

				if count % v7 == 0 then
					if not (bind and bind.Parent) then
						ClearCloneIndex()
						return
					end

					local model = object._maid:give(vfx.Ring:Clone());
					(TrackFX(model)):ScaleTo(random:NextNumber(0.5, 1) / v7 * 3)
					local v9 = math.clamp(v7, 3, 1e999) / 25
					playMesh({
						Model = model,
						T = 0,
						Anchor = humanoidRootPart.CFrame * CFrame.new(
							random:NextNumber(-3, 3),
							random:NextNumber(-3, 3),
							random:NextNumber(-3, 3)
						) * CFrame.Angles(1.5707963267948966, 0, 0),
						Info = TweenInfo.new(v9, Enum.EasingStyle.Quad)
					})

					if bind and bind.Parent then
						local model2 = object._maid:give(vfx.RingLong:Clone());
						(TrackFX(model2)):ScaleTo(random:NextNumber(0.5, 1) / v7 * 3)
						local v11 = v9 * 0.5
						playMesh({
							Model = model2,
							Anchor = model:GetPivot() * CFrame.new(0, -2 / v7 * 3, 0),
							Info = TweenInfo.new(v11, Enum.EasingStyle.Quad)
						})

						if bind and bind.Parent then
							local model3 = object._maid:give(vfx.Ball:Clone());
							(TrackFX(model3)):ScaleTo(random:NextNumber(0.5, 1) / v7 * 3)
							local v13 = v11 * 0.7
							playMesh({
								Model = model3,
								T = 1,
								EndT = 1,
								Anchor = model:GetPivot() * CFrame.new(0, -2 / v7 * 3, 0),
								Info = TweenInfo.new(v13, Enum.EasingStyle.Quad)
							})

							if bind and bind.Parent then
								local model4 = object._maid:give(vfx.Test:Clone());
								(TrackFX(model4)):ScaleTo(random:NextNumber(0.3, 0.6) / v7 * 3)
								playMesh({
									Model = model4,
									EndT = 0.5,
									Anchor = model:GetPivot() * CFrame.new(0, -1 / v7 * 3, 0) * CFrame.Angles(
										0,
										0,
										1.5707963267948966
									) * CFrame.Angles(math.rad((random:NextNumber(-360, 360))), 0, 0),
									Info = TweenInfo.new(v13 * 0.5, Enum.EasingStyle.Sine)
								})

								if bind and bind.Parent then
									local model5 = object._maid:give(vfx.Test2:Clone());
									(TrackFX(model5)):ScaleTo(random:NextNumber(0.3, 0.6) / v7 * 3)
									playMesh({
										Model = model5,
										EndT = 0.5,
										Anchor = humanoidRootPart.CFrame * CFrame.new(
											random:NextNumber(-13, 13),
											random:NextNumber(-3, 3),
											random:NextNumber(-13, 13)
										) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, -1 / v7 * 3, 0) * CFrame.Angles(
											0,
											0,
											1.5707963267948966
										) * CFrame.Angles(math.rad((random:NextNumber(-360, 360))), 0, 0),
										Info = TweenInfo.new(v13 * 0.5, Enum.EasingStyle.Sine)
									})

									if bind and bind.Parent then
										local model6 = object._maid:give(vfx.Tuff:Clone());
										(TrackFX(model6)):ScaleTo(random:NextNumber(0.3, 0.6) / v7 * 3)
										playMesh({
											Model = model6,
											EndT = 0.5,
											Anchor = humanoidRootPart.CFrame * CFrame.new(
												random:NextNumber(-13, 13),
												random:NextNumber(-3, 3),
												random:NextNumber(-13, 13)
											) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 1 / v7 * 3, 0) * CFrame.Angles(
												0,
												0,
												1.5707963267948966
											) * CFrame.Angles(math.rad((random:NextNumber(-360, 360))), 0, 0),
											Info = TweenInfo.new(v13 * 0.5, Enum.EasingStyle.Sine)
										})

										if bind and bind.Parent then
											local model7 = object._maid:give(vfx.Wave:Clone());
											(TrackFX(model7)):ScaleTo(random:NextNumber(0.5, 1) / v7 * 3)
											local v18 = v13 * 3.2
											playMesh({
												Model = model7,
												Anchor = humanoidRootPart.CFrame * CFrame.new(
													random:NextNumber(-13, 13),
													random:NextNumber(-3, 3),
													random:NextNumber(-13, 13)
												) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
													0,
													0,
													1.5707963267948966
												) * CFrame.new(0, -2 / v7 * 3, 0) * CFrame.Angles(
													math.rad((random:NextNumber(0, 360))),
													0,
													0
												),
												Info = TweenInfo.new(v18 * 0.5, Enum.EasingStyle.Quad)
											})

											if bind and bind.Parent then
												local FX, model8

												if v4 == "Blue" then
													v4 = "Red"
													FX = quickFX({
														FX = vfx.BarrageEmits.BarrageEmit,
														Maid = object._maid,
														Anchor = model3:GetPivot()
													})
													table.insert(v, FX)
													model8 = object._maid:give(vfx.BarrageEmits.Blue:Clone());
													(TrackFX(model8)):ScaleTo(random:NextNumber(0.2, 0.3) / v7 * 3)
													local v21 = v18 * 0.2
													playMesh({
														Model = model8,
														EndT = 0.7,
														Anchor = model:GetPivot() * CFrame.Angles(0, 0, 0) * CFrame.new(
															5,
															15 / v7 * 3,
															0
														) * CFrame.Angles(0, 0, 0),
														Info = TweenInfo.new(v21, Enum.EasingStyle.Quad)
													})
												else
													FX = quickFX({
														FX = vfx.BarrageEmits.BarrageEmit2,
														Maid = object._maid,
														Anchor = model3:GetPivot()
													})
													table.insert(v, FX)
													model8 = object._maid:give(vfx.BarrageEmits.Red:Clone());
													(TrackFX(model8)):ScaleTo(random:NextNumber(0.2, 0.3) / v7 * 3)
													local v21 = v18 * 0.2
													playMesh({
														Model = model8,
														EndT = 0.7,
														Anchor = model:GetPivot() * CFrame.Angles(0, 0, 0) * CFrame.new(
															-5,
															15 / v7 * 3,
															0
														) * CFrame.Angles(0, 0, 0),
														Info = TweenInfo.new(v21, Enum.EasingStyle.Quad)
													})
													v4 = "Blue"
												end

												if bind and bind.Parent then
													if tick() - lastTime > 1.3 then
														if bind and bind.Parent then
															if FX.BarrageEmit:FindFirstChild("Speed") then
																lifeScale({
																	FX = FX.BarrageEmit.Speed,
																	Scale = 0.5
																})
																playAttachment(FX.BarrageEmit.Speed)
															end
														else
															DisableFX(FX)
															DisableFX(model8)
															ClearCloneIndex()
															return
														end
													end

													if bind and bind.Parent then
														FX:PivotTo(FX:GetPivot() * CFrame.new(
															0,
															random:NextNumber(-5, -1),
															0
														))
														FX:ScaleTo(random:NextNumber(0.2, 0.4) / v7 * 3)
														lifeScale({
															FX = FX,
															Scale = 1
														})
														playAttachment(FX.BarrageEmit.Attachment)

														if bind and bind.Parent then
															local v21 = object._maid:give(Instance.new("Highlight"))
															table.insert(v, v21)
															v21.Parent = victim
															v21.OutlineTransparency = 1
															v21.FillTransparency = 0
															v21.DepthMode = Enum.HighlightDepthMode.Occluded
															v21.FillColor = v3[v4]
															TweenService:Create(
																v21,
																TweenInfo.new(0.03, Enum.EasingStyle.Sine),
																{
																	FillTransparency = 1
																}
															):Play()
															game.Debris:AddItem(v21, 0.03)
														else
															DisableFX(FX)
															ClearCloneIndex()
															return
														end
													else
														DisableFX(FX)
														ClearCloneIndex()
														return
													end
												else
													DisableFX(FX)
													DisableFX(model8)
													ClearCloneIndex()
													return
												end
											else
												DisableFX(model7)
												ClearCloneIndex()
												return
											end
										else
											DisableFX(model6)
											ClearCloneIndex()
											return
										end
									else
										DisableFX(model5)
										ClearCloneIndex()
										return
									end
								else
									DisableFX(model4)
									ClearCloneIndex()
									return
								end
							else
								DisableFX(model3)
								ClearCloneIndex()
								return
							end
						else
							DisableFX(model2)
							ClearCloneIndex()
							return
						end
					else
						DisableFX(model)
						ClearCloneIndex()
						return
					end
				end

				for k, v8 in pairs(v5) do
					if bind and bind.Parent then
						if tick() - v8.Tick > 0.03 then
							v5[k] = nil
							k:Destroy()
						end
					else
						ClearCloneIndex()
						return
					end
				end

				dtwait(0.01)

				if bind and bind.Parent then
					continue
				end

				ClearCloneIndex()
				return
			end

			if not (bind and bind.Parent) then
				ClearCloneIndex()
				return
			end

			local FX2 = quickFX({
				FX = vfx.BarrageFinish,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.4, -5)
			});
			(TrackFX(FX2)):ScaleTo(0.5)
			lifeScale({
				FX = FX2,
				Scale = 2
			})
			able({
				FX = FX2,
				On = false
			})
			playAttachment(FX2)

			if bind and bind.Parent then
				local model = object._maid:give(vfx.Fist:Clone());
				(TrackFX(model)):ScaleTo(1.7)
				playMesh({
					Model = model,
					T = 0.7,
					EndT = 1,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, 35) * CFrame.Angles(0, 0, 0),
					Info = TweenInfo.new(0.65, Enum.EasingStyle.Quad)
				})

				if bind and bind.Parent then
					local FX = quickFX({
						FX = vfx.BarrageEmits.BarrageEmit,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						)
					});
					(TrackFX(FX)):ScaleTo(1.3)
					lifeScale({
						FX = FX,
						Scale = 2
					})
					playAttachment(FX.BarrageEmit.Speed)

					for k, _ in pairs(v5) do
						v5[k] = nil
						k:Destroy()
					end
				else
					DisableFX(model)
					ClearCloneIndex()
				end
			else
				DisableFX(FX2)
				ClearCloneIndex()
			end
		end)
	end

	task.spawn(BarrageEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function FinishSend.UppercutEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = {}
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local bind = data.bind

	local function Cancelled()
		return not (bind and bind.Parent)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function TrackFX(p2)
		table.insert(v, p2)
		return p2
	end

	local function DisableFX(effect)
		if not effect then
			return
		end

		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = false
		end

		for _, effect2 in pairs(effect:GetDescendants()) do
			if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
				continue
			end

			effect2.Enabled = false
		end
	end

	if bind then
		bind.Destroying:Once(function()
			for _, v3 in pairs(v) do
				DisableFX(v3)
			end

			task.delay(1, Clean)
		end)
	end

	local function UppercutEvent()
		if not (bind and bind.Parent) then
			return
		end

		playAttachment(TrackFX(quickFX({
			FX = vfx.Uppercut,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(-0.7853981633974483, 0, 0)
		})))

		if not (bind and bind.Parent) then
			return
		end

		playAttachment(TrackFX(quickFX({
			FX = vfx.My7th,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0.7853981633974483, 0, 0)
		})))

		if not (bind and bind.Parent) then
			return
		end

		playAttachment(TrackFX(quickFX({
			FX = vfx.Dust,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(0, 0, 0)
		})))
		task.spawn(function()
			local v6 = {}

			for _, child in pairs(vfx.RunTrail:GetChildren()) do
				if bind and bind.Parent then
					local v7 = object._maid:give(child:Clone())
					table.insert(v, v7)
					local weld = Instance.new("Weld")
					weld.Part0 = v7
					weld.Part1 = char:FindFirstChild(child.Name)
					weld.Parent = v7
					v7.Parent = EFP
					table.insert(v6, v7)
				else
					for _, v7 in pairs(v6) do
						DisableFX(v7)
					end

					return
				end
			end

			dtwait(3)

			if bind and bind.Parent then
				for _, v7 in pairs(v6) do
					v7:Destroy()
				end
			else
				for _, v7 in pairs(v6) do
					DisableFX(v7)
				end
			end
		end)
	end

	task.spawn(UppercutEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function FinishSend.BackEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = {}
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local bind = data.bind

	local function Cancelled()
		return not (bind and bind.Parent)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function TrackFX(p2)
		table.insert(v, p2)
		return p2
	end

	local function DisableFX(effect)
		if not effect then
			return
		end

		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = false
		end

		for _, effect2 in pairs(effect:GetDescendants()) do
			if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
				continue
			end

			effect2.Enabled = false
		end
	end

	if bind then
		bind.Destroying:Once(function()
			for _, v3 in pairs(v) do
				DisableFX(v3)
			end

			task.delay(1, Clean)
		end)
	end

	local function BackEvent()
		if not (bind and bind.Parent) then
			return
		end

		playAttachment(TrackFX(quickFX({
			FX = vfx.BackDust,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(0, 0, 0)
		})))

		if not (bind and bind.Parent) then
			return
		end

		local FX = quickFX({
			FX = vfx.BackDash,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		});
		(TrackFX(FX)):ScaleTo(1.5)
		lifeScale({
			FX = FX,
			Scale = 1.5
		})
		playAttachment(FX)

		if not (bind and bind.Parent) then
			return
		end

		local model = object._maid:give(vfx.ThisWave:Clone());
		(TrackFX(model)):ScaleTo(0.5)
		playMesh({
			Model = model,
			Anchor = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0),
			Info = TweenInfo.new(0.85, Enum.EasingStyle.Quad)
		})

		if not (bind and bind.Parent) then
			DisableFX(model)
			return
		end

		local _ = vfx.TrailThing
		local v6 = {}

		for _, _ in pairs({ char["Left Arm"], char["Right Arm"] }) do
			if bind and bind.Parent then
				continue
			end

			for _, v7 in pairs(v6) do
				v7.Enabled = false
			end

			return
		end

		task.delay(0.5, function()
			if bind and bind.Parent then
				local folder = quickFX({
					FX = vfx.Land2,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 1)
				});
				(TrackFX(folder)):ScaleTo(2)
				playAttachment(folder)

				for _, beam in pairs(folder:GetDescendants()) do
					if bind and bind.Parent then
						if beam:IsA("Beam") then
							TweenService:Create(beam, TweenInfo.new(1, Enum.EasingStyle.Sine), {
								TextureSpeed = 0.1,
								Brightness = 0
							}):Play()
						end
					else
						DisableFX(folder)
						return
					end
				end
			else
				for _, v7 in pairs(v6) do
					v7.Enabled = false
				end
			end
		end)
	end

	task.spawn(BackEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return FinishSend