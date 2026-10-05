local createVector = vector.create
local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Modules.Util.Signal)
local RepairShip = require(game.ReplicatedStorage.Controllers.UI.RepairShip)
local v = nil
task.spawn(function()
	local IsPointInsideShipBounds = require(game.ReplicatedStorage:WaitForChild("IsPointInsideShipBounds"))
	v = IsPointInsideShipBounds
end)
local localPlayer = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, -1, false, 0)
local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true, 1)
local v2 = Component.new({
	Tag = "RepairHammer",
	Ancestors = { workspace },
	Extensions = {
		{
			ShouldConstruct = function(p)
				return p.Instance:GetAttribute("OwnerId") == localPlayer.UserId
			end
		}
	}
})

function v2:Freeze(p)
	if p then
		if self.freeze or self.destroyed then
			return
		end

		if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
			local freeze = BodyMover.new(localPlayer.Character):Create("BodyPosition", {
				MaxForce = createVector(30000000, 0, 30000000),
				Position = localPlayer.Character.HumanoidRootPart.Position,
				Priority = 1e999
			})
			self.freeze = freeze

			if freeze then
				self.trove:Add(freeze)
			end
		end
	else
		if self.freeze and not self.trove._cleaning then
			self.trove:Remove(self.freeze)
		end

		self.freeze = nil
	end
end

function v2:Construct()
	self.trove = Trove.new()
	self.trove:Add(function()
		self.destroyed = true
		self.holding = false
		self.down = false
		self.marker = nil
		self.surfaceGui = nil
		self.attachment = nil
		self.humanoid = nil
		self:Freeze(false)
		RepairShip:Cleanup()
		RepairShip:SetButtonColor()
	end)
	self.markerInVoid = true
	self.destroyed = false
	self.last = 1
	self.mode = "Default"
	self.down = false
	self.holding = false
	self.data = self.Instance:GetAttributes()
end

function v2:Start()
	local instance = self.Instance
	local attachment = instance:WaitForChild("Marker").Value

	if self.destroyed then
		return
	end

	local maid = nil

	local function updateState()
		if maid then
			maid:Destroy()
		end

		if self.destroyed then
			return
		end

		if instance:GetAttribute("Repairing") then
			RepairShip.new(self)
			maid = self.trove:Extend()
			maid:Add(function()
				maid = nil

				if RepairShip.mode == "Default" then
					RepairShip:Cleanup()
				end
			end)

			local function restartSequence()
				if self.down then
					RepairShip:Start()
					return
				end

				if RepairShip.mode == "Minigame" then
					RepairShip:Start()
				end

				RepairShip:M1Up()
			end

			if self.down then
				RepairShip:Start()
			else
				if RepairShip.mode == "Minigame" then
					RepairShip:Start()
				end

				RepairShip:M1Up()
			end

			maid:Add(instance:GetAttributeChangedSignal("Restart"):Connect(restartSequence))
		end
	end

	updateState()
	self.trove:Add(instance:GetAttributeChangedSignal("Repairing"):Connect(updateState))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onEnded()
		self.holding = false
		self:Freeze(false)

		if not self.down then
			return
		end

		self.down = false
		RepairShip:M1Up()
	end

	local network = instance:FindFirstChild("Network")

	if network then
		local _Handle = instance:FindFirstChild("_Handle")
		self.trove:Add(network.OnClientEvent:Connect(function(p)
			if p.Sound and _Handle then
				local Util = require(game.ReplicatedStorage.Util)
				Util.Sound:Play(p.Sound, _Handle, 100)
			elseif p.Freeze then
				if self.holding and p.Freeze == 1 then
					self:Freeze(true)
				elseif p.Freeze == 0 and self.holding then
					onEnded() -- equivalent call inferred; original call site unknown
				end
			end
		end))
	end

	self.trove:Add(game.ReplicatedStorage.PlayerJumpAttempted.Event:Connect(function()
		self.holding = false
		self:Freeze(false)

		if not self.down then
			return
		end

		self.down = false
		RepairShip:M1Up()
	end))
	local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		self.trove:Add(humanoid.StateEnabledChanged:Connect(function(p, p2)
			if p == Enum.HumanoidStateType.Seated and not p2 then
				self.Instance.Cleanup:FireServer()
			end
		end))
	end

	self.trove:Add(UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed or self.destroyed then
			return
		end

		if UserInputService.GamepadEnabled then
			if input.KeyCode ~= Enum.KeyCode.ButtonR2 then
				return
			end
		elseif input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		onEnded() -- equivalent call inferred; original call site unknown
	end))
	self.trove:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or self.destroyed then
			return
		end

		if UserInputService.GamepadEnabled then
			if input.KeyCode ~= Enum.KeyCode.ButtonR2 then
				return
			end
		elseif input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		self.holding = true

		if self.down then
			return
		end

		local total = 0

		while total < self.data.MinSwingTime and self.holding do
			total += task.wait()
		end

		if self.holding and not self.destroyed then
			self.down = true
			self.Instance.M1Down:FireServer(self.mode)
		end
	end))

	if self.data.MiniGameCanBeEnabled then
		local part = Instance.new("Part")
		self.trove:Add(part)
		part.Transparency = 1
		part.Name = "MiniGameMarker"
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = true
		part.Massless = true
		part.Size = Vector3.new(self.data.MiniGameRadius, 0, self.data.MiniGameRadius)
		part.Parent = workspace._WorldOrigin
		self.marker = part
		self.attachment = attachment
		local surfaceGui = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshEnabled()
			if not surfaceGui then
				surfaceGui = instance:FindFirstChildOfClass("SurfaceGui")
			end

			if surfaceGui then
				local miniGameEnabled = instance:GetAttribute("MiniGameEnabled") == true
				surfaceGui.Adornee = part
				surfaceGui.Enabled = miniGameEnabled
				self.surfaceGui = surfaceGui
			end
		end

		local function updateMiniGameProgress()
			if RepairShip.mode == "Minigame" then
				local miniGameProgress = instance:GetAttribute("MiniGameProgress")
				local miniGameGoal = instance:GetAttribute("MiniGameGoal")
				local miniGameHP = instance:GetAttribute("MiniGameHP")
				local formatted = (" %d/%d"):format(miniGameProgress, miniGameGoal)
				RepairShip.gui.Label.Text = ("+ %d HP"):format(miniGameHP) .. formatted
			end
		end

		refreshEnabled() -- equivalent call inferred; original call site unknown
		self.trove:Add(instance:GetAttributeChangedSignal("MiniGameEnabled"):Connect(refreshEnabled))
		updateMiniGameProgress()
		self.trove:Add(instance:GetAttributeChangedSignal("Update"):Connect(updateMiniGameProgress))
	end

	self.trove:Add(instance:GetAttributeChangedSignal("Update"):Connect(function()
		self.data = instance:GetAttributes()
	end))
end

function v2:Stop()
	if self.trove then
		self.trove:Destroy()
		self.trove = nil
	end
end

function v2:RenderSteppedUpdate(_)
	if self.destroyed then
		return
	end

	local miniGameEnabled = self.data.MiniGameEnabled

	if self.marker then
		if self.attachment and miniGameEnabled then
			self.markerInVoid = false
			local value = self.Instance.Boat.Value
			local primaryPart = value and value.PrimaryPart
			self.marker.Orientation = primaryPart and primaryPart.Orientation or CFrame.new()
			self.marker.Position = self.attachment.WorldPosition
		elseif not self.markerInVoid then
			self.markerInVoid = true
			self.marker.Position = Vector3.new(0, -math.max(1 + workspace.FallenPartsDestroyHeight, -999), 0)
		end
	end

	debug.profilebegin("RepairHammer: Position")

	if tick() - self.last >= 0.2 then
		self.last = tick()
		local humanoid = self.humanoid or localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
		local primaryPart = localPlayer.Character.PrimaryPart
		local position = primaryPart and primaryPart.Position
		self.humanoid = humanoid

		if self.data.MiniGameCanBeEnabled == true then
			local surfaceGui = self.surfaceGui

			if surfaceGui and self.attachment then
				local v3 = primaryPart.Size.Y * 1.1 + (humanoid and humanoid.HipHeight or 0)
				local v4 = (not miniGameEnabled and 1e999 or (self.attachment.WorldPosition - position).Magnitude or 1e999) <= self.data.MiniGameRadius * 0.5 + v3

				if self.mode == "Minigame" or not v4 then
					if self.mode ~= "Default" and not v4 then
						self.mode = "Default"
						RepairShip:Close()
					end
				else
					self.mode = "Minigame"
					RepairShip.new(self)
					RepairShip:Open()
				end

				if miniGameEnabled and not (self.spinTween and self.squeezeTween) then
					if not self.spinTween then
						local TweenService = game:GetService("TweenService")
						self.spinTween = TweenService:Create(surfaceGui.OutterCircle, tweenInfo, {
							Rotation = 360
						})
						self.spinTween:Play()
					end

					if not self.squeezeTween then
						local TweenService = game:GetService("TweenService")
						self.squeezeTween = TweenService:Create(surfaceGui.InnerCircle, tweenInfo2, {
							Size = UDim2.fromScale(1.1, 1.1)
						})
						self.squeezeTween:Play()
					end
				elseif not miniGameEnabled and (self.spinTween or self.squeezeTween) then
					if self.spinTween then
						self.spinTween:Cancel()
					end

					if self.squeezeTween then
						self.squeezeTween:Cancel()
					end

					self.squeezeTween = nil
					self.spinTween = nil
					surfaceGui.OutterCircle.Rotation = 0
					surfaceGui.InnerCircle.Size = UDim2.new(1, 0, 1, 0)
				end

				surfaceGui.AlwaysOnTop = not v4
			end
		end

		if position and v then
			local value = self.Instance.Boat.Value
			local v3 = value and v(position, value)

			if value and not v3 then
				self.Instance.Cleanup:FireServer()

				if self.trove then
					self.trove:Destroy()
					self.trove = nil
				end
			end
		end
	end

	debug.profileend()
end

return v2