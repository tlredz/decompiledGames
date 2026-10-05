local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
require(ReplicatedStorage.Shared.Types.AreaEggResetCycle)
local BossMastery = require(ReplicatedStorage.Data.BossMastery)
local Catalog = require(ReplicatedStorage.Shared.Modules.Mutations.Catalog)
local ScrambleMutationFlags = require(ReplicatedStorage.Shared.Flags.ScrambleMutationFlags)
local BossMasteryFlags = require(ReplicatedStorage.Shared.Flags.BossMasteryFlags)
local EggActionMovement = require(script.Parent.EggActionMovement)
local EggGrowthAnimation = require(script.Parent.EggGrowthAnimation)
local EggHatchAnimation = require(script.Parent.EggHatchAnimation)
local EggMechaUpgradeAnimation = require(script.Parent.EggMechaUpgradeAnimation)
local EggPlaceAnimation = require(script.Parent.EggPlaceAnimation)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local EggRenderer = require(script.Parent.EggRenderer)
local EggSkipAnimation = require(script.Parent.EggSkipAnimation)
local EggState = require(ReplicatedStorage.Client.EggState)
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local Log = require(ReplicatedStorage.Packages.Log)
local ModelCameraOcclusion = require(ReplicatedStorage.Client.ModelCameraOcclusion)
local MutationConsumableFeedback = require(script.Parent.MutationConsumableFeedback)
local NightEggTimeSkipAnimation = require(script.Parent.NightEggTimeSkipAnimation)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local ParasiteVisual = require(script.Parent.ParasiteVisual)
local PlacedEggBillboard = require(script.Parent.PlacedEggBillboard)
local PlacedEggGrowthPresentationPolicy = require(script.Parent.PlacedEggGrowthPresentationPolicy)
local PlacedEggReadyPulse = require(script.Parent.PlacedEggReadyPulse)
local PlotState = require(ReplicatedStorage.Client.PlotState)
require(ReplicatedStorage.Shared.Types.Plots)
local Products = require(ReplicatedStorage.Data.Products)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local SmartProximityPrompt = require(ReplicatedStorage.Client.SmartProximityPrompt)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryLock = require(ReplicatedStorage.Shared.Utils.TryLock)
local t = require(ReplicatedStorage.Packages.t)
require(script.Parent.Types)
local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 64, 64)
local color2 = Color3.fromRGB(255, 196, 80)
local color3 = Color3.fromRGB(80, 255, 120)
local v = {}
local v2 = 0
local random = Random.new()
local random2 = Random.new()
local dayStartsAt = nil
local v3 = false
local v4 = false
local v5 = "Boss"
local flag = false
local v6 = 0
local v7 = Trove.new()
local folder = Instance.new("Folder")
folder.Name = "PlacedEggRenders"
folder.Parent = workspace
local v8 = Log.new()
local PlacedEggRenderer = {
	LocalEggHatchStarted = Signal.new()
}
local getDirectGrowthTweenRemainingSeconds = PlacedEggGrowthPresentationPolicy.GetDirectGrowthTweenRemainingSeconds
local getStartScale = PlacedEggGrowthPresentationPolicy.GetStartScale
local getTargetScale = PlacedEggGrowthPresentationPolicy.GetTargetScale
local getVisualScale = PlacedEggGrowthPresentationPolicy.GetVisualScale
local isReady = PlacedEggGrowthPresentationPolicy.IsReady
local getRemainingGrowthSeconds = PlacedEggGrowthPresentationPolicy.GetRemainingGrowthSeconds

-- equivalent calls inferred from this helper; original call sites unknown
local function getKey(p: number, k: string)
	return (`{p}:{k}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOwnerPlayer(p: number)
	return Players:GetPlayerByUserId(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function readOwnerPlotData(p: number)
	local ownerPlayer = getOwnerPlayer(p) -- equivalent call inferred; original call site unknown

	if ownerPlayer == nil then
		return nil
	end

	return PlotState.ResolvePlot(ownerPlayer)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isLocalOwner(p: number)
	return p == Players.LocalPlayer.UserId
end

local function getNextReadyPulseAt(p: number)
	return p + random:NextNumber(5, 10)
end

local function getNextGrowthPulseAt(p: number)
	return p + random2:NextNumber(27, 65)
end

local function getInitialGrowthUpdateAt(p: number)
	local v9 = p + v2 * 0.2
	v2 = (v2 + 1) % 25
	return v9
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getNightTimeSkipSecondsValue(p)
	local nightTimeSkipAnimation = p.NightTimeSkipAnimation

	if nightTimeSkipAnimation == nil then
		return nil
	end

	return (nightTimeSkipAnimation:GetAppliedSecondsValue())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getNightTimeSkipSeconds(p)
	local nightTimeSkipSecondsValue = getNightTimeSkipSecondsValue(p) -- equivalent call inferred; original call site unknown

	if nightTimeSkipSecondsValue == nil then
		return 0
	end

	return nightTimeSkipSecondsValue.Value
end

local function isNightTimeSkipControllingPresentation(p)
	local nightTimeSkipAnimation = p.NightTimeSkipAnimation
	return nightTimeSkipAnimation ~= nil and not nightTimeSkipAnimation:IsComplete()
end

local function clearNightTimeSkipAnimation(state)
	local nightTimeSkipAnimation = state.NightTimeSkipAnimation

	if nightTimeSkipAnimation == nil then
		return
	end

	state.NightTimeSkipAnimation = nil

	if state.NightBillboardSuppressed then
		state.NightBillboardSuppressed = false
		PlacedEggBillboard.SetNightPresentationActive(state.OwnerUserId, state.Uid, false)
	end

	nightTimeSkipAnimation:Destroy()
	local scaleValue = state.ScaleValue

	if scaleValue ~= nil and state.Result.Model.Parent ~= nil then
		scaleValue.Value = state.Result.Model:GetScale()
	end
end

local function startNightTimeSkipForState(state, p: number)
	if not isLocalOwner(state.OwnerUserId) or state.IsHatching or state.Result.Model.Parent == nil or state.NightTimeSkipAnimation ~= nil then
		return
	end

	local placement = state.Record.Placement
	local v9 = p - AreaEggCycle.NightLengthSeconds()

	if placement == nil or placement.ReadyAt ~= nil or v9 < placement.PlacedAt then
		return
	end

	if EggRecords.IsGrown(
		state.Record,
		v9,
		state.Record.GrowthSpeedMultiplier,
		nil,
		Players:GetPlayerByUserId(state.OwnerUserId)
	) or p <= Workspace:GetServerTimeNow() then
		return
	end

	local growthAnimation = state.GrowthAnimation

	if growthAnimation ~= nil then
		growthAnimation:Cancel()
	end

	local readyPulse = state.ReadyPulse

	if readyPulse ~= nil then
		readyPulse:Cancel()
	end

	local scaleTween = state.ScaleTween

	if scaleTween ~= nil then
		scaleTween:Cancel()
		state.ScaleTween = nil
		state.DirectGrowthTweenActive = false
	end

	local nightTimeSkipAnimation = NightEggTimeSkipAnimation.new(
		state.Result.Model,
		state.Uid,
		state.Record,
		state.BasePivot,
		state.StartScale,
		state.TargetScale,
		v9,
		p
	)
	state.NightTimeSkipAnimation = nightTimeSkipAnimation
	PlacedEggBillboard.SetEntry({
		OwnerUserId = state.OwnerUserId,
		Uid = state.Uid,
		Record = state.Record,
		Model = state.Result.Model,
		TimeSkipSeconds = nightTimeSkipAnimation:GetAppliedSecondsValue()
	})
	state.NightBillboardSuppressed = true
	PlacedEggBillboard.SetNightPresentationActive(state.OwnerUserId, state.Uid, true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startNightTimeSkip(p)
	dayStartsAt = p.DayStartsAt

	for _, v9 in pairs(v) do
		startNightTimeSkipForState(v9, p.DayStartsAt)
	end
end

local function setStateScale(state, p: number, p2, flag2: boolean?, flag3: boolean?)
	if isLocalOwner(state.OwnerUserId) then
		local scaleValue = state.ScaleValue

		if scaleValue ~= nil then
			local scaleTween = state.ScaleTween
			local v9 = scaleTween ~= nil

			if scaleTween ~= nil then
				scaleTween:Cancel()
				state.ScaleTween = nil
				state.DirectGrowthTweenActive = false
			end

			if flag2 == false then
				if flag3 == true then
					state.DirectGrowthTweenActive = true
				end

				local v10 = math.abs(scaleValue.Value - p) > 0.001

				if v10 then
					scaleValue.Value = p
				end

				return v9 or v10
			elseif math.abs(scaleValue.Value - p) <= 0.001 then
				if flag3 == true then
					state.DirectGrowthTweenActive = true
				end

				return false
			else
				local tween = TweenService:Create(scaleValue, p2 or tweenInfo, {
					Value = p
				})
				state.ScaleTween = tween
				state.DirectGrowthTweenActive = flag3 == true
				tween.Completed:Once(function()
					if state.ScaleTween == tween then
						state.ScaleTween = nil

						if flag3 == true then
							state.DirectGrowthTweenActive = false
						end
					end
				end)
				tween:Play()
				return false
			end
		end
	end

	state.Result.Model:ScaleTo(p)
	EggRenderer.DisableCollisions(state.Result.Model)
	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startDirectGrowthTween(p, directGrowthTweenRemainingSeconds: number)
	local tweenInfo3 = TweenInfo.new(
		math.max(directGrowthTweenRemainingSeconds, 0.05),
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	setStateScale(p, p.TargetScale, tweenInfo3, true, true)
end

local function hasSkipGrowthCredit(productId: number)
	local Save = require(ReplicatedStorage.Shared.Save)

	if not Save.IsLoaded() then
		return false
	end

	local v9 = Save.Await()
	local productCredits

	if v9 ~= nil then
		productCredits = v9.ProductCredits
	end

	if typeof(productCredits) ~= "table" then
		return false
	end

	local productCredit = productCredits[tostring(productId)]
	return typeof(productCredit) == "number" and productCredit > 0
end

local function updatePrompt(data)
	local prompt = data.Prompt

	if prompt == nil then
		return
	end

	if flag or data.MutationPresenting then
		prompt.Enabled = false
	elseif isLocalOwner(data.OwnerUserId) then
		if v4 then
			local v9 = table.find(data.Record.Mutations or {}, v5) ~= nil or data.Record.BaseMutation == v5
			prompt.Enabled = not (v3 or data.IsHatching or v9)
			prompt.HoldDuration = 1
			prompt.ActionText = "Apply Mutation"
			local v11 = v5 == "Scrambled" and "Scrambled" or "Fractured"
			local v12

			if v5 == "Scrambled" then
				v12 = ScrambleMutationFlags.SuccessPercent:Get()
			else
				v12 = BossMasteryFlags.MutationConsumableSuccessPercent:Get()
			end

			prompt.ObjectText = `{v11} · {v12}% Success Chance`
		else
			local nightTimeSkipSeconds = getNightTimeSkipSeconds(data) -- equivalent call inferred; original call site unknown
			local ready = isReady(data.Record, nightTimeSkipSeconds)
			local v9

			if not ready then
				v9 = Products.GetEggSkipGrowthProduct(getRemainingGrowthSeconds(data.Record, nightTimeSkipSeconds))
			end

			local v11 = ready and "Hatch!" or v9 ~= nil and hasSkipGrowthCredit(v9.ProductId) and "Skip Growth (FREE!)" or "Skip Growth!"
			local v12 = ready or v9 ~= nil
			prompt.Enabled = not v3 and not data.IsHatching and v12
			prompt.HoldDuration = 0
			prompt.ActionText = v11
			prompt.ObjectText = v11
		end
	else
		prompt.Enabled = v4 and not v3 and not (flag or data.IsHatching)
		prompt.HoldDuration = 1
		prompt.ActionText = "Apply Mutation"
		prompt.ObjectText = "Egg"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateAllPrompts()
	for _, v9 in pairs(v) do
		updatePrompt(v9)
	end
end

local function notifyMutation(text: string, color4: Color3, p2: string)
	local shopProduct = BossMastery.GetShopProduct("MutationConsumable")
	local icon

	if shopProduct then
		icon = shopProduct.Icon
	end

	if p2 == "Scrambled" and Catalog.Scrambled.IconAssetId ~= nil then
		icon = "rbxassetid://" .. tostring(Catalog.Scrambled.IconAssetId)
	end

	Toast.Show({
		Text = text,
		Seconds = 2.5,
		Color = color4,
		Image = icon,
		SingleLine = true
	})
end

local fn
local onOwnerRefreshed

local function applyMutation(state)
	if isLocalOwner(state.OwnerUserId) then
		if flag then
			return
		end

		local formatted = `{state.OwnerUserId}:{state.Uid}`
		local ownerUserId = state.OwnerUserId
		local v9 = v5
		flag = true
		state.MutationPresenting = true
		updateAllPrompts() -- equivalent call inferred; original call site unknown
		local success, result = pcall(function()
			return Remotes.BossMastery.AskUseMutationConsumable:InvokeServer(state.Uid)
		end)
		flag = false
		local mutated

		if success then
			if type(result) == "table" then
				mutated = result.Success and result.Mutated
			else
				mutated = false
			end
		else
			mutated = success
		end

		local v10

		if success then
			if type(result) == "table" then
				v10 = result.Success and not result.Mutated
			else
				v10 = false
			end
		else
			v10 = success
		end

		if not (mutated or v10) then
			state.MutationPresenting = false
			updateAllPrompts() -- equivalent call inferred; original call site unknown

			if v[formatted] == state then
				onOwnerRefreshed(ownerUserId)
			end
		end

		if not success or type(result) ~= "table" then
			notifyMutation("Something went wrong, please try again.", color, v9)
			return
		end

		if not result.Success then
			notifyMutation(result.Message or "The consumable could not be used.", color, v9)
			return
		end

		local mutationId = result.MutationId or v9
		local v11 = mutationId == "Scrambled" and "Scrambled" or "Fractured"

		local function getCurrentModel()
			local v12 = v[formatted]

			if v12 == nil then
				return nil
			end

			return v12.Result.Model
		end

		if mutated then
			if v[formatted] == state then
				MutationConsumableFeedback.PlaySuccess({
					MutationId = mutationId,
					Pivot = state.BasePivot,
					GetModel = getCurrentModel,
					OnReveal = function()
						notifyMutation(`{v11} mutation applied!`, color3, mutationId)
					end,
					OnFinished = function()
						local v12 = v[formatted]

						if v12 ~= nil then
							v12.MutationPresenting = false
						end

						if v[formatted] == state then
							fn(formatted)
						end

						onOwnerRefreshed(ownerUserId)
						updateAllPrompts() -- equivalent call inferred; original call site unknown
					end
				})
			else
				onOwnerRefreshed(ownerUserId)
				notifyMutation(`{v11} mutation applied!`, color3, mutationId)
			end
		else
			MutationConsumableFeedback.PlayFailure({
				MutationId = mutationId,
				Pivot = state.BasePivot,
				GetModel = getCurrentModel,
				OnVerdict = function()
					notifyMutation(
						result.Message or mutationId == "Scrambled" and "The mutation failed..." or "The consumable fizzled...",
						color2,
						mutationId
					)
				end,
				OnFinished = function()
					local v12 = v[formatted]

					if v12 ~= nil then
						v12.MutationPresenting = false
					end

					onOwnerRefreshed(ownerUserId)
					updateAllPrompts() -- equivalent call inferred; original call site unknown
				end
			})
		end
	else
		local now = os.clock()

		if v6 <= now then
			v6 = now + 2.5
			notifyMutation("can only be used on your own eggs", Color3.fromRGB(255, 100, 100), v5)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackOcclusion(state)
	assert(not state.OcclusionTracked, (`Placed egg {state.Uid} occlusion is already tracked`))
	ModelCameraOcclusion.Register(state.Result.Model, 1)
	state.OcclusionTracked = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function untrackOcclusion(state)
	if not state.OcclusionTracked then
		return
	end

	ModelCameraOcclusion.Forget(state.Result.Model)
	state.OcclusionTracked = false
end

local function runHatchPresentation(data, flag2: boolean)
	if isLocalOwner(data.OwnerUserId) then
		PlacedEggRenderer.LocalEggHatchStarted:Fire(data.Uid)
	end

	local v9 = EggHatchAnimation.Play(data.OwnerUserId, data.Uid, data.Record, data.Result.Model, flag2)
	local v10, v11, v12 = EggState.FinishHatch(data.Uid)

	if v10 then
		if v9 ~= nil then
			local v13 = assert(v12, "Successful hatch completion must return the granted asset UID")
			EggHatchAnimation.FadeSoundWhenGrantedToolUnequips(v9, v13)
		end
	else
		v8:AtWarning():Log((`Failed to complete hatch for egg {data.Uid}: {v11 or "unknown"}`))
		fn((`{data.OwnerUserId}:{data.Uid}`))
		onOwnerRefreshed(data.OwnerUserId)
	end
end

local function activatePrompt(state)
	local readyPulse = state.ReadyPulse

	if readyPulse == nil then
		return false, "Egg is not owned by the local player"
	end

	if isReady(state.Record, getNightTimeSkipSeconds(state)) then
		if state.HatchLock(function()
			state.IsHatching = true
			untrackOcclusion(state) -- equivalent call inferred; original call site unknown
			state.NextReadyPulseAt = nil
			readyPulse:Cancel()
			updatePrompt(state)
			local v11, v12, v13 = EggState.BeginHatch(state.Uid)

			if v11 then
				if v13 ~= Eggs.HATCH_RESULT_MECHA_UPGRADED then
					runHatchPresentation(state, false)
					return
				end

				local formatted = `{state.OwnerUserId}:{state.Uid}`
				local ownerUserId = state.OwnerUserId
				EggMechaUpgradeAnimation.Play(ownerUserId, state.Result.Model, function()
					fn(formatted)
					onOwnerRefreshed(ownerUserId)
					local v14 = v[formatted]

					if v14 == nil then
						return nil
					end

					v14.IsHatching = true
					untrackOcclusion(v14) -- equivalent call inferred; original call site unknown
					v14.NextReadyPulseAt = nil
					local readyPulse2 = v14.ReadyPulse

					if readyPulse2 ~= nil then
						readyPulse2:Cancel()
					end

					updatePrompt(v14)
					return v14.Result.Model
				end)
				local v14 = v[formatted]

				if v14 == nil then
					EggState.FinishHatch(state.Uid)
				else
					runHatchPresentation(v14, true)
				end
			else
				state.IsHatching = false
				trackOcclusion(state) -- equivalent call inferred; original call site unknown
				updatePrompt(state)
				v8:AtWarning():Log((`Failed to hatch egg {state.Uid}: {v12 or "unknown"}`))
			end
		end) then
			return true
		end

		v8:AtDebug():Log((`Ignored duplicate hatch prompt for egg {state.Uid}`))
		return false, "Egg is already hatching"
	else
		local v10, v11, v12 = EggState.BeginSkipGrowth(state.Uid)

		if v10 and v12 then
			Storefront.Prompt(v12, true)
			return true
		end

		v8:AtWarning():Log((`Failed to request skip growth for egg {state.Uid}: {v11 or "unknown"}`))
		return false, v11
	end
end

fn = function(p: string)
	local v9 = v[p]

	if v9 == nil then
		return
	end

	untrackOcclusion(v9) -- equivalent call inferred; original call site unknown
	v[p] = nil
	clearNightTimeSkipAnimation(v9)
	PlacedEggBillboard.RemoveEntry(v9.OwnerUserId, v9.Uid)
	v9.Trove:Destroy()
end

local function destroyOwnerStates(p: number)
	for k, v9 in pairs(v) do
		if v9.OwnerUserId == p then
			fn(k)
		end
	end
end

local function addPlacedEggRenderState(ownerUserId: number, k: string, ownerEgg)
	local placement = ownerEgg.Placement

	if placement == nil then
		return
	end

	local ownerPlotData = readOwnerPlotData(ownerUserId) -- equivalent call inferred; original call site unknown

	if ownerPlotData == nil then
		return
	end

	local maid = Trove.new()
	local startScale = getStartScale(ownerEgg)
	local targetScale = getTargetScale(ownerEgg)
	local visualScale = getVisualScale(ownerEgg, startScale, targetScale)
	local basePivot = ownerPlotData.CenterPoint.CFrame * placement.LocalCFrame
	local visual = EggRenderer.RenderVisual({
		OwnerUserId = ownerUserId,
		UID = k,
		ModelName = `{ownerUserId}_{k}`,
		Record = ownerEgg,
		ScaleMultiplier = visualScale
	}, folder, false)
	maid:Add(visual.Model)
	EggActionMovement.SetPivot(visual.Model, basePivot)

	if isLocalOwner(ownerUserId) and EggState.TakePlantCue(k) then
		EggPlaceAnimation.Play(visual.Model, basePivot, folder)
	end

	local numberValue

	if isLocalOwner(ownerUserId) then
		numberValue = Instance.new("NumberValue")
		numberValue.Value = visualScale
		maid:Add(numberValue)
		maid:Add(numberValue.Changed:Connect(function(p2: number)
			visual.Model:ScaleTo(p2)
			EggRenderer.DisableCollisions(visual.Model)
		end))
	end

	local localOwner = isLocalOwner(ownerUserId) -- equivalent call inferred; original call site unknown
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.MaxActivationDistance = 7
	proximityPrompt.HoldDuration = 0
	maid:Add(SmartProximityPrompt.AttachToModel(proximityPrompt, visual.Model, {
		SurfaceOffset = 0.75,
		TrackDistance = 7,
		MaxActivationDistance = proximityPrompt.MaxActivationDistance
	}))
	local growthAnimation, readyPulse

	if localOwner then
		growthAnimation = EggGrowthAnimation.new(visual.Model, basePivot, 1)
		readyPulse = PlacedEggReadyPulse.new(visual.Model, basePivot, targetScale)
	else
		growthAnimation = nil
		readyPulse = nil
	end

	local v13 = {
		OwnerUserId = ownerUserId,
		Uid = k,
		Record = ownerEgg,
		Result = visual,
		BasePivot = basePivot,
		StartScale = startScale,
		TargetScale = targetScale,
		ScaleValue = numberValue,
		ScaleTween = nil,
		DirectGrowthTweenActive = false,
		GrowthAnimation = growthAnimation,
		NextGrowthUpdateAt = 0,
		NextGrowthPulseAt = nil,
		NightTimeSkipAnimation = nil,
		NightBillboardSuppressed = false,
		ReadyPulse = 0,
		NextReadyPulseAt = nil,
		Prompt = 0,
		Trove = 0,
		HatchLock = 0,
		IsHatching = false,
		MutationPresenting = false,
		OcclusionTracked = false
	}
	local nextGrowthUpdateAt = Workspace:GetServerTimeNow() + v2 * 0.2
	v2 = (v2 + 1) % 25
	v13.NextGrowthUpdateAt = nextGrowthUpdateAt
	v13.ReadyPulse = readyPulse
	v13.Prompt = proximityPrompt
	v13.Trove = maid
	v13.HatchLock = TryLock()
	local v15 = dayStartsAt

	if v15 ~= nil then
		startNightTimeSkipForState(v13, v15)
	end

	if readyPulse ~= nil then
		maid:Add(function()
			readyPulse:Destroy()
		end)
	end

	if growthAnimation ~= nil then
		maid:Add(function()
			growthAnimation:Destroy()
		end)
	end

	maid:Add(function()
		local scaleTween = v13.ScaleTween

		if scaleTween ~= nil then
			scaleTween:Cancel()
			v13.ScaleTween = nil
			v13.DirectGrowthTweenActive = false
		end
	end)
	v[`{ownerUserId}:{k}`] = v13
	trackOcclusion(v13) -- equivalent call inferred; original call site unknown
	local setEntry = PlacedEggBillboard.SetEntry
	local v16 = {
		OwnerUserId = ownerUserId,
		Uid = k,
		Record = ownerEgg,
		Model = visual.Model,
		TimeSkipSeconds = 0
	}
	local nightTimeSkipSecondsValue = getNightTimeSkipSecondsValue(v13) -- equivalent call inferred; original call site unknown
	v16.TimeSkipSeconds = nightTimeSkipSecondsValue
	setEntry(v16)
	updatePrompt(v13)

	if proximityPrompt ~= nil then
		maid:Add(proximityPrompt.Triggered:Connect(function(player)
			if player ~= Players.LocalPlayer then
				return
			end

			if v4 then
				applyMutation(v13)
			elseif isLocalOwner(v13.OwnerUserId) then
				activatePrompt(v13)
			end
		end))
	end

	local directGrowthTweenRemainingSeconds = getDirectGrowthTweenRemainingSeconds(
		ownerEgg,
		(Workspace:GetServerTimeNow())
	)

	if localOwner and directGrowthTweenRemainingSeconds > 0 then
		local nightTimeSkipAnimation = v13.NightTimeSkipAnimation
		local v17

		if nightTimeSkipAnimation == nil then
			v17 = false
		else
			v17 = not nightTimeSkipAnimation:IsComplete()
		end

		if not v17 then
			startDirectGrowthTween(v13, directGrowthTweenRemainingSeconds) -- equivalent call inferred; original call site unknown
		end
	end

	v8:AtDebug():Log((`Rendered placed egg {k} for owner {ownerUserId}`))
end

onOwnerRefreshed = function(ownerUserId: number)
	local ownerEggs = EggState.ReadOwnerEggs(ownerUserId)
	local ownerPlotData = readOwnerPlotData(ownerUserId) -- equivalent call inferred; original call site unknown

	if ownerPlotData == nil then
		return
	end

	local v10 = {}

	for k, ownerEgg in pairs(ownerEggs) do
		if ownerEgg.Placement == nil then
			continue
		end

		local key = getKey(ownerUserId, k) -- equivalent call inferred; original call site unknown
		v10[key] = true
		local v11 = v[key]

		if v11 ~= nil then
			if v11.IsHatching or v11.MutationPresenting then
				continue
			end

			if EggRecords.EggModelName(ownerEgg.AssetCategory, ownerEgg.Mutations, ownerEgg.BaseMutation) ~= EggRecords.EggModelName(
				v11.Record.AssetCategory,
				v11.Record.Mutations,
				v11.Record.BaseMutation
			) then
				fn(key)
				v11 = nil
			end
		end

		if v11 == nil then
			addPlacedEggRenderState(ownerUserId, k, ownerEgg)
		else
			local nightTimeSkipSeconds = getNightTimeSkipSeconds(v11) -- equivalent call inferred; original call site unknown
			local ready = isReady(v11.Record, nightTimeSkipSeconds)
			local ready2 = isReady(ownerEgg, nightTimeSkipSeconds)
			local hasParasite = v11.Record.HasParasite
			v11.Record = ownerEgg

			if ownerEgg.HasParasite ~= hasParasite then
				ParasiteVisual.Attach(v11.Result.Model, ownerEgg.HasParasite)
			end

			v11.StartScale = getStartScale(ownerEgg)
			v11.TargetScale = getTargetScale(ownerEgg)

			if ownerEgg.Placement ~= nil then
				v11.BasePivot = ownerPlotData.CenterPoint.CFrame * ownerEgg.Placement.LocalCFrame
				local readyPulse = v11.ReadyPulse

				if readyPulse ~= nil then
					readyPulse:SetTransform(v11.BasePivot, v11.TargetScale)
				end

				local growthAnimation = v11.GrowthAnimation

				if growthAnimation ~= nil then
					growthAnimation:SetBasePivot(v11.BasePivot)
				end

				local nightTimeSkipAnimation = v11.NightTimeSkipAnimation

				if nightTimeSkipAnimation ~= nil then
					nightTimeSkipAnimation:SetTransform(v11.BasePivot, v11.StartScale, v11.TargetScale)
					nightTimeSkipAnimation:AcknowledgeRecord(ownerEgg)

					if ready2 then
						nightTimeSkipAnimation:CancelVisual()
					end
				end

				local nightTimeSkipAnimation2 = v11.NightTimeSkipAnimation
				local v12

				if nightTimeSkipAnimation2 == nil then
					v12 = false
				else
					v12 = not nightTimeSkipAnimation2:IsComplete()
				end

				if not v12 and (readyPulse == nil or not readyPulse:IsPlaying()) and (growthAnimation == nil or not growthAnimation:IsPlaying()) then
					EggActionMovement.SetPivot(v11.Result.Model, v11.BasePivot)
				end
			end

			local nightTimeSkipAnimation = v11.NightTimeSkipAnimation

			if nightTimeSkipAnimation ~= nil and nightTimeSkipAnimation:IsComplete() then
				clearNightTimeSkipAnimation(v11)
			end

			local setEntry = PlacedEggBillboard.SetEntry
			local v12 = {
				OwnerUserId = ownerUserId,
				Uid = k,
				Record = ownerEgg,
				Model = v11.Result.Model,
				TimeSkipSeconds = 0
			}
			local nightTimeSkipSecondsValue = getNightTimeSkipSecondsValue(v11) -- equivalent call inferred; original call site unknown
			v12.TimeSkipSeconds = nightTimeSkipSecondsValue
			setEntry(v12)

			if isLocalOwner(ownerUserId) and not ready and ready2 and v11.NightTimeSkipAnimation == nil then
				if EggState.ReadChosenSkipUid() == k then
					setStateScale(v11, v11.TargetScale, tweenInfo2)
					task.spawn(EggSkipAnimation.Play, v11.Result.Model)
				else
					local skipReason = PlacedEggGrowthPresentationPolicy.GetSkipReason(v11.Result.Model)

					if setStateScale(v11, v11.TargetScale, nil, skipReason == nil) then
						local v13 = assert(skipReason, "Skipped natural completion requires a presentation reason")
						PlacedEggGrowthPresentationPolicy.LogSkipped(v11.Uid, "natural completion", v13)
					end
				end
			end

			updatePrompt(v11)
		end
	end

	for k, v11 in pairs(v) do
		if v11.OwnerUserId ~= ownerUserId or v10[k] then
			continue
		end

		fn(k)
	end
end

local function refreshAll()
	local ownedEggs = EggState.ReadOwnedEggs()
	local v9 = {}

	for _, ownedEgg in ipairs(ownedEggs) do
		v9[ownedEgg.OwnerUserId] = true
		onOwnerRefreshed(ownedEgg.OwnerUserId)
	end

	for k, v10 in pairs(v) do
		if not v9[v10.OwnerUserId] then
			fn(k)
		end
	end
end

local function updateReadyPulses(serverTimeNow: number)
	for _, v9 in pairs(v) do
		local readyPulse = v9.ReadyPulse

		if readyPulse == nil then
			continue
		end

		if not v9.IsHatching and v9.Result.Model.Parent ~= nil and isReady(v9.Record, getNightTimeSkipSeconds(v9)) then
			local nightTimeSkipAnimation = v9.NightTimeSkipAnimation
			local v11

			if nightTimeSkipAnimation == nil then
				v11 = false
			else
				v11 = not nightTimeSkipAnimation:IsComplete()
			end

			if not v11 then
				local nextReadyPulseAt = v9.NextReadyPulseAt

				if readyPulse:IsPlaying() then
					local skipReason = PlacedEggGrowthPresentationPolicy.GetSkipReason(v9.Result.Model)

					if skipReason == nil then
						if nextReadyPulseAt == nil then
							v9.NextReadyPulseAt = serverTimeNow + random:NextNumber(5, 10)
						end
					else
						readyPulse:Cancel()
						v9.NextReadyPulseAt = serverTimeNow + random:NextNumber(5, 10)
						PlacedEggGrowthPresentationPolicy.LogSkipped(v9.Uid, "ready pulse cancellation", skipReason)
					end
				elseif nextReadyPulseAt == nil then
					v9.NextReadyPulseAt = serverTimeNow + random:NextNumber(5, 10)
				elseif nextReadyPulseAt <= serverTimeNow then
					local skipReason = PlacedEggGrowthPresentationPolicy.GetSkipReason(v9.Result.Model)

					if skipReason == nil then
						if readyPulse:Play() then
							v9.NextReadyPulseAt = nil
						end
					else
						v9.NextReadyPulseAt = serverTimeNow + random:NextNumber(5, 10)
						PlacedEggGrowthPresentationPolicy.LogSkipped(v9.Uid, "ready pulse", skipReason)
					end
				end

				continue
			end
		end

		v9.NextReadyPulseAt = nil
		readyPulse:Cancel()
	end
end

local function updateGrowthPulses(serverTimeNow: number)
	for _, v9 in pairs(v) do
		local growthAnimation = v9.GrowthAnimation

		if growthAnimation == nil then
			continue
		end

		local directGrowthTweenRemainingSeconds = getDirectGrowthTweenRemainingSeconds(v9.Record, serverTimeNow)

		if not v9.IsHatching and v9.Result.Model.Parent ~= nil and not (isReady(v9.Record, getNightTimeSkipSeconds(v9)) or directGrowthTweenRemainingSeconds > 0) then
			local nightTimeSkipAnimation = v9.NightTimeSkipAnimation
			local v11

			if nightTimeSkipAnimation == nil then
				v11 = false
			else
				v11 = not nightTimeSkipAnimation:IsComplete()
			end

			if not v11 then
				local nextGrowthPulseAt = v9.NextGrowthPulseAt

				if growthAnimation:IsPlaying() then
					local skipReason = PlacedEggGrowthPresentationPolicy.GetSkipReason(v9.Result.Model)

					if skipReason ~= nil then
						growthAnimation:Cancel()
						v9.NextGrowthPulseAt = serverTimeNow + random2:NextNumber(27, 65)
						PlacedEggGrowthPresentationPolicy.LogSkipped(
							v9.Uid,
							"random growth jump cancellation",
							skipReason
						)
					end
				elseif nextGrowthPulseAt == nil then
					v9.NextGrowthPulseAt = serverTimeNow + random2:NextNumber(27, 65)
				elseif nextGrowthPulseAt <= serverTimeNow then
					v9.NextGrowthPulseAt = serverTimeNow + random2:NextNumber(27, 65)
					local skipReason = PlacedEggGrowthPresentationPolicy.GetSkipReason(v9.Result.Model)

					if skipReason == nil then
						growthAnimation:Play()
					else
						PlacedEggGrowthPresentationPolicy.LogSkipped(v9.Uid, "random growth jump", skipReason)
					end
				end

				continue
			end
		end

		v9.NextGrowthPulseAt = nil
		growthAnimation:Cancel()
	end
end

local function updateGrowth(serverTimeNow: number)
	for _, v9 in pairs(v) do
		if v9.IsHatching or v9.MutationPresenting or v9.Result.Model.Parent == nil then
			continue
		end

		local nightTimeSkipAnimation = v9.NightTimeSkipAnimation
		local v10

		if nightTimeSkipAnimation == nil then
			v10 = false
		else
			v10 = not nightTimeSkipAnimation:IsComplete()
		end

		if v10 then
			continue
		end

		local directGrowthTweenRemainingSeconds = getDirectGrowthTweenRemainingSeconds(v9.Record, serverTimeNow)

		if isLocalOwner(v9.OwnerUserId) and directGrowthTweenRemainingSeconds > 0 then
			if not v9.DirectGrowthTweenActive then
				updatePrompt(v9)
				startDirectGrowthTween(v9, directGrowthTweenRemainingSeconds) -- equivalent call inferred; original call site unknown
			end
		else
			local nextGrowthUpdateAt = v9.NextGrowthUpdateAt

			if not (serverTimeNow < nextGrowthUpdateAt) then
				v9.NextGrowthUpdateAt = nextGrowthUpdateAt + (math.floor((serverTimeNow - nextGrowthUpdateAt) / 5) + 1) * 5
				updatePrompt(v9)
				local visualScale = getVisualScale(v9.Record, v9.StartScale, v9.TargetScale)
				local naturalGrowthSkipReason = PlacedEggGrowthPresentationPolicy.GetNaturalGrowthSkipReason(
					v9.Result.Model,
					visualScale
				)

				if setStateScale(v9, visualScale, nil, naturalGrowthSkipReason == nil) then
					local v11 = assert(naturalGrowthSkipReason, "Skipped natural growth requires a presentation reason")
					PlacedEggGrowthPresentationPolicy.LogSkipped(v9.Uid, "natural growth", v11)
				end
			end
		end
	end
end

local function updateNightTimeSkips()
	for _, v9 in pairs(v) do
		local nightTimeSkipAnimation = v9.NightTimeSkipAnimation

		if nightTimeSkipAnimation == nil then
			continue
		end

		if v9.IsHatching or v9.Result.Model.Parent == nil then
			clearNightTimeSkipAnimation(v9)
		else
			updatePrompt(v9)

			if v9.NightBillboardSuppressed and nightTimeSkipAnimation:IsBillboardFadeFinished() then
				v9.NightBillboardSuppressed = false
				PlacedEggBillboard.SetNightPresentationActive(v9.OwnerUserId, v9.Uid, false)
			end

			if nightTimeSkipAnimation:IsComplete() then
				clearNightTimeSkipAnimation(v9)
				PlacedEggBillboard.SetEntry({
					OwnerUserId = v9.OwnerUserId,
					Uid = v9.Uid,
					Record = v9.Record,
					Model = v9.Result.Model,
					TimeSkipSeconds = nil
				})
			end
		end
	end
end

local function stepPlacedEggs()
	local serverTimeNow = Workspace:GetServerTimeNow()
	updateNightTimeSkips()
	updateGrowthPulses(serverTimeNow)
	updateReadyPulses(serverTimeNow)
	updateGrowth(serverTimeNow)
end

function PlacedEggRenderer.GetRenderFolder()
	return folder
end

function PlacedEggRenderer.Refresh()
	refreshAll()
end

function PlacedEggRenderer.SetPromptsSuppressed(flag2: boolean)
	t.strict(t.boolean)(flag2)
	v3 = flag2
	updateAllPrompts() -- equivalent call inferred; original call site unknown
end

function PlacedEggRenderer.ActivateLocalEgg(p: string)
	t.strict(t.string)(p)
	local v9 = v[`{Players.LocalPlayer.UserId}:{p}`]

	if v9 == nil then
		return false, "Egg is not rendered"
	end

	return activatePrompt(v9)
end

function PlacedEggRenderer.RequestSkipGrowthForLocalEgg(p: string)
	t.strict(t.string)(p)
	local v9 = v[`{Players.LocalPlayer.UserId}:{p}`]

	if v9 == nil then
		return false, "Egg is not rendered"
	end

	if isReady(v9.Record, getNightTimeSkipSeconds(v9)) then
		return false, "Egg is already ready"
	end

	return activatePrompt(v9)
end

function PlacedEggRenderer.AppendRaycastTargets(models, p: number)
	t.strict(t.number)(p)

	for _, v9 in pairs(v) do
		if v9.OwnerUserId == p and v9.Result.Model.Parent ~= nil then
			table.insert(models, v9.Result.Model)
		end
	end
end

function PlacedEggRenderer.DestroyOwner(p: number)
	t.strict(t.number)(p)
	destroyOwnerStates(p)
	PlacedEggBillboard.DestroyOwner(p)
end

function PlacedEggRenderer.SetAllHidden(flag2: boolean)
	t.strict(t.boolean)(flag2)
	local v9 = folder
	local parent

	if not flag2 then
		parent = workspace
	end

	v9.Parent = parent
	PlacedEggRenderer.SetPromptsSuppressed(flag2)
end

local function refreshMutationConsumableEquipped(instance)
	local v9 = false
	local v10 = "Boss"

	for _, tool in instance:GetChildren() do
		if not (tool:IsA("Tool") and tool:GetAttribute("ItemType") == "MutationConsumable") then
			continue
		end

		local mutationId = tool:GetAttribute("MutationId") or "Boss"

		if not (mutationId == "Boss" or mutationId == "Scrambled") then
			continue
		end

		v10 = mutationId
		v9 = true
		break
	end

	if v4 == v9 and v5 == v10 then
		return
	end

	v4 = v9
	v5 = v10
	updateAllPrompts() -- equivalent call inferred; original call site unknown
end

local function bindCharacter(character)
	v7:Clean()
	v7:Connect(character.ChildAdded, function()
		refreshMutationConsumableEquipped(character)
	end)
	v7:Connect(character.ChildRemoved, function()
		refreshMutationConsumableEquipped(character)
	end)
	refreshMutationConsumableEquipped(character)
end

EggState.SnapshotRefreshed:Connect(refreshAll)
EggState.OwnerRefreshed:Connect(onOwnerRefreshed)
EggState.OwnerCleared:Connect(PlacedEggRenderer.DestroyOwner)
EggState.ResetCountdown:Connect(startNightTimeSkip)
PlotState.PlotChanged:Connect(refreshAll)
RunService.Heartbeat:Connect(stepPlacedEggs)
Players.LocalPlayer.CharacterAdded:Connect(bindCharacter)

if Players.LocalPlayer.Character ~= nil then
	bindCharacter(Players.LocalPlayer.Character)
end

ScrambleMutationFlags.SuccessPercent.Changed:Connect(updateAllPrompts)
BossMasteryFlags.MutationConsumableSuccessPercent.Changed:Connect(updateAllPrompts)
task.defer(function()
	refreshAll()
	local serverTimeNow = Workspace:GetServerTimeNow()

	if AreaEggCycle.IsNightPhase(serverTimeNow) then
		startNightTimeSkip({
			DayStartsAt = AreaEggCycle.NextResetTime(serverTimeNow)
		}) -- equivalent call inferred; original call site unknown
	end
end)
return PlacedEggRenderer