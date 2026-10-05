local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local rifts = ReplicatedStorage:WaitForChild("resources").models:WaitForChild("Rifts")
local remoteEvent = Net:RemoteEvent("PersonalRifts/Spawn", 1e999)
local remoteEvent2 = Net:RemoteEvent("PersonalRifts/Enter", 1e999)
local maid = Trove.new()
local v = nil
return {
	Start = function(_)
		local localPlayer = Players.LocalPlayer

		local function PersonalRiftSpawn(childName)
			local character = localPlayer.Character

			if not character then
				return
			end

			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
			local child = rifts:FindFirstChild(childName)

			if not child then
				error("Rift model not found for " .. childName)
			end

			if v then
				ReplicatedStorage.events.anno_localthought:Fire("There's already a <b>rift</b> spawned")
				return
			end

			maid:Clean()
			local clone = child:Clone()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function riftCleanup()
				if not v then
					return
				end

				maid:Clean()
				v:Destroy()
				v = nil
			end

			for _, descendant in clone:GetDescendants() do
				descendant:AddTag("IgnorePerformance")
			end

			clone.Size = createVector(8.5, 8.5, 0)
			clone.CanTouch = true
			clone.CanCollide = false
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 2.5, 5.5)
			local position = clone.Position
			clone.Parent = workspace

			local function onRiftTouched(p)
				local playerFromCharacter = Players:GetPlayerFromCharacter(p.Parent)

				if not playerFromCharacter or playerFromCharacter ~= localPlayer then
					return
				end

				riftCleanup() -- equivalent call inferred; original call site unknown
				remoteEvent2:FireServer(position)
			end

			maid:Add(clone.Touched:Connect(onRiftTouched))
			v = clone
			task.delay(30, riftCleanup)
		end

		remoteEvent.OnClientEvent:Connect(PersonalRiftSpawn)
	end
}