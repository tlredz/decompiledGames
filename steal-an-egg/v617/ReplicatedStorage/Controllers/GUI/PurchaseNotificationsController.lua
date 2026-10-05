local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.Shared.Audio)
local Confetti = require(ReplicatedStorage.Client.UI.VFX.Confetti)
local Message = require(ReplicatedStorage.Client.Message)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local v = {
	ProductSettled = 0.8,
	Rejected = 90
}
local v2 = {
	Bounced = "Your gift couldn't reach its recipient, so it was added to your account instead.",
	Failed = "That purchase didn't go through. If any Robux were taken, Roblox refunds them automatically. Let us know if this keeps happening. 🙏",
	GiftDelivered = "Your gift has been delivered! 🎁",
	Thanks = "Thanks for your support! Your purchase is on its way. 🎉"
}
local v3 = {}
local v4 = {}

local function profileLoaded()
	return Save.Await() ~= nil
end

local function firstSighting(p: string)
	if v3[p] then
		return false
	end

	v3[p] = true
	return true
end

local function report(p: string, options)
	local v5 = options or {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function deliver()
		if v5.Celebrate then
			Confetti.Burst()
			Audio.Play(98002834893313, script)
		end

		Message.Notice(p)
	end

	if v5.After ~= nil then
		task.delay(v5.After, deliver)
		return
	end

	deliver() -- equivalent call inferred; original call site unknown
end

local function productIdOf(p)
	local productId

	if type(p) == "table" then
		productId = p.ProductId
	end

	if type(productId) == "number" then
		return productId
	end

	return nil
end

local function holdFailureNotice(p: number?)
	if p == nil then
		report(
			"That purchase didn't go through. If any Robux were taken, Roblox refunds them automatically. Let us know if this keeps happening. 🙏",
			{
				After = 90
			}
		)
		return
	end

	if v4[p] ~= nil then
		return
	end

	v4[p] = task.delay(90, function()
		v4[p] = nil
		report("That purchase didn't go through. If any Robux were taken, Roblox refunds them automatically. Let us know if this keeps happening. 🙏")
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function withdrawFailureNotice(p: number)
	local v5 = v4[p]

	if v5 ~= nil then
		v4[p] = nil
		task.cancel(v5)
	end
end

local function giftLine(p: number)
	if p == Players.LocalPlayer.UserId then
		return "Your gift couldn't reach its recipient, so it was added to your account instead."
	end

	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId then
		return (`Your gift is on its way to {playerByUserId.DisplayName}! 🎁`)
	end

	return "Your gift has been delivered! 🎁"
end

return {
	Start = function()
		Remotes.PassGrants.Awarded.OnClientEvent:Connect(function(_, flag: boolean?)
			if not flag and Save.Await() ~= nil then
				report("Thanks for your support! Your purchase is on its way. 🎉", {
					Celebrate = true
				})
			end
		end)

		local function onReceiptSettled(p: number?, flag: boolean)
			if p ~= nil then
				withdrawFailureNotice(p) -- equivalent call inferred; original call site unknown
			end

			if flag and Save.Await() ~= nil then
				report("Thanks for your support! Your purchase is on its way. 🎉", {
					Celebrate = true,
					After = 0.8
				})
			end
		end

		Remotes.Storefront.PurchaseSettled.OnClientEvent:Connect(function(_, p)
			local productId

			if type(p) == "table" then
				productId = p.ProductId
			end

			if type(productId) ~= "number" then
				productId = nil
			end

			if productId ~= nil then
				withdrawFailureNotice(productId) -- equivalent call inferred; original call site unknown
			end

			if Save.Await() ~= nil then
				report(v2.Thanks, {
					Celebrate = true,
					After = v.ProductSettled
				})
			end
		end)
		Remotes.Storefront.ReceiptCleared.OnClientEvent:Connect(function(value, _, flag: boolean?)
			if type(value) ~= "number" then
				value = nil
			end

			if value ~= nil then
				withdrawFailureNotice(value) -- equivalent call inferred; original call site unknown
			end

			if not flag and Save.Await() ~= nil then
				report(v2.Thanks, {
					Celebrate = true,
					After = v.ProductSettled
				})
			end
		end)
		Remotes.Storefront.PurchaseRejected.OnClientEvent:Connect(function(p)
			local productId

			if type(p) == "table" then
				productId = p.ProductId
			end

			if type(productId) ~= "number" then
				productId = nil
			end

			holdFailureNotice(productId)
		end)
		Remotes.Gifting.Received.OnClientEvent:Connect(function(p: string, p2: string, p3: string)
			local flag

			if v3[p2] then
				flag = false
			else
				v3[p2] = true
				flag = true
			end

			if flag then
				report(`{p} sent you a gift: {p3}! 🎁`, {
					Celebrate = true
				})
			end
		end)
		Remotes.Gifting.Completed.OnClientEvent:Connect(function(_, p: number, p2: string)
			local flag

			if v3[p2] then
				flag = false
			else
				v3[p2] = true
				flag = true
			end

			if flag then
				local bounced

				if p == Players.LocalPlayer.UserId then
					bounced = v2.Bounced
				else
					local playerByUserId = Players:GetPlayerByUserId(p)

					if playerByUserId then
						bounced = `Your gift is on its way to {playerByUserId.DisplayName}! 🎁`
					else
						bounced = v2.GiftDelivered
					end
				end

				report(bounced, {
					Celebrate = true
				})
			end
		end)
	end
}