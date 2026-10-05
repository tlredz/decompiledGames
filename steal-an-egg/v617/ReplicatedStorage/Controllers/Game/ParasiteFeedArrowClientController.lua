local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ArrowPointer3D = require(ReplicatedStorage.Client.WorldFX.ArrowPointer3D)
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local Save = require(ReplicatedStorage.Shared.Save)
local localPlayer = Players.LocalPlayer
local v = nil
local v2 = nil
local count = 0
local flag = false
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

		local function findNearestMonsterPart(humanoidRootPart)
			local child = Workspace:FindFirstChild(MonsterParasite.WorldFolderName)

			if child == nil then
				return nil
			end

			local v3 = 1e999
			local v4 = nil

			for _, basePart in child:GetChildren() do
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

				if basePart == nil then
					continue
				end

				local magnitude = (basePart.Position - humanoidRootPart.Position).Magnitude

				if not (magnitude < v3) then
					continue
				end

				v4 = basePart
				v3 = magnitude
			end

			return v4
		end

		local function holdsParasiteEgg()
			local v3 = Save.Await()
			local eggInventory

			if v3 ~= nil then
				eggInventory = v3.EggInventory
			end

			if typeof(eggInventory) ~= "table" then
				return false
			end

			for _, v4 in eggInventory do
				if typeof(v4) == "table" and v4.HasParasite == true then
					return true
				end
			end

			return false
		end

		local function hasNeverFed()
			local v3 = Save.Await()
			local monsterParasite

			if v3 ~= nil then
				monsterParasite = v3.MonsterParasite
			end

			return typeof(monsterParasite) == "table" and (monsterParasite.TotalFeeds or 0) <= 0
		end

		local function shouldGuide()
			local isLoaded = Save.IsLoaded()

			if not isLoaded then
				return isLoaded
			end

			local v3 = Save.Await()
			local monsterParasite

			if v3 ~= nil then
				monsterParasite = v3.MonsterParasite
			end

			isLoaded = typeof(monsterParasite) == "table" and (monsterParasite.TotalFeeds or 0) <= 0 and holdsParasiteEgg()
			return isLoaded
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyArrow()
			if v ~= nil then
				v:Destroy()
				v = nil
			end

			v2 = nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function pointArrowAt(p, humanoidRootPart)
			if v ~= nil and v2 == p then
				v:PointFrom(humanoidRootPart)
				return
			end

			destroyArrow() -- equivalent call inferred; original call site unknown
			local v3 = ArrowPointer3D.new(p, humanoidRootPart)
			v3:Start()
			v = v3
			v2 = p
		end

		local function runGuideLoop(p: number)
			while count == p do
				local isLoaded = Save.IsLoaded()

				if isLoaded then
					local v3 = Save.Await()
					local monsterParasite

					if v3 ~= nil then
						monsterParasite = v3.MonsterParasite
					end

					isLoaded = typeof(monsterParasite) == "table" and (monsterParasite.TotalFeeds or 0) <= 0 and holdsParasiteEgg()
				end

				if not isLoaded then
					break
				end

				local character = localPlayer.Character
				local humanoidRootPart

				if character ~= nil then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
						humanoidRootPart = nil
					end
				end

				local v3

				if humanoidRootPart ~= nil then
					v3 = findNearestMonsterPart(humanoidRootPart)
				end

				if humanoidRootPart == nil or v3 == nil then
					destroyArrow() -- equivalent call inferred; original call site unknown
				else
					pointArrowAt(v3, humanoidRootPart) -- equivalent call inferred; original call site unknown
				end

				task.wait(0.25)
			end

			if count == p then
				flag = false
				destroyArrow() -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refresh()
			local isLoaded = Save.IsLoaded()

			if isLoaded then
				local v3 = Save.Await()
				local monsterParasite

				if v3 ~= nil then
					monsterParasite = v3.MonsterParasite
				end

				isLoaded = typeof(monsterParasite) == "table" and (monsterParasite.TotalFeeds or 0) <= 0 and holdsParasiteEgg()
			end

			if isLoaded then
				if flag then
					return
				end

				count += 1
				flag = true
				task.spawn(runGuideLoop, count)
			else
				count += 1
				flag = false
				destroyArrow() -- equivalent call inferred; original call site unknown
			end
		end

		Save.WatchFields({ "EggInventory", "MonsterParasite" }, refresh)
		refresh() -- equivalent call inferred; original call site unknown
	end
}