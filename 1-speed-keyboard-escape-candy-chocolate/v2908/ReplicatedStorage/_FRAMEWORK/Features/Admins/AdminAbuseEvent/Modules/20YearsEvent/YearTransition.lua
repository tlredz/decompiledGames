local createVector = vector.create
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Config)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
require(script.Parent.Types)
local TransitionSounds = require(script.Parent.TransitionSounds)
local YearCounter = require(script.Parent.YearCounter)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = nil
local v2 = {}
local v3 = nil
local count = 0
local tweens = {}
local densitiesByInstance = {}
local now = nil
local v4 = nil
local now2 = nil
local v5 = nil
local v6 = false
local v7 = nil
local parts = {}
local v8 = 0
local v9 = false

local function getPlayerRoot(player)
	local character = player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function settleAtmosphereTweens()
	for _, v10 in tweens do
		v10:Cancel()
	end

	table.clear(tweens)

	for k, density in densitiesByInstance do
		k.Density = density
	end

	table.clear(densitiesByInstance)
end

local function captureFog()
	local atmospheres = {}

	for _, atmosphere in Lighting:GetChildren() do
		if atmosphere:IsA("Atmosphere") then
			table.insert(atmospheres, {
				instance = atmosphere,
				density = atmosphere.Density
			})
		end
	end

	return {
		start = Lighting.FogStart,
		finish = Lighting.FogEnd,
		color = Lighting.FogColor,
		atmospheres = atmospheres
	}
end

local function restoreFog(flag: boolean?)
	settleAtmosphereTweens()
	now = nil
	v4 = nil
	now2 = nil
	v5 = nil
	v6 = false
	local v10 = v

	if v10 then
		count += 1
		Lighting.FogStart = v10.start
		Lighting.FogEnd = v10.finish
		Lighting.FogColor = v10.color

		for _, atmosphere in v10.atmospheres do
			local instance = atmosphere.instance

			if instance.Parent == nil then
				instance.Density = flag and 0 or atmosphere.density
				instance.Parent = Lighting

				if flag then
					densitiesByInstance[instance] = atmosphere.density
					local tween = TweenService:Create(instance, TweenInfo.new(Config.yearAtmosphereFadeSeconds), {
						Density = atmosphere.density
					})
					table.insert(tweens, tween)
					tween:Play()
				end
			else
				instance.Density = atmosphere.density
			end
		end

		v = nil
	end
end

local function releaseLift(p)
	local v10 = v2[p]

	if v10 then
		v10.tween:Cancel()
		v10.align:Destroy()
		v10.attachment:Destroy()

		if v10.root.Parent then
			pcall(function()
				v10.root:SetNetworkOwnershipAuto()
			end)
		end

		v2[p] = nil
	end
end

local function checkLiftRecoveryReady(player)
	local v10 = v2[player]

	if not v10 or v10.recoveryAttempted or not v10.root.Parent then
		return nil
	end

	local character = player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if humanoidRootPart ~= v10.root then
		return nil
	end

	local now3 = os.clock()
	local Y = v10.root.Position.Y

	if v10.lastProgressY + Config.yearLiftProgressStuds <= Y then
		v10.lastProgressY = Y
		v10.lastProgressAt = now3
	end

	if Config.yearAtmosphereFadeSeconds + Config.yearFogBuildSeconds <= now3 - v10.startedAt and now3 - v10.lastProgressAt >= Config.yearLiftStallSeconds and (v10.root.Position - v10.finalPosition).Magnitude > Config.yearLiftRecoveryDistance then
		return v10
	end

	return nil
end

local function getCloudTemplates()
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local child

	if adminAbuse then
		child = adminAbuse:FindFirstChild(Config.assetFolderName)
	end

	local assets

	if child then
		assets = child:FindFirstChild("Assets")
	end

	local cloudTransition

	if assets then
		cloudTransition = assets:FindFirstChild("CloudTransition")
	end

	local parts2 = {}

	if not (cloudTransition and cloudTransition:IsA("Model")) then
		return parts2, nil
	end

	local primaryPart = cloudTransition.PrimaryPart or cloudTransition:FindFirstChild("Root")

	if not (primaryPart and primaryPart:IsA("BasePart")) then
		return parts2, nil
	end

	for _, part in cloudTransition:GetChildren() do
		if part:IsA("BasePart") and part ~= primaryPart then
			table.insert(parts2, part)
		end
	end

	return parts2, primaryPart
end

local function beginLandscape()
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local child

	if adminAbuse then
		child = adminAbuse:FindFirstChild(Config.assetFolderName)
	end

	local assets

	if child then
		assets = child:FindFirstChild("Assets")
	end

	local invertedSphereLandscape

	if assets then
		invertedSphereLandscape = assets:FindFirstChild("InvertedSphereLandscape")
	end

	local currentCamera = Workspace.CurrentCamera

	if not (invertedSphereLandscape and (invertedSphereLandscape:IsA("Model") or invertedSphereLandscape:IsA("BasePart")) and currentCamera) then
		v8 = os.clock() + 0.5
		return
	end

	local clone = invertedSphereLandscape:Clone()
	v7 = clone

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addVisual(part)
		table.insert(parts, part)
		part.Transparency = 1

		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.CastShadow = false
		end
	end

	if clone:IsA("BasePart") then
		addVisual(clone) -- equivalent call inferred; original call site unknown
	end

	for _, descendant in clone:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
			continue
		end

		addVisual(descendant) -- equivalent call inferred; original call site unknown
	end

	clone.Parent = currentCamera
	clone:PivotTo(currentCamera.CFrame)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearLandscape()
	if v7 then
		v7:Destroy()
		v7 = nil
	end

	table.clear(parts)
	v8 = 0
end

local function updateLandscape()
	local v10 = v7
	local currentCamera = Workspace.CurrentCamera

	if v10 and currentCamera then
		if v10.Parent ~= currentCamera then
			v10.Parent = currentCamera
		end

		v10:PivotTo(currentCamera.CFrame)
		local v11 = math.clamp(
			(Config.landscapeFadeStartFogEnd - Lighting.FogEnd) / (Config.landscapeFadeStartFogEnd - Config.landscapeFadeEndFogEnd),
			0,
			1
		)

		for _, v12 in parts do
			v12.Transparency = 1 - v11
		end
	end
end

local function clearClouds()
	local v10 = v3

	if v10 then
		v3 = nil

		for _, tween in v10.tweens do
			tween:Cancel()
		end

		for _, part in v10.parts do
			part:Destroy()
		end
	end
end

local function beginClouds(player, planeY: number)
	clearClouds()
	local character = player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	local cloudTemplates, v10 = getCloudTemplates()

	if humanoidRootPart and v10 and #cloudTemplates > 0 then
		local random = Random.new()
		local v11 = {
			parts = {},
			tweens = {},
			driftDirections = {},
			decals = {},
			planeY = planeY,
			lastRootPosition = humanoidRootPart.Position,
			peakPosition = Vector3.new(
				humanoidRootPart.Position.X,
				planeY + Config.cloudBelowPeak,
				humanoidRootPart.Position.Z
			),
			lastUpdatedAt = os.clock(),
			approachEndsAt = os.clock() + Config.cloudApproachSeconds,
			teleportArmed = false,
			teleported = false
		}
		v3 = v11
		local number = random:NextNumber(0, 6.283185307179586)
		local v12 = 6.283185307179586 / #cloudTemplates
		local tweenInfo = TweenInfo.new(Config.cloudApproachSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for k, cloudTemplate in cloudTemplates do
			local v13 = number + v12 * (k - 1) + random:NextNumber(-v12 * 0.25, v12 * 0.25)
			local v14 = Config.cloudApproachRadius + random:NextNumber(
				-Config.cloudRadiusVariation,
				Config.cloudRadiusVariation
			)
			local v15 = v13 + random:NextNumber(-1.2566370614359172, 1.2566370614359172)
			v11.driftDirections[k] = Vector3.new(math.cos(v15), 0, (math.sin(v15)))
			local v16 = cloudTemplate.Position.Y - v10.Position.Y
			local vector2 = Vector3.new(humanoidRootPart.Position.X, planeY + v16 - k * 3, humanoidRootPart.Position.Z)
			local clone = cloudTemplate:Clone()
			clone.Name = "AnniversaryTransitionCloud"
			clone.Anchored = true
			clone.CanCollide = false
			clone.CanTouch = false
			clone.CanQuery = false
			clone.Position = vector2 + Vector3.new(math.cos(v13) * v14, 0, math.sin(v13) * v14)

			for _, decal in clone:GetDescendants() do
				if not decal:IsA("Decal") then
					continue
				end

				local transparency = decal.Transparency
				v11.decals[decal] = transparency
				decal.Transparency = 1
				local tween = TweenService:Create(decal, tweenInfo, {
					Transparency = transparency
				})
				table.insert(v11.tweens, tween)
				tween:Play()
			end

			clone.Parent = Workspace
			table.insert(v11.parts, clone)
			local tween = TweenService:Create(clone, tweenInfo, {
				Position = vector2
			})
			table.insert(v11.tweens, tween)
			tween:Play()
		end
	elseif humanoidRootPart then
		logger:warn("20th Anniversary transition requires CloudTransition with Root and cloud parts in ReplicatedStorage.AdminAbuse.20Anniversary.Assets")
	end
end

local function updateClouds(player)
	local v10 = v3
	local character = player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if v10 and humanoidRootPart then
		local now3 = os.clock()
		local v11 = math.min(now3 - v10.lastUpdatedAt, 0.1)
		local v12 = humanoidRootPart.Position - v10.lastRootPosition
		local v13 = v10.teleportArmed and not v10.teleported and v12.Magnitude >= 40

		if v13 then
			v10.teleported = true
			v10.planeY += v12.Y
			v4 = humanoidRootPart.Position.Y - Config.yearLandingHeight
			now = nil
			v10.approachEndsAt = now3

			for _, part in v10.parts do
				part.Position += v12
			end
		end

		if v10.approachEndsAt <= now3 then
			if #v10.tweens > 0 then
				for _, tween in v10.tweens do
					tween:Cancel()
				end

				table.clear(v10.tweens)

				for k, decal in v10.decals do
					k.Transparency = decal
				end
			end

			for k, part in v10.parts do
				local cloudDescentDriftSpeed

				if v10.teleported then
					cloudDescentDriftSpeed = Config.cloudDescentDriftSpeed
				else
					cloudDescentDriftSpeed = Config.cloudDriftSpeed
				end

				local v14 = (not v10.teleported or v13) and createVector(0, 0, 0) or Vector3.new(v12.X, 0, v12.Z) * Config.cloudDescentFollowFraction
				part.Position += v10.driftDirections[k] * cloudDescentDriftSpeed * v11 + v14
			end
		end

		if v10.teleported then
			local v14 = humanoidRootPart.Position.Y - v10.planeY
			local v15 = math.clamp(
				(Config.cloudBelowPeak - v14) / (Config.cloudBelowPeak - Config.cloudVanishAboveHeight),
				0,
				1
			)

			for k, decal in v10.decals do
				k.Transparency = decal + (1 - decal) * v15
			end

			if v14 <= Config.cloudVanishAboveHeight then
				clearClouds()
			end
		end

		v10.lastRootPosition = humanoidRootPart.Position
		v10.lastUpdatedAt = now3
	end
end

local YearTransition = {
	startClient = function()
		v9 = true

		if not v7 then
			beginLandscape()
		end
	end,
	applyMapLighting = function(callback)
		settleAtmosphereTweens()
		local v10 = v

		if not v10 then
			callback()
			return
		end

		local fogStart = Lighting.FogStart
		local fogEnd = Lighting.FogEnd
		local fogColor = Lighting.FogColor

		for _, atmosphere in v10.atmospheres do
			atmosphere.instance.Density = atmosphere.density
			atmosphere.instance.Parent = Lighting
		end

		callback()
		local v11 = captureFog()
		v = v11

		for _, atmosphere in v11.atmospheres do
			atmosphere.instance.Parent = nil
		end

		Lighting.FogStart = fogStart
		Lighting.FogEnd = fogEnd
		Lighting.FogColor = fogColor
	end,
	onServer = function(player, p, _: number, _: number)
		if p == "launch" then
			releaseLift(player)
			local character = player.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			else
				humanoidRootPart = nil
			end

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			if humanoidRootPart then
				pcall(function()
					humanoidRootPart:SetNetworkOwner(nil)
				end)
				local attachment = Instance.new("Attachment")
				attachment.Name = "AnniversaryLiftAttachment"
				attachment.Parent = humanoidRootPart
				local alignPosition = Instance.new("AlignPosition")
				alignPosition.Name = "AnniversaryLift"
				alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
				alignPosition.Attachment0 = attachment
				alignPosition.Position = humanoidRootPart.Position
				alignPosition.MaxForce = 1000000
				alignPosition.MaxVelocity = Config.yearLiftSpeed
				alignPosition.Responsiveness = 50
				alignPosition.Parent = humanoidRootPart
				local v10 = humanoidRootPart.Position + Vector3.new(0, Config.yearLiftHeight, 0)
				local tween = TweenService:Create(
					alignPosition,
					TweenInfo.new(Config.yearLiftTweenSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = v10
					}
				)
				v2[player] = {
					root = humanoidRootPart,
					attachment = attachment,
					align = alignPosition,
					tween = tween,
					finalPosition = v10,
					reachedAt = nil,
					startedAt = os.clock(),
					lastProgressAt = os.clock(),
					lastProgressY = humanoidRootPart.Position.Y,
					recoveryAttempted = false,
					recovered = false
				}
				tween:Play()
			end
		elseif p == "peak" or p == "finish" then
			releaseLift(player)
		end
	end,
	recoverBlockedLift = function(player, callback)
		local v10 = checkLiftRecoveryReady(player)

		if v10 then
			v10.recoveryAttempted = true

			if callback(player, player.Character:GetPivot() + (v10.finalPosition - v10.root.Position)) then
				v10.tween:Cancel()
				v10.align.Position = v10.finalPosition
				v10.recovered = true
				v10.reachedAt = nil
			end
		end
	end,
	hasReachedPeak = function(p)
		local v10 = v2[p]

		if v10 and v10.root.Parent then
			if (v10.recovered or v10.tween.PlaybackState == Enum.PlaybackState.Completed) and (v10.root.Position - v10.finalPosition).Magnitude <= 6 then
				v10.reachedAt = v10.reachedAt or os.clock()
				return os.clock() - v10.reachedAt >= Config.yearPeakHoldSeconds
			else
				v10.reachedAt = nil
			end
		end

		return false
	end,
	releasePlayer = function(p)
		releaseLift(p)
	end,
	cleanupServer = function()
		for k in v2 do
			releaseLift(k)
		end
	end,
	onClient = function(player, p, p2: number, p3: number)
		if p == "launch" then
			TransitionSounds.cleanup()
			TransitionSounds.play(Config.yearTransitionSounds.elevate)
			restoreFog()
			YearCounter.show(p2, p3)
			count += 1
			local v10 = count
			local v11 = captureFog()
			v = v11

			for _, atmosphere in v11.atmospheres do
				local tween = TweenService:Create(
					atmosphere.instance,
					TweenInfo.new(Config.yearAtmosphereFadeSeconds),
					{
						Density = 0
					}
				)
				table.insert(tweens, tween)
				tween:Play()
			end

			Lighting.FogStart = Config.yearFogFarStart
			Lighting.FogEnd = Config.yearFogFarEnd
			Lighting.FogColor = Color3.fromRGB(210, 220, 235)

			if #v11.atmospheres > 0 then
				task.delay(Config.yearAtmosphereFadeSeconds, function()
					local v12 = v

					if v10 == count and v12 then
						for _, atmosphere in v12.atmospheres do
							atmosphere.instance.Parent = nil
						end

						now = os.clock()
					end
				end)
			else
				now = os.clock()
			end

			local character = player.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			if humanoidRootPart then
				v5 = humanoidRootPart.Position.Y + Config.yearLiftHeight - Config.cloudBelowPeak
			end
		elseif p == "peak" then
			YearCounter.roll()
			TransitionSounds.play(Config.yearTransitionSounds.launchBack)

			if not v6 then
				local character = player.Character
				local humanoidRootPart

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					humanoidRootPart = nil
				end

				if humanoidRootPart then
					v6 = true
					beginClouds(player, humanoidRootPart.Position.Y - Config.cloudBelowPeak)
				end
			end

			local v10 = v3

			if v10 then
				v10.teleportArmed = true
				local character = player.Character
				local humanoidRootPart

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					humanoidRootPart = nil
				end

				if humanoidRootPart and (humanoidRootPart.Position - v10.peakPosition).Magnitude >= 40 then
					v10.lastRootPosition = v10.peakPosition
					updateClouds(player)
				end
			end
		elseif p == "finish" then
			YearCounter.roll()
			v5 = nil
			now2 = os.clock()

			if not v4 then
				now = nil
			end
		end
	end,
	updateClient = function(player)
		if v9 and not v7 then
			local now3 = os.clock()

			if v8 <= now3 then
				beginLandscape()
			end
		end

		updateClouds(player)
		local v10 = now

		if v10 then
			local v11 = math.clamp((os.clock() - v10) / Config.yearFogBuildSeconds, 0, 1)
			Lighting.FogStart = math.exp(math.log(Config.yearFogFarStart) + (math.log(Config.yearFogNearStart) - math.log(Config.yearFogFarStart)) * v11)
			Lighting.FogEnd = math.exp(math.log(Config.yearFogFarEnd) + (math.log(Config.yearFogDistance) - math.log(Config.yearFogFarEnd)) * v11)

			if v11 >= 1 then
				now = nil
			end
		end

		local v11 = v4
		local v12 = now2
		local character = player.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		if v and (v11 and humanoidRootPart or v12) then
			local v13 = math.max(
				not (v11 and humanoidRootPart) and 0 or math.clamp(
					(Config.yearFogRevealStartHeight - (humanoidRootPart.Position.Y - v11)) / (Config.yearFogRevealStartHeight - Config.yearFogRevealEndHeight),
					0,
					1
				),
				not v12 and 0 or math.clamp((os.clock() - v12) / Config.yearFogFallbackRevealSeconds, 0, 1)
			)
			local v14 = v

			if v14 then
				Lighting.FogStart = math.exp(math.log(Config.yearFogNearStart + 1) + (math.log(v14.start + 1) - math.log(Config.yearFogNearStart + 1)) * v13) - 1
				Lighting.FogEnd = math.exp(math.log(Config.yearFogDistance + 1) + (math.log(v14.finish + 1) - math.log(Config.yearFogDistance + 1)) * v13) - 1
				Lighting.FogColor = Color3.fromRGB(210, 220, 235):Lerp(v14.color, v13)
			end

			if v13 >= 1 then
				clearClouds()
				restoreFog(true)
			end
		end

		updateLandscape()
		local planeY = v5

		if planeY and not v6 and humanoidRootPart and humanoidRootPart.Position.Y >= planeY + Config.cloudAppearAboveHeight then
			v6 = true
			beginClouds(player, planeY)
		end
	end,
	cancelClientTransition = function()
		TransitionSounds.cleanup()
		YearCounter.reset()
		restoreFog()
		clearClouds()
	end
}

function YearTransition.cleanupClient()
	v9 = false
	YearTransition.cancelClientTransition()
	clearLandscape() -- equivalent call inferred; original call site unknown
end

return YearTransition