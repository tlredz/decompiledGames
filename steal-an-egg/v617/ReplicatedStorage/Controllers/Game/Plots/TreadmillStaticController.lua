local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.array(t.integer), function(list)
	local v = {}

	for _, v2 in ipairs(list) do
		if v[v2] then
			return false
		else
			v[v2] = true
		end
	end

	return true
end)
local BaseUpgrade = require(ReplicatedStorage.Client.BaseUpgrade)
local transition = BaseUpgrade.Transition
require(ReplicatedStorage.Shared.Globals.Constants)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local emitAt = VFX.EmitAt
local TryLock = require(ReplicatedStorage.Shared.Utils.TryLock)
local Log = require(ReplicatedStorage.Packages.Log)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local PlotUpgradeVisibility = require(ReplicatedStorage.Client.PlotUpgradeVisibility)
local Preload = require(ReplicatedStorage.Shared.Utils.Preload)
local warmAssets = Preload.WarmAssets
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local TreadmillStaticCover = require(ReplicatedStorage.Client.UI.TreadmillStaticCover)
local TreadmillVideoGate = require(ReplicatedStorage.Client.TreadmillVideoGate)
local Render = require(script.Render)
require(script.Types.Interface)
local TreadmillVideoController = require(ReplicatedStorage.Shared.TreadmillVideoController)
local localPlayer = Players.LocalPlayer
local v = Log.new()

local function releaseActiveTreadmill(p: string?)
	for _, v2 in CollectionService:GetTagged("ActiveTreadmill") do
		if not (p == nil or v2:GetAttribute("ActiveTreadmillId") == p) then
			continue
		end

		CollectionService:RemoveTag(v2, "ActiveTreadmill")
		v2:SetAttribute("ActiveTreadmillId", nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindActiveTreadmill(activeTreadmillId: string, instance)
	releaseActiveTreadmill(activeTreadmillId)
	CollectionService:RemoveTag(instance, "ActiveTreadmill")
	instance:SetAttribute("ActiveTreadmillId", activeTreadmillId)
	CollectionService:AddTag(instance, "ActiveTreadmill")
end

return {
	Start = function()
		local treadmillUpgrade = ReplicatedStorage.Assets.Particles.TreadmillUpgrade
		local folder = Instance.new("Folder")
		folder.Name = "__ClientTreadmillRenders"
		folder.Parent = Workspace
		task.spawn(warmAssets, treadmillUpgrade)
		local v2 = nil
		local v3 = false
		local v4 = {}
		local v5 = false
		local tryLock = TryLock()
		local v7 = false
		local baseUpgradeLevel = 0
		local flag = true
		local v8 = 0
		local v9 = 0
		local v10 = false
		local v11 = false
		local flag2 = false
		local v12 = {}
		local v13 = {}
		local v14 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyRender(p: number)
			local v15 = v13[p]

			if v15 == nil then
				return
			end

			v13[p] = nil

			if v15.OwnerUserId == localPlayer.UserId then
				CollectionService:RemoveTag(v15.Model, "ActiveTreadmill")
			end

			if v15.Cover ~= nil then
				v15.Cover:Destroy()
			end

			v15.Model:Destroy()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveLocalRender()
			local localSlot = PlotState.ResolveLocalSlot()

			if localSlot == nil then
				return nil
			end

			return v13[localSlot]
		end

		local function animateScale(p, p2: number, p3: number, p4: number, p5)
			local v15 = 0

			while v15 < p4 do
				local v16 = RunService.PreRender:Wait()

				if p.Model.Parent == nil then
					break
				end

				v15 = math.min(v15 + v16, p4)
				local value = TweenService:GetValue(v15 / p4, p5, Enum.EasingDirection.Out)
				Render.SetGroundedScale(p, p2 + (p3 - p2) * value)
			end

			if p.Model.Parent ~= nil then
				Render.SetGroundedScale(p, p3)
			end
		end

		local function runLocalUpgradeAnimation(p, p2: number)
			local root = p.Model.Root
			assert(root:IsA("BasePart"), (`Treadmill "{p.TreadmillId}" Root must be a BasePart`))
			local highlight = Instance.new("Highlight")
			highlight.Adornee = p.Model
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = Color3.new(1, 1, 1)
			highlight.FillTransparency = 1
			highlight.OutlineColor = Color3.new(1, 1, 1)
			highlight.OutlineTransparency = 1
			highlight.Parent = p.Model
			local tween = TweenService:Create(
				highlight,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					FillTransparency = 0.15,
					OutlineTransparency = 0
				}
			)
			local tween2 = TweenService:Create(
				highlight,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					FillTransparency = 1,
					OutlineTransparency = 1
				}
			)
			tween.Completed:Once(function()
				tween2:Play()
			end)
			tween2.Completed:Once(function()
				highlight:Destroy()
			end)
			tween:Play()
			emitAt(root, treadmillUpgrade:Clone():GetChildren())
			Audio.Play(130233661094961, script, {
				PlaybackSpeed = { 0.9, 1.1 },
				Volume = 1.5
			})
			Toast.Show({
				Text = "Successfully upgraded your treadmill!",
				Color = Color3.fromRGB(0, 255, 47),
				Seconds = 0.7
			})
			animateScale(p, p2 * 0.8, p2, 0.55, Enum.EasingStyle.Elastic)
		end

		local function replaceRender(p: number, p2: number, p3, flag3: boolean)
			local v15 = (v14[p] or 0) + 1
			v14[p] = v15
			local v16 = v13[p]

			if flag3 and v16 ~= nil then
				local scale = v16.Model:GetScale()
				animateScale(v16, scale, scale * 0.8, 0.22, Enum.EasingStyle.Quad)

				if v14[p] ~= v15 then
					return
				end
			end

			destroyRender(p) -- equivalent call inferred; original call site unknown
			local v17 = Render.Build(p, p2, p3, flag3 and 0.8 or 1, p2 == localPlayer.UserId, folder)
			v13[p] = v17

			if p2 == localPlayer.UserId then
				v17.RateSign.Enabled = v2 == nil
				local cover = v17.Cover

				if cover ~= nil then
					TreadmillStaticCover.SetEnabled(cover, v2 == nil)
				end

				if v2 ~= nil and not v3 then
					bindActiveTreadmill(v17.TreadmillId, v17.Model) -- equivalent call inferred; original call site unknown
				end
			end

			if flag3 then
				runLocalUpgradeAnimation(v17, v17.Model:GetScale() / 0.8)
			end
		end

		local function refreshSlot(k: number, p: number?, flag3: boolean)
			if p == nil then
				v14[k] = (v14[k] or 0) + 1
				destroyRender(k) -- equivalent call inferred; original call site unknown
			elseif p == localPlayer.UserId or v4[p] == true then
				local playerByUserId = Players:GetPlayerByUserId(p)

				if playerByUserId == nil then
					return
				end

				local v15 = Save.Await(playerByUserId)

				if v15 == nil or PlotState.LookupOwner(k) ~= p then
					return
				end

				if v15.BaseUpgradeLevel ~= 0 then
					if p ~= localPlayer.UserId or not flag2 and (baseUpgradeLevel ~= 0 or not transition.IsPlaying()) then
						replaceRender(k, p, v15, flag3)
						return
					end

					flag2 = true
				end

				destroyRender(k) -- equivalent call inferred; original call site unknown
			else
				v14[k] = (v14[k] or 0) + 1
				destroyRender(k) -- equivalent call inferred; original call site unknown
			end
		end

		local function refreshPlayerRender(p, flag3: boolean)
			for k, v15 in pairs(PlotState.ReadOwners()) do
				if v15 ~= p.UserId then
					continue
				end

				refreshSlot(k, v15, flag3)
				break
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyRemoteSessionTransition(p, flag3: boolean, p2: number)
			if p2 <= v8 then
				return
			end

			v8 = p2

			if p == localPlayer then
				return
			end

			if flag3 then
				v4[p.UserId] = true
			else
				v4[p.UserId] = nil
			end

			refreshPlayerRender(p, false)
		end

		local function synchronizeRemoteSessionSnapshot()
			local v15, v16 = Remotes.Treadmill.AskRenderSnapshot:InvokeServer()
			t.strict(intersection)(v15)
			t.strict(t.number)(v16)
			table.clear(v4)

			for _, v17 in ipairs(v15) do
				if v17 ~= localPlayer.UserId then
					v4[v17] = true
				end
			end

			v8 = v16
			table.sort(v12, function(a, b)
				return a.Revision < b.Revision
			end)
			flag = false

			for _, v17 in ipairs(v12) do
				applyRemoteSessionTransition(v17.Player, v17.Active, v17.Revision) -- equivalent call inferred; original call site unknown
			end

			table.clear(v12)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshLocalRender(flag3: boolean)
			v7 = true
			refreshPlayerRender(localPlayer, flag3)
			v7 = false
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function consumePendingUpgradeRefresh()
			if not v5 or not v10 or v2 ~= nil then
				return
			end

			local v15 = v11
			v5 = false
			v10 = false
			v11 = false
			refreshLocalRender(v15) -- equivalent call inferred; original call site unknown
			v9 = Workspace:GetServerTimeNow() + 1.25
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshPlotUpgradeVisibility()
			PlotUpgradeVisibility.Apply("TreadmillUpgrade", baseUpgradeLevel > 0)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function revealFirstExpansionTreadmill()
			local v15 = Save.Await()
			assert(v15 ~= nil, "First expansion treadmill reveal requires local save data")

			if v15.BaseUpgradeLevel == 0 then
				return
			end

			baseUpgradeLevel = v15.BaseUpgradeLevel
			flag2 = false
			refreshPlotUpgradeVisibility() -- equivalent call inferred; original call site unknown
			refreshLocalRender(true) -- equivalent call inferred; original call site unknown
			v9 = Workspace:GetServerTimeNow() + 1.25
		end

		local function tryEnterStaticTreadmill()
			local localRender = resolveLocalRender() -- equivalent call inferred; original call site unknown

			if v2 ~= nil or v5 or v7 or localRender == nil then
				return
			end

			local serverTimeNow = Workspace:GetServerTimeNow()

			if serverTimeNow < v9 then
				return
			end

			local character = localPlayer.Character
			local humanoidRootPart

			if character ~= nil then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
				return
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { localRender.Bottom }

			if Workspace:Raycast(humanoidRootPart.Position, createVector(0, -8, 0), raycastParams) == nil then
				return
			end

			v9 = serverTimeNow + 1.25
			tryLock(function()
				bindActiveTreadmill(localRender.TreadmillId, localRender.Model) -- equivalent call inferred; original call site unknown
				local v15, v16 = Remotes.Treadmill.AskWearStill:InvokeServer()

				if v15 ~= true then
					releaseActiveTreadmill(localRender.TreadmillId)
					v:AtWarning():Log((`Static treadmill entry rejected: {v16}`))
				end
			end)
		end

		Save.Await()
		local v15 = Save.Await()
		assert(v15 ~= nil, "Static treadmill controller requires local save data")
		local treadmillUpgradeLevel = v15.TreadmillUpgradeLevel
		baseUpgradeLevel = v15.BaseUpgradeLevel
		Remotes.Treadmill.RenderStateShifted.OnClientEvent:Connect(function(player, flag3: boolean, revision: number)
			t.strict(t.instanceIsA("Player"))(player)
			t.strict(t.boolean)(flag3)
			t.strict(t.number)(revision)

			if flag then
				table.insert(v12, {
					Active = flag3,
					Player = player,
					Revision = revision
				})
				return
			end

			applyRemoteSessionTransition(player, flag3, revision) -- equivalent call inferred; original call site unknown
		end)
		synchronizeRemoteSessionSnapshot()

		for k, v16 in pairs(PlotState.ReadOwners()) do
			task.spawn(refreshSlot, k, v16, false)
		end

		refreshPlotUpgradeVisibility() -- equivalent call inferred; original call site unknown
		PlotState.PlotChanged:Connect(function(p: number, p2: number?)
			refreshPlotUpgradeVisibility() -- equivalent call inferred; original call site unknown
			task.spawn(refreshSlot, p, p2, false)
		end)
		TreadmillVideoGate.Changed:Connect(function()
			for k, v16 in pairs(PlotState.ReadOwners()) do
				if v16 ~= localPlayer.UserId or v2 == nil then
					task.spawn(refreshSlot, k, v16, false)
				end
			end
		end)
		PlotState.FolderChanged:Connect(function()
			refreshPlotUpgradeVisibility() -- equivalent call inferred; original call site unknown

			for k, v16 in pairs(PlotState.ReadOwners()) do
				task.spawn(refreshSlot, k, v16, false)
			end
		end)
		Players.PlayerAdded:Connect(function(player)
			task.spawn(refreshPlayerRender, player, false)
		end)
		Players.PlayerRemoving:Connect(function(player)
			v4[player.UserId] = nil

			for k, v16 in pairs(v13) do
				if not (v16 and v16.OwnerUserId == player.UserId) then
					continue
				end

				v14[k] = (v14[k] or 0) + 1
				destroyRender(k) -- equivalent call inferred; original call site unknown
			end
		end)
		Save.PeerLoaded:Connect(function(p)
			refreshPlayerRender(p, false)
		end)
		Save.PeerChanged:Connect(function(p, p2: string)
			if p2 == "TreadmillUpgradeLevel" then
				refreshPlayerRender(p, false)
			elseif p2 == "TreadmillMediaFeedState" then
				local v16 = Save.Peek(p)

				if v16 ~= nil then
					for _, v17 in pairs(v13) do
						if v17 and v17.OwnerUserId == p.UserId and v17.Cover ~= nil then
							TreadmillStaticCover.ApplyFeed(v17.Cover, v16.TreadmillMediaFeedState)
						end
					end
				end
			end
		end)
		Remotes.Treadmill.ViewStateShifted.OnClientEvent:Connect(function(p, p2: string)
			t.strict(t.instanceIsA("Player"))(p)
			t.strict(t.string)(p2)

			if p == localPlayer then
				return
			end

			local mediaEntry = TreadmillVideoController.GetMediaEntryByKey(p2)

			if mediaEntry == nil then
				return
			end

			for _, v16 in pairs(v13) do
				if v16 and v16.OwnerUserId == p.UserId and v16.Cover ~= nil then
					TreadmillStaticCover.ApplyMedia(v16.Cover, mediaEntry)
				end
			end
		end)
		Save.Watch("TreadmillUpgradeLevel"):Connect(function()
			local v16 = Save.Await()
			assert(v16 ~= nil, "Local treadmill upgrade requires save data")
			local treadmillUpgradeLevel2 = v16.TreadmillUpgradeLevel
			local v17 = treadmillUpgradeLevel < treadmillUpgradeLevel2
			treadmillUpgradeLevel = v16.TreadmillUpgradeLevel
			refreshPlotUpgradeVisibility() -- equivalent call inferred; original call site unknown

			if v2 == nil and not v5 then
				refreshLocalRender(v17) -- equivalent call inferred; original call site unknown
			else
				v10 = true
				v11 = v11 or v17

				if v5 and v10 then
					if v2 ~= nil then
						return
					end

					local v18 = v11
					v5 = false
					v10 = false
					v11 = false
					refreshLocalRender(v18) -- equivalent call inferred; original call site unknown
					v9 = Workspace:GetServerTimeNow() + 1.25
				end
			end
		end)
		Save.Watch("BaseUpgradeLevel"):Connect(function()
			local v16 = Save.Await()
			assert(v16 ~= nil, "Local base upgrade requires save data")
			local v17

			if baseUpgradeLevel == 0 then
				v17 = v16.BaseUpgradeLevel > 0
			else
				v17 = false
			end

			baseUpgradeLevel = v16.BaseUpgradeLevel

			if not v17 then
				refreshPlotUpgradeVisibility() -- equivalent call inferred; original call site unknown
			elseif transition.IsPlaying() then
				baseUpgradeLevel = 0
				flag2 = true
				refreshPlotUpgradeVisibility() -- equivalent call inferred; original call site unknown
			else
				revealFirstExpansionTreadmill() -- equivalent call inferred; original call site unknown
			end
		end)
		transition.Completed:Connect(function()
			if flag2 then
				revealFirstExpansionTreadmill() -- equivalent call inferred; original call site unknown
			end
		end)
		Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(activeTreadmillId: string?, _: number?, _: number?, _, flag3: boolean?, flag4: boolean?)
			v2 = activeTreadmillId
			v3 = activeTreadmillId ~= nil and flag4 == true

			if activeTreadmillId == nil or flag4 ~= true then
				if activeTreadmillId == nil then
					releaseActiveTreadmill()
					v9 = Workspace:GetServerTimeNow() + 1.25

					if flag3 == true then
						v5 = true
						consumePendingUpgradeRefresh() -- equivalent call inferred; original call site unknown
					end
				else
					local localRender = resolveLocalRender() -- equivalent call inferred; original call site unknown
					local v17

					if localRender == nil then
						v17 = false
					else
						v17 = localRender.TreadmillId == activeTreadmillId
					end

					assert(v17, (`Missing active treadmill render "{activeTreadmillId}"`))
					bindActiveTreadmill(activeTreadmillId, localRender.Model) -- equivalent call inferred; original call site unknown
				end
			else
				local adminTreadmill = Workspace:WaitForChild("AdminTreadmill", 5)
				local v17

				if adminTreadmill == nil then
					v17 = false
				else
					v17 = adminTreadmill:IsA("Tool")
				end

				assert(v17, "Workspace.AdminTreadmill must be a Tool")
				bindActiveTreadmill(activeTreadmillId, adminTreadmill) -- equivalent call inferred; original call site unknown
			end

			local localRender = resolveLocalRender() -- equivalent call inferred; original call site unknown

			if localRender ~= nil then
				local enabled = activeTreadmillId == nil or flag4 == true
				localRender.RateSign.Enabled = enabled
				local cover = localRender.Cover

				if cover ~= nil then
					TreadmillStaticCover.SetEnabled(cover, enabled)
				end
			end
		end)
		TreadmillVideoController.MediaChanged:Connect(function(p)
			local localRender = resolveLocalRender() -- equivalent call inferred; original call site unknown

			if localRender ~= nil then
				local cover = localRender.Cover

				if cover ~= nil then
					TreadmillStaticCover.ApplyMedia(cover, p)
				end
			end
		end)
		RunService.Heartbeat:Connect(tryEnterStaticTreadmill)
	end
}