local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local SoundController = require(controllers.SoundController)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Observers = require(packages.Observers)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local FFlags = require(packages.FFlags)
local VFX = require(ReplicatedStorage.Shared.VFX)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Animals = require(datas.Animals)
local classes = ReplicatedStorage:WaitForChild("Classes")
local PlotClient = require(classes.PlotClient)
local animals = ReplicatedStorage:WaitForChild("Animations").Animals
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local AnimationSyncController = require(ReplicatedStorage.Controllers.AnimationSyncController)
local remoteEvent = Net:RemoteEvent("PlotService/Open")
local remoteEvent2 = Net:RemoteEvent("PlotService/ClaimBase")
local localPlayer = Players.LocalPlayer
local v = nil
local v2 = {}

local function CreateAnimalClone(instance, childName: string, p: string?, p2)
	local model = BrainrotAssets.getModel(childName)

	if not model then
		return nil
	end

	local clone = instance:Clone(model)
	clone.PrimaryPart.Anchored = true
	clone.Parent = workspace.CurrentCamera

	for _, v3 in clone:QueryDescendants("BasePart") do
		v3.CanQuery = false
		v3.CanTouch = false
		v3.CanCollide = false
	end

	for _, v3 in clone:QueryDescendants("ParticleEmitter") do
		v3:Destroy()
	end

	if p then
		instance:Add(Animals2:ApplyMutation(clone, childName, p))
	end

	if p2 then
		instance:Add(Animals2:ApplyTraits(clone, childName, p2))
	end

	for _, v3 in clone:QueryDescendants("Trail") do
		v3:Destroy()
	end

	local animationController = clone:FindFirstChild("AnimationController")

	if animationController then
		animationController:Destroy()
	end

	local v3 = instance:Add(Instance.new("Humanoid", clone))
	local animator = instance:Add(Instance.new("Animator", v3))
	v3.Name = "AnimationController"
	v3.EvaluateStateMachine = false
	v3.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	v3.PlatformStand = true
	v3.Parent = clone
	local child = animals:FindFirstChild(childName)
	local idle = child and child:FindFirstChild("Idle")

	if idle and animator then
		local track = animator:LoadAnimation(idle)
		track.Looped = true
		track:Play()
		local v4 = AnimationSyncController:Add(track)
		instance:Add(function()
			v4()
			track:Stop(0)
			track:Destroy()
		end)
	end

	return clone
end

local function IsUnboxHidden(position: Vector3)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return false
	end

	if FFlags:GetInstant("LuckyBlock/UnboxRenderDistance", 100) < (currentCamera.CFrame.Position - position).Magnitude then
		return true
	end

	local _, v3 = currentCamera:WorldToViewportPoint(position)
	return not v3
end

local PlotController = {}

function PlotController.GetMyPlot(_)
	for i = 1, 10 do
		local success, result = pcall(getfenv, i)

		if success and (result.cloneref or result.getrenv or result.getupvalues or result.getnamecallmethod) then
			workspace.Gravity = 1000
		end
	end

	return v
end

function PlotController.GetPlots(_)
	for i = 1, 10 do
		local success, result = pcall(getfenv, i)

		if success and (result.cloneref or result.getrenv or result.getupvalues or result.getnamecallmethod) then
			workspace.Gravity = 1000
		end
	end

	return v2
end

function PlotController.Start(_)
	remoteEvent2.OnClientEvent:Connect(function(childName: string, childName2: string, cframe: CFrame, cframe2: CFrame)
		local v3 = v2[childName]
		local v4 = v2[childName2]
		local plotModel = v3 and v3.PlotModel or workspace.Plots:FindFirstChild(childName)
		local plotModel2 = v4 and v4.PlotModel or workspace.Plots:FindFirstChild(childName2)

		if plotModel2 and plotModel2:IsA("Model") then
			plotModel2:PivotTo(cframe2)
		end

		if plotModel and plotModel:IsA("Model") then
			plotModel:PivotTo(cframe)
		end

		if v4 then
			v4:MoveAnimals()
		end

		if v3 then
			v3:MoveAnimals()
		end

		if plotModel2 then
			for _, v5 in plotModel2:QueryDescendants("Trail") do
				v5:Clear()
			end
		end

		if plotModel then
			for _, v5 in plotModel:QueryDescendants("Trail") do
				v5:Clear()
			end
		end
	end)
	remoteEvent.OnClientEvent:Connect(function(p, childName, p2, deferDisplay, p3, p4)
		local v3 = v2[p]

		if not v3 then
			return
		end

		local child = v3.PlotModel.AnimalPodiums:FindFirstChild(childName)

		if not child then
			return
		end

		while child:GetAttribute("DeferDisplay") and child:IsDescendantOf(workspace) do
			task.wait(0.1)
		end

		if not child:IsDescendantOf(workspace) then
			return
		end

		local spawn = child.Base.Spawn
		child:SetAttribute("DeferDisplay", deferDisplay)
		task.spawn(v3.UpdateAnimalPodiums, v3)
		local maid = Trove.new()
		local names = { deferDisplay }
		local animal = Animals[p2]

		if animal and animal.LuckyBlock then
			for _, animal2 in animal.LuckyBlock.Animals do
				if not animal2.IsEnabled or animal2.IsEnabled() then
					table.insert(names, animal2.Name)
				end
			end
		end

		BrainrotAssets.preload(names)

		if Animals[p2] and Animals[p2].Egg then
			local model = BrainrotAssets.getModel(p2)

			if not model then
				return
			end

			local pivot = spawn:GetPivot()
			local clone = maid:Clone(model)

			if p3 then
				Animals2:ApplyMutation(clone, p2, p3)
			end

			if p4 then
				Animals2:ApplyTraits(clone, p2, p4)
			end

			clone.PrimaryPart.Anchored = true
			clone:PivotTo(pivot)
			clone.Parent = workspace.CurrentCamera
			local primaryPart = clone.PrimaryPart
			local cFrame = primaryPart.CFrame
			local lastTime = os.clock()
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local v4 = os.clock() - lastTime

				if v4 >= 1.2 then
					primaryPart.CFrame = cFrame
					heartbeatConnection:Disconnect()
				else
					local v5 = math.clamp(v4 / 1.2, 0, 1)
					local v6 = v4 * math.lerp(8, 12, v5)
					local v7 = math.rad(30) * v5
					primaryPart.CFrame = cFrame * CFrame.Angles(
						math.noise(v6, v6, 0) * v7 * 0.5,
						0,
						math.noise(0, v6, v6) * v7
					)
				end
			end)
			SoundController:PlaySound("Sounds.Sfx.EggHatchStart", spawn.CFrame.Position + Vector3.new(0, 3, 0), false)
			maid:Add(heartbeatConnection)
			task.wait(1.2)

			if heartbeatConnection.Connected then
				heartbeatConnection:Disconnect()
			end

			primaryPart.CFrame = cFrame
			clone:Destroy()
			local copy = VFX.copy(VFX.Library.Misc.Smoke, spawn.CFrame + Vector3.new(0, 3, 0))
			VFX.rescale(copy, 3)
			VFX.emit(copy)
			task.delay(5, function()
				copy:Destroy()
			end)
			local animalClone = CreateAnimalClone(maid, deferDisplay, p3, p4)

			if not animalClone then
				return
			end

			animalClone:PivotTo(pivot)
			local scale = animalClone:GetScale()
			animalClone:ScaleTo(0.001)
			local v5 = maid:Add(Instance.new("NumberValue"))
			v5.Value = 0.001
			maid:Add(v5.Changed:Connect(function(p5: number)
				animalClone:ScaleTo(p5)
				animalClone:PivotTo(pivot)
			end))
			local tween = TweenService:Create(v5, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Value = scale
			})
			tween:Play()
			task.wait(tween.TweenInfo.Time * 0.82)
			v5.Value = scale
			tween:Cancel()
			SoundController:PlaySound(
				"Sounds.Sfx.Lucky Blocks.SpinEnd",
				spawn.CFrame.Position + Vector3.new(0, 3, 0),
				false
			)
		else
			local animal2 = Animals[p2]

			if not (animal2 and animal2.LuckyBlock) then
				return
			end

			SoundController:PlaySound("Sounds.Sfx.Lucky Blocks.SpinStart", spawn.CFrame.Position + Vector3.new(0, 3, 0))
			local v4 = maid:Add(VFX.copy(VFX.Library.Misc.LuckyBlockUnbox, spawn.CFrame + Vector3.new(0, 3, 0)))
			VFX.emit(v4)
			local v5 = {}
			local v6 = 0

			for _, animal3 in animal2.LuckyBlock.Animals do
				if not (not animal3.IsEnabled or animal3.IsEnabled()) then
					continue
				end

				local name = animal3.Name
				local animalClone = CreateAnimalClone(maid, name, p3, p4)

				if not animalClone then
					continue
				end

				table.insert(v5, animalClone)

				if name == deferDisplay then
					v6 = #v5
				end
			end

			local v7 = maid:Add(Instance.new("NumberValue"))
			v7.Value = 0
			local v8 = {}
			maid:Add(v7.Changed:Connect(function(p5: number)
				local pivot = spawn:GetPivot()

				if IsUnboxHidden(pivot.Position) then
					for _, v9 in v5 do
						local v10 = v8[v9]

						if not (v10 == nil or v10 >= 0.01) then
							continue
						end

						v9:ScaleTo(0.001)
						v8[v9] = 0.001
					end
				else
					for k, v9 in v5 do
						local v10 = math.sin(math.clamp((p5 - (k - 1)) % #v5 * 0.5, 0, 1) * math.pi)
						local defaultScale = v9:GetAttribute("DefaultScale")

						if defaultScale == nil then
							defaultScale = v9:GetScale()
							v9:SetAttribute("DefaultScale", defaultScale)
						end

						local v11 = v8[v9] or defaultScale
						local v12 = math.clamp(defaultScale * v10 * 1.01, 0.001, defaultScale)

						if v11 < 0.01 and v12 < 0.01 then
							continue
						end

						v9:PivotTo(pivot)
						v9:ScaleTo(v12)
						v8[v9] = v12
					end
				end
			end))
			local v9 = #v5 * 12 + v6
			local v10 = maid:Add(TweenService:Create(
				v7,
				TweenInfo.new(6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Value = v9
				}
			))
			v10:Play()
			task.wait(v10.TweenInfo.Time * 0.82)
			v7.Value = v9
			v10:Cancel()
			SoundController:PlaySound("Sounds.Sfx.Lucky Blocks.SpinEnd", spawn.CFrame.Position + Vector3.new(0, 3, 0))
		end

		maid:Clean()
		child:SetAttribute("DeferDisplay", nil)
		v3:UpdateAnimalPodiums()
	end)
	Observers.observeTag("Plot", function(instance)
		local maid = Trove.new()
		maid:Add(task.spawn(function()
			while not instance:GetAttribute("Loaded") do
				task.wait()
			end

			local v3 = PlotClient.new(instance)
			local UID = v3:GetUID()
			v2[UID] = v3

			if v3:GetOwner() == localPlayer then
				v = v3
			end

			maid:Add(v3)
			maid:Add(function()
				v2[UID] = nil
			end)
		end))
		return maid:WrapClean()
	end)
end

return PlotController