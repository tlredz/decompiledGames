local createVector = vector.create
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BillboardTweens = require(script.Parent.BillboardTweens)
local ViewabilityTracker = require(script.Parent.ViewabilityTracker)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Save = require(ReplicatedStorage.Shared.Save)
local localPlayer = Players.LocalPlayer
local v = {}

local function getProductIcon(p: number)
	local v2 = v[p]

	if v2 then
		return v2
	end

	local success, productInfo = pcall(MarketplaceService.GetProductInfo, MarketplaceService, p, Enum.InfoType.Product)

	if not success or not productInfo or not productInfo.IconImageAssetId or productInfo.IconImageAssetId <= 0 then
		return nil
	end

	local v3 = "rbxassetid://" .. tostring(productInfo.IconImageAssetId)
	v[p] = v3
	return v3
end

local function applyProductIcon(iconHolder, assignedProductId: number)
	if not iconHolder then
		return
	end

	local icon = iconHolder:FindFirstChild("Icon")

	if not icon then
		return
	end

	if icon:IsA("ImageLabel") or icon:IsA("ImageButton") then
		task.spawn(function()
			local v2 = assignedProductId
			local image = v[v2]

			if not image then
				local success, productInfo = pcall(
					MarketplaceService.GetProductInfo,
					MarketplaceService,
					v2,
					Enum.InfoType.Product
				)

				if success and productInfo and productInfo.IconImageAssetId and not (productInfo.IconImageAssetId <= 0) then
					image = "rbxassetid://" .. tostring(productInfo.IconImageAssetId)
					v[v2] = image
				else
					image = nil
				end
			end

			if image and icon.Parent then
				icon.Image = image
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerPosition()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.Position
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDistanceFromPlayer(position: Vector3)
	local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown
	return playerPosition and (playerPosition - position).Magnitude
end

local function isInRange(instance, p: number)
	if not (instance and instance.Parent) then
		return false
	end

	local distanceFromPlayer = getDistanceFromPlayer(instance.Position) -- equivalent call inferred; original call site unknown
	return distanceFromPlayer ~= nil and distanceFromPlayer <= p
end

local function waitUntilWithinRange(adornee, p: number)
	while adornee.Parent do
		RunService.Heartbeat:Wait()
		local distanceFromPlayer = getDistanceFromPlayer(adornee.Position) -- equivalent call inferred; original call site unknown

		if distanceFromPlayer and distanceFromPlayer <= p then
			return true
		else
			task.wait(0.5)
		end
	end

	return false
end

local function formatTimer(cooldownEndsAt: number)
	local v2 = math.max(0, (math.ceil(cooldownEndsAt - os.clock())))
	local v3 = math.floor(v2 / 3600)
	local v4 = math.floor(v2 % 3600 / 60)
	local v5 = v2 % 60

	if v3 > 0 then
		return string.format("%02d:%02d:%02d", v3, v4, v5)
	end

	return string.format("%02d:%02d", v4, v5)
end

local function clampAngle(value: number, point: Vector2)
	return (math.clamp(value, math.rad(point.X), (math.rad(point.Y))))
end

local function lerpAngle(p: number, p2: number, p3: number)
	return p + ((p2 - p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * p3
end

local function startPivotRotation(adornee, instance)
	local pivotX = instance:GetAttribute("PivotX") or Vector2.zero
	local pivotY = instance:GetAttribute("PivotY") or Vector2.zero
	local v2 = pivotX.X ~= 0 or pivotX.Y ~= 0
	local v3 = pivotY.X ~= 0 or pivotY.Y ~= 0

	if not (v2 or v3) then
		return
	end

	local ball = adornee:FindFirstChild("Ball")
	local socket = adornee:FindFirstChild("Socket")

	if not (ball and socket) then
		return
	end

	local v4 = math.clamp(instance:GetAttribute("Range") or 50, 0, 500)
	local v5 = math.clamp(v4 * 5, 0, 500)
	local v6 = 0
	local v7 = 0
	task.spawn(function()
		while adornee.Parent do
			RunService.Heartbeat:Wait()
			local value = ball.Value
			local value2 = socket.Value

			if value and value2 then
				local v8 = adornee
				local v9 = v5
				local v10

				if v8 and v8.Parent then
					local distanceFromPlayer = getDistanceFromPlayer(v8.Position) -- equivalent call inferred; original call site unknown

					if distanceFromPlayer == nil then
						v10 = false
					else
						v10 = distanceFromPlayer <= v9
					end
				else
					v10 = false
				end

				if v10 then
					local v11 = adornee
					local v12 = v4
					local v13

					if v11 and v11.Parent then
						local distanceFromPlayer = getDistanceFromPlayer(v11.Position) -- equivalent call inferred; original call site unknown

						if distanceFromPlayer == nil then
							v13 = false
						else
							v13 = distanceFromPlayer <= v12
						end
					else
						v13 = false
					end

					if v13 then
						if value.Parent and value.Parent.Parent then
							local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown
							local worldCFrame = value2.WorldCFrame
							local pointToObjectSpace = worldCFrame:PointToObjectSpace(playerPosition)
							local v14 = 0
							local v15

							if v2 then
								local v16 = math.atan2(-pointToObjectSpace.X, -pointToObjectSpace.Z)
								local v17 = pivotX
								v15 = math.clamp(v16, math.rad(v17.X), (math.rad(v17.Y)))
							else
								v15 = 0
							end

							if v3 then
								local v16 = math.sqrt(pointToObjectSpace.X ^ 2 + pointToObjectSpace.Z ^ 2)
								local v17 = math.atan2(pointToObjectSpace.Y, (math.max(v16, 0.5)))
								local v18 = pivotY
								v14 = math.clamp(v17, math.rad(v18.X), (math.rad(v18.Y)))
							end

							local v16 = v7
							v7 = v16 + ((v15 - v16 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * 0.12
							local v17 = v6
							v6 = v17 + ((v14 - v17 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * 0.12
							local vectorToWorldSpace = worldCFrame:VectorToWorldSpace(CFrame.Angles(v6, v7, 0) * createVector(
								0,
								0,
								-1
							))
							local cframe = CFrame.lookAt(
								worldCFrame.Position,
								worldCFrame.Position + vectorToWorldSpace,
								worldCFrame.UpVector
							)
							value.Parent.CFrame = cframe * value.CFrame:Inverse()
						else
							task.wait(1)
						end
					else
						task.wait(1)
					end
				else
					task.wait(2)
				end
			else
				task.wait(2)
			end
		end
	end)
end

local BillboardController = {}
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function teardown()
	if v2 then
		v2.dead = true
		v2 = nil
	end
end

function BillboardController:start(data, p, flag: boolean?)
	local screen = self:FindFirstChild("Screen") or self:WaitForChild("Screen", 10)

	if screen then
		teardown() -- equivalent call inferred; original call site unknown
		self.ChildRemoved:Connect(function(child)
			if child == screen and v2 then
				v2.dead = true
				v2 = nil
			end
		end)
		self.ChildAdded:Connect(function(part)
			if part.Name == "Screen" and part:IsA("BasePart") and not v2 then
				BillboardController.start(self, data, p, flag)
			end
		end)
		local rewardedVideoBillboard = screen:WaitForChild("RewardedVideoBillboard", 10)

		if not rewardedVideoBillboard then
			warn((`[RVBillboard] No SurfaceGui found in {screen:GetFullName()}`))
			return
		end

		local devProductId = nil

		if not rewardedVideoBillboard.Adornee then
			local parent = rewardedVideoBillboard.Parent

			if parent and parent:IsA("BasePart") then
				rewardedVideoBillboard.Adornee = parent
			end
		end

		if not rewardedVideoBillboard.Adornee then
			for _ = 1, 10 do
				task.wait(1)

				if rewardedVideoBillboard.Adornee then
					break
				end
			end

			if not rewardedVideoBillboard.Adornee then
				warn((`[RVBillboard] {rewardedVideoBillboard:GetFullName()} | Adornee was not assigned; aborting.`))
				return
			end
		end

		local adornee = rewardedVideoBillboard.Adornee

		if not (adornee and adornee:IsA("BasePart")) then
			warn((`[RVBillboard] {rewardedVideoBillboard:GetFullName()} | no valid Adornee`))
			return
		end

		if not adornee.Parent then
			local v3 = os.clock() + 60

			while not adornee.Parent do
				task.wait(1)

				if not (v3 < os.clock()) then
					continue
				end

				warn((`[RVBillboard] Board {devProductId} — Adornee never parented after {60}s.`))
				return
			end
		end

		rewardedVideoBillboard.Enabled = true
		local v3 = Save.Await()
		local guardTutorialProgress = v3 and v3.GuardTutorialProgress
		local parent, pivot, flag2

		if guardTutorialProgress and not guardTutorialProgress.Completed then
			parent = self.Parent
			pivot = self:GetPivot()
			self.Parent = ReplicatedStorage
			flag2 = true
		else
			flag2 = false
			parent = nil
			pivot = nil
		end

		local parent2 = adornee.Parent

		if not (parent2 and parent2:IsA("Model")) then
			parent2 = nil
		end

		local screenFrame = rewardedVideoBillboard:FindFirstChild("ScreenFrame")

		if not screenFrame then
			warn((`[RVBillboard] {rewardedVideoBillboard:GetFullName()} | no ScreenFrame found`))
			return
		end

		local input = screenFrame:FindFirstChild("Input") or screenFrame:FindFirstChildOfClass("TextButton")

		if not (input and input:IsA("GuiButton")) then
			warn((`[RVBillboard] {rewardedVideoBillboard:GetFullName()} | no GuiButton found in ScreenFrame`))
			return
		end

		startPivotRotation(adornee, self)
		local uIScale = screenFrame:FindFirstChild("UIScale")
		local default = screenFrame:FindFirstChild("Default")
		local iconHolder

		if default then
			iconHolder = default:FindFirstChild("IconHolder") or nil
		else
			iconHolder = nil
		end

		local iconHolder2 = screenFrame:FindFirstChild("IconHolder")
		local cooldown = screenFrame:FindFirstChild("Cooldown")
		local timer

		if cooldown then
			timer = cooldown:FindFirstChild("Timer") or nil
		end

		local available = screenFrame:FindFirstChild("Available")
		local cashValue

		if available then
			cashValue = available:FindFirstChild("CashValue") or nil
		else
			cashValue = nil
		end

		local playButton

		if available then
			playButton = available:FindFirstChild("PlayButton") or nil
		end

		local uIScale2 = playButton and playButton:FindFirstChild("UIScale") or nil
		local starburst = screenFrame:FindFirstChild("Starburst")
		local surface = screenFrame:FindFirstChild("Surface")
		local border = surface and surface:FindFirstChild("Border")
		local color = border and border.Color or Color3.new()
		local baseStrokeThickness = not border and 0 or border.Thickness or 0
		local brightness = rewardedVideoBillboard.Brightness
		local backgroundColor3 = surface and surface.BackgroundColor3 or Color3.new()
		local color2 = Color3.new(
			math.min(1, backgroundColor3.R + 0.0392156862745098),
			math.min(1, backgroundColor3.G + 0.0392156862745098),
			(math.min(1, backgroundColor3.B + 0.0392156862745098))
		)

		if default then
			default.Visible = true
		end

		if iconHolder2 then
			iconHolder2.Visible = false
		end

		if cooldown then
			cooldown.Visible = false
		end

		if available then
			available.Visible = false
		end

		if starburst then
			task.spawn(function()
				while adornee.Parent do
					starburst.Rotation = os.clock() % 6 / 6 * 360
					RunService.Heartbeat:Wait()
				end
			end)
		end

		local v5 = {
			surfaceGui = rewardedVideoBillboard,
			screenPart = adornee,
			cooldownTimer = timer,
			adorneeModel = parent2,
			playAdButton = input,
			boardId = devProductId,
			placementId = nil,
			cooldownEndsAt = 0,
			pending = false,
			claimable = false,
			retried = false,
			connected = false,
			gated = false,
			checking = false,
			dead = false,
			bootTelemetrySent = false,
			multiplier = 1,
			rewardDuration = 30,
			rewardConfirmed = false,
			viewabilityTracker = ViewabilityTracker.new(adornee, self:GetAttribute("Range") or 50, flag),
			lastInfoRefresh = 0,
			currentVisibility = nil,
			updateVisibility = nil
		}
		v2 = v5

		if flag2 then
			task.spawn(function()
				while not v5.dead and self.Parent do
					local v6 = Save.Await()
					local guardTutorialProgress2 = v6 and v6.GuardTutorialProgress

					if guardTutorialProgress2 and guardTutorialProgress2.Completed then
						break
					else
						Save.Watch("GuardTutorialProgress"):Wait()
					end
				end

				if v5.dead or not self.Parent then
					return
				end

				local success, result = pcall(p.GetPlacementInfo.InvokeServer, p.GetPlacementInfo)

				if success and result and result.controlGroup then
					v5.dead = true
					return
				end

				self.Parent = parent
				self:PivotTo(pivot)
			end)
		end

		local hintEffect = script.Parent:FindFirstChild("HintEffect")
		local v6

		if hintEffect and self:GetAttribute("ShowHint") then
			local module = require(hintEffect)
			v6 = module.new(self, adornee, input)
		else
			v6 = nil
		end

		function v5.updateVisibility(currentVisibility: string)
			if currentVisibility == v5.currentVisibility then
				return
			end

			v5.currentVisibility = currentVisibility

			if default then
				default.Visible = currentVisibility == "Default" or currentVisibility == "Gated"
			end

			if iconHolder2 then
				iconHolder2.Visible = currentVisibility == "Cooldown" or currentVisibility == "Available"
			end

			if cooldown then
				cooldown.Visible = currentVisibility == "Cooldown"
			end

			if available then
				available.Visible = currentVisibility == "Available"
			end
		end

		v5.updateVisibility("Default")

		local function passProximityAndAvailability()
			if v5.dead or v5.checking then
				return false
			end

			v5.checking = true

			local function finish(flag3: boolean)
				v5.checking = false
				return flag3
			end

			local v7

			if not v5.bootTelemetrySent then
				if not waitUntilWithinRange(adornee, 150) then
					v5.checking = false
					return false
				end

				if v5.dead then
					v5.checking = false
					return false
				end

				v5.bootTelemetrySent = true
				data.Remotes.LogTelemetry:FireServer("Boot")
			end

			while adornee.Parent and not v5.dead do
				RunService.Heartbeat:Wait()
				v7 = RunService.Heartbeat:Wait()

				if v5.viewabilityTracker:update(v7) then
					break
				end
			end

			if v5.dead then
				v5.checking = false
				return false
			end

			if v5.cooldownEndsAt > os.clock() then
				v5.checking = false
				return false
			end

			if not data.IsAvailable() then
				v5.checking = false
				return false
			end

			if v5.dead then
				v5.checking = false
				return false
			end

			v5.claimable = true
			data.Remotes.LogTelemetry:FireServer("RegisterOpportunity")
			v5.checking = false
			return true
		end

		task.spawn(function()
			while adornee.Parent do
				task.wait()

				if rewardedVideoBillboard and rewardedVideoBillboard.Parent then
					local v7 = adornee
					local v8

					if v7 and v7.Parent then
						local distanceFromPlayer = getDistanceFromPlayer(v7.Position) -- equivalent call inferred; original call site unknown

						if distanceFromPlayer == nil then
							v8 = false
						else
							v8 = distanceFromPlayer <= 250
						end
					else
						v8 = false
					end

					if v8 then
						local v9

						if v5.gated then
							v9 = "Gated"
						elseif not v5.connected then
							v9 = "Default"
						elseif v5.cooldownEndsAt > os.clock() or not v5.claimable then
							v9 = "Cooldown"
						else
							v9 = "Available"
						end

						v5.updateVisibility(v9)

						if v6 then
							if v9 == "Available" then
								local v10 = adornee
								local v11 = (self:GetAttribute("Range") or 50) / 2
								local v12

								if v10 and v10.Parent then
									local distanceFromPlayer = getDistanceFromPlayer(v10.Position) -- equivalent call inferred; original call site unknown

									if distanceFromPlayer == nil then
										v12 = false
									else
										v12 = distanceFromPlayer <= v11
									end
								else
									v12 = false
								end

								if v12 then
									v6:show()
								else
									v6:hide()
								end
							else
								v6:hide()
							end
						end

						if v9 == "Cooldown" and v5.cooldownTimer then
							if v5.cooldownEndsAt > os.clock() then
								v5.cooldownTimer.Text = formatTimer(v5.cooldownEndsAt)
							else
								v5.cooldownTimer.Text = ""
							end
						end

						if v9 == "Cooldown" and v5.connected and v5.cooldownEndsAt <= os.clock() and not (v5.claimable or v5.pending or v5.checking) then
							local now = os.clock()

							if now - (v5.lastInfoRefresh or 0) >= 5 then
								v5.lastInfoRefresh = now
								task.spawn(function()
									if v5.dead then
										return
									end

									local success, result = pcall(p.GetPlacementInfo.InvokeServer, p.GetPlacementInfo)

									if not (success and result) then
										return
									end

									if result.placementId then
										v5.placementId = result.placementId
									end

									if result.gated then
										v5.gated = true
										v5.updateVisibility("Gated")
									elseif result.claimsMax and result.claimsMax > 0 and result.claimsUsed and result.claimsUsed >= result.claimsMax and result.windowResetsAt then
										local v10 = math.max(0, result.windowResetsAt - os.time())
										v5.cooldownEndsAt = os.clock() + v10
									else
										if result.secondsLeft and result.secondsLeft > 0 then
											v5.cooldownEndsAt = os.clock() + result.secondsLeft
											return
										end

										if not result.eligible then
											return
										end

										passProximityAndAvailability()
									end
								end)
							end
						end

						task.wait(1)
					else
						if v6 then
							v6:hide()
						end

						task.wait(2)
					end
				else
					if v6 then
						v6:hide()
					end

					task.wait(1)
				end
			end
		end)
		local v7 = {}

		if iconHolder2 then
			table.insert(v7, {
				instance = iconHolder2,
				basePosition = iconHolder2.Position
			})
		end

		if iconHolder then
			table.insert(v7, {
				instance = iconHolder,
				basePosition = iconHolder.Position
			})
		end

		if #v7 > 0 then
			local range = self:GetAttribute("Range") or 50
			task.spawn(function()
				while adornee.Parent do
					RunService.Heartbeat:Wait()
					local v8 = adornee
					local v9

					if v8 and v8.Parent then
						local distanceFromPlayer = getDistanceFromPlayer(v8.Position) -- equivalent call inferred; original call site unknown

						if distanceFromPlayer == nil then
							v9 = false
						else
							v9 = distanceFromPlayer <= 250
						end
					else
						v9 = false
					end

					if v9 then
						local distanceFromPlayer = getDistanceFromPlayer(adornee.Position) -- equivalent call inferred; original call site unknown

						if distanceFromPlayer then
							if distanceFromPlayer <= range then
								local midpoint = (math.sin(os.clock() * 2.0943951023931953) + 1) / 2

								for _, v11 in v7 do
									v11.instance.Position = UDim2.new(
										v11.basePosition.X.Scale,
										v11.basePosition.X.Offset,
										v11.basePosition.Y.Scale,
										v11.basePosition.Y.Offset - midpoint * 5
									)
								end
							else
								for _, v10 in v7 do
									v10.instance.Position = v10.basePosition
								end
							end
						else
							task.wait(2)
						end
					else
						task.wait(2)
					end
				end
			end)
		end

		local design = screenFrame:FindFirstChild("Design")

		if design then
			local v8 = {}

			for _, guiObject in design:GetChildren() do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local v9 = (#v8 + 1 - 1) * 1.25 + 10
				local v10 = v9 * 1.4
				table.insert(v8, {
					instance = guiObject,
					basePosition = guiObject.Position,
					baseRotation = guiObject.Rotation,
					omegaY = 6.283185307179586 / v9,
					omegaX = 6.283185307179586 / v10,
					startAt = os.clock() + math.random() * 2
				})
			end

			if #v8 > 0 then
				task.spawn(function()
					while adornee.Parent do
						RunService.Heartbeat:Wait()
						local v9 = adornee
						local v10

						if v9 and v9.Parent then
							local distanceFromPlayer = getDistanceFromPlayer(v9.Position) -- equivalent call inferred; original call site unknown

							if distanceFromPlayer == nil then
								v10 = false
							else
								v10 = distanceFromPlayer <= 250
							end
						else
							v10 = false
						end

						if v10 then
							local now = os.clock()

							for _, v11 in v8 do
								if now < v11.startAt then
									continue
								end

								local v12 = now - v11.startAt
								v11.instance.Position = v11.basePosition + UDim2.fromScale(
									math.sin(v12 * v11.omegaX) * 0.01,
									math.sin(v12 * v11.omegaY) * 0.02
								)
								v11.instance.Rotation = v11.baseRotation + math.sin(v12 * v11.omegaY) * 2
							end
						else
							task.wait(2)
						end
					end
				end)
			end
		end

		local shakeTargets = {}

		if iconHolder2 then
			table.insert(shakeTargets, {
				instance = iconHolder2,
				baseRotation = iconHolder2.Rotation
			})
		end

		if iconHolder then
			table.insert(shakeTargets, {
				instance = iconHolder,
				baseRotation = iconHolder.Rotation
			})
		end

		local v9 = BillboardTweens.new({
			frameScale = uIScale,
			buttonScale = uIScale2,
			frameStroke = border,
			surfaceGui = rewardedVideoBillboard,
			surface = surface,
			baseStrokeColor = color,
			baseStrokeThickness = baseStrokeThickness,
			baseBrightness = brightness,
			baseBackground = backgroundColor3,
			bumpedBackground = color2,
			shakeTargets = shakeTargets
		})
		task.spawn(function()
			local v10 = false

			while adornee.Parent do
				RunService.Heartbeat:Wait()
				local v11 = adornee
				local v12

				if v11 and v11.Parent then
					local distanceFromPlayer = getDistanceFromPlayer(v11.Position) -- equivalent call inferred; original call site unknown

					if distanceFromPlayer == nil then
						v12 = false
					else
						v12 = distanceFromPlayer <= 250
					end
				else
					v12 = false
				end

				if v12 ~= v10 then
					if not v12 then
						v9.resetHover()
					end

					v10 = v12
				end

				if v12 then
					RunService.Heartbeat:Wait()
				else
					task.wait(2)
				end
			end
		end)
		task.spawn(function()
			while adornee.Parent do
				task.wait(math.random(5, 15))
				local v10 = adornee
				local v11

				if v10 and v10.Parent then
					local distanceFromPlayer = getDistanceFromPlayer(v10.Position) -- equivalent call inferred; original call site unknown

					if distanceFromPlayer == nil then
						v11 = false
					else
						v11 = distanceFromPlayer <= 250
					end
				else
					v11 = false
				end

				if v11 then
					v9.shakeIcon()
				else
					RunService.Heartbeat:Wait()
				end
			end
		end)
		input.MouseEnter:Connect(function()
			local v10 = adornee
			local v11

			if v10 and v10.Parent then
				local distanceFromPlayer = getDistanceFromPlayer(v10.Position) -- equivalent call inferred; original call site unknown

				if distanceFromPlayer == nil then
					v11 = false
				else
					v11 = distanceFromPlayer <= 250
				end
			else
				v11 = false
			end

			if not v11 then
				return
			end

			data.Audio.playEnterSound()

			if v5.cooldownEndsAt > os.clock() or not v5.claimable then
				return
			end

			v9.hoverIn()
			v9.shakeIcon()
		end)
		input.MouseLeave:Connect(function()
			local v10 = adornee
			local v11

			if v10 and v10.Parent then
				local distanceFromPlayer = getDistanceFromPlayer(v10.Position) -- equivalent call inferred; original call site unknown

				if distanceFromPlayer == nil then
					v11 = false
				else
					v11 = distanceFromPlayer <= 250
				end
			else
				v11 = false
			end

			if not v11 then
				return
			end

			v9.resetHover()
			v9.shakeIcon()
		end)
		input.Activated:Connect(function()
			local v10 = adornee
			local v11

			if v10 and v10.Parent then
				local distanceFromPlayer = getDistanceFromPlayer(v10.Position) -- equivalent call inferred; original call site unknown

				if distanceFromPlayer == nil then
					v11 = false
				else
					v11 = distanceFromPlayer <= 250
				end
			else
				v11 = false
			end

			if not v11 then
				return
			end

			v9.frameScale(0.98, 0.06)
			local buttonScale = v9.buttonScale(0.6, 0.06)

			if buttonScale then
				buttonScale.Completed:Wait()
			end

			v9.frameScale(1, 0.12)
			v9.buttonScale(1, 0.12)
			v9.shakeIcon()
			v9.strokeHoverOut()
			data.Audio.playClickSound()

			if not v5.connected or v5.cooldownEndsAt > os.clock() or not v5.claimable or v5.pending then
				return
			end

			v5.retried = false
			v5.pending = true

			if data.IsAvailable() then
				if not data.ShowAd() then
					v5.pending = false
				end
			else
				v5.pending = false
				v5.claimable = false
			end
		end)
		data.OnAdCompleted(function(data2)
			data.Audio.playAdCompleteSound()
			v5.pending = false
			v5.claimable = false
			v5.viewabilityTracker:reset()

			if data2.claimsMax and data2.claimsMax > 0 and data2.claimsUsed and data2.claimsUsed >= data2.claimsMax and data2.windowResetsAt then
				local v10 = math.max(0, data2.windowResetsAt - os.time())
				v5.cooldownEndsAt = os.clock() + v10
			elseif data2.cooldownEndsAt then
				local v10 = math.max(0, data2.cooldownEndsAt - os.time())
				v5.cooldownEndsAt = os.clock() + v10
			end
		end)
		data.OnAdFailed(function(data2)
			v5.viewabilityTracker:reset()

			if data2.reason == "ControlGroup" then
				v5.dead = true

				if self and self.Parent then
					self.Parent = ReplicatedStorage
				end
			elseif data2.reason == "RewardAssigned" then
				if data2.assignedProductId then
					applyProductIcon(iconHolder2, data2.assignedProductId)
					applyProductIcon(iconHolder, data2.assignedProductId)
				end

				if data2.multiplier then
					v5.multiplier = data2.multiplier
				end

				if data2.rewardDuration then
					v5.rewardDuration = data2.rewardDuration
				end

				v5.rewardConfirmed = true
			elseif data2.reason == "SyncUpdate" then
				if data2.claimsMax and data2.claimsMax > 0 and data2.claimsUsed and data2.claimsUsed >= data2.claimsMax and data2.windowResetsAt then
					local v10 = math.max(0, data2.windowResetsAt - os.time())
					v5.cooldownEndsAt = os.clock() + v10
				elseif data2.secondsLeft and data2.secondsLeft > 0 then
					v5.cooldownEndsAt = os.clock() + data2.secondsLeft
				end

				v5.claimable = false
			else
				if data2.reason == "ClaimLimitReached" then
					task.spawn(function()
						local success, result = pcall(p.GetPlacementInfo.InvokeServer, p.GetPlacementInfo)

						if success and result and result.windowResetsAt then
							local v10 = math.max(0, result.windowResetsAt - os.time())
							v5.cooldownEndsAt = os.clock() + v10
						end

						v5.pending = false
					end)
					return
				end

				v5.pending = false

				if data2.result == Enum.ShowAdResult.ShowInterrupted and not v5.retried then
					v5.retried = true
					task.delay(6, function()
						if v5.dead or v5.cooldownEndsAt > os.clock() then
							return
						end

						passProximityAndAvailability()
					end)
				end
			end
		end)
		task.delay(5, function()
			if v5.dead then
				return
			end

			while not v5.dead do
				wait()
				local success, result = pcall(p.GetPlacementInfo.InvokeServer, p.GetPlacementInfo)

				if success and result then
					if result.controlGroup then
						v5.dead = true

						if self and self.Parent then
							self.Parent = ReplicatedStorage
						end

						break
					elseif not result.pending then
						if result.devProductId then
							devProductId = result.devProductId
							v5.boardId = devProductId
						end

						local assignedProductId = result.assignedProductId or devProductId

						if assignedProductId then
							applyProductIcon(iconHolder2, assignedProductId)
							applyProductIcon(iconHolder, assignedProductId)
						end

						if result.multiplier then
							v5.multiplier = result.multiplier
						end

						if result.rewardDuration then
							v5.rewardDuration = result.rewardDuration
						end

						if result.placementId then
							v5.placementId = result.placementId
						end

						if result.gated then
							v5.gated = true
							v5.updateVisibility("Gated")
							break
						else
							v5.connected = true

							if result.claimsMax and result.claimsMax > 0 and result.claimsUsed and result.claimsUsed >= result.claimsMax and result.windowResetsAt then
								local v10 = math.max(0, result.windowResetsAt - os.time())
								v5.cooldownEndsAt = os.clock() + v10
								break
							else
								if result.secondsLeft and result.secondsLeft > 0 then
									v5.cooldownEndsAt = os.clock() + result.secondsLeft
								end

								if not result.eligible then
									break
								end

								passProximityAndAvailability()
								break
							end
						end
					end
				end

				task.wait(5)
			end
		end)

		if cashValue then
			task.spawn(function()
				local leaderstats = localPlayer:WaitForChild("leaderstats", 30)
				local moneys = leaderstats and leaderstats:WaitForChild("Money/s", 30)

				if not moneys then
					return
				end

				while adornee.Parent and not v5.dead do
					local v10 = math.max(moneys.Value * v5.multiplier * v5.rewardDuration, 1000)
					cashValue.Text = "$" .. Simple.FormatCompact(math.round(v10), ".#")
					task.wait(1)
				end
			end)
		end
	else
		local childAddedConnection = nil
		childAddedConnection = self.ChildAdded:Connect(function(part)
			if part.Name == "Screen" and part:IsA("BasePart") then
				childAddedConnection:Disconnect()
				BillboardController.start(self, data, p, flag)
			end
		end)
	end
end

return BillboardController