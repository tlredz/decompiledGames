local createVector = vector.create
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
assert(RunService:IsClient(), "GuidePath is client-only")
local GuideArrow = require(script.Parent:WaitForChild("GuideArrow"))
local Signal = require(script.Parent:WaitForChild("Signal"))
local GuidePath = {}
local localPlayer = Players.LocalPlayer
local v = {
	AgentRadius = 2,
	AgentHeight = 5,
	AgentCanJump = false,
	WaypointSpacing = 100,
	Costs = {
		DangerZone = 1e999
	}
}
local thread = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getCharacterRoot()
	local character = localPlayer and localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local v3 = nil

local function rebuildRaycastParams()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local filterDescendantsInstances = {}
	local character = localPlayer and localPlayer.Character

	if character then
		table.insert(filterDescendantsInstances, character)
	end

	local guideArrow = workspace:FindFirstChild("GuideArrow")

	if guideArrow then
		table.insert(filterDescendantsInstances, guideArrow)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	v3 = raycastParams
end

local function invalidateRaycastParams()
	v3 = nil
end

local function getRaycastParams()
	if not v3 then
		rebuildRaycastParams()
	end

	return v3
end

if localPlayer then
	localPlayer.CharacterAdded:Connect(invalidateRaycastParams)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasLineOfSight(vector2: Vector3, vector3: Vector3, p)
	local v4 = vector3 - vector2
	local magnitude = v4.Magnitude

	if magnitude <= 3 then
		return true
	end

	local v5 = v4.Unit * (magnitude - 3)
	return workspace:Raycast(vector2, v5, p) == nil
end

local function computePath(position: Vector3, vector2: Vector3)
	local path = PathfindingService:CreatePath(v)

	if not pcall(function()
		path:ComputeAsync(position, vector2)
	end) or path.Status ~= Enum.PathStatus.Success then
		return nil
	end

	local waypoints = path:GetWaypoints()
	local result = {}

	for i = 2, #waypoints do
		table.insert(result, waypoints[i].Position + createVector(0, 3, 0))
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function furthestVisibleIndex(vector2: Vector3, list, p: number, p2)
	for i = #list, p + 1, -1 do
		-- equivalent call inferred; original call site unknown
		if hasLineOfSight(vector2, list[i], p2) then
			return i
		end
	end

	return p + 1
end

local function buildChain(vector2: Vector3, list, p: number, p2)
	local v4 = p - 1
	local result = {}

	while v4 < #list do
		local v5 = furthestVisibleIndex(vector2, list, v4, p2) -- equivalent call inferred; original call site unknown
		table.insert(result, list[v5])
		vector2 = list[v5]
		v4 = v5
	end

	return result
end

local function chainsEqual(list, list2)
	if #list ~= #list2 then
		return false
	end

	for i = 1, #list do
		if list[i] ~= list2[i] then
			return false
		end
	end

	return true
end

local function startGuide(vector2: Vector3, callback, value: number?, p: string?)
	local v4 = value or 8
	local v5 = Signal.new()
	v2 = v5
	thread = task.spawn(function()
		local WAIT_INTERVAL = 0.1
		local v6 = 0
		local v7 = nil
		local v8 = 1
		local v9 = {}

		while true do
			local characterRoot = getCharacterRoot() -- equivalent call inferred; original call site unknown

			if characterRoot then
				local now, v10, v11, v12, v13, v14, v15

				if callback then
					if not callback() then
						now = os.clock()
						v10 = v6 <= now

						if not v10 and v7 and v8 <= #v7 and (characterRoot.Position - v7[v8]).Magnitude > 15 or v10 then
							v7 = computePath(characterRoot.Position, vector2)
							v6 = now + 2
							v8 = 1
						end

						if v7 and #v7 > 0 then
							while v8 <= #v7 and (characterRoot.Position - v7[v8]).Magnitude <= 4 do
								v8 += 1
							end

							if #v7 < v8 then
								v11 = { vector2 }
							else
								v12 = characterRoot.Position + createVector(0, 3, 0)
								v13 = buildChain

								if not v3 then
									rebuildRaycastParams()
								end

								v11 = v13(v12, v7, v8, v3)
							end
						else
							v11 = { vector2 }
						end

						if #v11 == #v9 then
							local flag = true

							for i = 1, #v11 do
								if v11[i] == v9[i] then
									continue
								end

								v14 = false
								flag = false
								break
							end

							if flag then
								v14 = true
							end
						else
							v14 = false
						end

						if not v14 then
							v15 = #v9 > 0
							GuideArrow:SetChain(v11, p)

							if not v15 then
								v3 = nil
							end

							v9 = v11
						end

						task.wait(WAIT_INTERVAL)
						continue
					end
				elseif not ((characterRoot.Position - vector2).Magnitude <= v4) then
					now = os.clock()
					v10 = v6 <= now

					if not v10 and v7 and v8 <= #v7 and (characterRoot.Position - v7[v8]).Magnitude > 15 or v10 then
						v7 = computePath(characterRoot.Position, vector2)
						v6 = now + 2
						v8 = 1
					end

					if v7 and #v7 > 0 then
						while v8 <= #v7 and (characterRoot.Position - v7[v8]).Magnitude <= 4 do
							v8 += 1
						end

						if #v7 < v8 then
							v11 = { vector2 }
						else
							v12 = characterRoot.Position + createVector(0, 3, 0)
							v13 = buildChain

							if not v3 then
								rebuildRaycastParams()
							end

							v11 = v13(v12, v7, v8, v3)
						end
					else
						v11 = { vector2 }
					end

					if #v11 == #v9 then
						local flag = true

						for i = 1, #v11 do
							if v11[i] == v9[i] then
								continue
							end

							v14 = false
							flag = false
							break
						end

						if flag then
							v14 = true
						end
					else
						v14 = false
					end

					if not v14 then
						v15 = #v9 > 0
						GuideArrow:SetChain(v11, p)

						if not v15 then
							v3 = nil
						end

						v9 = v11
					end

					task.wait(WAIT_INTERVAL)
					continue
				end

				thread = nil
				GuideArrow:SetChain(nil)
				v3 = nil

				if v2 == v5 then
					v2 = nil
				end

				v5:Fire(true)
				v5:Destroy()
				break
			else
				task.wait(WAIT_INTERVAL)
			end
		end
	end)
	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopGuide()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	GuideArrow:SetChain(nil)
	v3 = nil

	if v2 then
		local v4 = v2
		v2 = nil
		v4:Fire(false)
		v4:Destroy()
	end
end

function GuidePath.SetDestination(_, vector2: Vector3?, value: number?, p: string?)
	stopGuide() -- equivalent call inferred; original call site unknown

	if not vector2 then
		return nil
	end

	local v4 = value or 8
	local v5 = Signal.new()
	v2 = v5
	local v6 = nil
	thread = task.spawn(function()
		local WAIT_INTERVAL = 0.1
		local v7 = 0
		local v8 = nil
		local v9 = 1
		local v10 = {}

		while true do
			local characterRoot = getCharacterRoot() -- equivalent call inferred; original call site unknown

			if characterRoot then
				local now, v11, v12, v13, v14, v15, v16

				if v6 then
					if not v6() then
						now = os.clock()
						v11 = v7 <= now

						if not v11 and v8 and v9 <= #v8 and (characterRoot.Position - v8[v9]).Magnitude > 15 or v11 then
							v8 = computePath(characterRoot.Position, vector2)
							v7 = now + 2
							v9 = 1
						end

						if v8 and #v8 > 0 then
							while v9 <= #v8 and (characterRoot.Position - v8[v9]).Magnitude <= 4 do
								v9 += 1
							end

							if #v8 < v9 then
								v12 = { vector2 }
							else
								v13 = characterRoot.Position + createVector(0, 3, 0)
								v14 = buildChain

								if not v3 then
									rebuildRaycastParams()
								end

								v12 = v14(v13, v8, v9, v3)
							end
						else
							v12 = { vector2 }
						end

						if #v12 == #v10 then
							local flag = true

							for i = 1, #v12 do
								if v12[i] == v10[i] then
									continue
								end

								v15 = false
								flag = false
								break
							end

							if flag then
								v15 = true
							end
						else
							v15 = false
						end

						if not v15 then
							v16 = #v10 > 0
							GuideArrow:SetChain(v12, p)

							if not v16 then
								v3 = nil
							end

							v10 = v12
						end

						task.wait(WAIT_INTERVAL)
						continue
					end
				elseif not ((characterRoot.Position - vector2).Magnitude <= v4) then
					now = os.clock()
					v11 = v7 <= now

					if not v11 and v8 and v9 <= #v8 and (characterRoot.Position - v8[v9]).Magnitude > 15 or v11 then
						v8 = computePath(characterRoot.Position, vector2)
						v7 = now + 2
						v9 = 1
					end

					if v8 and #v8 > 0 then
						while v9 <= #v8 and (characterRoot.Position - v8[v9]).Magnitude <= 4 do
							v9 += 1
						end

						if #v8 < v9 then
							v12 = { vector2 }
						else
							v13 = characterRoot.Position + createVector(0, 3, 0)
							v14 = buildChain

							if not v3 then
								rebuildRaycastParams()
							end

							v12 = v14(v13, v8, v9, v3)
						end
					else
						v12 = { vector2 }
					end

					if #v12 == #v10 then
						local flag = true

						for i = 1, #v12 do
							if v12[i] == v10[i] then
								continue
							end

							v15 = false
							flag = false
							break
						end

						if flag then
							v15 = true
						end
					else
						v15 = false
					end

					if not v15 then
						v16 = #v10 > 0
						GuideArrow:SetChain(v12, p)

						if not v16 then
							v3 = nil
						end

						v10 = v12
					end

					task.wait(WAIT_INTERVAL)
					continue
				end

				thread = nil
				GuideArrow:SetChain(nil)
				v3 = nil

				if v2 == v5 then
					v2 = nil
				end

				v5:Fire(true)
				v5:Destroy()
				break
			else
				task.wait(WAIT_INTERVAL)
			end
		end
	end)
	return v5
end

function GuidePath.SetDestinationUntil(_, vector2: Vector3?, callback, p: string?)
	stopGuide() -- equivalent call inferred; original call site unknown

	if not (vector2 and callback) then
		return nil
	end

	local v4 = Signal.new()
	v2 = v4
	local v5 = 8
	thread = task.spawn(function()
		local WAIT_INTERVAL = 0.1
		local v6 = 0
		local v7 = nil
		local v8 = 1
		local v9 = {}

		while true do
			local characterRoot = getCharacterRoot() -- equivalent call inferred; original call site unknown

			if characterRoot then
				local now, v10, v11, v12, v13, v14, v15

				if callback then
					if not callback() then
						now = os.clock()
						v10 = v6 <= now

						if not v10 and v7 and v8 <= #v7 and (characterRoot.Position - v7[v8]).Magnitude > 15 or v10 then
							v7 = computePath(characterRoot.Position, vector2)
							v6 = now + 2
							v8 = 1
						end

						if v7 and #v7 > 0 then
							while v8 <= #v7 and (characterRoot.Position - v7[v8]).Magnitude <= 4 do
								v8 += 1
							end

							if #v7 < v8 then
								v11 = { vector2 }
							else
								v12 = characterRoot.Position + createVector(0, 3, 0)
								v13 = buildChain

								if not v3 then
									rebuildRaycastParams()
								end

								v11 = v13(v12, v7, v8, v3)
							end
						else
							v11 = { vector2 }
						end

						if #v11 == #v9 then
							local flag = true

							for i = 1, #v11 do
								if v11[i] == v9[i] then
									continue
								end

								v14 = false
								flag = false
								break
							end

							if flag then
								v14 = true
							end
						else
							v14 = false
						end

						if not v14 then
							v15 = #v9 > 0
							GuideArrow:SetChain(v11, p)

							if not v15 then
								v3 = nil
							end

							v9 = v11
						end

						task.wait(WAIT_INTERVAL)
						continue
					end
				elseif not ((characterRoot.Position - vector2).Magnitude <= v5) then
					now = os.clock()
					v10 = v6 <= now

					if not v10 and v7 and v8 <= #v7 and (characterRoot.Position - v7[v8]).Magnitude > 15 or v10 then
						v7 = computePath(characterRoot.Position, vector2)
						v6 = now + 2
						v8 = 1
					end

					if v7 and #v7 > 0 then
						while v8 <= #v7 and (characterRoot.Position - v7[v8]).Magnitude <= 4 do
							v8 += 1
						end

						if #v7 < v8 then
							v11 = { vector2 }
						else
							v12 = characterRoot.Position + createVector(0, 3, 0)
							v13 = buildChain

							if not v3 then
								rebuildRaycastParams()
							end

							v11 = v13(v12, v7, v8, v3)
						end
					else
						v11 = { vector2 }
					end

					if #v11 == #v9 then
						local flag = true

						for i = 1, #v11 do
							if v11[i] == v9[i] then
								continue
							end

							v14 = false
							flag = false
							break
						end

						if flag then
							v14 = true
						end
					else
						v14 = false
					end

					if not v14 then
						v15 = #v9 > 0
						GuideArrow:SetChain(v11, p)

						if not v15 then
							v3 = nil
						end

						v9 = v11
					end

					task.wait(WAIT_INTERVAL)
					continue
				end

				thread = nil
				GuideArrow:SetChain(nil)
				v3 = nil

				if v2 == v4 then
					v2 = nil
				end

				v4:Fire(true)
				v4:Destroy()
				break
			else
				task.wait(WAIT_INTERVAL)
			end
		end
	end)
	return v4
end

return GuidePath