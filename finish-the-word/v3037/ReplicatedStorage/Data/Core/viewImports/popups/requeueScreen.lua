local import = _G.import("romodel")
local loadingScreen = require(script.Parent.loadingScreen)
local modesData = require(script.Parent.modesData)
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function formatElapsed(value)
	local v = math.max(0, (math.floor(value or 0)))
	return string.format("%d:%02d", math.floor(v / 60), v % 60)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getModeInfo(playerCount)
	for _, mode in pairs(modesData.Modes) do
		if mode.PlayerCount == playerCount then
			return mode
		end
	end

	return modesData.get()
end

local model = import.model(loadingScreen.LoadingScreen)

function model.init(options)
	local v = options or {}
	local modeInfo = getModeInfo(v.PlayerCount) -- equivalent call inferred; original call site unknown
	return {
		Name = "RequeueScreen",
		PlayerCount = v.PlayerCount,
		StartedAt = os.clock(),
		Title = "Searching for " .. modeInfo.ModeText,
		Subtext = formatElapsed()
	}
end

function model:spawn()
	self.ElapsedCon = RunService.Heartbeat:Connect(function()
		self.Content.Content.BottomRight.Subtext:setText(formatElapsed(os.clock() - self.StartedAt))
	end)
end

function model.despawn(p)
	if p.ElapsedCon then
		p.ElapsedCon:Disconnect()
	end
end

return {
	RequeueScreen = model
}