local createVector = vector.create
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local BillboardTweens = require(script.Parent.BillboardTweens)
local ViewabilityTracker = require(script.Parent.ViewabilityTracker)
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

function BillboardController.start(instance, data, p, flag: boolean?)
	local screen = instance:FindFirstChild("Screen") or instance:WaitForChild("Screen", 10)

	if screen then
		teardown() -- equivalent call inferred; original call site unknown
		instance.ChildRemoved:Connect(function(child)
			if child == screen and v2 then
				v2.dead = true
				v2 = nil
			end
		end)
		instance.ChildAdded:Connect(function(part)
			if part.Name == "Screen" and part:IsA("BasePart") and not v2 then
				BillboardController.start(instance, data, p, flag)
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
		local parent = adornee.Parent

		if not (parent and parent:IsA("Model")) then
			parent = nil
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

		startPivotRotation(adornee, instance)
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
		local playButton

		if available then
			playButton = available:FindFirstChild("PlayButton") or nil
		end

		local uIScale2 = playButton and playButton:FindFirstChild("UIScale") or nil
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

		local v4 = {
			surfaceGui = rewardedVideoBillboard,
			screenPart = adornee,
			cooldownTimer = timer,
			adorneeModel = parent,
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
			viewabilityTracker = ViewabilityTracker.new(adornee, instance:GetAttribute("Range") or 50, flag),
			lastInfoRefresh = 0,
			currentVisibility = nil,
			updateVisibility = nil
		}
		v2 = v4

		function v4.updateVisibility(currentVisibility: string)
			if currentVisibility == v4.currentVisibility then
				return
			end

			v4.currentVisibility = currentVisibility

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

		v4.updateVisibility("Default")

		local function passProximityAndAvailability()
			if v4.dead or v4.checking then
				return false
			end

			v4.checking = true

			local function finish(flag2: boolean)
				v4.checking = false
				return flag2
			end

			local v5

			if not v4.bootTelemetrySent then
				if not waitUntilWithinRange(adornee, 150) then
					v4.checking = false
					return false
				end

				if v4.dead then
					v4.checking = false
					return false
				end

				v4.bootTelemetrySent = true
				data.Remotes.LogTelemetry:FireServer("Boot")
			end

			while adornee.Parent and not v4.dead do
				RunService.Heartbeat:Wait()
				v5 = RunService.Heartbeat:Wait()

				if v4.viewabilityTracker:update(v5) then
					break
				end
			end

			if v4.dead then
				v4.checking = false
				return false
			end

			if v4.cooldownEndsAt > os.clock() then
				v4.checking = false
				return false
			end

			if not data.IsAvailable() then
				v4.checking = false
				return false
			end

			if v4.dead then
				v4.checking = false
				return false
			end

			v4.claimable = true
			data.Remotes.LogTelemetry:FireServer("RegisterOpportunity")
			v4.checking = false
			return true
		end

		task.spawn(function()
			while adornee.Parent do
				task.wait()

				if rewardedVideoBillboard and rewardedVideoBillboard.Parent then
					local v5 = adornee
					local v6

					if v5 and v5.Parent then
						local distanceFromPlayer = getDistanceFromPlayer(v5.Position) -- equivalent call inferred; original call site unknown

						if distanceFromPlayer == nil then
							v6 = false
						else
							v6 = distanceFromPlayer <= 250
						end
					else
						v6 = false
					end

					if v6 then
						local v7

						if v4.gated then
							v7 = "Gated"
						elseif not v4.connected then
							v7 = "Default"
						elseif v4.cooldownEndsAt > os.clock() or not v4.claimable then
							v7 = "Cooldown"
						else
							v7 = "Available"
						end

						v4.updateVisibility(v7)

						if v7 == "Cooldown" and v4.cooldownTimer then
							if v4.cooldownEndsAt > os.clock() then
								v4.cooldownTimer.Text = formatTimer(v4.cooldownEndsAt)
							else
								v4.cooldownTimer.Text = ""
							end
						end

						if v7 == "Cooldown" and v4.connected and v4.cooldownEndsAt <= os.clock() and not (v4.claimable or v4.pending or v4.checking) then
							local now = os.clock()

							if now - (v4.lastInfoRefresh or 0) >= 5 then
								v4.lastInfoRefresh = now
								task.spawn(function()
									if v4.dead then
										return
									end

									local success, result = pcall(p.GetPlacementInfo.InvokeServer, p.GetPlacementInfo)

									if not (success and result) then
										return
									end

									if result.placementId then
										v4.placementId = result.placementId
									end

									if result.gated then
										v4.gated = true
										v4.updateVisibility("Gated")
									elseif result.claimsMax and result.claimsMax > 0 and result.claimsUsed and result.claimsUsed >= result.claimsMax and result.windowResetsAt then
										local v8 = math.max(0, result.windowResetsAt - os.time())
										v4.cooldownEndsAt = os.clock() + v8
									else
										if result.secondsLeft and result.secondsLeft > 0 then
											v4.cooldownEndsAt = os.clock() + result.secondsLeft
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
						task.wait(2)
					end
				else
					task.wait(1)
				end
			end
		end)
		local v5 = {}

		if iconHolder2 then
			table.insert(v5, {
				instance = iconHolder2,
				basePosition = iconHolder2.Position
			})
		end

		if iconHolder then
			table.insert(v5, {
				instance = iconHolder,
				basePosition = iconHolder.Position
			})
		end

		if #v5 > 0 then
			local range = instance:GetAttribute("Range") or 50
			task.spawn(function()
				while adornee.Parent do
					RunService.Heartbeat:Wait()
					local v6 = adornee
					local v7

					if v6 and v6.Parent then
						local distanceFromPlayer = getDistanceFromPlayer(v6.Position) -- equivalent call inferred; original call site unknown

						if distanceFromPlayer == nil then
							v7 = false
						else
							v7 = distanceFromPlayer <= 250
						end
					else
						v7 = false
					end

					if v7 then
						local distanceFromPlayer = getDistanceFromPlayer(adornee.Position) -- equivalent call inferred; original call site unknown

						if distanceFromPlayer then
							if distanceFromPlayer <= range then
								local midpoint = (math.sin(os.clock() * 2.0943951023931953) + 1) / 2

								for _, v9 in v5 do
									v9.instance.Position = UDim2.new(
										v9.basePosition.X.Scale,
										v9.basePosition.X.Offset,
										v9.basePosition.Y.Scale,
										v9.basePosition.Y.Offset - midpoint * 5
									)
								end
							else
								for _, v8 in v5 do
									v8.instance.Position = v8.basePosition
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
			local v6 = {}

			for _, guiObject in design:GetChildren() do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local v7 = (#v6 + 1 - 1) * 1.25 + 10
				local v8 = v7 * 1.4
				table.insert(v6, {
					instance = guiObject,
					basePosition = guiObject.Position,
					baseRotation = guiObject.Rotation,
					omegaY = 6.283185307179586 / v7,
					omegaX = 6.283185307179586 / v8,
					startAt = os.clock() + math.random() * 2
				})
			end

			if #v6 > 0 then
				task.spawn(function()
					while adornee.Parent do
						RunService.Heartbeat:Wait()
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
							local now = os.clock()

							for _, v9 in v6 do
								if now < v9.startAt then
									continue
								end

								local v10 = now - v9.startAt
								v9.instance.Position = v9.basePosition + UDim2.fromScale(
									math.sin(v10 * v9.omegaX) * 0.01,
									math.sin(v10 * v9.omegaY) * 0.02
								)
								v9.instance.Rotation = v9.baseRotation + math.sin(v10 * v9.omegaY) * 2
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

		local v7 = BillboardTweens.new({
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
			local v8 = false

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

				if v10 ~= v8 then
					if not v10 then
						v7.resetHover()
					end

					v8 = v10
				end

				if v10 then
					RunService.Heartbeat:Wait()
				else
					task.wait(2)
				end
			end
		end)
		task.spawn(function()
			while adornee.Parent do
				task.wait(math.random(5, 15))
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
					v7.shakeIcon()
				else
					RunService.Heartbeat:Wait()
				end
			end
		end)
		input.MouseEnter:Connect(function()
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

			if not v9 then
				return
			end

			data.Audio.playEnterSound()

			if v4.cooldownEndsAt > os.clock() or not v4.claimable then
				return
			end

			v7.hoverIn()
			v7.shakeIcon()
		end)
		input.MouseLeave:Connect(function()
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

			if not v9 then
				return
			end

			v7.resetHover()
			v7.shakeIcon()
		end)
		input.Activated:Connect(function()
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

			if not v9 then
				return
			end

			v7.frameScale(0.98, 0.06)
			local buttonScale = v7.buttonScale(0.6, 0.06)

			if buttonScale then
				buttonScale.Completed:Wait()
			end

			v7.frameScale(1, 0.12)
			v7.buttonScale(1, 0.12)
			v7.shakeIcon()
			v7.strokeHoverOut()
			data.Audio.playClickSound()

			if not v4.connected or v4.cooldownEndsAt > os.clock() or not v4.claimable or v4.pending then
				return
			end

			v4.retried = false
			v4.pending = true

			if data.IsAvailable() then
				if not data.ShowAd() then
					v4.pending = false
				end
			else
				v4.pending = false
				v4.claimable = false
			end
		end)
		data.OnAdCompleted(function(data2)
			data.Audio.playAdCompleteSound()
			v4.pending = false
			v4.claimable = false
			v4.viewabilityTracker:reset()

			if data2.claimsMax and data2.claimsMax > 0 and data2.claimsUsed and data2.claimsUsed >= data2.claimsMax and data2.windowResetsAt then
				local v8 = math.max(0, data2.windowResetsAt - os.time())
				v4.cooldownEndsAt = os.clock() + v8
			elseif data2.cooldownEndsAt then
				local v8 = math.max(0, data2.cooldownEndsAt - os.time())
				v4.cooldownEndsAt = os.clock() + v8
			end
		end)
		data.OnAdFailed(function(data2)
			v4.viewabilityTracker:reset()

			if data2.reason == "RewardAssigned" then
				if data2.assignedProductId then
					applyProductIcon(iconHolder2, data2.assignedProductId)
					applyProductIcon(iconHolder, data2.assignedProductId)
				end
			elseif data2.reason == "SyncUpdate" then
				if data2.claimsMax and data2.claimsMax > 0 and data2.claimsUsed and data2.claimsUsed >= data2.claimsMax and data2.windowResetsAt then
					local v8 = math.max(0, data2.windowResetsAt - os.time())
					v4.cooldownEndsAt = os.clock() + v8
				elseif data2.secondsLeft and data2.secondsLeft > 0 then
					v4.cooldownEndsAt = os.clock() + data2.secondsLeft
				end

				v4.claimable = false
			else
				if data2.reason == "ClaimLimitReached" then
					task.spawn(function()
						local success, result = pcall(p.GetPlacementInfo.InvokeServer, p.GetPlacementInfo)

						if success and result and result.windowResetsAt then
							local v8 = math.max(0, result.windowResetsAt - os.time())
							v4.cooldownEndsAt = os.clock() + v8
						end

						v4.pending = false
					end)
					return
				end

				v4.pending = false

				if data2.result == Enum.ShowAdResult.ShowInterrupted and not v4.retried then
					v4.retried = true
					task.delay(6, function()
						if v4.dead or v4.cooldownEndsAt > os.clock() then
							return
						end

						passProximityAndAvailability()
					end)
				end
			end
		end)
		task.delay(3, function()
			if v4.dead then
				return
			end

			local success, result = pcall(p.GetPlacementInfo.InvokeServer, p.GetPlacementInfo)

			if not (success and result) then
				return
			end

			if result.devProductId then
				devProductId = result.devProductId
				v4.boardId = devProductId
			end

			local assignedProductId = result.assignedProductId or devProductId

			if assignedProductId then
				applyProductIcon(iconHolder2, assignedProductId)
				applyProductIcon(iconHolder, assignedProductId)
			end

			if result.placementId then
				v4.placementId = result.placementId
			end

			if result.gated then
				v4.gated = true
				v4.updateVisibility("Gated")
			else
				v4.connected = true

				if result.claimsMax and result.claimsMax > 0 and result.claimsUsed and result.claimsUsed >= result.claimsMax and result.windowResetsAt then
					local v8 = math.max(0, result.windowResetsAt - os.time())
					v4.cooldownEndsAt = os.clock() + v8
				else
					if result.secondsLeft and result.secondsLeft > 0 then
						v4.cooldownEndsAt = os.clock() + result.secondsLeft
					end

					if not result.eligible then
						return
					end

					passProximityAndAvailability()
				end
			end
		end)
	else
		local childAddedConnection = nil
		childAddedConnection = instance.ChildAdded:Connect(function(part)
			if part.Name == "Screen" and part:IsA("BasePart") then
				childAddedConnection:Disconnect()
				BillboardController.start(instance, data, p, flag)
			end
		end)
	end
end

return BillboardController