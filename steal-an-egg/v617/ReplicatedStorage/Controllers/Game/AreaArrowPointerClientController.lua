local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ArrowPointer3D = require(ReplicatedStorage.Client.WorldFX.ArrowPointer3D)
local localPlayer = Players.LocalPlayer
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local anchorForZone = Remotes.ZoneProbe.AnchorForZone
local v = nil
local v2 = nil
local count = 0
local v3 = nil
local v4 = nil
return {
	Start = function()
		local function resolveTargetPart(instance)
			if instance:IsA("BasePart") then
				return instance
			end

			if not instance:IsA("Model") then
				return nil
			end

			if instance.PrimaryPart == nil then
				return instance:FindFirstChildWhichIsA("BasePart", true)
			end

			return instance.PrimaryPart
		end

		local function findTaggedTargetPart(tag: string)
			for _, basePart in ipairs(CollectionService:GetTagged(tag)) do
				if not basePart:IsDescendantOf(Workspace) then
					continue
				end

				if not basePart:IsA("BasePart") then
					if basePart:IsA("Model") then
						if basePart.PrimaryPart == nil then
							basePart = basePart:FindFirstChildWhichIsA("BasePart", true)
						else
							basePart = basePart.PrimaryPart
						end
					else
						basePart = nil
					end
				end

				if basePart ~= nil then
					return basePart
				end
			end

			return nil
		end

		local function getCharacterRoot()
			local character = localPlayer.Character

			if character == nil then
				return nil
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
				return nil
			end

			return humanoidRootPart
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyArrow()
			if v3 ~= nil then
				v3:Destroy()
				v3 = nil
			end

			v4 = nil
		end

		local function pointArrowAt(taggedTargetPart)
			local character = localPlayer.Character
			local humanoidRootPart

			if character ~= nil then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
					humanoidRootPart = nil
				end
			end

			if humanoidRootPart == nil then
				return
			end

			if v3 ~= nil and v4 == taggedTargetPart then
				v3:PointFrom(humanoidRootPart)
				return
			end

			destroyArrow() -- equivalent call inferred; original call site unknown
			local v5 = ArrowPointer3D.new(taggedTargetPart, humanoidRootPart)
			v5:Start()
			v3 = v5
			v4 = taggedTargetPart
		end

		local function isPlayerInZone(p: string)
			return localPlayer:GetAttribute("AreaId") == p
		end

		local function runZoneLoop(p: string, p2: string, p3: number)
			while v == p and v2 == p2 and count == p3 do
				if localPlayer:GetAttribute("AreaId") == p then
					local taggedTargetPart = findTaggedTargetPart(p2)
					local character = localPlayer.Character
					local humanoidRootPart

					if character ~= nil then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
							humanoidRootPart = nil
						end
					end

					if taggedTargetPart ~= nil and humanoidRootPart ~= nil and (humanoidRootPart.Position - taggedTargetPart.Position).Magnitude <= 25 then
						break
					end

					if taggedTargetPart == nil then
						destroyArrow() -- equivalent call inferred; original call site unknown
					else
						pointArrowAt(taggedTargetPart)
					end

					task.wait(0.25)
				else
					destroyArrow() -- equivalent call inferred; original call site unknown
					task.wait(0.25)
				end
			end

			destroyArrow() -- equivalent call inferred; original call site unknown

			if count == p3 then
				v = nil
				v2 = nil
			end
		end

		local function setZone(p: string?, p2: string?)
			count += 1
			v = p
			v2 = p2
			destroyArrow() -- equivalent call inferred; original call site unknown

			if p == nil or p2 == nil then
				return
			end

			task.spawn(runZoneLoop, p, p2, count)
		end

		anchorForZone.OnClientEvent:Connect(function(value: string?, value2: string?)
			if value ~= nil and typeof(value) ~= "string" or value2 ~= nil and typeof(value2) ~= "string" then
				return
			end

			count += 1
			v = value
			v2 = value2
			destroyArrow() -- equivalent call inferred; original call site unknown

			if value ~= nil then
				if value2 == nil then
					return
				else
					task.spawn(runZoneLoop, value, value2, count)
				end
			end
		end)
	end
}