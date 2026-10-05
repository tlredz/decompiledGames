local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Trove = require(ReplicatedStorage.Packages.Trove)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local color = Color3.fromRGB(85, 255, 85)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function numberOr(value)
	if typeof(value) == "number" then
		return value
	end

	return 0
end

local function setupCharacter(player, instance)
	local playerOverhead = FastOverheadController.GuiTemplates.PlayerOverhead

	if not playerOverhead then
		return nil
	end

	local head = instance:WaitForChild("Head", 10)

	if not (head and head:IsA("BasePart")) then
		return nil
	end

	local maid = Trove.new()
	local fastOverhead, v2 = FastOverheadController.createFastOverhead({
		adornee = head,
		guiTemplate = playerOverhead,
		studsOffsetY = 3,
		relativeToAdornee = player == Players.LocalPlayer
	})
	maid:Add(v2)
	fastOverhead.DisplayName.Text = ""
	local generation = fastOverhead.Generation
	generation.TextColor3 = color
	local uIGradient = generation:FindFirstChildWhichIsA("UIGradient")

	if uIGradient then
		uIGradient.Enabled = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateGen()
		local generation2 = fastOverhead.Generation
		generation2.Text = `${NumberUtils:ToString(numberOr(player:GetAttribute("DisplayGen")))}/s`
	end

	updateGen() -- equivalent call inferred; original call site unknown
	maid:Add(player:GetAttributeChangedSignal("DisplayGen"):Connect(updateGen))
	maid:Add(player:GetPropertyChangedSignal("DisplayName"):Connect(function()
		fastOverhead.DisplayName.Text = player.DisplayName
	end))
	return maid
end

local function onPlayerAdded(player)
	local maid = Trove.new()
	v[player] = maid
	local v2 = nil

	local function onCharacter(p)
		if v2 then
			v2:Destroy()
			v2 = nil
		end

		local v3 = setupCharacter(player, p)

		if player.Character == p then
			v2 = v3
		elseif v3 then
			v3:Destroy()
		end
	end

	maid:Add(player.CharacterAdded:Connect(onCharacter))
	maid:Add(function()
		if v2 then
			v2:Destroy()
			v2 = nil
		end
	end)

	if player.Character then
		task.spawn(onCharacter, player.Character)
	end
end

return {
	Start = function(_)
		if not ServerData.IsTradePlaza() then
			return
		end

		for _, v2 in Players:GetPlayers() do
			onPlayerAdded(v2)
		end

		Players.PlayerAdded:Connect(onPlayerAdded)
		Players.PlayerRemoving:Connect(function(player)
			local v2 = v[player]

			if v2 then
				v2:Destroy()
				v[player] = nil
			end
		end)
	end
}