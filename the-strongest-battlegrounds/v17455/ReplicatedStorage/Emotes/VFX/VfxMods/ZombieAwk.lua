local ZombieAwk = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local EFP = libraryNew.EFP
local playMesh = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local raiseZIndex = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local quickWeld = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local _ = libraryNew.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

function ZombieAwk.FirstEvent(p)
	local char = p.Data.Char
	local humanoidRootPart = char.HumanoidRootPart
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

	local function FirstEvent()
		local FX = quickWeld({
			FX = vfx.Aura,
			Maid = object._maid,
			P = humanoidRootPart
		})

		if char:FindFirstChild("Axe") then
			task.spawn(function()
				task.wait(3)
				local v3 = object._maid:give(vfx.stuff:Clone())
				local children = {}

				for _, child in pairs(v3:GetChildren()) do
					child.Parent = char.Axe["Circle.003"]
					table.insert(children, child)
					game.Debris:AddItem(child, 6)
				end

				task.delay(1, function()
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
			end)
		end

		task.delay(1, function()
			able({
				FX = FX,
				On = true
			})
		end)
		task.delay(3, function()
			able({
				FX = FX,
				On = false
			})
		end)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ZombieAwk.CatchEvent(p)
	local char = p.Data.Char
	local _ = char.HumanoidRootPart
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

	local function CatchEvent()
		local FX = quickFX({
			FX = vfx.Catch,
			Maid = object._maid,
			Anchor = char["Right Arm"].CFrame * CFrame.new(0, -0.7, 0)
		})
		raiseZIndex({
			FX = FX,
			Count = 1.5
		})
		playAttachment(FX)
		local axe = char:FindFirstChild("Axe")

		if axe then
			task.wait(0.2)
			local v3 = object._maid:give(vfx.Weapon:Clone())
			local weld = Instance.new("Weld")
			weld.Part0 = v3
			weld.Part1 = axe.HandleR
			weld.C0 = CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, 3)
			weld.Parent = v3
			v3.Parent = EFP
			playAttachment(v3)
		end
	end

	task.spawn(CatchEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ZombieAwk.JumpEvent(p)
	local char = p.Data.Char
	local humanoidRootPart = char.HumanoidRootPart
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

	local function JumpEvent()
		if char:FindFirstChild("Axe") then
			task.spawn(function()
				task.wait(2)
				local v2 = object._maid:give(vfx.stuff:Clone())
				local children = {}

				for _, child in pairs(v2:GetChildren()) do
					child.Parent = char.Axe["Circle.003"]
					table.insert(children, child)
					game.Debris:AddItem(child, 6)
				end

				task.delay(1.5, function()
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
			end)
		end

		task.spawn(function()
			for i = 1, 4 do
				local folder = quickFX({
					FX = vfx.DatSpin,
					Maid = object._maid,
					Anchor = char:GetPivot() * CFrame.new(0, i * 2 * 1, 0) * CFrame.Angles(
						0,
						random:NextNumber(-4, 4),
						0
					)
				})
				folder:ScaleTo(i * 1.2 * 1)

				for _, beam in pairs(folder:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local transparency = beam.Transparency
					beam.Transparency = NumberSequence.new(1)
					playTween(beam, {
						Time = 0.1,
						EasingStyle = "Sine",
						Goal = {
							Transparency = transparency
						}
					})
				end

				local v2 = object._maid:give(Instance.new("NumberValue"))
				object._maid:giveTask(v2.Changed:Connect(function()
					folder:ScaleTo(v2.Value)
				end))
				v2.Value = folder:GetScale()
				TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Value = i * 3 * 1
				}):Play()
				local folder2 = folder
				task.delay(0.5, function()
					for i2, beam in pairs(folder2:GetDescendants()) do
						if beam:IsA("Beam") then
							playTween(beam, {
								Time = 0.5,
								EasingStyle = "Sine",
								Goal = {
									Transparency = NumberSequence.new(1)
								}
							})
						end
					end

					able({
						FX = folder2,
						On = false
					})
				end)
				task.wait(0.1)
			end
		end)
		playAttachment((quickFX({
			FX = vfx.Jump,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
		})))
		local clone = vfx.Ring2:Clone()
		clone:ScaleTo(2.25)
		playMesh({
			Model = clone,
			T = 0.5,
			EndT = 1,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0),
			Info = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
		})
		task.wait(0.1)
		local clone2 = vfx.Ring:Clone()
		clone2:ScaleTo(0.7)
		playMesh({
			Model = clone2,
			T = 0,
			EndT = 1,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0),
			Info = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
		})
	end

	task.spawn(JumpEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ZombieAwk.FallEvent(p)
	local char = p.Data.Char
	local humanoidRootPart = char.HumanoidRootPart
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

	local function FallEvent()
		local v2 = object._maid:give(vfx.FirstSlashmesh:Clone())
		v2.Parent = EFP
		v2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
			-1.5707963267948966,
			-1.5707963267948966,
			0
		) * CFrame.new(20, 0, 0))
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 1 do
				v2:PivotTo(CFrame.new(char.Torso.Position) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(
					10,
					0,
					0
				))
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			end
		end)
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 0.5 do
				local clone = vfx.Ring:Clone()
				clone:ScaleTo(0.7)
				playMesh({
					Model = clone,
					T = 0,
					EndT = 1,
					Anchor = CFrame.new(char.Torso.Position) * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0),
					Info = TweenInfo.new(0.1, Enum.EasingStyle.Sine)
				})
				task.wait(0.1)
			end
		end)
	end

	task.spawn(FallEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ZombieAwk.LandEvent(p)
	local char = p.Data.Char
	local humanoidRootPart = char.HumanoidRootPart
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

	local function LandEvent()
		local clone = vfx.WindFloor:Clone()
		clone:ScaleTo(1)
		playMesh({
			Model = clone,
			T = 0.8,
			EndT = 1,
			Anchor = CFrame.new(char.Torso.Position) * CFrame.new(0, 8, 0) * CFrame.Angles(0, 0, 0),
			Info = TweenInfo.new(4, Enum.EasingStyle.Exponential)
		})
		task.spawn(function()
			for i = 1, 3 do
				local folder = quickFX({
					FX = vfx.DatSpin2,
					Maid = object._maid,
					Anchor = char:GetPivot() * CFrame.new(0, 0, -6) * CFrame.Angles(
						math.rad((random:NextNumber(-0, 0))),
						math.rad((random:NextNumber(-360, 360))),
						(math.rad((random:NextNumber(-0, 0))))
					) * CFrame.new(0, i * 0.5 * 1, 0)
				})
				folder:ScaleTo(i * 1.2 * 1)

				for i2, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("Beam") then
						local transparency = effect.Transparency
						effect.Transparency = NumberSequence.new(1)
						playTween(effect, {
							Time = 0.1,
							EasingStyle = "Sine",
							Goal = {
								Transparency = transparency
							}
						})
						effect.TextureSpeed *= 0.5
						TweenService:Create(effect, TweenInfo.new(0.5 * i2, Enum.EasingStyle.Sine), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					elseif effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					end
				end

				local v2 = object._maid:give(Instance.new("NumberValue"))
				object._maid:giveTask(v2.Changed:Connect(function()
					folder:ScaleTo(v2.Value)
				end))
				v2.Value = folder:GetScale()
				TweenService:Create(v2, TweenInfo.new(i * 1.5, Enum.EasingStyle.Exponential), {
					Value = i * 7 * 1
				}):Play()
				local folder2 = folder
				local v5 = i
				task.delay(0.5, function()
					for i2, beam in pairs(folder2:GetDescendants()) do
						if beam:IsA("Beam") then
							playTween(beam, {
								Time = v5 * 0.2,
								EasingStyle = "Sine",
								Goal = {
									TextureSpeed = beam.TextureSpeed * 0.1,
									Transparency = NumberSequence.new(1)
								}
							})
						end
					end

					able({
						FX = folder2,
						On = false
					})
				end)
				task.wait(0.03)
			end
		end)
		local v2 = quickFX({
			FX = vfx.Slam,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, -6) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
		})
		v2:ScaleTo(7)
		playAttachment(v2)
		local _, v3, _ = humanoidRootPart.CFrame:ToOrientation()
		local folder = quickFX({
			FX = vfx.crack,
			Maid = object._maid,
			Anchor = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, v3, 0) * CFrame.new(
				0.1,
				-humanoidRootPart.Size.Y * 1.49,
				-4.6
			) * CFrame.Angles(0, 1.5707963267948966, 0)
		})
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 0.2 do
				local _, v4, _ = humanoidRootPart.CFrame:ToOrientation()
				folder:PivotTo(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, v4, 0) * CFrame.new(
					0.1,
					-humanoidRootPart.Size.Y * 1.49,
					-4.6
				) * CFrame.Angles(0, 1.5707963267948966, 0))
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			end
		end)
		task.delay(1, function()
			for _, image in pairs(folder:GetDescendants()) do
				if image:IsA("ImageLabel") then
					TweenService:Create(image, TweenInfo.new(2, Enum.EasingStyle.Sine), {
						ImageTransparency = 1
					}):Play()
				end
			end
		end)
		task.spawn(function()
			local v4 = quickFX({
				FX = vfx.Sparks,
				Maid = object._maid,
				Anchor = humanoidRootPart:GetPivot() * CFrame.new(0, 0, -6) * CFrame.Angles(-1.5707963267948966, 0, 0)
			})
			v4:ScaleTo(2)
			lifeScale({
				FX = v4.ok,
				Scale = 1.5
			})
			lifeScale({
				FX = v4.more.eh,
				Scale = 2.5
			})

			for _, child in pairs(v4:GetChildren()) do
				child:GetAttribute("EffectDuration")
			end

			shared.vfx.emit(v4)
			local v5 = quickFX({
				FX = vfx.Slash1,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(
					0,
					-1.5707963267948966,
					0
				)
			})
			shared.vfx.emit(v5)
			local v6 = object._maid:give(vfx.FirstSlashmesh:Clone())
			v6.Parent = EFP
			v6:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -6) * CFrame.Angles(
				-0.7853981633974483,
				-1.5707963267948966,
				0
			) * CFrame.new(20, 0, 0))
			shared.vfx.emit(v6)
		end)
		local clone2 = vfx.Ring:Clone()
		clone2:ScaleTo(1.4)
		playMesh({
			Model = clone2,
			T = 0,
			EndT = 1,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -10, -6) * CFrame.Angles(0, 0, 0),
			Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
		})
		local clone3 = vfx.Ring2:Clone()
		clone3:ScaleTo(3.25)
		playMesh({
			Model = clone3,
			T = 0.9,
			EndT = 1,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 5, -6) * CFrame.Angles(0, 0, 0),
			Info = TweenInfo.new(1.3, Enum.EasingStyle.Sine)
		})
		local v4 = quickFX({
			FX = vfx.Extra,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.4, -6)
		})
		v4:ScaleTo(5)
		lifeScale({
			FX = v4.Part.Attachment,
			Scale = 4
		})
		playAttachment(v4)
		local folder2 = quickFX({
			FX = vfx.Bems,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 10, 15) * CFrame.Angles(
				-0.6108652381980153,
				1.5707963267948966,
				0
			)
		})
		folder2:ScaleTo(1)

		for _, beam in pairs(folder2:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local transparency = beam.Transparency
			beam.Transparency = NumberSequence.new(1)
			playTween(beam, {
				Time = 0.075,
				EasingStyle = "Sine",
				Goal = {
					Transparency = transparency
				}
			})
			beam.TextureSpeed *= 4
			local v5 = beam
			task.delay(0.1425, function()
				TweenService:Create(v5, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					TextureSpeed = v5.TextureSpeed * 0.1
				}):Play()
				playTween(v5, {
					Time = 0.825,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new(1)
					}
				})
			end)
		end
	end

	task.spawn(LandEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return ZombieAwk