local ElfStuckInTree = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local _ = script.Name
local CollectionService = game:GetService("CollectionService")

function AnimateElfSaving(instance, data)
	if instance:GetAttribute("ElfSaved") or instance:GetAttribute("Rescued") then
		return
	end

	instance:SetAttribute("ElfSaved", true)
	local pivot = instance:GetPivot()
	local cFrame = instance.Parent.ElfCF.CFrame
	local cFrame2 = data.ElfLadder1.CFrame
	local cFrame3 = data.ElfLadder2.CFrame
	local cFrame4 = data.ElfLadder3.CFrame
	Client.HelpElfClient.StopAnimation(instance, "Idle")
	Client.HelpElfClient.PlayAnimation(instance, "Climb", -0.5)
	local v = (pivot.Position - cFrame.Position).Magnitude / 8
	print(v)
	local tweenModule = Client.TweenModule.new(function(p, _)
		instance:PivotTo((cFrame2:Lerp(cFrame3, p)))
	end, v)
	tweenModule:BindToComplete(function()
		Client.HelpElfClient.StopAnimation(instance, "Climb")
		instance:PivotTo(cFrame4)
		Client.HelpElfClient.PlayAnimation(instance, "Celebrate")
		Client.Sound.Play("ChristmasHit1")
	end)
	tweenModule:Play()
	task.delay(v + 3, function()
		Client.HelpElfClient.FadeOutElf(instance)
	end)
end

function ElfStuckInTree.AttemptHelpElf(instance)
	print("ATTEMPT HELP ELF STUCK IN TREE", instance)
	local position = instance:GetPivot().Position
	local tagged = CollectionService:GetTagged("LadderTop")
	local v = 1e999
	local v2 = nil

	for _, v3 in pairs(tagged) do
		local parent = v3.Parent
		local magnitude = (position - v3.Position).Magnitude

		if not (magnitude < v and parent.Parent == workspace.Structures) then
			continue
		end

		v2 = parent
		v = magnitude
	end

	if v < 15 then
		AnimateElfSaving(instance, v2)
		Client.Events.Elf_StuckInTree:FireServer(instance, v2)
	else
		Client.PopUpUI.AddPopUp("This elf can't get down without a ladder", "warning")
	end
end

function ElfStuckInTree.Init() end

return ElfStuckInTree