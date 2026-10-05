local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local v = require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Shared.FastUtils)
local v6 = require3(ReplicatedStorage2.ClientGameModules.TextUtility)
local v7 = require3(ReplicatedStorage2.Common.Utils)
local v8 = require3(ReplicatedStorage2.Shared.GenericCoinCrateData)
local v9 = require3(ReplicatedStorage2.Shared.Statable)
local content = Players.LocalPlayer.PlayerGui:WaitForChild("GenericCoinCrate").Holder.Content
local items = content.Items
local hoverImages = {}
local images = {}
local buttons = {}
local frameIndexes = {}

for _, v10 in { items.RightList, items.LeftList, items } do
	for _, button in v10:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local layoutOrder = tonumber(string.match(button.Name, "Reward_(%d+)"))

		if not layoutOrder then
			continue
		end

		button.LayoutOrder = layoutOrder
		hoverImages[layoutOrder] = button.HoverImage
		images[layoutOrder] = button.Image
		buttons[layoutOrder] = button
		button.HoverImage = ""
	end
end

local GenericCoinCrateController = {}
GenericCoinCrateController._animationQueue = {}

function GenericCoinCrateController:_glowItem(lastGlowIndex)
	if self._lastGlowIndex then
		buttons[self._lastGlowIndex].Image = images[self._lastGlowIndex]
	end

	v5.fastAudio("rbxassetid://6895079853", SoundService, 0.2, 1.2)
	buttons[lastGlowIndex].Image = hoverImages[lastGlowIndex]
	self._lastGlowIndex = lastGlowIndex
end

function GenericCoinCrateController:_animateFromQueue()
	if self._runningAnimation then
		return
	end

	local first = v.List.first(self._animationQueue)

	if not first then
		return
	end

	self._runningAnimation = true
	self._animationQueue = v.List.remove(self._animationQueue, 1)
	local v10 = first // 256
	local v11 = bit32.band(first, 1) ~= 0
	local reward = v8.Rewards[v10].Reward
	local value = reward.Value
	local v12 = frameIndexes[v10]

	local function stopAnimation()
		ReplicatedStorage2.Misc.reward:Play()
		self:_glowItem(v12)
		local showAwardItem = v7.Network.Events.ShowAwardItem
		local type2 = reward.Type
		local v13 = type(value) ~= "number" and 1 or value
		local valueConvertor = v7.ValueConvertor
		local v16

		if type(value) == "number" then
			v16 = `%s {reward.DisplayName}`
		else
			v16 = reward.DisplayName
		end

		showAwardItem(
			type2,
			v13,
			(`You received {valueConvertor:FormatMarkupColor(`{v16}`, Color3.new(0.2, 0.5, 1))}!`)
		)
		task.wait(1)
		self._runningAnimation = nil
		self:_animateFromQueue()
	end

	local v13, total

	if v11 then
		v13 = #buttons * math.random(4, 6) + v12 - 1
		total = 0.015
	else
		v13 = #buttons * math.random(9, 11) + v12 - 1
		total = 0.02
	end

	for i = 1, v13 do
		self:_glowItem(i % 9 + 1)
		task.wait(total)

		if not (v13 - i < 20) then
			continue
		end

		if v11 then
			total += 0.005
		else
			total += 0.015
		end
	end

	stopAnimation()
end

function GenericCoinCrateController:Open(p)
	local replion = v3.Client:GetReplion("Data")

	if not replion then
		return
	end

	if replion:GetExpect("Credits") < v8.Price * p then
		ReplicatedStorage2.Misc.error:Play()
		return
	end

	local v10, v11 = v2:Invoke("OpenGenericCoinCrate", p)

	if not v10 or typeof(v11) ~= "buffer" then
		ReplicatedStorage2.Misc.error:Play()
		return
	end

	local v12 = buffer.readu8(v11, 0)
	local v13 = v12 > 1

	for i = 1, v12 do
		local v14 = buffer.readu8(v11, i) * 256

		if v13 then
			v14 = bit32.bor(v14, 1)
		end

		self._animationQueue = v.List.push(self._animationQueue, v14)
	end

	self:_animateFromQueue()
end

function GenericCoinCrateController:Start()
	local state = v9.State(false)
	local rewardsByFrameIndex = {}

	for _, reward in v8.Rewards do
		if not reward.FrameIndex then
			continue
		end

		if rewardsByFrameIndex[reward.FrameIndex] then
			task.spawn(error, (`Index {reward.FrameIndex} is already reserved!`))
		else
			rewardsByFrameIndex[reward.FrameIndex] = reward
		end
	end

	for k, reward in v8.Rewards do
		local frameIndex = reward.FrameIndex

		if not frameIndex then
			frameIndex = 1

			while rewardsByFrameIndex[frameIndex] do
				frameIndex += 1
			end

			rewardsByFrameIndex[frameIndex] = reward
		end

		assert(frameIndex)
		local v10 = buttons[frameIndex]

		if v10 then
			frameIndexes[k] = frameIndex
			v10.Title.Text = reward.Reward.DisplayName
			v10.Vector.Image = reward.Reward.Icon or v7.Icons:GetIcon("DEFAULT_MISSING")
			v10.Vector.Odd.Text = `{reward.Chance}%`
			v9.setPropertyState(v10.Vector.Odd, "Visible", state)
		else
			task.spawn(error, (`Failed to find Item frame for reward {frameIndex}`))
		end
	end

	content.ShowOdds.Activated:Connect(function()
		state:Set(not state:Get())
	end)
	content.Close.Activated:Connect(function()
		v4:Close("GenericCoinCrate")
	end)

	for _, button in items.SpinButtons:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v10 = tonumber(string.match(button.Name, "Spin_(%d+)"))

		if v10 then
			button.Price.Text = v6.commify(v10 * v8.Price)
			button.SpinAmount.Text = `Spin {v10}`
			local v11 = v10
			button.Activated:Connect(function()
				self:Open(v11)
			end)
		else
			task.spawn(error, (`Failed to get spin amount for {button:GetFullName()}`))
		end
	end
end

return GenericCoinCrateController