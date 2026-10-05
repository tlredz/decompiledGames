local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = {
	"StartX",
	"StartZ",
	"Direction",
	"FromLength",
	"ToLength",
	"TweenDuration",
	"TweenId",
	"ThicknessY",
	"PauseUntil"
}
local v2 = {}
local v3 = {}
local v4 = {}
local postSimulationConnection = nil

local function getStateFromPart(part)
	local attributesByAttributeName = {}

	for _, attributeName in v do
		local attribute = part:GetAttribute(attributeName)

		if typeof(attribute) ~= "number" and typeof(attribute) ~= "Vector2" then
			return nil
		end

		attributesByAttributeName[attributeName] = attribute
	end

	attributesByAttributeName.Elapsed = 0
	attributesByAttributeName.Part = part
	return attributesByAttributeName
end

local function setRunTransformLocal(data, p: number?)
	local Y = data.Part.Position.Y
	local v5 = p or data.FromLength
	local v6 = (v5 - 1) * 0.5
	local vector

	if data.Direction.X == 0 then
		vector = Vector3.new(data.StartX + 0.5, Y, data.StartZ + data.Direction.Y * v6)
	else
		vector = Vector3.new(data.StartX + data.Direction.X * v6, Y, data.StartZ + 0.5)
	end

	local v7 = data.Direction.X == 0 and 2 or math.max(1, v5)
	local v8 = data.Direction.Y == 0 and 2 or math.max(1, v5)
	data.Part.Size = Vector3.new(v7, data.ThicknessY, v8)
	data.Part.CFrame = CFrame.new(vector)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startTweenSimulation()
	if postSimulationConnection and postSimulationConnection.Connected then
		return
	end

	postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
		debug.profilebegin("TreeRootAnimator:Step")

		if next(v2) == nil and postSimulationConnection ~= nil and postSimulationConnection.Connected then
			postSimulationConnection:Disconnect()
			postSimulationConnection = nil
			debug.profileend()
		else
			local serverTimeNow = workspace:GetServerTimeNow()

			for k, v5 in v3 do
				if v5.PauseUntil <= serverTimeNow then
					v2[k] = v5
					v3[k] = nil
				end

				setRunTransformLocal(v5)
			end

			local count = 0

			for k, v5 in v2 do
				if serverTimeNow < v5.PauseUntil then
					v3[k] = v5
					v2[k] = nil
					setRunTransformLocal(v5)
				else
					v5.Elapsed += dt
					local v6 = math.max(v5.TweenDuration, 0.011111111111111112)
					local v7 = math.clamp(v5.Elapsed / v6, 0, 1)
					setRunTransformLocal(v5, v5.FromLength + (v5.ToLength - v5.FromLength) * v7)

					if v7 >= 1 then
						v2[k] = nil
					end
				end

				count += 1

				if count >= 3 then
					break
				end
			end

			debug.profileend()
		end
	end)
end

local function applyTweenFromAttributes(part)
	local stateFromPart = getStateFromPart(part)

	if not stateFromPart then
		return
	end

	local tweenId = stateFromPart.TweenId

	if v4[part] == tweenId then
		return
	end

	v4[part] = tweenId

	if workspace:GetServerTimeNow() < stateFromPart.PauseUntil then
		v3[part] = stateFromPart
		v2[part] = nil
	else
		v2[part] = stateFromPart
		v3[part] = nil
	end

	setRunTransformLocal(stateFromPart)
	startTweenSimulation() -- equivalent call inferred; original call site unknown
end

return Observers.observeTag("RootRunTween", function(part)
	if not part:IsA("BasePart") then
		return nil
	end

	local maid = Trove.new()
	applyTweenFromAttributes(part)
	maid:Add(part:GetAttributeChangedSignal("TweenId"):Connect(function()
		applyTweenFromAttributes(part)
	end))
	maid:Add(part:GetAttributeChangedSignal("PauseUntil"):Connect(function()
		local pauseUntil = part:GetAttribute("PauseUntil") or 0
		local serverTimeNow = workspace:GetServerTimeNow()
		local v5 = v2[part]
		local v6 = v3[part]

		if serverTimeNow < pauseUntil then
			if v5 then
				v5.PauseUntil = pauseUntil
				v3[part] = v5
				v2[part] = nil
				setRunTransformLocal(v5)
			elseif v6 then
				v6.PauseUntil = pauseUntil
				setRunTransformLocal(v6)
			else
				local stateFromPart = getStateFromPart(part)

				if stateFromPart then
					v3[part] = stateFromPart
					setRunTransformLocal(stateFromPart)
				end
			end

			if postSimulationConnection and postSimulationConnection.Connected then
				return
			else
				postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
					debug.profilebegin("TreeRootAnimator:Step")

					if next(v2) == nil and postSimulationConnection ~= nil and postSimulationConnection.Connected then
						postSimulationConnection:Disconnect()
						postSimulationConnection = nil
						debug.profileend()
					else
						local serverTimeNow2 = workspace:GetServerTimeNow()

						for k, v7 in v3 do
							if v7.PauseUntil <= serverTimeNow2 then
								v2[k] = v7
								v3[k] = nil
							end

							setRunTransformLocal(v7)
						end

						local count = 0

						for k, v7 in v2 do
							if serverTimeNow2 < v7.PauseUntil then
								v3[k] = v7
								v2[k] = nil
								setRunTransformLocal(v7)
							else
								v7.Elapsed += dt
								local v8 = math.max(v7.TweenDuration, 0.011111111111111112)
								local v9 = math.clamp(v7.Elapsed / v8, 0, 1)
								setRunTransformLocal(v7, v7.FromLength + (v7.ToLength - v7.FromLength) * v9)

								if v9 >= 1 then
									v2[k] = nil
								end
							end

							count += 1

							if count >= 3 then
								break
							end
						end

						debug.profileend()
					end
				end)
			end
		end
	end))
	return function()
		maid:Destroy()
		v2[part] = nil
		v4[part] = nil
	end
end)