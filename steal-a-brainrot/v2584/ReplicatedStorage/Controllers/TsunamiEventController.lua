local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Debounce = require(ReplicatedStorage.Packages.Debounce)
require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Controllers.ConfirmationController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local ShopController = require(ReplicatedStorage.Controllers.ShopController)
local TsunamiEventDebug = require(ReplicatedStorage.Shared.TsunamiEventDebug)
local TsunamiEventData = require(ReplicatedStorage.Shared.TsunamiEventData)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local remoteEvent = Net:RemoteEvent("TsunamiEventService/BuySpeedUpgrade")
Net:RemoteEvent("TsunamiEventService/ToggleSlowmode")
Net:RemoteEvent("TsunamiEventService/Teleport")
local remoteEvent2 = Net:RemoteEvent("TsunamiEventService/Kill")
local remoteEvent3 = Net:RemoteEvent("ShopService/Purchase")
local localPlayer = Players.LocalPlayer
local tsunamiSpeedUpgrade = localPlayer.PlayerGui:WaitForChild("TsunamiSpeedUpgrade").TsunamiSpeedUpgrade
local TsunamiEventController = {}
local v = nil

function TsunamiEventController.StartWaves(_)
	local v2 = ReplicatorClient.get("TsunamiEvent/Waves")
	local folder = Instance.new("Folder")
	folder.Name = "Waves"
	folder.Parent = workspace
	local v3 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeWave(k: string)
		local v4 = v3[k]

		if v4 then
			v4.model:Destroy()
			v3[k] = nil
		end
	end

	local function reconcileWaves()
		local v4 = v2:TryIndex({ "waves" })

		if not v4 then
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()

		for k, v5 in v4 do
			if v3[k] then
				continue
			end

			local clone = ReplicatedStorage.Models.TsunamiWaves[v5.name]:Clone()
			clone.Name = k
			clone:PivotTo(TsunamiEventData.getWavePositionAtTime(v5, serverTimeNow))
			local wavesLoop = clone:FindFirstChild("WavesLoop", true)

			if wavesLoop then
				wavesLoop.Looped = true
				wavesLoop:Play()
			end

			local C1 = clone.Main.CFrame:Inverse() * clone:GetPivot()
			local motor6D = Instance.new("Motor6D")
			motor6D.Part0 = workspace.Terrain
			motor6D.Part1 = clone.Main
			motor6D.C1 = C1
			motor6D.Parent = clone.Main
			clone.Main.Anchored = false
			clone.Parent = folder
			v3[k] = {
				model = clone,
				motor = motor6D
			}
		end

		for k in v3 do
			if v4[k] then
				continue
			end

			removeWave(k) -- equivalent call inferred; original call site unknown
		end
	end

	local v4 = 0
	RunService.PostSimulation:Connect(function(_: number)
		local v5 = v2:TryIndex({ "waves" })

		if not v5 then
			return
		end

		TsunamiEventDebug.clear()
		debug.profilebegin("updateWaves")
		local serverTimeNow = workspace:GetServerTimeNow()
		local transforms = {}
		local wavePositionAtTimes = {}

		for k, v6 in v3 do
			local v7 = v5[k]

			if not v7 then
				continue
			end

			if v7.despawnsAt <= serverTimeNow then
				removeWave(k) -- equivalent call inferred; original call site unknown
			else
				local wavePositionAtTime = TsunamiEventData.getWavePositionAtTime(v7, serverTimeNow)
				local transform = v6.motor.Transform

				if transform == CFrame.identity then
					transform = wavePositionAtTime
				end

				transforms[k] = transform
				wavePositionAtTimes[k] = wavePositionAtTime
				v6.motor.Transform = wavePositionAtTime
			end
		end

		debug.profileend()
		debug.profilebegin("playerKill")
		local character, v6 = CharacterController:GetCharacter(localPlayer)

		if not character or not v6 or v6.Health <= 0 then
			debug.profileend()
			return
		end

		local position = character:GetPivot().Position
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { (character:FindFirstChild("HumanoidRootPart")) }
		TsunamiEventDebug.drawHitbox(position)

		for k, v7 in v5 do
			if v7.despawnsAt <= serverTimeNow or serverTimeNow - v4 <= 1 then
				continue
			end

			local v8 = v3[k]

			if not v8 then
				continue
			end

			local v9 = transforms[k]
			local v10 = wavePositionAtTimes[k]

			if (v10.Position - position).Magnitude >= 300 then
				continue
			end

			local extentsSize = v8.model:GetExtentsSize()
			local v11 = v9 + Vector3.new(0, extentsSize.Y * 0.5, -extentsSize.Z * 0.5)
			local v12 = v10 + Vector3.new(0, extentsSize.Y * 0.5, -extentsSize.Z * 0.5)
			local sweptAABB, v13 = MathUtils.getSweptAABB(v11.Position, v12.Position, extentsSize)
			local v14 = CFrame.new(sweptAABB) * v12.Rotation
			TsunamiEventDebug.drawTsunami(v14, v13)

			if not MathUtils.isPointInVolume(position, v14, v13) then
				continue
			end

			v4 = serverTimeNow
			remoteEvent2:FireServer()
		end

		debug.profileend()
	end)
	v2:Observe({ "waves" }, reconcileWaves)
	task.spawn(reconcileWaves)
end

function TsunamiEventController.StartSpeedHandling(_)
	local v2 = Synchronizer:Wait(localPlayer)

	if not v2 then
		return
	end

	local clones = {}

	for k, upgrade in TsunamiEventData.upgrades do
		local clone = tsunamiSpeedUpgrade.Content.List.Template:Clone()
		clone.Name = tostring(k)
		clone.LayoutOrder = k
		clone.Frame.Label.Text = `+{upgrade} Speed`
		clone.Frame.Tip.Text = `+{upgrade}`
		clone.Visible = true
		clone.Parent = tsunamiSpeedUpgrade.Content.List
		clones[k] = clone
		local v3 = AnimatedButton.new(clone.Frame.Buy)
		v3:Animate()
		local v4 = k
		v3.OnActivated:Connect(function()
			remoteEvent:FireServer(v4)
		end)
		local product = TsunamiEventData.products[upgrade]
		local v5 = AnimatedButton.new(clone.Frame.BuyRobux)
		ShopController:BindLabelToProductPrice(clone.Frame.BuyRobux.Price, product, "Product")
		v5:Animate()
		v5.OnActivated:Connect(function()
			remoteEvent3:FireServer(product)
		end)
	end

	local function updateSpeedUpgrades()
		local v3 = v2:Get({ "TsunamiEvent", "SpeedUpgrades" })

		for k, upgrade in TsunamiEventData.upgrades do
			local v4 = clones[k]
			local upgradeCost = TsunamiEventData.getUpgradeCost(v3, upgrade)
			v4.Frame.Buy.Price.Text = `Buy (${NumberUtils:ToString(upgradeCost)})`
			v4.Frame.PreviousAmount.Text = NumberUtils:Comma(TsunamiEventData.getTotalSpeed(v3))
			v4.Frame.TargetAmount.Text = NumberUtils:Comma(TsunamiEventData.getTotalSpeed(v3 + upgrade))
			local target = Spr.target
			local buy = v4.Frame.Buy
			local backgroundColor

			if upgradeCost <= v2:Get("Coins") then
				backgroundColor = Color3.fromRGB(81, 158, 86)
			else
				backgroundColor = Color3.fromRGB(158, 158, 158)
			end

			target(buy, 1, 5, {
				BackgroundColor3 = backgroundColor
			})
		end
	end

	v2:OnChanged({ "TsunamiEvent", "SpeedUpgrades" }, updateSpeedUpgrades)
	v2:OnChanged("Coins", updateSpeedUpgrades)
	task.spawn(updateSpeedUpgrades)
end

function TsunamiEventController.StartVIPAreas(_)
	local v2 = Synchronizer:Wait(localPlayer)

	if not v2 then
		return
	end

	local v3 = nil

	local function updateVIPAreas()
		if typeof(v3) == "function" then
			v3()
			v3 = nil
		end

		local v4 = v2:Get("Gamepass.VIP") == true
		v3 = Observers.observeTag("VIPAreas", function(p)
			p.CanCollide = not v4
			p.CanTouch = not v4
			local touchedConnection

			if v4 then
				touchedConnection = nil
			else
				touchedConnection = p.Touched:Connect(function(otherPart)
					if Players:GetPlayerFromCharacter(otherPart.Parent) == localPlayer and not Debounce(
						"VIPAreaTouch",
						1
					) then
						remoteEvent3:FireServer(1229510262)
					end
				end)
			end

			return function()
				p.CanCollide = true
				p.CanTouch = true

				if touchedConnection then
					touchedConnection:Disconnect()
				end
			end
		end)
	end

	v2:OnChanged("Gamepass.VIP", updateVIPAreas)
	v2:OnDictionaryInserted("Gamepass", updateVIPAreas)
	task.spawn(updateVIPAreas)
end

local WorldBrainrotController = require(ReplicatedStorage.Controllers.WorldBrainrotController)
local renderedBrainrots = {}

function TsunamiEventController.StartBrainrotRendering(_)
	WorldBrainrotController:RenderPool({
		PoolId = "TsunamiEvent/Brainrots",
		ReplicatorId = "TsunamiEvent/Brainrots",
		ShowTimer = true,
		ShowDropButton = true,
		GrabHoldDuration = 2,
		GrabMaxDistance = 10,
		RenderedBrainrots = renderedBrainrots
	})
end

function TsunamiEventController:GetBrainrot(p: string)
	return ReplicatorClient.get("TsunamiEvent/Brainrots"):TryIndex({ "brainrots", p })
end

function TsunamiEventController.GetBrainrotCFrame(_, p: string, flag: boolean?)
	local brainrot = TsunamiEventController:GetBrainrot(p)

	if not (brainrot and renderedBrainrots[p]) then
		return nil, nil
	end

	local model = renderedBrainrots[p].model

	if not model then
		return nil, nil
	end

	if flag then
		return brainrot.cframe, model
	end

	local part = brainrot.grabbed and CollectionService:GetTags((`Held_{brainrot.grabbed}`))[1]

	if not part then
		return brainrot.cframe, model
	end

	local v3

	if part:IsA("BasePart") or not part.PrimaryPart then
		v3 = part:GetPivot()
	else
		v3 = part.PrimaryPart.CFrame
	end

	return v3 + Vector3.new(0, (BrainrotAssets.getSize(brainrot.brainrot) or createVector(0, 0, 0)).Y * 0.5, 0), model
end

function TsunamiEventController:StartNormalServer() end

function TsunamiEventController.Start(_)
	if not ServerData.IsTsunamiServer() then
		TsunamiEventController:StartNormalServer()
		return
	end

	v = InterfaceController:Register("TsunamiSpeedUpgrade", tsunamiSpeedUpgrade, "TopQuint")
	v:AttachCloseButton(tsunamiSpeedUpgrade.Header.Close)
	v:Close()

	if not Synchronizer:Wait(localPlayer) then
		return
	end

	task.spawn(TsunamiEventController.StartSpeedHandling, TsunamiEventController)
	task.spawn(TsunamiEventController.StartVIPAreas, TsunamiEventController)
	task.spawn(TsunamiEventController.StartWaves, TsunamiEventController)
	task.spawn(TsunamiEventController.StartBrainrotRendering, TsunamiEventController)
end

return TsunamiEventController