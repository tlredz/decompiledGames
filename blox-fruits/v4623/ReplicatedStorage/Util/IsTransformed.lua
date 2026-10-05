local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local v = {
	Buddha2 = "HumanoidRootPart",
	Buddha = "HumanoidRootPart",
	Phoenix2 = true,
	Phoenix = true,
	Dragon = true,
	HydraRig = true,
	Mammoth = true,
	TRex = true,
	Kitsune = true,
	LeopardRig = true,
	TigerRig = true,
	YetiRig = true,
	GasRig = true,
	PainTransformed = true,
	MagnetRig = true,
	MagnetFlightTDisable = true,
	DogHouseForm = true
}
local v2 = {
	DiamondBody = true,
	FalconBody = true,
	DragonHybrid = true,
	FalconFlight = true,
	BuilderMode = true,
	BossDisguisedPotion = true
}
local v3 = {
	Flamingo = true,
	GravityFlight = true
}

function isTransformed(character, flag: boolean?, flag2: boolean?)
	if character == "rigList" then
		return v
	elseif character == "rigListSpecial" then
		return v3
	end

	assert(typeof(character) ~= "string")
	local v4 = flag2 == nil or flag2

	if not character then
		return true
	end

	if character:IsA("Player") then
		character = character.Character
	end

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return true
	end

	for childName, childName2 in pairs(v) do
		if typeof(childName2) == "string" then
			if character:FindFirstChild(childName2) and character[childName2]:FindFirstChild(childName) then
				return true
			end
		elseif character:FindFirstChild(childName) then
			return true
		end
	end

	if v4 then
		for childName, childName2 in pairs(v2) do
			if typeof(childName2) == "string" then
				if character:FindFirstChild(childName2) and character[childName2]:FindFirstChild(childName) then
					return true
				end
			elseif character:FindFirstChild(childName) then
				return true
			end
		end
	end

	if flag then
		for childName, childName2 in pairs(v3) do
			if typeof(childName2) == "string" then
				if character:FindFirstChild(childName2) and character[childName2]:FindFirstChild(childName) then
					return true
				end
			elseif character:FindFirstChild(childName) then
				return true
			end
		end
	end

	if not character:FindFirstChild("__TemporaryTransformation") then
		return false
	end

	local Global = require(game.ReplicatedStorage.Global)
	Global.TestGameWarn("player is mid-transform")
	return true
end

local RunService2 = game:GetService("RunService")

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	task.spawn(function()
		local SharedSignals = require(game.ReplicatedStorage:WaitForChild("SharedSignals"))
		local transformationChanged = SharedSignals.TransformationChanged()

		local function onCharacterAdded(character)
			local v4 = nil
			local v5 = nil
			local now = 0
			local connections = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateLastTransform(instance)
				now = tick()
				instance:SetAttribute("LastTransformChange", now)
			end

			local onChildAdded

			onChildAdded = function(child, flag: boolean?)
				task.defer(function()
					if child:IsA("Model") or child:IsA("Accessory") or child:IsA("Folder") or child:IsA("Attachment") then
						local v6 = flag
						local name = child.Name
						local v7, v8

						if v[name] then
							if v6 then
								name = false
							else
								v7 = false
								v8 = false
							end
						elseif v2[name] then
							if v6 then
								name = false
							else
								v7 = false
								v8 = true
							end
						elseif v3[name] then
							if v6 then
								name = false
							else
								v7 = true
								v8 = false
							end
						else
							name = nil
						end

						if name == false or name == nil or v5 then
							if name == false and v4 == child.Name then
								updateLastTransform(character) -- equivalent call inferred; original call site unknown
								v4 = nil

								if v5 then
									v5:Destroy()
									v5 = nil
								end

								transformationChanged:Fire(false)
							end
						else
							if v7 or v8 then
								if v7 and not v8 then
									v5 = AttributeCounter.destroyable(character, "SPECIAL_TRANSFORMATION")
								end
							else
								v5 = AttributeCounter.destroyable(character, "FULL_TRANSFORMATION")
							end

							updateLastTransform(character) -- equivalent call inferred; original call site unknown
							v4 = name
							transformationChanged:Fire(name, v7, v8)
						end
					end

					if child.Name == "HumanoidRootPart" then
						table.insert(connections, child.ChildAdded:Connect(onChildAdded))
						table.insert(connections, child.ChildRemoved:Connect(function(child2)
							onChildAdded(child2, true)
						end))

						for _, child2 in child:GetChildren() do
							onChildAdded(child2)
						end
					end
				end)
			end

			table.insert(connections, character.ChildAdded:Connect(onChildAdded))
			table.insert(connections, character.ChildRemoved:Connect(function(child)
				onChildAdded(child, true)
			end))
			table.insert(connections, character.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					for _, connection in connections do
						connection:Disconnect()
					end

					table.clear(connections)
				end
			end))

			for _, child in character:GetChildren() do
				onChildAdded(child)
			end
		end

		if isClient then
			game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

			if game.Players.LocalPlayer.Character then
				onCharacterAdded(game.Players.LocalPlayer.Character)
			end
		else
			for _, v4 in game.Players:GetPlayers() do
				if v4.Character then
					onCharacterAdded(v4.Character)
				end

				v4.CharacterAdded:Connect(onCharacterAdded)
			end

			game.Players.PlayerAdded:Connect(function(player)
				player.CharacterAdded:Connect(onCharacterAdded)
			end)
		end
	end)
end

local IsTransformed = {
	HasTransformedRecently = function(instance, p)
		local lastTransformChange = instance:GetAttribute("LastTransformChange")
		return type(lastTransformChange) == "number" and tick() - p < lastTransformChange
	end,
	isTransformed = isTransformed
}
setmetatable(IsTransformed, {
	__call = function(_, ...)
		return isTransformed(...)
	end
})
return IsTransformed