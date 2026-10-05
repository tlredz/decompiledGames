wait(0.2)
local module = require(script.Parent:FindFirstChild("RichText") or script.Parent.Parent)
script.Parent.Enabled = true
local v = { script.Parent.Frame.TextBox1, script.Parent.Frame.TextBox2, script.Parent.Frame.TextBox3 }
local v2 = module:New(
	v[1],
	"He thinks about walking at night to avoid the heat and sun, but based upon how dark it actually was the night before, and given that he has no flashlight, he's afraid that he'll break a leg or step on a rattlesnake. <Color=Yellow>So, he puts on some sun block, puts the rest in his pocket for reapplication later, <Color=/>brings an umbrella he'd had in the back of the SUV with him to give him a little shade, pours the windshield wiper fluid into his water bottle in case he gets that desperate, brings his pocket knife in case he finds a cactus that looks like it might have water in it, and heads out in the direction he thinks is right.",
	{
		ContainerVerticalAlignment = "Top"
	},
	false
)
local v3 = v2

for i = 2, #v do
	if v3.Overflown then
		v3 = module:ContinueOverflow(v[i], v3)
	end
end

v2:Animate(true)