local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local CAM = ReplicatedStorage.CAM
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Utility = require(CAM.Global.Utility)
local maid = cleanit.new()
local CrossReaver = {
	Id = 0
}
local track = nil
local postSimulationConnection = nil

function CrossReaver.Hold(player)
	maid:Clean()

	if track then
		track:Stop()
		track = nil
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart) then
		return
	end

	local id = CrossReaver.Id
	track = humanoid.Animator:LoadAnimation(script.Skill1Anim)
	track:Play()
	local v = track
	task.delay(Config.HOLD_AT, function()
		if id ~= CrossReaver.Id then
			return
		end

		if track == v and v.IsPlaying then
			v:AdjustSpeed(0)
		end
	end)
	local add = maid:Add(script.Parent.Parent.Parent.holder.skill_stand_still:Clone())
	add.Parent = humanoidRootPart
	local mousepos = Platform_Handler.mousepos(500)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v2 = {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = 0
	}
	local safeLookAt = Utility.SafeLookAt
	local position = humanoidRootPart.Position
	local X = mousepos.X
	v2.CFrame = safeLookAt(position, Vector3.new(X, humanoidRootPart.Position.Y, mousepos.Z), humanoidRootPart.CFrame)
	local alignOrientationWithAttachment, v3 = createAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		v2
	)
	maid:Add(v3)
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		mousepos = Platform_Handler.mousepos(500)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	maid:Add(postSimulationConnection)
end

function CrossReaver.UnHold(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if track then
		if track.TimePosition < Config.HOLD_AT then
			track.TimePosition = Config.HOLD_AT
		end

		track:AdjustSpeed(1)
	end

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function teardown()
		maid:Clean()

		if humanoidRootPart then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		end
	end

	local v = character and Utility.getvaluesfolder(character)

	if v then
		maid:Add(Utility.AddValue(v, "NR", Config.ENDLAG))
	end

	if character and track then
		local v2 = track
		local getvaluesfolder = Utility.getvaluesfolder(character)

		if getvaluesfolder then
			local childAddedConnection = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function disconnect()
				if childAddedConnection then
					childAddedConnection:Disconnect()
					childAddedConnection = nil
				end
			end

			local cancel_Values = Utility.Cancel_Values
			childAddedConnection = getvaluesfolder.ChildAdded:Connect(function(child)
				if cancel_Values[child.Name] then
					v2:Stop()
					teardown() -- equivalent call inferred; original call site unknown
					disconnect() -- equivalent call inferred; original call site unknown
				end
			end)
			v2.Stopped:Once(disconnect)
		end
	end

	local id = CrossReaver.Id
	task.wait(Config.ENDLAG)

	if id ~= CrossReaver.Id then
		return
	end

	teardown() -- equivalent call inferred; original call site unknown
end

function CrossReaver.Cancel(player)
	maid:Clean()

	if track then
		track:Stop()
		track = nil
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)

		for _, child in pairs(humanoidRootPart:GetChildren()) do
			if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
				child:Destroy()
			end
		end
	end
end

return CrossReaver