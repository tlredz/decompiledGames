local createVector = vector.create
game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Debris = require(game.ReplicatedStorage.Util.Debris)
local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local v = {
	"RespawnSFX.BF_Portal_Arrived_At_Destination_01",
	"RespawnSFX.BF_Portal_Arrived_At_Destination_02",
	"RespawnSFX.BF_Portal_Arrived_At_Destination_03"
}

local function emitParticles(folder)
	local v2 = 0

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitDelay = emitter:GetAttribute("EmitDelay") or 0
		local emitCount = emitter:GetAttribute("EmitCount") or emitter:GetAttribute("Emit") or 0
		v2 = math.max(v2, emitDelay + emitter.Lifetime.Max / math.max(emitter.TimeScale, 0.001))

		if emitDelay > 0 then
			local v3 = emitter
			local v4 = emitCount
			task.delay(emitDelay, function()
				if v3.Parent then
					v3:Emit(v4)
				end
			end)
		else
			emitter:Emit(emitCount)
		end
	end

	return v2
end

return function(player)
	local character = player.Character
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

	if not (humanoidRootPart and character.Parent) then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "RespawnEffect_" .. character.Name
	folder.Parent = workspace._WorldOrigin

	if player.SoundId then
		local sound = Instance.new("Sound")
		sound.SoundId = player.SoundId
		sound.PlayOnRemove = true
		sound.Parent = humanoidRootPart
		sound:Destroy()
	else
		Sound:Play(v[math.random(#v)], humanoidRootPart.Position)
	end

	local clone = script.EmitPart:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Parent = folder
	Debris:AddItem(folder, (math.max(emitParticles(clone), 1)))
	task.delay(0.22, function()
		local wrapHighlight = WrapHighlight(script.Highlight)

		if not (wrapHighlight and character.Parent) then
			return
		end

		local clone2 = wrapHighlight:Clone()
		clone2.FillColor = Color3.fromRGB(74, 198, 255)
		clone2.Parent = character
		Debris:AddItem(clone2, 0.7)
		TweenService:Create(clone2, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			FillTransparency = 1
		}):Play()
	end)
	task.wait(0.3)

	if not (character.Parent and folder.Parent) then
		return
	end

	local clone2 = script.RenderTemplate:Clone()
	local decal = clone2.Decal
	clone2.CFrame = humanoidRootPart.CFrame
	clone2.Mesh.Scale = createVector(0.15, 0.15, 0.15)
	clone2.Parent = folder
	TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Orientation = clone2.Orientation + createVector(0, 120, 0)
	}):Play()
	TweenService:Create(clone2.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = createVector(0.25, 0.25, 0.25)
	}):Play()
	task.delay(0.1, function()
		if not decal.Parent then
			return
		end

		TweenService:Create(decal, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)

	for i = 1, 16 do
		if clone2.Parent and decal.Parent then
			decal.Texture = clone2.MeshFlipbooks[i].Texture
			task.wait()
		else
			break
		end
	end

	clone2:Destroy()
end