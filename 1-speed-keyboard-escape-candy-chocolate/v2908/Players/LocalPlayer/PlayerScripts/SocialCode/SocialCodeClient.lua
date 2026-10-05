local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(120, 220, 140)
local color2 = Color3.fromRGB(255, 120, 120)
local color3 = Color3.fromRGB(180, 180, 190)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local submitDiscordVerifyCode = ReplicatedStorage:WaitForChild("SubmitDiscordVerifyCode")
local discordVerifyResult = ReplicatedStorage:WaitForChild("DiscordVerifyResult")
local socialVerifyGui = playerGui:WaitForChild("SocialVerifyGui")
local panel = socialVerifyGui:FindFirstChild("Panel")

if panel then
	if not panel:IsA("ImageLabel") then
		panel = socialVerifyGui
	end
else
	panel = socialVerifyGui
end

local textBox = panel:FindFirstChildWhichIsA("TextBox", true)

if not textBox then
	error("[DiscordVerify] TextBox 'CodeTextBox' missing")
end

local status = panel:FindFirstChild("Status")
local submit = panel:FindFirstChild("Submit")

if not (status and status:IsA("TextLabel") and submit and submit:IsA("TextButton")) then
	error("[DiscordVerify] TextLabel 'Status' or TextButton 'Submit' missing")
end

local flag = false

local function errorMessage(p: string)
	if p == "invalid_or_expired_code" then
		return "INVALID OR EXPIRED CODE. ONLY USE CODES YOU GENERATED YOURSELF ON THE OFFICIAL DISCORD."
	elseif p == "code_not_for_this_roblox_account" then
		return "THIS CODE WAS GENERATED FOR A DIFFERENT ROBLOX ACCOUNT. THE DISCORD WHO GAVE IT TO YOU IS NOT THE OFFICIAL ONE — GENERATE YOUR OWN CODE ON THE REAL OFFICIAL DISCORD."
	elseif p == "discord_already_linked" then
		return "THE DISCORD ACCOUNT THAT GENERATED THIS CODE IS ALREADY LINKED TO ANOTHER ROBLOX. ASK STAFF TO UNLINK IT FIRST."
	elseif p == "roblox_already_linked" then
		return "THIS ROBLOX ACCOUNT IS ALREADY LINKED TO A DISCORD. IF IT IS NOT YOURS, OPEN A TICKET ON THE OFFICIAL DISCORD."
	elseif p == "discord_not_in_guild" then
		return "THIS DISCORD ACCOUNT IS NOT (OR NO LONGER) ON THE GAME SERVER. JOIN THE DISCORD AND THEN REQUEST A NEW CODE."
	elseif p == "already_claimed" then
		return "REWARD ALREADY CLAIMED ON THIS ACCOUNT."
	elseif p == "roblox_account_reset_pending" then
		return "THIS ACCOUNT IS BEING RESET BY AN ADMIN. REJOIN THE GAME IN A FEW MINUTES AND TRY AGAIN."
	elseif p == "invalid_roblox_user_id" then
		return "INVALID PLAYER ID. REJOIN AND TRY AGAIN OR CONTACT AN ADMIN."
	elseif p == "unauthorized" then
		return "SERVER ERROR (AUTH). CONTACT AN ADMIN."
	end

	if p == "invalid_code" or p == "invalid_body" then
		return "REQUEST REJECTED. TRY AGAIN."
	end

	if p == "network" then
		return "NO RESPONSE FROM THE SERVER. TRY AGAIN LATER."
	elseif p == "rate_limited" then
		return "TOO MANY ATTEMPTS. WAIT BEFORE TRYING AGAIN."
	elseif p == "bad_gateway" then
		return "THE VERIFICATION API IS UNAVAILABLE (SERVER). TRY AGAIN LATER OR CONTACT AN ADMIN."
	end

	if p == "invalid_response" or p == "internal" then
		return "TECHNICAL ERROR. TRY AGAIN LATER."
	end

	return "FAILURE: " .. p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sanitizeCode(text: string)
	local v = string.upper(text)
	return (string.gsub(v, "[^A-Z0-9]", ""))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setStatus(text: string, textColor: Color3)
	status.Text = text
	status.TextColor3 = textColor
end

discordVerifyResult.OnClientEvent:Connect(function(p, value)
	flag = false
	submit.Active = true

	if typeof(p) ~= "boolean" then
		return
	end

	if p then
		setStatus("SUCCESSFULLY VERIFIED", color) -- equivalent call inferred; original call site unknown
	else
		setStatus(errorMessage(typeof(value) ~= "string" and "" or value), color2) -- equivalent call inferred; original call site unknown
	end
end)
textBox:GetPropertyChangedSignal("Text"):Connect(function()
	local text = textBox.Text
	local text2 = string.sub(sanitizeCode(text), 1, 32)

	if textBox.Text ~= text2 then
		textBox.Text = text2
	end
end)

local function trySubmit()
	if flag then
		return
	end

	local v = sanitizeCode(textBox.Text) -- equivalent call inferred; original call site unknown

	if #v < 4 or #v > 32 then
		setStatus("INVALID CODE LENGTH (MUST BE BETWEEN 4 AND 32 CHARACTERS).", color2) -- equivalent call inferred; original call site unknown
	else
		flag = true
		submit.Active = false
		setStatus("SENDING...", color3) -- equivalent call inferred; original call site unknown
		submitDiscordVerifyCode:FireServer(v)
	end
end

textBox.FocusLost:Connect(function(flag2: boolean)
	if flag2 then
		trySubmit()
	end
end)
submit.MouseButton1Click:Connect(trySubmit)