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
local v = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v2 = require3(ReplicatedStorage2.Shared.SpeedModifiers)

if RunService:IsServer() then
	function script.RagingDeflectionCollisionResponse.OnInvoke(instance, _, data)
		if not instance:GetAttribute("IsRagingDeflection") then
			return "Continue"
		end

		instance:SetAttribute("IsRagingDeflection", nil)
		data.Parry:Invoke(instance)
		data.SetSpeed:Invoke(data.GetSpeed:Invoke() + 40 + 34 * instance:GetAttribute("RagingDeflectionLevel") / 2)
		return "CancelAndInvalidate"
	end

	workspace.Balls.ChildAdded:Connect(function(child)
		if not require3(ReplicatedStorage2.Shared.UseBall2)() then
			return
		end

		child.AddCustomCollisionResponse:Invoke(script.RagingDeflectionCollisionResponse, 60)
	end)
end

local RagingDeflection = {}
RagingDeflection.cooldown = 30
RagingDeflection.cooldownReductionPerUpgrade = 4.375
RagingDeflection.iconId = "rbxassetid://14521129740"

function RagingDeflection.localOwnerActivation(data)
	ReplicatedStorage2.Remotes.M1Stop:Fire(true)
	local isRagingDeflectionChangedConnection = nil
	isRagingDeflectionChangedConnection = data.character:GetAttributeChangedSignal("IsRagingDeflection"):Connect(function()
		if data.character:GetAttribute("IsRagingDeflection") then
			return
		end

		isRagingDeflectionChangedConnection:Disconnect()
		ReplicatedStorage2.Remotes.M1Stop:Fire(false)
	end)
	local track = data.animator:LoadAnimation(script.AttemptAnimation)
	track:Play()
	task.delay(0.5 + data.upgradeLevel * 0.5 / 4, function()
		ReplicatedStorage2.Remotes.M1Stop:Fire(false)
		track:Stop(0.1)
	end)
	return nil
end

function RagingDeflection.serverActivationAsync(data)
	if data.character:GetAttribute("IsRagingDeflection") then
		return
	end

	local v3 = v2:SetModifierFor(
		data.character,
		"RagingDeflection",
		v2.Utils.MinDebuff(data.character, 0),
		v2.Priority.DEBUFF
	)
	local v4 = 0.5 + data.upgradeLevel * 0.5 / 4
	data.character:SetAttribute("RagingDeflectionLevel", data.upgradeLevel)
	data.character:SetAttribute("IsRagingDeflection", true)
	local highlight

	if data.upgradeLevel >= 2 then
		if data.character:FindFirstChild("Bobber", true) then
			highlight = Instance.new("Highlight")
			highlight.Name = "BobaDeflectHighlight"
		else
			highlight = Instance.new("Highlight")
			highlight.Name = "MaxRagingDeflectHighlight"
		end

		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = Color3.fromRGB(0, 60, 255)
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(0, 60, 255)
	else
		highlight = Instance.new("Highlight")
		highlight.Name = "RagingDeflectHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	end

	highlight.OutlineTransparency = 0.8
	highlight.Parent = data.character
	Debris:AddItem(highlight, 0.55)
	TweenService:Create(highlight, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		OutlineTransparency = 0
	}):Play()
	task.delay(v4 - 0.05, function()
		TweenService:Create(highlight, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			OutlineTransparency = 0.8
		}):Play()
	end)
	local clone

	if data.upgradeLevel >= 2 then
		if data.character:FindFirstChild("Bobber", true) then
			clone = ReplicatedStorage2.Misc.BobaDeflectionAttempt:Clone()
		else
			clone = ReplicatedStorage2.Misc.MaxRagingDeflectionAttempt:Clone()
		end
	else
		clone = ReplicatedStorage2.Misc.RagingDeflectionAttempt:Clone()
	end

	clone.Parent = data.rootPart
	clone.CFrame = data.rootPart.CFrame
	clone.WeldConstraint.Part1 = data.rootPart
	Debris:AddItem(clone, 3)
	local headpart = clone.Headpart
	local head = data.character:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		headpart.Parent = head
		headpart.CFrame = head.CFrame
		headpart.WeldConstraint.Part1 = head
		headpart.At.ParticleEmitter:Emit(1)
	else
		headpart:Destroy()
	end

	clone.OniCharge:Play()
	local isRagingDeflectionChangedConnection = nil
	isRagingDeflectionChangedConnection = data.character:GetAttributeChangedSignal("IsRagingDeflection"):Connect(function()
		if data.character:GetAttribute("IsRagingDeflection") then
			return
		end

		isRagingDeflectionChangedConnection:Disconnect()
		highlight:Destroy()
		v3()
		local torso = data.character:FindFirstChild("Torso")

		if torso and torso:IsA("BasePart") then
			local clone2

			if data.upgradeLevel >= 2 then
				if data.character:FindFirstChild("Bobber", true) then
					clone2 = ReplicatedStorage2.Misc.BobaDeflectionSuccess:Clone()
				else
					clone2 = ReplicatedStorage2.Misc.MaxRagingDeflectionSuccess:Clone()
				end
			else
				clone2 = ReplicatedStorage2.Misc.RagingDeflectionSuccess:Clone()
			end

			clone2.Parent = torso
			clone2.Position = torso.Position
			clone2.Orientation = Vector3.new(torso.Orientation.X, torso.Orientation.Y, 45)
			Debris:AddItem(clone2, 4)
			local swordshinies = clone2.swordshinies
			swordshinies.Parent = torso.Parent:FindFirstChild("sord", true)
			swordshinies.Enabled = true
			Debris:AddItem(swordshinies, 2)
			task.delay(0.2, function()
				swordshinies.Enabled = false
			end)
			clone2.Parried:Play()
			clone2.hit:Play()

			if data.upgradeLevel >= 2 and data.character:FindFirstChild("Bobber", true) then
				clone2.At2.ParticleEmitter:Emit(4)
				clone2.At2.Flash1:Emit(2)
				clone2.At2.Flash2:Emit(1)
			else
				for _, emitter in clone2:GetChildren() do
					if emitter:IsA("ParticleEmitter") and emitter ~= swordshinies then
						emitter:Emit((tonumber(emitter.Name)))
					end
				end
			end

			local motor6D = data.character:QueryDescendants("Motor6D.SwordMotor")[1]
			local rightArm = data.character:FindFirstChild("Right Arm")

			if motor6D and motor6D:IsA("Motor6D") and rightArm and rightArm:IsA("BasePart") then
				motor6D.Parent = rightArm
				motor6D.Part0 = rightArm
				task.delay(1, function()
					motor6D.Parent = torso
					motor6D.Part0 = torso
				end)
			end
		end

		for _, v5 in data.animator:GetPlayingAnimationTracks() do
			if v5.Animation == script.AttemptAnimation then
				v5:Stop(0)
			end
		end

		data.animator:LoadAnimation(script.SuccessAnimation):Play(0)
		task.spawn(function()
			if data.upgradeLevel < 2 then
				v({
					cframe = data.rootPart.CFrame,
					diameter = 48,
					color = Color3.new(1, 0, 0),
					orientation = "Forward"
				})
			elseif data.character:FindFirstChild("Bobber", true) then
				v({
					cframe = data.rootPart.CFrame,
					diameter = 48,
					color = Color3.fromRGB(236, 128, 255),
					orientation = "Forward"
				})
			else
				v({
					cframe = data.rootPart.CFrame,
					diameter = 48,
					color = Color3.fromRGB(0, 81, 255),
					orientation = "Forward"
				})
			end
		end)
	end)
	task.wait(0.5 + data.upgradeLevel * 0.5 / 4)

	if not data.character:GetAttribute("IsRagingDeflection") then
		return
	end

	isRagingDeflectionChangedConnection:Disconnect()
	data.character:SetAttribute("IsRagingDeflection", nil)
	data.character:SetAttribute("RagingDeflectionLevel", nil)
	highlight:Destroy()
	v3()
end

function RagingDeflection.anyClientActivationAsync(data)
	local color = Color3.fromRGB(153, 0, 0)

	if data.upgradeLevel >= 2 then
		color = Color3.fromRGB(10, 0, 148)

		if data.character:FindFirstChild("Bobber", true) then
			color = Color3.fromRGB(123, 0, 148)
		end
	end

	for _, duration in { 0, 0.2, 0.1 } do
		task.wait(duration)

		if not data.character:GetAttribute("IsRagingDeflection") then
			break
		end

		v({
			cframe = data.rootPart.CFrame * CFrame.new(0, -2.5, 0),
			diameter = 25,
			duration = 0.6,
			color = color,
			reverse = true,
			orientation = "Vertical"
		})
	end
end

return RagingDeflection