local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local _ = Util.BoatTween
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local scaleParticle2 = Util.ScaleParticle2
local SharkPalettes = require(ReplicatedStorage.EffectContainer.NPC.ChainShark.SharkPalettes)
return function(data)
	local cFrame = data.CFrame
	local rayHit = data.RayHit
	local rayPos = data.RayPos
	local _ = data.RayNorm
	local seaY = data.SeaY
	local scale = data.Scale or 1
	local colorSet = data.ColorSet or 1

	if (workspace.CurrentCamera.CFrame.Position - rayPos).Magnitude > 1000 then
		return
	end

	local slam = SharkPalettes[colorSet].Slam
	local v = {
		AirSplatter = ColorSequence.new(slam[1]),
		GroundCrack = ColorSequence.new(slam[2]),
		Core = ColorSequence.new(slam[3]),
		UpRays = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(121, 115, 99)),
			ColorSequenceKeypoint.new(0.318, slam[1]),
			ColorSequenceKeypoint.new(0.545, slam[4]),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		}),
		Splatter = ColorSequence.new(slam[5]),
		Zap = ColorSequence.new(slam[6])
	}
	Util.Sound:Play("Snarl", cFrame.Position, nil, 1.5, 0.5)
	local clone = script.SharkSlam:Clone()
	debris:AddItem(clone, 4)
	clone.CFrame = CFrame.new(rayPos)
	clone.Parent = _WorldOrigin
	local v2 = {
		Rock = true,
		Dust = true,
		GroundCrack = true
	}

	for _, child in pairs(clone.Ground:GetChildren()) do
		if v2[child.Name] then
			continue
		end

		if v[child.Name] then
			child.Color = v[child.Name]
		end

		scaleParticle2(child, scale, true)
		child:Emit(child:GetAttribute("EmitCount"))
	end

	Effect.new("NPC.ChainShark.Spin"):replicate({
		CFrame = cFrame * CFrame.Angles(0, 0, 1.5707963267948966),
		Super = true,
		Scale = scale,
		ColorSet = colorSet
	})

	for _, child in pairs(clone.Air:GetChildren()) do
		scaleParticle2(child, scale, true)

		if v[child.Name] then
			child.Color = v[child.Name]
		end

		child:Emit(child:GetAttribute("EmitCount"))
	end

	if rayHit then
		Util.Sound:Play("Wallhit2", cFrame.Position, nil, 1.1, 1.2)

		for _, child in pairs(clone.Ground:GetChildren()) do
			if not v2[child.Name] then
				continue
			end

			if v[child.Name] then
				child.Color = v[child.Name]
			end

			if child.Name ~= "GroundCrack" and child.Name ~= "Dust" then
				child.Color = ColorSequence.new(rayHit.Color)
			end

			scaleParticle2(child, scale, true)
			child:Emit(child:GetAttribute("EmitCount"))
		end
	else
		Effect.new("NPC.ChainShark.Splash"):replicate({
			CFrame = CFrame.new(rayPos.X, seaY, rayPos.Z) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0),
			Scale = scale
		})
	end

	if (workspace.CurrentCamera.CFrame.Position - rayPos).Magnitude < 300 then
		Util.CameraShaker:ShakeOnce(3, 5, 0.5, 0.5)
	end
end