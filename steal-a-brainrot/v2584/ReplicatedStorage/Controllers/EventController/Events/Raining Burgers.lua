local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.EventTypes)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local AnimalController = require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("EventService/RainingBurgers/Strike")
local name = script.Name
local maid = Trove.new()
local models = {}
local v = false

local function getBurgerTemplate()
	local burger = script:FindFirstChild("Burger")

	if burger and burger:IsA("Model") and burger.PrimaryPart then
		return burger
	end

	return nil
end

local function setupBurger(folder)
	local primaryPart = folder.PrimaryPart

	if not primaryPart then
		return nil
	end

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	local __burger_transform = primaryPart:FindFirstChild("__burger_transform")

	if __burger_transform and __burger_transform:IsA("Motor6D") then
		return __burger_transform
	end

	local motor6D = Instance.new("Motor6D")
	motor6D.Name = "__burger_transform"
	motor6D.Part0 = workspace.Terrain
	motor6D.Part1 = primaryPart
	motor6D.Parent = primaryPart
	return motor6D
end

local function isBrainrotBelow(vector2: Vector3)
	for _, v2 in AnimalController:GetAnimals() do
		local animalModel = v2.AnimalModel

		if not animalModel then
			continue
		end

		local position = animalModel:GetPivot().Position
		local v3 = position.X - vector2.X
		local v4 = position.Z - vector2.Z

		if v3 * v3 + v4 * v4 <= 64 then
			return true
		end
	end

	return false
end

local RainingBurgers = {}

function RainingBurgers.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	v = true
	maid:Add(function()
		v = false
		table.clear(models)
	end)
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	ReplicatedStorage:SetAttribute("RainingBurgersEvent", true)
	SoundController:UpdateOST()
	maid:Add(function()
		ReplicatedStorage:SetAttribute("RainingBurgersEvent", nil)
		SoundController:UpdateOST()
	end)
	local rainingBurgersMap = script:FindFirstChild("RainingBurgersMap")

	if rainingBurgersMap then
		local clone = maid:Clone(rainingBurgersMap)
		clone.Parent = workspace
	end

	maid:Add(Observers.observeTag("HideInRainingBurgers", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	local folder = Instance.new("Folder")
	folder.Name = "RainingBurgers"
	folder.Parent = workspace
	maid:Add(folder)
	local groundVFX = script:FindFirstChild("GroundVFX")
	local struckVFX = script:FindFirstChild("StruckVFX")
	local raycastParams = RaycastParams.new()
	raycastParams.IncludeInstances = { workspace.Map, workspace.Plots }
	raycastParams.RespectCanCollide = true
	raycastParams.CollisionGroup = "Burger"
	local v2 = {}

	local function dropBurger(vector2: Vector3, impactVFX, strikeUid: string?, Y: number?)
		local burger = script:FindFirstChild("Burger")

		if not (burger and burger:IsA("Model") and burger.PrimaryPart) then
			burger = nil
		end

		if not burger then
			return
		end

		if not Y then
			local raycastResult = workspace:Raycast(vector2, createVector(0, -3000, 0), raycastParams)

			if raycastResult then
				Y = raycastResult.Position.Y
			else
				Y = vector2.Y - 3000
			end
		end

		local model = table.remove(models, 1) or burger:Clone()
		local motor = setupBurger(model)

		if not motor then
			model:Destroy()
			return
		end

		if model.Parent == nil then
			model.Parent = folder
		end

		table.insert(v2, {
			model = model,
			motor = motor,
			x = vector2.X,
			z = vector2.Z,
			y = vector2.Y,
			groundY = Y,
			rotation = CFrame.Angles(
				math.random() * 6.283185307179586,
				math.random() * 6.283185307179586,
				math.random() * 6.283185307179586
			),
			expires = os.clock() + 12,
			impactVFX = impactVFX,
			strikeUid = strikeUid
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function release(p)
		if v and #models < 64 then
			p.motor.Transform = CFrame.new(0, -100000, 0)
			table.insert(models, p.model)
		else
			p.model:Destroy()
		end
	end

	maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		local now = os.clock()

		for i = #v2, 1, -1 do
			local v3 = v2[i]

			if v3.model.Parent then
				v3.y -= dt * 145

				if v3.strikeUid then
					local animalPosition = ClientEventUtils.getAnimalPosition(v3.strikeUid, {
						top = true
					})

					if animalPosition and animalPosition ~= createVector(0, 0, 0) then
						v3.x = animalPosition.X
						v3.z = animalPosition.Z
						v3.groundY = animalPosition.Y
					end
				end

				v3.motor.Transform = CFrame.new(v3.x, v3.y, v3.z) * v3.rotation
				local v4 = v3.y <= v3.groundY

				if v4 or v3.expires <= now then
					local impactVFX = v3.impactVFX

					if v4 and impactVFX and impactVFX:IsA("BasePart") then
						if v3.strikeUid then
							ClientEventUtils.playBurst(
								impactVFX,
								v3.strikeUid,
								{ ReplicatedStorage.Sounds.Events["Raining Burgers"]["Brainrot Hit"] }
							)
						else
							ClientEventUtils.playBurst(
								impactVFX,
								Vector3.new(v3.x, v3.groundY, v3.z),
								{ ReplicatedStorage.Sounds.Events["Raining Burgers"]["Hit Nothing"] }
							)
						end
					end

					release(v3) -- equivalent call inferred; original call site unknown
					table.remove(v2, i)
				end
			else
				table.remove(v2, i)
			end
		end
	end))
	maid:Add(Timer.Simple(0.1, function()
		local ambientSpawnArea = script:FindFirstChild("AmbientSpawnArea")

		if not (ambientSpawnArea and ambientSpawnArea:IsA("BasePart")) then
			return
		end

		local cFrame = ambientSpawnArea.CFrame
		local size = ambientSpawnArea.Size

		for _ = 1, 2 do
			local v3 = cFrame * Vector3.new(
				(math.random() - 0.5) * size.X,
				(math.random() - 0.5) * size.Y,
				(math.random() - 0.5) * size.Z
			)

			if not isBrainrotBelow(v3) then
				dropBurger(v3, groundVFX)
			end
		end
	end))
	maid:Add(remoteEvent.OnClientEvent:Connect(function(strikeUid: string)
		local animalPosition = ClientEventUtils.getAnimalPosition(strikeUid, {
			top = true
		})

		if not animalPosition or animalPosition == createVector(0, 0, 0) then
			return
		end

		dropBurger(animalPosition + createVector(0, 120, 0), struckVFX, strikeUid, animalPosition.Y)
	end))
end

function RainingBurgers.OnStop(_)
	maid:Destroy()
end

function RainingBurgers.OnLoad(_) end

return RainingBurgers