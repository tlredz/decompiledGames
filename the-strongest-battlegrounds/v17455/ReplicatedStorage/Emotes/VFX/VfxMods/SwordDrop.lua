local createVector = vector.create
local SwordDrop = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local playMesh = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local raiseZIndex = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local vfx = script.vfx
local MechCache = require(game.ReplicatedStorage.Resources.MechCache)
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local _ = game.Workspace.Camera
require(game.ReplicatedStorage.Resources.LightningModule)
require(game.ReplicatedStorage.Resources.MoonEmitter)
require(game.ReplicatedStorage.Resources.Libraryyyy2.Crater)

-- equivalent calls inferred from this helper; original call sites unknown
local function PlaceVFX(instance, p)
	instance:PivotTo(p * instance:GetAttribute("Offset"):Inverse())
end

local v = {}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function buildKey(data)
	return string.format(
		"%s|%s|%s|%s",
		tostring(data.lifeScale or 1),
		tostring(data.rateMult or 1),
		tostring(data.speedMult or 1),
		(tostring(data.dragMult or 1))
	)
end

local function bakeTemplate(instance, data)
	local clone = instance:Clone()

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if data.lifeScale and data.lifeScale ~= 1 then
			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * data.lifeScale, lifetime.Max * data.lifeScale)
		end

		if data.rateMult and data.rateMult ~= 1 then
			emitter.Rate *= data.rateMult
		end

		if data.speedMult and data.speedMult ~= 1 then
			local speed = emitter.Speed
			emitter.Speed = NumberRange.new(speed.Min * data.speedMult, speed.Max * data.speedMult)
		end

		if data.dragMult and data.dragMult ~= 1 then
			emitter.Drag *= data.dragMult
		end
	end

	return clone
end

function v.GetTemplate(p, options)
	local v3 = options or {}
	local v4 = v2[p]

	if not v4 then
		v4 = {}
		v2[p] = v4
	end

	local key = buildKey(v3) -- equivalent call inferred; original call site unknown
	local v5 = v4[key]

	if not v5 then
		v5 = bakeTemplate(p, v3)
		v4[key] = v5
	end

	return v5
end

function v:Clone(p2)
	return v.GetTemplate(self, p2):Clone()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SpringVector3(freq: number)
	return {
		freq = freq,
		pos = createVector(0, 0, 0),
		vel = createVector(0, 0, 0),
		Step = function(self, vector2: Vector3, p2: number)
			local v3 = self.freq * 2 * 3.141592653589793
			local pos = self.pos
			local vel = self.vel
			local v4 = pos - vector2
			local v5 = math.exp(-v3 * p2)
			local pos2 = (v4 * (1 + v3 * p2) + vel * p2) * v5 + vector2
			local vel2 = (vel - v4 * (v3 * v3) * p2) * v5
			self.pos = pos2
			self.vel = vel2
			return pos2
		end
	}
end

local function SpringCFrame(freq: number, freq2: number)
	local v3 = {
		posSpring = SpringVector3(freq),
		rotSpring = SpringVector3(freq2),
		rotVec = createVector(0, 0, 0),
		rotVel = createVector(0, 0, 0)
	}

	local function cframeToRotVec(cframe: CFrame)
		local axisAngle, v4 = cframe:ToAxisAngle()

		if v4 == v4 then
			return axisAngle * v4
		end

		return createVector(0, 0, 0)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rotVecToCFrame(vector2: Vector3)
		local magnitude = vector2.Magnitude

		if magnitude < 1e-6 then
			return CFrame.new()
		end

		return CFrame.fromAxisAngle(vector2 / magnitude, magnitude)
	end

	function v3:Step(cframe: CFrame?, cframe2: CFrame, p3: number)
		if cframe then
			local v4 = self.posSpring:Step(cframe2.Position, p3)
			local axisAngle, v5 = cframe:ToObjectSpace(cframe2):ToAxisAngle()
			local v6 = v5 ~= v5 and createVector(0, 0, 0) or axisAngle * v5
			local v7 = freq2 * 2 * 3.141592653589793
			local v8 = self.rotVec - v6
			local v9 = math.exp(-v7 * p3)
			local rotVec = (v8 * (1 + v7 * p3) + self.rotVel * p3) * v9 + v6
			local rotVel = (self.rotVel - v8 * (v7 * v7) * p3) * v9
			self.rotVec = rotVec
			self.rotVel = rotVel
			local v12 = rotVecToCFrame(rotVec) -- equivalent call inferred; original call site unknown
			local v13 = cframe.Rotation * v12
			return CFrame.new(v4) * v13
		else
			self.posSpring.pos = cframe2.Position
			self.posSpring.vel = createVector(0, 0, 0)
			self.rotVec = createVector(0, 0, 0)
			self.rotVel = createVector(0, 0, 0)
			return cframe2
		end
	end

	return v3
end

local flag = nil

function SwordDrop.FallEvent(p)
	local data = p.Data
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v3 then
			v3 = true
			object._maid:doCleaning()
		end
	end

	task.delay(5, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local char = data.Char
	local primaryPart = char.PrimaryPart

	local function FirstWind()
		local v4 = {}
		task.spawn(function()
			local wind = script.Wind

			local function Wind()
				local folder = object._maid:give(wind:Clone())
				folder.Parent = EFP
				folder:ScaleTo(0.3)
				local strength = object._maid:give(Instance.new("NumberValue"))
				strength.Value = 1
				local v6 = object._maid:give(Instance.new("NumberValue"))
				v6.Value = folder:GetScale()
				object._maid:giveTask(v6.Changed:Connect(function()
					folder:ScaleTo(v6.Value)
				end))
				TweenService:Create(v6, TweenInfo.new(2.8, Enum.EasingStyle.Sine), {
					Value = 3
				}):Play()
				local beams = {}

				for _, beam in ipairs(folder:GetDescendants()) do
					if beam:IsA("Beam") then
						beams[#beams + 1] = beam
					end
				end

				for _, v7 in ipairs(beams) do
					local transparency = v7.Transparency
					v7.Transparency = NumberSequence.new(1)
					playTween(v7, {
						Time = 0.7,
						EasingStyle = "Sine",
						Goal = {
							Transparency = transparency
						}
					})
				end

				task.delay(0.7, function()
					for _, v7 in ipairs(beams) do
						playTween(v7, {
							Time = 0.7,
							EasingStyle = "Sine",
							Goal = {
								Transparency = NumberSequence.new(1)
							}
						})
						game.Debris:AddItem(v7, 0.7)
					end

					task.wait(1)
					v4[folder] = nil
				end)
				local number = random:NextNumber(0, 360)
				folder:PivotTo(
					primaryPart.CFrame * CFrame.Angles(0, math.rad(number), 0) * CFrame.new(0, -20, 0) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					),
					strength.Value
				)
				v4[folder] = {
					Angle = number,
					Strength = strength,
					Beams = beams
				}
			end

			for _ = 1, 5 do
				Wind()
				task.wait(0.2)
			end
		end)
		local v5 = object._maid:give(Instance.new("NumberValue"))
		v5.Value = 0.1
		TweenService:Create(v5, TweenInfo.new(2, Enum.EasingStyle.Sine), {
			Value = 2
		}):Play()
		object._maid:giveTask(v5.Changed:Connect(function()
			for _, v6 in pairs(v4) do
				if not v6.Beams then
					continue
				end

				for _, beam in ipairs(v6.Beams) do
					local ogs = beam:GetAttribute("ogs")

					if not ogs then
						ogs = beam.TextureSpeed
						beam:SetAttribute("ogs", ogs)
					end

					beam.TextureSpeed = ogs * v5.Value
				end
			end
		end))
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 4 do
				for k, v6 in pairs(v4) do
					if not k.Parent then
						continue
					end

					local angle = v6.Angle
					local strength = v6.Strength
					k:PivotTo(k:GetPivot():Lerp(
						primaryPart.CFrame * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, -20, 0) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						),
						strength.Value
					))
				end

				RunService.RenderStepped:Wait()
			end
		end)
	end

	local function SecondWind()
		task.spawn(function()
			local wind2 = script.Wind2

			local function Wind()
				local folder = object._maid:give(wind2:Clone())
				folder.Parent = EFP
				folder:ScaleTo(0.3)
				local v4 = object._maid:give(Instance.new("NumberValue"))
				v4.Value = 1
				TweenService:Create(v4, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Value = 0
				}):Play()
				local v5 = object._maid:give(Instance.new("NumberValue"))
				v5.Value = folder:GetScale()
				object._maid:giveTask(v5.Changed:Connect(function()
					folder:ScaleTo(v5.Value)
				end))
				TweenService:Create(v5, TweenInfo.new(4, Enum.EasingStyle.Sine), {
					Value = 3
				}):Play()
				local beams = {}
				local beams2 = {}

				for _, beam in ipairs(folder:GetDescendants()) do
					if beam:IsA("Beam") then
						beams[#beams + 1] = beam
					elseif beam:isA("Attachment") and beam.Name == "2" then
						beams2[#beams2 + 1] = beam
					end
				end

				for _, v6 in ipairs(beams) do
					local transparency = v6.Transparency
					v6.Transparency = NumberSequence.new(1)
					playTween(v6, {
						Time = 0.2,
						EasingStyle = "Sine",
						Goal = {
							Transparency = transparency
						}
					})
					v6.TextureSpeed *= 2
					TweenService:Create(v6, TweenInfo.new(2, Enum.EasingStyle.Sine), {
						TextureSpeed = 0.1
					}):Play()
				end

				task.delay(0.2, function()
					for _, v6 in ipairs(beams) do
						playTween(v6, {
							Time = 0.2,
							EasingStyle = "Sine",
							Goal = {
								Transparency = NumberSequence.new(1)
							}
						})
						game.Debris:AddItem(v6, 0.2)
					end
				end)
				local number = random:NextNumber(0, 360)
				folder:PivotTo(
					primaryPart.CFrame * CFrame.Angles(0, math.rad(number), 0) * CFrame.new(0, -20, 0) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					),
					v4.Value
				)
				local parent = object._maid:give(Instance.new("Part"))
				parent.Anchored = true
				parent.CanCollide = false
				parent.Transparency = 1
				parent.CFrame = folder:GetPivot()
				parent.Parent = folder

				for _, v7 in ipairs(beams2) do
					local worldCFrame = v7.WorldCFrame
					v7.Parent = parent
					v7.WorldCFrame = worldCFrame
				end

				local cFrame = parent.CFrame
				local v7 = object._maid:give(Instance.new("NumberValue"))
				v7.Value = 1
				task.spawn(function()
					local lastTime = tick()

					while tick() - lastTime < 0.6000000000000001 do
						local total = 0
						folder:PivotTo(folder:GetPivot():Lerp(
							primaryPart.CFrame * CFrame.Angles(0, math.rad(number), 0) * CFrame.new(
								0,
								-40 * v5.Value,
								0
							) * CFrame.Angles(1.5707963267948966, 0, 0),
							v4.Value
						))
						parent.CFrame = cFrame * CFrame.new(0, -total, 0)
						total += v7.Value
						dtwait(0.01)
					end
				end)
			end

			for _ = 1, 15 do
				Wind()
				task.wait(0.1)
			end
		end)
	end

	task.wait(0.3)
	FirstWind()
	task.spawn(function()
		local wind2 = script.Wind2

		local function Wind()
			local folder = object._maid:give(wind2:Clone())
			folder.Parent = EFP
			folder:ScaleTo(0.3)
			local v4 = object._maid:give(Instance.new("NumberValue"))
			v4.Value = 1
			TweenService:Create(v4, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Value = 0
			}):Play()
			local v5 = object._maid:give(Instance.new("NumberValue"))
			v5.Value = folder:GetScale()
			object._maid:giveTask(v5.Changed:Connect(function()
				folder:ScaleTo(v5.Value)
			end))
			TweenService:Create(v5, TweenInfo.new(4, Enum.EasingStyle.Sine), {
				Value = 3
			}):Play()
			local beams = {}
			local beams2 = {}

			for _, beam in ipairs(folder:GetDescendants()) do
				if beam:IsA("Beam") then
					beams[#beams + 1] = beam
				elseif beam:isA("Attachment") and beam.Name == "2" then
					beams2[#beams2 + 1] = beam
				end
			end

			for _, v6 in ipairs(beams) do
				local transparency = v6.Transparency
				v6.Transparency = NumberSequence.new(1)
				playTween(v6, {
					Time = 0.2,
					EasingStyle = "Sine",
					Goal = {
						Transparency = transparency
					}
				})
				v6.TextureSpeed *= 2
				TweenService:Create(v6, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					TextureSpeed = 0.1
				}):Play()
			end

			task.delay(0.2, function()
				for _, v6 in ipairs(beams) do
					playTween(v6, {
						Time = 0.2,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new(1)
						}
					})
					game.Debris:AddItem(v6, 0.2)
				end
			end)
			local number = random:NextNumber(0, 360)
			folder:PivotTo(
				primaryPart.CFrame * CFrame.Angles(0, math.rad(number), 0) * CFrame.new(0, -20, 0) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				),
				v4.Value
			)
			local parent = object._maid:give(Instance.new("Part"))
			parent.Anchored = true
			parent.CanCollide = false
			parent.Transparency = 1
			parent.CFrame = folder:GetPivot()
			parent.Parent = folder

			for _, v7 in ipairs(beams2) do
				local worldCFrame = v7.WorldCFrame
				v7.Parent = parent
				v7.WorldCFrame = worldCFrame
			end

			local cFrame = parent.CFrame
			local v7 = object._maid:give(Instance.new("NumberValue"))
			v7.Value = 1
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 0.6000000000000001 do
					local total = 0
					folder:PivotTo(folder:GetPivot():Lerp(
						primaryPart.CFrame * CFrame.Angles(0, math.rad(number), 0) * CFrame.new(0, -40 * v5.Value, 0) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						),
						v4.Value
					))
					parent.CFrame = cFrame * CFrame.new(0, -total, 0)
					total += v7.Value
					dtwait(0.01)
				end
			end)
		end

		for _ = 1, 15 do
			Wind()
			task.wait(0.1)
		end
	end)

	local function Trails()
		local _ = char.Mech
		local v4 = MechCache.Get(char)
		local children = {}

		for _, child in ipairs(script.vfx.Trails:GetChildren()) do
			local parent = v4[child.Name]

			if not parent then
				continue
			end

			local v6 = object._maid:give(child:Clone())
			game.Debris:AddItem(v6, 8)

			for _, child2 in ipairs(v6:GetChildren()) do
				child2.Parent = parent
				local v7 = child2
				task.delay(8, function()
					if v7 and v7.Parent then
						v7:Destroy()
					end
				end)
				children[#children + 1] = child2
			end
		end

		task.delay(2, function()
			for _, trail in ipairs(children) do
				if not trail:IsA("Trail") then
					continue
				end

				playTween(trail, {
					Time = 1,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new(1)
					}
				})
				game.Debris:AddItem(trail, 1)
			end
		end)
	end

	Trails()

	local function Center()
		local FX = object._maid:give(script.vfx.Center:Clone())
		FX.Parent = EFP
		able({
			FX = FX,
			On = false
		})
		local v5 = object._maid:give(Instance.new("NumberValue"))
		object._maid:giveTask(v5.Changed:Connect(function()
			FX:ScaleTo(v5.Value)
		end))
		v5.Value = 0.5
		task.delay(0.2, function()
			able({
				FX = FX,
				On = true
			})
		end)
		TweenService:Create(v5, TweenInfo.new(4, Enum.EasingStyle.Sine), {
			Value = 3
		}):Play()
		local v6 = object._maid:give(vfx.SmallWind:Clone())
		v6.Transparency = 1
		local v7 = object._maid:give(vfx.Fortnite:Clone())
		v7.Transparency = 1
		TweenService:Create(v7, TweenInfo.new(2.5, Enum.EasingStyle.Sine), {
			Color = Color3.new(0, 0.615686, 1)
		}):Play()
		local v8 = object._maid:give(vfx.NewNight:Clone())
		v8.Transparency = 1
		TweenService:Create(v8, TweenInfo.new(2.5, Enum.EasingStyle.Sine), {
			Color = Color3.new(0, 0.615686, 1)
		}):Play()
		local give = object._maid:give(script.vfx.Disperse:Clone())
		give.Parent = EFP
		task.delay(0.4, function()
			TweenService:Create(v6, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
				Transparency = 0.85
			}):Play()
			TweenService:Create(v7, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Transparency = 0
			}):Play()
			task.wait(0.13)
			TweenService:Create(v8, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Transparency = 0
			}):Play()
		end)
		task.delay(1.6, function()
			able({
				FX = FX,
				On = false
			})
			v6:Destroy()
			v7:Destroy()
			v8:Destroy()
		end)
		v6.Parent = EFP
		v7.Parent = EFP
		local size = v6.Size
		local size2 = v7.Size
		local v9 = v8.Size * 1.2
		local v10 = object._maid:give(Instance.new("NumberValue"))
		v10.Value = 0.1
		TweenService:Create(v10, TweenInfo.new(2, Enum.EasingStyle.Sine), {
			Value = 1
		}):Play()
		local v11 = object._maid:give(Instance.new("NumberValue"))
		v11.Value = 0.5
		TweenService:Create(v11, TweenInfo.new(2, Enum.EasingStyle.Sine), {
			Value = 2
		}):Play()
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 2.2 do
				FX:PivotTo(primaryPart.CFrame * CFrame.new(0, -10, 0))

				if v6 and v6.Parent then
					v6:PivotTo(primaryPart.CFrame * CFrame.new(0, -10, 0) * CFrame.Angles(
						0,
						math.rad((random:NextNumber(0, 360))),
						0
					))
					v6.Size = size * random:NextNumber(0.8, 2) * 1.5
				end

				if v7 and v7.Parent then
					v7:PivotTo(primaryPart.CFrame * CFrame.new(0, -4, 0) * CFrame.Angles(
						0,
						math.rad((random:NextNumber(0, 360))),
						0
					) * CFrame.Angles(0, 0, 1.5707963267948966))
					v7.Size = size2 * random:NextNumber(0.8, 2) * v10.Value
				end

				if v8 and v8.Parent then
					v8:PivotTo(primaryPart.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(
						0,
						math.rad((random:NextNumber(0, 360))),
						0
					) * CFrame.Angles(1.5707963267948966, 0, 0))
					v8.Size = v9 * random:NextNumber(0.8, 2) * v11.Value
				end

				RunService.RenderStepped:Wait()
			end
		end)
		task.wait(0.3)
		task.spawn(function()
			tick()
			local v12 = object._maid:give(Instance.new("IntValue"))
			v12.Value = 10
			TweenService:Create(v12, TweenInfo.new(2, Enum.EasingStyle.Quad), {
				Value = 1
			}):Play()
			local v13 = object._maid:give(Instance.new("NumberValue"))
			v13.Value = 5
			TweenService:Create(v13, TweenInfo.new(2, Enum.EasingStyle.Quad), {
				Value = 30
			}):Play()
			local v14 = object._maid:give(Instance.new("NumberValue"))
			v14.Value = 115
			local parent = object._maid:give(Instance.new("Model"))
			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(153, 245, 255)
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = -10
			highlight.Parent = parent
			parent.Name = "Lightnings"
			parent.Parent = game.Workspace.Thrown
			local v16 = object._maid:give(Instance.new("PointLight"))
			v16.Brightness = 10
			v16.Range = 0
			v16.Color = Color3.new(0.333333, 0.635294, 1)
			v16.Shadows = false
			TweenService:Create(v16, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Range = 20
			}):Play()
			v16.Parent = primaryPart
			task.delay(1.3, function()
				v16:Destroy()
			end)
			task.delay(1.5, function()
				v14.Value = 100
				TweenService:Create(v14, TweenInfo.new(1, Enum.EasingStyle.Quad), {
					Value = 260
				}):Play()
				dtwait(0.4)
				TweenService:Create(v12, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Value = 30
				}):Play()
			end)
			local FX2 = object._maid:give(script.vfx.Disperse:Clone())
			FX2.Parent = EFP
			able({
				FX = FX2,
				On = false
			})
			task.delay(0.1, function()
				able({
					FX = FX2,
					On = true
				})
				task.wait(0.6)
				able({
					FX = FX2,
					On = false
				})
			end)
			local _ = script.vfx.mybrainissocookedatthispoint
		end)

		for i = 1, 8 do
			local clone = vfx.Ring:Clone()
			clone:ScaleTo(clone:GetScale() + i / 10)
			playMesh({
				Model = clone,
				T = 0.8,
				Anchor = primaryPart.CFrame * CFrame.new(0, -30, 0) * CFrame.Angles(0, 0, 0),
				Info = TweenInfo.new(1 / i, Enum.EasingStyle.Sine)
			})

			if i > 2 then
				local clone2 = vfx.Wind:Clone()
				clone2:ScaleTo(clone2:GetScale() + i / 10)
				playMesh({
					Model = clone2,
					T = 0.8,
					Anchor = primaryPart.CFrame * CFrame.new(0, -60, 0) * CFrame.Angles(3.141592653589793, 0, 0),
					Info = TweenInfo.new(1 / i, Enum.EasingStyle.Sine)
				})
			end

			task.wait(0.15)
		end
	end

	Center()
end

function SwordDrop.FirstEvent(p)
	local char = p.Data.Char
	local primaryPart = char.PrimaryPart
	local mech = char.Mech
	local primaryPart2 = mech.PrimaryPart
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v3 then
			v3 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local mrcoolfx = script.mrcoolfx
		task.wait(0.3)
		local v4 = {}
		local FX = object._maid:give(mrcoolfx.Booster3:Clone())
		raiseZIndex({
			FX = FX,
			Count = 10
		})
		local FX2 = object._maid:give(mrcoolfx.Booster:Clone())
		local FX3 = object._maid:give(mrcoolfx.Booster:Clone())
		v4[#v4 + 1] = FX2
		v4[#v4 + 1] = FX
		local waist = MechCache.Get(primaryPart2).Waist
		local v8 = {}

		local function getEmitters(folder)
			local v9 = v8[folder]

			if v9 then
				return v9
			end

			local emitters = {}

			for _, emitter in ipairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitters[#emitters + 1] = emitter
				end
			end

			v8[folder] = emitters
			return emitters
		end

		local v9 = {}
		local v10 = object._maid:give(Instance.new("NumberValue"))
		local v11 = object._maid:give(Instance.new("NumberValue"))
		object._maid:giveTask(v11.Changed:Connect(function()
			for _, v12 in ipairs(v4) do
				if v12.Name == "Wind" then
					v12:ScaleTo(v11.Value * 0.7)
				else
					v12:ScaleTo(v11.Value)
				end
			end
		end))
		object._maid:giveTask(v10.Changed:Connect(function()
			local value = v10.Value

			for _, v12 in ipairs(v4) do
				local emitters = getEmitters(v12)

				for _, emitter in ipairs(emitters) do
					local v13 = v9[emitter]

					if not v13 then
						v13 = {
							Speed = emitter.Speed,
							Lifetime = emitter.Lifetime,
							Rate = emitter.Rate
						}
						v9[emitter] = v13
					end

					local speed = v13.Speed
					local lifetime = v13.Lifetime
					emitter.Speed = NumberRange.new(speed.Min * value, speed.Max * value)
					emitter.Lifetime = NumberRange.new(lifetime.Min / value, lifetime.Max / value)
					emitter.Rate = v13.Rate * value
				end
			end
		end))
		v10.Value = 1.5
		v11.Value = 0.75
		TweenService:Create(v11, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			Value = 1.2000000000000002
		}):Play()
		local v12 = object._maid:give(Instance.new("PointLight"))
		v12.Brightness = 1
		v12.Color = Color3.new(1, 0.501961, 0)
		v12.Shadows = false
		TweenService:Create(v12, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			Range = 20
		}):Play()
		v12.Parent = waist
		game.Debris:AddItem(v12, 3)
		local freeze = game.Players.LocalPlayer.Character:FindFirstChild("Freeze")
		local v13 = freeze and freeze:GetAttribute("photondive") and true or nil
		task.delay(0.1, function()
			if v13 then
				shared.repfire({
					Effect = "Camshake",
					Intensity = 4,
					Last = 2
				})
			end
		end)
		task.delay(0.35, function()
			if v13 then
				shared.repfire({
					Effect = "Camshake",
					Intensity = 8,
					Last = 2
				})
			end

			TweenService:Create(v12, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
				Range = 50,
				Brightness = 5
			}):Play()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
			local raycastResult = game.Workspace:Raycast(
				primaryPart2.Position,
				createVector(0, -1000, 0),
				raycastParams
			)

			if not raycastResult then
				return
			end

			local _, v14, _ = primaryPart2.CFrame:ToOrientation()
			local FX4 = quickFX({
				FX = mrcoolfx.Burn,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position) * CFrame.new(0, 7.5, 0) * CFrame.Angles(0, v14, 0)
			})
			FX4:ScaleTo(FX4:GetScale() * 1.5)
			lifeScale({
				FX = FX4,
				Scale = 1
			})
			playAttachment(FX4)
			local folder = quickFX({
				FX = mrcoolfx.Smoke,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position) * CFrame.new(0, 0.75, 10) * CFrame.Angles(
					0,
					1.5707963267948966 + v14,
					0
				)
			})
			folder:ScaleTo(folder:GetScale() * 1.5)
			lifeScale({
				FX = folder,
				Scale = 1
			})
			local v16 = object._maid:give(Instance.new("NumberValue"))
			object._maid:giveTask(v16.Changed:Connect(function()
				folder:ScaleTo(v16.Value)
			end))
			v16.Value = 1.5
			TweenService:Create(v16, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Value = 3
			}):Play()
			task.delay(0.4, function()
				local emitters = {}

				for _, emitter in ipairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Name ~= "smog2" then
						emitters[#emitters + 1] = emitter
					end
				end

				for _, v17 in ipairs(emitters) do
					TweenService:Create(v17, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						TimeScale = 0.05
					}):Play()
				end
			end)
			task.delay(0.6, function()
				able({
					FX = folder,
					On = false
				})
				playAttachment(folder)
				task.wait(0.3)
				TweenService:Create(v16, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Value = 6
				}):Play()
			end)
			task.wait(0.05)
			TweenService:Create(v12, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Range = 33
			}):Play()
			TweenService:Create(v12, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Brightness = 1
			}):Play()
			task.wait(1)
			TweenService:Create(v12, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Brightness = 0
			}):Play()
		end)
		task.delay(0.4, function()
			TweenService:Create(v11, TweenInfo.new(0.05, Enum.EasingStyle.Bounce), {
				Value = 4.5
			}):Play()
			task.wait(0.1)
			TweenService:Create(v11, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
				Value = 1.5
			}):Play()
			TweenService:Create(v10, TweenInfo.new(2, Enum.EasingStyle.Sine), {
				Value = 2.25
			}):Play()
		end)
		able({
			FX = FX2,
			On = false
		})
		able({
			FX = FX3,
			On = false
		})
		local v14 = object._maid:give(Instance.new("NumberValue"))
		v14.Value = 1
		local FX5 = nil
		local folder = nil
		local v16 = object._maid:give(Instance.new("NumberValue"))
		v16.Value = 0.4
		task.delay(1, function()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
			local raycastResult = game.Workspace:Raycast(primaryPart2.Position, createVector(0, -100, 0), raycastParams)
			local FX4 = quickFX({
				FX = mrcoolfx.Round,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position)
			})
			FX4:ScaleTo(4.5)
			able({
				FX = FX4,
				On = false
			})
			able({
				FX = FX2,
				On = true
			})
			task.delay(0.2, function()
				able({
					FX = FX,
					On = false
				})
				local FX6 = quickFX({
					FX = mrcoolfx.Jump,
					Maid = object._maid,
					Anchor = CFrame.new(raycastResult.Position) * CFrame.new(0, 10, 0) * CFrame.Angles(0, 0, 0)
				})
				lifeScale({
					FX = FX6,
					Scale = 4
				})
				FX6:ScaleTo(FX6:GetScale() * 1.5)
				playAttachment(FX6)
				able({
					FX = FX4,
					On = true
				})
				FX5 = object._maid:give(script.vfx.ok:Clone())
				FX5:ScaleTo(1.3)
				FX5.Parent = EFP
				folder = object._maid:give(script.vfx.Temporary:Clone())
				folder.Parent = EFP
				TweenService:Create(v16, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					Value = 2
				}):Play()
				task.delay(0.4, function()
					for _, decal in ipairs(folder:GetDescendants()) do
						if not decal:IsA("Decal") then
							continue
						end

						if decal.Name == "RED1" then
							TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						else
							TweenService:Create(decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
					end
				end)
				local give = object._maid:give(script.vfx.umokiguess:Clone())
				give.Parent = EFP

				local function Clouds()
					local v19 = { "Color", "Density", "Cover" }
					local clouds = game.Workspace.Terrain.Clouds
					local v20 = {}

					for _, v21 in ipairs(v19) do
						v20[v21] = clouds[v21]
					end

					local v21 = {}

					for _, v22 in ipairs(v19) do
						v21[v22] = script.Clouds[v22]
					end

					TweenService:Create(clouds, TweenInfo.new(3, Enum.EasingStyle.Sine), v21):Play()
					task.delay(4, function()
						TweenService:Create(clouds, TweenInfo.new(8, Enum.EasingStyle.Sine), v20):Play()
					end)
				end

				local function Trails()
					local v19 = MechCache.Get(mech)
					local children = {}

					for _, child in ipairs(script.vfx.Trails:GetChildren()) do
						local parent = v19[child.Name]

						if not parent then
							continue
						end

						local v21 = object._maid:give(child:Clone())
						task.delay(10, function()
							if v21 and v21.Parent then
								v21:Destroy()
							end
						end)

						for _, child2 in ipairs(v21:GetChildren()) do
							child2.Parent = parent
							local v23 = child2
							task.delay(10, function()
								if v23 and v23.Parent then
									v23:Destroy()
								end
							end)
							children[#children + 1] = child2
						end
					end

					task.delay(2, function()
						for _, trail in ipairs(children) do
							if not trail:IsA("Trail") then
								continue
							end

							playTween(trail, {
								Time = 1,
								EasingStyle = "Sine",
								Goal = {
									Transparency = NumberSequence.new(1)
								}
							})
							game.Debris:AddItem(trail, 1)
						end
					end)
				end

				Trails()

				local function Boostersss()
					local v19 = object._maid:give(mrcoolfx.boosters:Clone())
					v19.Parent = EFP
					local v20 = MechCache.Get(mech)
					local v21 = {
						["Foot.L"] = v20["Foot.L"],
						["Foot.R"] = v20["Foot.R"]
					}

					for _, child in ipairs(mrcoolfx.ats:GetChildren()) do
						local v22 = object._maid:give(child:Clone())
						task.delay(10, function()
							if v22 and v22.Parent then
								v22:Destroy()
							end
						end)
						v22.Parent = v21[v22.Name]
						v22.Name = "Attachment"
					end

					local v22 = {}
					local v23 = {}

					for _, child in ipairs(v19:GetChildren()) do
						local bone = child:GetAttribute("Bone")

						if not v21[bone] then
							continue
						end

						local offset = child:GetAttribute("Offset")
						local isFoot = string.match(string.lower(child.Name), "foot") ~= nil
						v22[#v22 + 1] = {
							Booster = child,
							Offset = offset,
							Bone = v21[bone],
							IsFoot = isFoot
						}
						v23[#v23 + 1] = child
					end

					task.spawn(function()
						local lastTime = tick()
						local cframe = CFrame.new(0, 0.13, 0)

						while tick() - lastTime < 4 do
							for _, v24 in ipairs(v22) do
								if v24.IsFoot then
									v24.Booster:PivotTo(v24.Bone.Attachment.WorldCFrame * cframe * v24.Offset:Inverse())
								else
									v24.Booster:PivotTo(v24.Bone.Attachment.WorldCFrame * v24.Offset:Inverse())
								end
							end

							RunService.RenderStepped:Wait()
						end

						v19:Destroy()
					end)
					local v24 = {
						["LowerLeg.L"] = v20["LowerLeg.L"],
						["LowerLeg.R"] = v20["LowerLeg.R"],
						["Jetpack.Main"] = v20["Jetpack.Main"]
					}

					for _, child in ipairs(script.BoosterFolder:GetChildren()) do
						local parent = v24[child.Name]

						if not parent then
							continue
						end

						local v26 = object._maid:give(child:Clone())
						v26.Parent = parent
						game.Debris:AddItem(v26, 7)

						for _, emitter in ipairs(v26:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.LockedToPart = true
							end
						end

						v23[#v23 + 1] = v26
					end

					task.delay(3, function()
						for _, folder2 in ipairs(v23) do
							able({
								FX = folder2,
								On = false
							})

							for _, descendant in ipairs(folder2:GetDescendants()) do
								if descendant:IsA("Beam") then
									descendant.Enabled = false
								elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
									TweenService:Create(descendant, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
										Transparency = 1
									}):Play()
								end
							end
						end
					end)
				end

				if mech == game.Players.LocalPlayer.Character then
					shared.repfire({
						Effect = "Camshake",
						Intensity = 12,
						Last = 3
					})
				end

				local parent2 = object._maid:give(Instance.new("Model"))
				local highlight = Instance.new("Highlight")
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillColor = Color3.fromRGB(153, 245, 255)
				highlight.OutlineTransparency = 1
				highlight.FillTransparency = -10
				highlight.Parent = parent2
				Color3.new(0.34902, 0.631373, 1)
				task.spawn(function()
					local lastTime = tick()

					while tick() - lastTime < 4 do
						if folder and folder.Parent then
							folder:PivotTo(primaryPart2.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(
								0,
								math.rad((random:NextNumber(0, 360))),
								0
							) * CFrame.Angles(0, 0, -1.5707963267948966))
							folder:ScaleTo(v16.Value * 1.3)
						end

						RunService.RenderStepped:Wait()
					end
				end)

				if Rocks then
					for _, v20 in ipairs(Rocks) do
						v20.Material = Enum.Material.Neon
						v20.Color = Color3.new(1, 0.203922, 0.00392157)
						local v21 = random:NextNumber(1, 2) * 3
						TweenService:Create(v20, TweenInfo.new(v21, Enum.EasingStyle.Sine), {
							Color = Color3.new(0, 0, 0)
						}):Play()
						local v22 = v20
						task.delay(v21, function()
							v22.Material = Enum.Material.Slate
						end)
					end
				end
			end)
			local emitters = getEmitters(FX2)

			for _, emitter in ipairs(emitters) do
				emitter.Rate *= 2
			end

			TweenService:Create(v11, TweenInfo.new(2, Enum.EasingStyle.Sine), {
				Value = 3
			}):Play()

			for _, emitter in ipairs(emitters) do
				TweenService:Create(emitter, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
					TimeScale = 0.08
				}):Play()
			end

			task.delay(0.5, function()
				local emitters2 = getEmitters(FX4)

				for _, emitter in ipairs(emitters2) do
					TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						TimeScale = 0.2
					}):Play()
				end

				task.wait(1)
				able({
					FX = FX4,
					On = false
				})
			end)
			task.delay(0.5, function()
				able({
					FX = FX3,
					On = true
				})
				FX3:ScaleTo(1.5)
				task.wait(0.3)
				able({
					FX = FX3,
					On = false
				})
			end)
			local folder2 = quickFX({
				FX = mrcoolfx.Wind,
				Maid = object._maid,
				Anchor = primaryPart2.CFrame
			})
			folder2:ScaleTo(folder2:GetScale() * 1.5)
			local descendants = {}
			local descendants2 = {}

			for _, descendant in ipairs(folder2:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendants[#descendants + 1] = descendant
				elseif descendant:IsA("Attachment") and descendant.Name == "2" then
					descendants2[#descendants2 + 1] = descendant
				end
			end

			for _, v18 in ipairs(descendants) do
				local transparency = v18.Transparency
				v18.Transparency = NumberSequence.new(1)
				playTween(v18, {
					Time = 0.7,
					EasingStyle = "Sine",
					Goal = {
						Transparency = transparency
					}
				})
			end

			for _, v18 in ipairs(descendants2) do
				TweenService:Create(v18, TweenInfo.new(5, Enum.EasingStyle.Sine), {
					CFrame = v18.CFrame * CFrame.new(-40, 0, -150)
				}):Play()
			end

			task.delay(0.7, function()
				TweenService:Create(v14, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
					Value = 0.05
				}):Play()

				for _, v18 in ipairs(descendants) do
					if v18.Parent.Parent.Parent.Parent.Name == "Model" then
						TweenService:Create(v18, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
							TextureSpeed = 0.01
						}):Play()
						playTween(v18, {
							Time = 1,
							EasingStyle = "Sine",
							Goal = {
								Transparency = NumberSequence.new(1)
							}
						})
						game.Debris:AddItem(v18, 1)
					else
						TweenService:Create(v18, TweenInfo.new(4, Enum.EasingStyle.Sine), {
							TextureSpeed = 0.01
						}):Play()
						playTween(v18, {
							Time = 0.7,
							EasingStyle = "Sine",
							Goal = {
								Transparency = NumberSequence.new(1)
							}
						})
						game.Debris:AddItem(v18, 0.7)
					end
				end

				task.wait(0.1)
				lifeScale({
					FX = folder2,
					Scale = 3
				})
				local emitters2 = getEmitters(folder2)

				for _, emitter in ipairs(emitters2) do
					TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						TimeScale = 0.2
					}):Play()
				end

				task.wait(0.2)
				able({
					FX = folder2,
					On = false
				})
			end)
			v4[#v4 + 1] = folder2
			task.wait(1.05)
			able({
				FX = FX2,
				On = false
			})
			able({
				FX = FX5,
				On = false
			})
		end)
		task.spawn(function()
			local lastTime = tick()
			local count = 0
			local count2 = 0

			while tick() - lastTime < 4 do
				count += 1
				FX:PivotTo(waist.WorldCFrame * CFrame.new(-4, -3, 0) * CFrame.Angles(3.141592653589793, 0, 0))
				FX2:PivotTo(waist.WorldCFrame * CFrame.new(-4, -2 + v11.Value, 0) * CFrame.Angles(
					3.141592653589793,
					0,
					0
				))
				FX3:PivotTo(waist.WorldCFrame * CFrame.new(-4, -2 + v11.Value, 0) * CFrame.Angles(
					3.141592653589793,
					0,
					0
				))

				for _, v17 in ipairs(v4) do
					if v17.Name == "Wind" then
						v17:PivotTo(v17:GetPivot():Lerp(
							waist.Parent.WorldCFrame * CFrame.new(-4, -7 * v11.Value, 0) * CFrame.Angles(
								-1.5707963267948966,
								0,
								0
							),
							v14.Value
						))
					end
				end

				if FX5 and FX5.Parent then
					FX5:PivotTo(primaryPart2.CFrame * CFrame.new(0, 20, 0))
				end

				if count % 25 == 0 and tick() - lastTime < 2 and tick() - lastTime > 1.2 then
					count2 += 1
					local model = object._maid:give(script.vfx.Balls:Clone())
					model:ScaleTo(2)
					playMesh({
						Model = model,
						Anchor = primaryPart.CFrame * CFrame.new(0, -40, 0) * CFrame.Angles(0, 0, -1.5707963267948966),
						Info = TweenInfo.new(count2 * 0.3, Enum.EasingStyle.Sine)
					})
				end

				dtwait(0.02)
			end

			task.wait(6)
			Clean() -- equivalent call inferred; original call site unknown
		end)
		FX.Parent = EFP
		FX2.Parent = EFP
		FX3.Parent = EFP
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SwordDrop.SwordEvent(p)
	local char = p.Data.Char
	local _ = char.PrimaryPart
	local mech = char.Mech
	local primaryPart = mech.PrimaryPart
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v3 then
			v3 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SwordEvent()
		if flag then
			return
		end

		if not flag then
			flag = true
			task.delay(6, function()
				flag = nil
			end)
		end

		local mrcoolfx = script.mrcoolfx
		local groupValue = mech:FindFirstChild("GroupValue")
		local count = 0
		local v4 = nil
		local v5 = MechCache.Get(primaryPart)
		local middleFinger002L = v5["Middle.Finger.002.L"]
		local middleFinger002R = v5["Middle.Finger.002.R"]
		local v6 = {}
		local heartbeatConnection = nil

		local function ensureHandThingConn()
			if heartbeatConnection then
				return
			end

			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				local now = tick()

				for k, _ in pairs(v6) do
					if now - k.start >= 4 then
						v6[k] = nil
					else
						k.frameCount += 1

						if k.frameCount % 4 == 0 then
							k.widthScale = random:NextNumber(0.5, 5)

							if now - k.start > 0.75 then
								k.lengthScale = random:NextNumber(0.8, 1)
							else
								k.lengthScale = random:NextNumber(0.01, 1)
							end
						end

						k.thisspin += k.spinValue.Value
						local magnitude = (middleFinger002L.WorldCFrame.Position - middleFinger002R.WorldCFrame.Position).Magnitude
						local cFrame = CFrame.new(
							middleFinger002L.WorldCFrame.Position,
							middleFinger002R.WorldCFrame.Position
						) * CFrame.new(0, 0, -magnitude / 2)
						k.part.CFrame = cFrame
						k.part.Size = Vector3.new(1 * k.widthScale, 1 * k.widthScale, magnitude * k.lengthScale) * k.scaleValue.Value

						for k2, part in pairs(k.parts) do
							local v8 = k.part.CFrame * CFrame.Angles(0, part.Angle, 0) * CFrame.Angles(
								0,
								math.rad(k.thisspin),
								0
							) * CFrame.new(0, 0, part.radius.Value)
							part.CF = part.Spring:Step(part.CF, v8, dt)
							k2:PivotTo(part.CF)
						end
					end
				end

				if not next(v6) then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			end)
			object._maid:giveTask(function()
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			end)
		end

		local function HandThing()
			local v7 = object._maid:give(script.InsideBall:Clone())
			v7.Anchored = true
			v7.CanCollide = false
			v7.Material = Enum.Material.Neon
			local v8 = object._maid:give(Instance.new("Highlight"))
			v8.Parent = v7
			v8.OutlineTransparency = 1
			v8.DepthMode = Enum.HighlightDepthMode.Occluded
			v8.FillTransparency = -10
			v4 = v7

			if count == 0 then
				v7.Color = Color3.fromRGB(80, 83, 255)
				TweenService:Create(v7, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Color = Color3.new(0, 0.615686, 1)
				}):Play()
				v8.FillColor = Color3.fromRGB(153, 245, 255)
			elseif count == 1 then
				v7.Color = Color3.fromRGB(255, 255, 255)
				TweenService:Create(v7, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Color = Color3.new(0.921569, 0.52549, 1)
				}):Play()
				v8.FillColor = Color3.fromRGB(255, 255, 255)
			elseif count == 2 then
				v7.Color = Color3.fromRGB(255, 255, 255)
				v7.Material = Enum.Material.Glass
				v7.Transparency = 5
				TweenService:Create(v7, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Color = Color3.new(0.921569, 0.52549, 1)
				}):Play()
				v8.FillColor = Color3.fromRGB(255, 255, 255)
				v8.FillTransparency = 1
			end

			v7.Parent = EFP

			if count == 0 then
				for _, child in ipairs(script.vfx.stretch:GetChildren()) do
					local give = object._maid:give(child:Clone())
					give.Parent = v7
				end

				able({
					FX = v7,
					On = true
				})
			end

			local scaleValue = object._maid:give(Instance.new("NumberValue"))

			if count == 0 then
				scaleValue.Value = 1
				TweenService:Create(scaleValue, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
					Value = 2
				}):Play()
			elseif count == 1 then
				scaleValue.Value = 0.5
				TweenService:Create(scaleValue, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
					Value = 1
				}):Play()
			elseif count == 2 then
				scaleValue.Value = 1.1
				TweenService:Create(scaleValue, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
					Value = 2.1
				}):Play()
			end

			task.delay(0.8, function()
				able({
					FX = v7,
					On = false
				})
				TweenService:Create(scaleValue, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Value = 0.1
				}):Play()
				task.wait(0.1)
				v7.Transparency = 1
			end)
			local parts = {}
			task.spawn(function()
				if count == 0 then
					local parent = object._maid:give(Instance.new("Model"))
					parent.Parent = EFP
					local v12 = object._maid:give(Instance.new("Highlight"))
					v12.FillColor = Color3.new(0.447059, 0.34902, 1)
					v12.FillTransparency = -3
					v12.DepthMode = Enum.HighlightDepthMode.Occluded
					v12.OutlineTransparency = 1

					for i = 1, 10 do
						local v14 = object._maid:give(script.trail:Clone())
						local radius = object._maid:give(Instance.new("NumberValue"))
						radius.Value = 21
						TweenService:Create(radius, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
							Value = 11
						}):Play()
						parts[v14] = {
							Angle = 0.6283185307179586 * i,
							Spring = SpringCFrame(8, 8),
							CF = nil,
							radius = radius
						}
						v14.Parent = parent
						v14.Anchored = true
						v14.Size = createVector(0, 0, 0)
						TweenService:Create(v14, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
							Size = createVector(1, 1, 1)
						}):Play()
						task.wait(0.05)
					end
				end
			end)
			task.delay(1, function()
				for folder, _ in pairs(parts) do
					TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Size = createVector(0, 0, 0)
					}):Play()

					for _, trail in ipairs(folder:GetDescendants()) do
						if trail:IsA("Trail") then
							playTween(trail, {
								Time = 0.5,
								EasingStyle = "Sine",
								Goal = {
									Transparency = NumberSequence.new(1)
								}
							})
						end
					end

					game.Debris:AddItem(folder, 0.5)
				end
			end)
			task.delay(0.5, function()
				for _, v11 in pairs(parts) do
					TweenService:Create(v11.radius, TweenInfo.new(1, Enum.EasingStyle.Back), {
						Value = 0
					}):Play()
				end
			end)
			local spinValue = object._maid:give(Instance.new("NumberValue"))
			spinValue.Value = 5
			TweenService:Create(spinValue, TweenInfo.new(4, Enum.EasingStyle.Back), {
				Value = 0
			}):Play()
			local v12 = {
				part = v7,
				parts = parts,
				start = tick(),
				frameCount = 0,
				thisspin = 0,
				widthScale = 1,
				lengthScale = 1,
				scaleValue = scaleValue,
				spinValue = spinValue
			}
			v6[v12] = true
			ensureHandThingConn()
			count += 1
		end

		HandThing()
		HandThing()
		HandThing()
		task.wait(0.7)
		local folder = object._maid:give(script.vfx.Appear3:Clone())
		folder:PivotTo(primaryPart.CFrame * CFrame.new(0, 9, -8))
		lifeScale({
			FX = folder,
			Scale = 0.3
		})

		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.LockedToPart = true
			end
		end

		folder.Parent = EFP
		shared.vfx.emit(folder)
		playAttachment((quickFX({
			FX = script.vfx.Connect,
			Maid = object._maid,
			Anchor = primaryPart.CFrame
		})))
		local localPlayer = game.Players.LocalPlayer
		local s_FastMode = localPlayer:GetAttribute("S_FastMode") == true
		local s_PotatoMode = localPlayer:GetAttribute("S_PotatoMode") == true
		local folder2

		if not (s_FastMode or s_PotatoMode) then
			local v8 = object._maid:give(Instance.new("Highlight"))
			v8.FillTransparency = -10
			v8.DepthMode = Enum.HighlightDepthMode.Occluded
			v8.OutlineTransparency = 1
			v8.FillColor = Color3.fromRGB(156, 169, 255)
			local _ = mech.Sword.Color
			v8.Parent = mech.Sword
			TweenService:Create(v8, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				FillTransparency = 1
			}):Play()
			folder2 = object._maid:give(script.vfx.Storm:Clone())
		end

		local v8 = {}
		local FX = object._maid:give(script.vfx.S1:Clone())
		FX:PivotTo(primaryPart.CFrame * CFrame.new(0, -30, 0))
		lifeScale({
			FX = FX,
			Scale = 1
		})
		FX.Parent = EFP
		playAttachment(FX)
		local FX2 = object._maid:give(script.vfx.Blast:Clone())
		FX2:PivotTo(primaryPart.CFrame * CFrame.new(0, -30, 0))
		lifeScale({
			FX = FX2,
			Scale = 1
		})
		FX2.Parent = EFP
		playAttachment(FX2)
		local FX3 = object._maid:give(script.vfx.S1:Clone())
		FX3:PivotTo(primaryPart.CFrame * CFrame.new(0, 260, 0))
		FX3:ScaleTo(70)
		lifeScale({
			FX = FX3,
			Scale = 4
		})
		FX3.Parent = EFP
		playAttachment(FX3)
		local v12 = object._maid:give(script.vfx.GoAway:Clone())
		v12:PivotTo(primaryPart.CFrame * CFrame.new(0, 0, 0))
		v12:ScaleTo(15)
		v12.Parent = EFP
		local folder3 = object._maid:give(script.vfx.mybrainissocookedatthispoint3:Clone())
		folder3:PivotTo(CFrame.new(v4.Position + createVector(0, -50, 0)))
		folder3:ScaleTo(7)
		folder3.Parent = EFP
		task.spawn(function()
			for _, descendant in ipairs(folder3:GetDescendants()) do
				local effectDuration = descendant:GetAttribute("EffectDuration")

				if effectDuration then
					descendant:SetAttribute(
						"EffectDuration",
						NumberRange.new(effectDuration.Min * 0.5, effectDuration.Max * 0.5)
					)
				end
			end

			shared.vfx.emit(folder3)
		end)
		local FX4 = object._maid:give(script.vfx.Maybe:Clone())
		FX4:PivotTo(primaryPart.CFrame * CFrame.new(0, 0, 0))
		FX4:ScaleTo(2)
		lifeScale({
			FX = FX4,
			Scale = 0.5
		})
		playAttachment(FX4)
		FX4.Parent = EFP
		local FX5 = object._maid:give(script.vfx.Pre:Clone())
		FX5:PivotTo(primaryPart.CFrame * CFrame.new(0, 0, 0))
		FX5:ScaleTo(14)
		lifeScale({
			FX = FX5,
			Scale = 1
		})
		playAttachment(FX5)
		FX5.Parent = EFP
		local v15 = object._maid:give(script.vfx.Sustain:Clone())
		v15:PivotTo(primaryPart.CFrame * CFrame.new(0, 0, 0))
		v15:ScaleTo(5)
		playAttachment(v15)
		v15.Parent = EFP
		local FX6 = object._maid:give(script.vfx.SkyBackground:Clone())
		FX6:PivotTo(primaryPart.CFrame * CFrame.new(0, 200, 0))
		able({
			FX = FX6,
			On = true
		})
		FX6.Parent = EFP
		task.delay(3, function()
			able({
				FX = FX6,
				On = false
			})
		end)

		if folder2 then
			folder2:PivotTo(primaryPart.CFrame * CFrame.Angles(0, 0, 1.5707963267948966))

			for _, part in ipairs(folder2:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				v8[part] = {
					Spin = random:NextNumber(0.1, 0.4)
				}
				local mesh = part:FindFirstChild("Mesh")
				local decal = part:FindFirstChild("Decal")

				if not (mesh and decal) then
					continue
				end

				local scale = mesh.Scale
				mesh.Scale *= 0.1
				TweenService:Create(mesh, TweenInfo.new(random:NextNumber(0.3, 0.9) * 6, Enum.EasingStyle.Sine), {
					Scale = scale
				}):Play()
				TweenService:Create(decal, TweenInfo.new(3, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
				local color3 = decal.Color3
				decal.Color3 = Color3.fromRGB(8.823525, 19.90195, 25)
				decal.Color3 = Color3.fromRGB(200, 500, 2000)
				TweenService:Create(decal, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					Color3 = color3
				}):Play()
			end

			folder2.Parent = EFP
		end

		local v17 = {}

		local function Test() end

		if folder2 then
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 4 do
					for k, v18 in pairs(v8) do
						k:PivotTo(k:GetPivot() * CFrame.Angles(math.rad(v18.Spin), 0, 0))
						folder:PivotTo(primaryPart.CFrame * CFrame.new(0, 2, -8))
					end

					for k, v18 in pairs(v17) do
						k:PivotTo(k:GetPivot() * CFrame.Angles(0, math.rad(v18.Spin), 0))
					end

					task.wait(0.04)
				end
			end)
		end

		task.delay(0.05, function()
			for _, child in ipairs(folder.SwordAppear:GetChildren()) do
				if child.Name == "SUPER" or child.Name == "Xf2" then
					child:Destroy()
				end
			end
		end)

		if groupValue then
			groupValue.Name = "USED"
			local value = groupValue.Value
			shared.vfx.emit(value.lightning1_Assembly.lightning1)
			task.wait(0.1)
			shared.vfx.emit(value.lightning1_Assembly.Pre1)
			shared.vfx.emit(value.lightning1_Assembly.Pre2)
			task.wait(0.3)
			task.wait(0.2)
			task.wait(1.1)
			local v18 = object._maid:give(mrcoolfx.Grab:Clone())
			v18.Parent = EFP
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 2 do
					PlaceVFX(v18, primaryPart:GetPivot() * CFrame.new(0, -10, 0)) -- equivalent call inferred; original call site unknown
					RunService.RenderStepped:Wait()
				end
			end)
			shared.vfx.emit(v18)
			task.wait(1.3)
			local v19 = object._maid:give(mrcoolfx.XD:Clone())
			v19.Parent = mech.Sword
			shared.vfx.emit(v19)
			task.wait(0.3)
			shared.vfx.emit(value.Cframe_Assembly)
		end
	end

	task.spawn(SwordEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SwordDrop.BoomEvent(p)
	local mrcoolfx = script.mrcoolfx
	local data = p.Data
	local _ = data.Origin
	local char = data.Char
	local _ = char.PrimaryPart
	local primaryPart = char.Mech.PrimaryPart
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v3 then
			v3 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function BoomEvent()
		local v4 = primaryPart.CFrame * CFrame.new(0, 0, -6)
		local v5 = object._maid:give(Instance.new("Part"))
		v5.Parent = EFP
		v5.Anchored = true
		v5.CanCollide = false
		v5.Transparency = 1
		v5:PivotTo(v4)
		local folder = object._maid:give(mrcoolfx.LastImpact:Clone())

		for _, descendant in ipairs(folder:GetDescendants()) do
			if not (descendant:IsA("Model") or descendant:IsA("BasePart")) then
				continue
			end

			PlaceVFX(descendant, primaryPart:GetPivot() * CFrame.new(0, 0, 0)) -- equivalent call inferred; original call site unknown
		end

		folder.Parent = EFP
		playAttachment(folder)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
		local raycastResult = game.Workspace:Raycast(v4.Position, createVector(0, -200, 0), raycastParams)
		v5.CFrame = CFrame.new(raycastResult.Position + createVector(0, 1, 0))

		local function Demon()
			local parent = object._maid:give(Instance.new("Model"))
			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(30, 48, 241)
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = -10
			highlight.Parent = parent
			parent.Name = "Lightnings"
			parent.Parent = game.Workspace.Thrown
			local FX = quickFX({
				FX = v.GetTemplate(script.vfx.Ethereal, {
					rateMult = 2,
					lifeScale = 0.5,
					speedMult = 2,
					dragMult = 2
				}),
				Maid = object._maid,
				Anchor = v5.CFrame
			})
			FX:ScaleTo(2)
			local v8 = object._maid:give(Instance.new("NumberValue"))
			v8.Value = 12.3
			task.delay(0.3, function()
				TweenService:Create(v8, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
					Value = 15
				}):Play()
			end)
			playAttachment(FX.Part.emit)
			task.delay(0.5, function()
				able({
					FX = FX,
					On = false
				})
			end)
			task.wait(0.6)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function CanEvent()
			local vfx2 = script.vfx
			task.spawn(function()
				local lastTime = tick()
				local folder2 = object._maid:give(vfx2.center:Clone())
				folder2:PivotTo(v5.CFrame)
				folder2.Parent = EFP
				local folder3 = object._maid:give(vfx2.bottom:Clone())
				folder3:PivotTo(v5.CFrame)
				folder3.Parent = EFP
				TweenService:Create(folder2.PrimaryPart, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					CFrame = folder2:GetPivot() * CFrame.new(0, 100, 0)
				}):Play()
				TweenService:Create(folder3.PrimaryPart, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					CFrame = folder2:GetPivot() * CFrame.new(0, 42, 0)
				}):Play()
				local FX = object._maid:give(vfx2.Particles:Clone())
				FX:PivotTo(v5.CFrame)
				FX.Parent = EFP
				task.delay(0.3, function()
					able({
						FX = folder2,
						On = false
					})
					able({
						FX = folder3,
						On = false
					})
					able({
						FX = FX,
						On = false
					})
				end)
				local v7 = object._maid:give(Instance.new("NumberValue"))
				v7.Value = 0.1
				local objectValues = {}
				local count = 0

				for _, objectValue in ipairs(folder2:GetDescendants()) do
					if objectValue:IsA("ObjectValue") and objectValue:GetAttribute("MaxSize") then
						objectValues[#objectValues + 1] = objectValue
					end
				end

				local objectValues2 = {}

				for _, objectValue in ipairs(folder3:GetDescendants()) do
					if objectValue:IsA("ObjectValue") and objectValue:GetAttribute("MaxSize") then
						objectValues2[#objectValues2 + 1] = objectValue
					end
				end

				local maxSizes = {}
				object._maid:giveTask(v7.Changed:Connect(function()
					local value = v7.Value

					for _, v8 in ipairs(objectValues) do
						local maxSize = maxSizes[v8]

						if not maxSize then
							maxSize = v8:GetAttribute("MaxSize")
							maxSizes[v8] = maxSize
						end

						v8:SetAttribute("MaxSize", NumberRange.new(maxSize.Min * value, maxSize.Max * value))
					end

					for _, v8 in ipairs(objectValues2) do
						local maxSize = maxSizes[v8]

						if not maxSize then
							maxSize = v8:GetAttribute("MaxSize")
							maxSizes[v8] = maxSize
						end

						v8:SetAttribute("MaxSize", NumberRange.new(maxSize.Min * value, maxSize.Max * value))
					end

					FX:ScaleTo(value)
				end))
				TweenService:Create(v7, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Value = 1.5
				}):Play()

				while tick() - lastTime < 0.3 do
					count += 1

					if count % 10 == 0 then
						local model = object._maid:give(vfx2.slow:Clone())
						model:ScaleTo(count / 10 * 0.2 + 1)
						playMesh({
							Model = model,
							T = 0,
							EndT = 0,
							Anchor = v5.CFrame * CFrame.new(0, 50, 0) * CFrame.new(0, 20 * model:GetScale(), 0) * CFrame.Angles(
								0,
								math.rad((random:NextNumber(0, 360))),
								1.5707963267948966
							),
							Info = TweenInfo.new(0.05, Enum.EasingStyle.Sine)
						})
					end

					if count % 2 == 0 then
						if tick() - lastTime < 0.9 then
							local model = object._maid:give(vfx2.Wind2:Clone())
							model:ScaleTo(count / 10 * 2 + 1)
							playMesh({
								Model = model,
								Anchor = v5.CFrame * CFrame.new(0, 10 * model:GetScale(), 0) * CFrame.Angles(
									0,
									math.rad((random:NextNumber(0, 360))),
									1.5707963267948966
								),
								Info = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
							})
						end

						local model2 = object._maid:give(vfx2.Sphere:Clone())
						model2:ScaleTo(count / 10 * 0.3 + 1)
						playMesh({
							Model = model2,
							T = 0,
							EndT = 0,
							Anchor = v5.CFrame * CFrame.new(0, 10 * model2:GetScale(), 0) * CFrame.Angles(
								0,
								math.rad((random:NextNumber(0, 360))),
								0
							),
							Info = TweenInfo.new(0.02, Enum.EasingStyle.Sine)
						})
						local model3 = object._maid:give(vfx2.fast:Clone())
						model3:ScaleTo(count / 10 * 0.7 + 1)
						playMesh({
							Model = model3,
							T = 0,
							EndT = 0,
							Anchor = v5.CFrame * CFrame.new(0, -50, 0) * CFrame.new(0, 1 * model3:GetScale(), 0) * CFrame.Angles(
								3.141592653589793,
								math.rad((random:NextNumber(0, 360))),
								0
							),
							Info = TweenInfo.new(0.015, Enum.EasingStyle.Sine)
						})
					end

					task.wait(0.01)
				end
			end)
		end

		task.spawn(function()
			CanEvent() -- equivalent call inferred; original call site unknown
		end)
	end

	task.spawn(BoomEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return SwordDrop