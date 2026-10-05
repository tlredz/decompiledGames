local ElfSlippedOnIce = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local _ = script.Name
game:GetService("CollectionService")

function IsNaN(p)
	return p ~= p
end

function AnimateElfSaving(instance)
	if instance:GetAttribute("ElfSaved") or instance:GetAttribute("Rescued") then
		return
	end

	instance:SetAttribute("ElfSaved", true)
	local pivot = instance:GetPivot()
	local cFrame = instance.Parent.ElfCF.CFrame
	local cframe = pivot
	Client.HelpElfClient.PlayAnimation(instance, "GetUp")
	task.wait(0.5)
	Client.HelpElfClient.StopAnimation(instance, "Idle")
	task.wait(2)
	Client.HelpElfClient.PlayAnimation(instance, "IceSkate")
	local v = (pivot.Position - cFrame.Position).Magnitude / 8
	local tweenModule = Client.TweenModule.new(function(p, p2)
		local position = pivot:Lerp(cFrame, p).Position
		cframe = cframe - cframe.Position + position
		local lookVector = cframe.LookVector
		local unit = (cFrame.Position - position).Unit
		local angleBetweenVectors, v2 = Client.Utility.GetAngleBetweenVectors(lookVector, unit)
		local v3 = 5.235987755982989 * p2
		local v4 = math.min(angleBetweenVectors, v3) * v2

		if not (IsNaN(v4) or IsNaN(unit)) then
			if math.abs(v4) < v3 then
				cframe = CFrame.lookAlong(cframe.Position, unit)
			else
				cframe *= CFrame.Angles(0, v4, 0)
			end
		end

		instance:PivotTo(cframe)
	end, v)
	tweenModule:BindToComplete(function()
		Client.HelpElfClient.StopAnimation(instance, "IceSkate")
		Client.HelpElfClient.PlayAnimation(instance, "Celebrate")
		Client.Sound.Play("ChristmasHit1")
	end)
	tweenModule:Play()
	task.wait(7)
	Client.HelpElfClient.FadeOutElf(instance)
end

Client.Events.Elf_AnimateSlippedOnIce:Connect(function(p)
	AnimateElfSaving(p)
end)

function ElfSlippedOnIce.AttemptHelpElf(p)
	print("ATTEMPT HELP ELF SLIPPED ON ICE", p)

	if not localPlayer:GetAttribute("IceSkates") then
		Client.HelpElfClient.AddElfMessage("the ice is to slippery to help this elf across", p, true)
		return
	end

	task.spawn(function()
		AnimateElfSaving(p)
	end)
	Client.Events.Elf_SlippedOnIce:FireServer(p)
end

function ElfSlippedOnIce.Init() end

return ElfSlippedOnIce