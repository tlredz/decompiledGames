local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local HudController = require(ReplicatedStorage.Controllers.HudController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Net = require(ReplicatedStorage.Packages.Net)
local Traits = require(ReplicatedStorage.Datas.Traits)
local unreliableRemoteEvent = Net:UnreliableRemoteEvent("SoccerStadium/Aim")
local remoteEvent = Net:RemoteEvent("SoccerStadium/MiniEvent")
local remoteEvent2 = Net:RemoteEvent("SoccerStadium/Strike")
local remoteEvent3 = Net:RemoteEvent("SoccerStadium/StrikeHit")
local v = {
	Set1 = {
		105067541473003,
		91807092564471,
		114634183708882,
		87689089997965,
		73751940143820,
		119055722032874,
		90316217516456,
		98102616415272,
		132427845542454,
		116518073969710
	},
	Set2 = {
		121930341098922,
		109207410544641,
		133825061633610,
		114250151419509,
		126719852416986,
		121721810761281,
		111271271876977,
		129249577257499,
		76260713617530,
		130639889366582
	},
	Set3 = {
		95601867196079,
		105121981966831,
		98735067091072,
		110656067748543,
		114073579976826,
		106445439249019,
		133256558961601,
		114604586707092,
		113168074743217,
		137605677610786
	}
}
local maid = Trove.new()
local Soccer = {}

function Soccer.OnStart(_)
	pcall(function()
		if not PhysicsService:IsCollisionGroupRegistered("SoccerBall") then
			PhysicsService:RegisterCollisionGroup("SoccerBall")
		end

		PhysicsService:CollisionGroupSetCollidable("SoccerBall", "Player", false)
		PhysicsService:CollisionGroupSetCollidable("SoccerBall", "Animal", false)
	end)
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	maid:Add(Observers.observeTag("HideInSoccerStadium", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	task.spawn(function()
		local v2 = {}

		for _, v3 in v do
			for _, v4 in v3 do
				table.insert(v2, "rbxassetid://" .. v4)
			end
		end

		ContentProvider:PreloadAsync(v2)
	end)
	local v2 = {}
	maid:Add(function()
		table.clear(v2)
	end)
	maid:Add(Observers.observeTag("SoccerStadiumBrainrotSet", function(folder)
		local v3 = v[folder:GetAttribute("Set")]

		if not v3 or #v3 == 0 then
			return
		end

		local textures = {}

		for _, texture in folder:GetDescendants() do
			if not texture:IsA("Texture") then
				continue
			end

			v2[texture] = v3
			table.insert(textures, texture)
		end

		return function()
			for _, v4 in textures do
				v2[v4] = nil
			end
		end
	end))
	maid:Add(Timer.Simple(0.16666666666666666, function()
		local serverTimeNow = workspace:GetServerTimeNow()

		for k, v3 in v2 do
			local v4 = math.floor(serverTimeNow / 0.16666666666666666) % #v3 + 1
			k.ColorMapContent = Content.fromUri("rbxassetid://" .. v3[v4])
		end
	end))
	local soccerBall = script:FindFirstChild("SoccerBall")
	local folder = Instance.new("Folder")
	folder.Name = "SoccerBallRain"
	folder.Parent = workspace
	maid:Add(folder)
	local random = Random.new()
	local v3 = 0
	local v4 = createVector(0, 0, 0)
	local v5 = createVector(0, 0, 0)

	local function spawnBall(position: Vector3, assemblyLinearVelocity: Vector3, fn, p: string?)
		if not (soccerBall and soccerBall:IsA("BasePart")) then
			return
		end

		local clone = soccerBall:Clone()
		clone.Anchored = false
		clone.CanCollide = true
		clone.CanQuery = false
		clone.CanTouch = true
		clone.Massless = false
		clone.CollisionGroup = "SoccerBall"
		clone.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.75, 1, 1)
		clone.CFrame = CFrame.new(position) * CFrame.Angles(
			random:NextNumber(0, 6.283185307179586),
			random:NextNumber(0, 6.283185307179586),
			random:NextNumber(0, 6.283185307179586)
		)
		clone.AssemblyLinearVelocity = assemblyLinearVelocity
		clone.AssemblyAngularVelocity = Vector3.new(
			random:NextNumber(-12, 12),
			random:NextNumber(-12, 12),
			random:NextNumber(-12, 12)
		)
		clone.Parent = folder
		local character = Players.LocalPlayer.Character

		if character then
			for _, part in character:QueryDescendants("BasePart") do
				local noCollisionConstraint = Instance.new("NoCollisionConstraint")
				noCollisionConstraint.Part0 = clone
				noCollisionConstraint.Part1 = part
				noCollisionConstraint.Parent = clone
			end
		end

		local flag = false
		local v6 = false

		local function fadeOut()
			if v6 or not clone.Parent then
				return
			end

			v6 = true
			local tween = TweenService:Create(clone, TweenInfo.new(0.4), {
				Transparency = 1
			})
			tween:Play()
			tween.Completed:Once(function()
				if clone.Parent then
					clone:Destroy()
				end
			end)
		end

		local postSimulationConnection = nil
		local touchedConnection = nil
		touchedConnection = clone.Touched:Connect(function(otherPart)
			if flag or clone.CFrame.Position.Y > position.Y - 20 or otherPart:IsDescendantOf(folder) then
				return
			end

			if not p then
				local model = otherPart:FindFirstAncestorWhichIsA("Model")

				if model and model:FindFirstChildWhichIsA("Humanoid") then
					return
				end
			end

			flag = true
			touchedConnection:Disconnect()

			if postSimulationConnection then
				postSimulationConnection:Disconnect()
				postSimulationConnection = nil
			end

			if fn then
				local position2 = clone.CFrame.Position
				task.spawn(fn, position2)
			end

			task.delay(random:NextNumber(1, 2), fadeOut)
		end)

		if p then
			postSimulationConnection = RunService.PostSimulation:Connect(function()
				if flag or not clone.Parent then
					if postSimulationConnection then
						postSimulationConnection:Disconnect()
						postSimulationConnection = nil
					end
				else
					local animalPosition = ClientEventUtils.getAnimalPosition(p, {
						top = true
					})

					if animalPosition and animalPosition ~= createVector(0, 0, 0) then
						local v7 = Vector3.new(
							animalPosition.X - clone.Position.X,
							0,
							animalPosition.Z - clone.Position.Z
						) * 8

						if v7.Magnitude > 60 then
							v7 = v7.Unit * 60
						end

						clone.AssemblyLinearVelocity = Vector3.new(v7.X, clone.AssemblyLinearVelocity.Y, v7.Z)
					end
				end
			end)
		end

		task.delay(6, function()
			if not flag then
				fadeOut()
			end
		end)
	end

	local ballHitGround = ReplicatedStorage.Sounds.Events.Soccer.BallHitGround

	local function playImpactSound(vector2: Vector3)
		local v6 = SoundController:PlaySound(ballHitGround, vector2, false)

		if not v6 then
			return
		end

		maid:Add(v6)
		v6.Ended:Once(function()
			maid:Remove(v6)
		end)
	end

	local function dropBall(vector2: Vector3)
		spawnBall(
			vector2,
			Vector3.new(random:NextNumber(-22, 22), random:NextNumber(-14, -4), random:NextNumber(-22, 22)),
			function(vector3: Vector3)
				playImpactSound(vector3)
			end
		)
	end

	maid:Add(Timer.Simple(0.2, function()
		local now = os.clock()

		if v3 <= now or v5 == createVector(0, 0, 0) then
			return
		end

		for _ = 1, 2 do
			local vector2 = Vector3.new(
				(math.random() - 0.5) * v5.X,
				(math.random() - 0.5) * v5.Y,
				(math.random() - 0.5) * v5.Z
			)
			dropBall(v4 + vector2)
		end
	end))
	local soccerBallTrait = Traits.SoccerBallTrait or Traits.Ball
	local v6 = not soccerBallTrait and "" or soccerBallTrait.Icon
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p: number, vector2: Vector3?, vector3: Vector3?)
		EffectController:Activate("Blink")
		maid:Add(HudController:ShowFakeEvent("SoccerBallTrait", p, v6))

		if typeof(vector2) == "Vector3" and typeof(vector3) == "Vector3" then
			v4 = vector2
			v5 = vector3
			v3 = os.clock() + math.max(0, p - workspace:GetServerTimeNow())
		end

		task.delay(math.max(0, p - workspace:GetServerTimeNow()), function()
			EffectController:Activate("Blink")
		end)
	end))

	local function playBurst(p: string)
		local burst = script:FindFirstChild("Burst")

		if burst and burst:IsA("BasePart") then
			ClientEventUtils.playBurst(burst, p, { ReplicatedStorage.Sounds.Events.Soccer.Burst })
		end
	end

	maid:Add(remoteEvent2.OnClientEvent:Connect(function(p: string)
		local animalPosition = ClientEventUtils.getAnimalPosition(p, {
			top = true
		})

		if not animalPosition or animalPosition == createVector(0, 0, 0) then
			return
		end

		spawnBall(animalPosition + createVector(0, 45, 0), createVector(0, -10, 0), function()
			playBurst(p)
			remoteEvent3:FireServer(p)
		end, p)
	end))
	local total = 0
	local v7 = createVector(0, 0, 0)
	maid:Add(RunService.RenderStepped:Connect(function(dt: number)
		total += dt

		if total < 0.05 then
			return
		end

		total = 0
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local lookVector = currentCamera.CFrame.LookVector

		if (lookVector - v7).Magnitude < 0.02 then
			return
		end

		v7 = lookVector
		unreliableRemoteEvent:FireServer(lookVector)
	end))
end

function Soccer.OnStop(_)
	maid:Destroy()
end

return Soccer