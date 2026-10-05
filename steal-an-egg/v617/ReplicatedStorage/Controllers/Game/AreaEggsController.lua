local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local AreaEggNearbyPulse = require(script.AreaEggNearbyPulse)
local AreaEggSlotIdentity = require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity)
local AreaEggs = require(ReplicatedStorage.Shared.Types.AreaEggs)
local EggRenderer = require(ReplicatedStorage.Shared.Eggs.EggRenderer)
local EggState = require(ReplicatedStorage.Client.EggState)
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
local HoverHighlight = require(script.HoverHighlight)
local Log = require(ReplicatedStorage.Packages.Log)
local OnboardingTiming = require(ReplicatedStorage.Shared.Util.OnboardingTiming)
local NestResolver = require(script.NestResolver)
local Player = require(ReplicatedStorage.Shared.Player)
local RareEggHighlight = require(script.RareEggHighlight)
local SafeZoneBarriers = require(ReplicatedStorage.Shared.Util.SafeZoneBarriers)
local SmartProximityPrompt = require(ReplicatedStorage.Client.SmartProximityPrompt)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WorkspaceEggVisibility = require(script.WorkspaceEggVisibility)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local states = AreaEggs.States
local localPlayer = Players.LocalPlayer
local v = Log.new()

local function newRenderQueue(perFrame: number)
	return {
		Jobs = {},
		Order = {},
		PerFrame = perFrame,
		Pumping = false
	}
end

local function discardRender(p, p2: string)
	p.Jobs[p2] = nil
end

local function drainRenderQueue(state)
	while #state.Order > 0 do
		local count = 0

		while count < state.PerFrame do
			local v2 = table.remove(state.Order, 1)

			if v2 == nil then
				break
			end

			local job = state.Jobs[v2]

			if job == nil then
				continue
			end

			state.Jobs[v2] = nil
			count += 1
			local success, result = pcall(job)

			if not success then
				v:AtError():Log((`Area egg render for {v2} failed: {result}`))
			end
		end

		task.wait()
	end

	state.Pumping = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enqueueRender(state, uid: string, fn)
	if state.Jobs[uid] == nil then
		table.insert(state.Order, uid)
	end

	state.Jobs[uid] = fn

	if not state.Pumping then
		state.Pumping = true
		task.defer(drainRenderQueue, state)
	end
end

return {
	Start = function()
		local v2 = AreaEggNearbyPulse.new(localPlayer)
		local v3 = newRenderQueue(1)
		local v4 = newRenderQueue(8)
		local world = Workspace.World
		assert(world:IsA("Folder"), "Workspace.World must be a Folder")
		local areas = world.Areas
		assert(areas:IsA("Folder"), "Workspace.World.Areas must be a Folder")
		local separationLine = areas.SeparationLine
		assert(separationLine:IsA("BasePart"), "Workspace.World.Areas.SeparationLine must be a BasePart")
		local folder = Instance.new("Folder")
		folder.Name = "AreaEggSlotsClient"
		folder.Parent = Workspace
		local v5 = {}
		local v6 = {}
		local carryState = EggState.ReadCarryState()
		local hasFieldSnapshot = EggState.HasFieldSnapshot()
		local v7 = 0

		local function isLocalPlayerInGameplay()
			local rootPart = Player.FindRootPart(localPlayer)
			return rootPart ~= nil and GuardAreaGeometry.IsPastLine(separationLine, rootPart.Position)
		end

		local function isLocalPlayerTrapLocked()
			local character = Player.FindCharacter(localPlayer)
			return character ~= nil and character:GetAttribute("IsTrapped") == true
		end

		local function isEggReachable(p)
			local rootPart = Player.FindRootPart(localPlayer)

			if rootPart == nil then
				return false
			end

			local position = p.Record.BoundsCFrame.Position

			if (position - rootPart.Position).Magnitude > 12 then
				return true
			end

			return not SafeZoneBarriers.Separates(
				rootPart.Position,
				position,
				SafeZoneBarriers.IsFencedUid(p.Record.Uid)
			)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updatePromptEnabled(p)
			local prompt = p.Prompt
			local rootPart = Player.FindRootPart(localPlayer)
			local enabled

			if rootPart == nil then
				enabled = false
			else
				enabled = GuardAreaGeometry.IsPastLine(separationLine, rootPart.Position)
			end

			if enabled then
				local character = Player.FindCharacter(localPlayer)
				enabled = (character == nil or character:GetAttribute("IsTrapped") ~= true) and isEggReachable(p)
			end

			prompt.Enabled = enabled
		end

		local function cleanupRendered(p: string)
			v6[p] = nil
			v3.Jobs[p] = nil
			v4.Jobs[p] = nil
			local v8 = v5[p]

			if v8 == nil then
				return
			end

			v5[p] = nil
			v8.Trove:Destroy()

			if v8.OwnsModel and v8.Model.Parent ~= nil then
				TryCall(v8.Model.Destroy, v8.Model)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function scaleNestForRecord(p)
			local resolved = NestResolver.Resolve(p)
			resolved:ScaleTo(p.NestScale)
			return resolved
		end

		local function renderClientEgg(data)
			local model = EggRenderer.RenderVisual({
				OwnerUserId = 0,
				UID = data.Uid,
				ModelName = data.Uid,
				Record = {
					AssetCategory = data.AssetCategory,
					AssetScale = data.AssetScale,
					AssetEyeColor = data.AssetEyeColor,
					AssetColorSeed = data.AssetColorSeed,
					AssetColorIndex = data.AssetColorIndex,
					Mutations = table.clone(data.Mutations),
					BaseMutation = data.BaseMutation,
					HasParasite = data.HasParasite
				},
				ScaleAlpha = 1
			}, folder, false).Model
			model:PivotTo(data.BottomCFrame)
			return model
		end

		local function bindPrompt(record, model, ownsModel: boolean)
			RareEggHighlight.BindRenderedModel(record, model)
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.Name = "CarryAreaEgg"
			proximityPrompt.ActionText = "Steal"
			proximityPrompt.ObjectText = "Egg"
			proximityPrompt.MaxActivationDistance = 8
			proximityPrompt.HoldDuration = Workspace:GetAttribute("FastEggPickupTime") and 0.25 or 1.2
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
			local v8 = SmartProximityPrompt.AttachToModel(proximityPrompt, model, {
				MaxActivationDistance = 8,
				TrackDistance = 8,
				SurfaceOffset = 0.75
			})
			local maid = Trove.new()
			maid:Add(v8)
			local v9 = {
				Record = record,
				Model = model,
				OwnsModel = ownsModel,
				Prompt = proximityPrompt,
				Trove = maid
			}
			v5[record.Uid] = v9

			if record.State == states.Slot then
				maid:Add(v2:Bind(record.Uid, model, Workspace:GetServerTimeNow()))
			end

			HoverHighlight.Bind(model, proximityPrompt, maid)
			maid:Connect(proximityPrompt.Triggered, function(p2)
				if p2 ~= localPlayer then
					return
				end

				local character = localPlayer.Character

				if character then
					for _, tool in character:GetChildren() do
						if not (tool:IsA("Tool") and tool:GetAttribute("ItemType") == "MutationConsumable") then
							continue
						end

						local now = os.clock()

						if v7 <= now then
							v7 = now + 2.5
							local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
							Toast.Show({
								Text = "can only be used on your own eggs",
								Seconds = 2.5,
								Color = Color3.fromRGB(255, 100, 100),
								SingleLine = true
							})
						end

						return
					end
				end

				local v10

				if AreaEggSlotIdentity.LooksLikeFirstAreaUid(record.Uid) then
					v10 = AreaEggSlotIdentity.SlotKey(record.AreaId, record.NestId)
				end

				local carryFieldEgg, v11 = EggState.CarryFieldEgg(record.Uid, v10)

				if carryFieldEgg and v10 ~= nil then
					cleanupRendered(record.Uid)
					WorkspaceEggVisibility.SetHidden(record.Uid, false)
				end

				if not carryFieldEgg and v11 ~= nil then
					v:AtDebug():Log((`Area egg carry denied for {record.Uid}: {v11}`))
				end
			end)
			updatePromptEnabled(v9) -- equivalent call inferred; original call site unknown
		end

		local function renderSlot(record)
			cleanupRendered(record.Uid)
			local resolved = scaleNestForRecord(record) -- equivalent call inferred; original call site unknown
			resolved:PivotTo(resolved:GetPivot())

			if AreaEggSlotIdentity.LooksLikeFirstAreaUid(record.Uid) then
				WorkspaceEggVisibility.SetHidden(record.Uid, true)
			else
				local model = WorkspaceEggVisibility.ResolveModel(record.Uid)

				if model ~= nil then
					WorkspaceEggVisibility.SetHidden(record.Uid, false)
					bindPrompt(record, model, false)
					return
				end
			end

			bindPrompt(record, renderClientEgg(record), true)

			if AreaEggSlotIdentity.LooksLikeFirstAreaUid(record.Uid) then
				OnboardingTiming.Mark("FirstForestEggRendered")
			end
		end

		local function renderDropped(record)
			cleanupRendered(record.Uid)

			if AreaEggSlotIdentity.LooksLikeFirstAreaUid(record.Uid) then
				WorkspaceEggVisibility.SetHidden(record.Uid, true)
				bindPrompt(record, renderClientEgg(record), true)
			else
				WorkspaceEggVisibility.SetHidden(record.Uid, false)
				local model = WorkspaceEggVisibility.ResolveModel(record.Uid)

				if model == nil then
					v:AtDebug():Log((`Dropped area egg {record.Uid} skipped because its Workspace model is not parented`))
				else
					bindPrompt(record, model, false)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyRecordNow(fieldEgg)
			WorkspaceEggVisibility.SetHidden(fieldEgg.Uid, false)

			if fieldEgg.State == states.Dropped then
				renderDropped(fieldEgg)
			elseif fieldEgg.State == states.Slot then
				renderSlot(fieldEgg)
			else
				cleanupRendered(fieldEgg.Uid)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function shouldQueueRender(data)
			if v6[data.Uid] == data.Version then
				return false
			end

			local v8 = v5[data.Uid]
			return v8 == nil or v8.Record.Version ~= data.Version or v8.Record.State ~= data.State
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function queueApplyRecord(data, state)
			-- equivalent call inferred; original call site unknown
			if not shouldQueueRender(data) then
				return
			end

			v6[data.Uid] = data.Version

			local function fn()
				local fieldEgg = EggState.ReadFieldEgg(data.Uid)

				if fieldEgg == nil or fieldEgg.Version ~= data.Version then
					return
				end

				v6[data.Uid] = nil
				applyRecordNow(fieldEgg) -- equivalent call inferred; original call site unknown
			end

			enqueueRender(state, data.Uid, fn) -- equivalent call inferred; original call site unknown
		end

		local function applySnapshot(p, p2)
			local v8 = {}
			local records = {}

			for _, record in ipairs(p.Records) do
				v8[record.Uid] = true
				WorkspaceEggVisibility.SetHidden(record.Uid, false)

				if record.State == states.Slot or record.State == states.Dropped then
					table.insert(records, record)
				end
			end

			for k in pairs(v5) do
				if not v8[k] then
					cleanupRendered(k)
				end
			end

			for _, v9 in ipairs(records) do
				queueApplyRecord(v9, p2) -- equivalent call inferred; original call site unknown
			end
		end

		local function applyInitialSnapshot(p)
			local v8 = {}
			local records = {}
			local records2 = {}

			for _, record in ipairs(p.Records) do
				v8[record.Uid] = true
				WorkspaceEggVisibility.SetHidden(record.Uid, false)

				if not (record.State == states.Slot or record.State == states.Dropped) then
					continue
				end

				if AreaEggSlotIdentity.LooksLikeFirstAreaUid(record.Uid) then
					table.insert(records, record)
				else
					table.insert(records2, record)
				end
			end

			for k in pairs(v5) do
				if not v8[k] then
					cleanupRendered(k)
				end
			end

			for _, v9 in ipairs(records) do
				v6[v9.Uid] = nil
				WorkspaceEggVisibility.SetHidden(v9.Uid, false)

				if v9.State == states.Dropped then
					renderDropped(v9)
				elseif v9.State == states.Slot then
					renderSlot(v9)
				else
					cleanupRendered(v9.Uid)
				end
			end

			for _, v9 in ipairs(records2) do
				queueApplyRecord(v9, v4) -- equivalent call inferred; original call site unknown
			end
		end

		EggState.FieldClaimed:Connect(function(p)
			local RewardScreenTransition = require(ReplicatedStorage.Client.UI.VFX.RewardScreenTransition)
			RewardScreenTransition()
			local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
			Toast.Show({
				Text = `You stole an <font color="#{p.Color:ToHex()}">EGG</font>!`,
				Color = Color3.new(1, 1, 1),
				Seconds = 2.5
			})
		end)
		EggState.FieldRefreshed:Connect(function(p)
			if hasFieldSnapshot then
				applySnapshot(p, v3)
				return
			end

			hasFieldSnapshot = true
			applyInitialSnapshot(p)
		end)
		EggState.FieldShifted:Connect(function(p)
			WorkspaceEggVisibility.SetHidden(p.Uid, false)

			if p.State ~= states.Slot and p.State ~= states.Dropped then
				cleanupRendered(p.Uid)
				return
			end

			local v8 = v3
			local uid = p.Uid
			v8.Jobs[uid] = nil
			local v9 = v4
			local uid2 = p.Uid
			v9.Jobs[uid2] = nil
			v6[p.Uid] = nil
			queueApplyRecord(p, v3) -- equivalent call inferred; original call site unknown
		end)
		EggState.CarryChanged:Connect(function(p)
			carryState = p

			if p.IsCarrying and p.Uid ~= nil then
				if AreaEggSlotIdentity.LooksLikeFirstAreaUid(p.Uid) then
					cleanupRendered(p.Uid)
					WorkspaceEggVisibility.SetHidden(p.Uid, false)
				else
					WorkspaceEggVisibility.SetHidden(p.Uid, false)
				end
			end
		end)
		EggState.FieldGone:Connect(function(p: string)
			cleanupRendered(p)
			local v8 = carryState
			WorkspaceEggVisibility.SetHidden(p, v8 == nil or not v8.IsCarrying or v8.Uid ~= p)
		end)
		WorkspaceEggVisibility.ModelAdded:Connect(function(p)
			local fieldEgg = EggState.ReadFieldEgg(p.Name)

			if fieldEgg ~= nil and fieldEgg.State == states.Dropped and not AreaEggSlotIdentity.LooksLikeFirstAreaUid(fieldEgg.Uid) then
				queueApplyRecord(fieldEgg, v3) -- equivalent call inferred; original call site unknown
			end
		end)
		task.spawn(function()
			local CarryRunBackEffects = require(script.CarryRunBackEffects)
			CarryRunBackEffects.Start()
		end)
		WorkspaceEggVisibility.Start()
		RareEggHighlight.Start()
		RunService.Heartbeat:Connect(function()
			v2:Step(Workspace:GetServerTimeNow())

			for _, v8 in pairs(v5) do
				updatePromptEnabled(v8) -- equivalent call inferred; original call site unknown
			end
		end)
		applyInitialSnapshot(EggState.ReadFieldEggs())
	end
}