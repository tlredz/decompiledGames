local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Staff = require(ReplicatedStorage.Shared.Modules.Staff)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local staffTag = ReplicatedStorage.Assets.Billboards:WaitForChild("StaffTag")
		local v = {}
		local v2 = {}

		local function tagCharacter(instance, p, instance2)
			local head = instance:WaitForChild("Head", 10)

			if head == nil or not head:IsA("BasePart") or instance.Parent == nil then
				return
			end

			local clone = instance2:Clone(staffTag)
			local label = clone:FindFirstChild("Label")

			if label == nil or not label:IsA("TextLabel") then
				error("Assets.Billboards.StaffTag is missing a TextLabel named Label")
			end

			label.Text = Staff.OverheadLabel(p)
			label.TextColor3 = Color3.new(1, 1, 1)
			local uIGradient = label:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
			uIGradient.Name = "Sheen"
			uIGradient.Color = Staff.GradientOf(p)
			uIGradient.Parent = label
			v2[uIGradient] = true
			instance2:Add(function()
				v2[uIGradient] = nil
			end)
			clone.Name = `StaffTag_{instance.Name}`
			clone.Adornee = head
			clone.Enabled = true
			clone.Parent = playerGui
		end

		local function trackPlayer(player)
			if v[player] then
				return
			end

			local v3 = Trove.new()
			local extended = v3:Extend()
			v[player] = v3

			local function onCharacter(p)
				extended:Clean()
				local creatorDisguiseUserId = player:GetAttribute("CreatorDisguiseUserId")
				local roleOf = Staff.RoleOf

				if typeof(creatorDisguiseUserId) ~= "number" then
					creatorDisguiseUserId = player.UserId
				end

				local v4 = roleOf(creatorDisguiseUserId)

				if v4 ~= nil then
					tagCharacter(p, v4, extended)
				end
			end

			v3:Connect(player.CharacterAdded, onCharacter)
			v3:Connect(player:GetAttributeChangedSignal("CreatorDisguiseUserId"), function()
				if player.Character then
					task.spawn(onCharacter, player.Character)
				end
			end)
			v3:Connect(player.CharacterRemoving, function()
				extended:Clean()
			end)

			if player.Character then
				task.spawn(onCharacter, player.Character)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function forgetPlayer(p)
			local v3 = v[p]

			if v3 == nil then
				return
			end

			v[p] = nil
			v3:Destroy()
		end

		local function sweep()
			if next(v2) == nil then
				return
			end

			local v3 = os.clock() % 2.4 / 2.4
			local vector = Vector2.new(v3 * 2 - 1, 0)

			for k in v2 do
				k.Offset = vector
			end
		end

		RunService.Heartbeat:Connect(sweep)

		for _, v3 in Players:GetPlayers() do
			trackPlayer(v3)
		end

		Players.PlayerAdded:Connect(trackPlayer)
		Players.PlayerRemoving:Connect(forgetPlayer)
		Staff.Changed:Connect(function()
			for _, v3 in Players:GetPlayers() do
				forgetPlayer(v3) -- equivalent call inferred; original call site unknown
				trackPlayer(v3)
			end
		end)
	end
}