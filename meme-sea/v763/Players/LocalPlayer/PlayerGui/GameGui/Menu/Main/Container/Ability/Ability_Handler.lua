local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local Setting = require(moduleScript:WaitForChild("Setting"))
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local auraExp = playerData:WaitForChild("AuraExp")
local auraMaxExp = playerData:WaitForChild("AuraMaxExp")
local auraLevel = playerData:WaitForChild("AuraLevel")
local dodgeExp = playerData:WaitForChild("DodgeExp")
local dodgeMaxExp = playerData:WaitForChild("DodgeMaxExp")
local dodgeLevel = playerData:WaitForChild("DodgeLevel")
local flashStepExp = playerData:WaitForChild("FlashStepExp")
local flashStepMaxExp = playerData:WaitForChild("FlashStepMaxExp")
local flashStepLevel = playerData:WaitForChild("FlashStepLevel")
local parent = script.Parent.Parent.Parent.Parent
local parent2 = script.Parent
local allMenu = parent2.Parent.Parent.AllMenu
local main_Aura = parent2:WaitForChild("Main_Aura")
local main_Dodge = parent2:WaitForChild("Main_Dodge")
local main_FlashStep = parent2:WaitForChild("Main_FlashStep")
local auraFrame = main_Aura:WaitForChild("AuraFrame")
local dodgeFrame = main_Dodge:WaitForChild("DodgeFrame")
local flashStepFrame = main_FlashStep:WaitForChild("FlashStepFrame")
local guiEvent = ReplicatedStorage.OtherEvent.GuiEvents:WaitForChild("GuiEvent")
local maxAuraLevel = Setting.Setting.MaxAuraLevel
local maxDodgeLevel = Setting.Setting.MaxDodgeLevel
local maxFlashStepLevel = Setting.Setting.MaxFlashStepLevel
local flashStepCooldown = Setting.Setting.FlashStepCooldown
local instinct_Info = Setting.Setting.Instinct_Info
local max_Distance = instinct_Info.Max_Distance
local dodge_Multiplier = instinct_Info.Dodge_Multiplier
local dodge_Charge = instinct_Info.Dodge_Charge
local v = UserInputService.TouchEnabled and true or false
local v2 = {
	[1.25] = "1",
	[1.5] = "2",
	[1.75] = "3",
	[2] = "4",
	[1000] = "Infinity"
}
local v3 = {
	[1] = "1",
	[1.5] = "2",
	[2] = "3",
	[1000] = "Infinity"
}
local v4 = {
	[1] = "1",
	[1.5] = "2",
	[2] = "3",
	[1000] = "Infinity"
}

local function ConvertToPercent(p)
	return (p - 1) * 100
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OpeningThisFrame()
	return parent.Visible == true and parent.Position == UDim2.new(0.5, 0, 0.5, 0) and allMenu:GetAttribute("CurrentOpen") == parent2.Name
end

local function ShowAura()
	if maxAuraLevel <= auraLevel.Value then
		if localPlayer:GetAttribute("TH") then
			auraFrame.AuraLevel.Text = `เลเวล {v2[auraLevel.Value] or auraLevel.Value} (ตัน)`
		else
			auraFrame.AuraLevel.Text = `Level {v2[auraLevel.Value] or auraLevel.Value} (Max)`
		end
	elseif localPlayer:GetAttribute("TH") then
		auraFrame.AuraLevel.Text = `เลเวล {v2[auraLevel.Value] or auraLevel.Value} (Exp {auraExp.Value}/{auraMaxExp.Value})`
	else
		auraFrame.AuraLevel.Text = `Level {v2[auraLevel.Value] or auraLevel.Value} (Exp {auraExp.Value}/{auraMaxExp.Value})`
	end

	if auraExp.Value >= auraMaxExp.Value then
		TweenService:Create(auraFrame.AuraBar.Bar, TweenInfo.new(0.25), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
	else
		TweenService:Create(auraFrame.AuraBar.Bar, TweenInfo.new(0.25), {
			Size = UDim2.new(auraExp.Value / auraMaxExp.Value, 1, 1, 0)
		}):Play()
	end
end

local function ShowDodge()
	if maxDodgeLevel <= dodgeLevel.Value then
		if localPlayer:GetAttribute("TH") then
			dodgeFrame.DodgeLevel.Text = `เลเวล {v3[dodgeLevel.Value] or dodgeLevel.Value} (ตัน)`
		else
			dodgeFrame.DodgeLevel.Text = `Level {v3[dodgeLevel.Value] or dodgeLevel.Value} (Max)`
		end
	elseif localPlayer:GetAttribute("TH") then
		dodgeFrame.DodgeLevel.Text = `เลเวล {v3[dodgeLevel.Value] or dodgeLevel.Value} (Exp {dodgeExp.Value}/{dodgeMaxExp.Value})`
	else
		dodgeFrame.DodgeLevel.Text = `Level {v3[dodgeLevel.Value] or dodgeLevel.Value} (Exp {dodgeExp.Value}/{dodgeMaxExp.Value})`
	end

	if dodgeExp.Value >= dodgeMaxExp.Value then
		TweenService:Create(dodgeFrame.DodgeBar.Bar, TweenInfo.new(0.25), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
	else
		TweenService:Create(dodgeFrame.DodgeBar.Bar, TweenInfo.new(0.25), {
			Size = UDim2.new(dodgeExp.Value / dodgeMaxExp.Value, 1, 1, 0)
		}):Play()
	end
end

local function ShowFlashStep()
	if maxFlashStepLevel <= flashStepLevel.Value then
		if localPlayer:GetAttribute("TH") then
			flashStepFrame.FlashStepLevel.Text = `เลเวล {v4[flashStepLevel.Value] or flashStepLevel.Value} (ตัน)`
		else
			flashStepFrame.FlashStepLevel.Text = `Level {v4[flashStepLevel.Value] or flashStepLevel.Value} (Max)`
		end
	elseif localPlayer:GetAttribute("TH") then
		flashStepFrame.FlashStepLevel.Text = `เลเวล {v4[flashStepLevel.Value] or flashStepLevel.Value} (Exp {flashStepExp.Value}/{flashStepMaxExp.Value})`
	else
		flashStepFrame.FlashStepLevel.Text = `Level {v4[flashStepLevel.Value] or flashStepLevel.Value} (Exp {flashStepExp.Value}/{flashStepMaxExp.Value})`
	end

	if flashStepExp.Value >= flashStepMaxExp.Value then
		TweenService:Create(flashStepFrame.FlashStepBar.Bar, TweenInfo.new(0.25), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
	else
		TweenService:Create(flashStepFrame.FlashStepBar.Bar, TweenInfo.new(0.25), {
			Size = UDim2.new(flashStepExp.Value / flashStepMaxExp.Value, 1, 1, 0)
		}):Play()
	end
end

local function ShowAura_Buff()
	if localPlayer:GetAttribute("TH") then
		auraFrame.AuraBuff.Text = `+{(auraLevel.Value - 1) * 100}% ดาเมจทั้งหมด`
		auraFrame.AuraTank.Text = `+{(auraLevel.Value - 1) * 100 / 2}% พลังป้องกัน`
	else
		auraFrame.AuraBuff.Text = `+{(auraLevel.Value - 1) * 100}% Damage`
		auraFrame.AuraTank.Text = `+{(auraLevel.Value - 1) * 100 / 2}% Defense`
	end
end

local function ShowDodge_Buff()
	if localPlayer:GetAttribute("TH") then
		dodgeFrame.MaxDodge.Text = `หลบได้สูงสุด {math.ceil(dodge_Multiplier * dodgeLevel.Value)} ครั้ง`
		dodgeFrame.DodgeCD.Text = `+1 การหลบ/{string.format("%.1f", dodge_Charge / dodgeLevel.Value)} วินาที`
		dodgeFrame.DodgeRange.Text = `ระยะสูงสุด {max_Distance * dodgeLevel.Value} เมตร`
	else
		dodgeFrame.MaxDodge.Text = `{math.ceil(dodge_Multiplier * dodgeLevel.Value)} Max Dodges`
		dodgeFrame.DodgeCD.Text = `+1 Dodge/{string.format("%.1f", dodge_Charge / dodgeLevel.Value)} Seconds`
		dodgeFrame.DodgeRange.Text = `{max_Distance * dodgeLevel.Value}m Max Range`
	end
end

local function ShowFlashStep_Buff()
	if localPlayer:GetAttribute("TH") then
		flashStepFrame.FlashStepDistance.Text = `วาร์ปไกลสุด {500 * flashStepLevel.Value} เมตร`
		flashStepFrame.FlashStepCD.Text = `คูลดาวน์ {flashStepCooldown / flashStepLevel.Value} วินาที`
	else
		flashStepFrame.FlashStepDistance.Text = `{500 * flashStepLevel.Value}m Max Distance`
		flashStepFrame.FlashStepCD.Text = `{flashStepCooldown / flashStepLevel.Value}s Cooldown`
	end
end

guiEvent.Event:Connect(function(p)
	if p.MenuName == parent2.Name and p.Action == "Open" then
		ShowAura()
		ShowAura_Buff()
		ShowDodge()
		ShowDodge_Buff()
		ShowFlashStep()
		ShowFlashStep_Buff()
	end
end)
auraExp.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowAura()
	end
end)
auraMaxExp.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowAura()
	end
end)
auraLevel.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowAura()
		ShowAura_Buff()
	end
end)
dodgeExp.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowDodge()
	end
end)
dodgeMaxExp.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowDodge()
	end
end)
dodgeLevel.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowDodge()
		ShowDodge_Buff()
	end
end)
flashStepExp.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowFlashStep()
	end
end)
flashStepMaxExp.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowFlashStep()
	end
end)
flashStepLevel.Changed:Connect(function()
	if OpeningThisFrame() then
		ShowFlashStep()
		ShowFlashStep_Buff()
	end
end)

if v == true then
	flashStepFrame.Hotkey.Visible = false
	dodgeFrame.Hotkey.Visible = false
	auraFrame.Hotkey.Visible = false
end