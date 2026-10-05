local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local StatsFetch = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.StatsFetch)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local RigEffectScale = require(ReplicatedStorage.CAM.Global.RigEffectScale)
local TitleParticles = require(ReplicatedStorage.CAM.Client.Modules.TitleParticles)
local RunService = game:GetService("RunService")
local names = {}
local modulesByName = {}
local v = {}
local v2 = {}

for _, moduleScript in script:GetChildren() do
	table.insert(names, moduleScript.Name)
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

local uDim = UDim2.fromScale(4, 1.5)

local function overheadMetrics(parent, adornee)
	if not (adornee ~= nil and Players:GetPlayerFromCharacter(parent) == nil) then
		return 3.4, uDim
	end

	local success, result, v3 = pcall(RigEffectScale.BodyBox, parent)

	if not success or typeof(result) ~= "Vector3" or typeof(v3) ~= "Vector3" then
		return 3.4, uDim
	end

	local v4 = v3 - result
	local overheadOffset = parent:GetAttribute("OverheadOffset")
	local overheadHeadGap = parent:GetAttribute("OverheadHeadGap")

	if type(overheadOffset) ~= "number" then
		if type(overheadHeadGap) == "number" then
			local overheadTopMargin = parent:GetAttribute("OverheadTopMargin")
			local v5 = type(overheadTopMargin) ~= "number" and 1 or overheadTopMargin
			overheadOffset = math.max(overheadHeadGap + 1.2 + v5, 3.4)
		else
			overheadOffset = math.max(v3.Y - adornee.Position.Y + 1.2, 3.4)
		end
	end

	local v5 = math.clamp(v4.Y / 6, 1, 1.75)
	return overheadOffset, UDim2.fromScale(uDim.X.Scale * v5, uDim.Y.Scale * v5)
end

function CreateBillboard(parent, adornee, flag: boolean?)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "OverHead"
	billboardGui.MaxDistance = 200
	billboardGui.LightInfluence = 0
	billboardGui.AlwaysOnTop = flag == true
	local v3, size = overheadMetrics(parent, adornee)
	billboardGui.Size = size
	billboardGui.Adornee = adornee
	billboardGui.Parent = parent
	billboardGui.StudsOffsetWorldSpace = vector.create(0, v3, 0)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = billboardGui
	frame.Name = "Holder"
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 1
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "List"
	uIListLayout.Parent = frame
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.SortOrder = Enum.SortOrder.Name
	return frame
end

ReplicatedStorage:WaitForChild("CAM")
local overhead = ReplicatedStorage.CAM.Client.Components.Layout.Visibility.Overhead

-- equivalent calls inferred from this helper; original call sites unknown
local function componentVisible(childName: string)
	if overhead.All.Value ~= true then
		return false
	end

	local child = overhead:FindFirstChild(childName)
	return child == nil or child.Value == true
end

function updateVisibilities()
	for _, v3 in v do
		for _, v4 in names do
			local v5 = componentVisible(v4) -- equivalent call inferred; original call site unknown
			v3(v4, v5)
		end
	end
end

for _, child in ipairs(overhead:GetChildren()) do
	child.Changed:Connect(updateVisibilities)
end

updateVisibilities()

function Added(instance)
	if instance:GetAttribute("NoOverhead") == true then
		task.spawn(function()
			local humanoid = instance:WaitForChild("Humanoid", 9999)

			if humanoid == nil then
				return
			end

			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		end)
		return
	end

	if v2[instance] ~= nil then
		Removed(instance)
	end

	local maid = cleanit.new()
	v2[instance] = maid
	maid:Add(task.spawn(function()
		local humanoid = instance:WaitForChild("Humanoid", 9999)
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 9999)

		if humanoid == nil or humanoidRootPart == nil or instance.Parent == nil then
			return
		end

		local v3 = instance == Players.LocalPlayer.Character

		if humanoidRootPart.Parent == nil or instance.Parent == nil then
			return
		end

		local v4 = CreateBillboard(instance, humanoidRootPart, v3)
		maid:Add(v4.Parent)
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		local v5 = {}
		maid:Add(function()
			for _, v6 in v5 do
				v6()
			end

			table.clear(v5)
		end)
		local v6 = {}

		if v3 then
			v6.Health = true
			v6._Name = true
			v6.AFaction = true
			v6.Debuffs = true
		end

		local v7 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateVisibility(p: string, flag: boolean)
			if v6[p] then
				flag = false
			end

			if v7[p] ~= flag then
				if v5[p] then
					v5[p]()
				end

				v7[p] = flag

				if flag == true then
					v5[p] = modulesByName[p](v4, instance, humanoid, humanoidRootPart, maid)
				end
			end
		end

		v[instance] = updateVisibility

		for _, v8 in names do
			updateVisibility(v8, componentVisible(v8)) -- equivalent call inferred; original call site unknown
		end

		if not v3 then
			local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
			local getvaluesfolder = Utility.getvaluesfolder(instance)
			local v8 = nil

			local function refreshInvis()
				local v9 = getvaluesfolder and (getvaluesfolder:FindFirstChild("Invisibility") ~= nil or getvaluesfolder:FindFirstChild("Transparent") ~= nil) and true or false
				local v10 = not v9 and playerFromCharacter and StatsFetch.HasInvisibility(instance) == true and true or v9

				if v10 == v8 then
					return
				end

				v8 = v10
				v6.Health = v10
				v6._Name = v10
				v6.Debuffs = v10
				v6.AFaction = v10
				v6.VanityTitle = v10
				v6.Reputation = v10

				for _, v11 in {
					"Health",
					"_Name",
					"Debuffs",
					"AFaction",
					"VanityTitle",
					"Reputation"
				} do
					updateVisibility(v11, componentVisible(v11)) -- equivalent call inferred; original call site unknown
				end
			end

			if getvaluesfolder then
				maid:Add(getvaluesfolder.ChildAdded:Connect(function(child)
					if child.Name == "Invisibility" or child.Name == "Transparent" then
						refreshInvis()
					end
				end))
				maid:Add(getvaluesfolder.ChildRemoved:Connect(function(child)
					if child.Name == "Invisibility" or child.Name == "Transparent" then
						refreshInvis()
					end
				end))
			end

			if playerFromCharacter then
				local function hookSHC(instance2)
					maid:Add(instance2:GetPropertyChangedSignal("Value"):Connect(refreshInvis))
					maid:Add(instance2:GetAttributeChangedSignal("last_performed"):Connect(refreshInvis))
				end

				local SHC = instance:FindFirstChild("SHC") or instance:FindFirstChild("SHCS")

				if SHC then
					hookSHC(SHC)
				else
					local childAddedConnection = nil
					childAddedConnection = instance.ChildAdded:Connect(function(child)
						if child.Name == "SHC" or child.Name == "SHCS" then
							if childAddedConnection then
								childAddedConnection:Disconnect()
								childAddedConnection = nil
							end

							hookSHC(child)
							refreshInvis()
						end
					end)
					maid:Add(childAddedConnection)
				end
			end

			refreshInvis()
		end
	end))
end

function Removed(p)
	if v[p] then
		v[p] = nil
	end

	if v2[p] then
		v2[p]:Destroy()
		v2[p] = nil
	end
end

for _, v3 in CollectionService:GetTagged("Humanoids") do
	Added(v3)
end

CollectionService:GetInstanceAddedSignal("Humanoids"):Connect(Added)
CollectionService:GetInstanceRemovedSignal("Humanoids"):Connect(Removed)
local renderSteppedConnection = nil

local function runPromoted()
	for _, runner in TitleParticles.Runners do
		if runner.Promoted then
			runner:Run()
		end
	end
end

local function tickTitleParticles()
	local currentCamera = workspace.CurrentCamera
	local v3 = false

	for k, runner in TitleParticles.Runners do
		if k.Parent == nil or runner.Root.Parent == nil then
			TitleParticles.Remove(k)
		else
			runner.Promoted = currentCamera ~= nil and (k == Players.LocalPlayer.Character or (currentCamera.CFrame.Position - runner.Root.Position).Magnitude <= TitleParticles.PROMOTE_DISTANCE)

			if runner.Promoted then
				v3 = true
			else
				runner:Run()
			end
		end
	end

	if v3 and renderSteppedConnection == nil then
		renderSteppedConnection = RunService.RenderStepped:Connect(runPromoted)
	elseif not v3 and renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

task.spawn(function()
	while true do
		tickTitleParticles()
		task.wait(TitleParticles.TICK)
	end
end)