local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("Dough.Shockwaves.Slash")
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0)
TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	Util.Sound:Play("WhipQuick", cFrame)
	Util.Sound:Play("StringShot", cFrame, nil, 0.75)

	if (currentCamera.CFrame.p - cFrame.p).Magnitude < 100 then
		local v = 1 - (currentCamera.CFrame.p - cFrame.p).Magnitude / 100
		Effect.new("ShakeCam"):replicate({
			Preset = "Explosion",
			Power = 0.8 + v * 0.2
		})
	end

	local folder = Instance.new("Folder", workspace._WorldOrigin)
	folder.Name = "effs"
	Util.Debris:AddItem(folder, 7)
	task.spawn(function()
		for _ = 1, 2 do
			local clone = script.Ring1:Clone()
			clone.CFrame = cFrame
			clone.Parent = folder
			TweenService:Create(clone, tweenInfo2, {
				Size = createVector(55, 0.75, 55),
				Transparency = 1
			}):Play()
			task.wait(0.2)
		end
	end)
	local clone = script.Wind:Clone()
	clone.CFrame = cFrame * CFrame.new(0, 1.3, 0)
	clone.Parent = folder
	TweenService:Create(clone.Mesh, tweenInfo, {
		Scale = createVector(20, 5, 20)
	}):Play()
	TweenService:Create(clone.Decal, tweenInfo, {
		Transparency = 1
	}):Play()
	Util.Debris:AddItem(clone, 3)
	local clone2 = script.Strings:Clone()
	clone2.CFrame = cFrame * CFrame.new(0, 11, 0)
	clone2.Parent = folder
	clone2.whiteLines:Emit(20)
	clone2.wh1iteLines:Emit(20)
	local ray = Util.Ray
	local v = cFrame.p + createVector(0, 0.1, 0)
	local v2 = { workspace.Characters, workspace.Enemies }
	local v3, v4, v5 = ray(v, createVector(0, -15, 0), v2)

	if v3 then
		local v6 = CFrame.new(v4, v4 + v5) * CFrame.Angles(-1.5707963267948966, 0, 0)
		coroutine.wrap(function()
			Util.MeteorRocks({
				origin = v6,
				amount = 8,
				size = { 5, 5, 7.5 },
				offset = 21,
				tweenTime = 0.5,
				waitTime = 1
			})
		end)()
		local clone3 = script.Part:Clone()
		clone3.CFrame = v6
		clone3.FFGrass.Color = ColorSequence.new(v3.Color)
		clone3.Rocks.Color = ColorSequence.new(v3.Color)
		clone3.Parent = folder
		clone3.FFGrass:Emit(15)
		clone3.Rocks:Emit(15)
	end

	task.delay(0.4, function()
		clone2.whiteLines.Enabled = false
		clone2.wh1iteLines.Enabled = false
	end)
	local clone3 = script.BreathingIn:Clone()
	clone3.CFrame = cFrame * CFrame.new(0, 1, 0)
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.delay(0.25, function()
		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local position = cFrame * createVector(0, 15, 0)
	task.spawn(function()
		for _ = 1, 4 do
			local clone4 = script.Ring:Clone()
			clone4.CFrame = cFrame
			clone4.Size = createVector(20, 3, 20)
			clone4.Color = Color3.fromRGB(255, 255, 255)
			clone4.Material = Enum.Material.Plastic
			clone4.Parent = folder
			TweenService:Create(clone4, tweenInfo, {
				Position = position,
				Size = createVector(70, 0, 70),
				Transparency = 1
			}):Play()
			task.wait(0.16)
		end
	end)
end