local v = {
	"If a fish is over its average catch weight, its weight in your inventory will show up in yellow!",
	"All <i>FISH</i> have a small chance to have alternative colorways. These fish are called '<font color='#fff0bc'>Shiny</font>'! ",
	"Finding your favourite spot is important! Multiple <i>different</i> types of fish can spawn in different spots within the same body of water!",
	"On PC, you can favourite items by right clicking on them! This stops them from being sold when pressing 'Sell Inventory'!",
	"Fishing is easy when you get used to it! If you struggle with it, purchase the <i>Training Rod</i>! Then try bettering your control of your rod!",
	"The first ever fish added to 'Fisch' was the '<font color='#fff0bc'>Largemouth Bass</font>'! From then, The models have advanced and become more complicated and made to resemble the general breed of that fish.",
	"The '<font color='#ef794b'>Merchant Brothers</font>' is an extented family of brothers who sell and trade fish! You can find them in plenty of places! How do some stay in business?",
	"The '<font color='#c6ffc8'>Lantern Keeper</font>' is a rare to find vessel that can teleport at will. He is cursed with a constant flow of all possible knowledge at once. However, for 1000C$, you can get a side lantern!- <i>Fun</i>!",
	"<b>Some</b> of these tips are actually important. So maybe give them a read sometime!",
	"You can get a title if you die enough times.",
	"Don't swim for too long or you might drown.",
	"I'd like to personally thank you for playing, " .. (game.Players.LocalPlayer.DisplayName or game.Players.LocalPlayer.Name) .. ". ♡",
	"The Appraiser can re-evaluate your fish to better or worsen its selling price and attributes. However, she can not take away the '<font color='#fff0bc'>Shiny</font>' or '<font color='#fff0bc'>Sparkling</font>' attribute from a fish!",
	"Fisch is fish in german! The developer did not know that until much later in to the development process.",
	"Some fish have a chance to be <font color='#fff0bc'>Sparkling</font>! They sell for 85% more!",
	"One of the <font color='#ef794b'>Merchant Brothers</font> are blind. I wont tell you which one though..",
	"Hi! -kylecat11",
	"Hi, but the loudest! - woozynate",
	"50,000 fish used to live here... now it's a ghost town.",
	"W NICK W UPDATE W FISCH",
	"Hello! Hope your day is going well!",
	"zeeb glorp blep 👽👽👾👾👾👽👾👽👾",
	"Some fish descriptions actually have information on their real life counter-parts!",
	"The supporter halo changes colour depending on your chat name colour!",
	"Receiving a fish from another player causes you to unlock its bestiary info, but not it's bestiary completion percentage. Do it yourself!",
	"<i>Sometimes</i>, jumping in a whirlpool is actually worth it!",
	"The original concept for <b>Fisch</b> came from a random tweet nate saw and a roblox game called 'FISHing GAME' by GluttonyForEggs!"
}
local lastTime = tick()
local v2 = false
local heartbeatConnection = nil
local inputBeganConnection = nil
script.Parent.Text = v[math.random(1, #v)]
local RunService = game:GetService("RunService")
heartbeatConnection = RunService.Heartbeat:Connect(function()
	if tick() - lastTime >= 15 or v2 == true then
		v2 = false
		lastTime = tick()
		script.Parent.Text = v[math.random(1, #v)]
	end

	if script.Parent.Parent.Parent.Enabled == false or script.Parent.TextTransparency ~= 0 then
		if inputBeganConnection then
			inputBeganConnection:Disconnect()
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end
end)
local v3 = false
local UserInputService = game:GetService("UserInputService")
inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if v3 == true or gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Gamepad1 then
		v3 = true
		v2 = true
		task.wait(1)
		v3 = false
	end
end)