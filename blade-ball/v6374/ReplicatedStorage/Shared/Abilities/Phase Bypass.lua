local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
require3(ReplicatedStorage2.Misc.LightningBolt)
require3(ReplicatedStorage2.Misc.LightningBolt.LightningSparks)
local v = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v2 = require3(ReplicatedStorage2.Shared.SpeedModifiers)
local PhaseBypass = {}
PhaseBypass.cooldown = 40
PhaseBypass.iconId = "rbxassetid://14776121858"

function PhaseBypass.localOwnerActivation(p, p2)
	if RunService:IsClient() then
		TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			FieldOfView = 84
		}):Play()
		game.Lighting.cc2.Enabled = true
	end

	local pivot = p.character:GetPivot()

	local function cleanup()
		v2:RemoveModifierFor(p.character, "PhaseBypass")

		if p.character.Parent ~= workspace.Alive or p.humanoid.Health <= 0 then
			return
		end

		p.character:PivotTo(pivot)

		if RunService:IsClient() then
			TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				FieldOfView = 70
			}):Play()
			game.Lighting.cc2.Enabled = false
		end
	end

	task.delay(3, cleanup)
	p2.addCleaner(cleanup)
	v2:SetModifierFor(p.character, "PhaseBypass", function(p3: number, _)
		return p3 + 84
	end, v2.Priority.ADD)
	return nil
end

function PhaseBypass.anyClientActivationAsync(p, p2)
	local DELAY_DURATION = 3
	v({
		cframe = p.rootPart.CFrame,
		diameter = 30,
		color = Color3.fromRGB(155, 108, 255),
		orientation = "Forward"
	})
	task.spawn(function()
		local v3 = workspace:GetServerTimeNow() + 2

		while workspace:GetServerTimeNow() < v3 do
			task.wait(0.03)
			local color = Color3.fromRGB(160, 105, 255)

			if math.random() < 0.15 then
				color = Color3.fromRGB(0, 255, 64)
			end

			for _, part in p.character:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = part:Clone()
				clone.Color = color
				clone.Transparency = 1 - (1 - clone.Transparency) * 0.9
				local clone2 = part:Clone()
				clone2.Color = Color3.fromRGB(14, 0, 26)

				for _, v4 in { clone, clone2 } do
					v4:ClearAllChildren()
					v4.CastShadow = false
					v4.Material = Enum.Material.Neon
					v4.CanCollide = false
					v4.CanTouch = false
					v4.CanQuery = false
					v4.Anchored = true
					v4.Parent = workspace.Runtime
					Debris:AddItem(v4, 0.4)
					TweenService:Create(v4, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Size = createVector(0, 0, 0),
						Position = clone.Position + Vector3.new(
							(math.random() - 0.5) * 2,
							(math.random() - 0.5) * 2,
							(math.random() - 0.5) * 2
						)
					}):Play()
				end
			end
		end
	end)

	for _, part in p.character:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()
		clone:ClearAllChildren()
		clone.Color = Color3.fromRGB(0, 255, 72)
		clone.Material = Enum.Material.Neon
		clone.Transparency = 1 - (1 - clone.Transparency) * 0.6
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.CastShadow = false
		clone.Anchored = true
		clone.Parent = workspace.Runtime
		Debris:AddItem(clone, 4.5)

		local function cleanup()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = clone.Size * 3
			}):Play()
		end

		task.delay(DELAY_DURATION, cleanup)
		p2.addCleaner(cleanup)
	end

	local torso = p.character:FindFirstChild("Torso")

	if torso and torso:IsA("BasePart") then
		local clone = ReplicatedStorage2.Misc.PhaseBP:Clone()
		clone.Parent = torso
		clone.CFrame = torso.CFrame
		clone.WeldConstraint.Part1 = torso
		clone.Attachment.ParticleEmitter.Enabled = true
		Debris:AddItem(clone, 5)

		local function cleanup()
			if not clone.Parent then
				return
			end

			clone.Attachment.ParticleEmitter.Enabled = false
			clone.ParticleEmitter.Enabled = false
			clone.Particle2.Enabled = false
		end

		task.delay(DELAY_DURATION, cleanup)
		p2.addCleaner(cleanup)
	end

	local clone = ReplicatedStorage2.Misc.PhaseBP:Clone()
	clone.Parent = p.rootPart
	clone.CFrame = p.rootPart.CFrame
	clone.WeldConstraint.Part1 = p.rootPart
	clone.CyberStep:Play()
	clone.Step:Play()
	task.delay(DELAY_DURATION, function()
		clone.Step:Play()
		clone.ParticleEmitter.Enabled = false
		clone.Particle2.Enabled = false
		v({
			cframe = p.rootPart.CFrame,
			diameter = 30,
			color = Color3.fromRGB(0, 255, 42),
			orientation = "Forward"
		})
	end)
end

return PhaseBypass