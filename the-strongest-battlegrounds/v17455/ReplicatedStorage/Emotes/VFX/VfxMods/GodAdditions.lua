local createVector = vector.create
local GodAdditions = {}
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
local quickWeld = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local _ = libraryNew.EditableMeshShader
local vfx = script.vfx
require(game.ReplicatedStorage.Utility)
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local camera = game.Workspace.Camera
local BurstMod = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.BurstMod)
require(game.ReplicatedStorage.Resources.LightningModule)

function GodAdditions.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim

	if game.Players.LocalPlayer.Character ~= data.Char then
		local _ = game.Players.LocalPlayer.Character == data.Victim
	end

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
		local folder = quickFX({
			FX = vfx.Doom,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, 0)
		})
		local lastTime = tick()
		local v2 = object._maid:give(Instance.new("NumberValue"))
		local v3 = {}

		for _, objectValue in pairs(folder:GetDescendants()) do
			if objectValue:IsA("ObjectValue") then
				v3[objectValue] = {
					OG = objectValue:GetAttribute("MaxSize")
				}
			end
		end

		object._maid:giveTask(v2.Changed:Connect(function()
			for k, v4 in pairs(v3) do
				k:SetAttribute("MaxSize", NumberRange.new(v4.OG.Max * v2.Value))
			end
		end))
		v2.Value = 0.2
		TweenService:Create(v2, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
			Value = 3
		}):Play()
		playAttachment(folder)
		libraryNew.MeshEmit.Emit(folder)

		while tick() - lastTime < 0.2 do
			folder:PivotTo(CFrame.new(char.Torso.Position - createVector(0, 3, 0)))
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
		end

		task.delay(0.05, function() end)
		task.wait(0.15)
		local folder2 = quickFX({
			FX = vfx.Hmm,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 1, 0)
		})

		for _, objectValue in pairs(folder2:GetDescendants()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			objectValue:SetAttribute("EmitDelay", objectValue:GetAttribute("EmitDelay") + 0.085)
			objectValue:SetAttribute("EmitDuration", objectValue:GetAttribute("EmitDuration") + 0.085)
		end

		local v4 = object._maid:give(Instance.new("NumberValue"))
		local v5 = {}

		for _, objectValue in pairs(folder2:GetDescendants()) do
			if objectValue:IsA("ObjectValue") then
				v5[objectValue] = {
					OG = objectValue:GetAttribute("MaxSize")
				}
			end
		end

		object._maid:giveTask(v4.Changed:Connect(function()
			for k, v6 in pairs(v5) do
				k:SetAttribute("MaxSize", NumberRange.new(v6.OG.Max * v4.Value))
			end
		end))
		v4.Value = 0.1
		TweenService:Create(v4, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 3
		}):Play()
		playAttachment(folder2)
		libraryNew.MeshEmit.Emit(folder2)
		task.wait(0.35)
		local v6 = quickFX({
			FX = vfx.Plume2,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.4, -1.5)
		})
		playAttachment(v6)
		libraryNew.MeshEmit.Emit(v6)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.FloatEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
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

	local function FloatEvent()
		local folder = quickFX({
			FX = vfx.Float,
			Maid = object._maid,
			Anchor = victim.PrimaryPart.CFrame * CFrame.new(0, 1, 0)
		})
		playAttachment(folder)
		libraryNew.MeshEmit.Emit(folder)
		local v2 = object._maid:give(Instance.new("NumberValue"))
		local v3 = {}

		for _, objectValue in pairs(folder:GetDescendants()) do
			if objectValue:IsA("ObjectValue") then
				v3[objectValue] = {
					OG = objectValue:GetAttribute("MaxSize")
				}
			end
		end

		object._maid:giveTask(v2.Changed:Connect(function()
			for k, v4 in pairs(v3) do
				k:SetAttribute("MaxSize", NumberRange.new(v4.OG.Max * v2.Value))
			end
		end))
		v2.Value = 1
		TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 2
		}):Play()
		task.wait(0.4)
		local v4 = quickFX({
			FX = vfx.On,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 1, -6)
		})
		libraryNew.MeshEmit.Emit(v4)
		local FX = quickFX({
			FX = vfx.Launch,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 1, -6) * CFrame.Angles(1.5707963267948966, 0, 0)
		})
		lifeScale({
			FX = FX,
			Scale = 2
		})
		playAttachment(FX)
		libraryNew.MeshEmit.Emit(FX)
		local lastTime = tick()
		local position = humanoidRootPart.Position

		while tick() - lastTime < 0.7 do
			v4:PivotTo(CFrame.new(victim.Torso.Position, position) * CFrame.new(0, -3.5, 2) * CFrame.Angles(
				-1.3962634015954636,
				0,
				0
			))
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
		end
	end

	task.spawn(FloatEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.BounceEvent(p)
	local data = p.Data
	local char = data.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
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

	local function BounceEvent()
		local raycastResult = game.Workspace:Raycast(victim.PrimaryPart.Position, createVector(0, -10, 0))

		if raycastResult then
			local FX = quickFX({
				FX = vfx.Bounce,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position) + createVector(0, 1, 0)
			})
			lifeScale({
				FX = FX,
				Scale = 1
			})
			playAttachment(FX)
		end
	end

	task.spawn(BounceEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.RunEvent(p)
	local char = p.Data.Char
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

	local function RunEvent()
		local FX = quickFX({
			FX = vfx.Rush,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 1, 0)
		})
		playAttachment(FX)
		libraryNew.MeshEmit.Emit(FX)
		local FX2 = quickFX({
			FX = vfx.Step,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		lifeScale({
			FX = FX2,
			Scale = 0.5
		})
		playAttachment(FX2)
		libraryNew.MeshEmit.Emit(FX2)

		local function Crater() end

		task.spawn(function()
			task.wait(0.3)
			local FX3 = quickFX({
				FX = vfx.Step,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})
			lifeScale({
				FX = FX3,
				Scale = 0.5
			})
			playAttachment(FX3)
			libraryNew.MeshEmit.Emit(FX3)
			task.wait(0.15)
			local FX4 = quickFX({
				FX = vfx.Step,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})
			lifeScale({
				FX = FX4,
				Scale = 0.5
			})
			playAttachment(FX4)
			libraryNew.MeshEmit.Emit(FX4)
		end)
		local lastTime = tick()

		while tick() - lastTime < 15 do
			local _, v4, _ = humanoidRootPart.CFrame:ToOrientation()
			FX:PivotTo(CFrame.new(char.Torso.Position) * CFrame.Angles(0, v4, 0) * CFrame.new(0, 0, -4) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			))
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
		end

		able({
			FX = FX,
			On = false
		})
	end

	task.spawn(RunEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.JumpEvent(p)
	local char = p.Data.Char
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

	local function JumpEvent()
		local v2 = quickFX({
			FX = vfx.Jump,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 1, 0)
		})
		playAttachment(v2)
		libraryNew.MeshEmit.Emit(v2)
	end

	task.spawn(JumpEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.SwirlEvent(p)
	local char = p.Data.Char
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

	local function SwirlEvent()
		local function NormalSwirl()
			game:GetService("TweenService")

			local function createLiveColorValue(list, duration, p2)
				local color3Value = Instance.new("Color3Value")
				color3Value.Value = list[1]
				task.spawn(function()
					local lastTime = os.clock()
					local v2 = 1

					while os.clock() - lastTime < p2 do
						v2 = v2 % #list + 1
						local v3 = list[v2]
						local tween = TweenService:Create(
							color3Value,
							TweenInfo.new(duration, Enum.EasingStyle.Linear),
							{
								Value = v3
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end

					color3Value:Destroy()
					print("Color loop finished.")
				end)
				return color3Value
			end

			local v2 = {}

			for _, v3 in pairs({ char["Right Arm"], char["Left Arm"] }) do
				local parent = object._maid:give(Instance.new("Model"))
				local v5 = object._maid:give(Instance.new("Highlight"))
				v5.DepthMode = Enum.HighlightDepthMode.Occluded
				v5.FillTransparency = 0
				v5.FillColor = Color3.new(0, 0, 0)
				v5.OutlineColor = Color3.new(1, 0, 0)
				v5.OutlineTransparency = 0
				v5.Parent = parent
				v2[v3] = parent
				parent.Parent = EFP
			end

			Color3.new(0, 0, 0)
			task.spawn(function()
				task.wait(0.1)
				local lastTime = tick()

				while tick() - lastTime < 2.3 do
					for k, parent in pairs(v2) do
						local v4 = object._maid:give(Instance.new("Part"))
						v4.CFrame = k.CFrame * CFrame.new(0, -1, 0)
						v4.Material = Enum.Material.Neon
						v4.Anchored = true
						v4.Shape = Enum.PartType.Ball
						v4.Parent = EFP
						v4.Color = Color3.new(1, 0, 0)
						local number = random:NextNumber(0.7, 1)
						v4.Parent = parent
						local number2 = random:NextNumber(0.15, 0.2)
						v4.Size = Vector3.new(number, number, number) * 0.01
						TweenService:Create(v4, TweenInfo.new(number2, Enum.EasingStyle.Sine), {
							Size = Vector3.new(number, number, number)
						}):Play()
						task.delay(number2, function()
							local number3 = random:NextNumber(0.6, 0.8)
							TweenService:Create(v4, TweenInfo.new(number3, Enum.EasingStyle.Sine), {
								Size = createVector(0, 0, 0)
							}):Play()
							game.Debris:AddItem(v4, number3)
						end)
					end

					dtwait(0.03)
				end
			end)
		end
	end

	task.spawn(SwirlEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.ZoomEvent(p)
	local char = p.Data.Char
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

	local function ZoomEvent() end

	task.spawn(ZoomEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.StarEvent(p)
	local data = p.Data
	local vfx2 = script.vfx2
	local char = data.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	local v = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
	print(v)
	local sphere = char:FindFirstChild("Sphere")

	if not sphere then
		return
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
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
	local v3 = {}
	local v4 = {
		bind = data.bind
	}
	local parentChangedConnection = nil
	local v5 = false
	parentChangedConnection = v4.bind:GetPropertyChangedSignal("Parent"):Once(function()
		if v4.bind.Parent then
			return
		end

		v5 = true

		for _, v6 in pairs(v3) do
			v6:Destroy()
		end

		Clean() -- equivalent call inferred; original call site unknown
		return parentChangedConnection:Disconnect()
	end)

	if v then
		game.Lighting.ClockTime = 0
	end

	local function StarEvent()
		local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)

		local function Balls()
			task.wait(2.2)

			if data.bind.Parent then
				local clone = game.ReplicatedStorage.Resources:WaitForChild("Adjusted MeshEmitter"):Clone()
				clone.Parent = workspace
				game.Debris:AddItem(clone, 3)
				table.insert(v3, clone)
				local v6 = MoonEmitter.new(clone)
				local screenGui = Instance.new("ScreenGui")
				table.insert(v3, screenGui)
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 1, 0)
				frame.Parent = screenGui
				screenGui.Parent = game.Players.LocalPlayer.PlayerGui
				frame.BackgroundTransparency = 1
				frame.Position = UDim2.new(0, 0, 0.3, 0)
				local textLabel = Instance.new("TextLabel")
				textLabel.Font = Enum.Font.SourceSansSemibold
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.TextTransparency = 1
				textLabel.Position = UDim2.new(0, 0, 0, 0)
				textLabel.Parent = frame
				game.Debris:AddItem(screenGui, 5)
				v6:AssignExternal("Subtitles", textLabel)
				v6:Play()
				v6:SetTime(2.3)
				task.wait(4.3)

				if data.bind.Parent then
					local clone2 = game.ReplicatedStorage.Resources:WaitForChild("EndONly MeshEmitter"):Clone()
					clone2.Parent = workspace
					game.Debris:AddItem(clone2, 3)
					local v7 = MoonEmitter.new(clone2)
					table.insert(v3, clone2)
					local screenGui2 = Instance.new("ScreenGui")
					table.insert(v3, screenGui2)
					local frame2 = Instance.new("Frame")
					frame2.Size = UDim2.new(1, 0, 1, 0)
					frame2.Parent = screenGui2
					screenGui2.Parent = game.Players.LocalPlayer.PlayerGui
					frame2.BackgroundTransparency = 1
					frame2.Position = UDim2.new(0, 0, 0.3, 0)
					local textLabel2 = Instance.new("TextLabel")
					textLabel2.Font = Enum.Font.SourceSansSemibold
					textLabel2.Size = UDim2.new(1, 0, 1, 0)
					textLabel2.BackgroundTransparency = 1
					textLabel2.TextTransparency = 1
					textLabel2.Position = UDim2.new(0, 0, 0, 0)
					textLabel2.Parent = frame2
					game.Debris:AddItem(screenGui2, 5)
					v7:AssignExternal("Subtitles", textLabel2)
					v7:Play()
					v7:SetTime(0.2)
				elseif screenGui.Parent then
					screenGui:Destroy()
				end
			else
				Clean() -- equivalent call inferred; original call site unknown
			end
		end

		if not data.bind.Parent or v5 then
			return
		end

		task.spawn(Balls)

		if not data.bind.Parent or v5 then
			return
		end

		local char2 = object._maid:give(script.TemplateR6:Clone())
		local humanoidDescriptionFromUserIdAsync = nil
		local userId = game.Players:GetPlayerFromCharacter(char).UserId
		local _, result = pcall(function()
			humanoidDescriptionFromUserIdAsync = game.Players:GetHumanoidDescriptionFromUserIdAsync(userId)
		end)

		if result then
			humanoidDescriptionFromUserIdAsync = game.Players:GetHumanoidDescriptionFromUserIdAsync(747447782)
		end

		char2.Parent = game.Workspace.Thrown
		table.insert(v3, char2)
		local value = sphere.Value
		local anchor = value.CFrame * CFrame.new(0, 0, 20)
		char2.Humanoid:ApplyDescriptionAsync(humanoidDescriptionFromUserIdAsync)
		char2:PivotTo(value.CFrame * char2:GetAttribute("Offset"):Inverse())
		char2.Humanoid:LoadAnimation(script.Balls):Play()
		local v8 = {}
		local v9 = {
			Color3.fromRGB(255, 34, 34),
			Color3.fromRGB(0, 17, 255),
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(255, 247, 28),
			Color3.fromRGB(33, 255, 40),
			Color3.fromRGB(247, 0, 255),
			(Color3.fromRGB(255, 157, 0))
		}
		task.spawn(function()
			for i = 1, 7 do
				if not data.bind.Parent then
					break
				end

				local folder = object._maid:give(vfx2.Trail:Clone())
				table.insert(v3, folder)
				folder.Parent = EFP
				game.Debris:AddItem(folder, 4)
				local distance = object._maid:give(Instance.new("NumberValue"))
				distance.Value = 100
				table.insert(v3, distance)
				TweenService:Create(distance, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Value = 14
				}):Play()
				task.delay(0.5, function()
					TweenService:Create(distance, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Value = 17
					}):Play()
				end)

				if not data.bind.Parent or v5 then
					break
				end

				local trailScale = object._maid:give(Instance.new("NumberValue"))
				local lifeScale2 = object._maid:give(Instance.new("NumberValue"))
				table.insert(v3, trailScale)
				table.insert(v3, lifeScale2)
				local lifetimesByEffect = {}

				for _, effect in pairs(folder:GetDescendants()) do
					if effect:isA("Trail") then
						lifetimesByEffect[effect] = effect.Lifetime
					end

					if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
						effect.Color = ColorSequence.new(v9[i])
					end
				end

				object._maid:giveTask(lifeScale2.Changed:Connect(function()
					for k, v17 in pairs(lifetimesByEffect) do
						k.Lifetime = v17 * lifeScale2.Value
					end
				end))
				object._maid:giveTask(trailScale.Changed:Connect(function()
					folder:ScaleTo(trailScale.Value)
				end))

				if not data.bind.Parent or v5 then
					break
				end

				trailScale.Value = 0.1
				lifeScale2.Value = 0.1
				TweenService:Create(trailScale, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Value = 0.3
				}):Play()
				v8[folder] = {
					Angle = 0.8975979010256552 * i,
					Distance = distance,
					TrailScale = trailScale,
					LifeScale = lifeScale2,
					Count = i
				}

				for _, emitter in pairs(folder.Trail.Emit:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end
		end)

		if not data.bind.Parent or v5 then
			return
		end

		local v10 = object._maid:give(Instance.new("CFrameValue"))
		local v11 = object._maid:give(Instance.new("NumberValue"))
		local v12 = object._maid:give(Instance.new("NumberValue"))
		v12.Value = 0.5
		table.insert(v3, v10)
		table.insert(v3, v11)
		table.insert(v3, v12)

		if not data.bind.Parent or v5 then
			return
		end

		TweenService:Create(v10, TweenInfo.new(3, Enum.EasingStyle.Sine), {
			Value = CFrame.Angles(0, 0, 1.0471975511965976)
		}):Play()
		task.delay(1.5, function()
			if not data.bind.Parent or v5 then
				return
			end

			v11.Value = 15
			TweenService:Create(v10, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Value = CFrame.Angles(1.5707963267948966, 0, 0)
			}):Play()

			for _, v13 in pairs(v8) do
				TweenService:Create(v13.TrailScale, TweenInfo.new(3, Enum.EasingStyle.Bounce), {
					Value = 0.4
				}):Play()
				TweenService:Create(v13.Distance, TweenInfo.new(3, Enum.EasingStyle.Sine), {
					Value = 10
				}):Play()
			end

			local tween = TweenService:Create(v11, TweenInfo.new(3, Enum.EasingStyle.Quad), {
				Value = 16
			})
			tween:Play()
			local FX = quickFX({
				FX = vfx2.Connect,
				Maid = object._maid,
				Anchor = anchor * CFrame.new(0, 0, 25)
			})
			able({
				FX = FX,
				On = true
			})
			table.insert(v3, FX)
			task.wait(1.2)

			if not data.bind.Parent or v5 then
				return
			end

			tween:Pause()
			v11.Value = 0

			for _, v14 in pairs(v8) do
				v14.TrailScale.Value = 0.1
			end

			for k, _ in pairs(v8) do
				for _, emitter in pairs(k.Trail.Emit:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			task.wait(0.4)

			if not data.bind.Parent or v5 then
				return
			end

			for _, v14 in pairs(v8) do
				v14.TrailScale.Value = 0.1
				v14.LifeScale.Value = 0.1
			end

			v12.Value = 1

			for k, _ in pairs(v8) do
				for _, emitter in pairs(k.Trail.Emit:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			for _, v14 in pairs(v8) do
				TweenService:Create(v14.Distance, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Value = -0.5
				}):Play()
			end

			task.wait(0.06)

			if not data.bind.Parent or v5 then
				return
			end

			local FX2 = quickFX({
				FX = vfx2.Connect,
				Maid = object._maid,
				Anchor = anchor
			})
			raiseZIndex({
				FX = FX2,
				Count = 11
			})
			playAttachment(FX2)
			table.insert(v3, FX2)

			for k, _ in pairs(v8) do
				k:Destroy()
			end

			task.delay(0.15, function()
				char2["Right Arm"].Transparency = 1
			end)
		end)
		v11.Value = 10
		TweenService:Create(v11, TweenInfo.new(3, Enum.EasingStyle.Quad), {
			Value = 6
		}):Play()
		local total = 0
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 5 do
				total += v11.Value

				if not data.bind.Parent or v5 then
					break
				end

				for k, v13 in pairs(v8) do
					if tick() - lastTime > (v13.Count - 1) * 0.25 then
						k:PivotTo(k:GetPivot():Lerp(
							anchor * v10.Value * CFrame.Angles(0, v13.Angle + math.rad(total), 0) * CFrame.new(
								0,
								0,
								v13.Distance.Value
							),
							v12.Value
						))

						if v13.Ran then
							v13.Ran = nil
						end
					elseif not v13.Ran then
						v13.Ran = true
						k:PivotTo(anchor * v10.Value * CFrame.Angles(0, v13.Angle + math.rad(total), 0) * CFrame.new(
							0,
							0,
							v13.Distance.Value * 125
						))
					end
				end

				dtwait(0.01)
			end
		end)
		task.delay(2.45, function()
			if not data.bind.Parent then
				return
			end

			GodAdditions.HandEvent({
				Char = char2,
				OG = char,
				bind = data.bind
			})
		end)
	end

	task.spawn(StarEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.HandEvent(data)
	local char = data.Char
	local OG = data.OG
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	local vfx2 = script.vfx2
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
	local sphere = OG:FindFirstChild("Sphere")

	if not sphere then
		return
	end

	local function HandEvent()
		local value = sphere.Value
		local anchor = value.CFrame * CFrame.new(0, 0, 37)
		local v3 = object._maid:give(Instance.new("Highlight"))
		v3.FillColor = Color3.new(0, 0, 0)
		v3.FillTransparency = 0
		v3.OutlineTransparency = 1
		v3.DepthMode = Enum.HighlightDepthMode.Occluded
		v3.Parent = char
		TweenService:Create(v3, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
			FillTransparency = 1
		}):Play()
		local v4 = quickFX({
			FX = vfx2.Hand,
			Maid = object._maid,
			Anchor = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
		})
		playAttachment(v4)
		local FX = object._maid:give(vfx2.ArmThing.Attachment:Clone())
		FX.Parent = char["Right Arm"]
		quickFX({
			FX = vfx2.PRE,
			Maid = object._maid,
			Anchor = camera.CFrame * CFrame.new(0, 0, 4)
		})
		task.delay(0.2, function()
			if not data.bind.Parent then
				return
			end

			playAttachment((quickFX({
				FX = vfx2.light,
				Maid = object._maid,
				Anchor = value.CFrame * CFrame.new(0, -0.4, 35)
			})))
		end)
		task.delay(0.4, function()
			if not data.bind.Parent then
				return
			end

			playAttachment((quickFX({
				FX = vfx2.spin,
				Maid = object._maid,
				Anchor = anchor
			})))
			playAttachment((quickFX({
				FX = vfx2.PRE,
				Maid = object._maid,
				Anchor = anchor
			})))
		end)
		local lastTime = tick()

		while tick() - lastTime < 1.5 do
			if data.bind.Parent then
				v4:PivotTo(CFrame.new(char["Right Arm"].Position) * CFrame.Angles(-1.5707963267948966, 0, 0))
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			else
				Clean() -- equivalent call inferred; original call site unknown

				if not v3.Parent then
					break
				end

				v3:Destroy()
				break
			end
		end

		able({
			FX = FX,
			On = false
		})
		v4:Destroy()
	end

	task.spawn(HandEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.AuraEvent(p)
	local data = p.Data
	local char = data.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid

	if (game.Players.LocalPlayer.Character == char or game.Players.LocalPlayer.Character == data.Victim) and data.Ignore then
		return
	end

	local _ = script.vfx2
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

	task.delay(35, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function AuraEvent()
		local _ = script.vfx
		local _ = data.Cam
		local folder = object._maid:give(script.Aura:Clone())
		local v2 = object._maid:give(Instance.new("Highlight"))
		v2.DepthMode = Enum.HighlightDepthMode.Occluded
		v2.FillTransparency = 1
		v2.OutlineTransparency = 0
		v2.OutlineColor = Color3.fromRGB(247, 255, 153)
		v2.Parent = char

		for _, part in pairs(folder:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local humanoidRootPart = char:FindFirstChild(part.Name)

			if part.Name == "Aura" then
				humanoidRootPart = char.HumanoidRootPart
			end

			if not humanoidRootPart then
				continue
			end

			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = humanoidRootPart
			weld.Parent = part
		end

		folder.Parent = char
		task.delay(12, function()
			TweenService:Create(v2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				OutlineTransparency = 1,
				FillTransparency = 1
			}):Play()

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.Transparency < 1 then
					TweenService:Create(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("Beam") then
					playTween(descendant, {
						Time = 0.5,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(1, 1)
							})
						}
					})
					game.Debris:AddItem(descendant, 0.5)
				end
			end
		end)
	end

	task.spawn(AuraEvent)
	wait(30)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.CamEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local v = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
	local _ = script.vfx2
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	task.delay(25, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function CamEvent()
		local vfx2 = script.vfx
		local cam = data.Cam
		local v3 = {}
		local v4 = {
			bind = data.bind
		}
		local parentChangedConnection = nil
		local flag = false
		parentChangedConnection = v4.bind:GetPropertyChangedSignal("Parent"):Once(function()
			if v4.bind.Parent then
				return
			end

			flag = true

			for _, v5 in pairs(v3) do
				v5:Destroy()
			end

			return parentChangedConnection:Disconnect()
		end)

		if flag then
			return
		end

		local v5 = object._maid:give(Instance.new("BloomEffect"))
		v5.Intensity = 4
		v5.Size = 56
		v5.Threshold = 2
		v5.Parent = game.Lighting
		table.insert(v3, v5)

		if flag then
			return
		end

		local v6 = object._maid:give(vfx2.BackgroundStage4MeshWide:Clone())
		v6:PivotTo(cam:GetPivot() * v6:GetAttribute("Offset"):Inverse())
		v6.Parent = EFP
		v6.PointLight.Range = 25
		table.insert(v3, v6)
		local v7 = cam:GetPivot() * CFrame.new(6, 0, 10)

		if flag then
			return
		end

		local clone = vfx2.Moon2:Clone()
		clone:PivotTo(v7 * clone:GetAttribute("Offset"):Inverse())
		clone.Parent = EFP
		table.insert(v3, clone)
		local clone2 = vfx2.Moon:Clone()
		clone2:PivotTo(v7 * clone2:GetAttribute("Offset"):Inverse())
		clone2.Parent = EFP
		table.insert(v3, clone2)
		local cFrame = clone2.Eye.CFrame
		local size = clone2.Eye.Size
		clone2.Eye.CFrame = v7 * CFrame.new(
			-1.61505127,
			0.430894852,
			-23.725811,
			0.655570686,
			0.616835177,
			-0.435593277,
			-0.528605402,
			0.786801994,
			0.318620443,
			0.539261937,
			0.0213787109,
			0.841866672
		):Inverse()
		clone2.Eye.Size = createVector(77.143, 77.143, 0.001)
		local size2 = clone2.Galaxy.Size
		local cFrame2 = clone2.Galaxy.CFrame
		clone2.Galaxy.CFrame = v7 * CFrame.new(
			-0.981170654,
			0.551635742,
			-24.5139351,
			0.842059135,
			-4.65661287e-10,
			-0.53938514,
			-0.0115313306,
			0.999771476,
			-0.0180020947,
			0.539261878,
			0.0213786568,
			0.841866732
		):Inverse()
		clone2.Galaxy.Size = createVector(57.143, 57.143, 0.001)

		if flag then
			return
		end

		local size3 = clone2.SecondMoon.Size
		local _ = clone2.SecondMoon.CFrame
		clone2.SecondMoon.CFrame = v7 * CFrame.new(
			-1.53663635,
			0.930274963,
			-24.6075325,
			0.842059135,
			4.65661287e-10,
			-0.5393852,
			-0.0115313325,
			0.999771476,
			-0.0180020928,
			0.539261937,
			0.0213786587,
			0.841866672
		):Inverse()
		clone2.SecondMoon.Size = createVector(45, 45, 0.001)
		task.wait(0.2)

		if flag then
			return
		end

		TweenService:Create(v6, TweenInfo.new(2.1, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		TweenService:Create(v6.PointLight, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Range = 10
		}):Play()
		TweenService:Create(clone2.Galaxy, TweenInfo.new(2.7, Enum.EasingStyle.Quad), {
			Size = size2,
			CFrame = cFrame2
		}):Play()
		TweenService:Create(clone2.Eye, TweenInfo.new(2.7, Enum.EasingStyle.Quad), {
			Size = size,
			CFrame = cFrame
		}):Play()
		TweenService:Create(clone2.SecondMoon, TweenInfo.new(2.7, Enum.EasingStyle.Quad), {
			Size = size3
		}):Play()
		task.delay(0.9, function()
			if flag then
				return
			end

			TweenService:Create(v6.PointLight, TweenInfo.new(2.1, Enum.EasingStyle.Sine), {
				Range = 10
			}):Play()
		end)
		task.wait(3)

		if flag then
			return
		end

		local clone3

		if v then
			if flag then
				return
			end

			clone3 = script.Sphere1:Clone()
			table.insert(v3, clone3)
			clone3:PivotTo(humanoidRootPart:GetPivot())
			clone3.Size = createVector(30, 30, 30)
			clone3.Transparency = 1
			clone3.Parent = game.Workspace.Thrown
			TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Transparency = 0
			}):Play()
			task.wait(0.55)

			if flag then
				return
			end

			clone2:Destroy()
			clone:Destroy()
			clone3.Transparency = 1
		end

		if v then
			if flag then
				return
			end

			for _, child in pairs(game.Lighting:GetChildren()) do
				if child.Name == "GodCC" then
					child:Destroy()
				end
			end

			game.Lighting.ClockTime = 14.5
		end

		task.wait(3.3)

		if flag then
			return
		end

		if clone3 then
			TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Transparency = 0
			}):Play()
		end

		task.wait(0.55)

		if flag then
			return
		end

		if clone3 then
			TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
		end
	end

	task.spawn(CamEvent)
	wait(20)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.AnotherP(p)
	local moreAdditions = script.MoreAdditions
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
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

	local function AnotherP()
		playAttachment((quickFX({
			FX = moreAdditions.Away,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -1)
		})))
		local folder = quickFX({
			FX = moreAdditions.RootBeams,
			Maid = object._maid,
			Anchor = victim:GetPivot()
		})

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
			beam.TextureSpeed *= 1.5
		end

		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 3 do
				folder:PivotTo(CFrame.new(victim:GetPivot().Position, humanoidRootPart.Position) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				))
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			end
		end)
		task.delay(0.1, function()
			for _, beam in pairs(folder:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				playTween(beam, {
					Time = 0.6,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new(1)
					}
				})
				game.Debris:AddItem(beam, 0.6)
			end

			task.wait(0.35)
			able({
				FX = folder,
				On = false
			})
		end)
	end

	task.spawn(AnotherP)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.Hit1(p)
	local moreAdditions = script.MoreAdditions
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
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

	local function Hit1()
		local FX = quickFX({
			FX = moreAdditions.Hit,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -12)
		})
		lifeScale({
			FX = FX,
			Scale = 0.2
		})
		playAttachment(FX)
		task.wait(0.7)
		local FX2 = quickFX({
			FX = moreAdditions.Hit,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -12)
		})
		lifeScale({
			FX = FX2,
			Scale = 0.2
		})
		playAttachment(FX2)
		task.wait(0.8)
		local FX3 = quickFX({
			FX = moreAdditions.FinalHit,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -12) * CFrame.Angles(-0.6108652381980153, 0, 0)
		})
		lifeScale({
			FX = FX3,
			Scale = 1.5
		})
		playAttachment(FX3)
		local FX4 = object._maid:give(script.vfx.Down:Clone())
		FX4.Parent = EFP
		local _ = humanoidRootPart.CFrame
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 4 do
				FX4:PivotTo(CFrame.new(victim.Torso.Position, humanoidRootPart.Position) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				))
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			end
		end)
		able({
			FX = FX4,
			On = false
		})
		task.delay(0.1, function()
			able({
				FX = FX4,
				On = true
			})
			task.wait(0.2)
			able({
				FX = FX4,
				On = false
			})
		end)
	end

	task.spawn(Hit1)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.LandEvent(p)
	local data = p.Data
	local v = vfx
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { game.Workspace.Map }
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	task.delay(35, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v3 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim

	local function SlamEvent()
		local anchor = data.Anchor
		local clone = v.Ring1:Clone()
		clone:ScaleTo(0.96)
		clone:PivotTo(anchor * CFrame.new(0, 40, 0) * CFrame.Angles(0, 0, 0))
		playMesh({
			Model = clone,
			Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
		})
		local clone2 = v.Spikey:Clone()
		clone2:ScaleTo(0.96)
		clone2:PivotTo(anchor * CFrame.new(0, 45, 0) * CFrame.Angles(0, 0, 0))
		playMesh({
			Model = clone2,
			Info = TweenInfo.new(0.15, Enum.EasingStyle.Sine)
		})
		local clone3 = v.Ring2:Clone()
		clone3:ScaleTo(0.96)
		clone3:PivotTo(anchor * CFrame.new(0, 30, 0) * CFrame.Angles(0, 0, 0))
		playMesh({
			Model = clone3,
			Info = TweenInfo.new(0.4, Enum.EasingStyle.Sine)
		})
		local FX = quickFX({
			FX = v.Impact,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -1.5, 0)
		})
		FX:ScaleTo(FX:GetScale() * 1.2)
		able({
			FX = FX,
			On = false
		})
		playAttachment(FX)
		BurstMod.Spawn({
			origin = anchor.Position,
			amount = 25,
			raycastParams = raycastParams,
			radiusMin = 65,
			radiusMax = 120,
			arcHeightMin = 84,
			arcHeightMax = 192,
			durationMin = 1.2,
			durationMax = 1.9,
			sizeMin = 7.7,
			sizeMax = 12.8,
			templatePart = v.CubeTemplate,
			canCollideInFlight = false,
			canCollideOnLand = true,
			anchorOnLand = true,
			copyFloorAppearance = true,
			randomSpawnOrientation = true,
			spinDuringFlight = true,
			spinSpeedMin = 1,
			spinSpeedMax = 2,
			ghostThroughOnLand = true,
			ghostSecondsMin = 0.35,
			ghostSecondsMax = 0.6,
			onLand = function(FX2, position, _, _)
				FX2.Transparency = 1

				if math.random(1, 2) == 1 then
					local v5 = {
						"rbxassetid://109227602352152",
						"rbxassetid://118068307319834",
						"rbxasset://117747756028841",
						"rbxassetid://72482887095657",
						"rbxassetid://109014520859150",
						"rbxassetid://117658116341223",
						"rbxassetid://82791594163715"
					}
					local sfx = shared.sfx({
						CFrame = CFrame.new(position),
						SoundId = v5[math.random(1, #v5)],
						Volume = math.random(2, 3.5),
						PlaybackSpeed = random:NextNumber(0.9, 1.1)
					})
					sfx:Play("")

					if game.Players.LocalPlayer.Character == data.Char then
						sfx.Parent = workspace
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(
							sfx,
							TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Volume = 0.75
							}
						):Play()
					end
				end

				shared.repfire({
					Effect = "Ground Crater",
					Seed = math.random(1, 2000000000),
					start = position + createVector(0, 5, 0),
					["end"] = createVector(0, -34, 0),
					amount = 0,
					nosound = true,
					nodebris = true,
					sizemult = 1.3,
					size = 1.3
				})

				if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.PrimaryPart and (position - game.Players.LocalPlayer.Character.PrimaryPart.Position).Magnitude <= 350 and math.random(
					1,
					2
				) == 1 then
					shared.repfire({
						Effect = "Camshake",
						Intensity = 2,
						Last = 0.1
					})
				end

				able({
					FX = FX2,
					On = false
				})
				game.Debris:AddItem(FX2, 1)
			end
		})
		local v5 = quickFX({
			FX = v.Plume,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -1.5, -2)
		})
		v5:ScaleTo(1.2)
		playAttachment(v5)
		local folder = quickFX({
			FX = v.Plume,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -1.5, -2)
		})
		folder:ScaleTo(2.4)
		raiseZIndex({
			FX = folder,
			Count = 2
		})
		playAttachment(folder)
		task.delay(0.5, function()
			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						TimeScale = 0.2
					}):Play()
				end
			end
		end)
		local FX3 = quickFX({
			FX = v.CoolWave,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -1.5, 0)
		})
		lifeScale({
			FX = FX3,
			Scale = 2.5
		})
		FX3:ScaleTo(24)
		able({
			FX = FX3,
			On = false
		})
		playAttachment(FX3)
		local clone4 = v.WindDecal1:Clone()
		clone4:ScaleTo(16.8)
		clone4:PivotTo(anchor * CFrame.new(0, -5 * clone4:GetScale(), 0) * CFrame.Angles(3.141592653589793, 0, 0))
		playMesh({
			Model = clone4,
			Info = TweenInfo.new(2, Enum.EasingStyle.Exponential)
		})
		local clone5 = v.Bubble:Clone()
		clone5:ScaleTo(1.56)
		clone5:PivotTo(anchor)
		playMesh({
			Model = clone5,
			Info = TweenInfo.new(3, Enum.EasingStyle.Exponential)
		})
		local folder2 = quickFX({
			FX = v.OutBeams,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -1.5, 0)
		})
		local v7 = object._maid:give(Instance.new("NumberValue"))
		object._maid:giveTask(v7.Changed:Connect(function()
			folder2:PivotTo(folder2:GetPivot() * CFrame.Angles(0, 0.017453292519943295, 0))
			folder2:ScaleTo(v7.Value)
		end))

		for _, beam in pairs(folder2:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.TextureSpeed *= -2
			TweenService:Create(beam, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				TextureSpeed = 0.1
			}):Play()
		end

		v7.Value = 0.1
		TweenService:Create(v7, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 8.4
		}):Play()

		for _, folder3 in pairs(folder2:GetDescendants()) do
			for _, beam in pairs(folder3:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				playTween(beam, {
					Time = 0.4,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				})
				game.Debris:AddItem(beam, 0.4)
			end
		end

		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Include
		raycastParams2.FilterDescendantsInstances = { game.Workspace.Map }
		local raycastResult = game.Workspace:Raycast(anchor.Position, createVector(0, -10, 0), raycastParams2)
		local clone6 = v.WindDecal1:Clone()

		if raycastResult then
			clone6.Start.Impact252.Color3 = raycastResult.Instance.Color
		end

		clone6:ScaleTo(12)
		clone6:PivotTo(anchor * CFrame.new(0, -5 * clone6:GetScale(), 0) * CFrame.Angles(3.141592653589793, 0, 0))
		playMesh({
			Model = clone6,
			Info = TweenInfo.new(6, Enum.EasingStyle.Exponential)
		})

		if v3 then
			local v8 = object._maid:give(Instance.new("BlurEffect"))
			v8.Size *= 0.3
			v8.Parent = game.Lighting
			TweenService:Create(v8, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Size = 0
			}):Play()
		end

		local clone7 = v.HitShockImpact:Clone()
		clone7:ScaleTo(7.199999999999999)
		clone7:PivotTo(anchor * CFrame.new(0, 5 * clone7:GetScale(), 0) * CFrame.Angles(
			1.5707963267948966,
			1.5707963267948966,
			0
		))
		playMesh({
			Model = clone7,
			Info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
		})
		shared.repfire({
			Effect = "Ground Crater",
			Seed = math.random(1, 2000000000),
			start = anchor.Position,
			["end"] = createVector(0, -14, 0),
			amount = 4,
			nosound = true,
			sizemult = 5.7,
			size = 18
		})
		shared.repfire({
			Effect = "Ground Crater",
			Seed = math.random(1, 2000000000),
			start = anchor.Position,
			["end"] = createVector(0, -14, 0),
			amount = 5,
			nosound = true,
			sizemult = 1.75,
			size = 1.68
		})
		shared.repfire({
			Effect = "Ground Crater",
			Seed = math.random(1, 2000000000),
			start = anchor.Position,
			["end"] = createVector(0, -14, 0),
			amount = 6,
			nosound = true,
			sizemult = 8.1,
			size = 9.6
		})
	end

	task.spawn(SlamEvent)
	wait(35)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.Barrage(p)
	local finalAdditions = script.FinalAdditions
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
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
	local v2 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim

	local function Barrage()
		local v3 = {}
		local v4 = {
			bind = data.bind
		}
		local parentChangedConnection = nil
		local flag = false
		parentChangedConnection = v4.bind:GetPropertyChangedSignal("Parent"):Once(function()
			if v4.bind.Parent then
				return
			end

			flag = true
			warn("bai")

			for _, v5 in pairs(v3) do
				v5:Destroy()
			end

			Clean() -- equivalent call inferred; original call site unknown
			return parentChangedConnection:Disconnect()
		end)
		local v5 = object._maid:give(Instance.new("NumberValue"))
		v5.Value = 11
		table.insert(v3, v5)

		local function quadBezier(p2, p3, p4, p5)
			local v6 = 1 - p5
			return v6 * v6 * p2 + 2 * v6 * p5 * p3 + p5 * p5 * p4
		end

		local v6

		if v2 then
			v6 = object._maid:give(game.ReplicatedStorage.Resources.Sphere1:Clone())
			v6:PivotTo(char:GetPivot())
			v6.Transparency = 0.5
			v6.Size = createVector(150, 150, 150)
			v6.Parent = EFP
			table.insert(v3, v6)
		else
			v6 = nil
		end

		local function Method1noclone()
			if flag then
				return
			end

			local sine = Enum.EasingStyle.Sine
			local quad = Enum.EasingStyle.Quad
			local occluded = Enum.HighlightDepthMode.Occluded
			TweenService:Create(v5, TweenInfo.new(3, sine), {
				Value = 3
			}):Play()
			local lastTime = tick()
			local v7 = { Color3.fromRGB(170, 105, 65) }
			local tweenInfo = TweenInfo.new(2, sine)
			local v8 = object._maid:give(Instance.new("NumberValue"))
			v8.Value = 1
			TweenService:Create(v8, tweenInfo, {
				Value = 5
			}):Play()
			v3[#v3 + 1] = v8
			local v9 = object._maid:give(Instance.new("NumberValue"))
			v9.Value = 0.1
			TweenService:Create(v9, tweenInfo, {
				Value = 0.5
			}):Play()
			v3[#v3 + 1] = v9

			if flag then
				return
			end

			local cFrame = humanoidRootPart.CFrame
			local FX = quickFX({
				FX = finalAdditions.Jump,
				Maid = object._maid,
				Anchor = cFrame * CFrame.new(0, 0, -5) * CFrame.Angles(-1.5707963267948966, 0, 0)
			})
			lifeScale({
				FX = FX,
				Scale = 3
			})
			playAttachment(FX)
			v3[#v3 + 1] = FX
			local FX2 = quickFX({
				FX = finalAdditions.BarrageFX,
				Maid = object._maid,
				Anchor = victim:GetPivot()
			})
			able({
				FX = FX2,
				On = true
			})
			v3[#v3 + 1] = FX2
			local _ = {
				["Right Arm"] = "Right Shoulder",
				["Left Arm"] = "Left Shoulder",
				["Right Leg"] = "Right Hip",
				["Left Leg"] = "Left Hip",
				Head = "Neck",
				Torso = "RootJoint"
			}
			local color = Color3.fromRGB(242, 255, 0)
			local color2 = Color3.new(0, 0, 0)

			local function makeTrailColorSequence(data2)
				return ColorSequence.new({
					ColorSequenceKeypoint.new(0, data2),
					ColorSequenceKeypoint.new(0.219, Color3.new(data2.R * 0.5, data2.G * 0.5, data2.B * 0.5)),
					ColorSequenceKeypoint.new(0.47, color2),
					ColorSequenceKeypoint.new(1, color2)
				})
			end

			local cframe = CFrame.Angles(1.5707963267948966, 0, 0)
			local color3 = v7[1]
			local trailColorSequence = makeTrailColorSequence(color3)
			local colorSequence = ColorSequence.new(color3)
			local count = 0
			local v13 = 0

			while tick() - lastTime < 1.95 do
				count += 1

				if flag then
					break
				end

				if math.random(1, 3) == 3 then
					continue
				end

				if count % 11 == 0 then
					local v14 = object._maid:give(Instance.new("Highlight"))
					v14.FillTransparency = 0
					v14.OutlineTransparency = 0
					v14.DepthMode = occluded
					v14.FillColor = color
					v14.Parent = victim
					TweenService:Create(v14, TweenInfo.new(random:NextNumber(0.1, 0.2), sine), {
						FillTransparency = 1,
						OutlineTransparency = 1
					}):Play()
					game.Debris:AddItem(v14, 0.2)
					v3[#v3 + 1] = v14
				end

				local cFrame2 = humanoidRootPart.CFrame
				local value = v5.Value
				local value2 = v9.Value
				local value3 = v8.Value

				for _ = 1, math.random(1, 2) do
					if flag then
						return
					end

					if not v2 then
						local currentCamera = workspace.CurrentCamera

						if currentCamera and (currentCamera.CFrame.Position - cFrame2.Position).Magnitude > 150 and count % 2 == 0 then
							continue
						end
					end

					if v13 >= 60 then
						continue
					end

					v13 += 1
					local v14 = object._maid:give(Instance.new("NumberValue"))
					v14.Value = 2.5
					v3[#v3 + 1] = v14
					local clone = finalAdditions.ArmPresset4:Clone()
					task.delay(2, function()
						if clone and clone.Parent then
							clone:Destroy()
						end

						if v14 and v14.Parent then
							v14:Destroy()
						end
					end)
					local v17 = cFrame2 * CFrame.new(
						random:NextNumber(-value, value),
						random:NextNumber(-value, value),
						random:NextNumber(0, value * 2)
					) * cframe
					clone:PivotTo(v17)
					clone.Parent = EFP
					local v18 = random:NextNumber(0.2, 0.3) * value2
					local v19 = v18 * value3
					local primaryPart = clone.PrimaryPart
					TweenService:Create(primaryPart, TweenInfo.new(v18, quad), {
						CFrame = v17 * CFrame.new(0, random:NextNumber(-30, -20), 0)
					}):Play()
					v3[#v3 + 1] = clone
					primaryPart.Color = color3
					local attachment = primaryPart.Attachment
					attachment.Trail.Color = trailColorSequence
					attachment.Trail1.Color = colorSequence
					attachment.Trail2.Color = colorSequence
					local children = primaryPart["2nd"]:GetChildren()
					local goal = {
						Transparency = NumberSequence.new(1)
					}
					local time = v18 * 0.7

					for i = 1, #children do
						local trail = children[i]

						if not trail:IsA("Trail") then
							continue
						end

						trail.Lifetime *= 0.5
						playTween(trail, {
							Time = time,
							EasingStyle = "Sine",
							Goal = goal
						})
					end

					TweenService:Create(v14, TweenInfo.new(v19, sine), {
						Value = 0.01
					}):Play()
					game.Debris:AddItem(clone, v19)
					task.delay(v19, function()
						v13 -= 1
					end)
					local v22 = clone
					local v23 = v14
					object._maid:giveTask(v14.Changed:Connect(function()
						v22:ScaleTo(v23.Value)
					end))

					if count % 2 ~= 0 then
						continue
					end

					local v24 = clone
					task.delay(v19 * 0.5, function()
						if flag then
							return
						end

						local FX3 = quickFX({
							FX = finalAdditions.ArmEnd,
							Maid = object._maid,
							Anchor = v24:GetPivot() * cframe
						})
						v3[#v3 + 1] = FX3
						FX3:ScaleTo(v24:GetScale() * 0.7)
						lifeScale({
							FX = FX3,
							Scale = 0.2
						})
						playAttachment(FX3)
						game.Debris:AddItem(FX3, 0.5)
					end)
				end

				task.wait(0.04 * value2)
			end

			able({
				FX = FX2,
				On = false
			})

			if v6 then
				TweenService:Create(v6, TweenInfo.new(1, sine), {
					Transparency = 1
				}):Play()
			end

			char["Right Arm"].Transparency = 0
			char["Left Arm"].Transparency = 0
		end

		Method1noclone()
	end

	task.spawn(Barrage)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.Back(data)
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
	local v2 = { Color3.fromRGB(170, 105, 65) }

	local function Back()
		local finalAdditions = script.FinalAdditions
		data = data.Data
		local char = data.Char
		local humanoidRootPart = char.HumanoidRootPart
		local _ = char.Humanoid
		local victim = data.Victim
		local v3 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
		local v4

		if v3 then
			v4 = object._maid:give(game.ReplicatedStorage.Resources.Sphere1:Clone())
			v4:PivotTo(char:GetPivot())
			v4.Transparency = 0.5
			v4.Size = createVector(150, 150, 150)
			v4.Parent = EFP
		else
			v4 = nil
		end

		local FX

		if v3 then
			FX = quickFX({
				FX = finalAdditions.Background,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * finalAdditions.Background:GetAttribute("Offset"):Inverse()
			})
			able({
				FX = FX,
				On = true
			})
		else
			FX = nil
		end

		local FX2 = quickWeld({
			FX = finalAdditions.Connect,
			P = char["Right Arm"],
			Maid = object._maid,
			C0 = CFrame.new(0, -1, 0) * CFrame.Angles(3.141592653589793, 0, 0)
		})
		FX2:ScaleTo(0.5)
		able({
			FX = FX2,
			On = false
		})
		lifeScale({
			FX = FX2,
			Scale = 2
		})
		raiseZIndex({
			FX = FX2,
			Count = -5
		})
		task.delay(0.05, function()
			playAttachment(FX2)
		end)
		local v7 = object._maid:give(Instance.new("Highlight"))
		v7.FillTransparency = 1
		v7.OutlineTransparency = 0
		v7.OutlineColor = Color3.fromRGB(255, 255, 188)
		v7.Parent = char
		game.Debris:AddItem(v7, 0.9)
		local v8 = object._maid:give(Instance.new("NumberValue"))
		v8.Value = 11
		local v9 = object._maid:give(Instance.new("NumberValue"))
		v9.Value = 4
		local give = object._maid:give(Instance.new("NumberValue"))
		give.Value = 1
		local v10 = object._maid:give(Instance.new("NumberValue"))
		v10.Value = 0.1
		TweenService:Create(v10, TweenInfo.new(3, Enum.EasingStyle.Exponential), {
			Value = 5
		}):Play()
		local v11 = {}
		task.spawn(function()
			local lastTime = tick()
			task.spawn(function()
				while tick() - lastTime < 2.5 do
					for k, v12 in pairs(v11) do
						local speed = v12.Speed
						k:PivotTo(k:GetPivot() * CFrame.new(0, -speed.Value, 0))

						if not v12.Stopped then
							v12.Scale.Value = v10.Value * v12.ScaleOffset
						end
					end

					task.wait(0.01)
				end
			end)
			task.wait(1.3)
			task.spawn(function()
				local count = 0

				for _, v12 in pairs(v11) do
					count += 1
					TweenService:Create(v12.Speed, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Value = 22
					}):Play()

					if count % 2 == 0 then
						task.wait(0.01)
					end
				end
			end)
			TweenService:Create(v10, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Value = 0.01
			}):Play()
			task.wait(0.55)
			tick()

			for k, _ in pairs(v11) do
				k:Destroy()
			end

			if FX then
				able({
					FX = FX,
					On = false
				})
			end

			if v4 then
				TweenService:Create(v4, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end

			if v3 then
				if FX then
					FX:Destroy()
				end
			elseif FX then
				game.Debris:AddItem(FX, 5)
			end
		end)
		local count = 0

		for _ = 1, 30 do
			count += 1

			if count % 11 == 0 then
				local v12 = object._maid:give(Instance.new("Highlight"))
				v12.FillTransparency = 0
				v12.OutlineTransparency = 0
				v12.Parent = victim
				v12.DepthMode = Enum.HighlightDepthMode.Occluded
				v12.FillColor = Color3.fromRGB(242, 255, 0)
				TweenService:Create(v12, TweenInfo.new(random:NextNumber(0.1, 0.2), Enum.EasingStyle.Sine), {
					FillTransparency = 1,
					OutlineTransparency = 1
				}):Play()
				game.Debris:AddItem(v12, 0.2)
			end

			for _ = 1, math.random(1, 2) do
				local scale = object._maid:give(Instance.new("NumberValue"))
				scale.Value = 2.5
				local speed = object._maid:give(Instance.new("NumberValue"))
				speed.Value = 32
				TweenService:Create(speed, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Value = 0.05
				}):Play()
				local v14 = object._maid:give(Instance.new("NumberValue"))
				v14.Value = random:NextNumber(10, 20)
				TweenService:Create(v14, TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Value = 1
				}):Play()
				local clone = finalAdditions.ArmPresset:Clone()
				local number = random:NextNumber(-v8.Value, v8.Value)
				local number2 = random:NextNumber(-v8.Value, v8.Value)

				if math.abs(number) < 5 then
					number2 = math.random(1, 2) == 1 and random:NextNumber(-5, -15) or random:NextNumber(5, 15)
				end

				clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(
					number2,
					number,
					random:NextNumber(v8.Value * 4 * 2, v8.Value * 8 * 2)
				) * CFrame.Angles(1.5707963267948966, 0, 0))
				clone.Parent = EFP
				local v15 = random:NextNumber(0.2, 0.3) * v9.Value
				local color = v2[math.random(1, #v2)]
				clone.PrimaryPart.Color = color
				clone.PrimaryPart.Attachment.Trail.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, color),
					ColorSequenceKeypoint.new(0.219, Color3.new(color.R * 0.5, color.G * 0.5, color.B * 0.5)),
					ColorSequenceKeypoint.new(0.47, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
				})
				clone.PrimaryPart.Attachment.Trail1.Color = ColorSequence.new(color)
				clone.PrimaryPart.Attachment.Trail2.Color = ColorSequence.new(color)

				for _, trail in pairs(clone.PrimaryPart["2nd"]:GetChildren()) do
					if not trail:IsA("Trail") then
						continue
					end

					trail.Lifetime *= 0.5
					playTween(trail, {
						Time = v15 * 0.7,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new(1)
						}
					})
				end

				local size = clone.PrimaryPart.Size

				local function Change()
					if clone.Parent then
						clone:ScaleTo(scale.Value)
						clone.PrimaryPart.Size = Vector3.new(
							size.X * clone:GetScale() / v14.Value,
							size.Y * clone:GetScale() * v14.Value,
							size.X * clone:GetScale() / v14.Value
						)
					end
				end

				local Change2 = Change
				object._maid:giveTask(scale.Changed:Connect(function()
					Change2()
				end))
				local Change3 = Change
				object._maid:giveTask(v14.Changed:Connect(function()
					Change3()
				end))
				v11[clone] = {
					Scale = scale,
					ScaleOffset = random:NextNumber(0.8, 1.2),
					Speed = speed
				}
				local v21 = clone
				local color2 = clone.PrimaryPart.Color
				task.delay(0.2, function()
					v21.PrimaryPart.Color = Color3.new(1, 1, 1)
					TweenService:Create(v21.PrimaryPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Color = color2
					}):Play()
				end)
			end

			task.wait(0.003 * v9.Value)
		end
	end

	task.spawn(Back)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function GodAdditions.FistEvent(p)
	local finalAdditions = script.FinalAdditions
	local data = p.Data
	local char = data.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim
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
	local v2 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim

	local function FistEvent()
		if v2 then
			local v3 = object._maid:give(game.ReplicatedStorage.Resources.Sphere1:Clone())
			v3:PivotTo(char:GetPivot())
			v3.Transparency = 0
			v3.Size = createVector(150, 150, 150)
			v3.Parent = EFP
			game.Debris:AddItem(v3, 0.5)
		end

		local v3

		if v2 then
			v3 = object._maid:give(game.ReplicatedStorage.Resources.Sphere1:Clone())
			v3:PivotTo(char:GetPivot())
			v3.Transparency = 0.5
			v3.Size = createVector(150, 150, 150)
			v3.Parent = EFP
		end

		local v4 = object._maid:give(finalAdditions.Armm:Clone())
		local weld = Instance.new("Weld")
		weld.Part0 = v4
		weld.Part1 = char["Left Arm"]
		weld.Parent = v4
		v4.Parent = EFP
		able({
			FX = v4,
			On = true
		})
		dtwait(0.5)
		able({
			FX = v4,
			On = false
		})

		if v3 then
			TweenService:Create(v3, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
		end
	end

	task.spawn(FistEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)

function GodAdditions.Uppercut(p)
	local vfx2 = script.vfx
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim
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

	-- equivalent calls inferred from this helper; original call sites unknown
	local function PlaceVFX(descendant, pivot)
		descendant:PivotTo(pivot * descendant:GetAttribute("Offset"):Inverse())
	end

	local folder = object._maid:give(vfx2.Uppercut:Clone())
	local v2 = object._maid:give(Instance.new("Highlight"))
	v2.FillTransparency = 0
	v2.Parent = folder

	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Model")) then
			continue
		end

		PlaceVFX(descendant, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
	end

	folder.Parent = EFP
	local transparenciesByDescendant = {}

	local function Invisible()
		for _, descendant in pairs(char:GetDescendants()) do
			if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
				continue
			end

			transparenciesByDescendant[descendant] = descendant.Transparency
			descendant.Transparency = 1
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Visible()
		for k, transparency in pairs(transparenciesByDescendant) do
			k.Transparency = transparency
		end
	end

	shared.vfx.emit(folder.XD)
	task.wait(0.15)
	shared.vfx.emit(folder.Uppercut2)
	task.delay(0.3, function()
		local WAIT_INTERVAL = 0.05
		Invisible()
		task.wait(0.03)
		Visible() -- equivalent call inferred; original call site unknown
		task.wait(0.03)
		Invisible()
		task.wait(WAIT_INTERVAL)
		Visible() -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
		Invisible()
		task.wait(WAIT_INTERVAL)
		Visible() -- equivalent call inferred; original call site unknown
		task.wait(0.3)
		Invisible()
		task.wait(1)
		Visible() -- equivalent call inferred; original call site unknown
	end)
	task.wait(0.45)
	local v3 = object._maid:give(vfx2:WaitForChild("FINAL MeshEmitter"):Clone())
	v3.Parent = EFP
	local v4 = MoonEmitter.new(v3)
	v4:Play()
	v4:SetAnchor(humanoidRootPart.CFrame * CFrame.new(0, 0, 0))
	v4:SetTime(3.85)
	local folder2 = object._maid:give(vfx2.EX:Clone())

	for _, descendant in pairs(folder2:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Model")) then
			continue
		end

		PlaceVFX(descendant, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
	end

	folder2.Parent = EFP
	shared.vfx.emit(folder2)
end

return GodAdditions