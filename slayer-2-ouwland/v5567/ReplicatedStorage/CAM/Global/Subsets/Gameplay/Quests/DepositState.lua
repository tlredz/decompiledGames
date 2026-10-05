local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
require(ReplicatedStorage.Packages.cleanit)
local clientEffects = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("CnC"):WaitForChild("ClientEffects")

local function invisibleAnchor(name: string, position: Vector3)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = position
	return part
end

local function spawnScene(maid, p: string, position: Vector3, list, data)
	local v

	if data.Model == nil then
		local promptAt = data.PromptAt or position
		v = Instance.new("Part")
		v.Name = "Deposit"
		v.Anchored = true
		v.CanCollide = false
		v.CanQuery = false
		v.CanTouch = false
		v.Transparency = 1
		v.Size = createVector(1, 1, 1)
		v.Position = promptAt
	else
		v = data.Model:Clone()
		v:PivotTo(CFrame.new(position))
	end

	v.Name = data.ObjectText or "Deposit"
	local primaryPart

	if v:IsA("Model") then
		primaryPart = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
	else
		primaryPart = v
	end

	if primaryPart == nil then
		warn((`[DepositState] "{p}": the Model prop has no BasePart to anchor the prompt to`))
		v:Destroy()
		return nil, function(_: string) end
	else
		v.Parent = workspace
		local v2 = (#list + 1) * 1.3
		local billboardAt = data.BillboardAt or position + vector.create(0, v2 / 2 + 4, 0)
		local part = Instance.new("Part")
		part.Name = "DepositProgressAnchor"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.Position = billboardAt
		part.Parent = workspace.Debree
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "DepositProgress"
		billboardGui.Size = UDim2.fromScale(7, v2)
		billboardGui.MaxDistance = 60
		billboardGui.LightInfluence = 0
		billboardGui.Parent = part
		local UIDepositProgress = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.UIDepositProgress)
		local uIDepositProgress = UIDepositProgress(billboardGui, list, data.Title or data.ObjectText or "Delivery")
		maid:Add(function()
			uIDepositProgress()
			v:Destroy()
			task.delay(0.5, part.Destroy, part)
		end)
		local burstAt = data.BurstAt or position
		local vfxScale = data.VfxScale or 1
		return primaryPart, function(p2: string)
			clientEffects:Fire("QuestDeposit", burstAt, p2, vfxScale)
		end
	end
end

return {
	forTasks = function(p: string, items, options)
		local v = options or {}
		local v2 = math.max(v.Interval or 0.15, 0.15)
		return {
			Do = function(player, p2, object)
				local v3 = Quests.Holder[p]
				local taskSpecs

				if v3 ~= nil then
					taskSpecs = v3.TaskSpecs or nil
				end

				if taskSpecs == nil then
					warn((`[DepositState] no TaskSpecs for "{p}" — no deposit prop spawned`))
					return
				end

				local v4 = nil
				local v5 = {}

				for _, childName in items do
					local taskSpec = taskSpecs[childName]
					local child = p2.Tasks:WaitForChild(childName, 5)
					local value

					if child ~= nil then
						value = child:WaitForChild("Value", 5) or nil
					end

					local max

					if child ~= nil then
						max = child:WaitForChild("Max", 5) or nil
					end

					if taskSpec == nil or taskSpec.RequiredItem == nil or taskSpec.Position == nil or value == nil or max == nil then
						warn((`[DepositState] "{p}" / "{childName}": needs a Deposit spec with RequiredItem + Position, and a live task`))
					else
						if v4 ~= nil and taskSpec.Position ~= v4 then
							warn((`[DepositState] "{p}" / "{childName}": Position differs from the prop's — its deposits will be server-rejected`))
						end

						v4 = v4 or taskSpec.Position
						table.insert(v5, {
							Name = childName,
							Item = taskSpec.RequiredItem,
							Value = value,
							Max = max
						})
					end
				end

				if v4 == nil then
					return
				end

				local data = Utility.GetData(player)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function stocked()
					for _, v6 in v5 do
						if v6.Value.Value < v6.Max.Value then
							return false
						end
					end

					return true
				end

				local function nextRow()
					for _, v6 in v5 do
						if not (v6.Value.Value < v6.Max.Value) then
							continue
						end

						local heldItem = Utility.HeldItem(data, v6.Item)
						local amount

						if heldItem ~= nil then
							amount = heldItem:FindFirstChild("Amount") or nil
						end

						if (heldItem == nil and 0 or amount == nil and 1 or amount.Value) > 0 then
							return v6
						end
					end

					return nil
				end

				local parent, v7 = spawnScene(object, p, v4, v5, v)

				if parent == nil then
					return
				end

				local total = 0

				for _, v8 in v5 do
					total += v8.Max.Value
				end

				local prompt = Utility.CreatePrompt({
					ActionText = v.ActionText or "Stock",
					ObjectText = v.ObjectText or "Deposit",
					HoldDuration = total * v2 * 1.3 + v2,
					Parent = parent
				})
				local v8 = stocked() -- equivalent call inferred; original call site unknown
				prompt.Enabled = not v8
				local count = 0
				local v9 = nil
				local track = nil

				-- equivalent calls inferred from this helper; original call sites unknown
				local function endHold()
					count += 1
					v7("Stop")

					if v9 ~= nil then
						v9:Destroy()
						v9 = nil
					end

					if track ~= nil then
						track:Stop(0.2)
						track:Destroy()
						track = nil
					end
				end

				object:Add(endHold)
				object:Connect(prompt.PromptButtonHoldBegan, function()
					endHold() -- equivalent call inferred; original call site unknown
					local v10 = count
					local character = player.Character
					local humanoidRootPart

					if character ~= nil then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or nil
					end

					if humanoidRootPart ~= nil then
						v9 = Utility.AddValue(humanoidRootPart, "skill_stand_still")
					end

					local humanoid

					if character ~= nil then
						humanoid = character:FindFirstChildOfClass("Humanoid") or nil
					end

					if humanoid ~= nil then
						track = humanoid.Animator:LoadAnimation(script.Working)
						track:Play(0.2)
					end

					task.spawn(function()
						while count == v10 do
							local v11 = nextRow()

							if v11 == nil then
								break
							end

							v7("Start")
							SignalEvent.ToServer("QuestProgress", p, v11.Name)
							task.wait(v2)
						end

						if count ~= v10 or prompt.Parent == nil then
							return
						end

						endHold() -- equivalent call inferred; original call site unknown
						prompt.Enabled = false
						task.defer(function()
							local v11 = prompt
							local enabled

							if prompt.Parent == nil then
								enabled = false
							else
								local v13 = stocked() -- equivalent call inferred; original call site unknown
								enabled = not v13
							end

							v11.Enabled = enabled
						end)
					end)
				end)
				object:Connect(prompt.PromptButtonHoldEnded, endHold)

				for _, v10 in v5 do
					object:Connect(v10.Value.Changed, function()
						v7("Burst")

						-- equivalent call inferred; original call site unknown
						if not stocked() then
							return
						end

						endHold() -- equivalent call inferred; original call site unknown
						prompt.Enabled = false
					end)
				end
			end
		}
	end
}