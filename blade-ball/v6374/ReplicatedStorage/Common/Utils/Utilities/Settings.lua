local v = 900
local Settings = {
	WEEKLY_SPIN_START = 1697248800,
	WEEK_TIME = 604800,
	DAILY_LOGIN_COOLDOWN = 84600,
	UPDATE_RELEASE_TIME = workspace:GetAttribute("UPDATE_TIME"),
	MIN_TIME_TO_SHOW = 345600,
	MIN_TIME_FOR_UPDATE = 60,
	TIME_TO_CLAIM_UPDATE_GIFT = 900 + (v + 60),
	TIME_TO_UNLOCK_UPDATE_GIFT = v + 60,
	COLOR_YELLOW = Color3.fromRGB(255, 255, 0),
	COLOR_RED = Color3.fromRGB(255, 0, 0),
	COLOR_GREEN = Color3.fromRGB(0, 255, 0),
	TEST_PLACE_PRODUCT = 1688380605
}
workspace:GetAttributeChangedSignal("UPDATE_TIME"):Connect(function()
	Settings.UPDATE_RELEASE_TIME = workspace:GetAttribute("UPDATE_TIME") or 1e999
end)
return Settings