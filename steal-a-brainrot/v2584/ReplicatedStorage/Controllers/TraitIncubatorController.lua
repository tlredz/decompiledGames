local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Debounce = require(ReplicatedStorage.Packages.Debounce)
local Animals = require(ReplicatedStorage.Datas.Animals)
local Traits = require(ReplicatedStorage.Datas.Traits)
require(ReplicatedStorage.Shared.Updates)
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("TraitIncubatorService/Place")
local remoteEvent2 = Net:RemoteEvent("TraitIncubatorService/Swap")
local remoteEvent3 = Net:RemoteEvent("TraitIncubatorService/Grab")
local TraitIncubatorController = {
	IsEnabled = function(self)
		return FFlags:GetInstant("TraitIncubatorEnabled", true) and not ServerData.IsDuelsServer() and not (ServerData.IsTsunamiServer() or ServerData.IsTradePlaza()) and false
	end,
	GetIncubatorEgg = function(self)
		local v = Synchronizer:Get(localPlayer)

		if v then
			return v:Get("EasterEvent.IncubatorEgg")
		end

		return nil
	end
}

local function canIncubate(stealingIndex: string)
	local instant = FFlags:GetInstant("TraitIncubator/AcceptedBrainrots", { "Egg Lucky Block" })

	for _, v in instant do
		if stealingIndex == v then
			return true
		end
	end

	local animal = Animals[stealingIndex]

	if animal and animal.Egg ~= nil then
		return true
	end

	return false
end

local v = nil
local v2 = nil
local heartbeatConnection = nil
local v3 = false
local v4 = nil
local v5 = nil
local now = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function buildStateKey(incubatorEgg, grabbingIncubatorEgg: boolean, traitIncubatorActive: boolean)
	if not incubatorEgg then
		return (`{grabbingIncubatorEgg}{traitIncubatorActive}`)
	end

	local v6 = not (incubatorEgg.Traits and #incubatorEgg.Traits > 0) and "" or table.concat(incubatorEgg.Traits, "")
	return (`{incubatorEgg.Index}{incubatorEgg.Mutation or ""}{v6}{grabbingIncubatorEgg}{traitIncubatorActive}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAnimation()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v2 then
		v2:Destroy()
		v2 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startAnimation(motor6D)
	stopAnimation() -- equivalent call inferred; original call site unknown
	v2 = motor6D
	local total = 0
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if motor6D.Parent then
			local v6 = total * 0.7853981633974483
			local v7 = math.sin(total * 1.5) * 0.5
			motor6D.Transform = CFrame.new(0, v7, 0) * CFrame.Angles(0, v6, 0)
		else
			stopAnimation() -- equivalent call inferred; original call site unknown
		end
	end)
end

local function updateVisuals()
	local incubatorMachine = workspace:FindFirstChild("IncubatorMachine")

	if not incubatorMachine then
		return
	end

	local machine = incubatorMachine:FindFirstChild("Machine")

	if not machine then
		return
	end

	local screen = machine:FindFirstChild("Screen")
	local glass = machine:FindFirstChild("Glass")
	local eggPlacement = incubatorMachine:FindFirstChild("EggPlacement")
	local incubatorEgg = TraitIncubatorController:GetIncubatorEgg()
	local grabbingIncubatorEgg = localPlayer:GetAttribute("GrabbingIncubatorEgg") == true
	local v6

	if incubatorEgg == nil then
		v6 = false
	else
		v6 = not grabbingIncubatorEgg
	end

	local traitIncubatorActive = ReplicatedStorage:GetAttribute("TraitIncubatorActive") == true
	local v7 = v6 and traitIncubatorActive

	if v7 ~= v3 then
		v3 = v7
		local position = incubatorMachine:GetPivot().Position

		if v7 then
			SoundController:PlaySound("Sounds.Events.Easter.IncubatorOn", position, false)

			if not v4 and eggPlacement then
				local clone = ReplicatedStorage.Sounds.Events.Easter.IncubatorAmbient:Clone()
				clone.Parent = eggPlacement
				clone:Play()
				v4 = clone
			end
		else
			SoundController:PlaySound("Sounds.Events.Easter.IncubatorOff", position, false)

			if v4 then
				v4:Stop()
				v4:Destroy()
				v4 = nil
			end
		end
	end

	local stateKey = buildStateKey(incubatorEgg, grabbingIncubatorEgg, traitIncubatorActive) -- equivalent call inferred; original call site unknown

	if stateKey == v5 then
		return
	end

	v5 = stateKey

	if v6 and incubatorEgg then
		local index = incubatorEgg.Index

		if v and v:GetAttribute("BrainrotIndex") ~= index then
			stopAnimation() -- equivalent call inferred; original call site unknown
			v:Destroy()
			v = nil
		end

		if not v and eggPlacement then
			local animatedModel = Animals2:GetAnimatedModel(index, "Idle")

			if animatedModel and (v5 ~= stateKey or v or not eggPlacement.Parent) then
				animatedModel:Destroy()
				animatedModel = nil
			end

			if animatedModel then
				animatedModel:SetAttribute("BrainrotIndex", index)
				animatedModel:ScaleTo(animatedModel:GetScale() * 0.5)
				local mutation = incubatorEgg.Mutation

				if mutation and mutation ~= "Default" then
					Animals2:ApplyMutation(animatedModel, index, mutation)
				end

				local primaryPart = animatedModel.PrimaryPart or animatedModel:FindFirstChildWhichIsA("BasePart")

				if primaryPart then
					primaryPart.Anchored = false
					local _, v8 = animatedModel:GetBoundingBox()
					local motor6D = Instance.new("Motor6D")
					motor6D.Part0 = eggPlacement
					motor6D.Part1 = primaryPart
					motor6D.C0 = CFrame.new(0, v8.Y / 2, 0)
					motor6D.C1 = CFrame.new()
					motor6D.Parent = eggPlacement

					for _, part in animatedModel:GetDescendants() do
						if part:IsA("BasePart") and part ~= primaryPart then
							part.Anchored = false
						end
					end

					animatedModel.Parent = incubatorMachine
					v = animatedModel
					startAnimation(motor6D) -- equivalent call inferred; original call site unknown
				else
					animatedModel:PivotTo(eggPlacement:GetPivot())
					animatedModel.Parent = incubatorMachine
					v = animatedModel
				end
			end
		end

		if v then
			local traits = incubatorEgg.Traits

			if traits and #traits > 0 then
				Animals2:ApplyTraits(v, index, traits)
			end
		end
	else
		stopAnimation() -- equivalent call inferred; original call site unknown

		if v then
			v:Destroy()
			v = nil
		end
	end

	local overhead = incubatorMachine:FindFirstChild("Overhead")
	local traits = overhead and overhead.BillboardGui.Traits
	local template = traits and traits:FindFirstChild("Template")

	if template then
		for _, child in traits:GetChildren() do
			if child ~= template and child:IsA(template.ClassName) then
				child:Destroy()
			end
		end

		if v6 and incubatorEgg then
			local traits2 = incubatorEgg.Traits

			if traits2 and #traits2 > 0 then
				for _, trait in traits2 do
					local trait2 = Traits[trait]

					if not trait2 then
						continue
					end

					local clone = template:Clone()
					clone.Image = trait2.Icon
					clone.Visible = true
					clone.Parent = traits
				end
			end
		end

		local visible

		if v6 then
			if incubatorEgg == nil or incubatorEgg.Traits == nil then
				visible = false
			else
				visible = #incubatorEgg.Traits > 0
			end
		else
			visible = v6
		end

		traits.Visible = visible
	end

	if screen then
		local color

		if v7 then
			color = Color3.fromRGB(0, 175, 0)
		else
			color = Color3.fromRGB(200, 0, 0)
		end

		screen.Color = color
		local statusText = screen:FindFirstChild("StatusText", true)
		local surfaceGui = statusText and statusText:FindFirstChildWhichIsA("SurfaceGui")
		local textLabel = surfaceGui and surfaceGui:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.Text = v7 and "ACTIVE" or "OFF"
		end
	end

	if glass then
		if v6 and v7 then
			VFX.enable(glass)
		else
			VFX.disable(glass)
		end
	end
end

function TraitIncubatorController.Start(_)
	if not TraitIncubatorController:IsEnabled() then
		return
	end

	Observers.observeTag("TraitIncubatorDeliveryHitbox", function(p)
		local touchedConnection = p.Touched:Connect(function(otherPart)
			if not (TraitIncubatorController:IsEnabled() and otherPart.Parent) then
				return
			end

			local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

			if not playerFromCharacter or playerFromCharacter ~= localPlayer then
				return
			end

			local stealingIndex = playerFromCharacter:GetAttribute("StealingIndex")

			if not stealingIndex or Debounce("TraitIncubator/Delivery", 1) or os.clock() - now < 5 or not canIncubate(stealingIndex) then
				return
			end

			if TraitIncubatorController:GetIncubatorEgg() then
				remoteEvent2:FireServer()
			else
				remoteEvent:FireServer()
			end

			local incubatorMachine = workspace:FindFirstChild("IncubatorMachine")

			if incubatorMachine then
				SoundController:PlaySound(
					"Sounds.Events.Easter.IncubatorDeposit",
					incubatorMachine:GetPivot().Position,
					false
				)
			end
		end)
		return function()
			touchedConnection:Disconnect()
		end
	end, { workspace })
	Observers.observeTag("TraitIncubatorPrompt", function(p)
		local maid = Trove.new()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateGrabPrompt()
			local incubatorEgg = TraitIncubatorController:GetIncubatorEgg()
			local stealing = localPlayer:GetAttribute("Stealing") == true
			p.Enabled = incubatorEgg ~= nil and not stealing
		end

		maid:Add(p.Triggered:Connect(function()
			if Debounce("TraitIncubator/Grab", 1) then
				return
			end

			remoteEvent3:FireServer()
			now = os.clock()
		end))
		maid:Add(localPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
			updateGrabPrompt() -- equivalent call inferred; original call site unknown
		end))
		maid:Add(localPlayer:GetAttributeChangedSignal("GrabbingIncubatorEgg"):Connect(function()
			updateVisuals()
		end))
		maid:Add(ReplicatedStorage:GetAttributeChangedSignal("TraitIncubatorActive"):Connect(function()
			task.spawn(updateVisuals)
		end))
		Synchronizer:WaitAndCall(localPlayer, function(object)
			object:OnChanged("EasterEvent.IncubatorEgg", function()
				v5 = nil

				if v then
					stopAnimation() -- equivalent call inferred; original call site unknown
					v:Destroy()
					v = nil
				end

				task.spawn(updateVisuals)
				task.spawn(updateGrabPrompt)
			end, true)
			object:OnChanged("EasterEvent.IncubatorEgg.Traits", function()
				task.spawn(updateVisuals)
				task.spawn(updateGrabPrompt)
			end)
		end)
		return maid:WrapClean()
	end, { workspace })
end

return TraitIncubatorController