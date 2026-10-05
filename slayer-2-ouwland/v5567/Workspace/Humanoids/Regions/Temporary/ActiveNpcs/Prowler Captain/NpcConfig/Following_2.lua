local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Following = {
	CapturedEnemy = nil,
	LetGoDistance = 75,
	CaptureDistance = 0,
	Cache = {},
	NpcsPerPlayer = 2,
	ActiveAttackersPerPlayer = 1,
	StrafeDistance = 15,
	StrafeDirectionSwapTime = 3,
	PathRetries = {
		Current = 8,
		Max = 8,
		ExhaustedInterval = 1.5,
		ExhaustedGrowth = 1.5,
		ExhaustedIntervalMax = 60
	}
}
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local AiMimic = require(ServerStorage.SAM.AiThings.AiMimic)

function Following.CanFollow(instance)
	if not (instance ~= nil and Following.NpcsPerPlayer ~= nil) then
		return
	end

	local npcsFollowing = instance:FindFirstChild("NpcsFollowing")

	if npcsFollowing == nil then
		return true
	end

	local count = 0

	for _, objectValue in npcsFollowing:GetChildren() do
		if not objectValue:IsA("ObjectValue") or objectValue.Value ~= nil then
			count += 1
		end
	end

	if count < Following.NpcsPerPlayer then
		return true
	end
end

local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Validators = require(ReplicatedStorage.CAM.Global.Validators)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Allegiance = require(ReplicatedStorage.CAM.Global.Allegiance)

function Following.CanFollowFinal(p, instance, instance2, p2)
	if instance == nil or instance2 == nil or Allegiance.AreFriendly(instance2, instance) then
		return
	end

	local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart2 ~= nil then
		local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
		local total = 0

		if p.Following.AddIfAgroed and instance:FindFirstChild("NpcsFollowing") and #instance.NpcsFollowing:GetChildren() > 0 then
			total += p.Following.AddIfAgroed
		end

		if magnitude <= p2 + total and Checker.check_victim(script, instance2, instance, {
			iframe = true
		}) ~= nil then
			if p.Following.AggroValidator ~= nil then
				local v = Validators.Get(p.Following.AggroValidator)

				if v ~= nil and v(instance) ~= true then
					return
				end
			end

			local dynamicRaycastParams, v2 = RaycastHelper.GetDynamicRaycastParams(
				p.Spawning.Cache.RaycastParamsName,
				60
			)

			if v2 then
				dynamicRaycastParams.FilterDescendantsInstances = { workspace.Debree, instance2 }
				dynamicRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				(humanoidRootPart2.Position - humanoidRootPart.Position).Unit * (magnitude + 1),
				dynamicRaycastParams
			)
			return raycastResult ~= nil and raycastResult.Instance:IsDescendantOf(instance) and true or false, magnitude
		end
	end
end

function Following.ClearCache()
	if Following.Cache ~= nil then
		for k, connection in pairs(Following.Cache) do
			local typeName = typeof(connection)

			if typeName == "RBXScriptConnection" then
				connection:Disconnect()
			end

			if typeName == "table" and connection.Destroy ~= nil or typeName == "Instance" then
				connection:Destroy()
			end

			Following.Cache[k] = nil
		end

		Following.Cache = {}
	end
end

function Following:ResetOld()
	if Following.CapturedEnemy ~= nil then
		if Following.CapturedEnemy:FindFirstChild("NpcsFollowing") ~= nil then
			local child = Following.CapturedEnemy.NpcsFollowing:FindFirstChild(self.UniqueName)

			if child ~= nil then
				child:Destroy()
			end
		end

		Following.CapturedEnemy = nil
		local entity

		if self.Spawning ~= nil then
			entity = self.Spawning.Entity or nil
		end

		if entity ~= nil then
			entity:SetAttribute("Aggroed", nil)
		end

		self.Properties.NoTarget = 1
		self.TargetIsStunned = 0
		self.Properties.HasTarget = 0
		self.Properties.Strafing = 0
		self.Properties.NotStrafing = 1
	end
end

local EnemyDiscovarable = require(ServerStorage.SAM.AiThings.EnemyDiscovarable)

function Following.Set(data, character)
	local entity = data.Spawning.Entity

	if entity == nil or character == Following.CapturedEnemy then
		Following.LastNotifName = nil
	else
		if character == nil and Following.CapturedEnemy ~= nil and not Following.CapturedEnemy:HasTag("Players") then
			local child = game.Players:FindFirstChild(Following.CapturedEnemy.Name)

			if child ~= nil and child.Character ~= Following.CapturedEnemy and Following.CanFollow(child.Character) and EnemyDiscovarable(child.Character) and Following.CanFollowFinal(
				data,
				child.Character,
				entity,
				(math.max(Following.CaptureDistance, Following.LetGoDistance))
			) then
				character = child.Character
			end
		end

		data.Following.Reset(data, true)

		if character == nil then
			Following.LastNotifName = nil
		else
			if Following.LastNotifName ~= character.Name then
				if Following.LastNotifName == nil then
					EffectsEvent.ToOthersInRange(entity, "NpcNoticeEffect", entity)
				end

				Following.LastNotifName = character.Name
			end

			local parent = character:FindFirstChild("NpcsFollowing")

			if parent == nil then
				parent = Instance.new("Folder", character)
				parent.Name = "NpcsFollowing"
			end

			if parent:FindFirstChild(data.UniqueName) == nil then
				local objectValue = Instance.new("ObjectValue")
				objectValue.Value = data.Spawning.Entity
				objectValue.Name = data.UniqueName
				objectValue.Parent = parent
			end
		end
	end

	data.Properties.HasTarget = character == nil and 0 or 1
	data.Properties.NoTarget = character == nil and 1 or 0
	Following.CapturedEnemy = character

	if entity ~= nil then
		entity:SetAttribute("Aggroed", character ~= nil or nil)
	end
end

function Following.Reset(data, flag: boolean)
	Following.ResetOld(data)
	data.Properties.IsNotPathfinding = 1
	local entity = data.Spawning.Entity

	if entity then
		local folder = AiMimic:GetFolder(entity)
		folder.PathState.Value = 1
		folder.StateId.Value = 0
	end

	if not flag then
		Following.LastNotifName = nil
	end

	Following.PathRetries.Current = Following.PathRetries.Max

	if data.Folder ~= nil then
		data.Folder:SetAttribute("PathExhausted", nil)
	end
end

return Following