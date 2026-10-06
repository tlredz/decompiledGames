wait(0.1)
local kenHaki = game.Players.LocalPlayer.Character.Services.KenHaki
script.Parent.Text = kenHaki.Value .. " Dodges left"
kenHaki.Changed:Connect(function()
	script.Parent.Text = kenHaki.Value .. " Dodges left"
end)