local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TextChatService")
local Players = game:GetService("Players")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "GhostCharacter"
})
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v2 = false
local flag = false

function v:Construct()
	self._Janitor = Janitor.new()
	local ChatBubbleController = require(ReplicatedStorage.Modules.Client.Player.ChatBubbleController)
	v2 = ChatBubbleController
	local humanoidRootPart = self.Instance:WaitForChild("HumanoidRootPart")
	self.ghostHighlight = self.Instance:WaitForChild("GhostHighlight")
	self.vfxPart = self.Instance:WaitForChild("vfxPart")
	self.enterSound = self.vfxPart:WaitForChild("GhostEntered")
	self.exitSound = self.vfxPart:WaitForChild("GhostExited")
	self.jumpscareSound = self.vfxPart:WaitForChild("GhostJumpscare")
	self.aura1 = self.vfxPart:WaitForChild("Aura1")
	self.aura2 = humanoidRootPart:WaitForChild("Aura2")
	local playerFromCharacter = Players:GetPlayerFromCharacter(self.Instance)

	if playerFromCharacter and playerFromCharacter == Players.LocalPlayer then
		local all = v:GetAll()

		for _, v3 in all do
			if v3.Instance == self.Instance or self.isExitingEffect then
				continue
			end

			v3:SetTransparency(0.5)
			v3:SetGhostEffectsState(true)
		end
	end
end

function v:EnteredEffectLocalPlayer()
	flag = true
	self:SetGhostEffectsState(true)
	self.enterSound:Play()
	self:SetTransparency(0.5)
end

function v:EnteredEffectOthers()
	if self.isExitingEffect then
		return
	end

	local instance = self.Instance
	self.bubbleListener = v2.ConnectChatBubbleListener(function(p, _)
		if not p.TextSource or p.TextSource.UserId == Players.LocalPlayer.UserId or flag then
			return
		end

		local bubbleChatMessageProperties = Instance.new("BubbleChatMessageProperties")
		bubbleChatMessageProperties.BackgroundTransparency = 1
		bubbleChatMessageProperties.TextSize = 0
		return bubbleChatMessageProperties
	end)
	local humanoid = instance:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.NameDisplayDistance = 0
	end

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	self:SetGhostEffectsState(true)
	self.enterSound:Play()
	self:SetTransparency(1)
	self.endEffectInitial = task.delay(0.5, function()
		self.aura1.Enabled = false
		self.aura2.Enabled = false
		TweenService:Create(self.ghostHighlight, tweenInfo, {
			FillTransparency = 1
		}):Play()
	end)
end

function v:InstantlyApplyGhostEffects()
	if self.isExitingEffect then
		return
	end

	local instance = self.Instance
	self.bubbleListener = v2.ConnectChatBubbleListener(function(p, _)
		if not p.TextSource or p.TextSource.UserId == Players.LocalPlayer.UserId or flag then
			return
		end

		local bubbleChatMessageProperties = Instance.new("BubbleChatMessageProperties")
		bubbleChatMessageProperties.BackgroundTransparency = 1
		bubbleChatMessageProperties.TextSize = 0
		return bubbleChatMessageProperties
	end)
	local humanoid = instance:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.NameDisplayDistance = 0
	end

	self.ghostHighlight.FillTransparency = 1
	self.ghostHighlight.Enabled = true
	self.ghostHighlight.FillTransparency = 1
	self.aura1.Enabled = false
	self.aura2.Enabled = false
	self:SetTransparency(1, true)
end

function v:SetGhostEffectsState(enabled: boolean)
	self.ghostHighlight.FillTransparency = 1
	self.ghostHighlight.Enabled = enabled
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(self.ghostHighlight, tweenInfo, {
		FillTransparency = enabled and 0.5 or 1
	}):Play()
	self.aura1.Enabled = enabled
	self.aura2.Enabled = enabled
end

function v:SetTransparency(currentTransparency: number, flag2: boolean)
	if self.isExitingEffect then
		return
	end

	self.currentTransparency = currentTransparency
	local tweenInfo = TweenInfo.new(flag2 and 0 or 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	for _, child in self.Instance:GetChildren() do
		if child:IsA("MeshPart") then
			TweenService:Create(child, tweenInfo, {
				Transparency = currentTransparency
			}):Play()

			for _, descendant in child:GetDescendants() do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("Decal") then
					TweenService:Create(descendant, tweenInfo, {
						Transparency = currentTransparency
					}):Play()
				end
			end
		elseif child:IsA("Accessory") then
			local meshPart = child:FindFirstChildOfClass("MeshPart")

			if meshPart then
				TweenService:Create(meshPart, tweenInfo, {
					Transparency = currentTransparency
				}):Play()
			end

			for _, descendant in child:GetDescendants() do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("Decal") then
					TweenService:Create(descendant, tweenInfo, {
						Transparency = currentTransparency
					}):Play()
				end
			end
		end
	end
end

function v:ExitedEffect()
	self.exitSound:Play()
	self:SetTransparency(0)
	self:SetGhostEffectsState(true)
	task.delay(1, function()
		if self.Instance.Parent == nil then
			return
		end

		self:SetGhostEffectsState(false)
	end)
	self.isExitingEffect = true
end

function v:Jumpscare()
	self.jumpscareSound:Play()
	self:SetTransparency(0, true)
	self:SetGhostEffectsState(false)
	self.isExitingEffect = true
	self.aura1:Emit(5)
	self.aura2:Emit(5)
end

function v.SendToServerNormalExit(p)
	if Players:GetPlayerFromCharacter(p.Instance) then
		Remotes.fireServerComponent(p.Instance, "NormalExit")
	end
end

function v.SendToServerJumpscareGhost(p)
	if Players:GetPlayerFromCharacter(p.Instance) then
		Remotes.fireServerComponent(p.Instance, "JumpscareGhost")
	end
end

function v:Start()
	local instance = self.Instance
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local v3 = workspace:GetServerTimeNow() - (self.Instance:GetAttribute("TimeEntered") or 0)
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "RemoveEffect", function(p)
		if p then
			self:Jumpscare()
		else
			self:ExitedEffect()
		end
	end))

	if playerFromCharacter == Players.LocalPlayer then
		self:EnteredEffectLocalPlayer()
	elseif flag then
		self:SetGhostEffectsState(true)
		self:SetTransparency(0.5)
	elseif v3 > 3 then
		self:InstantlyApplyGhostEffects()
	else
		self:EnteredEffectOthers()
	end

	self._Janitor:Add(instance.ChildAdded:Connect(function(accessory)
		if not accessory:IsA("Accessory") then
			return
		end

		local meshPart = accessory:FindFirstChildOfClass("MeshPart")

		if meshPart and self.currentTransparency then
			meshPart.Transparency = self.currentTransparency
		end
	end))
end

function v:Stop()
	if self.bubbleListener then
		self.bubbleListener:Disconnect()
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(self.Instance)

	if playerFromCharacter and playerFromCharacter == Players.LocalPlayer then
		flag = false

		for _, v3 in v:GetAll() do
			if v3.Instance == self.Instance or v3.isExitingEffect then
				continue
			end

			v3:SetTransparency(1, false)
			v3:SetGhostEffectsState(false)
		end
	end

	self:SetTransparency(0, true)
	self:SetGhostEffectsState(false)
	self._Janitor:Destroy()
end

return v