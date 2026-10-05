local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
require(ReplicatedStorage.Packages.cleanit)
local clientEffects = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("CnC"):WaitForChild("ClientEffects")

local function spawnPickup(maid, position: Vector3, p: number, p2, fn)
	local v

	if p2.Model == nil then
		v = Instance.new("Part")
		v.Anchored = true
		v.CanCollide = false
		v.Material = Enum.Material.Neon
		v.Color = Color3.new(1, 0.95, 0.7)
		v.Size = createVector(1.5, 0.2, 2)
		v.Position = position
	else
		v = p2.Model:Clone()
		v:PivotTo(CFrame.new(position))

		if v:IsA("BasePart") then
			v.Anchored = true
		end

		for _, v2 in v:QueryDescendants("BasePart") do
			v2.Anchored = true
		end
	end

	v.Name = (p2.ObjectText or "Pickup") .. p
	local createPrompt = Utility.CreatePrompt
	local v2 = {
		ActionText = "Pick Up",
		ObjectText = p2.ObjectText or "Pickup",
		Parent = 0
	}
	local parent

	if v:IsA("Model") then
		parent = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
	else
		parent = v
	end

	v2.Parent = parent
	createPrompt(v2).Triggered:Connect(function()
		maid:Remove(v)
		v:Destroy()
		clientEffects:Fire("QuestPickup", position)
		fn(p)
	end)
	v.Parent = workspace
	maid:Add(v)
end

return {
	forTask = function(p: string, p2: string, options)
		local v = options or {}
		return {
			Tasks = {
				[p2] = {
					Do = function(_, instance, maid)
						local v2 = Quests.Holder[p]
						local v3

						if v2 == nil or v2.TaskSpecs == nil then
							v3 = nil
						else
							v3 = v2.TaskSpecs[p2] or nil
						end

						if v3 == nil or v3.Positions == nil then
							warn((`[PickupState] no Pickup TaskSpec/Positions for "{p}" / "{p2}" — no props spawned`))
							return
						end

						local fn = typeof(v3.Positions) ~= "function" and function(p3)
							return v3.Positions[p3]
						end or v3.Positions
						local spawnCount

						if typeof(v3.Positions) == "function" then
							spawnCount = v3.SpawnCount or 1
						else
							spawnCount = #v3.Positions
						end

						local spawnAt

						spawnAt = function(i: number, value: number?)
							local position = fn(i)

							if position ~= nil then
								spawnPickup(maid, position, i, v, function(p3)
									SignalEvent.ToServer("QuestProgress", p, p2, p3)

									if v3.RespawnTime ~= nil then
										maid:Add(task.delay(v3.RespawnTime, spawnAt, p3))
									end
								end)
								return
							end

							local v5 = (value or 0) + 1

							if v5 == 20 then
								warn((`[PickupState] "{p}" / "{p2}" slot {i}: placement function still returning nil after {20} tries`))
							end

							maid:Add(task.delay(0.5, spawnAt, i, v5))
						end

						for i = 1, spawnCount do
							local attribute = instance:GetAttribute("Picked" .. i)

							if v3.RespawnTime == nil then
								if attribute ~= true then
									spawnAt(i)
								end
							else
								local v4 = typeof(attribute) ~= "number" and 0 or v3.RespawnTime - (os.time() - attribute)

								if v4 > 0 then
									maid:Add(task.delay(v4, spawnAt, i))
								else
									spawnAt(i)
								end
							end
						end
					end
				}
			}
		}
	end
}