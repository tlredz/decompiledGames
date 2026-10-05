local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Utils = require(ReplicatedStorage.Common.Utils)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = { workspace.Map, workspace.Runtime }
local v2 = {
	"rbxassetid://13816054573",
	"rbxassetid://14061881330",
	"rbxassetid://14061881951",
	"rbxassetid://13712002536",
	"rbxassetid://13575704611",
	"rbxassetid://14261953171",
	"rbxassetid://15249897265",
	"rbxassetid://13712010899",
	"rbxassetid://13712011229"
}
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local quantumArena = ReplicatedStorage.Assets.Abilities.QuantumArena
local terrain = workspace.Terrain
local quantumArenaBase = SoundService.SFX.QuantumArenaBase
local quantumArenaOverlay = SoundService.SFX.QuantumArenaOverlay
local v3 = false
local v4 = {}
local v5 = { SoundService.SFX, SoundService.Music }
local maid = Trove.new()

local function getProperty(p, p2)
	return p[p2]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSizeMultiplier()
	local currentlySelectedMap = workspace:GetAttribute("CurrentlySelectedMap")

	if currentlySelectedMap and (string.find(currentlySelectedMap, "EXPANDED") or string.find(
		currentlySelectedMap,
		"BattleRoyale_"
	)) then
		return 31.25
	end

	return 12.5
end

local function emitDomainBall(duration: number, cFrame: CFrame, value: number?)
	local v6 = Utils.Physics.ResizePart(quantumArena.DomainBall:Clone(), getSizeMultiplier())
	v6.Square.Lifetime = NumberRange.new(value or 1)
	v6.CFrame = cFrame
	v6.Parent = currentCamera
	v6.Square.Enabled = true
	TweenService:Create(v6.Square, TweenInfo.new(duration), {
		ShapePartial = 1
	}):Play()
	task.delay(duration, function()
		if v6:IsDescendantOf(workspace) then
			v6.Square.Enabled = false
		end
	end)
	return v6
end

local function makeSphere(duration: number, cFrame: CFrame)
	local v6 = Utils.Physics.ResizePart(quantumArena.Sphere:Clone(), getSizeMultiplier())
	v6.CFrame = cFrame
	v6.Parent = currentCamera
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
	TweenService:Create(v6, tweenInfo, {
		Transparency = 0
	}):Play()
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		TweenService:Create(atmosphere, tweenInfo, {
			Density = 0
		}):Play()
	end

	return v6
end

local function execute(player)
	if not v3 then
		v3 = true
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, v2)
	end

	local character = player.Character
	local character2 = localPlayer.Character

	if not (character and character2 and character:FindFirstChildWhichIsA("Humanoid")) then
		return
	end

	local primaryPart = character.PrimaryPart

	if not primaryPart then
		return
	end

	local maid2 = Trove.new()
	local _ = SoundService.SFX.Volume
	local volumes = {}

	for _, v6 in v5 do
		volumes[v6] = v6.Volume
		v6.Volume = 0
		local v7 = v6
		maid2:Add(v6:GetPropertyChangedSignal("Volume"):Connect(function()
			volumes[v7] = v7.Volume
			v7.Volume = 0
		end))
	end

	local clone = quantumArenaBase:Clone()
	clone.SoundGroup = nil
	clone.Volume = volumes[SoundService.SFX] * clone.Volume
	clone.Parent = SoundService
	clone:Play()
	local cFrame = primaryPart.CFrame
	local clouds = terrain:FindFirstChildWhichIsA("Clouds")

	if clouds then
		clouds.Enabled = false
	end

	terrain.WaterWaveSize = (0 / 0)
	local v6 = false
	maid:Add(ReplicatedStorage.Remotes.RoundEnded.OnClientEvent:Connect(function()
		v6 = true
	end))
	local v7 = {}

	for _, folder in v do
		for _, part in folder:GetDescendants() do
			local success, result = pcall(getProperty, part, "Transparency")

			if not success then
				continue
			end

			local v8 = {
				Transparency = result
			}
			v7[part] = v8

			if type(result) == "number" then
				part.Transparency = 1

				if part:IsA("BasePart") and part.Name ~= "Border" then
					v8.CanCollide = part.CanCollide
					primaryPart.CanCollide = part.CollisionGroup == "MapFloor"
				end
			elseif typeof(result) == "NumberSequence" then
				part.Transparency = NumberSequence.new(1, 1)
			else
				warn((`Invalid Transparency type: {typeof(result)}`))
			end
		end
	end

	local clockTime = Lighting.ClockTime
	maid:Add(function()
		Lighting.ClockTime = clockTime

		for k, v8 in v7 do
			if not k:IsDescendantOf(workspace) then
				continue
			end

			for k2, v9 in v8 do
				k[k2] = v9
			end
		end

		if clouds then
			clouds.Enabled = true
		end

		terrain.WaterWaveSize = 0.5
	end)
	local v8 = emitDomainBall(1.5, cFrame, 2.5)
	TweenService:Create(Lighting.ColorCorrection, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Brightness = -0.5
	}):Play()
	task.wait(1)
	local atmosphere = Lighting:FindFirstChild("Atmosphere")
	local clone2

	if atmosphere then
		clone2 = atmosphere:Clone()
		clone2.Parent = Lighting
		atmosphere.Parent = nil
	end

	local sphere = makeSphere(1, cFrame)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
	task.wait(tweenInfo.Time)
	local tweenInfo2 = TweenInfo.new(tweenInfo.Time, Enum.EasingStyle.Exponential, tweenInfo.EasingDirection)
	TweenService:Create(sphere, tweenInfo2, {
		Color = Color3.fromRGB(255, 255, 255)
	}):Play()
	TweenService:Create(Lighting.ColorCorrection, tweenInfo2, {
		Brightness = 1
	}):Play()
	TweenService:Create(Lighting.Bloom, tweenInfo2, {
		Intensity = 1,
		Size = 50
	}):Play()
	task.wait(tweenInfo2.Time)
	local v9 = maid:Add(quantumArena.GlowAura:Clone())
	v9.CFrame = primaryPart.CFrame
	v9.Parent = workspace.CurrentCamera
	SoundService.AmbientReverb = Enum.ReverbType.Cave
	local tween = TweenService:Create(clone, TweenInfo.new(0.25), {
		Volume = 0
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	local clone3 = quantumArenaOverlay:Clone()
	clone3.SoundGroup = nil
	clone3.Volume = volumes[SoundService.SFX] * clone3.Volume
	clone3.Parent = SoundService
	clone3:Play()
	maid:Add(Utils.Physics.FastWeld(v9, primaryPart))
	Lighting.ClockTime = 12
	local atmospheres = { Lighting:FindFirstChild("Sky") }

	for _, v10 in atmospheres do
		v10.Parent = nil
	end

	local childAddedConnection = nil

	if atmosphere then
		table.insert(atmospheres, atmosphere)
	else
		childAddedConnection = Lighting.ChildAdded:Connect(function(atmosphere2)
			if atmosphere2:IsA("Atmosphere") and atmosphere2.Name == "Atmosphere" then
				table.insert(atmospheres, atmosphere2)
				atmosphere2.Parent = nil
			end
		end)
	end

	local clone4 = quantumArena.QuantumSky:Clone()
	clone4.Parent = Lighting
	maid:Add(function()
		clone4:Destroy()
	end)
	local maid3 = maid
	local v10 = maid3:Add(Utils.Physics.ResizePart(quantumArena.SpacePart:Clone(), getSizeMultiplier()))
	v10.CFrame = cFrame
	v10.Parent = workspace.CurrentCamera
	v8:Destroy()
	sphere:Destroy()
	local tweenInfo3 = TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
	TweenService:Create(Lighting.ColorCorrection, tweenInfo3, {
		Brightness = 0
	}):Play()
	TweenService:Create(Lighting.Bloom, tweenInfo3, {
		Intensity = 0.3,
		Size = 5
	}):Play()
	maid2:Destroy()

	for k, volume in volumes do
		k.Volume = volume
	end

	local lastTime = os.clock()

	while os.clock() - lastTime < 15 and not v6 and character2:IsDescendantOf(workspace.Alive) and workspace:GetAttribute("QuantumArenaActive") == player.UserId do
		task.wait()
	end

	local tweenInfo4 = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	TweenService:Create(sphere, tweenInfo4, {
		Color = Color3.fromRGB(255, 255, 255)
	}):Play()
	TweenService:Create(Lighting.ColorCorrection, tweenInfo4, {
		Brightness = 1
	}):Play()
	TweenService:Create(Lighting.Bloom, tweenInfo4, {
		Intensity = 1,
		Size = 50
	}):Play()
	task.wait(tweenInfo4.Time)
	local tween2 = TweenService:Create(clone3, TweenInfo.new(0.25), {
		Volume = 0
	})
	tween2.Completed:Connect(function()
		clone3:Destroy()
	end)
	tween2:Play()
	SoundService.AmbientReverb = Enum.ReverbType.NoReverb

	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	if clone2 then
		clone2:Destroy()
	end

	for _, v11 in atmospheres do
		v11.Parent = Lighting
	end

	maid:Destroy()
	clone4:Destroy()
	v7 = nil
	TweenService:Create(Lighting.ColorCorrection, tweenInfo4, {
		Brightness = 0
	}):Play()
	TweenService:Create(Lighting.Bloom, tweenInfo4, {
		Intensity = 0.3,
		Size = 5
	}):Play()
end

local flag = false
local requestExecuteQueue

requestExecuteQueue = function()
	if flag then
		return nil
	end

	local v6 = table.remove(v4, 1)

	if not v6 then
		return nil
	end

	flag = true
	xpcall(execute, warn, table.unpack(v6))
	flag = false
	task.spawn(requestExecuteQueue)
	return true
end

return function(p)
	table.insert(v4, { p })

	if flag then
		return
	end

	local v6 = table.remove(v4, 1)

	if not v6 then
		return
	end

	flag = true
	xpcall(execute, warn, table.unpack(v6))
	flag = false
	task.spawn(requestExecuteQueue)
end