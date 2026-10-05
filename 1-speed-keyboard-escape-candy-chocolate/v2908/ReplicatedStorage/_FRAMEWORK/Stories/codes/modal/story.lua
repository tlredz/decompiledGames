local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
local UILabs = require(packages["UI-Labs"])
local Vide = require(packages.Vide)
local CodeModal = require(ReplicatedStorage._FRAMEWORK.Features.CodeRedemption.CodeModal)
local Theme = require(ReplicatedStorage._FRAMEWORK.Features.CodeRedemption.Theme)
local names = Theme.names()
local v = {
	invalid_code = "This code doesn't exist.",
	expired = "This code has expired.",
	inactive = "This code is no longer active.",
	sold_out = "This code has been fully claimed.",
	already_claimed = "You already claimed this code.",
	claim_window_exceeded = "This code is too old to be claimed on your account.",
	rate_limited = "Too many attempts. Wait a moment and try again.",
	internal = "Something went wrong. Try again in a moment."
}
local v2 = {
	icon = "rbxassetid://15540211845",
	title = "Wins",
	detail = "Added to this galaxy",
	amount = "x250"
}
local v3 = {
	icon = "rbxassetid://136721646785674",
	title = "Candy Dominus",
	detail = "Tier 5 - signed by Cubastic",
	amount = "x1"
}
local v4 = {
	icon = "rbxassetid://134366443249667",
	title = "BBNO$ Treadmill",
	detail = "Treadmill skin",
	amount = ""
}
local v5 = {
	icon = "rbxassetid://94137693106401",
	title = "Admin Treadmill",
	detail = "Treadmill access",
	amount = ""
}
local v6 = {
	Wins = { v2 },
	Item = { v3 },
	Skin = { v4 },
	Treadmill = { v5 },
	Mixed = {
		v2,
		v3,
		v4,
		v5
	}
}
local controls2 = {
	Theme = UILabs.Choose(names, table.find(names, Theme.defaultName())),
	State = UILabs.Choose({
		"idle",
		"sending",
		"success",
		"error"
	}),
	Reason = UILabs.Choose({
		"invalid_code",
		"expired",
		"inactive",
		"sold_out",
		"already_claimed",
		"claim_window_exceeded",
		"rate_limited",
		"internal"
	}),
	Rewards = UILabs.Choose({
		"Mixed",
		"Wins",
		"Item",
		"Skin",
		"Treadmill"
	}),
	Width = UILabs.Slider(0.5, 0.2, 1, 0.05),
	Height = UILabs.Slider(0.5, 0.2, 1, 0.05),
	AspectRatio = UILabs.Slider(1.4, 0.6, 2.5, 0.1)
}
return UILabs.CreateVideStory({
	name = "Codes - Redeem modal",
	vide = Vide,
	controls = controls2
}, function(p)
	local controls = p.controls

	local function message()
		local state = controls.State()

		if state == "idle" then
			return "Enter a code to claim its rewards."
		elseif state == "sending" then
			return "Checking your code..."
		elseif state == "success" then
			return "Code redeemed!"
		end

		return v[controls.Reason()]
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isSuccess()
		return controls.State() == "success"
	end

	return CodeModal({
		Theme = controls.Theme,
		Size = function()
			return UDim2.fromScale(controls.Width(), controls.Height())
		end,
		AspectRatio = controls.AspectRatio,
		Status = function()
			return (controls.State())
		end,
		Message = message,
		Label = function()
			if isSuccess() then
				return "Launch week gift"
			end

			return ""
		end,
		OwnerName = function()
			if isSuccess() then
				return "Cubastic"
			end

			return ""
		end,
		OwnerUserId = function()
			if isSuccess() then
				return 3845375404
			end

			return 0
		end,
		Rewards = function()
			if isSuccess() then
				return v6[controls.Rewards()]
			end

			return {}
		end,
		OnSubmit = function(p2: string)
			print("[modal.story] submit", p2)
		end,
		OnClose = function()
			print("[modal.story] close")
		end
	})
end)