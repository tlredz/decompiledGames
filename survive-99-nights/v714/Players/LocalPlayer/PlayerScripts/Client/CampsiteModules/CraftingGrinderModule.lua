local createVector = vector.create
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CraftingGrinderModule = {}
local RunService = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local removeTable = require(ReplicatedStorage.Modules.UtilityAlec.removeTable)
Random.new()
local v = {}
local v2 = nil
local v3 = {
	1,
	3,
	5,
	8
}
local clones = {}
local clones2 = {}
local v4 = nil
local v5 = nil
local clone = nil

function GetParticlesForGrinder()
	local function GetLevel(instance)
		local v6 = 1

		for i = 1, #v3 do
			if not (instance:GetAttribute("Scrappable") and instance:GetAttribute("Scrappable") >= v3[i]) then
				continue
			end

			v6 = i
		end

		return v6
	end

	local v6 = 0
	local v7 = nil

	for _, v8 in pairs(clones2) do
		local level = GetLevel(v8)

		if not (v6 < level) then
			continue
		end

		v7 = v8
		v6 = level
	end

	if not v7 then
		for _, v8 in pairs(clones) do
			v8:Destroy()
		end
	end

	if (not v5 or v7 ~= v5) and v6 and v6 > 0 and (not v4 or v4 < v6) then
		v4 = v6
		v5 = v7
		local scrapperParticles = workspace.Map.Campground.Scrapper.ScrapperParticles
		local folder = ReplicatedStorage.Assets.Particles.GrinderLevels:FindFirstChild("ScrapperEmissionPart" .. math.clamp(
			v6,
			1,
			4
		))

		if localPlayer:GetAttribute("Class") and localPlayer:GetAttribute("Class") == "Engineer" and not clone then
			clone = ReplicatedStorage.Assets.Particles.Engineer.EngineerGrindEffect:Clone()

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			clone:PivotTo(scrapperParticles.Parent.GlowEffect:GetPivot())
			clone.Parent = workspace.Particles
		end

		for _, emitter in pairs(folder:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") or emitter.Parent.Name == "GlowEffect") then
				continue
			end

			local clone2 = emitter:Clone()

			if emitter.Parent.Name == "GlowEffect" then
				clone2.Parent = scrapperParticles.Parent.GlowEffect
			else
				clone2.Parent = scrapperParticles
			end

			if not emitter.Enabled then
				local v8 = emitter
				task.spawn(function()
					while v8 do
						v8:Emit(5)
						wait(1)
					end
				end)
			end

			table.insert(clones, clone2)
		end

		task.spawn(function()
			repeat
				wait(0.1)
			until not table.find(clones2, v7)

			for _, v8 in pairs(clones) do
				v8:Destroy()
			end

			if clone then
				clone:Destroy()
				clone = nil
			end

			v4 = nil
			v5 = nil
			GetParticlesForGrinder()
		end)
	end
end

function PivotModelToGrinder(folder)
	folder:PivotTo(workspace.Map.Campground.Scrapper.DashedLine.StartAttachment.WorldCFrame)

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = true
	end
end

local random = Random.new()

function TweenDownAndRattle(instance, _, p)
	local startAttachment = workspace.Map.Campground.Scrapper.DashedLine.StartAttachment
	local endAttachment = workspace.Map.Campground.Scrapper.DashedLine.EndAttachment
	local grinder = workspace.Map.Campground.Scrapper.DashedLine.Grinder
	local v6 = {}
	local worldPosition = startAttachment.WorldPosition
	local worldPosition2 = endAttachment.WorldPosition
	local scrappable = instance:GetAttribute("Scrappable")

	if instance:HasTag("CanBeGrinded") then
		scrappable = instance.Name == "Log" and 1 or 5
	end

	local v7 = math.clamp(
		(((instance:HasTag("Gem") or instance:HasTag("GreenGem")) and 10 or scrappable) - 1) / 7,
		0,
		1
	)
	local v8 = 2 + 14 * v7
	local _ = 0.5 + 3.5 * v7
	local v9 = instance:HasTag("CanBeGrinded") and 1 or v8

	if not grinder.Playing then
		grinder:Play()
	end

	for i = 1, 15 do
		table.insert(v6, (worldPosition:Lerp(worldPosition2, i / 15)))
	end

	wait(0.05)
	instance:PivotTo(instance:GetPivot() * CFrame.Angles(0, math.rad((random:NextInteger(0, 360))), 0))

	for i = 1, #v6 do
		for _ = 1, math.round(v9) do
			local pivot = instance:GetPivot()
			instance:PivotTo(pivot - pivot.Position + v6[i] + Vector3.new(
				random:NextInteger(-30, 30) / 100,
				random:NextInteger(-20, 20) / 100,
				random:NextInteger(-30, 30) / 100
			))
			wait(0.05)
		end
	end

	if instance:FindFirstChildWhichIsA("ParticleEmitter") then
		instance:FindFirstChildWhichIsA("ParticleEmitter"):Clear()
		instance:FindFirstChildWhichIsA("ParticleEmitter"):Destroy()
	end

	instance:Destroy()

	if v2 == p then
		grinder:Stop()
		v2 = nil
		SpinGrinder(false)
	end
end

local flag = false

function SpinGrinder(p)
	local scrapper = workspace.Map.Campground.Scrapper
	local poleLeft = scrapper.Movers.Left.PoleLeft
	local poleRight = scrapper.Movers.Right.PoleRight

	if p and not flag then
		flag = true
		task.spawn(function()
			while flag do
				poleLeft.CFrame *= CFrame.Angles(-0.03490658503988659, 0, 0)
				poleRight.CFrame *= CFrame.Angles(0.03490658503988659, 0, 0)
				wait()
			end
		end)
	elseif flag then
		flag = false
	end
end

function AddParticlesToObject(instance)
	if instance:HasTag("CanBeGrinded") then
		return
	end

	local primaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)

	if primaryPart then
		local clone2 = ReplicatedStorage.Assets.Particles.Grinder.ParticleEmitter:Clone()
		clone2.Enabled = true
		clone2.Parent = primaryPart
		GetParticlesForGrinder(instance)
	end
end

local v6 = {}

function ScrapItem(instance, instance2, p, _)
	if v[instance2] or not instance2.Parent then
		return
	end

	v[instance2] = true
	task.delay(5, function()
		v[instance2] = nil
	end)
	local _ = instance2:GetPivot().Position
	local _ = instance:GetPivot().Position + createVector(0, 2, 0)
	local clone2 = instance2:Clone()
	v6[clone2] = true
	task.delay(20, function()
		v6[clone2] = nil
	end)

	for _, part in pairs(clone2:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	v[clone2] = true
	task.delay(20, function()
		v[clone2] = nil
	end)
	local highlight = clone2:FindFirstChildWhichIsA("Highlight", true)

	if highlight then
		highlight:Destroy()
	end

	local billboardGui = clone2:FindFirstChildWhichIsA("BillboardGui", true)

	if billboardGui then
		billboardGui:Destroy()
	end

	clone2:PivotTo(instance2:GetPivot())
	local parent = instance2.Parent

	if not (parent and parent:IsDescendantOf(workspace)) then
		parent = workspace.Particles
	end

	clone2.Parent = parent
	task.spawn(function()
		for _ = 1, 20 do
			if instance2.Parent == nil then
				break
			end

			if instance2.Parent ~= game.ReplicatedStorage.TempStorage then
				instance2.Parent = game.ReplicatedStorage.TempStorage
			end

			RunService.RenderStepped:Wait()
		end
	end)
	table.insert(clones2, clone2)
	task.spawn(function()
		PivotModelToGrinder(clone2)
		AddParticlesToObject(clone2)

		if v2 then
			v2 += 1
		else
			v2 = 1
			SpinGrinder(true)
		end

		local v7 = v2
		TweenDownAndRattle(clone2, p, v7)

		if clone2 then
			removeTable(clones2, clone2)
		end
	end)
end

Client.Events.ScrapItem:Connect(ScrapItem)

function CraftingBenchAdded(instance)
	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if not parent or v6[parent] then
			return
		end

		if parent and parent.Parent and (parent:GetAttribute("Scrappable") or parent:HasTag("CanBeGrinded") or parent:HasTag("Gem") or parent:HasTag("GreenGem")) then
			local owner = parent:GetAttribute("Owner")

			if owner == nil or owner == localPlayer.UserId then
				if v[parent] or parent:GetAttribute("Scrapped") then
					return
				end

				local parent2 = parent.Parent
				task.spawn(function()
					ScrapItem(instance, parent, true)
				end)

				if not parent:HasTag("CanBeGrinded") and (owner == localPlayer.UserId or parent:GetAttribute("LastOwner") and parent:GetAttribute("LastOwner") == localPlayer.UserId) then
					Client.TutorialClient.HasAddedScrap = true

					if Client.TutorialClient.currentID == 2 then
						Client.TutorialClient.ClearTutorial(2)
					end
				end

				local v7 = Client.Events.RequestScrapItem:InvokeServer(instance, parent)

				if not (v7 and v7.Success) then
					print("not success")
					task.delay(2, function()
						v[parent] = nil
						parent.Parent = parent2
					end)
				end
			end
		end
	end)
end

function CraftingGrinderModule.Init()
	Client.Utility.ForAllTagged("CraftingBench", CraftingBenchAdded)
end

return CraftingGrinderModule