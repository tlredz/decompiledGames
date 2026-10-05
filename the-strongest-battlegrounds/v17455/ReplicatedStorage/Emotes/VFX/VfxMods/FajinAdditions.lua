local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local _ = libraryNew.EFP
local playMesh = libraryNew.PlayMesh
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
local _ = libraryNew.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local LightningModule = require(script.LightningModule)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
local children = { workspace.Built }
local FajinAdditions = {}

for _, child in pairs(workspace.Map:GetChildren()) do
	if tostring(child) ~= "Benchs" then
		table.insert(children, child)
	end
end

raycastParams.FilterDescendantsInstances = children

function FajinAdditions.FirstEvent(p)
	local char = p.Char
	local humanoidRootPart = char.HumanoidRootPart
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

	task.delay(7, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local DELAY_DURATION = 8
		local charging = p.Charging
		local cFrame = humanoidRootPart.CFrame
		local v2 = cFrame * CFrame.new(0, 3.5, 0)
		local v3 = object._maid:give(Instance.new("Highlight"))
		v3.FillColor = Color3.new(255, 0, 0)
		v3.FillTransparency = -3
		v3.OutlineTransparency = 1
		v3.Parent = char
		TweenService:Create(v3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			FillTransparency = 1
		}):Play()
		task.delay(5, function()
			if v3 and v3.Parent then
				v3:Destroy()
			end
		end)
		local v4 = quickFX({
			FX = vfx.Start,
			Maid = object._maid,
			Anchor = cFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		playAttachment(v4)
		task.delay(DELAY_DURATION, function()
			if v4 and v4.Parent then
				v4:Destroy()
			end
		end)
		local clone = vfx.Ring1:Clone()
		task.delay(DELAY_DURATION, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
		clone:ScaleTo(1)
		clone:PivotTo(v2 * CFrame.Angles(1.5707963267948966, 0, 0))
		playMesh({
			Model = clone,
			Info = TweenInfo.new(0.4, Enum.EasingStyle.Sine)
		})
		local clone2 = vfx.Ring2:Clone()
		task.delay(DELAY_DURATION, function()
			if clone2 and clone2.Parent then
				clone2:Destroy()
			end
		end)
		clone2:ScaleTo(0.3)
		clone2:PivotTo(v2 * CFrame.Angles(3.141592653589793, 0, 0))
		playMesh({
			Model = clone2,
			Info = TweenInfo.new(0.4, Enum.EasingStyle.Sine)
		})
		local clone3 = vfx.Orb:Clone()
		task.delay(DELAY_DURATION, function()
			if clone3 and clone3.Parent then
				clone3:Destroy()
			end
		end)
		clone3:ScaleTo(0.7)
		clone3:PivotTo(cFrame * CFrame.Angles(1.5707963267948966, 0, 0))
		playMesh({
			Model = clone3,
			Info = TweenInfo.new(0.8, Enum.EasingStyle.Sine)
		})
		local clone4 = vfx.WindDecal2:Clone()
		task.delay(DELAY_DURATION, function()
			if clone4 and clone4.Parent then
				clone4:Destroy()
			end
		end)
		clone4:ScaleTo(1)
		clone4:PivotTo(v2 * CFrame.Angles(0, 0, 1.5707963267948966))
		playMesh({
			Model = clone4,
			Info = TweenInfo.new(2.4, Enum.EasingStyle.Exponential)
		})
		local v5 = object._maid:give(Instance.new("PointLight"))
		task.delay(DELAY_DURATION, function()
			if v5 and v5.Parent then
				v5:Destroy()
			end
		end)
		v5.Brightness = 5
		v5.Range = 20
		v5.Color = Color3.new(1, 0, 0)
		v5.Parent = char.Torso
		TweenService:Create(v5, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Range = 0
		}):Play()
		local clone5 = vfx.SPur:Clone()
		task.delay(DELAY_DURATION, function()
			if clone5 and clone5.Parent then
				clone5:Destroy()
			end
		end)
		clone5:ScaleTo(0.65)
		clone5:PivotTo(cFrame * CFrame.Angles(3.141592653589793, 0, 0))
		playMesh({
			Model = clone5,
			Info = TweenInfo.new(1.8, Enum.EasingStyle.Exponential)
		})
		local clone6 = vfx.Wind:Clone()
		task.delay(DELAY_DURATION, function()
			if clone6 and clone6.Parent then
				clone6:Destroy()
			end
		end)
		clone6:ScaleTo(0.45)
		clone6:PivotTo(cFrame * CFrame.new(0, -1, 0) * CFrame.Angles(3.141592653589793, 0, 0))
		playMesh({
			Model = clone6,
			Info = TweenInfo.new(2.8, Enum.EasingStyle.Exponential)
		})
		task.wait(0.1)
		local v6 = char == game.Players.LocalPlayer.Character
		local cframe = CFrame.Angles(0, -0.2617993877991494, 0)
		local v7 = {
			Effect = "Camshake",
			Intensity = 0.3
		}

		local function Secondary()
			local folder = quickFX({
				FX = vfx.Suck,
				Maid = object._maid,
				Anchor = cFrame * CFrame.new(0, -1.5, 0)
			})
			task.delay(8, function()
				if folder and folder.Parent then
					folder:Destroy()
				end
			end)

			for _, emitter in ipairs(folder:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.TimeScale = 0.3
				TweenService:Create(emitter, TweenInfo.new(6, Enum.EasingStyle.Sine), {
					TimeScale = 1
				}):Play()
			end

			local folder2 = quickFX({
				FX = vfx.Second,
				Maid = object._maid,
				Anchor = cFrame * CFrame.new(0, -2.4, 0)
			})
			task.delay(8, function()
				if folder2 and folder2.Parent then
					folder2:Destroy()
				end
			end)
			local count = 0
			local descendants = {}
			local count2 = 0
			local descendants2 = {}

			for _, descendant in ipairs(folder2:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = true
					count += 1
					descendants[count] = descendant
				elseif descendant:IsA("ObjectValue") then
					descendant:SetAttribute("Enabled", true)
					count2 += 1
					descendants2[count2] = descendant
				end
			end

			task.spawn(function()
				local lastTime = tick()
				local count3 = 0

				while tick() - lastTime < 3 and charging and charging.Parent do
					count3 += 1
					folder2:PivotTo(folder2:GetPivot() * cframe)

					if v6 and count3 % 2 == 0 then
						shared.repfire(v7)
					end

					dtwait(0.15)
				end
			end)
			object._maid:give(charging.Destroying:Once(function()
				for i = 1, count do
					local v8 = descendants[i]

					if v8 and v8.Parent then
						v8.Enabled = false
					end
				end

				for i = 1, count2 do
					local v8 = descendants2[i]

					if v8 and v8.Parent then
						v8:SetAttribute("Enabled", false)
					end
				end

				able({
					FX = folder,
					On = false
				})
			end))
		end

		(function()
			local v8 = { char["Right Arm"], char["Left Arm"] }
			local count = 0
			local objectValues = {}

			for i = 1, 2 do
				local folder = object._maid:give(vfx.Spin.Spin:Clone())
				task.delay(8, function()
					if folder and folder.Parent then
						folder:Destroy()
					end
				end)
				folder.Parent = v8[i]

				for _, objectValue in ipairs(folder:GetDescendants()) do
					if not objectValue:IsA("ObjectValue") then
						continue
					end

					objectValue:SetAttribute("Emit", true)
					count += 1
					objectValues[count] = objectValue
				end
			end

			object._maid:give(charging.Destroying:Once(function()
				for i = 1, count do
					local v9 = objectValues[i]

					if v9 and v9.Parent then
						v9:SetAttribute("Enabled", false)
					end
				end
			end))
		end)()
		Secondary()
	end

	task.spawn(FirstEvent)
	wait(6)
	Clean() -- equivalent call inferred; original call site unknown
end

function FajinAdditions.DashEvent(p)
	local char = p.Char
	local humanoidRootPart = char.HumanoidRootPart
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

	local function DashEvent()
		warn("Yo g")
		local FX = quickFX({
			FX = vfx.Dash,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -10)
		})
		able({
			FX = FX,
			On = false
		})
		playAttachment(FX)
		game.Debris:AddItem(FX, 8)
		local folder = quickFX({
			FX = vfx.Proj2,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame
		})
		local v3 = quickFX({
			FX = vfx.EZ,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		})
		game.Debris:AddItem(folder, 8)
		game.Debris:AddItem(v3, 8)
		playAttachment(v3)
		task.delay(0.4, function()
			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("ObjectValue") then
					descendant:SetAttribute("Enabled", false)
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				end
			end
		end)
		task.spawn(function()
			local lastTime = tick()
			local count = 0

			while tick() - lastTime < 1 do
				if not (folder and folder.Parent) then
					break
				end

				count += 1

				if count % 3 == 0 and tick() - lastTime < 0.45 then
					local color = Color3.fromRGB(203, 18, 18)
					local duration = random:NextNumber(0.3, 0.5) * 0.5
					LightningModule.new(
						char.Torso,
						humanoidRootPart.CFrame * CFrame.new(random:NextNumber(-50, 50), 0, random:NextNumber(-30, -20)).Position,
						{
							Color = color,
							SecondaryColor = color,
							Duration = duration,
							ArcSway = 11,
							WanderRadius = 6,
							WanderSpeed = 0.1,
							ThicknessJitter = 0.5,
							SegmentCount = 6,
							JitterIntensity = 5,
							Width = 1,
							CylinderSize = random:NextNumber(3, 5)
						}
					)
				end

				folder:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0))
				dtwait(0.04)
			end
		end)
	end

	task.spawn(DashEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return FajinAdditions