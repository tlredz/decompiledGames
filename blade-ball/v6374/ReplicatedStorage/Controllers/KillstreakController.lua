local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Common.Utils)
local killstreakAuras = nil
local killstreakCounters = nil
local auras = nil
local charges = nil
local v2 = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local killstreakCounter = nil
local KillstreakController = {}

function KillstreakController:ChargeAura(instance, parent)
	if not parent then
		return
	end

	for _, child in instance:GetChildren() do
		local clone = child:Clone()
		clone.Parent = parent
		task.delay(10, function()
			if clone and clone:IsDescendantOf(workspace) then
				clone:Destroy()
			end
		end)

		for _, emitter in clone:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(10)
			end
		end
	end
end

function KillstreakController:UnpackAura(instance, instance2, _)
	local hatAttachment = instance:FindFirstChild("HatAttachment", true)
	local rightFootAttachment = instance:FindFirstChild("RightFootAttachment", true)

	if not (hatAttachment and rightFootAttachment) then
		return
	end

	local clone = instance2:Clone()
	clone.Attachment0 = hatAttachment
	clone.Attachment1 = rightFootAttachment
	clone.Parent = hatAttachment.Parent
	local clones = v2[instance]

	if clones then
		table.insert(clones, clone)
	else
		v2[instance] = { clone }
	end

	task.delay(1, function()
		if clone and clone:IsDescendantOf(workspace) then
			TweenService:Create(clone, TweenInfo.new(0.25), {
				Brightness = 0
			}):Play()
		end
	end)
end

function KillstreakController:ApplyAura(p, p2)
	if not p then
		return
	end

	self:UnpackAura(p, p2)
end

function KillstreakController:RemoveAura(player)
	local character = player.Character

	if not character then
		return
	end

	local v3 = v2[character]

	if v3 then
		for _, v4 in v3 do
			if v4 and v4:IsDescendantOf(workspace) then
				v4:Destroy()
			end
		end

		v2[character] = nil
	end
end

function KillstreakController:AnimateCounter(p)
	local child = killstreakCounters:FindFirstChild((`KillsStreak_{p}`))

	if not (p and child) then
		return
	end

	killstreakCounter:ClearAllChildren()
	child:FindFirstChild("TextLabel")
	local clone = child:Clone()
	local textLabel = clone:FindFirstChild("TextLabel")
	local tween = TweenService:Create(clone, TweenInfo.new(0.2), {
		Position = child.Position
	})
	local tween2 = TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Bounce), {
		Size = textLabel.Size
	})
	clone.Position -= UDim2.fromScale(0, 0.2)
	textLabel.Size += UDim2.fromScale(1.4, 1.4)
	tween:Play()
	tween2:Play()
	task.delay(0.8, function()
		local tween3 = TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
			Size = UDim2.fromScale(0.5, 0.5),
			ImageTransparency = 1
		})
		local tween4 = TweenService:Create(textLabel, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
			Size = UDim2.fromScale(6, 6),
			TextTransparency = 1
		})
		task.wait(0.5)
		tween3:Play()
		tween4:Play()
	end)
	clone.Parent = killstreakCounter
end

function KillstreakController:CheckPlayerCharacter(player)
	local character = player.Character

	if not character then
		return
	end

	local killstreakChangedConnection = character:GetAttributeChangedSignal("Killstreak"):Connect(function()
		self:RemoveAura(player)
		local killstreak = character:GetAttribute("Killstreak")

		if killstreak then
			local _ = player == Players.LocalPlayer
		end

		if not killstreak or killstreak < 2 then
			return
		end

		local child = auras:FindFirstChild(killstreak)
		local child2 = charges:FindFirstChild(killstreak)

		if child then
			self:ApplyAura(character, child)
		end

		if child2 then
			self:ChargeAura(child2, character:FindFirstChild("HumanoidRootPart"))
		end

		if player == Players.LocalPlayer then
			self:AnimateCounter(killstreak)
		end
	end)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = character.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			ancestryChangedConnection:Disconnect()
			killstreakChangedConnection:Disconnect()
			ancestryChangedConnection = nil
			killstreakChangedConnection = nil
		end
	end)
end

function KillstreakController:ConnectPlayerEvents(p)
	p.CharacterAdded:Connect(function()
		self:CheckPlayerCharacter(p)
	end)
	p.CharacterRemoving:Connect(function(character)
		v2[character] = nil
	end)
end

function KillstreakController:CheckAllPlayers()
	for _, v3 in Players:GetPlayers() do
		self:CheckPlayerCharacter(v3)
		self:ConnectPlayerEvents(v3)
	end
end

function KillstreakController:PlayerRemoving(p)
	self:RemoveAura(p)
end

function KillstreakController.Init(_) end

function KillstreakController:Start()
	killstreakAuras = ReplicatedStorage2.Misc.KillstreakAuras
	killstreakCounters = ReplicatedStorage2.Misc.KillstreakCounters
	auras = killstreakAuras:WaitForChild("Auras")
	charges = killstreakAuras:WaitForChild("Charges")
	killstreakCounter = playerGui:WaitForChild("KillstreakCounter")
	self:CheckAllPlayers()
	Players.PlayerAdded:Connect(function(player)
		self:CheckPlayerCharacter(player)
		self:ConnectPlayerEvents(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:PlayerRemoving(player)
	end)
	v.Thread.Every(10, function()
		for k in v2 do
			if k.Parent == nil then
				v2[k] = nil
			end
		end
	end)
end

return KillstreakController