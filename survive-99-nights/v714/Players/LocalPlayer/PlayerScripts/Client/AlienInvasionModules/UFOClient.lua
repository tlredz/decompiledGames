local UFOClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local random = Random.new()
local flag = false

function ExplosionAtPoints(position)
	local clone = ReplicatedStorage.Assets.Particles.UFOSmokeParticle:Clone()
	clone.Position = position
	clone.Parent = workspace.Particles
	TweenService:Create(clone.BillboardGui, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(200, 0, 200, 0)
	}):Play()
	TweenService:Create(
		clone.BillboardGui.ImageLabel,
		TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			ImageTransparency = 1
		}
	):Play()
	task.spawn(function()
		wait(0.75)

		if clone then
			clone:Destroy()
		end
	end)
end

function mapToRange(value)
	return 0.5 - (math.clamp(value, 400, 700) - 400) / 300 * 0.35
end

Client.Events.UFOCrashed:Connect(function(p, _, p2)
	local v = p2 - workspace:GetServerTimeNow()

	if v > 0 then
		task.spawn(function()
			MathAnimateUFOCrash(p, v)
			ExplosionAtPoints(p)
			local v2 = not (localPlayer.Character and localPlayer.Character.PrimaryPart) and 650 or (localPlayer.Character.PrimaryPart.Position - p).Magnitude
			print(v2 .. " and " .. mapToRange(v2))
			Client.Sound.Play("UFO_Crash", {
				Volume = mapToRange(v2) * 0.1
			})
		end)
	end
end)

function GetCrashingUFOs()
	local count = 0

	for _, child in pairs(workspace.CrashingUFOs:GetChildren()) do
		if child.Name ~= "Highlight" then
			count += 1
		end
	end

	return count
end

function FlashUFOModel(_)
	local v = workspace.CrashingUFOs:FindFirstChild("Highlight")

	if not v then
		task.spawn(function()
			wait(4)
			wait(13)
		end)
		v = Instance.new("Highlight")
		v.Parent = workspace.CrashingUFOs
		v.FillTransparency = 1
		v.OutlineTransparency = 1
	end

	task.spawn(function()
		while v and v.Parent and GetCrashingUFOs() > 0 do
			TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				FillTransparency = 0
			}):Play()
			wait(0.5)

			if not (v and v.Parent) then
				continue
			end

			TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				FillTransparency = 1
			}):Play()
			wait(0.5)
		end

		if v then
			v.Parent = nil
			v.Adornee = nil
			v:Destroy()
		end
	end)
end

function OnUFOCrashed(position)
	local clone = game.ReplicatedStorage.Assets.Particles.UFOCrash:Clone()
	clone.Parent = workspace.Particles
	clone:PivotTo(CFrame.new(position))

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(50)
		end
	end
end

function MathAnimateUFOCrash(position, p)
	CFrame.new(position)
	local clone = game.ReplicatedStorage.Assets.AlienInvasion.UFOAnimate:Clone()
	clone.Parent = workspace.CrashingUFOs
	task.spawn(function()
		FlashUFOModel(clone)
	end)
	local v = -1500

	if p > 5 then
		Client.TweenModule.new(function(p2)
			v = -1500 + p2 * 1500
		end, 5, "Expo"):Play()
	else
		v = 0
	end

	local v2 = p * 30 + -10
	Vector3.new(position.X, v2, position.Z)
	local total = 0
	local total2 = 0
	local total3 = 0

	while true do
		local v3 = RunService.RenderStepped:Wait()
		total += v3
		v2 += -30 * v3
		total2 += 1400 * v3
		total3 += 360 * v3
		math.clamp(1 - v2 / 500 * 1.4, 0.5, 1.4)
		local v4 = math.noise(total3 / 250) * 50
		local v5 = 15 + math.noise(total3 / 310) * 40

		if v2 - -10 < 50 then
			v5 *= (v2 - -10) / 50
		end

		clone:PivotTo(CFrame.new(position.X, v2, v + position.Z) * CFrame.Angles(0, math.rad(total3), 0) * CFrame.new(
			0,
			0,
			-v5
		) * CFrame.Angles(math.rad(v4), math.rad(total2), 0))

		if not (v2 <= -10 or p < total) then
			continue
		end

		clone:Destroy()
		OnUFOCrashed(position)
		break
	end
end

function AnimateUFOCrash(position)
	local cframe = CFrame.new(position)
	local UFO = workspace:WaitForChild("UFO")
	UFO:PivotTo(cframe * CFrame.new(
		50.4082642,
		93.6298218,
		-36.7232361,
		0.829513371,
		0.383692384,
		-0.405817211,
		-0.250891328,
		0.905203402,
		0.343016207,
		0.49895981,
		-0.182720467,
		0.84714359
	))
	local newAnimation = UFO:WaitForChild("NewAnimation")
	UFO:WaitForChild("AnimationController"):LoadAnimation(newAnimation):Play()
end

function SendUFO()
	local total = -1500
	local integer = random:NextInteger(-750, 750)
	local integer2 = random:NextInteger(180, 380)
	local integer3 = random:NextInteger(400, 750)
	local v = random:NextNumber(-30, 30) / 30
	local cframe = CFrame.new(integer, integer2, total)
	local clone = game.ReplicatedStorage.Assets.AlienInvasion.UFO:Clone()
	clone:ScaleTo(0.5 + random:NextNumber() * 1.2)
	clone:PivotTo(cframe)
	clone.Parent = workspace
	local cFrame = workspace.CurrentCamera.CFrame
	local v2 = false
	local total2 = 0
	local total3 = 0

	while total < 1300 do
		local v3 = RunService.RenderStepped:Wait()
		total += integer3 * v3

		if total > -400 and not v2 then
			task.spawn(function()
				Client.Sound.Play("UFO_Pass_1", {
					Volume = 0.5,
					Position = Vector3.new(integer, 30, 0)
				})
			end)
			v2 = true
		end

		if total > -100 then
			total2 += v * v3
			integer += total2
		end

		total3 += 1400 * v3
		clone:PivotTo(CFrame.new(cFrame.X + integer, integer2, cFrame.Z + total) * CFrame.Angles(
			0.3490658503988659,
			0,
			0
		) * CFrame.Angles(0, math.rad(total3), 0))
	end

	clone:Destroy()
end

Client.Events.StartAlienInvasion:Connect(function()
	flag = true
	task.spawn(function()
		wait(4)
		Client.PopUpUI.AddPopUp("something mysterious is flying above you", "alien")
	end)

	while flag do
		task.spawn(function()
			SendUFO()
		end)
		wait(0.1 + random:NextNumber() * 0.25)
	end
end)
Client.Events.StopAlienInvasion:Connect(function()
	flag = false
end)

function UFOClient.Init() end

return UFOClient