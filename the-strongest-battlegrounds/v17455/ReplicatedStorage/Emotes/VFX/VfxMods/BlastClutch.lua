local createVector = vector.create
local BlastClutch = {}
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
local _ = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local quickWeld = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local blastClutch = game.ReplicatedStorage.Resources.OldPirate.BlastClutch
require(game.ReplicatedStorage.Utility)
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local camera = game.Workspace.Camera
local v = {
	"rbxassetid://18840126037",
	"rbxassetid://18840125833",
	"rbxassetid://18840125602",
	"rbxassetid://18840125602",
	"rbxassetid://18840125602",
	"rbxassetid://18840125602",
	"rbxassetid://18840125449",
	"rbxassetid://18840125332",
	"rbxassetid://18840125174",
	"rbxassetid://18840125022",
	"rbxassetid://18840124888",
	"rbxassetid://18840124504",
	"rbxassetid://18840124339",
	"rbxassetid://18840124089"
}
local v2 = {
	"rbxassetid://18841684798",
	"rbxassetid://18841684701",
	"rbxassetid://18841684605",
	"rbxassetid://18841684408",
	"rbxassetid://18841684235",
	"rbxassetid://18841684134",
	"rbxassetid://18841683940",
	"rbxassetid://18841683790",
	"rbxassetid://18841683499",
	"rbxassetid://18841683231",
	"rbxassetid://18841683007",
	"rbxassetid://18841682830"
}

local function fn(position, p, value, value2)
	local random2 = Random.new()
	local unit = (p - position).Unit
	return (CFrame.new(Vector3.new(), unit) * CFrame.fromOrientation(0, 0, random2:NextNumber(0, 6.283185307179586)) * CFrame.fromOrientation(
		math.rad((random2:NextNumber(value or 0, value2 or 0))),
		0,
		0
	)).LookVector
end

local function fn2(image, list, tweenInfo, callback)
	local v3 = tweenInfo or TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	image:IsA("ImageLabel")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateTexture(p)
		local decal

		if image:IsA("ImageLabel") then
			decal = image
		else
			decal = image:FindFirstChildOfClass("Decal")
		end

		local v4 = decal and list[p]

		if v4 then
			if image:IsA("ImageLabel") then
				decal.Image = v4
			else
				decal.Texture = v4
			end
		end
	end

	local v4 = #list
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1
	local tween = TweenService:Create(numberValue, v3, {
		Value = v4
	})
	tween:Play()
	local changedConnection = numberValue.Changed:Connect(function(p)
		updateTexture(math.floor(p)) -- equivalent call inferred; original call site unknown
	end)
	local completedConnection = nil
	completedConnection = tween.Completed:Connect(function()
		numberValue:Destroy()

		if callback then
			callback()
		end

		changedConnection:Disconnect()
		completedConnection:Disconnect()
	end)
	return tween
end

function BlastClutch.FirstEvent(p)
	local char = p.Data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
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

	task.delay(8, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		task.wait(0.1)

		for _, part2 in pairs({ char["Right Arm"], char["Left Arm"] }) do
			local FX = quickWeld({
				FX = blastClutch.startup,
				Maid = object._maid,
				P = part2,
				C0 = CFrame.new(0, 1, 0)
			})
			FX:ScaleTo(0.5)
			lifeScale({
				FX = FX,
				Scale = 1
			})
			playAttachment(FX)
			local folder = quickWeld({
				FX = blastClutch.Charging,
				Maid = object._maid,
				P = part2,
				C0 = CFrame.new(0, 1, 0)
			})
			folder:ScaleTo(0.6)
			lifeScale({
				FX = folder,
				Scale = 1
			})
			able({
				FX = folder,
				On = false
			})

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(3, Enum.EasingStyle.Sine), {
						TimeScale = 0.2
					}):Play()
				end
			end

			local clone = blastClutch.untitled:Clone()
			local weld = Instance.new("Weld")
			weld.Part0 = clone.PrimaryPart
			weld.Part1 = part2
			weld.C0 = CFrame.new(0, 1, 0)
			weld.Parent = clone
			clone:SetAttribute("Balls", true)
			game.Debris:AddItem(clone, 10)
			clone.Parent = char
			clone.AnimationController:LoadAnimation(clone.Animation):Play()

			for _, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			local folder2 = folder
			task.delay(0.3, function()
				for i, part in pairs(clone:GetChildren()) do
					if part:IsA("BasePart") and part ~= clone.PrimaryPart then
						TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 0
						}):Play()
					end
				end

				local lastTime = tick()

				while tick() - lastTime < 10 and char:GetAttribute("HoldingBlastClutch") do
					wait()
				end

				for i, trail in pairs(folder2:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					playTween(trail, {
						Time = 0.2,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(1, 1)
							})
						}
					})
					game.Debris:AddItem(trail, 0.2)
				end

				able({
					FX = folder2,
					On = false
				})

				for i, part in pairs(clone:GetChildren()) do
					if part:IsA("BasePart") and part ~= clone.PrimaryPart then
						TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end
				end

				game.Debris:AddItem(clone, 0.4)
			end)
			local v8 = part2
			task.delay(0.25, function()
				able({
					FX = folder,
					On = true
				})
				local v9 = quickWeld({
					FX = blastClutch.Bol,
					Maid = object._maid,
					P = v8,
					C0 = CFrame.new(0, 0.5, 0)
				})
				v9:ScaleTo(0.1)
				TweenService:Create(v9.PrimaryPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				}):Play()
				local v10 = object._maid:give(Instance.new("Highlight"))
				v10.FillTransparency = 1
				v10.OutlineTransparency = 1
				v10.Parent = v9.PrimaryPart
				game.Debris:AddItem(v9, 0.1)
			end)
			local FX2 = folder
			task.delay(6.5, function()
				if FX2 and FX2.Parent then
					able({
						FX = FX2,
						On = false
					})
				end
			end)
			local v10 = quickWeld({
				FX = blastClutch.Bol,
				Maid = object._maid,
				P = part2,
				C0 = CFrame.new(0, 0.5, 0)
			})
			v10:ScaleTo(0.1)
			TweenService:Create(v10.PrimaryPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Size = createVector(0, 0, 0)
			}):Play()
			local v11 = object._maid:give(Instance.new("Highlight"))
			v11.FillTransparency = 1
			v11.OutlineTransparency = 1
			v11.Parent = v10.PrimaryPart
			game.Debris:AddItem(v10, 0.1)
		end

		local folder = quickFX({
			FX = blastClutch.SpeedLinesSmol,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		folder:ScaleTo(1)
		lifeScale({
			FX = folder,
			Scale = 0.6
		})
		able({
			FX = folder,
			On = true
		})

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Rate *= 5
			end
		end

		task.wait(0.15)
		local FX3 = quickFX({
			FX = blastClutch.charage,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(0, 0, 0)
		})
		FX3:ScaleTo(0.3)
		lifeScale({
			FX = FX3,
			Scale = 1
		})
		playAttachment(FX3)
		local FX4 = quickFX({
			FX = blastClutch.Uhm,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(0, 0, 0)
		})
		FX4:ScaleTo(1)
		lifeScale({
			FX = FX4,
			Scale = 1
		})
		playAttachment(FX4)
		local clone = blastClutch.Ring:Clone()
		clone:ScaleTo(1.4)
		playMesh({
			Model = clone,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -1.9, 0),
			Info = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
		})

		for _, v6 in pairs({ char["Right Arm"], char["Left Arm"] }) do
			local FX = quickWeld({
				FX = blastClutch.Idle,
				Maid = object._maid,
				P = v6,
				C0 = CFrame.new(0, 1, 0)
			})
			FX:ScaleTo(0.1)
			able({
				FX = FX,
				On = true
			})
			task.delay(0.15, function()
				FX:ScaleTo(0.35)
				dtwait(0.5)
				able({
					FX = FX,
					On = false
				})
				game.Debris:AddItem(FX, 1)
			end)
		end

		dtwait(0.4)
		able({
			FX = folder,
			On = false
		})
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function BlastClutch.PreEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
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

	local function PreEvent()
		local v4 = 0.6 * data.Scale
		local folder = quickFX({
			FX = blastClutch.Pre,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1, 0) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
		})
		folder:ScaleTo(v4)
		playAttachment(folder)

		if v4 > 2 then
			local v5 = quickFX({
				FX = blastClutch.Pre,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1, 0) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
			})
			v5:ScaleTo(0.6)
			playAttachment(v5)
		end

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.LockedToPart = true
			end
		end

		task.spawn(function()
			task.wait(0.15)
			task.spawn(function()
				for _ = 1, 10 do
					local parent = object._maid:give(blastClutch.meshes.Sphere2:Clone())
					parent.CFrame = humanoidRootPart.CFrame
					parent.Color = Color3.new(0.596078, 0.878431, 1)
					parent.Material = Enum.Material.Glass
					parent.Size = createVector(10, 10, 10)
					parent.Parent = EFP
					local v6 = object._maid:give(Instance.new("Highlight"))
					v6.FillTransparency = 1
					v6.OutlineTransparency = 1
					v6.Parent = parent
					parent.Transparency = 5
					game.Debris:AddItem(parent, 0.15)
					playTween(parent, {
						EasingStyle = "Sine",
						Time = 0.15,
						Goal = {
							Size = createVector(100, 100, 100)
						}
					})
					playTween(parent, {
						EasingStyle = "Sine",
						Time = 0.15,
						Goal = {
							Transparency = 1
						}
					})
					dtwait(0.01)
				end
			end)
		end)
		task.spawn(function()
			if game.Players.LocalPlayer.Character == char then
				local v5 = quickFX({
					FX = blastClutch.Pre,
					Maid = object._maid,
					Anchor = CFrame.new(camera.CFrame.Position, humanoidRootPart.Position) * CFrame.new(0, 0, -10)
				})
				v5:ScaleTo(0.6)
				playAttachment(v5)
				local lastTime = tick()

				while tick() - lastTime < 1.2 do
					v5:PivotTo(CFrame.new(camera.CFrame.Position, humanoidRootPart.Position) * CFrame.new(0, 0, -10))
					local RunService = game:GetService("RunService")
					RunService.RenderStepped:Wait()
				end
			end
		end)
	end

	task.spawn(PreEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function BlastClutch.BlastClutch(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
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

	local function BlastClutch2()
		local scale = data.Scale
		local v4 = 2 * scale
		local cFrame = humanoidRootPart.CFrame
		local position = cFrame.Position
		task.spawn(function()
			for _, child in pairs(char:GetChildren()) do
				if not child:GetAttribute("Balls") then
					continue
				end

				for _, part in pairs(child:GetChildren()) do
					if part:IsA("BasePart") and part ~= child.PrimaryPart then
						TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end
				end

				game.Debris:AddItem(child, 0.2)
			end

			local _ = 45 * scale
			local position2 = position - Vector3.new(0, humanoidRootPart.Size.Y * 1.5, 0)
			local clone = blastClutch.meshes.Crack:Clone()
			clone.Size = createVector(0.099, 5, 5)
			clone.CFrame = CFrame.new(position2) * CFrame.Angles(0, math.rad((math.random(0, 360))), 1.5707963267948966)
			clone.Parent = EFP
			game.Debris:AddItem(clone, 0.15)
			playTween(clone, {
				EasingStyle = "EntranceExpressive",
				Time = 0.15,
				Goal = {
					Size = createVector(0.099, 70, 70) * scale
				}
			})
			playTween(clone, {
				EasingStyle = "EntranceExpressive",
				Time = 0.15,
				Goal = {
					Transparency = 1
				}
			})
			local clone2 = blastClutch.meshes.CrackGlass:Clone()
			clone2.Size = createVector(0.099, 5, 5) * scale
			clone2.CFrame = CFrame.new(position2) * CFrame.Angles(
				0,
				math.rad((math.random(0, 360))),
				1.5707963267948966
			)
			clone2.Parent = EFP
			game.Debris:AddItem(clone2, 0.15)
			playTween(clone2, {
				EasingStyle = "EntranceExpressive",
				Time = 0.15,
				Goal = {
					Size = createVector(0.099, 75, 75) * scale
				}
			})
			playTween(clone2, {
				EasingStyle = "EntranceExpressive",
				Time = 0.15,
				Goal = {
					Transparency = 1
				}
			})
			local clone3 = blastClutch.meshes.Ring:Clone()
			clone3.CFrame = CFrame.new(position2)
			clone3.Size = createVector(5, 0.4, 5) * scale
			clone3.Position += createVector(0, 10, 0) * scale
			clone3.Parent = EFP
			game.Debris:AddItem(clone3, 0.15)
			playTween(clone3, {
				EasingStyle = "EntranceExpressive",
				Time = 0.15,
				Goal = {
					Size = createVector(75, 0.8, 75) * scale,
					CFrame = CFrame.new(position2)
				}
			})
			local clone4 = blastClutch.meshes.Ring:Clone()
			clone4.CFrame = CFrame.new(position2)
			clone4.Color = Color3.fromRGB(110, 153, 202)
			clone4.Size = createVector(5, 5, 5) * scale
			clone4.Position += createVector(0, 10, 0) * scale
			clone4.Parent = EFP
			game.Debris:AddItem(clone4, 0.15)
			playTween(clone4, {
				EasingStyle = "Sine",
				Time = 0.15,
				Goal = {
					Size = createVector(120, 15, 120) * scale,
					CFrame = CFrame.new(position2)
				}
			})
			local clone5 = blastClutch.meshes.WindVer2:Clone()
			clone5.CFrame = CFrame.new(position2)
			clone5.Size = createVector(60, 5, 60) * scale
			clone5.Position += createVector(0, 50, 0) * scale
			clone5.Parent = EFP
			game.Debris:AddItem(clone5, 0.15)
			playTween(clone5, {
				EasingStyle = "EntranceExpressive",
				Time = 0.15,
				Goal = {
					Size = createVector(100, 20, 100) * scale,
					CFrame = CFrame.new(position2) * CFrame.Angles(0, 3.141592653589793, 0)
				}
			})
			local clone6 = blastClutch.meshes.Ring:Clone()
			clone6.CFrame = CFrame.new(position2)
			clone6.Size = createVector(5, 0.4, 5) * scale
			clone6.Parent = EFP
			game.Debris:AddItem(clone6, 0.15)
			playTween(clone6, {
				EasingStyle = "EntranceExpressive",
				Time = 0.15,
				Goal = {
					Size = createVector(100, 0.8, 100) * scale,
					Position = clone3.Position + createVector(0, 20, 0) * scale
				}
			})
			playTween(clone6, {
				EasingStyle = "EntranceExpressive",
				Time = 0.15,
				Goal = {
					Transparency = 1
				}
			})
			local clone7 = blastClutch.meshes.Sphere:Clone()
			clone7.CFrame = CFrame.new(position2)
			clone7.Size = createVector(20, 20, 20) * scale
			clone7.Parent = EFP
			game.Debris:AddItem(clone7, 0.1)
			playTween(clone7, {
				EasingStyle = "EntranceExpressive",
				Time = 0.1,
				Goal = {
					Size = createVector(100, 100, 100) * scale
				}
			})
			local clone8 = blastClutch.meshes.Sphere2:Clone()
			clone8.CFrame = CFrame.new(position2)
			clone8.Color = Color3.new(0.596078, 0.878431, 1)
			clone8.Size = createVector(10, 10, 10) * scale
			clone8.Parent = EFP
			game.Debris:AddItem(clone8, 0.15)
			playTween(clone8, {
				EasingStyle = "Sine",
				Time = 0.15,
				Goal = {
					Size = createVector(100, 100, 100) * scale
				}
			})
			playTween(clone8, {
				EasingStyle = "Sine",
				Time = 0.15,
				Goal = {
					Transparency = 1
				}
			})
			local _ = { 4 * scale, 5 * scale }
			local _ = 3 * scale
			local _ = 30 * scale
			local clone9 = blastClutch.meshes.Wind:Clone()
			clone9.Size = createVector(15, 15, 8) * scale
			clone9.Position = position2
			clone9.Parent = EFP
			game.Debris:AddItem(clone9, 0.1)
			playTween(clone9, {
				EasingStyle = "EntranceExpressive",
				Time = 0.1,
				Goal = {
					Size = createVector(60, 60, 40) * scale,
					CFrame = clone9.CFrame * CFrame.new(0, 0, 20 * scale) * CFrame.Angles(0, 0, 3.141592653589793)
				}
			})
			playTween(clone9, {
				EasingStyle = "EntranceExpressive",
				Time = 0.1,
				Goal = {
					Transparency = 1
				}
			})
			local clone10 = blastClutch.meshes.Wave:Clone()
			clone10.Size = createVector(20, 4, 20) * scale
			clone10.Position = position2 + createVector(0, 10, 0) * scale
			clone10.Parent = EFP
			game.Debris:AddItem(clone10, 0.1)
			playTween(clone10, {
				EasingStyle = "EntranceExpressive",
				Time = 0.1,
				Goal = {
					Size = createVector(70, 8, 70) * scale
				}
			})
			local clone11 = blastClutch.meshes.Wave:Clone()
			clone11.Size = createVector(40, 4, 40) * scale
			clone11.Position = position2 + createVector(0, 10, 0) * scale
			clone11.Parent = EFP
			game.Debris:AddItem(clone11, 0.1)
			playTween(clone11, {
				EasingStyle = "EntranceExpressive",
				Time = 0.1,
				Goal = {
					Size = createVector(100, 15, 100) * scale
				}
			})
		end)

		for _ = 1, 15 * scale do
			local time = random:NextNumber(0.05, 0.07) * 2
			local clone = blastClutch.ShardSphere:Clone()

			if math.random(1, 2) == 1 then
				clone.Color = Color3.new(0.521569, 0.831373, 1)
			else
				clone.Color = Color3.new(1, 1, 1)
			end

			game.Debris:AddItem(clone, time)
			local number = random:NextNumber(-20 * v4, 20 * v4)
			local number2 = random:NextNumber(-20 * v4, 20 * v4)
			local v6 = cFrame * CFrame.new(number, math.random(90, 200), number2)
			clone.CFrame = CFrame.new(
				cFrame * CFrame.new(number, math.random(-20, 0) * scale, number2).Position,
				v6.Position
			) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = EFP
			local number3 = random:NextNumber(1, 3)
			clone.Mesh.Scale = Vector3.new(number3, math.random(25, 35), number3) * 1.4 * scale
			playTween(clone, {
				EasingStyle = "Sine",
				Time = time,
				Goal = {
					Position = v6.Position
				}
			})
			playTween(clone.Mesh, {
				EasingStyle = "Sine",
				Time = time,
				Goal = {
					Scale = Vector3.new(0, math.random(30, 40) * 1.4 * scale, 0)
				}
			})
		end

		local v5 = cFrame * CFrame.new(0, 0, -5)

		for _ = 0, math.random(10, 15) do
			local lookVector = fn(v5.Position, v5 * CFrame.new(0, 0, 15 * scale).Position, 15, 75)
			local v7 = math.random(40, 60)
			local cframe = CFrame.new(v5.Position + lookVector * v7, lookVector)
			local clone = blastClutch.ShardSphere:Clone()
			clone.Mesh.Scale *= 5 * scale
			clone.Color = Color3.new(1, 1, 1)
			clone.CFrame = CFrame.new(v5.Position, cframe.Position) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone.Parent = EFP
			local time = math.random(1, 3) / 15
			game.Debris:AddItem(clone, time)
			playTween(clone.Mesh, {
				EasingStyle = "EntranceExpressive",
				Time = time,
				Goal = {
					Scale = Vector3.new(0, clone.Mesh.Scale.Y, 0)
				}
			})
			playTween(clone, {
				EasingStyle = "EntranceExpressive",
				Time = time,
				Goal = {
					CFrame = CFrame.new(cframe.Position, v5.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
				}
			})
		end

		local v6 = quickFX({
			FX = blastClutch.Bol,
			Maid = object._maid,
			Anchor = cFrame
		})
		v6:ScaleTo(1.3)
		TweenService:Create(v6.PrimaryPart, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Size = createVector(0, 0, 0)
		}):Play()
		local v7 = object._maid:give(Instance.new("Highlight"))
		v7.FillTransparency = 1
		v7.OutlineTransparency = 1
		v7.Parent = v6.PrimaryPart
		game.Debris:AddItem(v6, 0.15)
		local v8 = quickFX({
			FX = blastClutch.ParticlePart,
			Maid = object._maid,
			Anchor = cFrame
		})
		v8:ScaleTo(6 * scale)
		playAttachment(v8)
		task.spawn(function()
			local folder = quickFX({
				FX = blastClutch.pls,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, 10 * scale, 0)
			})
			folder:ScaleTo(0.1 * scale)
			TweenService:Create(folder.PrimaryPart, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				CFrame = folder:GetPivot() * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
			local v9 = object._maid:give(Instance.new("NumberValue"))
			object._maid:giveTask(v9.Changed:Connect(function()
				folder:ScaleTo(v9.Value)
			end))
			v9.Value = folder:GetScale()
			TweenService:Create(v9, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Value = 1.8 * scale
			}):Play()

			for _, beam in pairs(folder:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				playTween(beam, {
					Time = 1,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				})
				game.Debris:AddItem(beam, 1)
			end
		end)
		task.spawn(function()
			local folder = quickFX({
				FX = blastClutch.TornadoClouds,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, 1, 0)
			})
			folder:ScaleTo(0.1 * scale)
			local v9 = object._maid:give(Instance.new("NumberValue"))
			object._maid:giveTask(v9.Changed:Connect(function()
				folder:ScaleTo(v9.Value)
			end))
			v9.Value = folder:GetScale()
			TweenService:Create(v9, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
				Value = 6 * scale
			}):Play()

			for _, beam in pairs(folder:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				playTween(beam, {
					Time = 0.6,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				})
				game.Debris:AddItem(beam, 0.6)
			end
		end)
		local FX = quickFX({
			FX = blastClutch.crack,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
		})
		FX:ScaleTo(3.5 * scale)
		lifeScale({
			FX = FX,
			Scale = 0.2
		})
		playAttachment(FX)
		local FX2 = quickFX({
			FX = blastClutch.Good,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(0, 0, 0)
		})
		FX2:ScaleTo(3.5 * scale)
		lifeScale({
			FX = FX2,
			Scale = 1
		})
		playAttachment(FX2)
		local quake = FX.Flipbook.Quake
		quake.Decal.Transparency = 0.98
		task.spawn(function()
			fn2(quake, v, TweenInfo.new(0.01, Enum.EasingStyle.Sine, Enum.EasingDirection.In), nil)
		end)
		quake.Mesh.Scale *= 0.5
		local quake2 = FX.Flipbook.Quake2
		task.spawn(function()
			fn2(quake2, v2, TweenInfo.new(0.01, Enum.EasingStyle.Sine, Enum.EasingDirection.In), nil)
		end)
		TweenService:Create(quake.Decal, TweenInfo.new(4, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		task.delay(1.5, function()
			TweenService:Create(quake2.Decal, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
		end)
		dtwait(0.1)
		local FX3 = quickFX({
			FX = blastClutch.GroundBurst,
			Maid = object._maid,
			Anchor = cFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.4, 0)
		})
		lifeScale({
			FX = FX3,
			Scale = 1 * scale
		})
		FX3:ScaleTo(0.6 * scale)
		playAttachment(FX3)
	end

	task.spawn(BlastClutch2)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return BlastClutch