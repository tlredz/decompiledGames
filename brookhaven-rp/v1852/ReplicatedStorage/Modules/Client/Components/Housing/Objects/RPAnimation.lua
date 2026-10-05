local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local InteractionsInfo = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionsInfo)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local InteractablesController = require(ReplicatedStorage.Modules.Client.Interactables.InteractablesController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local localPlayer = Players.LocalPlayer
local animationPlaying = nil
local v = nil
local v2 = Component.new({
	Tag = "RPAnimation"
})
local tracksByAnimationId = {}
local v3 = {}

function v2.SetLegacyAnimationCancel(callback)
	v = callback
end

function v2.ClearLegacyAnimationCancel(callback)
	if v == callback then
		v = nil
	end
end

function v2.CancelLegacyAnimation()
	if v ~= nil then
		v()
	end
end

function v2.CancelAllEnabled()
	for _, v4 in v2:GetAll() do
		if not v4:IsEnabled() then
			continue
		end

		Remotes.fireServerComponent(v4.Instance, "Stop")
		v4:End()
	end
end

local function jumpRequest(p, p2, _)
	if p ~= "JumpRequest" then
		return Enum.ContextActionResult.Pass
	end

	if p2 == Enum.UserInputState.Begin then
		if PanelController.IsOpen("MainGUIHandler", "HouseCam") then
			return Enum.ContextActionResult.Sink
		else
			v2.CancelAllEnabled()
		end
	end

	return Enum.ContextActionResult.Sink
end

function v2:Construct()
	animationPlaying = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("AnimationPlaying")
	self._Janitor = Janitor.new()
	self._type = self.Instance:GetAttribute("Type")
	self._enabled = false
	self._seatDebounce = false
end

function v2:Start()
	self._Janitor:AddPromise(InteractionPrompt:WaitForInstance(self.Instance):andThen(function(p)
		self._Janitor:Add(p.Interacted:Connect(function()
			if self._seatDebounce then
				return
			end

			v2.CancelLegacyAnimation()

			if not Remotes.invokeServerComponent(self.Instance, "Interact") then
				return
			end

			task.defer(function()
				self:Play()
			end)
		end))

		if (self.Instance:IsA("Seat") or self.Instance:IsA("VehicleSeat")) and self.Instance:GetAttribute("ActivateRPAnimOnSit") then
			self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Occupant"):Connect(function()
				if self.Instance.Occupant then
					local character = Players.LocalPlayer.Character

					if character and self.Instance.Occupant:IsDescendantOf(character) then
						InteractablesController.InteractWithOverride(p)
					end
				end
			end))
		end
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "Stop", function()
		self:End()
	end))
	self._Janitor:Add(UserInputService.JumpRequest:Connect(function()
		if not self:IsEnabled() then
			return
		end

		Remotes.fireServerComponent(self.Instance, "Stop")
		self:End()
	end))
	self._Janitor:Add(localPlayer.CharacterAdded:Connect(function()
		tracksByAnimationId = {}
	end))
end

function v2:Play()
	if self._enabled then
		return
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = character:FindFirstChild("Animator", true)

	if not (humanoid and humanoidRootPart and animator) then
		return
	end

	self._type = self.Instance:GetAttribute("Type")
	local v4 = InteractionsInfo[self._type]

	if not v4 or v4.DontLockPlayer then
		return
	end

	local animationId = v4 and v4.animationId

	if animationId then
		local track = tracksByAnimationId[animationId]

		if not track then
			local v5 = v3[animationId] or Instance.new("Animation")
			v5.Name = "RPanimation"
			v5.AnimationId = animationId
			v3[animationId] = v5
			track = animator:LoadAnimation(v5)
			tracksByAnimationId[animationId] = track
		end

		track:Play()
	end

	if self.Instance:IsA("Seat") or self.Instance:IsA("VehicleSeat") then
		self.Instance:Sit(humanoid)
		self._seatDebounce = true
	else
		humanoid.WalkSpeed = 0
		humanoidRootPart.CFrame = self.Instance.CFrame * CFrame.new(0, 0, -2)
	end

	ContextActionService:BindAction("JumpRequest", jumpRequest, false, Enum.KeyCode.Space)
	self._enabled = true
	animationPlaying.Value = true
end

function v2:End()
	if not self._enabled then
		return
	end

	self._enabled = false
	ContextActionService:UnbindAction("JumpRequest")

	if animationPlaying ~= nil then
		animationPlaying.Value = false
	end

	local character = localPlayer.Character
	local humanoid

	if character == nil then
		humanoid = false
	else
		humanoid = character:FindFirstChild("Humanoid")
	end

	local animator

	if character == nil then
		animator = false
	else
		animator = character:FindFirstChild("Animator", true)
	end

	if animator ~= nil then
		for _, v4 in animator:GetPlayingAnimationTracks() do
			if v4.Name == "RPanimation" then
				v4:Stop()
			end
		end
	end

	if humanoid ~= nil then
		if self.Instance:IsA("Seat") or self.Instance:IsA("VehicleSeat") then
			local seatWeld = self.Instance:FindFirstChild("SeatWeld")

			if seatWeld ~= nil then
				seatWeld:Destroy()
			end

			humanoid.Sit = false
			humanoid.Jump = true
			task.delay(2.5, function()
				self._seatDebounce = false
			end)
		else
			humanoid.WalkSpeed = 16
		end
	end
end

function v2:IsEnabled()
	return self._enabled
end

function v2:Stop()
	self:End()
	self._Janitor:Destroy()
end

return v2