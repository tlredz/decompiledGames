local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local AnimalOverheadController = require(ReplicatedStorage.Controllers.AnimalOverheadController)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Animals = require(datas.Animals)
local _ = ReplicatedStorage:WaitForChild("Others").AnimalTemplate
local shared = ReplicatedStorage:WaitForChild("Shared")
local Animals2 = require(shared.Animals)
local BrainrotAssets = require(shared.BrainrotAssets)
local _ = ReplicatedStorage:WaitForChild("Overheads").AnimalOverhead
local utils = ReplicatedStorage:WaitForChild("Utils")
local NumberUtils = require(utils.NumberUtils)
local TimeUtils = require(utils.TimeUtils)
local animals = ReplicatedStorage:WaitForChild("Animations").Animals
local renderedMovingAnimals = workspace:WaitForChild("RenderedMovingAnimals")
local animalTraits = ReplicatorClient.get("AnimalTraits")
local AnimalClient = {}
AnimalClient.__index = AnimalClient

function AnimalClient.GetUID(p)
	return p.UID
end

function AnimalClient.new(instance)
	local object = setmetatable({}, AnimalClient)
	object.UID = instance.Name
	object.Collector = Trove.new()
	object.Instance = instance
	local maid = object.Collector:Extend()
	local v = nil

	local function buildVisual()
		maid:Clean()
		local v2 = {}
		v = v2
		object.Index = object.Instance:GetAttribute("Index")
		object.Mutation = object.Instance:GetAttribute("Mutation")
		object.Overhead = nil
		local animal = Animals[object.Index]

		if not animal then
			warn("Failed to find animal data: " .. object.Index)
			return
		end

		local model = BrainrotAssets.getModel(object.Index)

		if v ~= v2 then
			return
		end

		if not model then
			warn("Failed to find animal model: " .. tostring(object.Index))
			return
		end

		object.AnimalModel = model:Clone()
		local extentsSize = object.AnimalModel:GetExtentsSize()

		for _, part in object.AnimalModel:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			part.Anchored = false
		end

		maid:Add(object.AnimalModel)

		if object.AnimalModel.PrimaryPart then
			object.AnimalModel.PrimaryPart.Anchored = true
		end

		object.AnimalModel:AddTag("RenderedMovingAnimal")
		object.AnimalModel.Parent = renderedMovingAnimals

		if object.Mutation then
			maid:Add(Animals2:ApplyMutation(object.AnimalModel, object.Index, object.Mutation))
		end

		local function updateOverhead()
			if not object.Overhead then
				return
			end

			local text

			if animal.LuckyBlock then
				local v4 = Animals2:IsLuckyBlockTimerDisabled(object.Index) and 0 or animal.LuckyBlock.RoadTimer or animal.LuckyBlock.Timer
				text = v4 <= 0 and "READY!" or TimeUtils:E(v4)
			elseif animal.Egg then
				text = animal.Egg.Timer <= 0 and "READY!" or TimeUtils:E(animal.Egg.Timer)
			else
				text = `${NumberUtils:ToString(Animals2:GetGeneration(object.Index, object.Mutation, object.Traits))}/s`
			end

			object.Overhead.Generation.Text = text
			local generation = object.Overhead.Generation
			generation.Visible = text ~= "" and not animal.HideGeneration
		end

		local extended = maid:Extend()
		local v3 = nil

		local function updateTraits()
			extended:Clean()
			local v4 = {}
			v3 = v4
			local animalModel = object.AnimalModel
			local traits = animalTraits:TryIndex({ "traits", object.UID })
			local v6 = object

			if type(traits) ~= "table" then
				traits = nil
			end

			v6.Traits = traits

			if object.Traits then
				local v7 = Animals2:ApplyTraits(animalModel, object.Index, object.Traits)

				if v3 == v4 and object.AnimalModel == animalModel then
					if v7 then
						extended:Add(v7)
					end
				else
					if v7 then
						v7()
					end

					return
				end
			end

			if object.Overhead then
				AnimalOverheadController:PopulateTraits(object.Overhead, object.Traits, extended)
				object.Overhead.DisplayName.Text = AnimalOverheadController:ResolveDisplayName(
					object.Index,
					object.Traits
				)
			end

			updateOverhead()
		end

		if FFlags:GetInstant("Optimisation.HumanoidBrainrotModels", ServerData.IsNewPlayersServer()) then
			local animationController = object.AnimalModel:FindFirstChild("AnimationController")

			if animationController then
				animationController:Destroy()
			end

			local humanoid = Instance.new("Humanoid", object.AnimalModel)
			Instance.new("Animator", humanoid)
			humanoid.Name = "AnimationController"
			humanoid.EvaluateStateMachine = false
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.PlatformStand = true
			humanoid.BreakJointsOnDeath = false
			humanoid.RequiresNeck = false
			humanoid.Parent = object.AnimalModel
		end

		local animator = object.AnimalModel.AnimationController.Animator
		local child = animals:FindFirstChild(object.Index)
		local walk = child and child:FindFirstChild("Walk")

		if walk then
			object.WalkTrack = animator:LoadAnimation(walk)
			object.WalkTrack.Looped = true
			object.WalkTrack:Play()
			object.WalkTrack:AdjustSpeed(walk:GetAttribute("Speed") or 1)
		end

		local roadBrainrotIdle = child and (child:FindFirstChild("RoadBrainrotIdle") or child:FindFirstChild("Idle"))

		if roadBrainrotIdle then
			object.IdleTrack = animator:LoadAnimation(roadBrainrotIdle)
			object.IdleTrack.Looped = true
			object.IdleTrack:AdjustSpeed(roadBrainrotIdle:GetAttribute("Speed") or 1)
		end

		local function updateForceIdle()
			if object.Instance:GetAttribute("ForceIdle") then
				object.WalkTrack:Stop()
				object.IdleTrack:Play()
				object.AnimalModel:SetAttribute("Walking", false)
			else
				object.WalkTrack:Play()
				object.IdleTrack:Stop()
				object.AnimalModel:SetAttribute("Walking", true)
			end
		end

		maid:Add(object.Instance:GetAttributeChangedSignal("ForceIdle"):Connect(updateForceIdle))
		maid:Add(task.spawn(updateForceIdle))
		local adornee = object.AnimalModel:FindFirstChild("OVERHEAD_ATTACHMENT", true)

		if not adornee then
			adornee = Instance.new("Attachment")
			adornee.Name = "Info"
			adornee.CFrame = CFrame.new(0, extentsSize.Y * 0.75 * (animal.OverheadYOffsetModifier or 1), 0)
			adornee.Parent = object.Instance.PrimaryPart
			maid:Add(adornee)
		end

		if not animal.HideOverhead then
			local fastOverhead, v5 = FastOverheadController.createFastOverhead({
				adornee = adornee,
				guiTemplate = FastOverheadController.GuiTemplates.AnimalOverhead
			})
			object.Overhead = fastOverhead
			maid:Add(v5)
			AnimalOverheadController:Populate({
				Overhead = object.Overhead,
				Index = object.Index,
				Mutation = object.Mutation,
				Trove = maid
			})
			updateOverhead()
		end

		object.AnimalModel:PivotTo(object.Instance:GetPivot())
		local primaryPart = object.AnimalModel.PrimaryPart

		if primaryPart then
			primaryPart.RootPriority = 100
			local v5

			if FFlags:GetInstant("AnimalClient/UseNormalWelds", true) then
				v5 = maid:Add(Instance.new("Weld"))
				v5.Part0 = primaryPart
				v5.Part1 = object.Instance.PrimaryPart
				v5.C0 = primaryPart.PivotOffset
			else
				v5 = maid:Add(Instance.new("WeldConstraint"))
				v5.Part0 = primaryPart
				v5.Part1 = object.Instance.PrimaryPart
			end

			v5.Parent = primaryPart
			local v6 = {}
			local postSimulationConnection = nil
			maid:Add(function()
				if postSimulationConnection then
					postSimulationConnection:Disconnect()
					postSimulationConnection = nil
				end
			end)

			local function updateAnchorState()
				local v7 = v5.Enabled and v5.Part1 ~= nil

				if not v7 then
					for _, v9 in ipairs(v6) do
						if not v9.Part1 then
							continue
						end

						v7 = true
						break
					end
				end

				if v7 then
					if postSimulationConnection then
						postSimulationConnection:Disconnect()
						postSimulationConnection = nil
					end

					if primaryPart.Anchored then
						object.AnimalModel:PivotTo(object.Instance:GetPivot())
						primaryPart.Anchored = false
					end
				else
					primaryPart.Anchored = true
					object.AnimalModel:PivotTo(object.Instance:GetPivot())

					if not postSimulationConnection then
						postSimulationConnection = RunService.PostSimulation:Connect(function()
							if object.Instance.Parent then
								object.AnimalModel:PivotTo(object.Instance:GetPivot())
							end
						end)
					end
				end
			end

			updateAnchorState()
			maid:Add(object.Instance:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
				v5.Part1 = object.Instance.PrimaryPart
				updateAnchorState()
			end))
			maid:Add(v5:GetPropertyChangedSignal("Part1"):Connect(updateAnchorState))

			local function updateClientWeld(child2)
				if child2.Name ~= "CreateClientWeld" then
					return
				end

				local weld = Instance.new("Weld")
				weld.Name = "Weld"
				weld.Part0 = primaryPart
				table.insert(v6, weld)
				local v7 = { Observers.observeProperty(child2, "Value", function(part)
						weld.Part1 = part
						updateAnchorState()
						return nil
					end), Observers.observeAttribute(child2, "C0", function(C0)
						weld.C0 = C0
						return nil
					end), Observers.observeAttribute(child2, "C1", function(C1)
						weld.C1 = C1
						return nil
					end) }
				weld.Parent = primaryPart
				v5.Enabled = false
				updateAnchorState()
				child2.Destroying:Once(function()
					local index = table.find(v6, weld)

					if index then
						table.remove(v6, index)
					end

					weld:Destroy()
					local v8 = false

					for _, child3 in object.Instance:GetChildren() do
						if not (child3.Name == "CreateClientWeld" and child3 ~= child2) then
							continue
						end

						v8 = true
						break
					end

					if not v8 then
						object.AnimalModel:PivotTo(object.Instance:GetPivot())
						v5.Enabled = true
					end

					updateAnchorState()

					for _, v10 in v7 do
						v10()
					end
				end)
			end

			maid:Add(object.Instance.ChildAdded:Connect(function(child2)
				updateClientWeld(child2)
			end))

			for _, child2 in object.Instance:GetChildren() do
				maid:Add(task.spawn(updateClientWeld, child2))
			end
		end

		maid:Add(animalTraits:Observe({ "traits", object.UID }, updateTraits))
	end

	object.Collector:Add(object.Instance:GetAttributeChangedSignal("Index"):Connect(buildVisual))
	object.Collector:Add(task.spawn(buildVisual))
	return object
end

function AnimalClient:Destroy()
	self.Collector:Destroy()
end

return AnimalClient