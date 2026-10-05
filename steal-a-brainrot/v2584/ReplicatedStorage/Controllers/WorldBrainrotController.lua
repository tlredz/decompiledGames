local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
require(ReplicatedStorage.Packages.Gradients)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Net = require(ReplicatedStorage.Packages.Net)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local AnimalOverheadController = require(ReplicatedStorage.Controllers.AnimalOverheadController)
local Animals = require(ReplicatedStorage.Shared.Animals)
local EggScale = require(ReplicatedStorage.Shared.EggScale)
require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
require(ReplicatedStorage.Datas.Mutations)
require(ReplicatedStorage.Datas.Traits)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local remoteEvent = Net:RemoteEvent("WorldBrainrotService/Grab")
local remoteEvent2 = Net:RemoteEvent("WorldBrainrotService/Drop")
local localPlayer = Players.LocalPlayer
local v2 = {}
local drop = localPlayer.PlayerGui:WaitForChild("ToolsFrames").Drop

local function getDropButtonVisibility()
	for _, v3 in v2 do
		if not v3.params.ShowDropButton then
			continue
		end

		local v4 = v3.replicator:TryIndex({ "brainrots" })

		if not v4 then
			continue
		end

		for _, v5 in v4 do
			if v5.grabbed == localPlayer.UserId then
				return v3.params.PoolId
			end
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateDropButtonVisibility()
	drop.Visible = getDropButtonVisibility()
end

return table.freeze({
	Start = function(_)
		localPlayer:GetAttributeChangedSignal("Stealing"):Connect(updateDropButtonVisibility)
		drop.Activate.Activated:Connect(function()
			local dropButtonVisibility = getDropButtonVisibility()

			if dropButtonVisibility then
				remoteEvent2:FireServer(dropButtonVisibility)
			end
		end)
	end,
	RenderPool = function(_, params)
		local maid = Trove.new()
		local replicator = ReplicatorClient.get(params.ReplicatorId)
		local renderedBrainrots = params.RenderedBrainrots or {}
		local showTimer = params.ShowTimer

		if showTimer == nil then
			local v4 = replicator:TryIndex({ "config" })

			if v4 then
				showTimer = v4.showTimer
			end
		end

		local grabHoldDuration = params.GrabHoldDuration or 2
		local grabMaxDistance = params.GrabMaxDistance or 10

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyBrainrot(k: string)
			local renderedBrainrot = renderedBrainrots[k]

			if renderedBrainrot then
				renderedBrainrot.trove:Destroy()
				renderedBrainrots[k] = nil
			end
		end

		local function renderBrainrot(k: string)
			if renderedBrainrots[k] then
				return
			end

			local path = replicator:Path({ "brainrots", k })
			local maid2 = Trove.new()
			local maid3 = maid2:Extend()
			renderedBrainrots[k] = {
				trove = maid2,
				model = nil,
				prompt = nil
			}
			local v4 = nil

			local function updateBrainrotModel()
				maid3:Destroy()
				local v5 = {}
				v4 = v5
				local v6 = replicator:TryIndex(path())

				if not v6 then
					return
				end

				local animatedModel = Animals:GetAnimatedModel(v6.brainrot, "Idle")

				if v4 == v5 and renderedBrainrots[k] then
					if not animatedModel then
						warn((`Brainrot model not found: {v6.brainrot}`))
						return
					end

					maid3:Add(animatedModel)
					renderedBrainrots[k].model = animatedModel
					maid3:Add(function()
						if renderedBrainrots[k] then
							renderedBrainrots[k].model = nil
							renderedBrainrots[k].prompt = nil
						end
					end)
					assert(animatedModel.PrimaryPart, (`{v6.brainrot} has no PrimaryPart`))
					local animal = Animals2[v6.brainrot]

					local function updateCFrame()
						if v6.grabbed and not params.KeepWhenGrabbed then
							animatedModel:PivotTo(CFrame.new(10000, 10000, 10000))
						else
							animatedModel:PivotTo(v6.cframe)
						end
					end

					maid3:Add(replicator:Listen(path("cframe"), updateCFrame))
					maid3:Add(replicator:Listen(path("grabbed"), updateCFrame))
					maid3:Add(task.defer(updateCFrame))
					animatedModel.PrimaryPart.Anchored = true
					local v7 = animatedModel:FindFirstChild("OVERHEAD_ATTACHMENT", true)

					if not v7 then
						v7 = Instance.new("Attachment")
						local extentsSize = animatedModel:GetExtentsSize()
						v7.CFrame = CFrame.new(0, extentsSize.Y * 0.5, 0)
						v7.Parent = animatedModel.PrimaryPart
					end

					local fastOverhead, v8 = FastOverheadController.createFastOverhead({
						adornee = v7,
						guiTemplate = FastOverheadController.GuiTemplates.AnimalOverhead
					})
					maid3:Add(v8)
					local generation = fastOverhead.Generation
					local stolen = fastOverhead.Stolen

					if showTimer and v6.brainrot ~= "Gold Egg" then
						stolen.Visible = true
						stolen.LayoutOrder = -1
						stolen.Size = UDim2.fromScale(1, 0.25)
					else
						stolen.Visible = false
					end

					local luckyBlock = animal.LuckyBlock or animal.Egg
					local timer = v6.timer or luckyBlock and luckyBlock.Timer

					local function updateOverhead()
						if timer == nil then
							generation.Text = `${NumberUtils:ToString(Animals:GetGeneration(v6.brainrot, v6.mutation, v6.traits, nil))}/s`
						else
							local v9 = Animals:IsLuckyBlockTimerDisabled(v6.brainrot) and 0 or timer
							generation.Text = v9 <= 0 and "READY!" or TimeUtils:E(v9)
						end

						if showTimer then
							stolen.Text = `{v6.despawnTimer}s`
						end
					end

					local hideRarity = v6.brainrot == "Gold Egg"
					AnimalOverheadController:Populate({
						Overhead = fastOverhead,
						Index = v6.brainrot,
						Traits = v6.traits,
						Mutation = v6.mutation,
						Trove = maid3,
						HidePrice = hideRarity or animal.Egg ~= nil,
						HideRarity = hideRarity
					})
					local visible = not hideRarity

					if visible then
						visible = params.HideHatchTimer ~= true or timer == nil
					end

					generation.Visible = visible
					task.spawn(updateOverhead)
					maid3:Add(Timer.Simple(1, updateOverhead))
					maid3:Add(replicator:Listen(path("despawnTimer"), updateOverhead))
					fastOverhead.Parent = v7
					local prompt = maid3:Add(Instance.new("ProximityPrompt"))
					prompt.ActionText = v6.brainrot == "Gold Egg" and "Collect" or "Grab"
					prompt.ObjectText = v6.brainrot
					prompt.HoldDuration = grabHoldDuration
					prompt.RequiresLineOfSight = v6.requiresLineOfSight == true
					prompt.MaxActivationDistance = grabMaxDistance
					prompt.Parent = animatedModel.PrimaryPart
					renderedBrainrots[k].prompt = prompt

					if params.OnRendered then
						params.OnRendered(k)
					end

					maid3:Add(prompt.Triggered:Connect(function(player)
						if not player.Character then
							return
						end

						remoteEvent:FireServer(params.PoolId, k)
					end))

					if params.KeepWhenGrabbed then
						local visibilityByLabel = {}

						for _, label in fastOverhead:GetChildren() do
							if label:IsA("TextLabel") and label.Name ~= "Stolen" then
								visibilityByLabel[label] = label.Visible
							end
						end

						local function updateGrabbedVisuals()
							local visible2 = v6.grabbed ~= nil

							for _, part in animatedModel:GetDescendants() do
								if not part:IsA("BasePart") then
									continue
								end

								local defaultTransparency = part:GetAttribute("DefaultTransparency")

								if defaultTransparency == nil then
									defaultTransparency = part.Transparency
									part:SetAttribute("DefaultTransparency", defaultTransparency)
								end

								if visible2 and part.Transparency < 1 then
									part.Transparency = 0.5
								else
									part.Transparency = defaultTransparency
								end
							end

							for _, label in fastOverhead:GetChildren() do
								if not label:IsA("TextLabel") then
									continue
								end

								if label.Name == "Stolen" then
									label.Text = "STOLEN"
									label.Visible = visible2
								elseif visible2 then
									label.Visible = false
								else
									label.Visible = visibilityByLabel[label] ~= false
								end
							end

							prompt.Enabled = not visible2
						end

						maid3:Add(replicator:Listen(path("grabbed"), updateGrabbedVisuals))
						maid3:Add(task.defer(updateGrabbedVisuals))
					end

					if v6.mutation then
						local success, result = pcall(function()
							Animals:ApplyMutation(animatedModel, v6.brainrot, v6.mutation)
						end)

						if not success then
							warn((`WorldBrainrotController: ApplyMutation failed for {v6.brainrot}: {result}`))
						end
					end

					if v6.traits then
						local success, result = pcall(function()
							Animals:ApplyTraits(animatedModel, v6.brainrot, v6.traits)
						end)

						if not success then
							warn((`WorldBrainrotController: ApplyTraits failed for {v6.brainrot}: {result}`))
						end
					end

					if v4 ~= v5 or not renderedBrainrots[k] then
						return
					end

					local scale = v6.scale or EggScale.GetEggScale(v6.brainrot)

					if scale ~= 1 then
						animatedModel:ScaleTo(animatedModel:GetScale() * scale)
					end
				elseif animatedModel then
					animatedModel:Destroy()
				end
			end

			maid2:Add(replicator:Listen(path("mutation"), function()
				updateBrainrotModel()
			end))
			maid2:Add(replicator:Listen(path("traits"), function()
				updateBrainrotModel()
			end))
			maid2:Add(task.spawn(updateBrainrotModel))
			return maid2
		end

		maid:Add(replicator:Observe({ "brainrots" }, function(items, p)
			if items == nil then
				for k in renderedBrainrots do
					destroyBrainrot(k) -- equivalent call inferred; original call site unknown
				end
			else
				for k in items do
					if not renderedBrainrots[k] then
						renderBrainrot(k)
					end
				end

				if p ~= nil then
					for k in renderedBrainrots do
						if items[k] then
							continue
						end

						destroyBrainrot(k) -- equivalent call inferred; original call site unknown
					end
				end
			end
		end))
		local v4 = {
			params = params,
			replicator = replicator
		}
		table.insert(v2, v4)
		maid:Add(replicator:Observe({ "brainrots" }, function()
			updateDropButtonVisibility() -- equivalent call inferred; original call site unknown
		end))
		maid:Add(function()
			for k, v5 in v2 do
				if v5 ~= v4 then
					continue
				end

				table.remove(v2, k)
				break
			end
		end)
		maid:Add(function()
			for k in renderedBrainrots do
				destroyBrainrot(k) -- equivalent call inferred; original call site unknown
			end
		end)
		maid:Add(function()
			updateDropButtonVisibility() -- equivalent call inferred; original call site unknown
		end)
		return maid
	end
})