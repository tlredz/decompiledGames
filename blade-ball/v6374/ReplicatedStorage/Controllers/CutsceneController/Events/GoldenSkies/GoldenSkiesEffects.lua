local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Debris")
local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Common.Utils)
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = { workspace.Map, workspace.Runtime }
local v3 = {
	"rbxassetid://13816054573",
	"rbxassetid://14061881330",
	"rbxassetid://14061881951",
	"rbxassetid://13712002536",
	"rbxassetid://13575704611",
	"rbxassetid://14261953171",
	"rbxassetid://15249897265"
}
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local goldenSkies = ReplicatedStorage2.Assets.Events.AdminAbuse.GoldenSkies
local terrain = workspace.Terrain
local quantumArenaBase = SoundService.SFX.QuantumArenaBase
local quantumArenaOverlay = SoundService.SFX.QuantumArenaOverlay
local v4 = false
local v5 = { SoundService.SFX, SoundService.Music }
local maid = v.new()

local function getProperty(p, p2)
	return p[p2]
end

local function getSizeMultiplier()
	local currentlySelectedMap = workspace:GetAttribute("CurrentlySelectedMap")

	if currentlySelectedMap and (string.find(currentlySelectedMap, "EXPANDED") or string.find(
		currentlySelectedMap,
		"BattleRoyale_"
	)) then
		return 41.25
	end

	return 16.5
end

local v6 = {}
local flag = false
local GoldenSkiesEffects = {}

function GoldenSkiesEffects.execute(p, cframe: CFrame)
	local spawn = workspace:FindFirstChild("Spawn")

	if spawn then
		spawn:GetPivot()
	end

	if flag then
		return
	end

	if not v4 then
		v4 = true
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, v3)
	end

	flag = true
	table.clear(v6)
	local maid2 = v.new()
	local _ = SoundService.SFX.Volume
	local volumes = {}

	for _, v7 in v5 do
		volumes[v7] = v7.Volume
		v7.Volume = 0
		local v8 = v7
		maid2:Add(v7:GetPropertyChangedSignal("Volume"):Connect(function()
			volumes[v8] = v8.Volume
			v8.Volume = 0
		end))
	end

	local clone = quantumArenaBase:Clone()
	clone.SoundGroup = nil
	clone.Volume = volumes[SoundService.SFX] * clone.Volume
	clone.Parent = SoundService
	clone:Play()
	local clouds = terrain:FindFirstChildWhichIsA("Clouds")

	if clouds then
		clouds.Enabled = false
	end

	local v7 = {}
	terrain.WaterWaveSize = (0 / 0)
	local clockTime = Lighting.ClockTime
	maid:Add(function()
		Lighting.ClockTime = clockTime

		if next(v7) then
			for k, v8 in v7 do
				if not k:IsDescendantOf(workspace) then
					continue
				end

				for k2, v9 in v8 do
					k[k2] = v9
				end
			end

			table.clear(v7)
		end

		if clouds then
			clouds.Enabled = true
		end

		terrain.WaterWaveSize = 0.5
	end)
	local clone2 = maid:Clone(goldenSkies.Effects.Impact)
	clone2.CFrame = p.CFrame * CFrame.new(0, -35, -220) * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone2.Parent = currentCamera

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter.Rate)
		end
	end

	local clone3 = maid:Clone(goldenSkies.Effects.MainFireWork)
	clone3.CFrame = p.CFrame * CFrame.new(0, 100, -200)
	clone3.Parent = currentCamera

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter.Rate)
		end
	end

	local clone4 = maid:Clone(goldenSkies.Effects.Top)
	clone4.CFrame = clone3.CFrame
	clone4.Parent = currentCamera
	local clone5 = maid:Clone(goldenSkies.Effects.Bottom)
	clone5.CFrame = clone2.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	clone5.Parent = currentCamera
	local clone6 = maid:Clone(goldenSkies.Effects.Trail)
	clone6.Parent = currentCamera
	clone6.Main.CFrame = clone2.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	clone6.LeftStar.CFrame = clone2.CFrame * CFrame.new(120, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	clone6.RightStar.CFrame = clone2.CFrame * CFrame.new(-120, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	local lastTime = tick()
	coroutine.wrap(function()
		repeat
			clone6:SetPrimaryPartCFrame(clone6:GetPrimaryPartCFrame() * CFrame.fromEulerAnglesXYZ(0, 0.2, 0))
			TweenService:Create(clone6.Main, TweenInfo.new(0.1), {
				CFrame = clone6.Main.CFrame * CFrame.new(0, 9.5, 0)
			}):Play()
			TweenService:Create(clone6.RightStar, TweenInfo.new(0.1), {
				CFrame = clone6.RightStar.CFrame * CFrame.new(0, 9.5, 0)
			}):Play()
			TweenService:Create(clone6.LeftStar, TweenInfo.new(0.1), {
				CFrame = clone6.LeftStar.CFrame * CFrame.new(0, 9.5, 0)
			}):Play()
			task.wait()
		until tick() - lastTime >= 0.8
	end)()
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
	TweenService:Create(Lighting.ColorCorrection, tweenInfo, {
		Brightness = 1
	}):Play()
	TweenService:Create(Lighting.Bloom, tweenInfo, {
		Intensity = 1,
		Size = 50
	}):Play()
	task.wait(tweenInfo.Time)
	SoundService.AmbientReverb = Enum.ReverbType.Cave
	local tween = TweenService:Create(clone, TweenInfo.new(0.25), {
		Volume = 0
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	local clone7 = quantumArenaOverlay:Clone()
	clone7.SoundGroup = nil
	clone7.Volume = volumes[SoundService.SFX] * clone7.Volume
	clone7.Parent = SoundService
	clone7:Play()
	v6.OverlaySound = clone7
	Lighting.ClockTime = 12
	local temp = { Lighting:FindFirstChild("Sky") }

	for _, v9 in temp do
		v9.Parent = nil
	end

	v6.Temp = temp
	local clone_2 = maid:Clone(goldenSkies.GoldenSky)
	clone_2.Parent = Lighting
	local clone8 = maid:Clone(goldenSkies.Effects.Beams)
	clone8.CFrame = clone3.CFrame * CFrame.new(0, -100, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone8.Parent = currentCamera

	for _, folder in v2 do
		for _, part in folder:GetDescendants() do
			local success, result = pcall(getProperty, part, "Transparency")

			if not success then
				continue
			end

			local v9 = {
				Transparency = result
			}
			v7[part] = v9

			if type(result) == "number" then
				part.Transparency = 1

				if part:IsA("BasePart") and part.Name ~= "Border" then
					v9.CanCollide = part.CanCollide
				end
			elseif typeof(result) == "NumberSequence" then
				part.Transparency = NumberSequence.new(1, 1)
			else
				warn((`Invalid Transparency type: {typeof(result)}`))
			end
		end
	end

	local clone9 = maid:Clone(ReplicatedStorage2.Assets.Events.AdminAbuse.GoldenMap)
	clone9:PivotTo(cframe)
	clone9.Parent = workspace.Runtime
	task.wait(1)

	if clone9.Parent then
		clone9:Destroy()
	end

	if next(v7) then
		for k, v9 in v7 do
			if not k:IsDescendantOf(workspace) then
				continue
			end

			for k2, v10 in v9 do
				k[k2] = v10
			end
		end

		table.clear(v7)
	end

	local tweenInfo2 = TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
	TweenService:Create(Lighting.ColorCorrection, tweenInfo2, {
		Brightness = 0
	}):Play()
	TweenService:Create(Lighting.Bloom, tweenInfo2, {
		Intensity = 0.3,
		Size = 5
	}):Play()
	maid2:Destroy()

	for k, volume in volumes do
		k.Volume = volume
	end
end

function GoldenSkiesEffects.stop()
	print(v6)

	if not (next(v6) and flag) then
		maid:Destroy()
		return
	end

	local overlaySound = v6.OverlaySound
	local temp = v6.Temp
	table.clear(v6)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	TweenService:Create(Lighting.ColorCorrection, tweenInfo, {
		Brightness = 1
	}):Play()
	TweenService:Create(Lighting.Bloom, tweenInfo, {
		Intensity = 1,
		Size = 50
	}):Play()
	task.wait(tweenInfo.Time)
	local tween = TweenService:Create(overlaySound, TweenInfo.new(0.25), {
		Volume = 0
	})
	tween.Completed:Connect(function()
		overlaySound:Destroy()
	end)
	tween:Play()
	SoundService.AmbientReverb = Enum.ReverbType.NoReverb
	print(temp)

	if temp then
		for _, v7 in temp do
			if v7.Parent then
				v7.Parent = Lighting
			end
		end
	end

	maid:Destroy()
	flag = false
	TweenService:Create(Lighting.ColorCorrection, tweenInfo, {
		Brightness = 0
	}):Play()
	TweenService:Create(Lighting.Bloom, tweenInfo, {
		Intensity = 0.3,
		Size = 5
	}):Play()
end

return GoldenSkiesEffects