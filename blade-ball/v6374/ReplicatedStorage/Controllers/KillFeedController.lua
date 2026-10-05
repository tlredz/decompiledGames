local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Packages.Spring)
local v4 = require3(ReplicatedStorage2.Packages.Signal)
local v5 = require3(ReplicatedStorage2.Packages.Trove)
local v6 = require3(ReplicatedStorage2.Common.Utils)
local v7 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local localPlayer = Players.LocalPlayer
local testGame = v2.isTestGame()
local killFeed = localPlayer.PlayerGui:WaitForChild("KillFeed")
local v8 = v4.new()
local clones = {}
local KillFeedController = {}

function KillFeedController:AddToList(player, player2, childName, value)
	if typeof(player) ~= "Instance" or typeof(player2) ~= "Instance" or not (player:IsA("Player") and player2:IsA("Player")) then
		return
	end

	local maid = v5.new()
	local v9 = player2 == localPlayer and 2 or 1
	local clone = maid:Clone((killFeed.Frame:FindFirstChild((tostring(v9)))))
	clone.Holder.Right.PlayerName.Text = player.DisplayName
	clone.Holder.Right.Vector.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=100&h=100`
	clone.Holder.Left.PlayerName.Text = player2.DisplayName
	clone.Holder.Left.Vector.Image = `rbxthumb://type=AvatarHeadShot&id={player2.UserId}&w=100&h=100`
	local child

	if childName then
		child = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(childName)
	end

	if child then
		local icon = child:GetAttribute("Icon")

		for i = 1, value or 0 do
			icon = child:GetAttribute((`Icon{i}`)) or icon
		end

		clone.Holder.Middle.Vector.Image = icon or v6.Icons:GetIcon("DEFAULT_MISSING")
	else
		clone.Holder.Middle.Vector.Image = "rbxassetid://85978736659072"
	end

	clone.Visible = true
	clone.Parent = killFeed.Frame
	local v10 = v3.new(0.5, 4, nil, 0.8)
	local v11 = v3.new(-0.1, 4, nil, 0.8)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateTarget()
		local index = table.find(clones, clone)

		if index then
			v11.goal = index * 0.06
		else
			v10.goal = 1.5
		end
	end

	table.insert(clones, clone)
	updateTarget() -- equivalent call inferred; original call site unknown
	v8:Fire()
	maid:Add(v8:Connect(updateTarget))
	maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		local v12 = v10:update(dt)
		local v13 = v11:update(dt)
		clone.Position = UDim2.fromScale(v12, v13)

		if v10.goal >= 1.5 and v10.position >= 1.35 and v10.velocity < 0.01 then
			maid:Destroy()
		end
	end))
	maid:Add(task.delay(5, function()
		local index = table.find(clones, clone)

		if index then
			table.remove(clones, index)
			v8:Fire()
		end
	end))
end

function KillFeedController:Start()
	if not (testGame or v2.isRankedMatchServer()) then
		v:Connect("AddToKillFeed", function(...) end)
		return
	end

	local function updateCondensed()
		killFeed.Enabled = not v7.Condensed.CurrentState
	end

	v7.Condensed.StateChanged:Connect(updateCondensed)
	task.spawn(updateCondensed)
	v:Connect("AddToKillFeed", function(...)
		self:AddToList(...)
	end)
end

return KillFeedController