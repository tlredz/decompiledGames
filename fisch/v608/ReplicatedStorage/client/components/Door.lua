local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local Shake = require(packages.Shake)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local NotificationController = require(legacyControllers:WaitForChild("NotificationController"))
local SettingsController = require(legacyControllers:WaitForChild("SettingsController"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local remoteEvent = Net:RemoteEvent("DoorRemote", -1)
local remoteEvent2 = Net:RemoteEvent("VenueHatchUpdate", -1)
legacyLocalPlayerData.fetch():WaitForChild("Cache")
local v = Component.new({
	Tag = "Door"
})

local function GetCharacter(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return character, humanoidRootPart
	end
end

function v:SteppedUpdate(_: number)
	if self.opened == true then
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			character = nil
			humanoidRootPart = nil
		end
	else
		character = nil
	end

	if not character then
		return
	end

	if self.closedTip then
		self.onArea = self.onArea ~= nil and (self.onArea or false)
		local magnitude = (self.Instance.Root.Position - humanoidRootPart.Position).Magnitude

		if self.onArea == true then
			if magnitude >= 30 then
				self.onArea = false
			end
		elseif magnitude <= 15 then
			self.onArea = true
			NotificationController:Notify(self.closedTip, 5)
		end
	end
end

function v:ForceState(flag: boolean)
	if self.Instance.Name == "VenueHatch" then
		local venueHatchOpen = flag and self.Instance.Parent:FindFirstChild("VenueHatchOpen")

		if venueHatchOpen then
			for _, part in venueHatchOpen:GetDescendants() do
				if part:IsA("BasePart") or part:IsA("MeshPart") then
					part.Transparency = 0
				end
			end

			if self.Instance.Parent then
				self.Instance:Destroy()
			end
		end
	else
		for k, position in self.positions do
			k.C0 = position[flag]
		end

		for k, transparency in self.transparencies do
			k.Transparency = transparency[flag]

			if not k:GetAttribute("DisableCollisionWhenTransparent") then
				continue
			end

			k.CanCollide = not flag
			k.CanQuery = not flag
			k.CanTouch = not flag
		end
	end
end

function v:Toggle(opened: boolean)
	if not (self.Instance.Name ~= "VenueHatch" and self.opened ~= opened) then
		return
	end

	self.opened = opened
	local v2 = 0

	for k, position in self.positions do
		local toggleTime = k:GetAttribute("ToggleTime") or 1

		if v2 <= toggleTime then
			v2 = toggleTime
		end

		TweenService:Create(k, TweenInfo.new(toggleTime, Enum.EasingStyle[k:GetAttribute("TweenStyle") or "Linear"]), {
			C0 = position[opened]
		}):Play()
	end

	for k, transparency in self.transparencies do
		local toggleTime = k:GetAttribute("ToggleTime") or 1

		if v2 <= toggleTime then
			v2 = toggleTime
		end

		TweenService:Create(k, TweenInfo.new(toggleTime, Enum.EasingStyle[k:GetAttribute("TweenStyle") or "Linear"]), {
			Transparency = transparency[opened]
		}):Play()

		if not k:GetAttribute("DisableCollisionWhenTransparent") then
			continue
		end

		k.CanCollide = not opened
		k.CanQuery = not opened
		k.CanTouch = not opened
	end

	for _, descendant in self.Instance:GetDescendants() do
		if descendant:IsA("Sound") then
			if descendant.Name == "Toggle" then
				descendant:Play()
			end

			if opened == true then
				if descendant.Name == "Open" then
					descendant:Play()
				end
			elseif descendant.Name == "Close" then
				descendant:Play()
			end
		elseif descendant:IsA("ParticleEmitter") then
			if descendant:GetAttribute("EnabledParticle") then
				descendant.Enabled = true
				local v3 = descendant
				task.delay(v2, function()
					v3.Enabled = false
				end)
			else
				local emitCount = descendant:GetAttribute("EmitCount") or 1
				local emitDelay = descendant:GetAttribute("EmitDelay") or 0

				if emitDelay == 0 then
					descendant:Emit(emitCount)
				else
					local v3 = descendant
					local v4 = emitCount
					task.delay(emitDelay, function()
						v3:Emit(v4)
					end)
				end
			end
		end
	end

	if self.Instance:GetAttribute("ShakeCamera") then
		if not SettingsController:GetSettingValue("cameraShake") then
			return
		end

		local currentCamera = workspace.CurrentCamera
		local value = Enum.RenderPriority.Last.Value
		local v3 = Shake.new()
		v3.FadeInTime = v2 * 0.05
		v3.FadeOutTime = v2 * 0.25
		v3.Frequency = 0.1
		v3.Amplitude = self.Instance:GetAttribute("ShakeAmplitude") or 1.5
		v3.SustainTime = v2 * 0.7
		v3.Sustain = true
		v3.RotationInfluence = createVector(0.1, 0.1, 0.1)
		v3:Start()
		v3:BindToRenderStep(Shake.NextRenderName(), value, function(position, data, _)
			currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data.X, data.Y, data.Z)
		end)
		task.delay(v2, function()
			v3:Destroy()
		end)
	end
end

function v:Construct()
	self.trove = Trove.new()
	self.positions = {}
	self.transparencies = {}
	self.opened = false
	self.closedTip = self.Instance:GetAttribute("ClosedTip")
	local welds = self.Instance:FindFirstChild("Welds")

	if welds then
		for _, weld in welds:GetChildren() do
			if not weld:IsA("Weld") then
				continue
			end

			self.positions[weld] = {}
			self.positions[weld][false] = weld.C0
			self.positions[weld][true] = weld:GetAttribute("OpenedCFrame") or weld.C0
		end
	end

	for _, part in self.Instance:GetDescendants() do
		if not (part:IsA("BasePart") and part:GetAttribute("OpenedTransparency")) then
			continue
		end

		self.transparencies[part] = {}
		self.transparencies[part][false] = part.Transparency
		self.transparencies[part][true] = part:GetAttribute("OpenedTransparency")
	end

	if self.Instance.Name == "VenueHatch" then
		local venueHatchOpen = self.Instance.Parent:FindFirstChild("VenueHatchOpen")

		if venueHatchOpen then
			for _, part in venueHatchOpen:GetDescendants() do
				if part:IsA("BasePart") or part:IsA("MeshPart") then
					part.Transparency = 1
				end
			end
		else
			warn("Door:Construct - VenueHatchOpen not found for VenueHatch")
		end
	end
end

function v:Start()
	local opened = Net:RemoteFunction("GetDoorState"):InvokeServer(self.Instance.Name)
	self.opened = opened
	self:ForceState(opened)
	self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p: string, flag: boolean)
		if p == self.Instance.Name then
			if flag == true and self.opened == true then
				return
			else
				self:Toggle(flag)
			end
		end
	end))
	self.trove:Add(remoteEvent2.OnClientEvent:Connect(function(flag: boolean)
		if self.Instance.Name ~= "VenueHatch" then
			return
		end

		if flag then
			local venueHatchOpen = self.Instance.Parent:FindFirstChild("VenueHatchOpen")

			if venueHatchOpen then
				for _, part in venueHatchOpen:GetDescendants() do
					if part:IsA("BasePart") or part:IsA("MeshPart") then
						part.Transparency = 0
					end
				end

				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://98748827592084"
				sound.Volume = 0.6
				sound.Parent = SoundService
				sound:Play()
				sound.Ended:Connect(function()
					sound:Destroy()
				end)

				if self.Instance.Parent then
					self.Instance:Destroy()
				end
			else
				warn("Door:VenueHatchUpdate - VenueHatchOpen not found")
			end
		end
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v