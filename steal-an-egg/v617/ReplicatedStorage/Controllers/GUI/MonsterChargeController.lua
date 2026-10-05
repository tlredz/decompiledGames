local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local MonsterParasiteEligibility = require(ReplicatedStorage.Shared.Util.MonsterParasiteEligibility)
local MonsterParasite2 = require(ReplicatedStorage.Shared.Types.MonsterParasite)
require(ReplicatedStorage.Packages.Networking)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
return {
	Start = function()
		local monsterParasite = Remotes.MonsterParasite
		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local v = Trove.new()
		local v2 = {
			Active = false,
			EndsAt = 0,
			ServerTime = 0
		}
		v2.EndsAt = MonsterParasite.EndsAt
		v2.ServerTime = os.time()
		local v3 = 0
		local v4 = nil
		local v5 = nil
		local v6 = nil
		local v7 = nil
		local v8 = nil
		local v9 = false
		local YsByAttribute = {}
		local v10 = nil
		local flag = true
		local v11 = 0
		local v12 = 0
		local v13 = nil
		local now = 0
		local v14 = nil
		local v15 = false
		local now2 = 0
		local charge = nil
		local charge2 = nil
		local v16 = {}
		local v17 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function formatRemaining(p: number)
			local v18 = math.max(math.floor(p), 0)
			local v19 = v18 // 86400
			local v20 = v18 % 86400 // 3600
			local v21 = v18 % 3600 // 60

			if v19 > 0 then
				return (`{v19}d {v20}h`)
			end

			return (`{v20}h {v21}m`)
		end

		local function getOwnedMonster()
			local folder = Workspace:FindFirstChild(MonsterParasite.WorldFolderName)

			if folder == nil or not folder:IsA("Folder") then
				return nil
			end

			for _, model in folder:GetChildren() do
				if model:IsA("Model") and model:GetAttribute("OwnerUserId") == localPlayer.UserId then
					return model
				end
			end

			return nil
		end

		local function resolveTemplate()
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local extra

			if assets then
				extra = assets:FindFirstChild("Extra")
			end

			local monsterBillboardAttachment

			if extra then
				monsterBillboardAttachment = extra:FindFirstChild("MonsterBillboardAttachment")
			end

			if monsterBillboardAttachment ~= nil and monsterBillboardAttachment:IsA("Attachment") then
				return monsterBillboardAttachment
			end

			if not v9 then
				v9 = true
				warn("[MonsterCharge] Missing ReplicatedStorage.Assets.Extra.MonsterBillboardAttachment; the monster billboard is skipped")
			end

			return nil
		end

		local function resolveMonsterTemplate(attribute: number)
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local models

			if assets then
				models = assets:FindFirstChild("Models")
			end

			local child

			if models then
				child = models:FindFirstChild(MonsterParasite.AssetsFolderName)
			end

			local monsterModelName = MonsterParasite.MonsterModelNames[attribute]
			local model

			if child and monsterModelName then
				model = child:FindFirstChild(monsterModelName)
			end

			if model and model:IsA("Model") and model.PrimaryPart then
				return model
			end

			return nil
		end

		local function measureHeadHeight(instance)
			local primaryPart = instance.PrimaryPart

			if primaryPart == nil then
				return nil
			end

			local boundingBox, v18 = instance:GetBoundingBox()
			local v19 = boundingBox.Position + createVector(0, 1, 0) * (v18.Y * 0.5)
			return primaryPart.CFrame:PointToObjectSpace(v19).Y
		end

		local function resolveBillboardHeight(instance, billboardGui)
			local attribute = instance:GetAttribute(MonsterParasite.MonsterModelIndexAttributeName)

			if typeof(attribute) ~= "number" then
				attribute = nil
			end

			local Y

			if attribute then
				Y = YsByAttribute[attribute]
			end

			if Y == nil then
				local v18

				if attribute then
					v18 = resolveMonsterTemplate(attribute)
				end

				if v18 then
					local primaryPart = v18.PrimaryPart

					if primaryPart == nil then
						Y = nil
					else
						local boundingBox, v19 = v18:GetBoundingBox()
						local v20 = boundingBox.Position + createVector(0, 1, 0) * (v19.Y * 0.5)
						Y = primaryPart.CFrame:PointToObjectSpace(v20).Y
					end
				else
					Y = nil
				end

				if not Y then
					local primaryPart = instance.PrimaryPart

					if primaryPart == nil then
						Y = nil
					else
						local boundingBox, v19 = instance:GetBoundingBox()
						local v20 = boundingBox.Position + createVector(0, 1, 0) * (v19.Y * 0.5)
						Y = primaryPart.CFrame:PointToObjectSpace(v20).Y
					end
				end

				if Y ~= nil and attribute ~= nil then
					YsByAttribute[attribute] = Y
				end
			end

			if Y == nil then
				return 8.5
			end

			return Y + (not billboardGui and 2 or billboardGui.Size.Y.Scale * 0.5) + 0.75
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setLabelText(instance, childName: string, text: string)
			local label = instance:FindFirstChild(childName, true)

			if label ~= nil and label:IsA("TextLabel") then
				label.Text = text
			end
		end

		local function resolveDebrisFolder()
			local transient = Workspace:FindFirstChild("Transient")

			if transient == nil then
				return Workspace
			end

			return transient
		end

		local function createAnchor()
			local part = Instance.new("Part")
			part.Name = "MonsterBillboardAnchor"
			part.Size = createVector(0.1, 0.1, 0.1)
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Massless = true
			part.Locked = true
			part.Archivable = false
			local transient = Workspace:FindFirstChild("Transient")

			if transient == nil then
				transient = Workspace
			end

			part.Parent = transient
			return part
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyBillboard()
			if v4 ~= nil then
				v4:Destroy()
				v4 = nil
			end

			v5 = nil
			v6 = nil
			v7 = nil
			v8 = nil
			v10 = nil
			flag = true
		end

		local function ensureBillboard(ownedMonster)
			local primaryPart = ownedMonster.PrimaryPart

			if primaryPart == nil then
				destroyBillboard() -- equivalent call inferred; original call site unknown
				return nil
			else
				local template = resolveTemplate()

				if template == nil then
					destroyBillboard() -- equivalent call inferred; original call site unknown
					return nil
				else
					local parent = v4

					if parent ~= nil and parent.Parent == nil then
						destroyBillboard() -- equivalent call inferred; original call site unknown
						parent = nil
					end

					local clone = v5

					if parent == nil or clone == nil then
						destroyBillboard() -- equivalent call inferred; original call site unknown
						parent = Instance.new("Part")
						parent.Name = "MonsterBillboardAnchor"
						parent.Size = createVector(0.1, 0.1, 0.1)
						parent.Transparency = 1
						parent.Anchored = true
						parent.CanCollide = false
						parent.CanQuery = false
						parent.CanTouch = false
						parent.CastShadow = false
						parent.Massless = true
						parent.Locked = true
						parent.Archivable = false
						local transient = Workspace:FindFirstChild("Transient")

						if transient == nil then
							transient = Workspace
						end

						parent.Parent = transient
						clone = template:Clone()
						clone.Parent = parent
						v4 = parent
						v5 = clone
						setLabelText(clone, "MonsterName", MonsterParasite.MonsterDisplayName) -- equivalent call inferred; original call site unknown
						local progress = clone:FindFirstChild("Progress", true)
						local fill

						if progress then
							fill = progress:FindFirstChild("Fill")
						end

						local progress2

						if progress then
							progress2 = progress:FindFirstChild("Progress", true)
						end

						if not (fill and fill:IsA("GuiObject")) then
							fill = nil
						end

						v6 = fill

						if not (progress2 and progress2:IsA("TextLabel")) then
							progress2 = nil
						end

						v7 = progress2
					end

					if parent.CFrame ~= primaryPart.CFrame then
						parent.CFrame = primaryPart.CFrame
					end

					local billboardHeight = resolveBillboardHeight(
						ownedMonster,
						clone:FindFirstChildWhichIsA("BillboardGui")
					)
					v10 = billboardHeight

					if flag then
						flag = false
						clone.Position = Vector3.new(0, billboardHeight, 0)
					end

					v8 = ownedMonster
					return clone
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshTargetAlpha()
			v11 = v15 and 1 or math.clamp((charge2 or 0) / MonsterParasite.MaxCharge, 0, 1)
		end

		local function render()
			local v18 = Save.Await()
			local v19

			if v18 == nil then
				v19 = false
			else
				v19 = MonsterParasiteEligibility.IsEligible(v18.SpeedPower)
			end

			local ownedMonster = getOwnedMonster()

			if v18 == nil or not v19 or not v2.Active or ownedMonster == nil then
				destroyBillboard() -- equivalent call inferred; original call site unknown
				charge = nil
				charge2 = nil
				table.clear(v16)
				v15 = false
				v13 = nil
				v12 = 0
				v11 = 0
			else
				local billboard = ensureBillboard(ownedMonster)

				if billboard == nil then
					return
				end

				local monsterParasite2 = v18.MonsterParasite
				local v20 = charge
				charge = monsterParasite2.Charge

				if charge2 == nil then
					charge2 = monsterParasite2.Charge
				elseif v20 ~= nil and monsterParasite2.Charge ~= v20 then
					table.insert(v16, {
						Wrap = monsterParasite2.Charge < v20,
						Since = os.clock()
					})
				end

				refreshTargetAlpha() -- equivalent call inferred; original call site unknown
				local v21 = os.time() + v3
				local v23 = formatRemaining(v2.EndsAt - v21) -- equivalent call inferred; original call site unknown
				setLabelText(billboard, "Timer", `Leaves in {v23}`) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startDrain()
			v15 = false
			v13 = math.max(v12, v11)
			now = os.clock()
			charge2 = charge
			refreshTargetAlpha() -- equivalent call inferred; original call site unknown
		end

		local function releaseGain()
			local v18 = table.remove(v16, 1)

			if v18 == nil then
				return
			end

			if v18.Wrap then
				charge2 = MonsterParasite.MaxCharge
				v15 = true
				now2 = os.clock()
			else
				charge2 = math.clamp((charge2 or 0) + MonsterParasite.ChargePerFeed, 0, MonsterParasite.MaxCharge)

				if #v16 == 0 then
					charge2 = charge
				end
			end

			refreshTargetAlpha() -- equivalent call inferred; original call site unknown
		end

		local function stepAnchor(p: number)
			local v18 = v4
			local v19 = v5
			local v20 = v10

			if v18 == nil or v19 == nil or v20 == nil then
				return
			end

			local v21 = v8
			local primaryPart

			if v21 ~= nil then
				primaryPart = v21.PrimaryPart
			end

			if primaryPart ~= nil and v18.CFrame ~= primaryPart.CFrame then
				v18.CFrame = primaryPart.CFrame
			end

			local Y = v19.Position.Y

			if math.abs(v20 - Y) < 0.001 then
				if Y ~= v20 then
					v19.Position = Vector3.new(0, v20, 0)
				end
			else
				v19.Position = Vector3.new(0, Y + (v20 - Y) * math.min(p * 9, 1), 0)
			end
		end

		local function stepBar(p: number)
			stepAnchor(p)
			local v18 = v6

			if v18 == nil then
				return
			end

			local attribute = localPlayer:GetAttribute(MonsterParasite2.ChargeGainAttributeName)

			if typeof(attribute) == "number" and attribute ~= v17 then
				v17 = attribute
				releaseGain()
			end

			local v19 = v16[1]

			if v19 ~= nil and os.clock() - v19.Since > MonsterParasite2.ChargeGainCueTimeout then
				releaseGain()
			end

			local v20 = v8
			local attribute2

			if v20 then
				attribute2 = v20:GetAttribute(MonsterParasite2.ChargeDrainAttributeName)
			end

			if typeof(attribute2) == "number" and attribute2 ~= v14 then
				v14 = attribute2
				startDrain() -- equivalent call inferred; original call site unknown
			elseif v15 and os.clock() - now2 > 6 then
				startDrain() -- equivalent call inferred; original call site unknown
			end

			local v21 = v13

			if v21 == nil then
				v12 += (v11 - v12) * math.min(p * 14, 1)

				if math.abs(v11 - v12) < 0.001 then
					v12 = v11
				end
			else
				local v22 = math.clamp((os.clock() - now) / MonsterParasite2.ChargeDrainDuration, 0, 1)
				v12 = v21 * (1 - v22 * v22 * (3 - v22 * 2))

				if v22 >= 1 then
					v13 = nil
					v12 = 0
				end
			end

			local v22 = math.clamp(v12, 0, 1)
			v18.Size = UDim2.fromScale(v22, 1)
			local v23 = v7

			if v23 ~= nil then
				v23.Text = `{math.round(v22 * 100)}%`
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setEventState(p)
			v2 = p
			v3 = p.ServerTime - os.time()
			render()
		end

		local function disableLegacyHud(screenGui)
			if screenGui == nil then
				screenGui = playerGui:FindFirstChild(MonsterParasite.HudName)
			end

			if screenGui ~= nil and screenGui.Name == MonsterParasite.HudName and screenGui:IsA("ScreenGui") then
				screenGui.Enabled = false
			end
		end

		v:Connect(playerGui.ChildAdded, disableLegacyHud)
		local screenGui = playerGui:FindFirstChild(MonsterParasite.HudName)

		if screenGui ~= nil and screenGui.Name == MonsterParasite.HudName and screenGui:IsA("ScreenGui") then
			screenGui.Enabled = false
		end

		v:Connect(Save.Watch("MonsterParasite"), render)
		v:Connect(Save.Watch("SpeedPower"), render)
		v:Connect(monsterParasite.EventStateShifted.OnClientEvent, function(p)
			if MonsterParasite2.EventStateSchema(p) then
				setEventState(p) -- equivalent call inferred; original call site unknown
			end
		end)
		v:Connect(RunService.RenderStepped, stepBar)
		local v18 = Timer.new(0.15)
		v:Add(v18)
		v:Connect(v18.Tick, render)
		v18:Start()
		task.spawn(function()
			local success, result = pcall(function()
				return monsterParasite.AskSnapshot:InvokeServer()
			end)

			if not (success and MonsterParasite2.SnapshotSchema(result)) then
				return
			end

			setEventState(result.Event) -- equivalent call inferred; original call site unknown
		end)
	end
}