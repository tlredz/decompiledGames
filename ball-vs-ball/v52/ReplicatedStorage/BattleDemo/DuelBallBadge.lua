local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local DuelBallBadge = {
	SIDE_BY_TEAM = {
		Blue = "红方",
		Yellow = "蓝方"
	}
}
local v = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("悬浮UI"):WaitForChild("Rig"):WaitForChild("对局玩家血量"):WaitForChild("红方")
local image = v.Image
local imageColor3 = v.ImageColor3

local function getBallImage(p: string)
	local byCnId = Config.ball and Config.ball.byCnId
	local v2 = byCnId and byCnId[p]
	local image2 = v2 and v2.image

	if typeof(image2) == "string" and string.match(image2, "^%a+://") then
		return image2
	end

	return nil
end

local v2 = {
	Aiming = true,
	RoundStarting = true,
	Playing = true
}

function DuelBallBadge.shouldShowBall(value)
	return typeof(value) == "string" and v2[value] == true
end

function DuelBallBadge.formatKills(p: number)
	return (tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

function DuelBallBadge:apply(value: string?, value2: number?)
	local v3

	if typeof(value) == "string" then
		v3 = value ~= ""
	else
		v3 = false
	end

	local image2

	if v3 then
		local byCnId = Config.ball and Config.ball.byCnId
		local v4 = byCnId and byCnId[value]
		image2 = v4 and v4.image

		if typeof(image2) ~= "string" or not string.match(image2, "^%a+://") then
			image2 = nil
		end
	end

	if image2 then
		self.Image = image2
		self.ImageColor3 = Color3.new(1, 1, 1)
	else
		self.Image = image
		self.ImageColor3 = imageColor3
	end

	local guiObject = self:FindFirstChild("击杀数")

	if guiObject and guiObject:IsA("GuiObject") then
		local visible = v3 and typeof(value2) == "number"
		guiObject.Visible = visible
		local label = guiObject:FindFirstChild("数值")

		if visible and label and label:IsA("TextLabel") then
			label.Text = DuelBallBadge.formatKills(value2)
		end
	end
end

return DuelBallBadge