local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Synchronizer = require(packages.Synchronizer)
local Trove = require(packages.Trove)
local Timer = require(packages.Timer)
local Net = require(packages.Net)
local Observers = require(packages.Observers)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local AnimalPrompt = require(script.AnimalPrompt)
local utils = ReplicatedStorage:WaitForChild("Utils")
local TimeUtils = require(utils.TimeUtils)
local NumberUtils = require(utils.NumberUtils)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Animals = require(shared.Animals)
local BrainrotAssets = require(shared.BrainrotAssets)
local EggScale = require(shared.EggScale)
local animals = ReplicatedStorage:WaitForChild("Animations").Animals
local datas = ReplicatedStorage:WaitForChild("Datas")
local Animals2 = require(datas.Animals)
require(datas.Rarities)
local Bases = require(datas.Bases)
local UnlockBase = require(datas.UnlockBase)
local ServerData = require(datas.ServerData)
local FuseMachineData = require(ReplicatedStorage.Datas.FuseMachineData)
local VirtualInstance = require(ReplicatedStorage.Shared.VirtualInstance)
local shared2 = ReplicatedStorage:WaitForChild("Shared")
local Friends = require(shared2.Friends)
local ServerAuthority = require(shared2.ServerAuthority)
local AnimationSyncController = require(ReplicatedStorage.Controllers.AnimationSyncController)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local ConfirmationController = require(ReplicatedStorage.Controllers.ConfirmationController)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local AnimalOverheadController = require(ReplicatedStorage.Controllers.AnimalOverheadController)
local remoteEvent = Net:RemoteEvent("ShopService/Purchase")
local localPlayer = Players.LocalPlayer
local remoteEvent2 = Net:RemoteEvent("PlotService/Sell")
local remoteEvent3 = Net:RemoteEvent("StealService/Grab")
local remoteEvent4 = Net:RemoteEvent("PlotService/Open")
local remoteEvent5 = Net:RemoteEvent("PlotService/ClaimCoins")
local remoteEvent6 = Net:RemoteEvent("f5f26af9-cb1b-4588-bcc9-12fd78f64599")
local remoteEvent7 = Net:RemoteEvent("8b2abeb7-37e3-4739-a9d8-6fb2d58d966c")
local remoteEvent8 = Net:RemoteEvent("PlotService/ToggleFriends")
local fireServer = remoteEvent8.FireServer
local count = 0

if ServerData.IsTradePlaza() then
	RunService.Heartbeat:Connect(function()
		count = 0
	end)
end

local PlotClient = {}
PlotClient.__index = PlotClient

function PlotClient:ClearIndex(p: number)
	self.AnimalsTraits[p] = nil

	if self.AnimalsModels[p] then
		self.AnimalsModels[p]:Destroy()
		self.AnimalsModels[p] = nil
	end

	if self.ModelsCollector[p] then
		self.ModelsCollector[p]:Clean()
		self.ModelsCollector[p] = nil
	end
end

function PlotClient.MoveAnimals(p)
	local animalPodiums = p.PlotModel:FindFirstChild("AnimalPodiums")

	if not animalPodiums then
		return
	end

	for k, animalsModel in p.AnimalsModels do
		local child = animalPodiums:FindFirstChild((tostring(k)))
		local base = child and child:FindFirstChild("Base")
		local spawn = base and base:FindFirstChild("Spawn")

		if animalsModel.Parent and spawn then
			animalsModel:PivotTo(spawn:GetPivot())
		end
	end
end

function PlotClient:UpdateModel(childName: number, p)
	local v = p.AnimalList[childName]

	if v and self.AnimalsIndex[childName] ~= v.Index then
		self:ClearIndex(childName)
		self.AnimalsIndex[childName] = v.Index
	end

	local animalsModel = self.AnimalsModels[childName]
	local v2 = not animalsModel and type(v) == "table"

	if not v2 and animalsModel then
		local v3 = animalsModel:GetAttribute("Mutation") ~= v.Mutation or v2
		local v4 = type(v.Traits) == "table" and self.AnimalsTraits[childName] ~= table.concat(v.Traits, ",") or v3
		v2 = type(v.Traits) ~= "table" and self.AnimalsTraits[childName] ~= nil or v4
	end

	if v2 then
		self:ClearIndex(childName)
		self.AnimalsIndex[childName] = v.Index
	end

	if v2 then
		local maid = self.ModelsCollector[childName]

		if maid then
			maid:Clean()
		else
			maid = Trove.new()
			self.ModelsCollector[childName] = maid
		end

		local index = v.Index
		task.spawn(function()
			local model = BrainrotAssets.getModel(index)

			if not model or self.ModelsCollector[childName] ~= maid or self.AnimalsIndex[childName] ~= index or self.AnimalsModels[childName] then
				return
			end

			if ServerData.IsTradePlaza() then
				while count >= 5 do
					task.wait()
				end

				if self.ModelsCollector[childName] ~= maid or self.AnimalsIndex[childName] ~= index or self.AnimalsModels[childName] then
					return
				end

				count += 1
			end

			local clone = model:Clone()
			self.AnimalsModels[childName] = clone
			local isTradePlaza = ServerData.IsTradePlaza()

			for _, part in clone:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.Massless = true

				if isTradePlaza then
					part.CastShadow = false
				end
			end

			clone.Parent = self.PlotModel
			clone.PrimaryPart.Anchored = true
			local mutation = v.Mutation

			if mutation then
				maid:Add(Animals:ApplyMutation(clone, v.Index, mutation))
				clone:SetAttribute("Mutation", mutation)
			end

			local child = self.PlotModel.AnimalPodiums:FindFirstChild(childName)
			local base = child and child:FindFirstChild("Base")
			local spawn = base and base:FindFirstChild("Spawn")

			if spawn then
				clone:PivotTo(spawn:GetPivot())
			end

			local extentsSize = clone:GetExtentsSize()
			local traits = v.Traits

			if traits then
				maid:Add(Animals:ApplyTraits(clone, v.Index, traits))
				self.AnimalsTraits[childName] = table.concat(traits, ",")
			end

			if self.ModelsCollector[childName] ~= maid or self.AnimalsModels[childName] ~= clone then
				return
			end

			local child2 = self.PlotModel.AnimalPodiums:FindFirstChild(childName)

			if not child2 then
				self:ClearIndex(childName)
				return
			end

			local parts = {}

			for _, part in clone:GetDescendants() do
				if not part:IsA("BasePart") or (part:HasTag("PhantomPart") or part:HasTag("PhantomEyesPart")) then
					continue
				end

				table.insert(parts, part)
			end

			local formatted = `AnimalList.{childName}`
			clone:PivotTo(child2.Base.Spawn:GetPivot())
			local v3 = (ServerData.IsTradePlaza() and 0.27 or 1) * EggScale.GetEggScale(v.Index)

			if v3 ~= 1 then
				clone:ScaleTo(clone:GetScale() * v3)
			end

			if FFlags:GetInstant("Optimisation.HumanoidBrainrotModels", ServerData.IsNewPlayersServer()) then
				local animationController = clone:FindFirstChild("AnimationController")

				if animationController then
					animationController:Destroy()
				end

				local humanoid = Instance.new("Humanoid", clone)
				Instance.new("Animator", humanoid)
				humanoid.Name = "AnimationController"
				humanoid.EvaluateStateMachine = false
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				humanoid.PlatformStand = true
				humanoid.Parent = clone
			end

			local animationController = clone:FindFirstChild("AnimationController")
			local animator = animationController and animationController:FindFirstChild("Animator")
			local child3 = animals:FindFirstChild(v.Index)
			local idle = child3 and child3:FindFirstChild("Idle")

			if ServerData.IsTradePlaza() then
				if idle and animator then
					local track = animator:LoadAnimation(idle)
					track:Play(0)
					local total = 0

					while track.Length == 0 and total < 5 do
						total += task.wait()

						if self.ModelsCollector[childName] ~= maid or self.AnimalsModels[childName] ~= clone then
							return
						end
					end

					task.wait()

					if self.ModelsCollector[childName] ~= maid or self.AnimalsModels[childName] ~= clone then
						return
					end

					local transformsByBone = {}

					for _, bone in clone:GetDescendants() do
						if bone:IsA("Bone") then
							transformsByBone[bone] = bone.Transform
						end
					end

					local animationController2 = clone:FindFirstChild("AnimationController")

					if animationController2 then
						animationController2:Destroy()
					end

					for k, transform in transformsByBone do
						k.Transform = transform
					end
				end
			else
				if idle and animator then
					local track = animator:LoadAnimation(idle)
					track.Looped = true
					track:Play()
					local v4 = AnimationSyncController:Add(track)
					maid:Add(function()
						v4()
						track:Stop(0)
						track:Destroy()
					end)
				end

				local animal = Animals2[v.Index]
				local OVERHEAD_ATTACHMENT = clone:FindFirstChild("OVERHEAD_ATTACHMENT", true)

				if not OVERHEAD_ATTACHMENT then
					OVERHEAD_ATTACHMENT = maid:Add(Instance.new("Attachment"))
					OVERHEAD_ATTACHMENT.CFrame = CFrame.new(
						0,
						extentsSize.Y * 0.75 * v3 * (not animal and 1 or animal.OverheadYOffsetModifier or 1),
						0
					)
					OVERHEAD_ATTACHMENT.Parent = child2.Base.Spawn
				end

				local fastOverhead, v4 = FastOverheadController.createFastOverhead({
					adornee = OVERHEAD_ATTACHMENT,
					guiTemplate = FastOverheadController.GuiTemplates.AnimalOverhead
				})
				maid:Add(v4)
				local generation = fastOverhead.Generation
				local labels = {}

				for _, label in fastOverhead:GetChildren() do
					if label:IsA("TextLabel") then
						table.insert(labels, label)
					end
				end

				local formatted2 = `${NumberUtils:ToString(Animals:GetGeneration(v.Index, v.Mutation, v.Traits, nil))}/s`

				local function updateOverhead()
					local v5 = self.Channel:Get(formatted)
					local text

					if v5 and v5.Timer ~= nil then
						local v7 = Animals:IsLuckyBlockTimerDisabled(v5.Index) and 0 or v5.Timer
						text = v7 <= 0 and "READY!" or TimeUtils:E(v7)
					elseif v5 and v5.Machine and (v5.Machine.Type == "Crafting" or v5.Machine.Type == "Fuse") and v5.Machine.Active then
						local v7 = (v5.Machine.FinishTime or 0) - workspace:GetServerTimeNow()
						text = v7 <= 0 and "READY!" or TimeUtils:E(v7)
					else
						text = formatted2
					end

					generation.Text = text
					generation.Visible = text ~= "" and not animal.HideGeneration
				end

				AnimalOverheadController:Populate({
					Overhead = fastOverhead,
					Index = v.Index,
					Traits = traits,
					Mutation = mutation,
					Player = localPlayer,
					Trove = maid
				})
				task.spawn(updateOverhead)
				maid:Add(self.Channel:OnChanged("AnimalList", updateOverhead))
				maid:Add(Timer.Simple(1, updateOverhead))
				maid:Add(self.PlotModel:GetAttributeChangedSignal("Nuked"):Connect(function()
					if self.PlotModel:GetAttribute("Nuked") then
						fastOverhead:Destroy()
					end
				end))
				local v5 = nil
				local v6 = false
				local v7 = nil
				local v8 = false

				local function updateVisibility()
					local v9 = self.Channel:Get(formatted)
					local owner = self:GetOwner()
					local v10 = (owner and v9 and v9.Steal == owner.UserId) == true
					local machine = v9 and v9.Machine
					local v11 = v9 and (v9.Steal or machine) and true or false
					local type2

					if machine then
						type2 = machine.Type
					end

					local v12 = (machine and machine.Active) == true

					if v11 == v5 and v10 == v6 and type2 == v7 and v12 == v8 then
						return
					end

					v5 = v11
					v6 = v10
					v7 = type2
					v8 = v12
					task.spawn(updateOverhead)

					for _, v13 in parts do
						local defaultTransparency = v13:GetAttribute("DefaultTransparency")

						if defaultTransparency == nil then
							defaultTransparency = v13.Transparency
							v13:SetAttribute("DefaultTransparency", defaultTransparency)
						end

						if v11 and v13.Transparency < 1 then
							v13.Transparency = 0.5
						else
							v13.Transparency = defaultTransparency
						end
					end

					for _, v13 in labels do
						if not v13:GetAttribute("DefaultState") then
							v13:SetAttribute("DefaultState", v13.Visible)
						end

						if v13.Name == "Stolen" then
							local machine2 = v9 and v9.Machine

							if machine2 and v9.Machine.Type == "Crafting" and v9.Machine.Active then
								v13.Text = "CRAFTING"
								v13.TextColor3 = Color3.fromRGB(187, 123, 203)
							elseif machine2 and v9.Machine.Type == "Fuse" and v9.Machine.Active then
								v13.Text = "FUSING"
								v13.TextColor3 = Color3.fromRGB(0, 140, 255)
							elseif machine2 and v9.Machine.Type == "Fuse" then
								v13.Text = "IN FUSE"
								v13.TextColor3 = Color3.fromRGB(0, 140, 255)
							elseif machine2 and v9.Machine.Type == "Duel" then
								v13.Text = "IN DUEL"
								v13.TextColor3 = Color3.fromRGB(255, 94, 78)
							elseif machine2 and v9.Machine.Type == "Trade" then
								v13.Text = "IN TRADE"
								v13.TextColor3 = Color3.fromRGB(255, 165, 0)
							elseif machine2 and v9.Machine.Type == "Crafting" then
								v13.Text = "IN MACHINE"
								v13.TextColor3 = Color3.fromRGB(187, 123, 203)
							elseif machine2 then
								v13.Text = "IN MACHINE"
								v13.TextColor3 = Color3.fromRGB(0, 140, 255)
							else
								v13.Text = "STOLEN"
								v13.TextColor3 = Color3.fromRGB(255, 0, 4)
							end
						end

						if v11 then
							if v13.Name == "Stolen" then
								v13.Visible = not v10
							elseif v13.Name == "Generation" then
								v13.Visible = v9.Machine and v9.Machine.Active
							else
								v13.Visible = false
							end
						elseif v13.Name == "Stolen" then
							v13.Visible = false
						else
							v13.Visible = v13:GetAttribute("DefaultState")
						end
					end
				end

				maid:Add(self.Channel:OnChanged(`AnimalList.{childName}.Steal`, updateVisibility, true))
				maid:Add(self.Channel:OnChanged(`AnimalList.{childName}.Machine`, updateVisibility))
				maid:Add(self.Channel:OnChanged("AnimalList", function(p2)
					local v9

					if typeof(p2) == "table" then
						v9 = p2[childName]
					end

					if type(v9) == "table" then
						updateVisibility()
					end
				end))
			end
		end)
	end
end

function PlotClient:HideClaim(childName: number)
	local child = self.PlotModel.AnimalPodiums:FindFirstChild(childName)
	local v = child and self.CollectGuis[child]

	if v then
		v.gui.Enabled = false
	end
end

function PlotClient:UpdateClaim(childName: number, data)
	local v = data.AnimalList[childName]
	local animal = Animals2[v.Index]
	local child = self.PlotModel.AnimalPodiums:FindFirstChild(childName)

	if not child then
		return
	end

	local v2 = self.CollectGuis[child]

	if not v2 then
		local fastOverhead, v3 = FastOverheadController.createFastOverhead({
			adornee = child.Claim.Main,
			guiTemplate = FastOverheadController.GuiTemplates.CashPad
		})
		local ancestryChangedConnection = nil
		ancestryChangedConnection = child.AncestryChanged:Connect(function()
			if not child:IsDescendantOf(workspace) then
				v3()
				ancestryChangedConnection:Disconnect()
				self.CollectGuis[child] = nil
			end
		end)
		v2 = {
			gui = fastOverhead,
			collect = VirtualInstance.wrap(fastOverhead.Collect),
			collectAmount = VirtualInstance.wrap(fastOverhead.CollectAmount),
			offline = VirtualInstance.wrap(fastOverhead.Offline)
		}
		self.CollectGuis[child] = v2
	end

	if animal and (animal.LuckyBlock or animal.Egg) or v.Machine or data.IsDuelsServer or data.IsTradePlaza then
		v2.gui.Enabled = false
		return
	end

	local generation = Animals:GetGeneration(v.Index, v.Mutation, v.Traits, localPlayer)
	local v3 = math.floor(workspace:GetServerTimeNow() - v.LastCollect) * generation
	v2.collectAmount.Text = `${NumberUtils:ToString(v3)}`

	if v.OfflineGain then
		v2.offline.Text = `(Offline Cash: <font color="#73ff00">${NumberUtils:ToString(v.OfflineGain * generation)}</font>)`
	end

	v2.offline.Visible = v.OfflineGain ~= nil
	v2.gui.Enabled = true
end

function PlotClient:UpdatePrompt(childName: number, data)
	local child = self.PlotModel.AnimalPodiums:FindFirstChild(childName)

	if child then
		local v = data.AnimalList[childName]

		if child:GetAttribute("DeferDisplay") then
			v = nil
		elseif v == "Empty" then
			v = nil
		end

		local index

		if v then
			index = v.Index
		else
			index = `None_{tostring(childName)}`
		end

		local spawn = child.Base.Spawn
		local animalsPrompt = self.AnimalsPrompts[childName]

		if animalsPrompt and animalsPrompt.AnimalIndex ~= index then
			for _, prompt in pairs(animalsPrompt.Prompts) do
				prompt:Destroy()
			end

			animalsPrompt = nil
		end

		if not animalsPrompt then
			animalsPrompt = {
				AnimalIndex = index,
				Prompts = {
					AnimalPrompt.new(childName, index, spawn.PromptAttachment),
					AnimalPrompt.new(childName, index, spawn.PromptAttachment, {
						KeyboardKeyCode = Enum.KeyCode.F,
						GamepadKeyCode = Enum.KeyCode.ButtonY,
						UIOffset = Vector2.new(0, -72)
					})
				}
			}
			local v2 = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateOverheadVisibility()
				local animalOverhead = child:FindFirstChild("AnimalOverhead", true)

				if animalOverhead and animalOverhead:IsA("BillboardGui") then
					animalOverhead.AlwaysOnTop = next(v2) ~= nil
				end
			end

			for _, prompt in pairs(animalsPrompt.Prompts) do
				local v3 = prompt
				prompt.Collector:Add(prompt.ProximityPrompt.PromptShown:Connect(function()
					v2[v3.ProximityPrompt] = true
					updateOverheadVisibility() -- equivalent call inferred; original call site unknown
				end))
				local v4 = prompt
				prompt.Collector:Add(prompt.ProximityPrompt.PromptHidden:Connect(function()
					v2[v4.ProximityPrompt] = nil
					updateOverheadVisibility() -- equivalent call inferred; original call site unknown
				end))
				local v5 = prompt
				prompt.Collector:Add(function()
					v2[v5.ProximityPrompt] = nil
					updateOverheadVisibility() -- equivalent call inferred; original call site unknown
				end)
				local v6 = prompt
				prompt.Collector:Add(prompt.ProximityPrompt.PromptButtonHoldBegan:Connect(function()
					for k, prompt2 in pairs(animalsPrompt.Prompts) do
						if prompt2 ~= v6 then
							prompt2.ProximityPrompt.Enabled = false
						end
					end
				end))
				local v7 = prompt
				prompt.Collector:Add(prompt.ProximityPrompt.PromptButtonHoldEnded:Connect(function()
					for k, prompt2 in pairs(animalsPrompt.Prompts) do
						if prompt2 == v7 then
							continue
						end

						prompt2.ProximityPrompt.Enabled = true
						prompt2:SetState(prompt2.State)
					end
				end))
			end

			self.AnimalsPrompts[childName] = animalsPrompt
		end

		assert(animalsPrompt)
		local prompt = animalsPrompt.Prompts[1]
		local prompt2 = animalsPrompt.Prompts[2]

		if data.IsPlotOwner then
			local isDuelsServer = data.IsDuelsServer
			local isGrabbing = data.IsGrabbing
			local isBusy = data.IsBusy

			if (v or isGrabbing) and not (v and v.Machine and v.Machine.Active or isBusy) then
				if isGrabbing then
					local steal = v and v.Steal

					if steal then
						steal = v.Steal ~= localPlayer.UserId
					end

					if steal then
						if prompt.State ~= "None" then
							prompt:SetState("None")
						end
					elseif prompt.State ~= "Place" then
						prompt:SetState("Place", function()
							remoteEvent3:FireServer("Place", childName)
						end)
					end

					if prompt2.State ~= "None" then
						prompt2:SetState("None")
					end
				elseif v and v.Machine and not (v.Machine.Active or isDuelsServer) then
					if prompt.State ~= "Return" then
						prompt:SetState("Return", function()
							local type2 = v.Machine and v.Machine.Type

							if type2 == "Fuse" then
								local v2, v3 = FuseMachineData.Remotes.RemoveBrainrot:InvokeServer(childName)

								if not v2 then
									NotificationController:Error(v3 or "Something went wrong!")
								end
							elseif type2 == "Crafting" then
								Net:RemoteEvent("CraftingMachineService/Return"):FireServer(childName)
							elseif type2 == "BrainrotTrader" then
								Net:RemoteEvent("BrainrotTraderService/Return"):FireServer(childName)
							else
								Net:RemoteEvent("StockEventService/Return"):FireServer(type2, childName)
							end
						end)
					end

					if prompt2.State ~= "None" then
						prompt2:SetState("None")
					end
				else
					local timer = v.Timer or 1
					local v2 = Animals:IsLuckyBlockTimerDisabled(v.Index) and 0 or timer

					if v and v.Steal or isDuelsServer or data.IsTradePlaza then
						if prompt.State ~= "None" then
							prompt:SetState("None")
						end
					elseif prompt.State == "Grab" or not (v2 > 0) then
						if prompt.State ~= "Open" and v2 <= 0 then
							prompt:SetState("Open", function()
								remoteEvent4:FireServer(childName)
							end)
						end
					else
						prompt:SetState("Grab", function()
							remoteEvent3:FireServer("Grab", childName)
						end)
					end

					if v and v.Steal or isDuelsServer or data.IsTradePlaza then
						if prompt2.State ~= "None" then
							prompt2:SetState("None")
						end
					elseif prompt2.State ~= "Sell" then
						prompt2:SetState("Sell", function()
							local animalIndex = self.AnimalsPrompts[childName].AnimalIndex

							if Animals:GetRarityWeight(Animals2[animalIndex].Rarity) >= 5 then
								local formatted = `Do you want to sell {animalIndex}?`

								if ConfirmationController:IsInPrompt() or not ConfirmationController:Show(formatted) then
									return
								end
							end

							remoteEvent2:FireServer(childName)
						end)
					end
				end
			else
				if prompt.State ~= "None" then
					prompt:SetState("None")
				end

				if prompt2.State ~= "None" then
					prompt2:SetState("None")
				end
			end
		else
			if v and v.Steal and v.Steal ~= "FuseMachine" or data.IsTsunamiServer or data.IsTradePlaza or data.IsBusy then
				if prompt.State ~= "None" then
					prompt:SetState("None")
				end
			elseif v and not (v.Machine and v.Machine.Active) then
				if prompt.State ~= "Steal" then
					prompt:SetState("Steal", function()
						fireServer(
							remoteEvent6,
							workspace:GetServerTimeNow() + 16,
							"7aae3e74-d52e-433a-83b1-9d5a507d2e80",
							self.PlotModel.Name,
							childName
						)
						remoteEvent6:FireServer(
							workspace:GetServerTimeNow() + 16,
							"c3eb316e-a4cc-4dc9-8b0e-1a770a7d99fd",
							self.PlotModel.Name,
							childName
						)
					end)
				end
			elseif prompt.State ~= "None" then
				prompt:SetState("None")
			end

			if prompt2.State ~= "None" then
				prompt2:SetState("None")
			end
		end
	else
		local animalsPrompt = self.AnimalsPrompts[childName]

		if animalsPrompt then
			for _, prompt in pairs(animalsPrompt.Prompts) do
				prompt:Destroy()
			end

			self.AnimalsPrompts[childName] = nil
		end
	end
end

local function buildUpdateContext(object, animalList)
	local isPlotOwner = object:GetOwner() == localPlayer
	local isGrabbing = false

	if isPlotOwner and localPlayer:GetAttribute("Stealing") then
		for _, item in animalList do
			if item.Steal ~= localPlayer.UserId then
				continue
			end

			isGrabbing = true
			break
		end
	end

	return {
		AnimalList = animalList,
		IsPlotOwner = isPlotOwner,
		IsDuelsServer = ServerData.IsDuelsServer(),
		IsTsunamiServer = ServerData.IsTsunamiServer(),
		IsTradePlaza = ServerData.IsTradePlaza(),
		IsBusy = localPlayer:GetAttribute("IsTrading") == true or localPlayer:GetAttribute("IsDuelSelecting") == true,
		IsGrabbing = isGrabbing
	}
end

function PlotClient:UpdateAnimalPodiums()
	local animalPodiums = self.PlotModel:FindFirstChild("AnimalPodiums")

	if not animalPodiums then
		return
	end

	local nuked = self.PlotModel:GetAttribute("Nuked")
	local animalList = self.Channel:Get("AnimalList") or {}
	local updateContext = buildUpdateContext(self, animalList)

	for i = 1, Bases[self.PlotModel:GetAttribute("Tier")].MaxAnimals do
		if nuked then
			self:HideClaim(i)
			local animalsPrompt = self.AnimalsPrompts[i]

			if animalsPrompt then
				for _, prompt in pairs(animalsPrompt.Prompts) do
					prompt:Destroy()
				end
			end
		else
			local child = animalPodiums:FindFirstChild(i)

			if type(animalList[i]) == "table" and child and not child:GetAttribute("DeferDisplay") then
				self:UpdateModel(i, updateContext)

				if not updateContext.IsTradePlaza then
					self:UpdateClaim(i, updateContext)
				end
			else
				self:ClearIndex(i)
				self:HideClaim(i)
			end

			if not updateContext.IsTradePlaza then
				self:UpdatePrompt(i, updateContext)
			end
		end
	end
end

local function UpdatePurchaseBlockedLabel(object)
	local visible = false
	object:GetOwner()
	local purchases = object.PlotModel:WaitForChild("Purchases", 5)

	if not purchases then
		return
	end

	if object.Channel:Get("BlockEndTime") ~= nil then
		local v2 = math.clamp(math.round(object.Channel:Get("BlockEndTime") - workspace:GetServerTimeNow()), 0, 1e999)

		for _, child in purchases:GetChildren() do
			if child:FindFirstChild("Main") then
				child.Main.BillboardGui.RemainingTime.Text = TimeUtils:C(v2)
			end
		end

		visible = true
	end

	for _, child in purchases:GetChildren() do
		if not child:FindFirstChild("Main") then
			continue
		end

		child.Main.BillboardGui.LockStudio.Visible = not visible
		child.Main.BillboardGui.RemainingTime.Visible = visible
		child.Main.BillboardGui.Locked.Visible = visible
	end
end

local function UpdateDelayBlockedLabel(object)
	if object.Channel:Get("BlockEndTime") == nil then
		local visible = false
		local purchases = object.PlotModel:FindFirstChild("Purchases")

		if not purchases then
			return
		end

		if object.Channel:Get("BlockedDelayTime") ~= nil then
			local v2 = math.clamp(
				math.round(object.Channel:Get("BlockedDelayTime") - workspace:GetServerTimeNow()),
				0,
				1e999
			)

			for _, child in purchases:GetChildren() do
				if child:FindFirstChild("Main") then
					child.Main.BillboardGui.RemainingTime.Text = TimeUtils:C(v2)
				end
			end

			visible = true
		end

		for _, child in purchases:GetChildren() do
			if not child:FindFirstChild("Main") then
				continue
			end

			child.Main.BillboardGui.LockStudio.Visible = not visible
			child.Main.BillboardGui.RemainingTime.Visible = visible
			child.Main.BillboardGui.Delay.Visible = visible
		end
	end
end

local function UpdateUnlock(object)
	if object:GetOwner() == localPlayer then
		return
	end

	local unlock = object.PlotModel:FindFirstChild("Unlock")

	if not unlock then
		return
	end

	if ServerData.IsTradePlaza() then
		for _, child in unlock:GetChildren() do
			local unlockBase = child:FindFirstChild("UnlockBase")

			if unlockBase then
				unlockBase.Enabled = false
			end
		end
	else
		for _, child in unlock:GetChildren() do
			local floor = child.UnlockBase:GetAttribute("Floor")

			if not floor then
				continue
			end

			local v = floor == 2 and "BlockEndTimeSecondFloor" or floor == 3 and "BlockEndTimeThirdFloor" or "BlockEndTimeFirstFloor"
			local enabled = object.Channel:Get(v) ~= nil
			child.UnlockBase.Enabled = enabled
		end
	end
end

local function UpdateBlocked(object)
	if not (object.Channel and object.Channel.Get) then
		return
	end

	local owner = object:GetOwner()
	local v = owner == localPlayer
	local inGameFriends = Friends:GetInGameFriends(localPlayer)
	local v2 = object.Channel:Get("FriendsAllowed") == true
	local laserHitbox = object.PlotModel:FindFirstChild("LaserHitbox")

	if not laserHitbox then
		return
	end

	local enabled = ServerAuthority.isEnabled()

	if ServerData.IsTradePlaza() then
		for _, part in laserHitbox:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			if not enabled then
				part.CanCollide = false
			end

			part.CanQuery = false
		end
	else
		for _, part in laserHitbox:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			local floor = part:GetAttribute("Floor")

			if not floor then
				continue
			end

			local v3 = floor == 2 and "BlockEndTimeSecondFloor" or floor == 3 and "BlockEndTimeThirdFloor" or "BlockEndTimeFirstFloor"
			local canQuery = object.Channel:Get(v3) ~= nil

			if not enabled then
				local v5 = (v or localPlayer:GetAttribute("IgnoreLasers")) and true or table.find(inGameFriends, owner) and v2 and true or false
				part.CanCollide = canQuery and not v5
			end

			if FFlags:GetInstant("Plot/FixProximityPromptsVisibility", true) then
				part.CanQuery = canQuery
			end
		end
	end
end

function PlotClient:GetOwner()
	return self.Channel:Get("Owner")
end

function PlotClient.GetSpawn(p)
	return p.PlotModel.Spawn
end

function PlotClient.GetUID(p)
	return p.UID
end

function PlotClient.new(plotModel)
	local object = setmetatable({}, PlotClient)
	object.UID = plotModel.Name
	object.PlotModel = plotModel
	object.Collector = Trove.new()
	object.OwnerCollector = Trove.new()
	object.Collector:Add(object.OwnerCollector, "Destroy")
	object.AnimalsModels = {}
	object.AnimalsIndex = {}
	object.AnimalsTraits = {}
	object.AnimalsPrompts = {}
	object.ModelsCollector = {}
	object.CollectGuis = {}
	object.Channel = Synchronizer:Wait(object.UID)

	local function reset()
		for k, animalsPrompt in object.AnimalsPrompts do
			for _, prompt in animalsPrompt.Prompts do
				prompt:Destroy()
			end

			object.AnimalsPrompts[k] = nil
		end

		for k, animalsModel in object.AnimalsModels do
			animalsModel:Destroy()
			object.AnimalsModels[k] = nil
		end

		table.clear(object.AnimalsTraits)
	end

	local function setup()
		object.OwnerCollector:Clean()
		reset()
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.MaxParts = 1
		local v = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshHitboxFilter()
			local filterDescendantsInstances = {}

			for k in v do
				table.insert(filterDescendantsInstances, k)
			end

			overlapParams.FilterDescendantsInstances = filterDescendantsInstances
		end

		local function observeHitboxTag(p: string)
			object.OwnerCollector:Add(Observers.observeTag(p, function(p2)
				if v[p2] then
					return nil
				end

				v[p2] = true
				refreshHitboxFilter() -- equivalent call inferred; original call site unknown
				return function()
					v[p2] = nil
					refreshHitboxFilter() -- equivalent call inferred; original call site unknown
				end
			end, { object.PlotModel }))
		end

		observeHitboxTag("PlotDeliveryHitbox")

		if ServerData.IsTsunamiServer() then
			observeHitboxTag("PlotStealHitbox")
		end

		object.OwnerCollector:Add(Observers.observeTag("PlotLaserHitbox", function()
			task.spawn(UpdateBlocked, object)
			return function() end
		end, { object.PlotModel }))
		object.OwnerCollector:Add(Observers.observeTag("PlotClaimHitbox", function(p)
			local name = p.Parent and p.Parent.Parent and tonumber(p.Parent.Parent.Name)
			local touchedConnection = p.Touched:Connect(function(otherPart)
				if not (object:GetOwner() == localPlayer and otherPart.Name == "HumanoidRootPart") then
					return
				end

				local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

				if not playerFromCharacter or playerFromCharacter ~= object:GetOwner() then
					return
				end

				remoteEvent5:FireServer(name)
			end)
			task.spawn(function()
				object:UpdateAnimalPodiums()
			end)
			return function()
				touchedConnection:Disconnect()
				task.spawn(function()
					object:UpdateAnimalPodiums()
				end)
			end
		end, { object.PlotModel }))

		if object:GetOwner() == localPlayer and not ServerData.IsTradePlaza() then
			local total = 0
			object.OwnerCollector:Add(RunService.PostSimulation:Connect(function(dt: number)
				total += dt

				if total < 0.05 then
					return
				end

				debug.profilebegin("PlotClient:Hitboxes")
				total = 0

				if not localPlayer:GetAttribute("Stealing") then
					debug.profileend()
					return
				end

				for _, v2 in object.Channel:Get("AnimalList") or {} do
					if v2.Steal ~= localPlayer.UserId then
						continue
					end

					debug.profileend()
					return
				end

				local character = localPlayer.Character

				if not character then
					debug.profileend()
					return
				end

				local position = character:GetPivot().Position

				if #workspace:GetPartBoundsInBox(CFrame.new(position), createVector(4, 4, 2), overlapParams) <= 0 then
					debug.profileend()
					return
				end

				fireServer(remoteEvent7, "7c7745c9-ae67-4244-a463-78872bbd5977")
				remoteEvent7:FireServer("7c7745c9-ae67-4244-a463-78872bbd5977")
				debug.profileend()
			end))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateBlocks()
			UpdatePurchaseBlockedLabel(object)
			UpdateUnlock(object)
			UpdateDelayBlockedLabel(object)
			UpdateBlocked(object)
		end

		if not ServerData.IsTradePlaza() then
			object.OwnerCollector:Add(Timer.Simple(1, function()
				object:UpdateAnimalPodiums()
				updateBlocks() -- equivalent call inferred; original call site unknown
			end, true))
		end

		object.OwnerCollector:Add(Observers.observeTag("PlotBlockHitbox", function(_)
			task.spawn(UpdateDelayBlockedLabel, object)
			task.spawn(UpdatePurchaseBlockedLabel, object)
			return function()
				task.spawn(UpdateDelayBlockedLabel, object)
				task.spawn(UpdatePurchaseBlockedLabel, object)
			end
		end, { object.PlotModel }))
		object.OwnerCollector:Add(object.Channel:OnChanged("BlockEndTime", updateBlocks, true))
		object.OwnerCollector:Add(object.Channel:OnChanged("BlockEndTimeFirstFloor", updateBlocks, true))
		object.OwnerCollector:Add(object.Channel:OnChanged("BlockEndTimeSecondFloor", updateBlocks, true))
		object.OwnerCollector:Add(object.Channel:OnChanged("BlockEndTimeThirdFloor", updateBlocks, true))
		object.OwnerCollector:Add(object.Channel:OnChanged("BlockedDelayTime", updateBlocks, true))
		object.OwnerCollector:Add(object.Channel:OnChanged("AnimalList", function(_)
			object:UpdateAnimalPodiums()
		end, true))
		object.OwnerCollector:Add(plotModel:GetAttributeChangedSignal("Nuked"):Connect(function()
			if plotModel:GetAttribute("Nuked") then
				for _, model in object.PlotModel:GetChildren() do
					if not (model:IsA("Model") and model.PrimaryPart) then
						continue
					end

					model.PrimaryPart.Anchored = false
					model.PrimaryPart.CanCollide = true
				end
			end
		end))
		local owner = object:GetOwner()

		if owner then
			object.OwnerCollector:Add(owner:GetAttributeChangedSignal("Stealing"):Connect(function(_)
				object:UpdateAnimalPodiums()
			end))
			object.OwnerCollector:Add(owner:GetAttributeChangedSignal("IsTrading"):Connect(function()
				object:UpdateAnimalPodiums()
			end))
		end

		object.OwnerCollector:Add(Observers.observeTag("UnlockBasePrompt", function(instance)
			local triggeredConnection = instance.Triggered:Connect(function(player)
				if player and player:IsA("Player") then
					local owner2 = object:GetOwner()

					if owner2 == player or not owner2 then
						return
					end

					local productId = UnlockBase[instance:GetAttribute("Floor")].ProductId
					local userId = owner2.UserId

					if object.Channel:Get("BlockEndTimeFirstFloor") ~= nil or object.Channel:Get("BlockEndTimeSecondFloor") ~= nil or object.Channel:Get("BlockEndTimeThirdFloor") ~= nil then
						remoteEvent:FireServer(productId, userId)
					end
				end
			end)
			task.spawn(UpdateBlocked, object)
			task.spawn(UpdateUnlock, object)
			return function()
				triggeredConnection:Disconnect()
				task.spawn(UpdateBlocked, object)
				task.spawn(UpdateUnlock, object)
			end
		end, { object.PlotModel }))
		object.OwnerCollector:Add(Friends.OnFriendsUpdate:Connect(function()
			UpdateBlocked(object)
		end))
		object.OwnerCollector:Add(localPlayer:GetAttributeChangedSignal("IgnoreLasers"):Connect(function()
			UpdateBlocked(object)
		end))
		object.OwnerCollector:Add(Observers.observeTag("PlotFriendPanel", function(instance)
			local maid = Trove.new()

			if object.PlotModel:GetAttribute("Tier") == 0 and object:GetOwner() or ServerData.IsDuelsServer() or ServerData.IsTradePlaza() then
				instance:PivotTo(CFrame.new(createVector(0, 1000000000, 0)))
			end

			local proximityPrompt = instance.Main.ProximityPrompt
			maid:Add(object.Channel:OnChanged("FriendsAllowed", function(flag: boolean)
				proximityPrompt.ObjectText = flag == true and "Disallow Friends" or "Allow Friends"
				instance.Main.SurfaceGui.ImageLabel.Image = flag == true and "rbxassetid://110507824065923" or "rbxassetid://110783679426495"
				UpdateBlocked(object)
			end, true))
			maid:Add(proximityPrompt.Triggered:Connect(function()
				if object:GetOwner() ~= localPlayer then
					return
				end

				remoteEvent8:FireServer()
			end))
			return function()
				maid:Destroy()
			end
		end, { object.PlotModel }))
		object.OwnerCollector:Add(Observers.observeTag("PlotSign", function(p)
			p.YourBase.Enabled = object:GetOwner() == localPlayer
			return function() end
		end, { object.PlotModel }))

		if ServerData.IsTradePlaza() then
			local owner2 = object:GetOwner()
			local miniBaseOverhead = script:FindFirstChild("MiniBaseOverhead")
			local stealHitbox = object.PlotModel:FindFirstChild("StealHitbox") or object.PlotModel:FindFirstChild("Spawn")

			if owner2 and miniBaseOverhead and miniBaseOverhead:IsA("BillboardGui") and stealHitbox and stealHitbox:IsA("BasePart") then
				local v2

				if stealHitbox.Name == "StealHitbox" then
					v2 = stealHitbox.Size.Y * 0.5 + 6
				else
					local tier = object.PlotModel:GetAttribute("Tier") or 0
					local v3 = Bases[tier] or Bases[0]
					local model = v3 and v3.Model
					v2 = (not model and 40 or model:GetExtentsSize().Y) * 0.27 + 3
				end

				local v3 = {
					Headless = 6,
					Octo = 4,
					["Pot of Gold"] = 2,
					Skibidi = 8,
					Summer = 4,
					Taco = 2,
					["Bunny Basket"] = 6,
					Divine = 2,
					Tralalero = 4
				}
				local baseSkinName = object.PlotModel:GetAttribute("BaseSkinName")

				if typeof(baseSkinName) == "string" then
					v2 += v3[baseSkinName] or 0
				end

				local clone = miniBaseOverhead:Clone()
				clone.Adornee = stealHitbox
				clone.StudsOffsetWorldSpace = Vector3.new(0, v2, 0)
				local title = clone:FindFirstChild("Title", true)

				if title and title:IsA("TextLabel") then
					title.Text = `{owner2.DisplayName}'s Base`
					local parent = title.Parent

					if parent and parent:IsA("GuiObject") then
						local getTextBoundsParams = Instance.new("GetTextBoundsParams")
						getTextBoundsParams.Text = title.Text
						getTextBoundsParams.Font = title.FontFace
						getTextBoundsParams.RichText = title.RichText
						object.OwnerCollector:Add(getTextBoundsParams)

						-- equivalent calls inferred from this helper; original call sites unknown
						local function updateTitleSize()
							getTextBoundsParams.Size = 16
							local success, textBoundsAsync = pcall(
								TextService.GetTextBoundsAsync,
								TextService,
								getTextBoundsParams
							)

							if not success then
								return false
							end

							title.Size = UDim2.fromScale(math.clamp(textBoundsAsync.X / 240, 0, 1), 1)
							return true
						end

						task.spawn(function()
							for _ = 1, 10 do
								-- equivalent call inferred; original call site unknown
								if updateTitleSize() then
									break
								else
									task.wait(1)
								end
							end
						end)
					end
				end

				local playerIcon = clone:FindFirstChild("PlayerIcon", true)

				if playerIcon and playerIcon:IsA("ImageLabel") then
					playerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={owner2.UserId}&w=150&h=150`
				end

				local viewerCount = clone:FindFirstChild("ViewerCount", true)

				if viewerCount and viewerCount:IsA("TextLabel") then
					local parent = viewerCount.Parent

					-- equivalent calls inferred from this helper; original call sites unknown
					local function updateViewers()
						local previewViewers = object.PlotModel:GetAttribute("PreviewViewers")
						local v4 = typeof(previewViewers) ~= "number" and 0 or previewViewers
						viewerCount.Text = tostring(v4)

						if parent and parent:IsA("GuiObject") then
							parent.Visible = v4 > 0
						end
					end

					updateViewers() -- equivalent call inferred; original call site unknown
					object.OwnerCollector:Add(object.PlotModel:GetAttributeChangedSignal("PreviewViewers"):Connect(updateViewers))
				end

				clone.Parent = stealHitbox
				object.OwnerCollector:Add(clone)
			end
		end
	end

	object.Collector:Add(object.Channel:OnChanged("Owner", setup, true))
	object.Collector:Add(object.PlotModel:GetAttributeChangedSignal("Tier"):Connect(setup))

	if ServerData.IsTradePlaza() then
		object.Collector:Add(object.PlotModel.ChildAdded:Connect(function(child)
			if child.Name == "AnimalPodiums" or child.Name == "StealHitbox" or child.Name == "Spawn" then
				task.defer(setup)
			end
		end))
		object.Collector:Add(object.PlotModel:GetAttributeChangedSignal("BaseSkinName"):Connect(function()
			task.defer(setup)
		end))
	end

	return object
end

function PlotClient:Destroy()
	for k, animalsPrompt in self.AnimalsPrompts do
		for _, prompt in animalsPrompt.Prompts do
			prompt:Destroy()
		end

		self.AnimalsPrompts[k] = nil
	end

	for k, animalsModel in self.AnimalsModels do
		animalsModel:Destroy()
		self.AnimalsModels[k] = nil
	end

	table.clear(self.AnimalsTraits)
	self.Collector:Destroy()
end

return PlotClient