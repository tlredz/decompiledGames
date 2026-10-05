local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
Network:listen("UpdateMemoryTilesUi", function(p, p2, p3)
	local frame = playerGui:FindFirstChild("MemoryTiles"):FindFirstChild("Frame")
	local canvasGroup = frame:FindFirstChild("CanvasGroup")
	frame:FindFirstChild("Round")

	if not p3 then
		frame.Visible = false
		return
	end

	local function updateLivesUI()
		local child = canvasGroup:FindFirstChild("Life" .. 1)

		if child then
			if p2 < 1 then
				child.ImageTransparency = 0.9
			else
				child.ImageTransparency = 0
			end
		end

		local child2 = canvasGroup:FindFirstChild("Life" .. 2)

		if child2 then
			if p2 < 2 then
				child2.ImageTransparency = 0.9
			else
				child2.ImageTransparency = 0
			end
		end

		local child3 = canvasGroup:FindFirstChild("Life" .. 3)

		if child3 then
			if p2 < 3 then
				child3.ImageTransparency = 0.9
			else
				child3.ImageTransparency = 0
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateRoundUI()
		local round = frame.Round

		if round then
			round.Text = `Round {p}/10`
		end
	end

	updateRoundUI() -- equivalent call inferred; original call site unknown
	updateLivesUI()
	frame.Visible = true
end)
return {}