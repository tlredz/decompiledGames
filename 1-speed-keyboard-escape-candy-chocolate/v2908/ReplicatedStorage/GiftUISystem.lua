local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
game:GetService("SocialService")
local GroupService = game:GetService("GroupService")
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage2:WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local verifyGroup = remotes:WaitForChild("VerifyGroup")
local claimGift = remotes:WaitForChild("ClaimGift")
local flag = false
local v = {
	modal = nil,
	closeBtn = nil,
	verifyBtn = nil,
	check1 = nil,
	check2 = nil
}

local function findElements()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local function getOne(tag)
		local tagged = CollectionService:GetTagged(tag)

		for _, v2 in ipairs(tagged) do
			if v2:IsDescendantOf(playerGui) then
				return v2
			end
		end

		return nil
	end

	v.modal = getOne("GiftModal")
	v.closeBtn = getOne("GiftCloseBtn")
	v.verifyBtn = getOne("GiftVerifyBtn")
	v.check1 = getOne("GiftStep1Check")
	v.check2 = getOne("GiftStep2Check")
	v.verifyBtnFrame = getOne("VerifyButtonFrame")

	for k, v2 in pairs(v) do
		if not v2 then
			warn("❌ " .. k .. " MANQUANT (Vérifie tes tags)")
		end
	end
end

local GiftUISystem = {
	UpdateDisplay = function(self)
		if not v.modal then
			findElements()
		end

		if ClientState:Get().GiftClaimed then
			if v.check1 then
				v.check1.Visible = true
			end

			if v.check2 then
				v.check2.Visible = true
			end

			if v.verifyBtn then
				v.verifyBtn.Text = "Claimed! ✓"
				v.verifyBtnFrame.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
			end
		else
			if v.check1 then
				v.check1.Visible = false
			end

			if v.check2 then
				v.check2.Visible = false
			end

			if v.verifyBtn then
				v.verifyBtn.Text = "Verify & Claim!"
				v.verifyBtnFrame.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
			end
		end
	end
}

local function initialize()
	if flag then
		return
	end

	if not v.modal then
		findElements()
	end

	if v.closeBtn then
		v.closeBtn.MouseButton1Click:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end

	if v.verifyBtn then
		v.verifyBtn.MouseButton1Click:Connect(function()
			if ClientState:Get().GiftClaimed then
				return
			end

			v.verifyBtn.Text = "Checking..."
			local success, result = pcall(function()
				return verifyGroup:InvokeServer()
			end)

			if success and result then
				if v.check1 then
					v.check1.Visible = true
				end

				if v.check2 then
					v.check2.Visible = true
				end

				claimGift:FireServer()
				ClientState:Update({
					GiftClaimed = true
				})

				for _, v2 in ipairs(CollectionService:GetTagged("UIActionBtn")) do
					if v2:GetAttribute("Action") == "Gift" then
						v2.Visible = false
					end
				end

				SoundManager:Play("SUCCESS")
				v.verifyBtn.Text = "Claimed! ✓"
				v.verifyBtnFrame.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
				task.delay(0.5, function()
					ClientState:CloseCurrentModal(v.modal)
				end)
			else
				SoundManager:Play("ERROR")
				v.verifyBtn.Text = "Join Group First!"
				v.verifyBtnFrame.BackgroundColor3 = Color3.fromRGB(220, 44, 44)
				task.delay(5, function()
					v.verifyBtn.Text = "Verify & Claim!"
					v.verifyBtnFrame.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
				end)
				task.wait(1)
				task.spawn(function()
					local success2, result2 = pcall(function()
						return GroupService:PromptJoinAsync(Config.GROUP_ID)
					end)

					if not success2 then
						warn("❌ Erreur GroupService:PromptJoinAsync :", result2)
					end
				end)
			end
		end)
	end

	flag = true
end

function GiftUISystem:InitLogic()
	if not v.modal then
		findElements()
	end

	initialize()
	self:UpdateDisplay()
end

function GiftUISystem.OnClose(_) end

return GiftUISystem