local createVector = vector.create
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local localPlayer = Players.LocalPlayer
local v = nil
local positions = {}
local position = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = false
local v6 = nil
local now = 0
local v7 = 16
local total = 0
local v8 = 0
local count = 0
local v9 = 0
local v10 = nil
local v11 = false
return {
	Start = function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function debugEnabled()
			return Workspace:GetAttribute("ClientObbyAntiTpDebug") == true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function dprint(p: string)
			if debugEnabled() then
				print("[ObbyAntiTP] " .. p)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function nowClock()
			return os.clock()
		end

		local function parseRegionAttribute()
			local anticheatSuspendedRegion = Workspace:GetAttribute("AnticheatSuspendedRegion")

			if typeof(anticheatSuspendedRegion) ~= "string" then
				return nil
			end

			local v12 = {}

			for k in string.gmatch(anticheatSuspendedRegion, "[^,]+") do
				local v13 = tonumber(k)

				if v13 == nil then
					return nil
				else
					table.insert(v12, v13)
				end
			end

			if #v12 == 6 then
				return {
					Min = Vector3.new(v12[1], v12[2], v12[3]),
					Max = Vector3.new(v12[4], v12[5], v12[6])
				}
			end

			return nil
		end

		local function regionFromMap(folder)
			local vector2 = nil
			local vector3 = nil

			for _, part in folder:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				local position2 = part.Position
				local v12 = part.Size * 0.5
				local v13 = position2 - v12
				local v14 = position2 + v12

				if vector2 then
					vector2 = Vector3.new(
						math.min(vector2.X, v13.X),
						math.min(vector2.Y, v13.Y),
						(math.min(vector2.Z, v13.Z))
					)
				else
					vector2 = v13
				end

				if vector3 then
					vector3 = Vector3.new(
						math.max(vector3.X, v14.X),
						math.max(vector3.Y, v14.Y),
						(math.max(vector3.Z, v14.Z))
					)
				else
					vector3 = v14
				end
			end

			if vector2 == nil or vector3 == nil then
				return nil
			end

			return {
				Min = vector2 - createVector(25, 25, 25),
				Max = vector3 + createVector(25, 25, 25)
			}
		end

		local function collectMapLandmarks(monsterEventMap)
			table.clear(positions)
			position = nil

			if monsterEventMap == nil then
				return
			end

			local winParts = monsterEventMap:FindFirstChild("WinParts")

			if winParts ~= nil then
				for _, part in winParts:GetChildren() do
					if part:IsA("BasePart") then
						table.insert(positions, part.Position)
					end
				end
			end

			local obbyRespawn = monsterEventMap:FindFirstChild("ObbyRespawn")

			if obbyRespawn ~= nil and obbyRespawn:IsA("BasePart") then
				position = obbyRespawn.Position
			end
		end

		local function refreshRegion()
			local monsterEventMap = Workspace:FindFirstChild("MonsterEventMap")
			local v12 = parseRegionAttribute()

			if v12 == nil and monsterEventMap ~= nil then
				v12 = regionFromMap(monsterEventMap)
			end

			v = v12
			collectMapLandmarks(monsterEventMap)

			if v == nil then
				if debugEnabled() then
					print("[ObbyAntiTP] disarmed: no event region")
				end
			else
				dprint(("armed: region %s -> %s, %d win gates"):format(tostring(v.Min), tostring(v.Max), #positions)) -- equivalent call inferred; original call site unknown
			end
		end

		local function inRegion(position2: Vector3)
			local v12 = v

			if v12 == nil then
				return false
			end

			return position2.X >= v12.Min.X and position2.X <= v12.Max.X and position2.Y >= v12.Min.Y and position2.Y <= v12.Max.Y and position2.Z >= v12.Min.Z and position2.Z <= v12.Max.Z
		end

		local function isEnabled()
			return Workspace:GetAttribute("ClientObbyAntiTp") ~= false and v ~= nil
		end

		local function horizontal(vector2: Vector3, vector3: Vector3)
			return ((vector2 - vector3) * createVector(1, 0, 1)).Magnitude
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function grace(p: number)
			v8 = math.max(v8, os.clock() + p)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rebaseline(position2: Vector3?)
			local v12 = v4

			if position2 == nil and v12 ~= nil then
				position2 = v12.Position
			end

			v6 = position2
			now = os.clock()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function jumpVelocity(data)
			if data.UseJumpPower then
				return (math.max(data.JumpPower, 0))
			end

			return (math.sqrt(math.max(Workspace.Gravity, 0) * 2 * math.max(data.JumpHeight, 0)))
		end

		local function nearWinPart(vector2: Vector3)
			for _, v12 in positions do
				if (vector2 - v12).Magnitude <= 30 then
					return true
				end
			end

			return false
		end

		local function nearObbyRespawn(vector2: Vector3)
			return position ~= nil and (vector2 - position).Magnitude <= 25
		end

		local function lagback(position2: Vector3)
			local v12 = v2
			local v13 = v4
			local v14 = v3

			if v12 == nil or v13 == nil or v14 == nil then
				return
			end

			v14.Sit = false
			v13.AssemblyLinearVelocity = createVector(0, 0, 0)
			v13.AssemblyAngularVelocity = createVector(0, 0, 0)
			v12:PivotTo(CFrame.new(position2) * v13.CFrame.Rotation)
			local v15 = v4

			if position2 == nil and v15 ~= nil then
				position2 = v15.Position
			end

			v6 = position2
			now = os.clock()
			grace(0.3) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function kill(formatted: string)
			local v12 = v4
			local v13 = v3
			v5 = true
			dprint("KILL: " .. formatted) -- equivalent call inferred; original call site unknown

			if v12 ~= nil then
				v12.AssemblyLinearVelocity = createVector(0, 0, 0)
				v12.AssemblyAngularVelocity = createVector(0, 0, 0)
			end

			if v13 ~= nil then
				v13.Health = 0
				v13:ChangeState(Enum.HumanoidStateType.Dead)
			end
		end

		local function punish(position2: Vector3, vector2: Vector3, magnitude: number, p: number, p2: number)
			if p2 - v9 > 5 then
				count = 0
			end

			count += 1
			v9 = p2
			local flag

			if magnitude >= 300 or p >= 150 or count >= 6 then
				flag = true
			elseif magnitude >= 100 then
				local flag2 = true

				for _, v12 in positions do
					if not ((position2 - v12).Magnitude <= 30) then
						continue
					end

					flag = true
					flag2 = false
					break
				end

				if flag2 then
					flag = false
				end
			else
				flag = false
			end

			dprint(("flag #%d: moved %.0f (up %.0f)%s"):format(count, magnitude, p, flag and " EXTREME" or "")) -- equivalent call inferred; original call site unknown
			lagback(vector2)

			if flag then
				local v12 = count
				count = 0
				kill(("jump %.0f studs (up %.0f), flags %d"):format(magnitude, p, v12)) -- equivalent call inferred; original call site unknown
			end
		end

		local function check()
			local v12 = v4
			local v13 = v3

			if v12 == nil or v13 == nil or v5 then
				return
			end

			if v13.Health <= 0 or not v12:IsDescendantOf(Workspace) then
				return
			end

			local v14 = nowClock() -- equivalent call inferred; original call site unknown
			local v15 = v14 - now

			if v15 < 0.1 then
				return
			end

			now = v14
			local position2 = v12.Position
			local v16

			if Workspace:GetAttribute("ClientObbyAntiTp") == false then
				v16 = false
			else
				v16 = v ~= nil
			end

			if v16 then
				local v17 = math.clamp(v13.WalkSpeed, 2, 1000)

				if v7 <= v17 then
					v7 = v17
					total = 0
				else
					total += math.min(v15, 0.4)

					if total >= 3 then
						v7 = v17
					end
				end

				local v18 = inRegion(position2)

				if v18 and v11 then
					if v13.Sit or v13.PlatformStand then
						grace(1.5) -- equivalent call inferred; original call site unknown
						v6 = position2
					else
						local v19 = v10

						if v19 ~= nil then
							if v19.ExpiresAt <= v14 then
								v10 = nil
							elseif (position2 - v19.Target).Magnitude <= 15 then
								v10 = nil
								v6 = position2
								return
							end
						end

						if v14 < v8 then
							v6 = position2
							return
						end

						if v15 > 1 or v6 == nil then
							v6 = position2
							return
						end

						local v20 = math.min(v15, 0.4)
						local v21 = v6
						local assemblyLinearVelocity = v12.AssemblyLinearVelocity
						local v22 = math.min((assemblyLinearVelocity * createVector(1, 0, 1)).Magnitude, 400)
						local v23 = math.clamp(assemblyLinearVelocity.Y, 0, 400)
						local v24 = v7 * 1.7000000000000002 * v20 + 14 + v22 * v20
						local magnitude = ((position2 - v21) * createVector(1, 0, 1)).Magnitude
						local v25 = jumpVelocity(v13) -- equivalent call inferred; original call site unknown
						local v26 = math.max(v25, v23) * v20 + 14
						local v27 = position2.Y - v21.Y
						local v28 = v24 + 80 < magnitude
						local v29 = v26 + 60 < v27

						if not (v28 or v29) then
							v6 = position2
							return
						end

						local v30 = position
						local v31

						if v30 == nil then
							v31 = false
						else
							v31 = (position2 - v30).Magnitude <= 25
						end

						if v31 then
							v6 = position2
						else
							punish(position2, v21, magnitude, math.max(v27, 0), v14)
						end
					end
				else
					v11 = v18
					v6 = position2
				end
			else
				v6 = position2
				v11 = false
			end
		end

		Remotes.RigSync.Refresh.OnClientEvent:Connect(function(json)
			if typeof(json) ~= "string" then
				return
			end

			local success, result = pcall(function()
				return HttpService:JSONDecode(json)
			end)

			if not success or typeof(result) ~= "table" then
				return
			end

			local action = result.Action
			local arguments = result.Arguments
			local v12 = typeof(arguments) ~= "table" and {} or arguments

			if action == "Relocate" then
				local v13 = tonumber(v12[1])
				local v14 = tonumber(v12[2])
				local v15 = tonumber(v12[3])

				if v13 ~= nil and v14 ~= nil and v15 ~= nil then
					v10 = {
						Target = Vector3.new(v13, v14, v15),
						ExpiresAt = os.clock() + 8
					}
				end

				grace(1) -- equivalent call inferred; original call site unknown

				if debugEnabled() then
					print("[ObbyAntiTP] grace: server relocation")
				end
			elseif action == "BeginImpulse" or action == "BeginRagdoll" then
				grace(math.clamp(tonumber(v12[1]) or 1, 1, 5) + 0.5) -- equivalent call inferred; original call site unknown
				dprint("grace: server " .. tostring(action)) -- equivalent call inferred; original call site unknown
			elseif action == "EndRagdoll" then
				grace(1) -- equivalent call inferred; original call site unknown
			end
		end)

		local function onCharacter(instance)
			v5 = false
			count = 0
			v10 = nil
			v11 = false
			v2 = instance
			v3 = nil
			v4 = nil
			v6 = nil
			local humanoid = instance:WaitForChild("Humanoid", 10)
			local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 10)

			if humanoid == nil or not humanoid:IsA("Humanoid") or humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") or localPlayer.Character ~= instance then
				return
			end

			v3 = humanoid
			v4 = humanoidRootPart
			v7 = math.clamp(humanoid.WalkSpeed, 2, 1000)
			total = 0
			grace(3) -- equivalent call inferred; original call site unknown
			rebaseline(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
			humanoid.Died:Connect(function()
				v5 = true
			end)
		end

		localPlayer.CharacterAdded:Connect(onCharacter)

		if localPlayer.Character ~= nil then
			task.spawn(onCharacter, localPlayer.Character)
		end

		Workspace:GetAttributeChangedSignal("AnticheatSuspendedRegion"):Connect(refreshRegion)
		Workspace.ChildAdded:Connect(function(child)
			if child.Name == "MonsterEventMap" then
				task.defer(refreshRegion)
			end
		end)
		Workspace.ChildRemoved:Connect(function(child)
			if child.Name == "MonsterEventMap" then
				task.defer(refreshRegion)
			end
		end)
		refreshRegion()
		RunService.Heartbeat:Connect(check)
	end
}