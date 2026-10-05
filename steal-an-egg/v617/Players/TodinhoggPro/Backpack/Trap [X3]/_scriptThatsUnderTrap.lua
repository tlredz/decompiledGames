local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local AntiCheatService = require(ServerScriptService.Controllers.AntiCheatService)
local Audio = require(ReplicatedStorage.Shared.Audio)
require(ReplicatedStorage.Shared.Globals.Constants)
local GameplayToolGuard = require(ServerScriptService.Library.Tools.Internal.GameplayToolGuard)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ScriptThatsUnderTrap = {
	ScaleTo = function(primaryPart, p: number)
		local model = Instance.new("Model")
		primaryPart.Parent = model
		model.PrimaryPart = primaryPart
		model:ScaleTo(p)
		primaryPart.Parent = nil
		model:Destroy()
	end
}

function ScriptThatsUnderTrap:Install(p: number)
	local owner = self:GetAttribute("Owner")
	local v = false
	local v2 = {}
	local touchedConnection = nil
	local hitbox = self:WaitForChild("Hitbox")
	assert(hitbox:IsA("BasePart"), "Trap Hitbox must be a BasePart")
	self.CanTouch = true
	hitbox.CanTouch = true

	local function createTrapBillboard(instance)
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "TrapBillboard"
		billboardGui.Size = UDim2.fromScale(6, 3)
		billboardGui.StudsOffset = createVector(0, 3, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.MaxDistance = 50
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundTransparency = 1
		frame.Parent = billboardGui
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.fromScale(1, 0.4)
		textLabel.Position = UDim2.new(0, 0, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "TRAPPED"
		textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.Parent = frame
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Thickness = 2.5
		uIStroke.Parent = textLabel
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Size = UDim2.fromScale(1, 0.5)
		textLabel2.Position = UDim2.fromScale(0, 0.5)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = tostring(7) .. "s"
		textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel2.TextScaled = true
		textLabel2.Font = Enum.Font.SourceSansBold
		textLabel2.Parent = frame
		local uIStroke2 = Instance.new("UIStroke")
		uIStroke2.Thickness = 2.5
		uIStroke2.Parent = textLabel2
		local head = instance:FindFirstChild("Head")

		if head then
			billboardGui.Parent = head
		elseif instance.PrimaryPart then
			billboardGui.Parent = instance.PrimaryPart
		else
			billboardGui:Destroy()
			return nil
		end

		task.spawn(function()
			for i = 7, 1, -1 do
				if billboardGui and billboardGui.Parent then
					textLabel2.Text = tostring(i) .. "s"
					task.wait(1)
				else
					break
				end
			end

			if billboardGui and billboardGui.Parent then
				billboardGui:Destroy()
			end
		end)
		return billboardGui
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getModelHeight(instance)
		if instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart then
			local _, v3 = instance:GetBoundingBox()
			return v3.Y / 2
		end

		error("HumanoidRootPart or PrimaryPart not found")
		return 2
	end

	local function getCharacterFromPart(parent2)
		while parent2 and parent2 ~= workspace do
			if parent2:IsA("Model") and parent2:FindFirstChildOfClass("Humanoid") then
				return parent2
			else
				parent2 = parent2.Parent
			end
		end

		return nil
	end

	local function positionCloseModel(folder)
		if folder:IsA("BasePart") then
			folder.CFrame = self.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
			folder.Anchored = true
		else
			if folder:IsA("PVInstance") then
				folder:PivotTo(self.CFrame)
			end

			for _, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					part.Anchored = true
				end
			end
		end
	end

	local function releaseTrappedCharacter(instance)
		local v3 = v2[instance]

		if not v3 then
			return
		end

		v2[instance] = nil
		local carrierConnection = v3.carrierConnection

		if carrierConnection then
			carrierConnection:Disconnect()
		end

		local trapStateConnection = v3.trapStateConnection

		if trapStateConnection then
			trapStateConnection:Disconnect()
		end

		local billboard = v3.billboard

		if billboard and billboard.Parent then
			billboard:Destroy()
		end

		local rootPart = v3.rootPart

		if rootPart and rootPart.Parent then
			rootPart.Anchored = v3.originalRootAnchored
		end

		local humanoid = v3.humanoid

		if humanoid then
			humanoid.JumpHeight = v3.originalJumpHeight
			humanoid.AutoRotate = v3.originalAutoRotate
			humanoid.PlatformStand = false
		end

		if instance and instance.Parent then
			instance:SetAttribute("IsTrapped", nil)
		end
	end

	local function notifyTrapOwner(playerFromCharacter)
		if typeof(owner) ~= "string" then
			return
		end

		local player = Players:FindFirstChild(owner)

		if player and player:IsA("Player") then
			Remotes.Alerts.Raise:FireClient(player, {
				Type = "Toast",
				Lane = "Feed",
				Text = `You <font color="#00FF00">trapped</font> {playerFromCharacter.DisplayName}!`,
				Color = Color3.new(1, 1, 1),
				Seconds = 2
			})
		end
	end

	local function freezeCharacter(instance, vector2: Vector3)
		if v2[instance] or instance:GetAttribute("IsTrapped") then
			return false
		end

		local humanoid = instance:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if not (humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return false
		end

		local modelHeight = getModelHeight(instance) -- equivalent call inferred; original call site unknown
		local v3 = vector2 + Vector3.new(0, modelHeight, 0)
		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

		if not (playerFromCharacter and GameplayToolGuard.DropHeldEggFromPlayerHit(playerFromCharacter)) then
			return false
		end

		local cframe = CFrame.new(v3)

		if not AntiCheatService.TeleportCharacter(playerFromCharacter, cframe) then
			return false
		end

		local anchored = humanoidRootPart.Anchored
		local jumpHeight = humanoid.JumpHeight
		local autoRotate = humanoid.AutoRotate
		humanoidRootPart.Anchored = true
		humanoid:UnequipTools()
		humanoid.JumpHeight = 0
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
		instance:SetAttribute("IsTrapped", true)
		notifyTrapOwner(playerFromCharacter)
		local v4 = {
			character = instance,
			humanoid = humanoid,
			rootPart = humanoidRootPart,
			originalRootAnchored = anchored,
			originalJumpHeight = jumpHeight,
			originalAutoRotate = autoRotate
		}
		v2[instance] = v4
		v4.billboard = createTrapBillboard(instance)
		Audio.Play(9091607929, humanoidRootPart.CFrame, {
			PlaybackSpeed = { 0.9, 1.1 },
			Volume = 1.3,
			MaxDistance = 70
		})
		v4.carrierConnection = instance:GetAttributeChangedSignal("CarrierUserId"):Connect(function()
			if instance:GetAttribute("CarrierUserId") ~= nil then
				releaseTrappedCharacter(instance)
			end
		end)
		v4.trapStateConnection = instance:GetAttributeChangedSignal("IsTrapped"):Connect(function()
			if instance:GetAttribute("IsTrapped") ~= true then
				releaseTrappedCharacter(instance)
			end
		end)
		task.delay(7, function()
			if v2[instance] ~= v4 then
				return
			end

			releaseTrappedCharacter(instance)
		end)
		return true
	end

	local function activateTrap(characterFromPart)
		if v or not self.Parent or not freezeCharacter(
			characterFromPart,
			hitbox.Position - createVector(0, 1, 0) * (hitbox.Size.Y / 2)
		) then
			return
		end

		v = true
		self:SetAttribute("TrapActive", true)

		if touchedConnection then
			touchedConnection:Disconnect()
			touchedConnection = nil
		end

		local clone = ReplicatedStorage.Assets.Extra.ClosedTrap:Clone()

		if p ~= 1 then
			ScriptThatsUnderTrap.ScaleTo(clone, p)
		end

		positionCloseModel(clone)
		clone.Parent = self
		self.Transparency = 1
		self.CanCollide = false
		self.CanTouch = false
		task.delay(7.5, function()
			if clone and clone.Parent then
				clone:Destroy()
			end

			if self and self.Parent then
				self:Destroy()
			end
		end)
	end

	local function onTouched(instance)
		if v or not self.Parent or (not instance or instance:IsDescendantOf(self)) then
			return
		end

		local characterFromPart = getCharacterFromPart(instance)

		if not characterFromPart then
			return
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(characterFromPart)

		if playerFromCharacter and playerFromCharacter.Name == owner or not (playerFromCharacter and GameplayToolGuard.IsPlayerInGameplayArea(playerFromCharacter)) or not GameplayToolGuard.IsHoldingEgg(playerFromCharacter) then
			return
		end

		local humanoid = characterFromPart:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		activateTrap(characterFromPart)
	end

	touchedConnection = hitbox.Touched:Connect(onTouched)
end

return ScriptThatsUnderTrap