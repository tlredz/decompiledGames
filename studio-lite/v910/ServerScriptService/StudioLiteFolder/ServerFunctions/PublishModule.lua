local PublishModule = {}
PublishModule.__index = PublishModule
local HttpService = game:GetService("HttpService")
local v = {
	StarterPlayerScripts = [[
<Item class="StarterPlayerScripts" referent="RBX2F7BA2260AFA4FE5833F026C6CCE9F57">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">StarterPlayerScripts</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000036f</UniqueId>
</Properties>
]],
	StarterCharacterScripts = [[
<Item class="StarterCharacterScripts" referent="RBX7779C12C152047E2A2FF87393A44D41E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">StarterCharacterScripts</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000370</UniqueId>
</Properties>
]],
	SpawnLocation = [[
<Item class="SpawnLocation" referent="RBX3C7695D5290E477487A20CEE29AEBCF2">
<Properties>
<bool name="AllowTeamChangeOnTouch">false</bool>
<bool name="Anchored">true</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BackSurface">0</token>
<token name="BottomSurface">0</token>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0.5</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4288914085</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<int name="Duration">0</int>
<bool name="EnableFluidForces">true</bool>
<bool name="Enabled">true</bool>
<token name="FrontSurface">0</token>
<token name="LeftSurface">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<string name="Name">SpawnLocation</string>
<bool name="Neutral">true</bool>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RightSurface">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<int name="TeamColor">194</int>
<token name="TopSurface">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000036c</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="FormFactorRaw">1</token>
<token name="Shape">1</token>
<Vector3 name="Size">
<X>12</X>
<Y>1</Y>
<Z>12</Z>
</Vector3>
</Properties>
]],
	Attachment = [[
<Item class="Attachment" referent="RBXBD048CC0DFED469FB6219A35DD53880D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<string name="Name">Attachment</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000432c</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	Bone = [[
<Item class="Bone" referent="RBX2A9863CD62CC45208C83F1734D75E039">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<string name="Name">Bone</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000432e</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	BindableEvent = [[
<Item class="BindableEvent" referent="RBX297D0D2741284F21B8216452FFF84A65">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Event</string>
<UniqueId name="UniqueId">377df23608bc6c70067eb1c90000440b</UniqueId>
</Properties>
]],
	Script = [=[
<Item class="Script" referent="RBX66C1625455D04AC580D81E01C9513A7E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Disabled">false</bool>
<Content name="LinkedSource"><null></null></Content>
<string name="Name">Script</string>
<token name="RunContext">0</token>
<string name="ScriptGuid">{FF361BB9-5B67-4864-AADE-7E5A85E36A3E}</string>
<ProtectedString name="Source">print(&quot;Hello it&apos;s \&quot; wo--]]&gt;&lt;/rld!&quot;)
script.Parent.Touched:Connect(function()
&#9;script.Parent.BrickColor = BrickColor.random()
end)</ProtectedString>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a000041fa</UniqueId>
</Properties>
]=],
	Folder = [[
<Item class="Folder" referent="RBXC7F38F5F49694AFF826B4662532EF763">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Folder</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000430e</UniqueId>
</Properties>
]],
	Tool = [[
<Item class="Tool" referent="RBX49DC52B61922403DBD366CF81F4A6C1D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="CanBeDropped">true</bool>
<bool name="Enabled">true</bool>
<CoordinateFrame name="Grip">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<token name="LevelOfDetail">0</token>
<bool name="ManualActivationOnly">false</bool>
<CoordinateFrame name="ModelMeshCFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<SharedString name="ModelMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<Vector3 name="ModelMeshSize">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="ModelStreamingMode">0</token>
<string name="Name">Tool</string>
<bool name="NeedsPivotMigration">false</bool>
<Ref name="PrimaryPart">null</Ref>
<bool name="RequiresHandle">true</bool>
<float name="ScaleFactor">1</float>
<Content name="TextureId"><null></null></Content>
<string name="ToolTip"></string>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000430f</UniqueId>
<OptionalCoordinateFrame name="WorldPivotData"></OptionalCoordinateFrame>
</Properties>
]],
	Model = [[
<Item class="Model" referent="RBXD892B28CA57646F18A821C94EEFF520C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="LevelOfDetail">0</token>
<CoordinateFrame name="ModelMeshCFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<SharedString name="ModelMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<Vector3 name="ModelMeshSize">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="ModelStreamingMode">0</token>
<string name="Name">Model</string>
<bool name="NeedsPivotMigration">false</bool>
<Ref name="PrimaryPart">null</Ref>
<float name="ScaleFactor">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004311</UniqueId>
<OptionalCoordinateFrame name="WorldPivotData"></OptionalCoordinateFrame>
</Properties>
]],
	ClickDetector = [[
<Item class="ClickDetector" referent="RBX46176F3C45F545AABBF01DF34DC0F53F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Content name="CursorIcon"><null></null></Content>
<float name="MaxActivationDistance">32</float>
<string name="Name">ClickDetector</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004312</UniqueId>
</Properties>
]],
	Decal = [[
<Item class="Decal" referent="RBXB05767C29B254B2FA219A5C27AD07684">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<token name="Face">5</token>
<string name="Name">Decal</string>
<Content name="Texture"><null></null></Content>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004313</UniqueId>
<int name="ZIndex">1</int>
</Properties>
]],
	Dialog = [[
<Item class="Dialog" referent="RBX935EBC792FB846F7A98494B1D3AD8A36">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BehaviorType">0</token>
<float name="ConversationDistance">25</float>
<bool name="GoodbyeChoiceActive">true</bool>
<string name="GoodbyeDialog"></string>
<string name="InitialPrompt"></string>
<string name="Name">Dialog</string>
<token name="Purpose">1</token>
<token name="Tone">0</token>
<float name="TriggerDistance">0</float>
<Vector3 name="TriggerOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004314</UniqueId>
</Properties>
]],
	DialogChoice = [[
<Item class="DialogChoice" referent="RBXDD3DDAB336574C7C8C1CB211DD0BA922">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="GoodbyeChoiceActive">true</bool>
<string name="GoodbyeDialog"></string>
<string name="Name">DialogChoice</string>
<string name="ResponseDialog"></string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004315</UniqueId>
<string name="UserDialog"></string>
</Properties>
]],
	DragDetector = [[
<Item class="DragDetector" referent="RBX10E56A3A574E4D9EA939D3D55563AE92">
<Properties>
<Content name="ActivatedCursorIcon"><null></null></Content>
<bool name="ApplyAtCenterOfMass">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<Content name="CursorIcon"><null></null></Content>
<CoordinateFrame name="DragFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<token name="DragStyle">1</token>
<bool name="Enabled">true</bool>
<token name="GamepadModeSwitchKeyCode">1004</token>
<token name="KeyboardModeSwitchKeyCode">306</token>
<float name="MaxActivationDistance">32</float>
<float name="MaxDragAngle">0</float>
<Vector3 name="MaxDragTranslation">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="MaxForce">10000000</float>
<float name="MaxTorque">10000</float>
<float name="MinDragAngle">0</float>
<Vector3 name="MinDragTranslation">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<string name="Name">DragDetector</string>
<Vector3 name="Orientation">
<X>-0</X>
<Y>180</Y>
<Z>90</Z>
</Vector3>
<token name="PermissionPolicy">1</token>
<Ref name="ReferenceInstance">null</Ref>
<token name="ResponseStyle">1</token>
<float name="Responsiveness">10</float>
<bool name="RunLocally">false</bool>
<float name="TrackballRadialPullFactor">1</float>
<float name="TrackballRollFactor">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004316</UniqueId>
<token name="VRSwitchKeyCode">1007</token>
</Properties>
]],
	MaterialVariant = [[
<Item class="MaterialVariant" referent="RBX8AAA4E91D61F485DA34B4CFE5DBA45FE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><null></null></Content>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">MaterialVariant</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><null></null></Content>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004317</UniqueId>
</Properties>
]],
	ProximityPrompt = [[
<Item class="ProximityPrompt" referent="RBX09A95F31CBE34EDEBAE20CD998151B3F">
<Properties>
<string name="ActionText">Interact</string>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<bool name="ClickablePrompt">true</bool>
<bool name="Enabled">true</bool>
<token name="Exclusivity">0</token>
<token name="GamepadKeyCode">1000</token>
<float name="HoldDuration">0</float>
<token name="KeyboardKeyCode">101</token>
<float name="MaxActivationDistance">10</float>
<string name="Name">ProximityPrompt</string>
<string name="ObjectText"></string>
<bool name="RequiresLineOfSight">true</bool>
<Ref name="RootLocalizationTable">null</Ref>
<token name="Style">0</token>
<Vector2 name="UIOffset">
<X>0</X>
<Y>0</Y>
</Vector2>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004318</UniqueId>
</Properties>
]],
	SurfaceAppearance = [[
<Item class="SurfaceAppearance" referent="RBX3FA9EDB055BC454CA0BFBA503986D23B">
<Properties>
<token name="AlphaMode">0</token>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<Content name="ColorMap"><null></null></Content>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">SurfaceAppearance</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><null></null></Content>
<Content name="TexturePack"><null></null></Content>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004319</UniqueId>
</Properties>
]],
	TerrainDetail = [[
<Item class="TerrainDetail" referent="RBX346F7572B66C4BC99FA996CF16B22A4A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Content name="ColorMap"><null></null></Content>
<token name="Face">1</token>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">TerrainDetail</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><null></null></Content>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000431a</UniqueId>
</Properties>
]],
	Texture = [[
<Item class="Texture" referent="RBX4A4FDC7F5BF84C11BDC3029EF81BD522">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<token name="Face">5</token>
<string name="Name">Texture</string>
<float name="OffsetStudsU">0</float>
<float name="OffsetStudsV">0</float>
<float name="StudsPerTileU">2</float>
<float name="StudsPerTileV">2</float>
<Content name="Texture"><null></null></Content>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000431b</UniqueId>
<int name="ZIndex">1</int>
</Properties>
]],
	PathfindingLink = [[
<Item class="PathfindingLink" referent="RBX58EC7AE29DC7473CBC2546488790AEFC">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="IsBidirectional">true</bool>
<string name="Label"></string>
<string name="Name">PathfindingLink</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000431c</UniqueId>
</Properties>
]],
	Animation = [[
<Item class="Animation" referent="RBX575D3C6114F2402FB518FFF6EBE5BBE6">
<Properties>
<Content name="AnimationId"><null></null></Content>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Animation</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000431d</UniqueId>
</Properties>
]],
	AnimationController = [[
<Item class="AnimationController" referent="RBXADFD515EE4F34AAC87B11DA7BD0ECE9A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">AnimationController</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000431e</UniqueId>
</Properties>
]],
	FaceControls = [[
<Item class="FaceControls" referent="RBX42D43E1FB81842208A5D31AA43B403FB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">FaceControls</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000431f</UniqueId>
</Properties>
]],
	Motor6D = [[
<Item class="Motor6D" referent="RBXD8C70B754351452880626053EDA1F597">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="DesiredAngle">0</float>
<bool name="Enabled">true</bool>
<float name="MaxVelocity">0</float>
<string name="Name">Motor6D</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004320</UniqueId>
</Properties>
]],
	Accessory = [[
<Item class="Accessory" referent="RBX0B84E1BAFC524268A86D3281968BA5DD">
<Properties>
<token name="AccessoryType">0</token>
<CoordinateFrame name="AttachmentPoint">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Accessory</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004321</UniqueId>
</Properties>
]],
	ForceField = [[
<Item class="ForceField" referent="RBX1B178256031C4BF2843B92B00DF3D2A7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">ForceField</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004322</UniqueId>
<bool name="Visible">true</bool>
</Properties>
]],
	BodyColors = [[
<Item class="BodyColors" referent="RBX81ED835066EF441EB2CBFC5F5FB2F86F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="HeadColor3">
<R>0.992156923</R>
<G>0.917647123</G>
<B>0.552941203</B>
</Color3>
<Color3 name="LeftArmColor3">
<R>0.992156923</R>
<G>0.917647123</G>
<B>0.552941203</B>
</Color3>
<Color3 name="LeftLegColor3">
<R>0.0509803966</R>
<G>0.411764741</G>
<B>0.674509823</B>
</Color3>
<string name="Name">Body Colors</string>
<Color3 name="RightArmColor3">
<R>0.992156923</R>
<G>0.917647123</G>
<B>0.552941203</B>
</Color3>
<Color3 name="RightLegColor3">
<R>0.0509803966</R>
<G>0.411764741</G>
<B>0.674509823</B>
</Color3>
<Color3 name="TorsoColor3">
<R>0.156862751</R>
<G>0.498039246</G>
<B>0.278431386</B>
</Color3>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004323</UniqueId>
</Properties>
]],
	Humanoid = [=[
<Item class="Humanoid" referent="RBXABB4C1104ECC4BC785961676FBD896E8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoJumpEnabled">true</bool>
<bool name="AutoRotate">true</bool>
<bool name="AutomaticScalingEnabled">true</bool>
<bool name="BreakJointsOnDeath">true</bool>
<token name="CollisionType">0</token>
<token name="DisplayDistanceType">0</token>
<string name="DisplayName"></string>
<bool name="EvaluateStateMachine">true</bool>
<float name="HealthDisplayDistance">100</float>
<token name="HealthDisplayType">0</token>
<float name="Health_XML">100</float>
<float name="HipHeight">0</float>
<Vector3 name="InternalBodyScale">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
<float name="InternalHeadScale">1</float>
<float name="JumpHeight">7.19999981</float>
<float name="JumpPower">50</float>
<float name="MaxHealth">100</float>
<float name="MaxSlopeAngle">89</float>
<string name="Name">Humanoid</string>
<float name="NameDisplayDistance">100</float>
<token name="NameOcclusion">2</token>
<bool name="RequiresNeck">true</bool>
<token name="RigType">0</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004324</UniqueId>
<bool name="UseJumpPower">true</bool>
<float name="WalkSpeed">16</float>
</Properties>
    <Item class="Script" referent="RBX66C1625455D04AC580D81E01C9513A7E">
	<Properties>
	<BinaryString name="AttributesSerialize"></BinaryString>
	<bool name="Disabled">false</bool>
	<Content name="LinkedSource"><null></null></Content>
	<string name="Name">Script</string>
	<token name="RunContext">0</token>
	<string name="ScriptGuid">{FF361BB9-5B67-4864-AADE-7E5A85E36A3E}</string>
	<ProtectedString name="Source"><![CDATA[--FixSurfaceAppearanceScript  -  If the humanoid published by Studio Lite has a SurfaceAppearance instance,
--      this script will reapply/reset the Humanoid Descriptions.  This is needed since Roblox prevents
--      developer scripts from viewing the properties of a SurfaceAppearance.  ScottSpiritWalker, 12/20/2024.
wait(.5)
local h = script.Parent
local hd = h:FindFirstChild("HumanoidDescription")
if hd then
	local found = {}  --delete duplicate Accessory and BodyParts children.  BodyParts can have duplicate assetIds, but accessories cannot. 
	for _,c in pairs(hd:GetChildren()) do
		if c.ClassName == "AccessoryDescription" then
			if found[c.AssetId] then
				--print("Deleting dup",c.AssetId)
				c:Destroy()
			else
				found[c.AssetId] = 1
			end
		elseif c.ClassName == "BodyPartDescription" then
			if found[c.BodyPart] then
				--print("Deleting dup",c.AssetId)
				c:Destroy()
			else
				found[c.BodyPart] = 1
			end				
		end
	end
	if h.Parent:FindFirstChildWhichIsA("SurfaceAppearance",true) then
		local t = {}
		if hd.Head == 3064931584 then  --old zombie save off textures.
			for i,j in pairs(h.Parent:GetChildren()) do
				if j.ClassName == "MeshPart" then
					t[j.Name] = j.TextureID
				end
			end
		end
		h:ApplyDescriptionReset(hd)
		if next(t) then  
			for i,j in pairs(h.Parent:GetChildren()) do
				if j.ClassName == "MeshPart" then
					print(j.Name, j.MeshId,j.TextureID, t[j.MeshId])
					if t[j.Name] then
						j.TextureID = t[j.Name] 
					end
				end
			end
		end
		--print("Applied SurfaceAppearance.")
	end
end
wait()
script:Destroy()
	]]></ProtectedString>
	<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a000041fa</UniqueId>
	</Properties>
	</Item>
]=],
	Animator = [[
<Item class="Animator" referent="RBX06190DA6D0B546089CB521D3B98B2BC1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Animator</string>
<bool name="PreferLodEnabled">true</bool>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000432d</UniqueId>
</Properties>
]],
	Pants = [[
<Item class="Pants" referent="RBX7090DDCEB0ED41C1A07E3357D99BC6DC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<string name="Name">Clothing</string>
<Content name="PantsTemplate"><null></null></Content>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004326</UniqueId>
</Properties>
]],
	Shirt = [[
<Item class="Shirt" referent="RBXFD65D4B00BC8423C8D9765F9F91D76FE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<string name="Name">Clothing</string>
<Content name="ShirtTemplate"><null></null></Content>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004327</UniqueId>
</Properties>
]],
	ShirtGraphic = [[
<Item class="ShirtGraphic" referent="RBXFEC32F9795254FC4B1EBA215FC8B3179">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<Content name="Graphic"><null></null></Content>
<string name="Name">Shirt Graphic</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004328</UniqueId>
</Properties>
]],
	AlignOrientation = [[
<Item class="AlignOrientation" referent="RBX04261247A7034222BB9E5B22FCC32B0E">
<Properties>
<token name="AlignType">5</token>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<int name="Color">23</int>
<bool name="Enabled">true</bool>
<float name="MaxAngularVelocity">INF</float>
<float name="MaxTorque">10000</float>
<token name="Mode">1</token>
<string name="Name">AlignOrientation</string>
<bool name="PrimaryAxisOnly">false</bool>
<bool name="ReactionTorqueEnabled">false</bool>
<float name="Responsiveness">10</float>
<bool name="RigidityEnabled">false</bool>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004329</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	AlignPosition = [[
<Item class="AlignPosition" referent="RBXBE2DEBB277334294B3C13E1E56A97B8C">
<Properties>
<bool name="ApplyAtCenterOfMass">false</bool>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">194</int>
<bool name="Enabled">true</bool>
<token name="ForceLimitMode">0</token>
<token name="ForceRelativeTo">2</token>
<Vector3 name="MaxAxesForce">
<X>10000</X>
<Y>10000</Y>
<Z>10000</Z>
</Vector3>
<float name="MaxForce">10000</float>
<float name="MaxVelocity">INF</float>
<token name="Mode">1</token>
<string name="Name">AlignPosition</string>
<Vector3 name="Position">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<bool name="ReactionForceEnabled">false</bool>
<float name="Responsiveness">10</float>
<bool name="RigidityEnabled">false</bool>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000432a</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	AngularVelocity = [[
<Item class="AngularVelocity" referent="RBXBBC9EEC4DC33444989F79009FC91F47F">
<Properties>
<Vector3 name="AngularVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">23</int>
<bool name="Enabled">true</bool>
<float name="MaxTorque">0</float>
<string name="Name">AngularVelocity</string>
<bool name="ReactionTorqueEnabled">false</bool>
<token name="RelativeTo">2</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000432b</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	BallSocketConstraint = [[
<Item class="BallSocketConstraint" referent="RBX8E8CB23789E3410EBEA89021B551872C">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">1009</int>
<bool name="Enabled">true</bool>
<bool name="LimitsEnabled">false</bool>
<float name="MaxFrictionTorqueXml">0</float>
<string name="Name">BallSocketConstraint</string>
<float name="Radius">0.150000006</float>
<float name="Restitution">0</float>
<bool name="TwistLimitsEnabled">false</bool>
<float name="TwistLowerAngle">-45</float>
<float name="TwistUpperAngle">45</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004330</UniqueId>
<float name="UpperAngle">45</float>
<bool name="Visible">false</bool>
</Properties>
]],
	CylindricalConstraint = [[
<Item class="CylindricalConstraint" referent="RBX0F06AB9ED80F48F39379EAE03668E281">
<Properties>
<token name="ActuatorType">0</token>
<token name="AngularActuatorType">0</token>
<bool name="AngularLimitsEnabled">false</bool>
<float name="AngularResponsiveness">45</float>
<float name="AngularRestitution">0</float>
<float name="AngularSpeed">0</float>
<float name="AngularVelocity">0</float>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">1009</int>
<bool name="Enabled">true</bool>
<float name="InclinationAngle">0</float>
<bool name="LimitsEnabled">false</bool>
<float name="LinearResponsiveness">45</float>
<float name="LowerAngle">-45</float>
<float name="LowerLimit">0</float>
<float name="MotorMaxAcceleration">INF</float>
<float name="MotorMaxAngularAcceleration">500000</float>
<float name="MotorMaxForce">0</float>
<float name="MotorMaxTorque">0</float>
<string name="Name">CylindricalConstraint</string>
<float name="Restitution">0</float>
<bool name="RotationAxisVisible">false</bool>
<float name="ServoMaxForce">0</float>
<float name="ServoMaxTorque">0</float>
<float name="Size">0.150000006</float>
<bool name="SoftlockAngularServoUponReachingTarget">false</bool>
<bool name="SoftlockServoUponReachingTarget">false</bool>
<float name="Speed">0</float>
<float name="TargetAngle">0</float>
<float name="TargetPosition">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004331</UniqueId>
<float name="UpperAngle">45</float>
<float name="UpperLimit">5</float>
<float name="Velocity">0</float>
<bool name="Visible">false</bool>
</Properties>
]],
	HingeConstraint = [[
<Item class="HingeConstraint" referent="RBX23A5BBAE7F804D78897DF2C2B899EB0A">
<Properties>
<token name="ActuatorType">0</token>
<float name="AngularResponsiveness">45</float>
<float name="AngularSpeed">0</float>
<float name="AngularVelocity">0</float>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">1009</int>
<bool name="Enabled">true</bool>
<bool name="LimitsEnabled">false</bool>
<float name="LowerAngle">-45</float>
<float name="MotorMaxAcceleration">500000</float>
<float name="MotorMaxTorque">0</float>
<string name="Name">HingeConstraint</string>
<float name="Radius">0.150000006</float>
<float name="Restitution">0</float>
<float name="ServoMaxTorque">0</float>
<bool name="SoftlockServoUponReachingTarget">false</bool>
<float name="TargetAngle">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004332</UniqueId>
<float name="UpperAngle">45</float>
<bool name="Visible">false</bool>
</Properties>
]],
	LinearVelocity = [[
<Item class="LinearVelocity" referent="RBXF03CD4987A684F89BA1ED899ED70AF03">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">26</int>
<bool name="Enabled">true</bool>
<token name="ForceLimitMode">0</token>
<bool name="ForceLimitsEnabled">true</bool>
<Vector3 name="LineDirection">
<X>1</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="LineVelocity">-0</float>
<Vector3 name="MaxAxesForce">
<X>1000</X>
<Y>1000</Y>
<Z>1000</Z>
</Vector3>
<float name="MaxForce">1000</float>
<Vector2 name="MaxPlanarAxesForce">
<X>1000</X>
<Y>1000</Y>
</Vector2>
<string name="Name">LinearVelocity</string>
<Vector2 name="PlaneVelocity">
<X>0</X>
<Y>0</Y>
</Vector2>
<Vector3 name="PrimaryTangentAxis">
<X>1</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="RelativeTo">2</token>
<Vector3 name="SecondaryTangentAxis">
<X>0</X>
<Y>1</Y>
<Z>0</Z>
</Vector3>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004333</UniqueId>
<Vector3 name="VectorVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="VelocityConstraintMode">2</token>
<bool name="Visible">false</bool>
</Properties>
]],
	LineForce = [[
<Item class="LineForce" referent="RBX6F2F480B1FBF49DD9E18A21A7750C8B6">
<Properties>
<bool name="ApplyAtCenterOfMass">false</bool>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">23</int>
<bool name="Enabled">true</bool>
<bool name="InverseSquareLaw">false</bool>
<float name="Magnitude">1000</float>
<float name="MaxForce">INF</float>
<string name="Name">LineForce</string>
<bool name="ReactionForceEnabled">false</bool>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004334</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	NoCollisionConstraint = [[
<Item class="NoCollisionConstraint" referent="RBX1CDF64E310A44ACF8D97D16CB85F65FB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<string name="Name">NoCollisionConstraint</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004335</UniqueId>
</Properties>
]],
	PlaneConstraint = [[
<Item class="PlaneConstraint" referent="RBX2EAFCF4DF88B4413A07B017B3F1D2DE7">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">194</int>
<bool name="Enabled">true</bool>
<string name="Name">PlaneConstraint</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004336</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	PrismaticConstraint = [[
<Item class="PrismaticConstraint" referent="RBX1E7B292C502E452DA39B0D11ADA1FF69">
<Properties>
<token name="ActuatorType">0</token>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">1009</int>
<bool name="Enabled">true</bool>
<bool name="LimitsEnabled">false</bool>
<float name="LinearResponsiveness">45</float>
<float name="LowerLimit">0</float>
<float name="MotorMaxAcceleration">INF</float>
<float name="MotorMaxForce">0</float>
<string name="Name">PrismaticConstraint</string>
<float name="Restitution">0</float>
<float name="ServoMaxForce">0</float>
<float name="Size">0.150000006</float>
<bool name="SoftlockServoUponReachingTarget">false</bool>
<float name="Speed">0</float>
<float name="TargetPosition">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004337</UniqueId>
<float name="UpperLimit">5</float>
<float name="Velocity">0</float>
<bool name="Visible">false</bool>
</Properties>
]],
	RigidConstraint = [[
<Item class="RigidConstraint" referent="RBX2514D2104F3347E18F48ACF442921308">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">194</int>
<bool name="Enabled">true</bool>
<string name="Name">RigidConstraint</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004338</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	RodConstraint = [[
<Item class="RodConstraint" referent="RBX06E24FA1DE524E57970A97F953FE7C51">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">26</int>
<bool name="Enabled">true</bool>
<float name="Length">5</float>
<float name="LimitAngle0">90</float>
<float name="LimitAngle1">90</float>
<bool name="LimitsEnabled">false</bool>
<string name="Name">RodConstraint</string>
<float name="Thickness">0.100000001</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004339</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	RopeConstraint = [[
<Item class="RopeConstraint" referent="RBXB3A0A5A81F57454EA09A2894F26AECD9">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">25</int>
<bool name="Enabled">true</bool>
<float name="Length">5</float>
<string name="Name">RopeConstraint</string>
<float name="Restitution">0</float>
<float name="Thickness">0.100000001</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000433a</UniqueId>
<bool name="Visible">false</bool>
<bool name="WinchEnabled">false</bool>
<float name="WinchForce">10000</float>
<float name="WinchResponsiveness">45</float>
<float name="WinchSpeed">2</float>
<float name="WinchTarget">5</float>
</Properties>
]],
	SpringConstraint = [[
<Item class="SpringConstraint" referent="RBX79FCA03E8DA14CE694207BEFDAF12CE0">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Coils">3</float>
<int name="Color">200</int>
<float name="Damping">0</float>
<bool name="Enabled">true</bool>
<float name="FreeLength">1</float>
<bool name="LimitsEnabled">false</bool>
<float name="MaxForce">INF</float>
<float name="MaxLength">5</float>
<float name="MinLength">0</float>
<string name="Name">SpringConstraint</string>
<float name="Radius">0.400000006</float>
<float name="Stiffness">0</float>
<float name="Thickness">0.100000001</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000433b</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	Torque = [[
<Item class="Torque" referent="RBX69A5655EB2294222B8770F4ECEABB896">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">23</int>
<bool name="Enabled">true</bool>
<string name="Name">Torque</string>
<token name="RelativeTo">0</token>
<Vector3 name="Torque">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000433c</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	TorsionSpringConstraint = [[
<Item class="TorsionSpringConstraint" referent="RBXF305F7FC761B42D1B89EE2F00B3A9C23">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Coils">8</float>
<int name="Color">200</int>
<float name="Damping">0.00999999978</float>
<bool name="Enabled">true</bool>
<bool name="LimitEnabled">false</bool>
<bool name="LimitsEnabled">false</bool>
<float name="MaxAngle">45</float>
<float name="MaxTorque">INF</float>
<string name="Name">TorsionSpringConstraint</string>
<float name="Radius">0.400000006</float>
<float name="Restitution">0</float>
<float name="Stiffness">100</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000433d</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	UniversalConstraint = [[
<Item class="UniversalConstraint" referent="RBXB304D88E50EC487682E0DDB0429E8157">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">1009</int>
<bool name="Enabled">true</bool>
<bool name="LimitsEnabled">false</bool>
<float name="MaxAngle">45</float>
<string name="Name">UniversalConstraint</string>
<float name="Radius">0.200000003</float>
<float name="Restitution">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000433e</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	VectorForce = [[
<Item class="VectorForce" referent="RBXDE71098CE63749BDBFEE533CC8092693">
<Properties>
<bool name="ApplyAtCenterOfMass">false</bool>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Color">23</int>
<bool name="Enabled">true</bool>
<Vector3 name="Force">
<X>1000</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<string name="Name">VectorForce</string>
<token name="RelativeTo">0</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000433f</UniqueId>
<bool name="Visible">false</bool>
</Properties>
]],
	WeldConstraint = [[
<Item class="WeldConstraint" referent="RBX30B3B406111F492DB9D86E9320FA8F3A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">WeldConstraint</string>
<Ref name="Part0Internal">null</Ref>
<Ref name="Part1Internal">null</Ref>
<int name="State">3</int>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004340</UniqueId>
</Properties>
]],
	Beam = [[
<Item class="Beam" referent="RBX3BA2DB06496845648332275AFE7B367D">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Brightness">1</float>
<ColorSequence name="Color">0 1 1 1 0 1 1 1 1 0 </ColorSequence>
<float name="CurveSize0">0</float>
<float name="CurveSize1">0</float>
<bool name="Enabled">true</bool>
<bool name="FaceCamera">false</bool>
<float name="LightEmission">0</float>
<float name="LightInfluence">1</float>
<string name="Name">Beam</string>
<int name="Segments">10</int>
<Content name="Texture"><null></null></Content>
<float name="TextureLength">1</float>
<token name="TextureMode">0</token>
<float name="TextureSpeed">1</float>
<NumberSequence name="Transparency">0 0.5 0 1 0.5 0 </NumberSequence>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004341</UniqueId>
<float name="Width0">1</float>
<float name="Width1">1</float>
<float name="ZOffset">0</float>
</Properties>
]],
	Explosion = [[
<Item class="Explosion" referent="RBX427B23FADD524A4B9D125310FA668421">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="BlastPressure">500000</float>
<float name="BlastRadius">4</float>
<float name="DestroyJointRadiusPercent">1</float>
<token name="ExplosionType">1</token>
<string name="Name">Explosion</string>
<Vector3 name="Position">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="TimeScale">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004342</UniqueId>
<bool name="Visible">true</bool>
</Properties>
]],
	Fire = [[
<Item class="Fire" referent="RBXBFB0B07CC22A4186A58D60E50DD061CE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color">
<R>0.92549026</R>
<G>0.545098066</G>
<B>0.274509817</B>
</Color3>
<bool name="Enabled">true</bool>
<string name="Name">Fire</string>
<Color3 name="SecondaryColor">
<R>0.545098066</R>
<G>0.313725501</G>
<B>0.215686291</B>
</Color3>
<float name="TimeScale">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004343</UniqueId>
<float name="heat_xml">9</float>
<float name="size_xml">5</float>
</Properties>
]],
	Highlight = [[
<Item class="Highlight" referent="RBX3023AD2552C94B089899A10558696F51">
<Properties>
<Ref name="Adornee">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="DepthMode">0</token>
<bool name="Enabled">true</bool>
<Color3 name="FillColor">
<R>1</R>
<G>0</G>
<B>0</B>
</Color3>
<float name="FillTransparency">0.5</float>
<string name="Name">Highlight</string>
<Color3 name="OutlineColor">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="OutlineTransparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004344</UniqueId>
</Properties>
]],
	ParticleEmitter = [[
<Item class="ParticleEmitter" referent="RBX6283F24D8ECC4B5AA544090F6102C0F3">
<Properties>
<Vector3 name="Acceleration">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Brightness">1</float>
<ColorSequence name="Color">0 1 1 1 0 1 1 1 1 0 </ColorSequence>
<float name="Drag">0</float>
<token name="EmissionDirection">1</token>
<bool name="Enabled">true</bool>
<NumberRange name="FlipbookFramerate">1 1 </NumberRange>
<string name="FlipbookIncompatible">Particle texture must be 1024 by 1024 to use flipbooks.</string>
<token name="FlipbookLayout">0</token>
<token name="FlipbookMode">0</token>
<bool name="FlipbookStartRandom">false</bool>
<NumberRange name="Lifetime">5 10 </NumberRange>
<float name="LightEmission">0</float>
<float name="LightInfluence">1</float>
<bool name="LockedToPart">false</bool>
<string name="Name">ParticleEmitter</string>
<token name="Orientation">0</token>
<float name="Rate">20</float>
<NumberRange name="RotSpeed">0 0 </NumberRange>
<NumberRange name="Rotation">0 0 </NumberRange>
<token name="Shape">0</token>
<token name="ShapeInOut">0</token>
<float name="ShapePartial">1</float>
<token name="ShapeStyle">0</token>
<NumberSequence name="Size">0 1 0 1 1 0 </NumberSequence>
<NumberRange name="Speed">5 5 </NumberRange>
<Vector2 name="SpreadAngle">
<X>0</X>
<Y>0</Y>
</Vector2>
<NumberSequence name="Squash">0 0 0 1 0 0 </NumberSequence>
<Content name="Texture"><url>rbxasset://textures/particles/sparkles_main.dds</url></Content>
<float name="TimeScale">1</float>
<NumberSequence name="Transparency">0 0 0 1 0 0 </NumberSequence>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004345</UniqueId>
<float name="VelocityInheritance">0</float>
<bool name="WindAffectsDrag">false</bool>
<float name="ZOffset">0</float>
</Properties>
]],
	Smoke = [[
<Item class="Smoke" referent="RBX901A6FFC3444434C974978C1FF8D5C13">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<bool name="Enabled">true</bool>
<string name="Name">Smoke</string>
<float name="TimeScale">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004346</UniqueId>
<float name="Opacity_xml">0.5</float>
<float name="RiseVelocity_xml">1</float>
<float name="Size_xml">1</float>
</Properties>
]],
	Sparkles = [[
<Item class="Sparkles" referent="RBX78A23364ED4C4A21A22745FC93805C76">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<string name="Name">Sparkles</string>
<Color3 name="SparkleColor">
<R>0.564705908</R>
<G>0.0980392247</G>
<B>1</B>
</Color3>
<float name="TimeScale">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004347</UniqueId>
</Properties>
]],
	Trail = [[
<Item class="Trail" referent="RBXB45D0B882F884334BF41E2144FF84261">
<Properties>
<Ref name="Attachment0">null</Ref>
<Ref name="Attachment1">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Brightness">1</float>
<ColorSequence name="Color">0 1 1 1 0 1 1 1 1 0 </ColorSequence>
<bool name="Enabled">true</bool>
<bool name="FaceCamera">false</bool>
<float name="Lifetime">2</float>
<float name="LightEmission">0</float>
<float name="LightInfluence">1</float>
<float name="MaxLength">0</float>
<float name="MinLength">0.100000001</float>
<string name="Name">Trail</string>
<Content name="Texture"><null></null></Content>
<float name="TextureLength">1</float>
<token name="TextureMode">0</token>
<NumberSequence name="Transparency">0 0.5 0 1 0.5 0 </NumberSequence>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004348</UniqueId>
<NumberSequence name="WidthScale">0 1 0 1 1 0 </NumberSequence>
</Properties>
]],
	Atmosphere = [[
<Item class="Atmosphere" referent="RBXC40DF1EF78BC4940A55DAD292439200E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color">
<R>0.784300029</R>
<G>0.666700006</G>
<B>0.423500001</B>
</Color3>
<Color3 name="Decay">
<R>0.360799998</R>
<G>0.235300004</G>
<B>0.0549000017</B>
</Color3>
<float name="Density">0.395000011</float>
<float name="Glare">0</float>
<float name="Haze">0</float>
<string name="Name">Atmosphere</string>
<float name="Offset">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004349</UniqueId>
</Properties>
]],
	TremoloSoundEffect = [[
<Item class="TremoloSoundEffect" referent="RBX7AFAE38673AB479CB2E0649027060933">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Depth">1</float>
<float name="Duty">0.5</float>
<bool name="Enabled">true</bool>
<float name="Frequency">5</float>
<string name="Name">TremoloSoundEffect</string>
<int name="Priority">0</int>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004392</UniqueId>
</Properties>
]],
	Sky = [[
<Item class="Sky" referent="RBXCBF117D3919244BD93CAEA2C227C9690">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="CelestialBodiesShown">true</bool>
<float name="MoonAngularSize">11</float>
<Content name="MoonTextureId"><url>rbxasset://sky/moon.jpg</url></Content>
<string name="Name">Sky</string>
<Content name="SkyboxBk"><url>rbxasset://textures/sky/sky512_bk.tex</url></Content>
<Content name="SkyboxDn"><url>rbxasset://textures/sky/sky512_dn.tex</url></Content>
<Content name="SkyboxFt"><url>rbxasset://textures/sky/sky512_ft.tex</url></Content>
<Content name="SkyboxLf"><url>rbxasset://textures/sky/sky512_lf.tex</url></Content>
<Content name="SkyboxRt"><url>rbxasset://textures/sky/sky512_rt.tex</url></Content>
<Content name="SkyboxUp"><url>rbxasset://textures/sky/sky512_up.tex</url></Content>
<int name="StarCount">3000</int>
<float name="SunAngularSize">21</float>
<Content name="SunTextureId"><url>rbxasset://sky/sun.jpg</url></Content>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000434b</UniqueId>
</Properties>
]],
	BillboardGui = [[
<Item class="BillboardGui" referent="RBXCADC587303364D73BF4D698602C862C1">
<Properties>
<bool name="Active">true</bool>
<Ref name="Adornee">null</Ref>
<bool name="AlwaysOnTop">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<float name="Brightness">1</float>
<bool name="ClipsDescendants">false</bool>
<float name="DistanceLowerLimit">0</float>
<float name="DistanceStep">0</float>
<float name="DistanceUpperLimit">-1</float>
<bool name="Enabled">true</bool>
<Vector3 name="ExtentsOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="ExtentsOffsetWorldSpace">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="LightInfluence">1</float>
<float name="MaxDistance">INF</float>
<string name="Name">BillboardGui</string>
<Ref name="PlayerToHideFrom">null</Ref>
<bool name="ResetOnSpawn">true</bool>
<Ref name="RootLocalizationTable">null</Ref>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<UDim2 name="Size">
<XS>0</XS>
<XO>200</XO>
<YS>0</YS>
<YO>50</YO>
</UDim2>
<Vector2 name="SizeOffset">
<X>0</X>
<Y>0</Y>
</Vector2>
<Vector3 name="StudsOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="StudsOffsetWorldSpace">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000434c</UniqueId>
<token name="ZIndexBehavior">1</token>
</Properties>
]],
	CanvasGroup = [[
<Item class="CanvasGroup" referent="RBX21438D0187FA455B850ABAE0A255BC7A">
<Properties>
<bool name="Active">false</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">0</int>
<bool name="ClipsDescendants">true</bool>
<bool name="Draggable">false</bool>
<Color3 name="GroupColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="GroupTransparency">0</float>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<string name="Name">CanvasGroup</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<bool name="Selectable">false</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>100</XO>
<YS>0</YS>
<YO>100</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000434d</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	Frame = [[
<Item class="Frame" referent="RBX37A49DA9AC7F4C18A5203696D58BDF23">
<Properties>
<bool name="Active">false</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">1</int>
<bool name="ClipsDescendants">false</bool>
<bool name="Draggable">false</bool>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<string name="Name">Frame</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<bool name="Selectable">false</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>100</XO>
<YS>0</YS>
<YO>100</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<token name="Style">0</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000434e</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	ImageButton = [[
<Item class="ImageButton" referent="RBX4EFDE0E69FA64803B5FA2899A0E9F189">
<Properties>
<bool name="Active">true</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoButtonColor">true</bool>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">0</int>
<bool name="ClipsDescendants">false</bool>
<bool name="Draggable">false</bool>
<Content name="HoverImage"><null></null></Content>
<Content name="Image"><url>rbxasset://textures/ui/GuiImagePlaceholder.png</url></Content>
<Color3 name="ImageColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<Vector2 name="ImageRectOffset">
<X>0</X>
<Y>0</Y>
</Vector2>
<Vector2 name="ImageRectSize">
<X>0</X>
<Y>0</Y>
</Vector2>
<float name="ImageTransparency">0</float>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<bool name="Modal">false</bool>
<string name="Name">ImageButton</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<Content name="PressedImage"><null></null></Content>
<token name="ResampleMode">0</token>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<token name="ScaleType">0</token>
<bool name="Selectable">true</bool>
<bool name="Selected">false</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>100</XO>
<YS>0</YS>
<YO>100</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<Rect2D name="SliceCenter">
<Min>
<X>0</X>
<Y>0</Y>
</Min>
<Max>
<X>0</X>
<Y>0</Y>
</Max>
</Rect2D>
<float name="SliceScale">1</float>
<token name="Style">0</token>
<UDim2 name="TileSize">
<XS>1</XS>
<XO>0</XO>
<YS>1</YS>
<YO>0</YO>
</UDim2>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000434f</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	ImageLabel = [[
<Item class="ImageLabel" referent="RBX64AFF2B881214424BCCD02810F9FFB5B">
<Properties>
<bool name="Active">false</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">0</int>
<bool name="ClipsDescendants">false</bool>
<bool name="Draggable">false</bool>
<Content name="Image"><url>rbxasset://textures/ui/GuiImagePlaceholder.png</url></Content>
<Color3 name="ImageColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<Vector2 name="ImageRectOffset">
<X>0</X>
<Y>0</Y>
</Vector2>
<Vector2 name="ImageRectSize">
<X>0</X>
<Y>0</Y>
</Vector2>
<float name="ImageTransparency">0</float>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<string name="Name">ImageLabel</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<token name="ResampleMode">0</token>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<token name="ScaleType">0</token>
<bool name="Selectable">false</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>100</XO>
<YS>0</YS>
<YO>100</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<Rect2D name="SliceCenter">
<Min>
<X>0</X>
<Y>0</Y>
</Min>
<Max>
<X>0</X>
<Y>0</Y>
</Max>
</Rect2D>
<float name="SliceScale">1</float>
<UDim2 name="TileSize">
<XS>1</XS>
<XO>0</XO>
<YS>1</YS>
<YO>0</YO>
</UDim2>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004350</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	Path2D = [[
<Item class="Path2D" referent="RBXF38FF151FFD04A1BA2F7E85D9EB475E4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<string name="Name">Path2D</string>
<BinaryString name="PropertiesSerialize">AAAAAA==</BinaryString>
<float name="Thickness">1</float>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004351</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	ScreenGui = [[
<Item class="ScreenGui" referent="RBXE27CCAE4481D47BDA6CEE498D3777873">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<bool name="ClipToDeviceSafeArea">true</bool>
<int name="DisplayOrder">0</int>
<bool name="Enabled">true</bool>
<string name="Name">ScreenGui</string>
<bool name="ResetOnSpawn">true</bool>
<Ref name="RootLocalizationTable">null</Ref>
<token name="SafeAreaCompatibility">1</token>
<token name="ScreenInsets">2</token>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004352</UniqueId>
<token name="ZIndexBehavior">1</token>
</Properties>
]],
	ScrollingFrame = [[
<Item class="ScrollingFrame" referent="RBX93191385175440CEA96BA3C5FDC12710">
<Properties>
<bool name="Active">true</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticCanvasSize">0</token>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">0</int>
<Content name="BottomImage"><url>rbxasset://textures/ui/Scroll/scroll-bottom.png</url></Content>
<Vector2 name="CanvasPosition">
<X>0</X>
<Y>0</Y>
</Vector2>
<UDim2 name="CanvasSize">
<XS>0</XS>
<XO>0</XO>
<YS>2</YS>
<YO>0</YO>
</UDim2>
<bool name="ClipsDescendants">true</bool>
<bool name="Draggable">false</bool>
<token name="ElasticBehavior">0</token>
<token name="HorizontalScrollBarInset">0</token>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<Content name="MidImage"><url>rbxasset://textures/ui/Scroll/scroll-middle.png</url></Content>
<string name="Name">ScrollingFrame</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<Color3 name="ScrollBarImageColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<float name="ScrollBarImageTransparency">0</float>
<int name="ScrollBarThickness">12</int>
<token name="ScrollingDirection">4</token>
<bool name="ScrollingEnabled">true</bool>
<bool name="Selectable">true</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">true</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>100</XO>
<YS>0</YS>
<YO>100</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<Content name="TopImage"><url>rbxasset://textures/ui/Scroll/scroll-top.png</url></Content>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004353</UniqueId>
<token name="VerticalScrollBarInset">0</token>
<token name="VerticalScrollBarPosition">0</token>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	SurfaceGui = [[
<Item class="SurfaceGui" referent="RBX93FCAC2A3F4C4BEEB53BBC1A39F6B6B2">
<Properties>
<bool name="Active">true</bool>
<Ref name="Adornee">null</Ref>
<bool name="AlwaysOnTop">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<float name="Brightness">1</float>
<Vector2 name="CanvasSize">
<X>800</X>
<Y>600</Y>
</Vector2><bool name="ClipsDescendants">true</bool>
<bool name="Enabled">true</bool>
<token name="Face">5</token>
<float name="LightInfluence">1</float>
<float name="MaxDistance">1000</float>
<string name="Name">SurfaceGui</string>
<float name="PixelsPerStud">50</float>
<bool name="ResetOnSpawn">true</bool>
<Ref name="RootLocalizationTable">null</Ref>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<token name="SizingMode">0</token>
<float name="ToolPunchThroughDistance">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004354</UniqueId>
<token name="ZIndexBehavior">1</token>
<float name="ZOffset">0</float>
</Properties>
]],
	TextBox = [[
<Item class="TextBox" referent="RBXFD0886895F2940C6AE27B7658D7E5C99">
<Properties>
<bool name="Active">true</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">0</int>
<bool name="ClearTextOnFocus">true</bool>
<bool name="ClipsDescendants">false</bool>
<bool name="Draggable">false</bool>
<Font name="FontFace">
<Family><url>rbxasset://fonts/families/SourceSansPro.json</url></Family>
<Weight>400</Weight>
<Style>Normal</Style>
<CachedFaceId><url>rbxasset://fonts/SourceSansPro-Regular.ttf</url></CachedFaceId>
</Font>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<float name="LineHeight">1</float>
<string name="LocalizationMatchIdentifier"></string>
<string name="LocalizationMatchedSourceText"></string>
<int name="MaxVisibleGraphemes">-1</int>
<bool name="MultiLine">false</bool>
<string name="Name">TextBox</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<string name="OpenTypeFeatures"></string>
<Color3 name="PlaceholderColor3">
<R>0.699999988</R>
<G>0.699999988</G>
<B>0.699999988</B>
</Color3>
<string name="PlaceholderText"></string>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<bool name="RichText">false</bool>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<bool name="Selectable">true</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<bool name="ShowNativeInput">true</bool>
<UDim2 name="Size">
<XS>0</XS>
<XO>200</XO>
<YS>0</YS>
<YO>50</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<string name="Text">TextBox</string>
<Color3 name="TextColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="TextDirection">0</token>
<bool name="TextEditable">true</bool>
<bool name="TextScaled">false</bool>
<float name="TextSize">14</float>
<Color3 name="TextStrokeColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<float name="TextStrokeTransparency">1</float>
<float name="TextTransparency">0</float>
<token name="TextTruncate">0</token>
<bool name="TextWrapped">false</bool>
<token name="TextXAlignment">2</token>
<token name="TextYAlignment">1</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004355</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	TextButton = [[
<Item class="TextButton" referent="RBX095E995061AE4C3893EA1561FF300E38">
<Properties>
<bool name="Active">true</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoButtonColor">true</bool>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">0</int>
<bool name="ClipsDescendants">false</bool>
<bool name="Draggable">false</bool>
<Font name="FontFace">
<Family><url>rbxasset://fonts/families/SourceSansPro.json</url></Family>
<Weight>400</Weight>
<Style>Normal</Style>
<CachedFaceId><url>rbxasset://fonts/SourceSansPro-Regular.ttf</url></CachedFaceId>
</Font>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<float name="LineHeight">1</float>
<string name="LocalizationMatchIdentifier"></string>
<string name="LocalizationMatchedSourceText"></string>
<int name="MaxVisibleGraphemes">-1</int>
<bool name="Modal">false</bool>
<string name="Name">TextButton</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<string name="OpenTypeFeatures"></string>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<bool name="RichText">false</bool>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<bool name="Selectable">true</bool>
<bool name="Selected">false</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>200</XO>
<YS>0</YS>
<YO>50</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<token name="Style">0</token>
<string name="Text">Button</string>
<Color3 name="TextColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="TextDirection">0</token>
<bool name="TextScaled">false</bool>
<float name="TextSize">14</float>
<Color3 name="TextStrokeColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<float name="TextStrokeTransparency">1</float>
<float name="TextTransparency">0</float>
<token name="TextTruncate">0</token>
<bool name="TextWrapped">false</bool>
<token name="TextXAlignment">2</token>
<token name="TextYAlignment">1</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004356</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	TextLabel = [[
<Item class="TextLabel" referent="RBX4C7F91F85F8646589416810924F247A9">
<Properties>
<bool name="Active">false</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">0</int>
<bool name="ClipsDescendants">false</bool>
<bool name="Draggable">false</bool>
<Font name="FontFace">
<Family><url>rbxasset://fonts/families/SourceSansPro.json</url></Family>
<Weight>400</Weight>
<Style>Normal</Style>
<CachedFaceId><url>rbxasset://fonts/SourceSansPro-Regular.ttf</url></CachedFaceId>
</Font>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<float name="LineHeight">1</float>
<string name="LocalizationMatchIdentifier"></string>
<string name="LocalizationMatchedSourceText"></string>
<int name="MaxVisibleGraphemes">-1</int>
<string name="Name">TextLabel</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<string name="OpenTypeFeatures"></string>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<bool name="RichText">false</bool>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<bool name="Selectable">false</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>200</XO>
<YS>0</YS>
<YO>50</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<string name="Text">Label</string>
<Color3 name="TextColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="TextDirection">0</token>
<bool name="TextScaled">false</bool>
<float name="TextSize">14</float>
<Color3 name="TextStrokeColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<float name="TextStrokeTransparency">1</float>
<float name="TextTransparency">0</float>
<token name="TextTruncate">0</token>
<bool name="TextWrapped">false</bool>
<token name="TextXAlignment">2</token>
<token name="TextYAlignment">1</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004357</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	UIAspectRatioConstraint = [[
<Item class="UIAspectRatioConstraint" referent="RBX3172554D6F7B445FA7282F3308EA54A7">
<Properties>
<float name="AspectRatio">1</float>
<token name="AspectType">0</token>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="DominantAxis">0</token>
<string name="Name">UIAspectRatioConstraint</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004358</UniqueId>
</Properties>
]],
	UICorner = [[
<Item class="UICorner" referent="RBXA454182CC089458EBD944091F9AAAFE2">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<UDim name="CornerRadius">
<S>0</S>
<O>8</O>
</UDim>
<string name="Name">UICorner</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004359</UniqueId>
</Properties>
]],
	UIGradient = [[
<Item class="UIGradient" referent="RBX9E4FBCE3FE044C0A938C1F11910BAC51">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<ColorSequence name="Color">0 1 1 1 0 1 1 1 1 0 </ColorSequence>
<bool name="Enabled">true</bool>
<string name="Name">UIGradient</string>
<Vector2 name="Offset">
<X>0</X>
<Y>0</Y>
</Vector2>
<float name="Rotation">0</float>
<NumberSequence name="Transparency">0 0 0 1 0 0 </NumberSequence>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000435a</UniqueId>
</Properties>
]],
	UIGridLayout = [[
<Item class="UIGridLayout" referent="RBXE68BE4322409461FA6F9531A30FEB4CD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<UDim2 name="CellPadding">
<XS>0</XS>
<XO>5</XO>
<YS>0</YS>
<YO>5</YO>
</UDim2>
<UDim2 name="CellSize">
<XS>0</XS>
<XO>100</XO>
<YS>0</YS>
<YO>100</YO>
</UDim2>
<token name="FillDirection">0</token>
<int name="FillDirectionMaxCells">0</int>
<token name="HorizontalAlignment">1</token>
<string name="Name">UIGridLayout</string>
<token name="SortOrder">0</token>
<token name="StartCorner">0</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000435b</UniqueId>
<token name="VerticalAlignment">1</token>
</Properties>
]],
	UIListLayout = [[
<Item class="UIListLayout" referent="RBX221B710E5C4444CC8C3FDE968619F4E7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="FillDirection">1</token>
<token name="HorizontalAlignment">1</token>
<token name="HorizontalFlex">0</token>
<token name="ItemLineAlignment">0</token>
<string name="Name">UIListLayout</string>
<UDim name="Padding">
<S>0</S>
<O>0</O>
</UDim>
<token name="SortOrder">0</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000435c</UniqueId>
<token name="VerticalAlignment">1</token>
<token name="VerticalFlex">0</token>
<bool name="Wraps">false</bool>
</Properties>
]],
	UIPadding = [[
<Item class="UIPadding" referent="RBXA5539545AE7740AB8569781E7793D601">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">UIPadding</string>
<UDim name="PaddingBottom">
<S>0</S>
<O>0</O>
</UDim>
<UDim name="PaddingLeft">
<S>0</S>
<O>0</O>
</UDim>
<UDim name="PaddingRight">
<S>0</S>
<O>0</O>
</UDim>
<UDim name="PaddingTop">
<S>0</S>
<O>0</O>
</UDim>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000435d</UniqueId>
</Properties>
]],
	UIPageLayout = [[
<Item class="UIPageLayout" referent="RBX095EF11595BD48BD9C58350488B05533">
<Properties>
<bool name="Animated">true</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Circular">false</bool>
<token name="EasingDirection">1</token>
<token name="EasingStyle">2</token>
<token name="FillDirection">0</token>
<bool name="GamepadInputEnabled">true</bool>
<token name="HorizontalAlignment">1</token>
<string name="Name">UIPageLayout</string>
<UDim name="Padding">
<S>0</S>
<O>0</O>
</UDim>
<bool name="ScrollWheelInputEnabled">true</bool>
<token name="SortOrder">0</token>
<bool name="TouchInputEnabled">true</bool>
<float name="TweenTime">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000435e</UniqueId>
<token name="VerticalAlignment">1</token>
</Properties>
]],
	UIScale = [[
<Item class="UIScale" referent="RBX1187F11C18F441E8AF2196F974E4C37B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">UIScale</string>
<float name="Scale">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000435f</UniqueId>
</Properties>
]],
	UISizeConstraint = [[
<Item class="UISizeConstraint" referent="RBX17141D781CB6460AA9FCD35AE4221155">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Vector2 name="MaxSize">
<X>INF</X>
<Y>INF</Y>
</Vector2>
<Vector2 name="MinSize">
<X>0</X>
<Y>0</Y>
</Vector2>
<string name="Name">UISizeConstraint</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004360</UniqueId>
</Properties>
]],
	UITextSizeConstraint = [[
<Item class="UITextSizeConstraint" referent="RBX9BF62C9A311245C88DF05572D74D63F6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="MaxTextSize">100</int>
<int name="MinTextSize">1</int>
<string name="Name">UITextSizeConstraint</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004364</UniqueId>
</Properties>
]],
	UIStroke = [[
<Item class="UIStroke" referent="RBX3EEB56FD981A469FA0C1BAC0479F45EA">
<Properties>
<token name="ApplyStrokeMode">0</token>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<bool name="Enabled">true</bool>
<token name="LineJoinMode">0</token>
<string name="Name">UIStroke</string>
<float name="Thickness">1</float>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004362</UniqueId>
</Properties>
]],
	UITableLayout = [[
<Item class="UITableLayout" referent="RBXBF31D88873084C5F8159723BFCFEA52C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="FillDirection">1</token>
<bool name="FillEmptySpaceColumns">false</bool>
<bool name="FillEmptySpaceRows">false</bool>
<token name="HorizontalAlignment">1</token>
<token name="MajorAxis">0</token>
<string name="Name">UITableLayout</string>
<UDim2 name="Padding">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<token name="SortOrder">0</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004363</UniqueId>
<token name="VerticalAlignment">1</token>
</Properties>
]],
	VideoFrame = [[
<Item class="VideoFrame" referent="RBXE6CB4780133A4D138FECA5275D399F68">
<Properties>
<bool name="Active">false</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">0</int>
<bool name="ClipsDescendants">false</bool>
<bool name="Draggable">false</bool>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<bool name="Looped">false</bool>
<string name="Name">VideoFrame</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<bool name="Playing">false</bool>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<bool name="Selectable">false</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>100</XO>
<YS>0</YS>
<YO>100</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<double name="TimePosition">0</double>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004365</UniqueId>
<Content name="Video"><null></null></Content>
<bool name="Visible">true</bool>
<float name="Volume">1</float>
<int name="ZIndex">1</int>
</Properties>
]],
	ViewportFrame = [[
<Item class="ViewportFrame" referent="RBX44B6300A5A2749D29ACBC988FF6BFD74">
<Properties>
<bool name="Active">false</bool>
<Color3 name="Ambient">
<R>0.784313738</R>
<G>0.784313738</G>
<B>0.784313738</B>
</Color3>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">0</int>
<CoordinateFrame name="CameraCFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="CameraFieldOfView">1.22173059</float>
<bool name="ClipsDescendants">false</bool>
<bool name="Draggable">false</bool>
<Color3 name="ImageColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="ImageTransparency">0</float>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<Color3 name="LightColor">
<R>0.549019635</R>
<G>0.549019635</G>
<B>0.549019635</B>
</Color3>
<Vector3 name="LightDirection">
<X>-1</X>
<Y>-1</Y>
<Z>-1</Z>
</Vector3>
<string name="Name">ViewportFrame</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<bool name="Selectable">false</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>100</XO>
<YS>0</YS>
<YO>100</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004367</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
]],
	Seat = [[
<Item class="Seat" referent="RBXAFBBE7EE2D5B4D09B6BB5158EE13E5CA">
<Properties>
<bool name="Anchored">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BackSurface">0</token>
<token name="BottomSurface">0</token>
<CoordinateFrame name="CFrame">
<X>2.30999994</X>
<Y>0.500003994</Y>
<Z>8.52000046</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4279970357</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="Disabled">false</bool>
<bool name="EnableFluidForces">true</bool>
<token name="FrontSurface">0</token>
<token name="LeftSurface">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<string name="Name">Seat</string>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RightSurface">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="TopSurface">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004368</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="FormFactorRaw">1</token>
<token name="Shape">1</token>
<Vector3 name="Size">
<X>4</X>
<Y>1</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	Teams = [[
<Item class="Teams" referent="RBXE69C48FD499E493FB202410F7233624C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Teams</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000364</UniqueId>
</Properties>
]],
	Team = [[
<Item class="Team" referent="RBXF15FC8BFD8C643D8955B868133906F1B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoAssignable">true</bool>
<string name="Name">Team</string>
<int name="TeamColor">1</int>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004369</UniqueId>
</Properties>
]],
	VehicleSeat = [[
<Item class="VehicleSeat" referent="RBX6200E90C3F204F2A8D6EFC1695B856DC">
<Properties>
<bool name="Anchored">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BackSurface">0</token>
<token name="BottomSurface">0</token>
<CoordinateFrame name="CFrame">
<X>2.30999994</X>
<Y>1.50003505</Y>
<Z>8.52000046</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4279970357</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="Disabled">false</bool>
<bool name="EnableFluidForces">true</bool>
<token name="FrontSurface">0</token>
<bool name="HeadsUpDisplay">true</bool>
<token name="LeftSurface">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<float name="MaxSpeed">25</float>
<string name="Name">VehicleSeat</string>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RightSurface">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<int name="Steer">0</int>
<float name="SteerFloat">0</float>
<int name="Throttle">0</int>
<float name="ThrottleFloat">0</float>
<token name="TopSurface">0</token>
<float name="Torque">10</float>
<float name="Transparency">0</float>
<float name="TurnSpeed">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000436a</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="Size">
<X>4</X>
<Y>1</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	PointLight = [[
<Item class="PointLight" referent="RBX28148CD29C3343F2803BDBB640C30F01">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Brightness">1</float>
<Color3 name="Color">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<bool name="Enabled">true</bool>
<string name="Name">PointLight</string>
<float name="Range">8</float>
<bool name="Shadows">false</bool>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000436b</UniqueId>
</Properties>
]],
	SpotLight = [[
<Item class="SpotLight" referent="RBX4E1C5CCDEE85432FACEDD59E08C9F27B">
<Properties>
<float name="Angle">90</float>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Brightness">1</float>
<Color3 name="Color">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<bool name="Enabled">true</bool>
<token name="Face">5</token>
<string name="Name">SpotLight</string>
<float name="Range">16</float>
<bool name="Shadows">false</bool>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000436c</UniqueId>
</Properties>
]],
	SurfaceLight = [[
<Item class="SurfaceLight" referent="RBX6923EBDA428C43EC8AB1F9606F3126AB">
<Properties>
<float name="Angle">90</float>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Brightness">1</float>
<Color3 name="Color">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<bool name="Enabled">true</bool>
<token name="Face">5</token>
<string name="Name">SurfaceLight</string>
<float name="Range">16</float>
<bool name="Shadows">false</bool>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000436d</UniqueId>
</Properties>
]],
	BlockMesh = [[
<Item class="BlockMesh" referent="RBX81B24E47618044529ECF3236B157EC73">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Bevel">0</float>
<float name="Bevel Roundness">0</float>
<float name="Bulge">0</float>
<string name="Name">Mesh</string>
<Vector3 name="Offset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="Scale">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000436e</UniqueId>
<Vector3 name="VertexColor">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
</Properties>
]],
	CharacterMesh = [[
<Item class="CharacterMesh" referent="RBXB0CD841B1B6F41C3A3CFD8544048F984">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<int64 name="BaseTextureId">0</int64>
<token name="BodyPart">0</token>
<int64 name="MeshId">0</int64>
<string name="Name">CharacterMesh</string>
<int64 name="OverlayTextureId">0</int64>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000436f</UniqueId>
</Properties>
]],
	SpecialMesh = [[
<Item class="SpecialMesh" referent="RBX6F50FFBAEE15417BA7F7424A59370A17">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Content name="MeshId"><null></null></Content>
<token name="MeshType">0</token>
<string name="Name">Mesh</string>
<Vector3 name="Offset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="Scale">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
<Content name="TextureId"><null></null></Content>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004370</UniqueId>
<Vector3 name="VertexColor">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
</Properties>
]],
	CornerWedgePart = [[
<Item class="CornerWedgePart" referent="RBX1F17469E37F645CFBA6590CFE0C0C8AF">
<Properties>
<bool name="Anchored">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BackSurface">0</token>
<token name="BottomSurface">0</token>
<CoordinateFrame name="CFrame">
<X>2.30999994</X>
<Y>3.00003505</Y>
<Z>8.52000046</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4288914085</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="EnableFluidForces">true</bool>
<token name="FrontSurface">0</token>
<token name="LeftSurface">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<string name="Name">CornerWedge</string>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RightSurface">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="TopSurface">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004371</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="Size">
<X>2</X>
<Y>2</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	MeshPart = [[
<Item class="MeshPart" referent="RBX916D75F6283C48F1A91BE359F6384213">
<Properties>
<SharedString name="AeroMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<bool name="Anchored">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BackSurface">0</token>
<token name="BottomSurface">0</token>
<CoordinateFrame name="CFrame">
<X>2.30999994</X>
<Y>4.50005198</Y>
<Z>8.52000046</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4288914085</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="DoubleSided">false</bool>
<bool name="EnableFluidForces">true</bool>
<token name="FluidFidelityInternal">0</token>
<token name="FrontSurface">0</token>
<bool name="HasJointOffset">false</bool>
<bool name="HasSkinnedMesh">false</bool>
<Vector3 name="InitialSize">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="JointOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="LeftSurface">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<Content name="MeshId"><null></null></Content>
<string name="Name">MeshPart</string>
<SharedString name="PhysicalConfigData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<BinaryString name="PhysicsData"></BinaryString>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RenderFidelity">1</token>
<token name="RightSurface">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Content name="TextureID"><null></null></Content>
<token name="TopSurface">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004372</UniqueId>
<Vector3 name="UnscaledCofm">
<X>NAN</X>
<Y>NAN</Y>
<Z>NAN</Z>
</Vector3>
<Vector3 name="UnscaledVolInertiaDiags">
<X>NAN</X>
<Y>NAN</Y>
<Z>NAN</Z>
</Vector3>
<Vector3 name="UnscaledVolInertiaOffDiags">
<X>NAN</X>
<Y>NAN</Y>
<Z>NAN</Z>
</Vector3>
<float name="UnscaledVolume">NAN</float>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<int name="VertexCount">0</int>
<Vector3 name="Size">
<X>4</X>
<Y>1</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	Part = [[
<Item class="Part" referent="RBXE9259AA838724A88B333A9E9499FD668">
<Properties>
<bool name="Anchored">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BackSurface">0</token>
<token name="BottomSurface">0</token>
<CoordinateFrame name="CFrame">
<X>2.30999994</X>
<Y>5.50006294</Y>
<Z>8.52000046</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4288914085</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="EnableFluidForces">true</bool>
<token name="FrontSurface">0</token>
<token name="LeftSurface">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<string name="Name">Part</string>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RightSurface">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="TopSurface">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004373</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="FormFactorRaw">1</token>
<token name="Shape">1</token>
<Vector3 name="Size">
<X>4</X>
<Y>1</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	TrussPart = [[
<Item class="TrussPart" referent="RBX76E9948A5F1D4A278ECCEC9A894642F4">
<Properties>
<bool name="Anchored">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BackSurface">0</token>
<token name="BottomSurface">0</token>
<CoordinateFrame name="CFrame">
<X>2.30999994</X>
<Y>7.00007915</Y>
<Z>8.52000046</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4288914085</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="EnableFluidForces">true</bool>
<token name="FrontSurface">0</token>
<token name="LeftSurface">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<string name="Name">Truss</string>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RightSurface">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="TopSurface">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004374</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="Size">
<X>2</X>
<Y>2</Y>
<Z>2</Z>
</Vector3>
<token name="Style">0</token>
</Properties>
]],
	WedgePart = [[
<Item class="WedgePart" referent="RBXC2E6F17E9E4A428AB29562B734BE66B9">
<Properties>
<bool name="Anchored">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BackSurface">0</token>
<token name="BottomSurface">0</token>
<CoordinateFrame name="CFrame">
<X>2.30999994</X>
<Y>8.99999428</Y>
<Z>8.52000046</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4288914085</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="EnableFluidForces">true</bool>
<token name="FrontSurface">0</token>
<token name="LeftSurface">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<string name="Name">Wedge</string>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RightSurface">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="TopSurface">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004375</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="FormFactorRaw">1</token>
<Vector3 name="Size">
<X>1</X>
<Y>2</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	BloomEffect = [[
<Item class="BloomEffect" referent="RBXF714904A626140D5BCF8BACE751D55C7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<float name="Intensity">1</float>
<string name="Name">Bloom</string>
<float name="Size">24</float>
<float name="Threshold">2</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004376</UniqueId>
</Properties>
]],
	BlurEffect = [[
<Item class="BlurEffect" referent="RBX311D0E96734F48A88CA4E1D771789624">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<string name="Name">Blur</string>
<float name="Size">24</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004377</UniqueId>
</Properties>
]],
	ColorCorrectionEffect = [[
<Item class="ColorCorrectionEffect" referent="RBX89B9CA73AAB84263B28F985C41B2CF80">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Brightness">0</float>
<float name="Contrast">0</float>
<bool name="Enabled">true</bool>
<string name="Name">ColorCorrection</string>
<float name="Saturation">0</float>
<Color3 name="TintColor">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<token name="TonemapperPreset">0</token>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000437c</UniqueId>
</Properties>
]],
	DepthOfFieldEffect = [[
<Item class="DepthOfFieldEffect" referent="RBX0AEF05E67ABD4AFBBB8A8D4DEECEEB36">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<float name="FarIntensity">0.75</float>
<float name="FocusDistance">0.0500000007</float>
<float name="InFocusRadius">10</float>
<string name="Name">DepthOfField</string>
<float name="NearIntensity">0.75</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000437a</UniqueId>
</Properties>
]],
	SunRaysEffect = [[
<Item class="SunRaysEffect" referent="RBX58ED30CA989346CA81D33320F54EA705">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<float name="Intensity">0.25</float>
<string name="Name">SunRays</string>
<float name="Spread">1</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000437b</UniqueId>
</Properties>
]],
	ColorGradingEffect = [[
<Item class="ColorGradingEffect" referent="RBX0F86BEFA650A4885AB9D185CF3F2B92F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<string name="Name">ColorGrading</string>
<token name="TonemapperPreset">1</token>
<UniqueId name="UniqueId">223bb66dd408f5db070f1f9900004f92</UniqueId>
</Properties>
]],
	BindableFunction = [[
<Item class="BindableFunction" referent="RBXEDA6B8FF3E5D4116BCCA27920A22FEFA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Function</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000437e</UniqueId>
</Properties>
]],
	LocalScript = [=[
<Item class="LocalScript" referent="RBXCE0869D075DF4A55B4541E5C29AE4BA1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Disabled">false</bool>
<Content name="LinkedSource"><null></null></Content>
<string name="Name">LocalScript</string>
<token name="RunContext">0</token>
<string name="ScriptGuid">{A7A2C6D1-8936-4D8F-A45D-9A2AE9525164}</string>
<ProtectedString name="Source"><![CDATA[print("Hello world!")
]]></ProtectedString>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000437f</UniqueId>
</Properties>
]=],
	RemoteEvent = [[
<Item class="RemoteEvent" referent="RBXB5FE5349195A442795504182CF3A4DB5">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">RemoteEvent</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004382</UniqueId>
</Properties>
]],
	ModuleScript = [=[
<Item class="ModuleScript" referent="RBX6A5AB5395EC24443840DD8F9AEC34F7E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Content name="LinkedSource"><null></null></Content>
<string name="Name">ModuleScript</string>
<string name="ScriptGuid">{26CAB37F-80B5-4B07-BE72-6C2F597CDDB4}</string>
<ProtectedString name="Source"><![CDATA[local module = {}

return module
]]></ProtectedString>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004383</UniqueId>
</Properties>
]=],
	RemoteFunction = [[
<Item class="RemoteFunction" referent="RBXCD126F62C4E84C2F97D1F047CE7F69D6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">RemoteFunction</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004386</UniqueId>
</Properties>
]],
	UnreliableRemoteEvent = [[
<Item class="UnreliableRemoteEvent" referent="RBXA27C9C08C5B943CBA664E8DD2F2CB28E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">UnreliableRemoteEvent</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004387</UniqueId>
</Properties>
]],
	ChorusSoundEffect = [[
<Item class="ChorusSoundEffect" referent="RBX34529416D90D4DEFA190D7F748FCC210">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Depth">0.150000006</float>
<bool name="Enabled">true</bool>
<float name="Mix">0.5</float>
<string name="Name">ChorusSoundEffect</string>
<int name="Priority">0</int>
<float name="Rate">0.5</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004388</UniqueId>
</Properties>
]],
	CompressorSoundEffect = [[
<Item class="CompressorSoundEffect" referent="RBX1D6DB7D87A924856AADB79BA89FA0A14">
<Properties>
<float name="Attack">0.100000001</float>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<float name="GainMakeup">0</float>
<string name="Name">CompressorSoundEffect</string>
<int name="Priority">0</int>
<float name="Ratio">40</float>
<float name="Release">0.100000001</float>
<Ref name="SideChain">null</Ref>
<float name="Threshold">-40</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004389</UniqueId>
</Properties>
]],
	DistortionSoundEffect = [[
<Item class="DistortionSoundEffect" referent="RBX36ACF943C9BD438F89E899028CC370EA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<float name="Level">0.75</float>
<string name="Name">DistortionSoundEffect</string>
<int name="Priority">0</int>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000438a</UniqueId>
</Properties>
]],
	EchoSoundEffect = [[
<Item class="EchoSoundEffect" referent="RBXDB8D8319C81A4863A4B33F3AEB5F9DB3">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Delay">1</float>
<float name="DryLevel">0</float>
<bool name="Enabled">true</bool>
<float name="Feedback">0.5</float>
<string name="Name">EchoSoundEffect</string>
<int name="Priority">0</int>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000438b</UniqueId>
<float name="WetLevel">0</float>
</Properties>
]],
	EqualizerSoundEffect = [[
<Item class="EqualizerSoundEffect" referent="RBX2B6E6E1366734061B476077DF361E5FC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<float name="HighGain">0</float>
<float name="LowGain">-20</float>
<float name="MidGain">-10</float>
<string name="Name">EqualizerSoundEffect</string>
<int name="Priority">0</int>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000438c</UniqueId>
</Properties>
]],
	FlangeSoundEffect = [[
<Item class="FlangeSoundEffect" referent="RBXC211476E6FCD4A99BCDCB80C0F21792E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Depth">0.449999988</float>
<bool name="Enabled">true</bool>
<float name="Mix">0.850000024</float>
<string name="Name">FlangeSoundEffect</string>
<int name="Priority">0</int>
<float name="Rate">5</float>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000438d</UniqueId>
</Properties>
]],
	PitchShiftSoundEffect = [[
<Item class="PitchShiftSoundEffect" referent="RBX1D6BC3A935A94A9287EDEF30BECFF482">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<string name="Name">PitchShiftSoundEffect</string>
<float name="Octave">1.25</float>
<int name="Priority">0</int>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000438e</UniqueId>
</Properties>
]],
	ReverbSoundEffect = [[
<Item class="ReverbSoundEffect" referent="RBX0A52D201917543C19D81E57BD856CA2E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="DecayTime">1.5</float>
<float name="Density">1</float>
<float name="Diffusion">1</float>
<float name="DryLevel">-6</float>
<bool name="Enabled">true</bool>
<string name="Name">ReverbSoundEffect</string>
<int name="Priority">0</int>
<UniqueId name="UniqueId">7bdf20b295fbe64d068944540000438f</UniqueId>
<float name="WetLevel">0</float>
</Properties>
]],
	Sound = [[
<Item class="Sound" referent="RBX3C6C037DD4274AFB801BDD969ACB5903">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="EmitterSize">10</float>
<NumberRange name="LoopRegion">0 60000 </NumberRange>
<bool name="Looped">false</bool>
<string name="Name">Sound</string>
<bool name="PlayOnRemove">false</bool>
<NumberRange name="PlaybackRegion">0 60000 </NumberRange>
<bool name="PlaybackRegionsEnabled">false</bool>
<float name="PlaybackSpeed">1</float>
<bool name="Playing">false</bool>
<token name="RollOffMode">3</token>
<Ref name="SoundGroup">null</Ref>
<Content name="SoundId"><null></null></Content>
<double name="TimePosition">0</double>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004390</UniqueId>
<float name="Volume">0.5</float>
<float name="xmlRead_MaxDistance_3">10000</float>
</Properties>
]],
	SoundGroup = [[
<Item class="SoundGroup" referent="RBX68F3990CED0E4D83A4AE9F66E1093A43">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">SoundGroup</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004391</UniqueId>
<float name="Volume">0.5</float>
</Properties>
]],
	TextChannel = [[
<Item class="TextChannel" referent="RBX0751E3A359894A5EB2D8B436D84BF95A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">TextChannel</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042a9</UniqueId>
</Properties>
]],
	TextChatCommand = [[
<Item class="TextChatCommand" referent="RBX9ECCE7363B864A269B5F61D67D42269A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutocompleteVisible">true</bool>
<bool name="Enabled">true</bool>
<string name="Name">TextChatCommand</string>
<string name="PrimaryAlias"></string>
<string name="SecondaryAlias"></string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042aa</UniqueId>
</Properties>
]],
	Configuration = [[
<Item class="Configuration" referent="RBX6BCF58C1018C48B7A06245F25EEF85A8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Configuration</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042ac</UniqueId>
</Properties>
]],
	HumanoidDescription = [[
<Item class="HumanoidDescription" referent="RBX0BD5C32064B84D9193656FA3BEF0D5B4">
<Properties>
<string name="AccessoryBlob">[]</string>
<string name="AccessoryRigidAndLayeredBlob">[]</string>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="BackAccessory"></string>
<float name="BodyTypeScale">0.300000012</float>
<int64 name="ClimbAnimation">0</int64>
<float name="DepthScale">1</float>
<string name="EmotesDataInternal"></string>
<string name="EquippedEmotesDataInternal"></string>
<int64 name="Face">0</int64>
<string name="FaceAccessory"></string>
<int64 name="FallAnimation">0</int64>
<string name="FrontAccessory"></string>
<int64 name="GraphicTShirt">0</int64>
<string name="HairAccessory"></string>
<string name="HatAccessory"></string>
<int64 name="Head">0</int64>
<Color3 name="HeadColor">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<float name="HeadScale">1</float>
<float name="HeightScale">1</float>
<int64 name="IdleAnimation">0</int64>
<int64 name="JumpAnimation">0</int64>
<int64 name="LeftArm">0</int64>
<Color3 name="LeftArmColor">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<int64 name="LeftLeg">0</int64>
<Color3 name="LeftLegColor">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<int64 name="MoodAnimation">0</int64>
<string name="Name">HumanoidDescription</string>
<string name="NeckAccessory"></string>
<int64 name="Pants">0</int64>
<float name="ProportionScale">1</float>
<int64 name="RightArm">0</int64>
<Color3 name="RightArmColor">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<int64 name="RightLeg">0</int64>
<Color3 name="RightLegColor">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<int64 name="RunAnimation">0</int64>
<int64 name="Shirt">0</int64>
<string name="ShouldersAccessory"></string>
<int64 name="SwimAnimation">0</int64>
<int64 name="Torso">0</int64>
<Color3 name="TorsoColor">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042ad</UniqueId>
<string name="WaistAccessory"></string>
<int64 name="WalkAnimation">0</int64>
<float name="WidthScale">1</float>
</Properties>
]],
	Weld = [[
<Item class="Weld" referent="RBXFD79D059B8714EAEB7BF2D01511FC628">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="Enabled">true</bool>
<string name="Name">Weld</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042ae</UniqueId>
</Properties>
]],
	BoolValue = [[
<Item class="BoolValue" referent="RBX797C2F07DEA640DFB9B7E6CC047F5F3A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042af</UniqueId>
<bool name="Value">false</bool>
</Properties>
]],
	BrickColorValue = [[
<Item class="BrickColorValue" referent="RBXF4C65ECF3E3C41C0A2FBAD6652978DDF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b0</UniqueId>
<int name="Value">194</int>
</Properties>
]],
	CFrameValue = [[
<Item class="CFrameValue" referent="RBXECCEB613D24C4638AC530BC8996E823C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b1</UniqueId>
<CoordinateFrame name="Value">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
</Properties>
]],
	Color3Value = [[
<Item class="Color3Value" referent="RBXA7038C1DD8B74A9C9314827A1F672BB9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b2</UniqueId>
<Color3 name="Value">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
</Properties>
]],
	IntValue = [[
<Item class="IntValue" referent="RBXFD8151C232E2421B8184441ACACA8078">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b3</UniqueId>
<int64 name="Value">0</int64>
</Properties>
]],
	NumberValue = [[
<Item class="NumberValue" referent="RBX4E55669A32EC48DBB4A1A88F9A6E66BC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b4</UniqueId>
<double name="Value">0</double>
</Properties>
]],
	ObjectValue = [[
<Item class="ObjectValue" referent="RBX9A08BC4E128C4FCE9F0EB46F208BA1E9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b5</UniqueId>
<Ref name="Value">null</Ref>
</Properties>
]],
	RayValue = [[
<Item class="RayValue" referent="RBX2D22574FA9C54BF3BCE074466AAACD33">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b6</UniqueId>
<Ray name="Value">
<origin>
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</origin>
<direction>
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</direction>
</Ray>
</Properties>
]],
	StringValue = [[
<Item class="StringValue" referent="RBX7945CF6F30E24205807BB120DA30F26E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b7</UniqueId>
<string name="Value"></string>
</Properties>
]],
	Vector3Value = [[
<Item class="Vector3Value" referent="RBX96C84B8B73344CB89B8434C42EC159C5">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Value</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b8</UniqueId>
<Vector3 name="Value">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
</Properties>
]],
	WorldModel = [[
<Item class="WorldModel" referent="RBX403B9505ED794D538016C87FF57614C7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="LevelOfDetail">0</token>
<CoordinateFrame name="ModelMeshCFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<SharedString name="ModelMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<Vector3 name="ModelMeshSize">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="ModelStreamingMode">0</token>
<string name="Name">WorldModel</string>
<bool name="NeedsPivotMigration">false</bool>
<Ref name="PrimaryPart">null</Ref>
<float name="ScaleFactor">1</float>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042b9</UniqueId>
<OptionalCoordinateFrame name="WorldPivotData"></OptionalCoordinateFrame>
</Properties>
]],
	BodyVelocity = [[
<Item class="BodyVelocity" referent="RBXA00A73D8B8DD408BA0358577D6768717">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Vector3 name="MaxForce">
<X>4000</X>
<Y>4000</Y>
<Z>4000</Z>
</Vector3>
<string name="Name">BodyVelocity</string>
<float name="P">1250</float>
<UniqueId name="UniqueId">5d1c0f3483200f1d0697d82500004376</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>2</Y>
<Z>0</Z>
</Vector3>
</Properties>
]],
	CylinderMesh = [[
<Item class="CylinderMesh" referent="RBX60447495CF25489DA5981127911DD6AC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Bevel">0</float>
<float name="Bevel Roundness">0</float>
<float name="Bulge">0</float>
<string name="Name">Mesh</string>
<Vector3 name="Offset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="Scale">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
<UniqueId name="UniqueId">61b1cee312c5eed706b63230000046dd</UniqueId>
<Vector3 name="VertexColor">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
</Properties>
]],
	WrapDeformer = [[
<Item class="WrapDeformer" referent="RBX13407D32FCF7498FA109ACF84DD10C7B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Content name="CageMeshId"><null></null></Content>
<CoordinateFrame name="CageOrigin">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Content name="HSRAssetId"><null></null></Content>
<SharedString name="HSRData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<SharedString name="HSRMeshIdData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<CoordinateFrame name="ImportOrigin">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<string name="Name">WrapDeformer</string>
<Content name="TemporaryCageMeshId"><null></null></Content>
<UniqueId name="UniqueId">1857f279b32c2fee0776cdfd000052d4</UniqueId>
</Properties>
]],
	WrapLayer = [[
<Item class="WrapLayer" referent="RBXA5ADDDA6399C4109863EEC4D850AB3D0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="AutoSkin">0</token>
<CoordinateFrame name="BindOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Content name="CageMeshId"><null></null></Content>
<CoordinateFrame name="CageOrigin">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="Enabled">true</bool>
<Content name="HSRAssetId"><null></null></Content>
<SharedString name="HSRData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<SharedString name="HSRMeshIdData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<CoordinateFrame name="ImportOrigin">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<string name="Name">WrapLayer</string>
<int name="Order">1</int>
<float name="Puffiness">1</float>
<Content name="ReferenceMeshId"><null></null></Content>
<CoordinateFrame name="ReferenceOrigin">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="ShrinkFactor">0</float>
<Content name="TemporaryCageMeshId"><null></null></Content>
<Content name="TemporaryReferenceId"><null></null></Content>
<UniqueId name="UniqueId">1857f279b32c2fee0776cdfd000052d5</UniqueId>
</Properties>
]],
	WrapTarget = [[
<Item class="WrapTarget" referent="RBXE7C76507BD5A43DCB0BE8E69BF9EF484">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Content name="CageMeshId"><null></null></Content>
<CoordinateFrame name="CageOrigin">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Content name="HSRAssetId"><null></null></Content>
<SharedString name="HSRData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<SharedString name="HSRMeshIdData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<CoordinateFrame name="ImportOrigin">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<string name="Name">WrapTarget</string>
<float name="Stiffness">0</float>
<Content name="TemporaryCageMeshId"><null></null></Content>
<UniqueId name="UniqueId">1857f279b32c2fee0776cdfd000052d6</UniqueId>
</Properties>
]],
	BodyPartDescription = [[
<Item class="BodyPartDescription" referent="RBX7F99803BE12947768D06B2300CEA8601">
<Properties>
<int64 name="AssetId">0</int64>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BodyPart">0</token>
<Color3 name="Color">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<UniqueId name="HistoryId">00000000000000000000000000000000</UniqueId>
<Ref name="Instance">null</Ref>
<string name="Name">BodyPartDescription</string>
<UniqueId name="UniqueId">1857f279b32c2fee0776cdfd000052d7</UniqueId>
</Properties>
]],
	AccessoryDescription = [[
<Item class="AccessoryDescription" referent="RBX80911BFDF43F40349403B558FF5A674B">
<Properties>
<token name="AccessoryType">0</token>
<int64 name="AssetId">0</int64>
<BinaryString name="AttributesSerialize"></BinaryString>
<Ref name="Instance">null</Ref>
<bool name="IsLayered">false</bool>
<string name="Name">AccessoryDescription</string>
<int name="Order">0</int>
<Vector3 name="Position">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Puffiness">1</float>
<Vector3 name="Rotation">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="Scale">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
<UniqueId name="UniqueId">1857f279b32c2fee0776cdfd000052d8</UniqueId>
</Properties>
]],
	ManualWeld = [[
<Item class="ManualWeld" referent="RBX803E0F8E13F942A7844990E59EC63FDA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="Enabled">true</bool>
<string name="Name">ManualWeld</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">2edb7b184eb326660795f8e1000053a5</UniqueId>
</Properties>
]],
	PackageLink = [[
<Item class="PackageLink" referent="RBX13B5BAA642C14624B3BD0696BE16A54D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoUpdate">false</bool>
<string name="DefaultName"></string>
<int name="ModifiedState">-1</int>
<string name="Name">PackageLink</string>
<Content name="PackageIdSerialize"><url>rbxassetid://117041232117630</url></Content>
<BinaryString name="SerializedDefaultAttributes"></BinaryString>
<UniqueId name="UniqueId">6c4b5fab85710cfa07c529d500005894</UniqueId>
<int64 name="VersionIdSerialize">2</int64>
</Properties>
]],
	Snap = [[
<Item class="Snap" referent="RBXFA01BD3A73DC4CB1915734C5649875EF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="Enabled">true</bool>
<string name="Name">Snap</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">452c49fae9331fd007d1bf23000051ff</UniqueId>
</Properties>
]],
	Clouds = [[
<Item class="Clouds" referent="RBXF781219F2E844C40A5FB81BA5D13D89F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="Cover">0.5</float>
<float name="Density">0.699999988</float>
<bool name="Enabled">true</bool>
<string name="Name">Clouds</string>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005219</UniqueId>
</Properties>
]],
	Motor = [[
<Item class="Motor" referent="RBX2D30757D15C44B3287604E2899D311A2">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="DesiredAngle">0</float>
<bool name="Enabled">true</bool>
<float name="MaxVelocity">0</float>
<string name="Name">Motor</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab000051ff</UniqueId>
</Properties>
]],
	Rotate = [[
<Item class="Rotate" referent="RBX2E81B7A04C94428D80B6237DC9A72F92">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="Enabled">true</bool>
<string name="Name">Rotate</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005200</UniqueId>
</Properties>
]],
	SelectionBox = [[
<Item class="SelectionBox" referent="RBX9CFE2C61C5D54266A3CCC3AE5396FFD4">
<Properties>
<Ref name="Adornee">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<float name="LineThickness">0.150000006</float>
<string name="Name">SelectionBox</string>
<bool name="StudioSelectionBox">false</bool>
<Color3 name="SurfaceColor3">
<R>0.0509803966</R>
<G>0.411764741</G>
<B>0.674509823</B>
</Color3>
<float name="SurfaceTransparency">1</float>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005201</UniqueId>
<bool name="Visible">true</bool>
</Properties>
]],
	BodyGyro = [[
<Item class="BodyGyro" referent="RBX86FAB378468B4CD6B7EC82D2AD6BFCF4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="D">500</float>
<Vector3 name="MaxTorque">
<X>400000</X>
<Y>0</Y>
<Z>400000</Z>
</Vector3>
<string name="Name">BodyGyro</string>
<float name="P">3000</float>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005202</UniqueId>
</Properties>
]],
	Glue = [[
<Item class="Glue" referent="RBX79028FE9C72E4226B5F34ECB0447D3AF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="Enabled">true</bool>
<Vector3 name="F0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="F1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="F2">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="F3">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<string name="Name">Glue</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005203</UniqueId>
</Properties>
]],
	FileMesh = [[
<Item class="FileMesh" referent="RBX321BBAEEE442421EAAED7E544186CB18">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Content name="MeshId"><null></null></Content>
<string name="Name">Mesh</string>
<Vector3 name="Offset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="Scale">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
<Content name="TextureId"><null></null></Content>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005204</UniqueId>
<Vector3 name="VertexColor">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
</Properties>
]],
	IntConstrainedValue = [[
<Item class="IntConstrainedValue" referent="RBXB08558CE69B6449CB62D74C7BD062C65">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<int64 name="MaxValue">10</int64>
<int64 name="MinValue">0</int64>
<string name="Name">Value</string>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005205</UniqueId>
<int64 name="value">0</int64>
</Properties>
]],
	RotateP = [[
<Item class="RotateP" referent="RBXFE21263EEF454C68BBE4566688EAF6EC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="BaseAngle">0</float>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="Enabled">true</bool>
<string name="Name">RotateP</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005206</UniqueId>
</Properties>
]],
	RotateV = [[
<Item class="RotateV" referent="RBXF7157CDAAA924B2BA67B413C21B5FC32">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="BaseAngle">0</float>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="Enabled">true</bool>
<string name="Name">RotateV</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005207</UniqueId>
</Properties>
]],
	DoubleConstrainedValue = [[
<Item class="DoubleConstrainedValue" referent="RBX26C6618D576D4ED1A41930BF7EE4ADD4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<double name="MaxValue">1</double>
<double name="MinValue">0</double>
<string name="Name">Value</string>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005208</UniqueId>
<double name="value">0</double>
</Properties>
]],
	Hat = [[
<Item class="Hat" referent="RBX86BAAB494D964E3ABFE265F880802BC6">
<Properties>
<CoordinateFrame name="AttachmentPoint">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Hat</string>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005209</UniqueId>
</Properties>
]],
	Backpack = [[
<Item class="Backpack" referent="RBXF91F2378C23245199AB24C377EA95843">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Backpack</string>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab0000520a</UniqueId>
</Properties>
]],
	BodyForce = [[
<Item class="BodyForce" referent="RBXA46791D7ACBE4032B09753A287F3375B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Vector3 name="Force">
<X>0</X>
<Y>1</Y>
<Z>0</Z>
</Vector3>
<string name="Name">BodyForce</string>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab0000520b</UniqueId>
</Properties>
]],
	BodyPosition = [[
<Item class="BodyPosition" referent="RBXA9829086537A4EA0A86E706FC75FD59A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="D">1250</float>
<Vector3 name="MaxForce">
<X>4000</X>
<Y>4000</Y>
<Z>4000</Z>
</Vector3>
<string name="Name">BodyPosition</string>
<float name="P">10000</float>
<Vector3 name="Position">
<X>0</X>
<Y>50</Y>
<Z>0</Z>
</Vector3>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab0000520c</UniqueId>
</Properties>
]],
	BodyThrust = [[
<Item class="BodyThrust" referent="RBX0DF7A78FD9DB490C828C968D6A83A730">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Vector3 name="Force">
<X>0</X>
<Y>1</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="Location">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<string name="Name">BodyThrust</string>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab0000520d</UniqueId>
</Properties>
]],
	KeyframeSequence = [[
<Item class="KeyframeSequence" referent="RBX1721752E1F6D4AA8800B21E0C7F52A37">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="AuthoredHipHeight">2</float>
<BinaryString name="GuidBinaryString">AAAAAAAAAAAAAAAAAAAAAA==</BinaryString>
<bool name="Loop">true</bool>
<string name="Name">KeyframeSequence</string>
<token name="Priority">2</token>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab0000520e</UniqueId>
</Properties>
]],
	Camera = [[
<Item class="Camera" referent="RBXD8498904B11248D9947386B7159A76D8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>20</Y>
<Z>20</Z>
<R00>1</R00>
<R01>0</R01>
<R02>-0</R02>
<R10>-0</R10>
<R11>0.707106829</R11>
<R12>0.707106829</R12>
<R20>0</R20>
<R21>-0.707106829</R21>
<R22>0.707106829</R22>
</CoordinateFrame>
<Ref name="CameraSubject">null</Ref>
<token name="CameraType">0</token>
<float name="FieldOfView">70</float>
<token name="FieldOfViewMode">0</token>
<CoordinateFrame name="Focus">
<X>0</X>
<Y>0</Y>
<Z>-5</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="HeadLocked">true</bool>
<float name="HeadScale">1</float>
<string name="Name">Camera</string>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab0000520f</UniqueId>
<bool name="VRTiltAndRollEnabled">false</bool>
</Properties>
]],
	PathfindingModifier = [[
<Item class="PathfindingModifier" referent="RBXAE06D71A7D424567AD4254B8C38A7AAD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Label"></string>
<string name="Name">PathfindingModifier</string>
<bool name="PassThrough">false</bool>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005210</UniqueId>
</Properties>
]],
	GuiMain = [[
<Item class="GuiMain" referent="RBXACBC54383D354AFB8674562B9720EF5E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<bool name="ClipToDeviceSafeArea">true</bool>
<int name="DisplayOrder">0</int>
<bool name="Enabled">true</bool>
<string name="Name">GuiMain</string>
<bool name="ResetOnSpawn">true</bool>
<Ref name="RootLocalizationTable">null</Ref>
<token name="SafeAreaCompatibility">1</token>
<token name="ScreenInsets">2</token>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005211</UniqueId>
<token name="ZIndexBehavior">0</token>
</Properties>
]],
	Keyframe = [[
<Item class="Keyframe" referent="RBXD72CD33DC53146B9AF26747AC2411D00">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Keyframe</string>
<float name="Time">0</float>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005212</UniqueId>
</Properties>
]],
	BodyAngularVelocity = [[
<Item class="BodyAngularVelocity" referent="RBX2037FFD6C7DA45CEA4E0A92E54AA3BC5">
<Properties>
<Vector3 name="AngularVelocity">
<X>0</X>
<Y>2</Y>
<Z>0</Z>
</Vector3>
<BinaryString name="AttributesSerialize"></BinaryString>
<Vector3 name="MaxTorque">
<X>4000</X>
<Y>4000</Y>
<Z>4000</Z>
</Vector3>
<string name="Name">BodyAngularVelocity</string>
<float name="P">1250</float>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005213</UniqueId>
</Properties>
]],
	UIFlexItem = [[
<Item class="UIFlexItem" referent="RBX8E7ED6DF78344A51A3698D171F5FF099">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="FlexMode">0</token>
<float name="GrowRatio">0</float>
<token name="ItemLineAlignment">0</token>
<string name="Name">UIFlexItem</string>
<float name="ShrinkRatio">0</float>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005214</UniqueId>
</Properties>
]],
	AdPortal = [[
<Item class="AdPortal" referent="RBX28AB4D26ABBE4EAD96B9C83A0DE77E1D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">AdPortal</string>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab00005216</UniqueId>
</Properties>
]],
	UIDragDetector = [[
<Item class="UIDragDetector" referent="RBX8342C21A1E0945D6B13B43BF9890B1D7">
<Properties>
<Content name="ActivatedCursorIcon"><null></null></Content>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BoundingBehavior">0</token>
<Ref name="BoundingUI">null</Ref>
<Content name="CursorIcon"><null></null></Content>
<Vector2 name="DragAxis">
<X>1</X>
<Y>0</Y>
</Vector2>
<token name="DragRelativity">0</token>
<float name="DragRotation">0</float>
<token name="DragSpace">0</token>
<token name="DragStyle">0</token>
<UDim2 name="DragUDim2">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<bool name="Enabled">true</bool>
<float name="MaxDragAngle">0</float>
<UDim2 name="MaxDragTranslation">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<float name="MinDragAngle">0</float>
<UDim2 name="MinDragTranslation">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<string name="Name">UIDragDetector</string>
<Ref name="ReferenceUIInstance">null</Ref>
<token name="ResponseStyle">0</token>
<UDim2 name="SelectionModeDragSpeed">
<XS>0</XS>
<XO>300</XO>
<YS>0</YS>
<YO>300</YO>
</UDim2>
<float name="SelectionModeRotateSpeed">90</float>
<token name="UIDragSpeedAxisMapping">0</token>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab0000521a</UniqueId>
</Properties>
]],
	BoxHandleAdornment = [[
<Item class="BoxHandleAdornment" referent="RBX97006907F7194096AF05C3A55B74F1BE">
<Properties>
<token name="AdornCullingMode">0</token>
<Ref name="Adornee">null</Ref>
<bool name="AlwaysOnTop">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<string name="Name">BoxHandleAdornment</string>
<Vector3 name="Size">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
<Vector3 name="SizeRelativeOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">48538bfd680d7e4507d249ab0000521b</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">-1</int>
</Properties>
]],
	Pose = [[
<Item class="Pose" referent="RBX4357E25E1D9E4DE184804446AFF44951">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<token name="EasingDirection">0</token>
<token name="EasingStyle">0</token>
<string name="Name">Pose</string>
<UniqueId name="UniqueId">14ed926867a13c4b07d53eff00005291</UniqueId>
<float name="Weight">1</float>
</Properties>
]],
	AdGui = [[
<Item class="AdGui" referent="RBXDAAA061CA60A4517B01B1FC2DB28F4D4">
<Properties>
<bool name="Active">true</bool>
<token name="AdShape">1</token>
<Ref name="Adornee">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<bool name="EnableVideoAds">true</bool>
<bool name="Enabled">true</bool>
<token name="Face">5</token>
<Content name="FallbackImage"><null></null></Content>
<string name="Name">AdGui</string>
<bool name="ResetOnSpawn">true</bool>
<Ref name="RootLocalizationTable">null</Ref>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<UniqueId name="UniqueId">14ed926867a13c4b07d53eff00005292</UniqueId>
<token name="ZIndexBehavior">0</token>
</Properties>
]],
	AnimationRigData = [=[
<Item class="AnimationRigData" referent="RBX87885456072F43139E95D174959D1FD9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">AnimationRigData</string>
<UniqueId name="UniqueId">14ed926867a13c4b07d53eff00005295</UniqueId>
<BinaryString name="label">AQAAAAEAAAAAAAAA</BinaryString>
<BinaryString name="name">AQAAAAEAAAAAAAAA</BinaryString>
<BinaryString name="parent">AQAAAAEAAAAAAA==</BinaryString>
<BinaryString name="postTransform"><![CDATA[AQAAAAEAAAAAAIA/AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAA
AAA=]]></BinaryString>
<BinaryString name="preTransform"><![CDATA[AQAAAAEAAAAAAIA/AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAA
AAA=]]></BinaryString>
<BinaryString name="transform"><![CDATA[AQAAAAEAAAAAAIA/AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAA
AAA=]]></BinaryString>
</Properties>
]=],
	KeyframeMarker = [[
<Item class="KeyframeMarker" referent="RBX934DEEF079DB43CCAF16077EB2272CA7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">KeyframeMarker</string>
<UniqueId name="UniqueId">14ed926867a13c4b07d53eff00005296</UniqueId>
<string name="Value"></string>
</Properties>
]],
	HopperBin = [[
<Item class="HopperBin" referent="RBXD235B0BC5FBB45DA97EAFE2BDE17AA3E">
<Properties>
<bool name="Active">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BinType">0</token>
<token name="LevelOfDetail">0</token>
<CoordinateFrame name="ModelMeshCFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<SharedString name="ModelMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<Vector3 name="ModelMeshSize">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="ModelStreamingMode">0</token>
<string name="Name">HopperBin</string>
<bool name="NeedsPivotMigration">false</bool>
<Ref name="PrimaryPart">null</Ref>
<float name="ScaleFactor">1</float>
<Content name="TextureId"><null></null></Content>
<UniqueId name="UniqueId">14ed926867a13c4b07d53eff00005297</UniqueId>
<OptionalCoordinateFrame name="WorldPivotData"></OptionalCoordinateFrame>
</Properties>
]],
	FluidForceSensor = [[
<Item class="FluidForceSensor" referent="RBX8B0BAA93120C48EF8E3C45F58E186A66">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">FluidForceSensor</string>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a00005342</UniqueId>
<token name="UpdateType">0</token>
</Properties>
]],
	PartOperationAsset = [[
<Item class="PartOperationAsset" referent="RBXE8855EE6F29046488F60E095755D8718">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<BinaryString name="ChildData"></BinaryString>
<BinaryString name="MeshData"></BinaryString>
<string name="Name">Instance</string>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a00005343</UniqueId>
</Properties>
]],
	IntersectOperation = [[
<Item class="IntersectOperation" referent="RBXC9B0310E4020476099A45AD730E567F0">
<Properties>
<SharedString name="AeroMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<bool name="Anchored">false</bool>
<Content name="AssetId"><null></null></Content>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AudioCanCollide">true</bool>
<float name="BackParamA">-0.5</float>
<float name="BackParamB">0.5</float>
<token name="BackSurface">0</token>
<token name="BackSurfaceInput">0</token>
<float name="BottomParamA">-0.5</float>
<float name="BottomParamB">0.5</float>
<token name="BottomSurface">0</token>
<token name="BottomSurfaceInput">0</token>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<BinaryString name="ChildData"></BinaryString>
<SharedString name="ChildData2">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4294967295</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="EnableFluidForces">true</bool>
<token name="FluidFidelityInternal">0</token>
<token name="FormFactor">3</token>
<float name="FrontParamA">-0.5</float>
<float name="FrontParamB">0.5</float>
<token name="FrontSurface">0</token>
<token name="FrontSurfaceInput">0</token>
<Vector3 name="InitialSize">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
<float name="LeftParamA">-0.5</float>
<float name="LeftParamB">0.5</float>
<token name="LeftSurface">0</token>
<token name="LeftSurfaceInput">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<BinaryString name="MeshData"></BinaryString>
<SharedString name="MeshData2">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<string name="Name">Intersection</string>
<SharedString name="PhysicalConfigData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<BinaryString name="PhysicsData"></BinaryString>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RenderFidelity">0</token>
<float name="RightParamA">-0.5</float>
<float name="RightParamB">0.5</float>
<token name="RightSurface">0</token>
<token name="RightSurfaceInput">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="SmoothingAngle">0</float>
<float name="TopParamA">-0.5</float>
<float name="TopParamB">0.5</float>
<token name="TopSurface">0</token>
<token name="TopSurfaceInput">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a00005344</UniqueId>
<Vector3 name="UnscaledCofm">
<X>NAN</X>
<Y>NAN</Y>
<Z>NAN</Z>
</Vector3>
<Vector3 name="UnscaledVolInertiaDiags">
<X>NAN</X>
<Y>NAN</Y>
<Z>NAN</Z>
</Vector3>
<Vector3 name="UnscaledVolInertiaOffDiags">
<X>NAN</X>
<Y>NAN</Y>
<Z>NAN</Z>
</Vector3>
<float name="UnscaledVolume">NAN</float>
<bool name="UsePartColor">false</bool>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="size">
<X>4</X>
<Y>1.20000005</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	VelocityMotor = [[
<Item class="VelocityMotor" referent="RBX01D40613A4364066BA38E69CB5445434">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="C0">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<CoordinateFrame name="C1">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="CurrentAngle">0</float>
<float name="DesiredAngle">0</float>
<bool name="Enabled">true</bool>
<Ref name="Hole">null</Ref>
<float name="MaxVelocity">0</float>
<string name="Name">VelocityMotor</string>
<Ref name="Part0">null</Ref>
<Ref name="Part1">null</Ref>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a00005345</UniqueId>
</Properties>
]],
	Handles = [[
<Item class="Handles" referent="RBX14053E99C941498F954B46931B633320">
<Properties>
<Ref name="Adornee">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<Faces name="Faces">
<faces>63</faces>
</Faces>
<string name="Name">Handles</string>
<token name="Style">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a00005346</UniqueId>
<bool name="Visible">true</bool>
</Properties>
]],
	ConeHandleAdornment = [[
<Item class="ConeHandleAdornment" referent="RBXBB29E6D4AF91426EBBDD416165F1DF35">
<Properties>
<token name="AdornCullingMode">0</token>
<Ref name="Adornee">null</Ref>
<bool name="AlwaysOnTop">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<float name="Height">2</float>
<string name="Name">ConeHandleAdornment</string>
<float name="Radius">0.5</float>
<Vector3 name="SizeRelativeOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a00005347</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">-1</int>
</Properties>
]],
	Hint = [[
<Item class="Hint" referent="RBX5B7ED2DE578C4D5EBFA2EAFF648955B6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Message</string>
<string name="Text"></string>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a00005348</UniqueId>
</Properties>
]],
	LocalizationTable = [[
<Item class="LocalizationTable" referent="RBXA5538C40B053469DB914CCB145150B0F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Contents">[]</string>
<string name="Name">LocalizationTable</string>
<string name="SourceLocaleId">en-us</string>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a00005349</UniqueId>
</Properties>
]],
	NumberPose = [[
<Item class="NumberPose" referent="RBX941C549CB0894AD18DBB5830309ACD18">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="EasingDirection">0</token>
<token name="EasingStyle">0</token>
<string name="Name">Pose</string>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a0000534a</UniqueId>
<double name="Value">0</double>
<float name="Weight">1</float>
</Properties>
]],
	CylinderHandleAdornment = [[
<Item class="CylinderHandleAdornment" referent="RBX97E9C4403081408CBBE176A261F247FB">
<Properties>
<token name="AdornCullingMode">0</token>
<Ref name="Adornee">null</Ref>
<bool name="AlwaysOnTop">false</bool>
<float name="Angle">360</float>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<float name="Height">1</float>
<float name="InnerRadius">0</float>
<string name="Name">CylinderHandleAdornment</string>
<float name="Radius">1</float>
<Vector3 name="SizeRelativeOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a0000534b</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">-1</int>
</Properties>
]],
	Accoutrement = [[
<Item class="Accoutrement" referent="RBX0A39A9386B1946F3A9FF1B077CAEA1C9">
<Properties>
<CoordinateFrame name="AttachmentPoint">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Accoutrement</string>
<UniqueId name="UniqueId">7777fbfe13c3180807db881a0000534c</UniqueId>
</Properties>
]],
	StyleSheet = [[
<Item class="StyleSheet" referent="RBX9808DEDB9FF64467A19F98FD2F2F1306">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">StyleSheet</string>
<UniqueId name="UniqueId">6abe962e87a3532407dbb03800005342</UniqueId>
</Properties>
]],
	NegateOperation = [[
<Item class="NegateOperation" referent="RBX98C4AC54F67D4E0FBC8A3A6D2289FE4F">
<Properties>
<SharedString name="AeroMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<bool name="Anchored">true</bool>
<Content name="AssetId"><null></null></Content>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AudioCanCollide">true</bool>
<float name="BackParamA">-0.5</float>
<float name="BackParamB">0.5</float>
<token name="BackSurface">0</token>
<token name="BackSurfaceInput">0</token>
<float name="BottomParamA">-0.5</float>
<float name="BottomParamB">0.5</float>
<token name="BottomSurface">0</token>
<token name="BottomSurfaceInput">0</token>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">false</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<BinaryString name="ChildData"></BinaryString>
<SharedString name="ChildData2">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4294967295</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="EnableFluidForces">true</bool>
<token name="FluidFidelityInternal">0</token>
<token name="FormFactor">3</token>
<float name="FrontParamA">-0.5</float>
<float name="FrontParamB">0.5</float>
<token name="FrontSurface">0</token>
<token name="FrontSurfaceInput">0</token>
<Vector3 name="InitialSize">
<X>1</X>
<Y>1</Y>
<Z>1</Z>
</Vector3>
<float name="LeftParamA">-0.5</float>
<float name="LeftParamB">0.5</float>
<token name="LeftSurface">0</token>
<token name="LeftSurfaceInput">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<BinaryString name="MeshData"></BinaryString>
<SharedString name="MeshData2">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<string name="Name">NegativePart</string>
<SharedString name="PhysicalConfigData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<BinaryString name="PhysicsData"></BinaryString>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RenderFidelity">0</token>
<float name="RightParamA">-0.5</float>
<float name="RightParamB">0.5</float>
<token name="RightSurface">0</token>
<token name="RightSurfaceInput">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="SmoothingAngle">0</float>
<float name="TopParamA">-0.5</float>
<float name="TopParamB">0.5</float>
<token name="TopSurface">0</token>
<token name="TopSurfaceInput">0</token>
<float name="Transparency">0.100000001</float>
<UniqueId name="UniqueId">6abe962e87a3532407dbb03800005343</UniqueId>
<Vector3 name="UnscaledCofm">
<X>NAN</X>
<Y>NAN</Y>
<Z>NAN</Z>
</Vector3>
<Vector3 name="UnscaledVolInertiaDiags">
<X>NAN</X>
<Y>NAN</Y>
<Z>NAN</Z>
</Vector3>
<Vector3 name="UnscaledVolInertiaOffDiags">
<X>NAN</X>
<Y>NAN</Y>
<Z>NAN</Z>
</Vector3>
<float name="UnscaledVolume">NAN</float>
<bool name="UsePartColor">false</bool>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Vector3 name="size">
<X>4</X>
<Y>1.20000005</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	Hole = [[
<Item class="Hole" referent="RBXE906DEA95C7D4760BE2392C833DC7251">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="FaceId">0</token>
<token name="InOut">2</token>
<token name="LeftRight">1</token>
<string name="Name">Hole</string>
<token name="TopBottom">1</token>
<UniqueId name="UniqueId">1509bd47f655e3bf07dccdf90000533e</UniqueId>
</Properties>
]],
	StyleDerive = [[
<Item class="StyleDerive" referent="RBX782C5ABFE59A49DBB57B63E44D2D6D50">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="Index">-1</int>
<string name="Name">StyleDerive</string>
<Ref name="StyleSheet">null</Ref>
<UniqueId name="UniqueId">1509bd47f655e3bf07dccdf90000533f</UniqueId>
</Properties>
]],
	StyleLink = [[
<Item class="StyleLink" referent="RBX770189E99EDC4043A409211D767DCFED">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">StyleLink</string>
<Ref name="StyleSheet">null</Ref>
<UniqueId name="UniqueId">1509bd47f655e3bf07dccdf900005340</UniqueId>
</Properties>
]],
	StyleRule = [[
<Item class="StyleRule" referent="RBXC6633B95BF074EC699385FF8351D677D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">StyleRule</string>
<int name="Priority">0</int>
<BinaryString name="PropertiesSerialize">AAAAAA==</BinaryString>
<string name="Selector"></string>
<UniqueId name="UniqueId">1509bd47f655e3bf07dccdf900005341</UniqueId>
</Properties>
]],
	Actor = [[
<Item class="Actor" referent="RBX567FEB7CEA404779A3A1F5AA62448EFA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="LevelOfDetail">0</token>
<CoordinateFrame name="ModelMeshCFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<SharedString name="ModelMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<Vector3 name="ModelMeshSize">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="ModelStreamingMode">0</token>
<string name="Name">Actor</string>
<bool name="NeedsPivotMigration">false</bool>
<Ref name="PrimaryPart">null</Ref>
<float name="ScaleFactor">1</float>
<UniqueId name="UniqueId">3c330340e83c436c07dfb67100005343</UniqueId>
<OptionalCoordinateFrame name="WorldPivotData"></OptionalCoordinateFrame>
</Properties>
]],
	CurveAnimation = [[
<Item class="CurveAnimation" referent="RBX553377832E1547D4A759481DB5C3727A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<BinaryString name="GuidBinaryString">AAAAAAAAAAAAAAAAAAAAAA==</BinaryString>
<bool name="Loop">true</bool>
<string name="Name">Instance</string>
<token name="Priority">2</token>
<UniqueId name="UniqueId">3c330340e83c436c07dfb67100005344</UniqueId>
</Properties>
]],
	SelectionSphere = [[
<Item class="SelectionSphere" referent="RBX1DD4DE26AC03486299C2B082C83537A1">
<Properties>
<Ref name="Adornee">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<string name="Name">SelectionSphere</string>
<Color3 name="SurfaceColor3">
<R>0.0509803966</R>
<G>0.411764741</G>
<B>0.674509823</B>
</Color3>
<float name="SurfaceTransparency">1</float>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">3c330340e83c436c07dfb67100005345</UniqueId>
<bool name="Visible">true</bool>
</Properties>
]],
	SelectionPartLasso = [[
<Item class="SelectionPartLasso" referent="RBX8484C56A9B5E47B2BF1AC85F498F44B5">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<Ref name="Humanoid">null</Ref>
<string name="Name">SelectionPartLasso</string>
<Ref name="Part">null</Ref>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">3c330340e83c436c07dfb67100005346</UniqueId>
<bool name="Visible">true</bool>
</Properties>
]],
	SelectionPointLasso = [[
<Item class="SelectionPointLasso" referent="RBX95F44C2B6DE0457297A4A2C589650E5C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<Ref name="Humanoid">null</Ref>
<string name="Name">SelectionPointLasso</string>
<Vector3 name="Point">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">3c330340e83c436c07dfb67100005347</UniqueId>
<bool name="Visible">true</bool>
</Properties>
]],
	EulerRotationCurve = [[
<Item class="EulerRotationCurve" referent="RBX73D9F2CA4014428C82B2F01E9DA5FA03">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Instance</string>
<token name="RotationOrder">0</token>
<UniqueId name="UniqueId">44c5d3d40e6a6586080092010000559f</UniqueId>
</Properties>
]],
	Vector3Curve = [[
<Item class="Vector3Curve" referent="RBXE30FFFE4A16F401BB7A3BA8E572CC58D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Instance</string>
<UniqueId name="UniqueId">44c5d3d40e6a658608009201000055a0</UniqueId>
</Properties>
]],
	SkateboardPlatform = [[
<Item class="SkateboardPlatform" referent="RBX072EC971AD654B4AA042E1A34C76D70E">
<Properties>
<bool name="Anchored">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AudioCanCollide">true</bool>
<token name="BackSurface">0</token>
<token name="BottomSurface">4</token>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4288914085</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="EnableFluidForces">true</bool>
<token name="FrontSurface">0</token>
<token name="LeftSurface">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<string name="Name">SkateboardPlatform</string>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<token name="RightSurface">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<int name="Steer">0</int>
<bool name="StickyWheels">true</bool>
<int name="Throttle">0</int>
<token name="TopSurface">3</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">44c5d3d40e6a658608009201000055a1</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="formFactorRaw">1</token>
<token name="shape">1</token>
<Vector3 name="size">
<X>4</X>
<Y>1.20000005</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	RocketPropulsion = [[
<Item class="RocketPropulsion" referent="RBX218A7CB548DC49948FEA03BBC5CB2BD6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="CartoonFactor">0.699999988</float>
<float name="MaxSpeed">30</float>
<float name="MaxThrust">4000</float>
<Vector3 name="MaxTorque">
<X>400000</X>
<Y>400000</Y>
<Z>0</Z>
</Vector3>
<string name="Name">RocketPropulsion</string>
<Ref name="Target">null</Ref>
<Vector3 name="TargetOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="TargetRadius">4</float>
<float name="ThrustD">0.00100000005</float>
<float name="ThrustP">5</float>
<float name="TurnD">500</float>
<float name="TurnP">3000</float>
<UniqueId name="UniqueId">44c5d3d40e6a658608009201000055a2</UniqueId>
</Properties>
]],
	MarkerCurve = [[
<Item class="MarkerCurve" referent="RBX5C2813141E674BE9B1493424AE04C0A8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Instance</string>
<UniqueId name="UniqueId">44c5d3d40e6a658608009201000055a3</UniqueId>
<BinaryString name="ValuesAndTimes">AQAAAAAAAAABAAAAAAAAAA==</BinaryString>
</Properties>
]],
	FloorWire = [[
<Item class="FloorWire" referent="RBX6C7B51DB3B384D98BBA5B17EC89F5F80">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<float name="CycleOffset">0</float>
<Ref name="From">null</Ref>
<string name="Name">FloorWire</string>
<float name="StudsBetweenTextures">4</float>
<Content name="Texture"><null></null></Content>
<Vector2 name="TextureSize">
<X>1</X>
<Y>1</Y>
</Vector2>
<Ref name="To">null</Ref>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">44c5d3d40e6a658608009201000055a4</UniqueId>
<float name="Velocity">2</float>
<bool name="Visible">true</bool>
<float name="WireRadius">0.0625</float>
</Properties>
]],
	BubbleChatMessageProperties = [[
<Item class="BubbleChatMessageProperties" referent="RBX614216096DE04FB5B38364D9665FF982">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Instance</string>
<int64 name="SourceAssetId">-1</int64>
<UniqueId name="UniqueId">5406e794f691e00d0803064900005597</UniqueId>
</Properties>
]],
	SphereHandleAdornment = [[
<Item class="SphereHandleAdornment" referent="RBXE8309ADB8C164543BED789CD0D3BAD2D">
<Properties>
<token name="AdornCullingMode">0</token>
<Ref name="Adornee">null</Ref>
<bool name="AlwaysOnTop">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<string name="Name">SphereHandleAdornment</string>
<float name="Radius">1</float>
<Vector3 name="SizeRelativeOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">5406e794f691e00d0803064900005598</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">-1</int>
</Properties>
]],
	IKControl = [[
<Item class="IKControl" referent="RBXBF3A90634F61461ABC867FC96BF9D260">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Ref name="ChainRoot">null</Ref>
<bool name="DefinesCapabilities">false</bool>
<bool name="Enabled">true</bool>
<Ref name="EndEffector">null</Ref>
<CoordinateFrame name="EndEffectorOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<string name="Name">IKControl</string>
<CoordinateFrame name="Offset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Ref name="Pole">null</Ref>
<int name="Priority">0</int>
<float name="SmoothTime">0.0500000007</float>
<Ref name="Target">null</Ref>
<token name="Type">0</token>
<UniqueId name="UniqueId">5406e794f691e00d0803064900005599</UniqueId>
<float name="Weight">1</float>
</Properties>
]],
	FloatCurve = [[
<Item class="FloatCurve" referent="RBX37F3E47B609E410DB6338BC84DDF9E72">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Instance</string>
<UniqueId name="UniqueId">6d96c26fffbc3dbd080744080000559b</UniqueId>
<BinaryString name="ValuesAndTimes">AQAAAAAAAAABAAAAAAAAAA==</BinaryString>
</Properties>
]],
	Flag = [[
<Item class="Flag" referent="RBX85EC1E2929AD4577AF5A5830F8059B97">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="CanBeDropped">true</bool>
<bool name="Enabled">true</bool>
<CoordinateFrame name="Grip">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<token name="LevelOfDetail">0</token>
<bool name="ManualActivationOnly">false</bool>
<CoordinateFrame name="ModelMeshCFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<SharedString name="ModelMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<Vector3 name="ModelMeshSize">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="ModelStreamingMode">0</token>
<string name="Name">Flag</string>
<bool name="NeedsPivotMigration">false</bool>
<Ref name="PrimaryPart">null</Ref>
<bool name="RequiresHandle">true</bool>
<float name="ScaleFactor">1</float>
<int name="TeamColor">194</int>
<Content name="TextureId"><null></null></Content>
<string name="ToolTip"></string>
<UniqueId name="UniqueId">6d96c26fffbc3dbd08074408000055a0</UniqueId>
<OptionalCoordinateFrame name="WorldPivotData"></OptionalCoordinateFrame>
</Properties>
]],
	FlagStand = [[
<Item class="FlagStand" referent="RBX425E58A1B40A4D49988A347973B31FA1">
<Properties>
<bool name="Anchored">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AudioCanCollide">true</bool>
<float name="BackParamA">-0.5</float>
<float name="BackParamB">0.5</float>
<token name="BackSurface">0</token>
<token name="BackSurfaceInput">0</token>
<float name="BottomParamA">-0.5</float>
<float name="BottomParamB">0.5</float>
<token name="BottomSurface">4</token>
<token name="BottomSurfaceInput">0</token>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4288914085</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="EnableFluidForces">true</bool>
<float name="FrontParamA">-0.5</float>
<float name="FrontParamB">0.5</float>
<token name="FrontSurface">0</token>
<token name="FrontSurfaceInput">0</token>
<float name="LeftParamA">-0.5</float>
<float name="LeftParamB">0.5</float>
<token name="LeftSurface">0</token>
<token name="LeftSurfaceInput">0</token>
<bool name="Locked">false</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<string name="MaterialVariantSerialized"></string>
<string name="Name">FlagStand</string>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<float name="RightParamA">-0.5</float>
<float name="RightParamB">0.5</float>
<token name="RightSurface">0</token>
<token name="RightSurfaceInput">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<int name="TeamColor">194</int>
<float name="TopParamA">-0.5</float>
<float name="TopParamB">0.5</float>
<token name="TopSurface">3</token>
<token name="TopSurfaceInput">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">6d96c26fffbc3dbd08074408000055a1</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="formFactorRaw">1</token>
<token name="shape">1</token>
<Vector3 name="size">
<X>4</X>
<Y>1.20000005</Y>
<Z>2</Z>
</Vector3>
</Properties>
]],
	AudioEmitter = [[
<Item class="AudioEmitter" referent="RBX31061536D4BD4AE6B0D50DD0C472B5B6">
<Properties>
<BinaryString name="AngleAttenuation">AA==</BinaryString>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="AudioInteractionGroup"></string>
<BinaryString name="DistanceAttenuation">AA==</BinaryString>
<string name="Name">AudioEmitter</string>
<token name="SimulationFidelity">1</token>
<UniqueId name="UniqueId">6d96c26fffbc3dbd08074408000055a4</UniqueId>
</Properties>
]],
	ArcHandles = [[
<Item class="ArcHandles" referent="RBX92304B998E094F7587A01BDE62E70E51">
<Properties>
<Ref name="Adornee">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<Axes name="Axes">
<axes>7</axes>
</Axes>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<string name="Name">ArcHandles</string>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">6d96c26fffbc3dbd08074408000055a5</UniqueId>
<bool name="Visible">true</bool>
</Properties>
]],
	ControllerPartSensor = [[
<Item class="ControllerPartSensor" referent="RBXF04E6BB6656945F3A116170670D79A34">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="HitFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Vector3 name="HitNormal">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<string name="Name">ControllerPartSensor</string>
<float name="SearchDistance">0</float>
<Ref name="SensedPart">null</Ref>
<token name="SensorMode">0</token>
<UniqueId name="UniqueId">6d96c26fffbc3dbd08074408000055a6</UniqueId>
<token name="UpdateType">0</token>
</Properties>
]],
	Message = [[
<Item class="Message" referent="RBXBA5D6037F4DF420F8BDF42BE329EAFD0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Message</string>
<string name="Text"></string>
<UniqueId name="UniqueId">6d96c26fffbc3dbd08074408000055a7</UniqueId>
</Properties>
]],
	ControllerManager = [[
<Item class="ControllerManager" referent="RBX5856C54D0FF94BA9ADCEEB1D0487E5D0">
<Properties>
<Ref name="ActiveController">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="BaseMoveSpeed">16</float>
<float name="BaseTurnSpeed">8</float>
<Ref name="ClimbSensor">null</Ref>
<Vector3 name="FacingDirection">
<X>0</X>
<Y>0</Y>
<Z>1</Z>
</Vector3>
<Ref name="GroundSensor">null</Ref>
<Vector3 name="MovingDirection">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<string name="Name">ControllerManager</string>
<Ref name="RootPart">null</Ref>
<UniqueId name="UniqueId">2811b49b4ef51ce3087367be00005bee</UniqueId>
<Vector3 name="UpDirection">
<X>0</X>
<Y>1</Y>
<Z>0</Z>
</Vector3>
</Properties>
]],
	LineHandleAdornment = [[
<Item class="LineHandleAdornment" referent="RBXA9C4CAA89BA14F298EA3B4586018423C">
<Properties>
<token name="AdornCullingMode">0</token>
<Ref name="Adornee">null</Ref>
<bool name="AlwaysOnTop">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<float name="Length">5</float>
<string name="Name">LineHandleAdornment</string>
<Vector3 name="SizeRelativeOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Thickness">1</float>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">2811b49b4ef51ce3087367be00005bef</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">-1</int>
</Properties>
]],
	ImageHandleAdornment = [[
<Item class="ImageHandleAdornment" referent="RBX42094A5887B544A9B788E450FB1C8179">
<Properties>
<token name="AdornCullingMode">0</token>
<Ref name="Adornee">null</Ref>
<bool name="AlwaysOnTop">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<Color3 name="Color3">
<R>0.94901967</R>
<G>0.952941239</G>
<B>0.952941239</B>
</Color3>
<Content name="Image"><url>rbxasset://textures/SurfacesDefault.png</url></Content>
<string name="Name">ImageHandleAdornment</string>
<Vector2 name="Size">
<X>1</X>
<Y>1</Y>
</Vector2>
<Vector3 name="SizeRelativeOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">2811b49b4ef51ce3087367be00005bf0</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">-1</int>
</Properties>
]],
	SurfaceSelection = [[
<Item class="SurfaceSelection" referent="RBX4F25FC41BC3A4EB497605580FD2EF096">
<Properties>
<Ref name="Adornee">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="Color3">
<R>0.0509803928</R>
<G>0.411764711</G>
<B>0.674509823</B>
</Color3>
<string name="Name">SurfaceSelection</string>
<token name="TargetSurface">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">2811b49b4ef51ce3087367be00005bf5</UniqueId>
<bool name="Visible">true</bool>
</Properties>
]],
	AudioPlayer = [[
<Item class="AudioPlayer" referent="RBXC1309BD4043840E596562FF1EFB14588">
<Properties>
<Content name="Asset"><null></null></Content>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLoad">true</bool>
<bool name="IsMutedForCapture">false</bool>
<NumberRange name="LoopRegion">0 60000 </NumberRange>
<bool name="Looping">false</bool>
<string name="Name">AudioPlayer</string>
<NumberRange name="PlaybackRegion">0 60000 </NumberRange>
<double name="PlaybackSpeed">1</double>
<double name="TimePosition">0</double>
<UniqueId name="UniqueId">2811b49b4ef51ce3087367be00005bfc</UniqueId>
<float name="Volume">1</float>
</Properties>
]],
	AudioPitchShifter = [[
<Item class="AudioPitchShifter" referent="RBXEB08903401B541CDA658E7D709D155D5">
<Properties>
<bool name="Bypass">false</bool>
<float name="Pitch">1.25</float>
<token name="WindowSize">1</token>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">AudioPitchShifter</string>
<UniqueId name="UniqueId">60f4517cd8591c4e0a4b62b500000798</UniqueId>
</Properties>
]],
	HapticEffect = [[
<Item class="HapticEffect" referent="RBX27DAEF78595C40F2A856D6089F90F9C7">
<Properties>
<bool name="Looped">false</bool>
<Vector3 name="Position">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Radius">3</float>
<token name="Type">2</token>
<BinaryString name="WaveformData"></BinaryString>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">HapticEffect</string>
<UniqueId name="UniqueId">60f4517cd8591c4e0a4b62b500000799</UniqueId>
</Properties>
]],
	AudioDeviceOutput = [[
<Item class="AudioDeviceOutput" referent="RBX8371B303ABC945BABE9B1278AEFC6392">
<Properties>
<Ref name="Player">null</Ref>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">AudioDeviceOutput</string>
<UniqueId name="UniqueId">60f4517cd8591c4e0a4b62b50000079a</UniqueId>
</Properties>
]]
}
local flag = false
local flag2 = false
local flag3 = false
local v2 = false
local count = 0

function Color3uint8Encode(p, p2, p3)
	return (tostring(p * 65536 + p2 * 256 + p3 + 4278190080))
end

function to_base64(value)
	return (value:gsub(".", function(value2)
		local v3 = value2:byte()
		local v4 = ""

		for i = 8, 1, -1 do
			v4 ..= v3 % 2 ^ i - v3 % 2 ^ (i - 1) > 0 and "1" or "0"
		end

		return v4
	end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(value2)
		if #value2 < 6 then
			return ""
		end

		local total = 0

		for i = 1, 6 do
			total += value2:sub(i, i) ~= "1" and 0 or 2 ^ (6 - i) or 0
		end

		return ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(total + 1, total + 1)
	end) .. ({ "", "==", "=" })[#value % 3 + 1]
end

function DictRowCnt(items)
	local count2 = 0

	for _, _ in pairs(items) do
		count2 += 1
	end

	return count2
end

local deepCopy

deepCopy = function(items)
	local result = {}

	for k, item in items do
		if type(item) == "table" then
			item = deepCopy(item) or item
		end

		result[k] = item
	end

	return result
end

local buf = buffer.create(3000)
local total = 0
local now = tick()
local v3 = {
	Anchored = 1,
	CanCollide = 1,
	ClassName = 1,
	Axis = 1,
	SecondaryAxis = 1,
	GripPos = 1,
	GripRight = 1,
	GripForward = 1,
	GripUp = 1,
	ClockTime = 1,
	WorldPivot = 1,
	CollisionFidelity = 1,
	AttachmentForward = 1,
	AttachmentRight = 1,
	AttachmentUp = 1,
	AttachmentPos = 1,
	SL_UniqueId = 1
}

function ReplaceXMLbyPropName(value, value2, value3)
	if not value or v3[value2] then
		return value
	end

	local v4

	if value2 == "SL_Anchored" or value2 == "SL_CanCollide" then
		v4 = value2:sub(4)
	elseif value2 == "MeshSize" then
		v4 = "InitialSize"
	elseif value2 == "[TAGS]" then
		v4 = "Tags"
	elseif value2 == "RollOffMinDistance" then
		v4 = "EmitterSize"
	elseif value2 == "MaterialVariant" then
		v4 = "MaterialVariantSerialized"
	elseif value2 == "RollOffMaxDistance" then
		v4 = "xmlRead_MaxDistance_3"
	elseif value2 == "AssemblyAngularVelocity" then
		v4 = "RotVelocity"
	elseif value2 == "AssemblyLinearVelocity" then
		v4 = "Velocity"
	else
		v4 = value2
	end

	local v5 = nil
	local typeName = typeof(value3)

	if typeof(value3) == "boolean" or typeof(value3) == "number" then
		v5 = value3
		value3 = tostring(value3)
	elseif typeof(value3) == "table" then
		v5 = deepCopy(value3)

		if value3.EnumType and value3.Name then
			value3 = tostring(Enum[value3.EnumType][value3.Name].Value)
		elseif value3.X and typeof(value3.X) == "table" and value3.X.Offset and value3.X.Scale and value3.Y and typeof(value3.Y) == "table" and value3.Y.Offset and value3.Y.Scale then
			value3 = "\n" .. "<XS>" .. value3.X.Scale .. "</XS>\n" .. "<XO>" .. value3.X.Offset .. "</XO>\n" .. "<YS>" .. value3.Y.Scale .. "</YS>\n" .. "<YO>" .. value3.Y.Offset .. "</YO>\n"
			typeName = "UDim2"
		elseif value3.Offset and typeof(value3.Offset) ~= "table" and value3.Scale and typeof(value3.Scale) ~= "table" then
			value3 = "\n" .. "<S>" .. value3.Scale .. "</S>\n" .. "<O>" .. value3.Offset .. "</O>\n"
			typeName = "UDim"
		elseif value3.Min and typeof(value3.Min) == "table" and value3.Max and typeof(value3.Max) == "table" and value3.Min.X and value3.Min.Y and value3.Max.X and value3.Max.Y then
			value3 = [[

<Min>
]] .. "<X>" .. value3.Min.X .. "</X>\n" .. "<Y>" .. value3.Min.Y .. "</Y>\n" .. "</Min>\n" .. "<Max>\n" .. "<X>" .. value3.Max.X .. "</X>\n" .. "<Y>" .. value3.Max.Y .. [[
</Y>
</Max>
]]
		elseif value3.Min and typeof(value3.Min) ~= "table" and value3.Max and typeof(value3.Max) ~= "table" then
			value3 = value3.Min .. " " .. value3.Max .. " "
			typeName = "NumberRange"
		elseif value3.R and value3.G and value3.B and value3.Scale then
			value3 = "\n<R>" .. value3.R / 255 .. "</R>\n" .. "<G>" .. value3.G / 255 .. "</G>\n" .. "<B>" .. value3.B / 255 .. "</B>\n"
			typeName = "Color3"
		elseif value3.BrickColor then
			value3 = BrickColor.new(value3.BrickColor).Number
			typeName = "BrickColor"
		elseif v4 == "Tags" and value3[1] then
			local v6 = ""

			for i = 1, #value3 do
				if i > 1 then
					v6 ..= "\0"
				end

				v6 ..= value3[i]
			end

			value3 = to_base64(v6)
		elseif value3["1"] and typeof(value3["1"]) == "table" then
			if value3["1"].R and value3["1"].G and value3["1"].B and value3["1"].Time then
				local v6 = ""
				typeName = "ColorSequence"

				for i = 1, DictRowCnt(value3) do
					v6 ..= value3[tostring(i)].Time .. " " .. value3[tostring(i)].R .. " " .. value3[tostring(i)].G .. " " .. value3[tostring(i)].B .. " 0 "
				end

				value3 = v6
			elseif value3["1"].Time and value3["1"].Value and value3["1"].Envelope then
				local v6 = ""
				typeName = "NumberSequence"

				for i = 1, DictRowCnt(value3) do
					v6 ..= value3[tostring(i)].Time .. " " .. value3[tostring(i)].Value .. " " .. value3[tostring(i)].Envelope .. " "
				end

				value3 = v6
			end
		else
			local v6 = v4 == "CustomPhysicalProperties" and [[

<CustomPhysics>true</CustomPhysics>
]] or "\n"

			if value3.R01 then
				typeName = "CFrame"
			elseif value3.Y1 then
				typeName = "Rect"
			elseif value3.Z then
				typeName = "Vector3"
			elseif value3.Y then
				typeName = "Vector2"
			else
				typeName = typeName
			end

			for k, value4 in pairs(value3) do
				if typeof(value4) == "table" then
					warn("Publish problem.  Property not handled: ", v4, "\nxml:", value, "\nreplaceValue:", value3)
				else
					if typeof(value4) == "string" and (value4:sub(1, 4) == "http" or value4:sub(1, 3) == "rbx") and value4:sub(
						1,
						15
					):find(
						"://",
						1,
						true
					) then
						value4 = "<url>" .. value4:gsub("&", "&amp;") .. "</url>"
					end

					if k:sub(1, 4) == "Font" then
						k = k:sub(5)

						if k == "Weight" then
							value4 = Enum.FontWeight[value4].Value
						end
					end

					v6 ..= "<" .. k .. ">" .. tostring(value4) .. "</" .. k .. ">\n"
				end
			end

			value3 = v6
		end
	elseif typeof(value3) == "string" then
		if (value3:sub(1, 4) == "http" or value3:sub(1, 3) == "rbx") and value3:sub(1, 15):find("://", 1, true) then
			value3 = "<url>" .. value3:gsub("&", "&amp;") .. "</url>"
		elseif value3:sub(1, 9) ~= "<![CDATA[" then
			value3 = value3:gsub("<", "&lt;"):gsub("\"", "&quot;")
		end
	end

	local v6 = value3 or "<null></null>"
	local v7, v8 = value:find("name=\"" .. v4 .. "\">", 1, true)

	if v7 and v8 then
		local v9 = v7 - 2
		local v10 = ""

		while value:sub(v9, v9) ~= "<" do
			v10 = value:sub(v9, v9) .. v10
			v9 -= 1
		end

		local v11, _ = value:find("</" .. v10, v8 + 1, true)

		if v11 then
			value = value:sub(1, v8) .. tostring(v6) .. value:sub(v11)
		else
			warn("Publish: can't find end tag:", v4, v10)
		end
	elseif v4 == "Color" then
		if typeof(v5) == "table" and typeof(v5.R) == "number" and typeof(v5.G) == "number" and typeof(v5.B) == "number" then
			value = ReplaceXMLbyPropName(value, "Color3uint8", Color3uint8Encode(v5.R, v5.G, v5.B))
		else
			warn("Problem with color property:", "Color", v5, typeof(v5), v6, (typeof(v6)))
		end
	elseif v4:sub(-5) == "Color" then
		local success, result = pcall(function()
			return BrickColor.new(v6.BrickColor)
		end)

		if success then
			value = ReplaceXMLbyPropName(
				value,
				v4 .. "3",
				"<R>" .. result.r .. "</R>" .. "<G>" .. result.g .. "</G>" .. "<B>" .. result.b .. "</B>"
			)
		elseif not ("LeftArmColor,RightArmColor,LeftLegColor,RightLegColor,HeadColor,TorsoColor"):find(v4, 1, true) then
			warn("Problem with color... property:", v4)
		end
	elseif v4 == "Heat" or v4 == "Size" then
		value = ReplaceXMLbyPropName(value, v4:lower() .. "_xml", v6)
	elseif v4 == "Value" then
		value = ReplaceXMLbyPropName(value, "value", v6)
	elseif v4 == "Part0" or v4 == "Part1" then
		value = ReplaceXMLbyPropName(value, v4 .. "Internal", v6)
	elseif v4:sub(1, 11) == "SL_Assembly" then
		value = ReplaceXMLbyPropName(value, v4:sub(4), v6)
	elseif v4 ~= "Enabled" and v4 ~= "Archivable" and v4 ~= "Position" and v4 ~= "Rotation" and v4 ~= "RBXRefinementScale" and v4 ~= "RenderFidelity" and v4 ~= "InitialSize" and v4 ~= "DoubleSided" and v4 ~= "IgnoreGuiInset" and v4 ~= "Orientation" then
		if v4 == "Tags" then
			local v9 = value:find("</Properties>", 1, true)

			if v9 then
				value = value:sub(1, v9 - 1) .. "<BinaryString name=\"Tags\">" .. v6 .. "</BinaryString>" .. value:sub(v9)
			else
				warn("Unexpected error adding Tags: Can't find </Properties> for xml", value)
			end
		elseif v5 then
			if typeName == "string" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 2)
				total += 1
				buffer.writeu32(buf, total, #v5)
				total += 4
				buffer.writestring(buf, total, v5)
				total += #v5
			elseif typeName == "number" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 6)
				total += 1
				buffer.writef64(buf, total, (tonumber(v5)))
				total += 8
			elseif typeName == "boolean" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 3)
				total += 1

				if v5 then
					buffer.writeu8(buf, total, 1)
				else
					buffer.writeu8(buf, total, 0)
				end

				total += 1
			elseif typeName == "UDim" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 9)
				total += 1
				buffer.writef32(buf, total, v5.Scale)
				total += 4
				buffer.writei32(buf, total, v5.Offset)
				total += 4
			elseif typeName == "UDim2" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 10)
				total += 1
				buffer.writef32(buf, total, v5.X.Scale)
				total += 4
				buffer.writei32(buf, total, v5.X.Offset)
				total += 4
				buffer.writef32(buf, total, v5.Y.Scale)
				total += 4
				buffer.writei32(buf, total, v5.Y.Offset)
				total += 4
			elseif typeName == "NumberRange" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 27)
				total += 1
				buffer.writef32(buf, total, v5.Min)
				total += 4
				buffer.writef32(buf, total, v5.Max)
				total += 4
			elseif typeName == "Color3" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 15)
				total += 1
				buffer.writef32(buf, total, v5.R)
				total += 4
				buffer.writef32(buf, total, v5.G)
				total += 4
				buffer.writef32(buf, total, v5.B)
				total += 4
			elseif typeName == "BrickColor" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 14)
				total += 1
				buffer.writeu32(buf, total, BrickColor.new(v5.BrickColor).Number)
				total += 4
			elseif typeName == "ColorSequence" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 25)
				total += 1
				local v9 = DictRowCnt(v5)
				buffer.writeu32(buf, total, v9)
				total += 4

				for i = 1, v9 do
					buffer.writef32(buf, total, 0)
					total += 4
					buffer.writef32(buf, total, v5[tostring(i)].Time)
					total += 4
					buffer.writef32(buf, total, v5[tostring(i)].R)
					total += 4
					buffer.writef32(buf, total, v5[tostring(i)].G)
					total += 4
					buffer.writef32(buf, total, v5[tostring(i)].B)
					total += 4
				end
			elseif typeName == "NumberSequence" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 23)
				total += 1
				local v9 = DictRowCnt(v5)
				buffer.writeu32(buf, total, v9)
				total += 4

				for i = 1, v9 do
					buffer.writef32(buf, total, v5[tostring(i)].Envelope)
					total += 4
					buffer.writef32(buf, total, v5[tostring(i)].Time)
					total += 4
					buffer.writef32(buf, total, v5[tostring(i)].Value)
					total += 4
				end
			elseif typeName == "CFrame" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 20)
				total += 1
				buffer.writef32(buf, total, v5.X)
				total += 4
				buffer.writef32(buf, total, v5.Y)
				total += 4
				buffer.writef32(buf, total, v5.Z)
				total += 4
				buffer.writeu8(buf, total, 0)
				total += 1
				buffer.writef32(buf, total, v5.R00)
				total += 4
				buffer.writef32(buf, total, v5.R01)
				total += 4
				buffer.writef32(buf, total, v5.R02)
				total += 4
				buffer.writef32(buf, total, v5.R10)
				total += 4
				buffer.writef32(buf, total, v5.R11)
				total += 4
				buffer.writef32(buf, total, v5.R12)
				total += 4
				buffer.writef32(buf, total, v5.R20)
				total += 4
				buffer.writef32(buf, total, v5.R21)
				total += 4
				buffer.writef32(buf, total, v5.R22)
				total += 4
			elseif typeName == "Rect" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 28)
				total += 1
				buffer.writef32(buf, total, v5.X0)
				total += 4
				buffer.writef32(buf, total, v5.Y0)
				total += 4
				buffer.writef32(buf, total, v5.X1)
				total += 4
				buffer.writef32(buf, total, v5.Y1)
				total += 4
			elseif typeName == "Vector3" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 17)
				total += 1
				buffer.writef32(buf, total, v5.X)
				total += 4
				buffer.writef32(buf, total, v5.Y)
				total += 4
				buffer.writef32(buf, total, v5.Z)
				total += 4
			elseif typeName == "Vector2" then
				buffer.writeu32(buf, 0, buffer.readu32(buf, 0) + 1)
				buffer.writeu32(buf, total, #v4)
				total += 4
				buffer.writestring(buf, total, v4)
				total += #v4
				buffer.writeu8(buf, total, 16)
				total += 1
				buffer.writef32(buf, total, v5.X)
				total += 4
				buffer.writef32(buf, total, v5.Y)
				total += 4
			else
				warn(
					"Publish: Can't find Property or Attribute:",
					v4,
					"Value:",
					v6,
					"oldValue:",
					v5,
					"Type:",
					typeName,
					"Class:",
					value:sub(1, 2000):match("Item class=\"(.-)\""),
					"Name:",
					value:sub(1, 2000):match("<string name=\"Name\">(.-)<")
				)
			end
		end
	end

	return value
end

local v4 = 1
local v5 = ""
local ServerStorage = game:GetService("ServerStorage")
local studioLiteFolder = ServerStorage:WaitForChild("StudioLiteFolder")

function Merge(p, instance, parent)
	if now + 2 < tick() then
		print("Publish Merging", parent.Name)
		task.wait()
		now = tick()
	end

	if instance then
		buffer.writeu32(buf, 0, 0)
		total = 4

		if instance.MeshId and instance.SL_CanCollide then
			if instance.MeshId == "rbxassetid://1155182527" then
				instance.PhysicalConfigData = "1D7D8b2OQKeIlZaCtF26QA=="
				flag3 = true
			elseif instance.MeshId == "rbxassetid://6294822610" then
				instance.PhysicalConfigData = "kQKaxv8mWRIpK+JT72YbkQ=="
				flag2 = true
			elseif instance.MeshId == "rbxassetid://6386254129" then
				instance.PhysicalConfigData = "NzEJpNX4wSzxfnBpqUsM9w=="
				flag = true
			end
		end

		for k, v6 in pairs(instance) do
			if typeof(v6) ~= "table" or not v6.ClassName then
				p = ReplaceXMLbyPropName(p, k, v6)
			end
		end

		if total > 4 then
			if total > 3000 then
				warn("Too many attributes in", instance.Name, instance.ClassName)
			else
				local v6 = "<![CDATA[" .. to_base64(buffer.readstring(buf, 0, total)) .. "]]>"
				p = ReplaceXMLbyPropName(p, "AttributesSerialize", v6)
			end

			total = 0
		end

		v2 = false

		for _, v6 in pairs(instance) do
			if not (typeof(v6) == "table" and v6.ClassName) then
				continue
			end

			if v6.ClassName == "Script" or v6.ClassName == "LocalScript" or v6.ClassName == "ModuleScript" then
				if v6.SLCodeTextBox and v6.SLCodeTextBox.Text then
					v5 = ""

					for _, v7 in ipairs(v6.SLCodeTextBox.Text:split("\n")) do
						local v8 = v7:gsub("</?font.->", ""):gsub("</?b>", ""):gsub("&lt;", "<")
						v5 ..= v8 .. "\n"
					end

					v6.Source = "<![CDATA[" .. v5 .. "]]>"
					v6.SLCodeTextBox = nil
				else
					local v7 = studioLiteFolder.Scripts:FindFirstChild(v6.ClassName .. v6.Name) or studioLiteFolder.Scripts:FindFirstChild("Insert" .. v6.ClassName .. v6.Name)

					if v7 then
						if v6.Disabled ~= nil then
							v6.Disabled = v7.Disabled
						end

						local v8 = studioLiteFolder.ScriptSource:FindFirstChild(v6.ClassName .. v6.Name) or studioLiteFolder.ScriptSource:FindFirstChild("Insert" .. v6.ClassName .. v6.Name)

						if v8 then
							v6.Source = "<![CDATA[" .. v8.Value .. "]]>"
						else
							warn("Publish: can't find source for", v6.ClassName .. v6.Name)
						end
					else
						warn("Publish: can't find script", v6.ClassName .. v6.Name)
					end
				end
			end

			if v6.ClassName == "Folder" and v6.Name == "PackageLink" then
				v6.ClassName = "PackageLink"
				v6.Name = v6.NameValue.Value
				v6.DefaultName = v6.DefaultNameValue.Value or ""
				v6.AutoUpdate = v6.AutoUpdateValue.Value or false
				v6.PackageIdSerialize = v6.PackageIdSerializeValue.Value
				v6.VersionIdSerialize = v6.VersionIdSerializeValue.Value
				v6.NameValue = nil
				v6.DefaultNameValue = nil
				v6.AutoUpdateValue = nil
				v6.PackageIdSerializeValue = nil
				v6.VersionIdSerializeValue = nil
			end

			local v7 = v6
			local success, result = pcall(function()
				local v8 = v[v7.ClassName]

				if not v8 then
					warn("Class: " .. v7.ClassName .. ".  Currently not supported by Studio Lite publishing.")
					return
				end

				local stringValue = Instance.new("StringValue", parent)
				stringValue.Name = v7.Name
				local v9, v10 = v8:find("referent=\"RBX", 1, true)

				if v9 and v10 then
					v8 = v8:sub(1, v10 + 21) .. ("0000" .. v4):sub(-5) .. v8:sub(v10 + 27)
					stringValue.Value = v8:sub(v10 - 2, v10 + 32)
					v4 += 1

					if v7.CFrame then
						local v11 = ""

						for k, v12 in pairs(v7.CFrame) do
							v11 ..= "<" .. k .. ">" .. v12 .. "</" .. k .. ">"
						end

						stringValue.Value ..= v11
					end
				end

				local v11, v12 = v8:find("UniqueId\">", 1, true)

				if v11 and v12 then
					v8 = v8:sub(1, v12 + 21) .. ("0000" .. v4):sub(-5) .. v8:sub(v12 + 27)
					v4 += 1

					if v7.ClassName == "Humanoid" then
						local v13, v14 = v8:find("referent=\"RBX", v12, true)

						if v13 and v14 then
							v8 = v8:sub(1, v14 + 21) .. ("0000" .. v4):sub(-5) .. v8:sub(v14 + 27)
							stringValue.Value = v8:sub(v14 - 2, v14 + 32)
							v4 += 1
						end

						local v15, v16 = v8:find("UniqueId\">", v14, true)

						if v15 and v16 then
							v8 = v8:sub(1, v16 + 21) .. ("0000" .. v4):sub(-5) .. v8:sub(v16 + 27)
							v4 += 1
						end
					end
				end

				p ..= Merge(v8, v7, stringValue)
			end)

			if success then
				continue
			end

			warn("Publish problem with ClassName:", v6.ClassName)
			warn(v6)
			warn(result)
		end
	end

	p ..= "</Item>\n"
	return p
end

function StringToCFrame(value)
	local v6 = tonumber(value:match("<X>(.-)</X>") or 0)
	local v7 = tonumber(value:match("<Y>(.-)</Y>") or 0)
	local v8 = tonumber(value:match("<Z>(.-)</Z>") or 0)
	local v9 = tonumber(value:match("<R00>(.-)</R00>") or 0)
	local v10 = tonumber(value:match("<R01>(.-)</R01>") or 0)
	local v11 = tonumber(value:match("<R02>(.-)</R02>") or 0)
	local v12 = tonumber(value:match("<R10>(.-)</R10>") or 0)
	local v13 = tonumber(value:match("<R11>(.-)</R11>") or 0)
	local v14 = tonumber(value:match("<R12>(.-)</R12>") or 0)
	local v15 = tonumber(value:match("<R20>(.-)</R20>") or 0)
	local v16 = tonumber(value:match("<R21>(.-)</R21>") or 0)
	local v17 = tonumber(value:match("<R22>(.-)</R22>") or 0)
	return CFrame.new(v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17)
end

function UpdateRefs(value, folder)
	local v6 = ""
	local v7 = nil
	local v8 = nil
	local v9 = nil
	local v10 = nil
	local v11 = nil
	local parent = nil
	local parts = value:split("\n")

	for i, part in ipairs(parts) do
		if now + 2 < tick() then
			print("Publish UpdateRef", i)
			task.wait()
			now = tick()
		end

		local v12, v13 = part:find("referent=\"RBX", 1, true)

		if v12 and v13 then
			v6 = part:sub(v13 - 2, v13 + 32)
			v10 = nil
			v11 = nil
		else
			v8 = part:find(">self.", 1, true)

			if v8 then
				v9 = part:find("</Ref>", 1, true)

				if v9 and v8 + 6 < v9 - 1 then
					v7 = part:sub(v8 + 6, v9 - 1)
					parent = nil

					for _, descendant in ipairs(folder:GetDescendants()) do
						if descendant.Value:sub(1, 35) ~= v6 then
							continue
						end

						parent = descendant
						break
					end

					local v15 = i
					local success, result = pcall(function()
						if not parent then
							warn("Publish: ref not found for:", v6, part)
							return
						end

						for i2, v16 in ipairs(v7:split(".")) do
							if v16 == "Parent" then
								parent = parent.Parent
							else
								parent = parent[v16]
							end
						end

						part = part:sub(1, v8) .. parent.Value:sub(1, 35) .. part:sub(v9)

						if part:find("name=\"Part0Internal\"") and #parent.Value > 40 then
							v10 = parent.Value:sub(36)
						end

						if part:find("name=\"Part1Internal\"") and #parent.Value > 40 then
							v11 = parent.Value:sub(36)
						end

						if v10 and v11 then
							local components, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26 = StringToCFrame(v10):toObjectSpace(StringToCFrame(v11)):GetComponents()
							part ..= "\n" .. ([[
<CoordinateFrame name="CFrame0">
	<X>%s</X>
	<Y>%s</Y>
	<Z>%s</Z>
	<R00>%s</R00>
	<R01>%s</R01>
	<R02>%s</R02>
	<R10>%s</R10>
	<R11>%s</R11>
	<R12>%s</R12>
	<R20>%s</R20>
	<R21>%s</R21>
	<R22>%s</R22>
	</CoordinateFrame>]]):format(components, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26)
						end

						parts[v15] = part
					end)

					if not success then
						warn(
							"Problem with WeldConstraint. Part0 or Part1 referent not found:",
							result,
							part,
							v10,
							v11,
							v7,
							parent
						)
					end
				end
			end
		end
	end

	return table.concat(parts, "\n")
end

local v6 = {
	Accept = "*/*"
}
local count2 = 0

function PublishModule.Publish(_, data, p, value, p2, p3, p4)
	local v7 = game.Players:GetPlayers()[1]
	count2 += 1

	if count2 > 40 then
		v7:Kick("Too many Publish requests.")
		return
	end

	local warningText = v7:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("WarningText")
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "ref"
	print("Publish Started...")

	if data.StarterPlayer then
		data.StarterPlayer.ClassName = "StarterPlayer"

		if data.StarterPlayer.StarterPlayerScripts then
			data.StarterPlayer.StarterPlayerScripts.ClassName = "StarterPlayerScripts"
		else
			data.StarterPlayer.StarterPlayerScripts = {
				ClassName = "StarterPlayerScripts",
				Name = "StarterPlayerScripts"
			}
		end

		if data.StarterPlayer.StarterCharacterScripts then
			data.StarterPlayer.StarterCharacterScripts.ClassName = "StarterCharacterScripts"
		else
			data.StarterPlayer.StarterCharacterScripts = {
				ClassName = "StarterCharacterScripts",
				Name = "StarterCharacterScripts"
			}
		end

		if not data.StarterPlayer.StarterCharacterScripts.ClientActionEventLocal then
			data.StarterPlayer.StarterCharacterScripts.ClientActionEventLocal = {
				ClassName = "LocalScript",
				Name = "ClientActionEventLocal"
			}
		end
	else
		error("Publish: Seem to be missing StarterPlayer in the convertedTable.")
	end

	if data.Lighting and data.Lighting.SL_Technology then
		if data.Lighting.SL_Technology.EnumType and data.Lighting.SL_Technology.Name then
			pcall(function()
				data.Lighting.Technology = Enum[data.Lighting.SL_Technology.EnumType][data.Lighting.SL_Technology.Name].Value
			end)
		end

		data.Lighting.SL_Technology = nil
	end

	print("Publish Merging...")
	local stringValue2 = Instance.new("StringValue", stringValue)
	stringValue2.Name = "Workspace"
	local v8 = Merge([=[
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
<External>null</External>
<External>nil</External>
<Item class="Workspace" referent="RBXFCD357AE07894BD3BF083012B8272692">
<Properties>
<float name="AirDensity">0.00120000006</float>
<bool name="AllowThirdPartySales">true</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="AvatarUnificationMode">0</token>
<token name="CSGAsyncDynamicCollision">0</token>
<token name="ClientAnimatorThrottling">0</token>
<BinaryString name="CollisionGroupData">AQEABP////8HRGVmYXVsdA==</BinaryString>
<Ref name="CurrentCamera">RBX614D6A37BC974570ACC081996E0F4020</Ref>
<double name="DistributedGameTime">0</double>
<bool name="ExplicitAutoJoints">true</bool>
<float name="FallenPartsDestroyHeight">-500</float>
<token name="FluidForces">0</token>
<Vector3 name="GlobalWind">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="Gravity">196.199997</float>
<token name="IKControlConstraintSupport">0</token>
<token name="LevelOfDetail">0</token>
<token name="MeshPartHeadsAndAccessories">0</token>
<CoordinateFrame name="ModelMeshCFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<SharedString name="ModelMeshData">yuZpQdnvvUBOTYh1jqZ2cA==</SharedString>
<Vector3 name="ModelMeshSize">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<token name="ModelStreamingBehavior">0</token>
<token name="ModelStreamingMode">0</token>
<token name="MoverConstraintRootBehavior">0</token>
<string name="Name">Workspace</string>
<bool name="NeedsPivotMigration">false</bool>
<token name="PhysicsSteppingMethod">0</token>
<token name="PlayerCharacterDestroyBehavior">0</token>
<token name="PrimalPhysicsSolver">0</token>
<Ref name="PrimaryPart">null</Ref>
<token name="RejectCharacterDeletions">0</token>
<token name="RenderingCacheOptimizations">0</token>
<token name="ReplicateInstanceDestroySetting">0</token>
<token name="Retargeting">0</token>
<float name="ScaleFactor">1</float>
<token name="SignalBehavior2">1</token>
<token name="StreamOutBehavior">2</token>
<bool name="StreamingEnabled">false</bool>
<bool name="TerrainWeldsFixed">true</bool>
<bool name="TouchesUseCollisionGroups">false</bool>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000002</UniqueId>
<OptionalCoordinateFrame name="WorldPivotData">
<CFrame>
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CFrame>
</OptionalCoordinateFrame>
</Properties>
<Item class="Camera" referent="RBX614D6A37BC974570ACC081996E0F4020">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<CoordinateFrame name="CFrame">
<X>-1.35072446</X>
<Y>16.1335068</Y>
<Z>22.6204529</Z>
<R00>0.998806357</R00>
<R01>0.0246140603</R01>
<R02>-0.042189464</R02>
<R10>1.86264493e-09</R10>
<R11>0.863747299</R11>
<R12>0.503925145</R12>
<R20>0.0488446802</R20>
<R21>-0.503323615</R21>
<R22>0.862716377</R22>
</CoordinateFrame>
<Ref name="CameraSubject">null</Ref>
<token name="CameraType">0</token>
<float name="FieldOfView">70</float>
<token name="FieldOfViewMode">0</token>
<CoordinateFrame name="Focus">
<X>0</X>
<Y>0</Y>
<Z>-5</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="HeadLocked">true</bool>
<float name="HeadScale">1</float>
<string name="Name">Camera</string>
<UniqueId name="UniqueId">179a555039d7b72a0689fc7c000042ab</UniqueId>
<bool name="VRTiltAndRollEnabled">false</bool>
</Properties>
</Item>
<Item class="Terrain" referent="RBX9D2A78EBB0A4463FB86AE3F8A0B4D7B9">
<Properties>
<token name="AcquisitionMethod">0</token>
<bool name="Anchored">true</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BackSurface">0</token>
<token name="BackSurfaceInput">0</token>
<float name="BottomParamA">-0.5</float>
<float name="BottomParamB">0.5</float>
<token name="BottomSurface">4</token>
<token name="BottomSurfaceInput">0</token>
<CoordinateFrame name="CFrame">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<bool name="CanCollide">true</bool>
<bool name="CanQuery">true</bool>
<bool name="CanTouch">true</bool>
<bool name="CastShadow">true</bool>
<string name="CollisionGroup">Default</string>
<int name="CollisionGroupId">0</int>
<Color3uint8 name="Color3uint8">4288914085</Color3uint8>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>false</CustomPhysics>
</PhysicalProperties>
<bool name="Decoration">true</bool>
<bool name="EnableFluidForces">true</bool>
<float name="FrontParamA">-0.5</float>
<float name="FrontParamB">0.5</float>
<token name="FrontSurface">0</token>
<token name="FrontSurfaceInput">0</token>
<float name="GrassLength">0.699999988</float>
<float name="LeftParamA">-0.5</float>
<float name="LeftParamB">0.5</float>
<token name="LeftSurface">0</token>
<token name="LeftSurfaceInput">0</token>
<bool name="Locked">true</bool>
<bool name="Massless">false</bool>
<token name="Material">256</token>
<BinaryString name="MaterialColors"><![CDATA[AAAAAAAAb34+WFlWmJiYimFJz8unrJRsY2Rm3eTl6/3/lHxfeXBiS0pKjIJo/xhDUFRUhoZ2
zNLfaoZA///+//PAj5CH]]></BinaryString>
<string name="MaterialVariantSerialized"></string>
<string name="Name">Terrain</string>
<BinaryString name="PhysicsGrid">AgMAAAAAAAAAAAAAAAA=</BinaryString>
<CoordinateFrame name="PivotOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
<R00>1</R00>
<R01>0</R01>
<R02>0</R02>
<R10>0</R10>
<R11>1</R11>
<R12>0</R12>
<R20>0</R20>
<R21>0</R21>
<R22>1</R22>
</CoordinateFrame>
<float name="Reflectance">0</float>
<float name="RightParamA">-0.5</float>
<float name="RightParamB">0.5</float>
<token name="RightSurface">0</token>
<token name="RightSurfaceInput">0</token>
<int name="RootPriority">0</int>
<Vector3 name="RotVelocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<bool name="ShorelinesUpgraded">true</bool>
<BinaryString name="SmoothGrid">AQU=</BinaryString>
<bool name="SmoothVoxelsUpgraded">false</bool>
<float name="TopParamA">-0.5</float>
<float name="TopParamB">0.5</float>
<token name="TopSurface">3</token>
<token name="TopSurfaceInput">0</token>
<float name="Transparency">0</float>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000036b</UniqueId>
<Vector3 name="Velocity">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<Color3 name="WaterColor">
<R>0.0470588282</R>
<G>0.329411775</G>
<B>0.360784322</B>
</Color3>
<float name="WaterReflectance">1</float>
<float name="WaterTransparency">0.300000012</float>
<float name="WaterWaveSize">0.150000006</float>
<float name="WaterWaveSpeed">10</float>
<Vector3 name="Size">
<X>2044</X>
<Y>252</Y>
<Z>2044</Z>
</Vector3>
</Properties>
</Item>
]=], data.Workspace, stringValue2) .. [[
<Item class="SoundService" referent="RBX098BBF28B9104CD482CCB1474A4AC90A">
<Properties>
<token name="AmbientReverb">0</token>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="DistanceFactor">3.32999992</float>
<float name="DopplerScale">1</float>
<string name="Name">SoundService</string>
<bool name="RespectFilteringEnabled">true</bool>
<float name="RolloffScale">1</float>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000300</UniqueId>
<token name="VolumetricAudio">1</token>
</Properties>
</Item>
<Item class="VideoCaptureService" referent="RBXA894F26FB0774D42A23F9E466C338A06">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">VideoCaptureService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000301</UniqueId>
</Properties>
</Item>
<Item class="NonReplicatedCSGDictionaryService" referent="RBX46D33373B9CB4223B5F6B1BC363D3F77">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">NonReplicatedCSGDictionaryService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000302</UniqueId>
</Properties>
</Item>
<Item class="CSGDictionaryService" referent="RBX7094A41BDA6246DE9373840D228D8D95">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">CSGDictionaryService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000303</UniqueId>
</Properties>
</Item>
<Item class="Chat" referent="RBXFDE40B931980414B8B3A62FACC9C1BB8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="BubbleChatEnabled">true</bool>
<bool name="LoadDefaultChat">true</bool>
<string name="Name">Chat</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000308</UniqueId>
</Properties>
</Item>
<Item class="TimerService" referent="RBX1AC99373E1B74511940A0B2EC90E7DB4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Instance</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000309</UniqueId>
</Properties>
</Item>
<Item class="Players" referent="RBXB3F5E2CB54DA4FFD822D92AD3C197B5A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="CharacterAutoLoads">true</bool>
<int name="MaxPlayersInternal">30</int>
<string name="Name">Players</string>
<int name="PreferredPlayersInternal">30</int>
<float name="RespawnTime">3</float>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000030b</UniqueId>
<bool name="UseStrafingAnimations">false</bool>
</Properties>
</Item>
]]
	local stringValue3 = Instance.new("StringValue", stringValue)
	stringValue3.Name = "ReplicateFirst"
	local v9 = (v8 .. Merge([[
<Item class="ReplicatedFirst" referent="RBX1F03D069C1C9423DB605B7FAFE3BD221">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">ReplicatedFirst</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000030e</UniqueId>
</Properties>
]], data.ReplicateFirst, stringValue3)) .. [[
<Item class="TweenService" referent="RBX7E70093321FC42B19948D346C7D5FA7A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">TweenService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000310</UniqueId>
</Properties>
</Item>
<Item class="MaterialService" referent="RBXD6D109F0734B411CBFB64C2FACA149C4">
<Properties>
<string name="AsphaltName">Asphalt</string>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="BasaltName">Basalt</string>
<string name="BrickName">Brick</string>
<string name="CardboardName">Cardboard</string>
<string name="CarpetName">Carpet</string>
<string name="CeramicTilesName">CeramicTiles</string>
<string name="ClayRoofTilesName">ClayRoofTiles</string>
<string name="CobblestoneName">Cobblestone</string>
<string name="ConcreteName">Concrete</string>
<string name="CorrodedMetalName">CorrodedMetal</string>
<string name="CrackedLavaName">CrackedLava</string>
<string name="DiamondPlateName">DiamondPlate</string>
<string name="FabricName">Fabric</string>
<string name="FoilName">Foil</string>
<string name="GlacierName">Glacier</string>
<string name="GraniteName">Granite</string>
<string name="GrassName">Grass</string>
<string name="GroundName">Ground</string>
<string name="IceName">Ice</string>
<string name="LeafyGrassName">LeafyGrass</string>
<string name="LeatherName">Leather</string>
<string name="LimestoneName">Limestone</string>
<string name="MarbleName">Marble</string>
<string name="MetalName">Metal</string>
<string name="MudName">Mud</string>
<string name="Name">MaterialService</string>
<string name="PavementName">Pavement</string>
<string name="PebbleName">Pebble</string>
<string name="PlasterName">Plaster</string>
<string name="PlasticName">Plastic</string>
<string name="RockName">Rock</string>
<string name="RoofShinglesName">RoofShingles</string>
<string name="RubberName">Rubber</string>
<string name="SaltName">Salt</string>
<string name="SandName">Sand</string>
<string name="SandstoneName">Sandstone</string>
<string name="SlateName">Slate</string>
<string name="SmoothPlasticName">SmoothPlastic</string>
<string name="SnowName">Snow</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000311</UniqueId>
<bool name="Use2022MaterialsXml">true</bool>
<string name="WoodName">Wood</string>
<string name="WoodPlanksName">WoodPlanks</string>
</Properties>
<Item class="MaterialVariant" referent="RBXC11242A9DB0641ECAFC610B93141511D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440501706</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor1</string>
<Content name="NormalMap"><url>rbxassetid://8440501578</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440501391</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184690047</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005873</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA1F58104B7544E7FB34BF007A256C96C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440500676</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor10</string>
<Content name="NormalMap"><url>rbxassetid://8440500543</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440500432</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184759918</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005874</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX49315744A7B74A4FA4BA83053B5BD9D7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8444060163</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor11</string>
<Content name="NormalMap"><url>rbxassetid://8444060163</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444061570</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184763193</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005875</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX14D2951B950647858C13EFC0F2BE253B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440502370</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor12</string>
<Content name="NormalMap"><url>rbxassetid://8440502169</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440501963</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184765975</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005876</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX541AD02ADDDC41B3950DDD17BB1D9F3C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://4901790362</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://4901817167</url></Content>
<string name="Name">Floor13</string>
<Content name="NormalMap"><url>rbxassetid://4901792281</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://4901793145</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184768707</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005877</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX7826C55063824BFAAEB41E50C066D544">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440790483</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor14</string>
<Content name="NormalMap"><url>rbxassetid://8440790876</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440791131</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122883540</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005878</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXDAD0A75F727341F7AD85735617196EC4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://6223040349</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor15</string>
<Content name="NormalMap"><url>rbxassetid://6223040083</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6223039857</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184773400</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005879</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB5AD5B0EC770458787393212EE363011">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440322667</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor16</string>
<Content name="NormalMap"><url>rbxassetid://8440322891</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440322399</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122907431</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000587a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFB14328A7ACA4B35932CD6FF4C8F7C6A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440321507</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor17</string>
<Content name="NormalMap"><url>rbxassetid://8440321903</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440321602</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184777950</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000587b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5869CCD7DE804F1AA8153FC6FDE3712B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://7970865610</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor18</string>
<Content name="NormalMap"><url>rbxassetid://7970866459</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7970866952</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629114772</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000587c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX922272BC2018485590BC1F50C51B6155">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8036370413</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor19</string>
<Content name="NormalMap"><url>rbxassetid://8036371382</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8036372846</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629088555</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000587d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX520346FA0DE245E4B7A916CF2FEB77CD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440501062</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor2</string>
<Content name="NormalMap"><url>rbxassetid://8440500942</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440500809</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184701977</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000587e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA6FEBA2B696F4EB48EDA07956E232582">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8444067891</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor20</string>
<Content name="NormalMap"><url>rbxassetid://8444068356</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444068643</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122935483</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000587f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX7233E9C69F7E457B946C9328BF713E0B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440321290</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor21</string>
<Content name="NormalMap"><url>rbxassetid://8440321402</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440321136</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184797453</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005880</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA45E3E5442C9407CACCD043E04713822">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://6019996602</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor22</string>
<Content name="NormalMap"><url>rbxassetid://6019997327</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6019997936</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122769550</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005881</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD0792394182144898E163B7760DE1C5B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://7978658009</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor23</string>
<Content name="NormalMap"><url>rbxassetid://7978659424</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7978660388</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184801356</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005882</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5CF03FDB82F34557863BB34AD5EAB128">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440791539</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor24</string>
<Content name="NormalMap"><url>rbxassetid://8440791880</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440792151</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629102021</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005883</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX12B5A64BE4274964A7A69D75429351FD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://6034957066</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor25</string>
<Content name="NormalMap"><url>rbxassetid://6034957332</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6034957504</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184835092</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005884</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB42898D38EBE479CA003B2CD60185AFC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440323373</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor26</string>
<Content name="NormalMap"><url>rbxassetid://8440323474</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440323149</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122793406</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005885</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE3442FFF767442F887E2BD575581833F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://6223152253</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor27</string>
<Content name="NormalMap"><url>rbxassetid://6223151950</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6223151647</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122841898</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005886</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX92EE7CFF7FD94BA7A14ECFC00F7BFFA4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440502993</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor28</string>
<Content name="NormalMap"><url>rbxassetid://8440502766</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440502530</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10402863901</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005887</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5FC0AEF39668448980827B5E55E3A92E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8444089143</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor29</string>
<Content name="NormalMap"><url>rbxassetid://8444090045</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444090500</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185002175</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005888</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX49ADBEAE61554EC683570DEFE768E06B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://7892453314</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor3</string>
<Content name="NormalMap"><url>rbxassetid://7892455279</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7892457391</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184706173</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005889</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXDE0A3563C5054804842DD8AEB79B0A0E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8444079627</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor4</string>
<Content name="NormalMap"><url>rbxassetid://8444080711</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444081086</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122863729</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000588a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX768C2D96B60D4143A1E93F659B7661B4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440509825</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor5</string>
<Content name="NormalMap"><url>rbxassetid://8440509603</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440509286</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184721697</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000588b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX12AEAF43BF18435ABDCD63653CE88AED">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440784141</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor6</string>
<Content name="NormalMap"><url>rbxassetid://8440784827</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440785237</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184725550</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000588c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8FC7D607FEAD418E8106B843D7B845FA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://6094667563</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor7</string>
<Content name="NormalMap"><url>rbxassetid://6094667491</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6094669735</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184727851</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000588d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX585B279597564E7F9A5E6F8E1572098F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440796907</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor8</string>
<Content name="NormalMap"><url>rbxassetid://8440797445</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440797748</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629154513</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000588e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2D293F8980E9479B8F0278E9630930D6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440510667</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Floor9</string>
<Content name="NormalMap"><url>rbxassetid://8440510344</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440510030</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14184737145</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000588f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX0B627C8EE8194C3D9D5CB2F31F34CF34">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://7970865610</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Tile 4</string>
<Content name="NormalMap"><url>rbxassetid://7970866459</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7970866952</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">8</float>
<Content name="TexturePack"><url>rbxassetid://10629114772</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005890</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX67538F9816A345D79A0B98B783CA2C62">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://9596619368</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://9596629019</url></Content>
<string name="Name">Tile 7</string>
<Content name="NormalMap"><url>rbxassetid://9596619324</url></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">6</float>
<Content name="TexturePack"><url>rbxassetid://11137491544</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005891</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX11BBEAB726E342C8A4DAD517C6CE54EE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://9596589104</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://9596604614</url></Content>
<string name="Name">Tile 6</string>
<Content name="NormalMap"><url>rbxassetid://9596589113</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://9596606710</url></Content>
<float name="StudsPerTile">8</float>
<Content name="TexturePack"><url>rbxassetid://11137491488</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005892</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX38E88F48CB704FEF9E9D992451729F6A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://10536140030</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Tile 5</string>
<Content name="NormalMap"><url>rbxassetid://10536140203</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://10536140124</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10536140289</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005893</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5E855F17644341C7A71362A51D36F6FD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://10536172734</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://10536172474</url></Content>
<string name="Name">Tile 2</string>
<Content name="NormalMap"><url>rbxassetid://10536172860</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://10536172745</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">8</float>
<Content name="TexturePack"><url>rbxassetid://10536172964</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005894</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8DCA1878387E49EDAE383E925DCC863F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8036370413</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Tile 3</string>
<Content name="NormalMap"><url>rbxassetid://8036371382</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8036372846</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629088555</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005895</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXF2A4CF5C92A3413F956AFE5BE2C56008">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8444067891</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Tile 1</string>
<Content name="NormalMap"><url>rbxassetid://8444068356</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444068643</url></Content>
<float name="StudsPerTile">7</float>
<Content name="TexturePack"><url>rbxassetid://11122935483</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005896</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA929837E29B54E65BA1AB1AD15ECA16C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440782577</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground1</string>
<Content name="NormalMap"><url>rbxassetid://8440783206</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440783582</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185065518</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005898</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD1AA5AD6C96E4F63AF08FA556EC8058B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440800154</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground10</string>
<Content name="NormalMap"><url>rbxassetid://8440800518</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440800723</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185126694</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005899</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA08B445AD63B437EAD85BB6CE619BC22">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440801012</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground11</string>
<Content name="NormalMap"><url>rbxassetid://8440801277</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440801485</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185128010</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000589a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX153A6214CF2449DB8E331E57107002CB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://6223015459</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground12</string>
<Content name="NormalMap"><url>rbxassetid://6223015006</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6223014644</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185129636</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000589b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX697F26BA0CC54352B2AD890297F583C6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444041435</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground13</string>
<Content name="NormalMap"><url>rbxassetid://8444042294</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444042783</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10770612901</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000589c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXBC2BCA253721446E814B66A405103504">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444110739</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground14</string>
<Content name="NormalMap"><url>rbxassetid://8444111691</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444112210</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122971627</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000589d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA8494362B0EB49A780B250CEF7F70F6C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440326451</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground15</string>
<Content name="NormalMap"><url>rbxassetid://8440326687</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440326313</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122955920</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000589e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB15A83B667A64D79AD8837F11AD3B778">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8276284513</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground16</string>
<Content name="NormalMap"><url>rbxassetid://8276285478</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8276286146</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185208039</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000589f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX884CFF22531F4FDAB2BFC9D603350B82">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444104569</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground17</string>
<Content name="NormalMap"><url>rbxassetid://8444105031</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444105274</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185212529</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a0</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX418F8066B4D74A4AAE7F3E4256E30EB4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440776741</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground18</string>
<Content name="NormalMap"><url>rbxassetid://8440777013</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440777258</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185214782</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a1</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX147C6856B1D34621A837868CC25951F9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://6702773208</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground19</string>
<Content name="NormalMap"><url>rbxassetid://6702774774</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702776037</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185215981</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a2</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA6F8534D07CC4FADB74D6830C8DF336B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444098439</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground2</string>
<Content name="NormalMap"><url>rbxassetid://8444099022</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444099549</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185069669</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a3</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX75FCB58DAB1C4563955125266E8681E8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440795859</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground20</string>
<Content name="NormalMap"><url>rbxassetid://8440796214</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440796488</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122962676</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a4</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXDEF3B0840FB94B4BB6F85AF6EC1252C7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440801802</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground21</string>
<Content name="NormalMap"><url>rbxassetid://8440802088</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440802277</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185219530</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a5</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX4E238594860B407B961CBE238FA113DA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://6125529088</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground22</string>
<Content name="NormalMap"><url>rbxassetid://6125528997</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6125528936</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122985156</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a6</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX3DBAF1C1D55D4641B7B1D58E82D727E1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440793918</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground23</string>
<Content name="NormalMap"><url>rbxassetid://8440794290</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440794544</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185227315</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a7</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8E74C60C4CF94315A5B76B275BC275BD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440789410</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground24</string>
<Content name="NormalMap"><url>rbxassetid://8440789795</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440790084</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11110371753</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a8</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX640AC971C38C4B379973991D93453DBF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444086918</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground25</string>
<Content name="NormalMap"><url>rbxassetid://8444087646</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444087924</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185231028</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058a9</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFC4E6BDD957B4EC1AB039F9ACA696FC6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444091032</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground26</string>
<Content name="NormalMap"><url>rbxassetid://8444091514</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444091876</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185232151</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058aa</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8D2AA9027DE244E4B5A6314140E13127">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444032256</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground27</string>
<Content name="NormalMap"><url>rbxassetid://8444033062</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444033404</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185233345</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ab</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXAD1809B9195249068ED95F6704A2F1D1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444043309</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground28</string>
<Content name="NormalMap"><url>rbxassetid://8444043826</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444044210</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185234636</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ac</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX7B15FD5E65064E73B3A4F4437AA321CE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444094537</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground29</string>
<Content name="NormalMap"><url>rbxassetid://8444095407</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444095886</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185235945</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ad</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXC785ADBA8021482C947DCB04C62DA895">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444075656</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground3</string>
<Content name="NormalMap"><url>rbxassetid://8444076097</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444076316</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185071234</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ae</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8528D975848845D4817D042F1DD53257">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444105621</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground4</string>
<Content name="NormalMap"><url>rbxassetid://8444106160</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444106479</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185073128</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058af</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX83BCB1C71A744DE29F1A2E300EA313AB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444050239</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground5</string>
<Content name="NormalMap"><url>rbxassetid://8444050847</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444051239</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185075258</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058b0</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA53F2183B5C943CF95AE649AA49DB243">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444120979</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground6</string>
<Content name="NormalMap"><url>rbxassetid://8444121762</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444122130</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185077333</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058b1</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9E17DA3BCEC54B92ABC53CECE63A66D5">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444048545</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground7</string>
<Content name="NormalMap"><url>rbxassetid://8444049442</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444049839</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185081894</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058b2</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXF196400D230B4A37866427F2A84BD898">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440798069</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground8</string>
<Content name="NormalMap"><url>rbxassetid://8440798555</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440798784</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122948554</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058b3</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXED7C7FEBAFBA4A0BAA9A7648E1A66005">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8444096600</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground9</string>
<Content name="NormalMap"><url>rbxassetid://8444097367</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444097871</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11110371751</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058b4</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX13AD65CC6C9F44B28492F4516336A90F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8435172990</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8435174527</url></Content>
<string name="Name">Metal1</string>
<Content name="NormalMap"><url>rbxassetid://8435176238</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8435178029</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185441917</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058b6</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX4FB3CB44402E43BEABB571A10EB62A4C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6693428090</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6693429545</url></Content>
<string name="Name">Metal2</string>
<Content name="NormalMap"><url>rbxassetid://6693430836</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6693431844</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185444157</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058b7</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX3CBC74DC0A2C4EB5BCE3DC2530FB3263">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://4544826467</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://4544824902</url></Content>
<string name="Name">Metal3</string>
<Content name="NormalMap"><url>rbxassetid://4544824384</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://4544823523</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10402864126</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058b8</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE872F780E20247FDBA7987AB36FF2FC1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8440328338</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440327710</url></Content>
<string name="Name">Metal4</string>
<Content name="NormalMap"><url>rbxassetid://8440328073</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440327889</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185447405</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058b9</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX7BE66121854142628A0F03A15902D26F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8440332015</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440331215</url></Content>
<string name="Name">Metal5</string>
<Content name="NormalMap"><url>rbxassetid://8440331638</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440331404</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629875171</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ba</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXC12F87EA15CA4E518AA4DD83341EEBAE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6693492221</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6693493120</url></Content>
<string name="Name">Metal6</string>
<Content name="NormalMap"><url>rbxassetid://6693494258</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6693495892</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185453610</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058bb</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXF2AB919D821E472B8761BFAA841836DC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6702316776</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6702317942</url></Content>
<string name="Name">Metal7</string>
<Content name="NormalMap"><url>rbxassetid://6702319027</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702320096</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185462105</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058bc</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXC0B1B87968D348C19E233C01AE926902">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://4544925326</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://4544925130</url></Content>
<string name="Name">Metal8</string>
<Content name="NormalMap"><url>rbxassetid://4544924862</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://4544924465</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185464059</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058bd</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE4DE47E201954E09A1E7F753F5D4C98D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6693445435</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6693446399</url></Content>
<string name="Name">Metal9</string>
<Content name="NormalMap"><url>rbxassetid://6693447544</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6693448679</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10402864340</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058be</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX58A704F85708420EA3138C4E7BF93DCD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6223130583</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6223130186</url></Content>
<string name="Name">Metal10</string>
<Content name="NormalMap"><url>rbxassetid://6223129977</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6223129551</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10402864112</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058bf</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX124DB57CEF20412AA5F3F2DE30D15DC6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6222858138</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6222857522</url></Content>
<string name="Name">Metal30</string>
<Content name="NormalMap"><url>rbxassetid://6222857522</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6222857093</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185495090</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c0</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXDF4BD011A84740FBB01732B089E40E99">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8440512403</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440512147</url></Content>
<string name="Name">Metal12</string>
<Content name="NormalMap"><url>rbxassetid://8440511995</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440511774</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629516800</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c1</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD0C1ECBB757F4D08B388E1142F9E5AB2">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://7892739437</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://7892746877</url></Content>
<string name="Name">Metal13</string>
<Content name="NormalMap"><url>rbxassetid://7892740848</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7892743394</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185470992</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c2</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX212B4472E6464813ABB15AD454CE8621">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8444100536</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8444101108</url></Content>
<string name="Name">Metal14</string>
<Content name="NormalMap"><url>rbxassetid://8444101959</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444102271</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11123092492</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c3</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE3AD0079FA874F0499869310292C6093">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6702347391</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6702348610</url></Content>
<string name="Name">Metal15</string>
<Content name="NormalMap"><url>rbxassetid://6702348965</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702349433</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185473529</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c4</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX4D82025CDAF2423AB158E62D0040574F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://5324314653</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://5324314822</url></Content>
<string name="Name">Metal16</string>
<Content name="NormalMap"><url>rbxassetid://5324315242</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5324315546</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629891858</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c5</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX40BB0F8CCB544CE289D93ECB3FE75C5D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8440512986</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440512857</url></Content>
<string name="Name">Metal17</string>
<Content name="NormalMap"><url>rbxassetid://8440512724</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440512561</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185476509</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c6</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2B7457615DAD488AA34031D3EAA9C2A8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6702308151</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6702308928</url></Content>
<string name="Name">Metal29</string>
<Content name="NormalMap"><url>rbxassetid://6702310117</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702311154</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629881209</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c7</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX34B4B0AA0E03470190F444A1EF552910">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8440323773</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440323607</url></Content>
<string name="Name">Metal19</string>
<Content name="NormalMap"><url>rbxassetid://8440323952</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440324123</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185479404</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c8</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFDE94D4C907D4BF789CFA30CD0D060BB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://5489087715</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Metal20</string>
<Content name="NormalMap"><url>rbxassetid://5489088420</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6102603539</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11123061872</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058c9</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFEE777024042448FAC1B0B66BDFC89BF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://7892762863</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://7892765047</url></Content>
<string name="Name">Metal21</string>
<Content name="NormalMap"><url>rbxassetid://7892767044</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7892768980</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185481847</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ca</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX0C3CA9D0FF4F46C585C4879AA3EEF41A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://7892589680</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://7892591239</url></Content>
<string name="Name">Metal22</string>
<Content name="NormalMap"><url>rbxassetid://7892593866</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7892594890</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185483271</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058cb</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX46CC9FD00D7C453EA9DB0C25582B032B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://7892704568</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://7892715299</url></Content>
<string name="Name">Metal23</string>
<Content name="NormalMap"><url>rbxassetid://7892719275</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7892721501</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185485153</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058cc</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFADFAD46FE694214AB610AE7E2CBE8EC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8439857410</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8439861794</url></Content>
<string name="Name">Metal24</string>
<Content name="NormalMap"><url>rbxassetid://8439860739</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8439862754</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10402864122</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058cd</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX49CF56B5E654471CAEF29059DB6D5DDE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8439880469</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8439882322</url></Content>
<string name="Name">Metal25</string>
<Content name="NormalMap"><url>rbxassetid://8439889406</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8439890845</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185488087</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ce</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX551085A9E1E7485E8A9220E7541687E3">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8440327114</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440326914</url></Content>
<string name="Name">Metal26</string>
<Content name="NormalMap"><url>rbxassetid://8440327523</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440327311</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11123044826</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058cf</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX45BFF347730D4AF3BB8857A3AC5DD948">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8019559199</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8019560428</url></Content>
<string name="Name">Metal27</string>
<Content name="NormalMap"><url>rbxassetid://8019561253</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8019562232</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185491035</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058d0</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX47BC78E5E2C04C3B99650E6A1F69A936">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6702328360</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6702328966</url></Content>
<string name="Name">Metal28</string>
<Content name="NormalMap"><url>rbxassetid://6702330224</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702333119</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185492372</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058d1</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB669A774AB294882AAAA07B7209919D2">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://5324314653</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://5324314822</url></Content>
<string name="Name">Metal 1</string>
<Content name="NormalMap"><url>rbxassetid://5324315242</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5324315546</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629891858</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058d2</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFBA942ED5C83430F967DDA8C69DF56D6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://4544954463</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://4544953655</url></Content>
<string name="Name">Metal 2</string>
<Content name="NormalMap"><url>rbxassetid://4544953387</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://4544953003</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629885319</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058d3</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX83FB5B97C20A41B0B9666F794EE8518E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8035492489</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8035493638</url></Content>
<string name="Name">Metal 3</string>
<Content name="NormalMap"><url>rbxassetid://8035495344</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8035496869</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10632246481</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058d4</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2934218B81014519B3407F7C99CDDB48">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6693445435</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><url>rbxassetid://6693446399</url></Content>
<string name="Name">Metal 4</string>
<Content name="NormalMap"><url>rbxassetid://6693447544</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6693448679</url></Content>
<float name="StudsPerTile">6</float>
<Content name="TexturePack"><url>rbxassetid://10402864340</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058d5</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXCD7EC8B8CE734693B9F39BF3F6C6FD0C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><null></null></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8105626593</url></Content>
<string name="Name">Metal 5</string>
<Content name="NormalMap"><url>rbxassetid://8105626255</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8105625687</url></Content>
<float name="StudsPerTile">10.5</float>
<Content name="TexturePack"><url>rbxassetid://11110371702</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058d6</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX99FD45701FBC429AA9B177C7CDCEC762">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://8035492489</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><url>rbxassetid://8035493638</url></Content>
<string name="Name">Metal 7</string>
<Content name="NormalMap"><url>rbxassetid://8035495344</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8035496869</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10632246481</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058d7</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXEFAF83DF4C0C4567934C309326213C27">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1088</token>
<Content name="ColorMap"><url>rbxassetid://6702308151</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><url>rbxassetid://6702308928</url></Content>
<string name="Name">Metal 8</string>
<Content name="NormalMap"><url>rbxassetid://6702310117</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702311154</url></Content>
<float name="StudsPerTile">6</float>
<Content name="TexturePack"><url>rbxassetid://10629881209</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058d8</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA33161AA2A6E4070AF2253A89B201E82">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474554323</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized1</string>
<Content name="NormalMap"><url>rbxassetid://8474555506</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474556619</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185711836</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058da</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX49DEBC8827D147E68BF8D35B4259282C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8503845030</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized2</string>
<Content name="NormalMap"><url>rbxassetid://8503845999</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8503847771</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185712993</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058db</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX98F194681F10489AB24CD88EB08BC595">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474587647</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized3</string>
<Content name="NormalMap"><url>rbxassetid://8474588985</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474591358</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185714243</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058dc</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX145E3E8C0FC242FFB55C757C15A29D3F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474569343</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized4</string>
<Content name="NormalMap"><url>rbxassetid://8474570922</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474574003</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629144283</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058dd</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA4B3D24B3A7E4D97978A3D7EEFF81A20">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474592610</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized5</string>
<Content name="NormalMap"><url>rbxassetid://8474595486</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474597374</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185752600</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058de</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX1A31FA8A3EE245FEB4880C2109C360A6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474581556</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized6</string>
<Content name="NormalMap"><url>rbxassetid://8474582674</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474585792</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185753820</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058df</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX03F26E8B2749492CAF409D95E6320AF0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474577106</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized7</string>
<Content name="NormalMap"><url>rbxassetid://8474578029</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474579762</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185754973</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058e0</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD2C72502ABAE40A289D2889021BD2B08">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8503769456</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized8</string>
<Content name="NormalMap"><url>rbxassetid://8503770488</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8503771559</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185756063</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058e1</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB6908C0D11174C2B87B727578D1EB19B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474602115</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized9</string>
<Content name="NormalMap"><url>rbxassetid://8474603238</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474604775</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185757354</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058e2</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXEE68A7033F1C4E0883CA4681194FC630">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474540257</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized10</string>
<Content name="NormalMap"><url>rbxassetid://8474543226</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474547367</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185758516</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058e3</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5D45F0E232174FA3883218690E91A1CA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8503892851</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized11</string>
<Content name="NormalMap"><url>rbxassetid://8503894564</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8503895203</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185759864</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058e4</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA692FF3FF087406A8DC3C4DD58ABD07B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474607184</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized12</string>
<Content name="NormalMap"><url>rbxassetid://8474608074</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474609265</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185760951</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058e5</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX973E49831A764F899FD0497A6F3E7BBF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8474559675</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Styalized13</string>
<Content name="NormalMap"><url>rbxassetid://8474561314</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8474566360</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185762227</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058e6</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX3197C651EF5E41EAB07C47D74CE46793">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://6222912459</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick1</string>
<Content name="NormalMap"><url>rbxassetid://6222912050</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6222911655</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185988747</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058e8</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXAE190727C0904C7AADF9950CA748BCB7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444028502</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick2</string>
<Content name="NormalMap"><url>rbxassetid://8444029393</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444029861</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185990554</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058e9</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXDFB1F0D9C154451A9C3A7EF05C53F566">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8440775343</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick3</string>
<Content name="NormalMap"><url>rbxassetid://8440776012</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440776312</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185991746</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ea</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX6E22AEEFBFD84394BE0713DD2FB0E1D3">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8440335535</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick4</string>
<Content name="NormalMap"><url>rbxassetid://8440335891</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440335677</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185992711</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058eb</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA33CF69AB9CB45E18303BE7B0C304180">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444076710</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick5</string>
<Content name="NormalMap"><url>rbxassetid://8444077046</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444077388</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185994577</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ec</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXBE4D1D14290A425F9D4092492E43FECB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8440778692</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick6</string>
<Content name="NormalMap"><url>rbxassetid://8440779347</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440779631</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185995629</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ed</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX95D2DE4C67474874A9720312F98E5F17">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8440329611</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick7</string>
<Content name="NormalMap"><url>rbxassetid://8440329817</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440329424</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11123154563</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ee</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD9EBEF6DA1724B04AEEE00C4E4FA40C5">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8440781197</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick8</string>
<Content name="NormalMap"><url>rbxassetid://8440781640</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440781915</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185997856</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ef</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8972D7B39FA04EC78F9BD6D36705FCE9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444065703</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick9</string>
<Content name="NormalMap"><url>rbxassetid://8444066703</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444067351</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14185998872</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f0</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA9AEDC0347F84C0DA8E821E7DC23BC86">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://7978671231</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick10</string>
<Content name="NormalMap"><url>rbxassetid://7978673549</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7978675541</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10631132568</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f1</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX335473D5AE6F4AC899E90999C74CB798">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444045154</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick11</string>
<Content name="NormalMap"><url>rbxassetid://8444045927</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444046429</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186001153</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f2</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXF04B6FFB9F9147F48CC0F058137EAE76">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444054153</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick12</string>
<Content name="NormalMap"><url>rbxassetid://8444055053</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444055625</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186002195</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f3</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB96145CC1831405BBB3097F293F18226">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://7978680696</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick13</string>
<Content name="NormalMap"><url>rbxassetid://7978682141</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7978683628</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11123171271</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f4</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD13A368B82AC4BBBB84EDA23BEBD9087">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444118156</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick14</string>
<Content name="NormalMap"><url>rbxassetid://8444118588</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444118936</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186004512</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f5</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9A482DE5909F46919443ECE56F3EC921">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8329681649</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick15</string>
<Content name="NormalMap"><url>rbxassetid://8329704039</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8329712758</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186005794</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f6</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX18A7DEF1B4F34E11AC5ECB87D52B6023">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://7892395387</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick16</string>
<Content name="NormalMap"><url>rbxassetid://7892389946</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7892391921</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11123161735</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f7</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD70AF0A468EE447688D61551741E604E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8440319319</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick17</string>
<Content name="NormalMap"><url>rbxassetid://8440319650</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440319456</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186007906</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f8</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX56647DE8A3F04216A01D602F1F8B0984">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8440787930</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick18</string>
<Content name="NormalMap"><url>rbxassetid://8440788514</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440788884</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186008952</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058f9</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE8E871F3C8564638A3E32D0191EDA412">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444081487</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick19</string>
<Content name="NormalMap"><url>rbxassetid://8444082304</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444082745</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10631125044</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058fa</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX4FC54C60FAE24366941F8526B10B5DC6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444062151</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick20</string>
<Content name="NormalMap"><url>rbxassetid://8444062873</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444063307</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11123136039</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058fb</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9247B491217644969A9E9A45915BC18C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://5769935160</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick21</string>
<Content name="NormalMap"><url>rbxassetid://5769934893</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5769934778</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186012284</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058fc</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD4AE13660BFB4309A10CDB185841763B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://6020020685</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick22</string>
<Content name="NormalMap"><url>rbxassetid://6020021221</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6020021826</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10685955543</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058fd</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX61C7D55EA3214E2B9AC3C0226ED8923E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444116151</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick23</string>
<Content name="NormalMap"><url>rbxassetid://8444117098</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444117656</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186015132</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058fe</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX1CD2A702E9AA40F9B32D06917E7ACE12">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://11883899816</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883901612</url></Content>
<string name="Name">Brick 12</string>
<Content name="NormalMap"><url>rbxassetid://11883901185</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883900801</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883901689</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000058ff</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX15A44FE54EDF485396998E5E336CD389">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://9596572755</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick 6</string>
<Content name="NormalMap"><url>rbxassetid://9596572846</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://9596576346</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11137491495</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005900</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX1102B26ED0B146D0B1E5FC3FD966A782">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8410945820</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8410940597</url></Content>
<string name="Name">Brick 10</string>
<Content name="NormalMap"><url>rbxassetid://8410936391</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8410944143</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372022</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005901</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2A92E49EC85D44C1BBA1BB8041DA23CB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://5447029735</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick 11</string>
<Content name="NormalMap"><url>rbxassetid://5447030456</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5447030036</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">11</float>
<Content name="TexturePack"><url>rbxassetid://14191656023</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005902</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX84A1606FB8CC492FAC375BFCC85D4322">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://7892395387</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick 8</string>
<Content name="NormalMap"><url>rbxassetid://7892389946</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7892391921</url></Content>
<float name="StudsPerTile">8</float>
<Content name="TexturePack"><url>rbxassetid://11123161735</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005903</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX63854090EC084C1E9060EA70AA6AA838">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://5447395938</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick 5</string>
<Content name="NormalMap"><url>rbxassetid://5447394909</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5447397250</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">6</float>
<Content name="TexturePack"><url>rbxassetid://14191667157</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005904</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX0297A4A91B074D1493CB578C143F4A8D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://7978680696</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick 9</string>
<Content name="NormalMap"><url>rbxassetid://7978682141</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7978683628</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11123171271</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005905</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX446E4D11D7A64F888670639CEE22F729">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8444081487</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick 2</string>
<Content name="NormalMap"><url>rbxassetid://8444082304</url></Content>
<Content name="RoughnessMap"><null></null></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">9</float>
<Content name="TexturePack"><url>rbxassetid://10631124710</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005906</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE85B3BF7C70B4F35929BB4B842A8FB09">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8370039417</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8370035404</url></Content>
<string name="Name">Brick 1</string>
<Content name="NormalMap"><url>rbxassetid://8370034937</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8369994724</url></Content>
<float name="StudsPerTile">20</float>
<Content name="TexturePack"><url>rbxassetid://11110371699</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005907</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX64AD7463466C4FC6960C392748AF1289">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://7978671231</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Brick 4</string>
<Content name="NormalMap"><url>rbxassetid://7978673549</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7978675541</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">8</float>
<Content name="TexturePack"><url>rbxassetid://10631132568</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005908</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8E7F4098F6444DCDA80147DABE92D9B6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8444122778</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Roof1</string>
<Content name="NormalMap"><url>rbxassetid://8444123345</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444123594</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11143984729</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000590a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX24493874C6404029B6E1D9DB4E866711">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440792645</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Roof2</string>
<Content name="NormalMap"><url>rbxassetid://8440793193</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440793473</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186044556</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000590b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXC11C4DCD55F54141B356B6E9A5A15F0A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://5770014062</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Roof3</string>
<Content name="NormalMap"><url>rbxassetid://5770018471</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5770018846</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186045715</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000590c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8DA4A249050F40AC88BF393D0ACFB3A7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://6021985745</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Roof4</string>
<Content name="NormalMap"><url>rbxassetid://6021986125</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6021985983</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186046567</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000590d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD9CBD2EE000948CCB337AA0CA249F5C1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://5482122762</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Roof5</string>
<Content name="NormalMap"><url>rbxassetid://5482120419</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5482117785</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186047887</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000590e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX652022ADD4654255AEE029F1B4DB023D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://8440515322</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cloth1</string>
<Content name="NormalMap"><url>rbxassetid://8440515016</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440514769</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186062128</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005910</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2DE2D82EC6734AB5BCA885D14C3890A0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://7980554514</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cloth2</string>
<Content name="NormalMap"><url>rbxassetid://7980555702</url></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186070616</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005911</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX33EF85501D2C4F47814B25BCE4F76B34">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://7967866335</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cloth3</string>
<Content name="NormalMap"><url>rbxassetid://7967867694</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7967869325</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186075659</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005912</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB6079BE2861A4EFC8A8E4E0CC2B3FE3C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://8440334711</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cloth4</string>
<Content name="NormalMap"><url>rbxassetid://8440335382</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440335115</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186077179</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005913</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXBC61488CD79148F095E3DF1BA9D0B8DB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://8440514658</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cloth5</string>
<Content name="NormalMap"><url>rbxassetid://8440514463</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440514227</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186079767</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005914</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX6B44BC591C3748E2BFB39A23EAF5ABCF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://8440319791</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cloth6</string>
<Content name="NormalMap"><url>rbxassetid://8440320132</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440319909</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186083912</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005915</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9E71FBBDC29E49DDBC706949E08FFA7F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://8444077873</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cloth7</string>
<Content name="NormalMap"><url>rbxassetid://8444078393</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444078753</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186086718</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005916</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE461263AAFAD42EE8C5244BF59166211">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://4544878302</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://4544877455</url></Content>
<string name="Name">Cloth8</string>
<Content name="NormalMap"><url>rbxassetid://4544873473</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://4544875660</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186088186</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005917</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9D6A03C599854B7195D38ADA04FF0E98">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://8444069144</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cloth9</string>
<Content name="NormalMap"><url>rbxassetid://8444069666</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444070108</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186089270</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005918</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD4DCD5D1CC684D7A8A7E1C10AC87CA04">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://6022336743</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6022337649</url></Content>
<string name="Name">Cloth10</string>
<Content name="NormalMap"><url>rbxassetid://6022337963</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6022338269</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186065550</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005919</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9498E1CFD77649789D4A0143A83B2E50">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://8440516656</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cloth11</string>
<Content name="NormalMap"><url>rbxassetid://8440516527</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440516354</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186069042</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000591a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX529AEB2F92304AF1973F9098F6E8BD6D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8439907381</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Paint1</string>
<Content name="NormalMap"><url>rbxassetid://8439908367</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8439909588</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186112200</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000591c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX14B58CF95FD249BF9546DCC3DD237C19">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8444083604</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Paint2</string>
<Content name="NormalMap"><url>rbxassetid://8444084422</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444084931</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186113988</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000591d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9357852F3FDF4133A722AEAD45423D8A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://5447104854</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Paint3</string>
<Content name="NormalMap"><url>rbxassetid://5447102129</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5447103159</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186115526</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000591e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2A5DFAF57DC147D99EB09283EAB7CE86">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://6034917232</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Paint4</string>
<Content name="NormalMap"><url>rbxassetid://6034917402</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6034917522</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186116999</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000591f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE2C0718D57214C02B0BA4D48C677F0ED">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8444039071</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Paint5</string>
<Content name="NormalMap"><url>rbxassetid://8444040064</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444040582</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186118720</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005920</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX63D792EB5609447FBC87E2BD5E3FD7E0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8444056389</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Paint6</string>
<Content name="NormalMap"><url>rbxassetid://8444057276</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444057715</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186121063</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005921</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5816E1E4EC474309859587C2EE040F93">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440795014</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Paint7</string>
<Content name="NormalMap"><url>rbxassetid://8440795321</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440795582</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186122454</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005922</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX62D48DF2F6FE47D6A4E413875FF5F4B0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8036361271</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Paint8</string>
<Content name="NormalMap"><url>rbxassetid://8036362785</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8036363348</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186124199</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005923</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB8F3F21F659E4307BC471A14A06ACDC2">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">784</token>
<Content name="ColorMap"><url>rbxassetid://8440514039</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Marble1</string>
<Content name="NormalMap"><url>rbxassetid://8440513856</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440513701</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191600583</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005925</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX70CB1872B6644528929083110CE3212E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">784</token>
<Content name="ColorMap"><url>rbxassetid://8440513544</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Marble2</string>
<Content name="NormalMap"><url>rbxassetid://8440513277</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440513119</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191606585</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005926</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5DFF540EB3D54F36A04F509F1C5D4005">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">784</token>
<Content name="ColorMap"><url>rbxassetid://7968592900</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Marble4</string>
<Content name="NormalMap"><url>rbxassetid://7968594383</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7968596038</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191615792</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005927</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXC452A04394CC4253B43AAB89840394C1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">784</token>
<Content name="ColorMap"><url>rbxassetid://8440505519</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Marble5</string>
<Content name="NormalMap"><url>rbxassetid://8440505202</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440505014</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191618145</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005928</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX0FFBE2E8CEF24C59AD5EFC6153BB2EA1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">784</token>
<Content name="ColorMap"><url>rbxassetid://8440504192</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Marble6</string>
<Content name="NormalMap"><url>rbxassetid://8440503970</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440503827</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191620166</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005929</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2292C4D4C122482EB568ABEA16DB3BA2">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">784</token>
<Content name="ColorMap"><url>rbxassetid://8440504789</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Marble7</string>
<Content name="NormalMap"><url>rbxassetid://8440504532</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440504396</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191622332</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000592a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE28E447133FB4F1F82B8D33F062A2261">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">784</token>
<Content name="ColorMap"><url>rbxassetid://7968630513</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Marble8</string>
<Content name="NormalMap"><url>rbxassetid://7968643355</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7968644523</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191624463</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000592b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX82527F766EA4425E967119D5F880C552">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">784</token>
<Content name="ColorMap"><url>rbxassetid://8440503625</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Marble9</string>
<Content name="NormalMap"><url>rbxassetid://8440503394</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440503151</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191628682</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000592c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX819902B0109B45C0AE614F8396D038DB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">784</token>
<Content name="ColorMap"><url>rbxassetid://8440332621</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440331808</url></Content>
<string name="Name">Marble10</string>
<Content name="NormalMap"><url>rbxassetid://8440332463</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440332165</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191604011</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000592d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX072B0955333C4038893C6AD28B3117B1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8444108887</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall1</string>
<Content name="NormalMap"><url>rbxassetid://8444109312</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444109752</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191651365</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000592f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX98793A63DC0E4D499E8BE0961B85D78C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://5447029735</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall2</string>
<Content name="NormalMap"><url>rbxassetid://5447030456</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5447030036</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191656023</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005930</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX84464C78AEAC49F688B02D7476AA15BE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8440509083</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall3</string>
<Content name="NormalMap"><url>rbxassetid://8440508886</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440508619</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191658365</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005931</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX17A0381464494577A8D8D36687CF7FED">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8440508422</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall4</string>
<Content name="NormalMap"><url>rbxassetid://8440508228</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440507854</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191661082</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005932</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX4DAD9AF403604697B890D98C57696F15">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8440500188</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall5</string>
<Content name="NormalMap"><url>rbxassetid://8440499930</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440499738</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191662808</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005933</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2AB7A314C3B4401DAE3CD827F8C05E94">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8440516189</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall6</string>
<Content name="NormalMap"><url>rbxassetid://8440515978</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440515581</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191665134</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005934</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX6A654BA6B6C24E5C870BEFB66537403B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://5447395938</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall7</string>
<Content name="NormalMap"><url>rbxassetid://5447394909</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5447397250</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191667157</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005935</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX968E75B92CD448DF8484E74DBF9E8711">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8444070621</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall8</string>
<Content name="NormalMap"><url>rbxassetid://8444071060</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444071505</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191669507</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005936</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2AA1C252211147C8ABCD50ACFD1F78ED">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://6222892953</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall9</string>
<Content name="NormalMap"><url>rbxassetid://6222892639</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6222892238</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191671639</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005937</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFCECA20D59FD4B1997949C91AF4A9DCA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://6102603774</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wall10</string>
<Content name="NormalMap"><url>rbxassetid://6102603670</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6102603539</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191653776</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005938</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX6EC7CA71630F45BB8FB2354B44CD5998">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://6702766730</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood1</string>
<Content name="NormalMap"><url>rbxassetid://6702768717</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702770019</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191686448</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000593a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX6EEB33E9A46E4EFE89628B838FE8519A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://6090553562</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood2</string>
<Content name="NormalMap"><url>rbxassetid://6090547835</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6090548117</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191713372</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000593b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8C6A8C7DB71048C0B941F3CEB61431EB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://6222814802</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6222814417</url></Content>
<string name="Name">Wood3</string>
<Content name="NormalMap"><url>rbxassetid://6222814222</url></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191727054</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000593c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX4F39EC85234141A798E89CCE3D542E13">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://7970879917</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood4</string>
<Content name="NormalMap"><url>rbxassetid://7970881284</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7970883594</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191729238</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000593d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX03D12A966D5F414897A7D6FB7F66E3A8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://6223105832</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood5</string>
<Content name="NormalMap"><url>rbxassetid://6223105534</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6223105224</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191731354</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000593e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8EDC35F31D08477AB741127D7B8EA806">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8440785560</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood6</string>
<Content name="NormalMap"><url>rbxassetid://8440785930</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440786209</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191733525</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000593f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX59BE875E56D54C1A89D15B595385B007">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://6022445043</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood7</string>
<Content name="NormalMap"><url>rbxassetid://6022433044</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6022433425</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191735540</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005940</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX0D2BD2C49B8A4BC295E461DDCA9AC86E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://4902036330</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood8</string>
<Content name="NormalMap"><url>rbxassetid://4902038477</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://4902038901</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191738115</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005941</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXF8C8A26F70434F79B3E161C18D93DAD9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8440780067</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood9</string>
<Content name="NormalMap"><url>rbxassetid://8440780576</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440780849</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191742193</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005942</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFAC6529279544755B286346693BF259E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://6702791805</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood10</string>
<Content name="NormalMap"><url>rbxassetid://6702793266</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702794697</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191688727</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005943</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXDB29DC4A6FE744C5AF97B634400D2790">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8329729045</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood11</string>
<Content name="NormalMap"><url>rbxassetid://8329735001</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8329740317</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191691438</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005944</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB23654A2DC22486BBDB3EF53828CBF81">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8444119366</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood12</string>
<Content name="NormalMap"><url>rbxassetid://8444119954</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444120335</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191693948</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005945</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX89F3E390FD034CA2AAE2AE3D19C1E29D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8439902353</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood18</string>
<Content name="NormalMap"><url>rbxassetid://8439903970</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8439904777</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191708237</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005946</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX48E0902EAE8745B886622AC4477CE834">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8440330759</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood16</string>
<Content name="NormalMap"><url>rbxassetid://8440330949</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440330577</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191703754</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005947</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXC36161CA416C413B88C99101CF838C64">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8440498825</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood21</string>
<Content name="NormalMap"><url>rbxassetid://8440498639</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440498471</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191717822</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005948</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9ADDBFAF435040F9902B154B03328F83">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8440498259</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood20</string>
<Content name="NormalMap"><url>rbxassetid://8440498019</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440497746</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191715262</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005949</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5740980EBB5941B2B9C62E2F45469682">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8444064051</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood13</string>
<Content name="NormalMap"><url>rbxassetid://8444064601</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444064947</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191695915</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000594a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX6D3F337437744ACF9AEE61B739590A1F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8444046892</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood17</string>
<Content name="NormalMap"><url>rbxassetid://8444047271</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444047541</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191706017</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000594b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFF185999B0EB4174BE8143CE8031F005">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8440499549</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood22</string>
<Content name="NormalMap"><url>rbxassetid://8440499242</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440498996</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191719729</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000594c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX4D390BF6F32044EEBC118B1D5632F650">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8439893327</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood23</string>
<Content name="NormalMap"><url>rbxassetid://8439894616</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8439896358</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191722011</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000594d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX72D5C12221F34B55B90E7A1E6F577A94">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8440799093</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood14</string>
<Content name="NormalMap"><url>rbxassetid://8440799328</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440799734</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191698724</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000594e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX6F17CDD724564900887119F438C26F77">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8444102950</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood24</string>
<Content name="NormalMap"><url>rbxassetid://8444103662</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444104159</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191724603</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000594f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX754FC16306A04371907FCF22DBB4F81D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://6702814604</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6702815766</url></Content>
<string name="Name">Wood15</string>
<Content name="NormalMap"><url>rbxassetid://6702817277</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702818353</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191701384</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005950</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9CA9764B6EDF49FEBCA842D5B2CE71B0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8440330222</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood19</string>
<Content name="NormalMap"><url>rbxassetid://8440330417</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440329979</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191711301</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005951</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXBC98DE62087C4FBFB596348DAF599AB4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://11888057720</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood 13</string>
<Content name="NormalMap"><url>rbxassetid://11888057127</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11888055797</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11888057892</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005952</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXC11B09BC7FBF4D67973E75EF9DADD5B0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://6222814802</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><url>rbxassetid://6222814417</url></Content>
<string name="Name">Wood 3</string>
<Content name="NormalMap"><url>rbxassetid://6222814222</url></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">8</float>
<Content name="TexturePack"><url>rbxassetid://14191727054</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005953</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX56C5C23AD2644DE786CBFE6C33236F86">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8410966374</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8410968304</url></Content>
<string name="Name">Wood 1</string>
<Content name="NormalMap"><url>rbxassetid://8410969955</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8410971901</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372017</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005954</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX20840392347C4149AC3847232B4522F3">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">528</token>
<Content name="ColorMap"><url>rbxassetid://8369998493</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8369994724</url></Content>
<string name="Name">Wood 4</string>
<Content name="NormalMap"><url>rbxassetid://8369993805</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8369989555</url></Content>
<float name="StudsPerTile">11.7410002</float>
<Content name="TexturePack"><url>rbxassetid://11110371803</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005955</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX1E847E03729C4F4D9BC3F5257332E67D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">528</token>
<Content name="ColorMap"><url>rbxassetid://6223105832</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood 5</string>
<Content name="NormalMap"><url>rbxassetid://6223105534</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6223105224</url></Content>
<float name="StudsPerTile">12</float>
<Content name="TexturePack"><url>rbxassetid://14191731354</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005956</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX245762C0DFF54078890E73DD5BBBB7D4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://11883123750</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood 6</string>
<Content name="NormalMap"><url>rbxassetid://11883120034</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883119480</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883147172</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005957</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX961568D06282479BACABE84AA6FAB5CF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">528</token>
<Content name="ColorMap"><url>rbxassetid://11888345581</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood 7</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><url>rbxassetid://11888346155</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11888346339</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005958</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8035B60F95534E01B48B07DFAC22F093">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8444119366</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood 8</string>
<Content name="NormalMap"><url>rbxassetid://8444119954</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444120335</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191693948</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005959</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX18AA1C7C42AC45FB8D9DDC8214D65160">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://6702814604</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6702815766</url></Content>
<string name="Name">Wood 9</string>
<Content name="NormalMap"><url>rbxassetid://6702817277</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6702818353</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191701384</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000595a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX233A5A2D76E94C01BBDC66C2E7C60143">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://7385620368</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood 11</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11889239156</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000595b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX325360E9B92E46B39DE9A08A1300DA47">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://11893253374</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11893253321</url></Content>
<string name="Name">Wood 10</string>
<Content name="NormalMap"><url>rbxassetid://11893251820</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11893251656</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11893253503</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000595c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX399717E8FF3348448A2C6620E634246C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://11888083617</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wood 12</string>
<Content name="NormalMap"><url>rbxassetid://11888077820</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11888076443</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11888083814</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000595d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX156AE3F8AFC04136B5B7DAF449E67931">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8444036738</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock1</string>
<Content name="NormalMap"><url>rbxassetid://8444037435</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444037944</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191783696</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000595f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9B18F57E658B4436A2B0568C87BD3C61">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8440324732</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock2</string>
<Content name="NormalMap"><url>rbxassetid://8440324501</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440324300</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191796842</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005960</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8D8CD09CBDC14A8FB196B6A71F8EFE2D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8435073403</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock3</string>
<Content name="NormalMap"><url>rbxassetid://8435076763</url></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191799679</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005961</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX597E40C002F840A89BCB9B6D84D24D86">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8444052267</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock4</string>
<Content name="NormalMap"><url>rbxassetid://8444052267</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444053212</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191802937</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005962</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXEE7625386A7643A0A434F963C2361DE6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8439871564</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock5</string>
<Content name="NormalMap"><url>rbxassetid://8439872947</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8439874052</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191805890</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005963</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8EFBBB7097E245C1804462FA716F8BCB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8440506861</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock6</string>
<Content name="NormalMap"><url>rbxassetid://8440506613</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440506394</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191808400</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005964</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX499D63D32B064F2685F0B286CDF5AF01">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8444074180</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock7</string>
<Content name="NormalMap"><url>rbxassetid://8444074645</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444074947</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191813033</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005965</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXC23D7B28D4764AB3AD38E80B382C6E84">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8440324918</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock8</string>
<Content name="NormalMap"><url>rbxassetid://8440325457</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440325109</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191815701</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005966</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB820B96F240342E8988846BC8B074B8D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8035573127</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8035573933</url></Content>
<string name="Name">Rock9</string>
<Content name="NormalMap"><url>rbxassetid://8035575227</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8035576561</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191818618</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005967</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX02390D718CB146BD99D75BDC2449B20D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8444092526</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock10</string>
<Content name="NormalMap"><url>rbxassetid://8444093480</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444093882</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191785656</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005968</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX6414AAC36D0A4569AB575437AD0FD7F2">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8444034396</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock11</string>
<Content name="NormalMap"><url>rbxassetid://8444035366</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444036035</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191787901</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005969</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5764DC45518440979E77C96ACEABE894">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8440506205</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock12</string>
<Content name="NormalMap"><url>rbxassetid://8440506023</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440505768</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191791953</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000596a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX694456D2CE6A424CBAF452430149AAB6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">896</token>
<Content name="ColorMap"><url>rbxassetid://8276571265</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Rock13</string>
<Content name="NormalMap"><url>rbxassetid://8276572390</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8276573627</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191794623</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000596b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA9ABCE23BBBE4D109E1E5560947990A4">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://4902178831</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other1</string>
<Content name="NormalMap"><url>rbxassetid://4902179752</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://4902180490</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191852650</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000596d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX723B9C20CEEE498780B99DFD241C7730">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440507643</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other2</string>
<Content name="NormalMap"><url>rbxassetid://8440507348</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440507016</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191871037</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000596e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX69A585CA8B354F518AD0FD57928D034E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440511618</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440511405</url></Content>
<string name="Name">Other3</string>
<Content name="NormalMap"><url>rbxassetid://8440511293</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440510945</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191876911</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000596f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE3D36A6FB2374D309976F0191476F406">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8444058248</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other4</string>
<Content name="NormalMap"><url>rbxassetid://8444058900</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444059378</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191881696</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005970</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX7EC542579B7E4A56BDA7457EA184C37B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://6687689610</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://6687443102</url></Content>
<string name="Name">Other5</string>
<Content name="NormalMap"><url>rbxassetid://6687443039</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6687442950</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191884708</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005971</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX825B4429C834402AA0B2DBE0E20C24AB">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440332773</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other6</string>
<Content name="NormalMap"><url>rbxassetid://8440332324</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440333003</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191887403</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005972</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9665401B12734AEDBB07D7D0056600EF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440328533</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440328729</url></Content>
<string name="Name">Other7</string>
<Content name="NormalMap"><url>rbxassetid://8440329237</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440328948</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191889856</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005973</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX6D359734DD42490BB53326D180393876">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8035584592</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other8</string>
<Content name="NormalMap"><url>rbxassetid://8035586063</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8035586885</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191892316</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005974</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA3B8A01675234F89B34894913C17C2E7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://5324380197</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other9</string>
<Content name="NormalMap"><url>rbxassetid://5324380791</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5324381130</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191894559</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005975</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX3B0AAEAAE19D4EE380ABC2343F949451">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://4902193536</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other10</string>
<Content name="NormalMap"><url>rbxassetid://4902195322</url></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191854713</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005976</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5A497A7BA0824E4C812336CA6E66512D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440325689</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other11</string>
<Content name="NormalMap"><url>rbxassetid://8440326141</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440325873</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191857295</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005977</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX24270EA42F604A6A9F10171E996BE618">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://4595615069</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other12</string>
<Content name="NormalMap"><url>rbxassetid://4595617260</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://4595620067</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191859836</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005978</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD7B1309E6F47447185C966CCBADEF607">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8440517960</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8440517766</url></Content>
<string name="Name">Other13</string>
<Content name="NormalMap"><url>rbxassetid://8440517570</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440517333</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191862579</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005979</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXCEFFAA04B49842759D2188D8EEE63669">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://6223089912</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other14</string>
<Content name="NormalMap"><url>rbxassetid://6223089433</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6223089080</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191865700</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000597a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX9DCD9FE8BF984790BBFEABE2710E0EF3">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://5324273594</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Other15</string>
<Content name="NormalMap"><url>rbxassetid://5324274086</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5324274293</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191868544</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000597b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD54105B5EF19470D921095629339AE86">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://11888120082</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11888120478</url></Content>
<string name="Name">Plaster 2</string>
<Content name="NormalMap"><url>rbxassetid://11888121455</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11888119379</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11888121581</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000597c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX828AB80A1AC44CF9821CA6ECDA0566F8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://11888111260</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11888105326</url></Content>
<string name="Name">Plaster 1</string>
<Content name="NormalMap"><url>rbxassetid://11888104118</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11888102916</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11888111457</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000597d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX57B01FA7087E42DE9921C625F18719C1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://8440795859</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground 2</string>
<Content name="NormalMap"><url>rbxassetid://8440796214</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440796488</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122962676</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000597e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXF958708CB492462286D16C2714FD9C33">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">864</token>
<Content name="ColorMap"><url>rbxassetid://8440789410</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Gravel 1</string>
<Content name="NormalMap"><url>rbxassetid://8440789795</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440790084</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11110371753</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000597f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX92D1EBF0FFFB45AA9AFBE8ED741A2FFC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">864</token>
<Content name="ColorMap"><url>rbxassetid://8444096600</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Gravel 2</string>
<Content name="NormalMap"><url>rbxassetid://8444097367</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444097871</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11110371751</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005980</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA55707EEA1F247EBA2B1ABD5FD3467F2">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">864</token>
<Content name="ColorMap"><url>rbxassetid://11883879610</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Gravel 3</string>
<Content name="NormalMap"><url>rbxassetid://11883883869</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883881050</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883884009</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005981</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX1EF3BC6C21264784AADF31A0644D6334">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1344</token>
<Content name="ColorMap"><url>rbxassetid://8440326451</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Mud 2</string>
<Content name="NormalMap"><url>rbxassetid://8440326687</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440326313</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122955920</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005982</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXAA97E887473D4E27883B181D14C578CE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1360</token>
<Content name="ColorMap"><url>rbxassetid://10527430140</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Ground 1</string>
<Content name="NormalMap"><url>rbxassetid://10527430101</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://10528957830</url></Content>
<float name="StudsPerTile">15</float>
<Content name="TexturePack"><url>rbxassetid://10528957967</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005983</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE8744E7B720C4EBB9E19197DBB1F4E7E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1344</token>
<Content name="ColorMap"><url>rbxassetid://8440798069</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Mud 1</string>
<Content name="NormalMap"><url>rbxassetid://8440798555</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440798784</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11122948554</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005984</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX45C6B08980864894A4D7A4F98D1DA3C5">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1376</token>
<Content name="ColorMap"><url>rbxassetid://288525813</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Marking 1</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">2</float>
<Content name="TexturePack"><url>rbxassetid://11883446833</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005985</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXAD9C67BF241045E2AB2F5F778F0345E6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1536</token>
<Content name="ColorMap"><url>rbxassetid://8311264287</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8311257940</url></Content>
<string name="Name">Ice 1</string>
<Content name="NormalMap"><url>rbxassetid://8322600180</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8311253663</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11110371745</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005986</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA7B49D55981E4AC09C3A9F754E2F099B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://296397709</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Container 1</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">2</float>
<Content name="TexturePack"><url>rbxassetid://11889287709</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005987</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX223071B2B95F45FCBB1DE4BC163A3AED">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">800</token>
<Content name="ColorMap"><url>rbxassetid://6223022164</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Slate 1</string>
<Content name="NormalMap"><url>rbxassetid://6223021930</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6223021581</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11110371752</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005988</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX838A25FE397148DF96088BD945715E3D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://8035584592</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Sidewalk liner 1</string>
<Content name="NormalMap"><url>rbxassetid://8035586063</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8035586885</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14191892316</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005989</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXBB693FD59C664D19A0007D2BD5B15ECC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1296</token>
<Content name="ColorMap"><url>rbxassetid://10374269004</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://10373774683</url></Content>
<string name="Name">Sand 2</string>
<Content name="NormalMap"><url>rbxassetid://10373776486</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://10373774841</url></Content>
<float name="StudsPerTile">20</float>
<Content name="TexturePack"><url>rbxassetid://10374269138</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000598a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXEBD50653D1B7477487BAFDFACD592347">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1296</token>
<Content name="ColorMap"><url>rbxassetid://10148508048</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><url>rbxassetid://10148507627</url></Content>
<string name="Name">Sand 1</string>
<Content name="NormalMap"><url>rbxassetid://10148504694</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://10148502614</url></Content>
<int64 name="SourceAssetId">10169623250</int64>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10148523965</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000598b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX35AB994472CE48AE827E339B3A7ECBB8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">864</token>
<Content name="ColorMap"><url>rbxassetid://6125529088</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Wet pebble</string>
<Content name="NormalMap"><url>rbxassetid://6125528997</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://6125528936</url></Content>
<int64 name="SourceAssetId">11180295441</int64>
<float name="StudsPerTile">6</float>
<Content name="TexturePack"><url>rbxassetid://11122985156</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000598d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXCF81DBBF86A648ED8913057795914DEA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">880</token>
<Content name="ColorMap"><url>rbxassetid://8440502993</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cobblestone 1</string>
<Content name="NormalMap"><url>rbxassetid://8440502766</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440502530</url></Content>
<float name="StudsPerTile">15</float>
<Content name="TexturePack"><url>rbxassetid://10402863901</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000598f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX12DAF8390F9745C4BF3AA6B4C5ADCF45">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">880</token>
<Content name="ColorMap"><url>rbxassetid://8440502993</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Cobblestone 2</string>
<Content name="NormalMap"><url>rbxassetid://8440502766</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440502530</url></Content>
<float name="StudsPerTile">6</float>
<Content name="TexturePack"><url>rbxassetid://10402863901</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005990</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX0CDC9D9BEE8A4E068698AF21AFC4D17E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">880</token>
<Content name="ColorMap"><url>rbxassetid://7463961962</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://7463964326</url></Content>
<string name="Name">Cobblestone 3</string>
<Content name="NormalMap"><url>rbxassetid://7463958255</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://7463954519</url></Content>
<int64 name="SourceAssetId">8222649062</int64>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10685906689</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005991</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXFB1CE92D70DA47BF825DF7E4253CE4C7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">880</token>
<Content name="ColorMap"><url>rbxassetid://11215517084</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11215517584</url></Content>
<string name="Name">Cobblestone 4</string>
<Content name="NormalMap"><url>rbxassetid://11215518235</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11215518736</url></Content>
<float name="StudsPerTile">25</float>
<Content name="TexturePack"><url>rbxassetid://11215518894</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005992</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX79F3C5C8246F464698A16B0BF2F025A9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://11215482660</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11215483338</url></Content>
<string name="Name">Cobblestone 5</string>
<Content name="NormalMap"><url>rbxassetid://11215484153</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11215484833</url></Content>
<float name="StudsPerTile">20</float>
<Content name="TexturePack"><url>rbxassetid://11215484961</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005993</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD30554C1F9F049E4BAA0EF25803AB95A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8444039071</url></Content>
<token name="MaterialPattern">1</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Concrete 4</string>
<Content name="NormalMap"><url>rbxassetid://8444040064</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444040582</url></Content>
<float name="StudsPerTile">6</float>
<Content name="TexturePack"><url>rbxassetid://14186118720</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005995</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2F9996CD174B4B1E9E8DB8FCF90DDE8B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8036361271</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Concrete 2</string>
<Content name="NormalMap"><url>rbxassetid://8036362785</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8036363348</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://14186124199</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005996</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX1AA03F8E8D3F4570A2890C68CBA6B71E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8440791539</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Concrete 1</string>
<Content name="NormalMap"><url>rbxassetid://8440791880</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440792151</url></Content>
<int64 name="SourceAssetId">10854682009</int64>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10629102021</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005997</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX446F23E7D036457195E5AD332D832CFC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://5447395938</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Concrete 3</string>
<Content name="NormalMap"><url>rbxassetid://5447394909</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://5447397250</url></Content>
<float name="StudsPerTile">8</float>
<Content name="TexturePack"><url>rbxassetid://14191667157</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a500005998</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXDD952FDD1A584C6B9D4AEE45FAA77BD1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">848</token>
<Content name="ColorMap"><url>rbxassetid://8410945820</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8410940597</url></Content>
<string name="Name">Old Brick</string>
<Content name="NormalMap"><url>rbxassetid://8410936391</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8410944143</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372022</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000599a</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE05842A0E61E41BCBD7674F5C66E82CD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">816</token>
<Content name="ColorMap"><url>rbxassetid://8411010520</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8411013899</url></Content>
<string name="Name">Old Concrete</string>
<Content name="NormalMap"><url>rbxassetid://8411015215</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8411017080</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11351372031</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000599b</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX7163DC9D123145FEAE7ACEF6302C774B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1312</token>
<Content name="ColorMap"><url>rbxassetid://8411074364</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8411075811</url></Content>
<string name="Name">Old Fabric</string>
<Content name="NormalMap"><url>rbxassetid://8411076899</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8411078144</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372018</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000599c</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX7337CFEAF212433BB643D90E3160BB8E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1072</token>
<Content name="ColorMap"><url>rbxassetid://8411064783</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8411066283</url></Content>
<string name="Name">Old Foil</string>
<Content name="NormalMap"><url>rbxassetid://8411068079</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8411069742</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372019</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000599d</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXAB009EF8962D4F72B983607C0EB35CC9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1280</token>
<Content name="ColorMap"><url>rbxassetid://8410994855</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8410996399</url></Content>
<string name="Name">Old Grass</string>
<Content name="NormalMap"><url>rbxassetid://8410999048</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8411000704</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372027</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000599e</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX0AC6967BC9334B328945137A3B55F3C0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1536</token>
<Content name="ColorMap"><url>rbxassetid://8411042605</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8411044561</url></Content>
<string name="Name">Old Ice</string>
<Content name="NormalMap"><url>rbxassetid://8411045553</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8411046474</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372016</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a50000599f</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXAA27FFCB69264409AF4E2FA2BA82B1C6">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1296</token>
<Content name="ColorMap"><url>rbxassetid://8411031670</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8411033083</url></Content>
<string name="Name">Old Sand</string>
<Content name="NormalMap"><url>rbxassetid://8411034097</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8411036081</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372015</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059a0</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX22145094458D47E983072F0886C7DF67">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">512</token>
<Content name="ColorMap"><url>rbxassetid://8410966374</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8410968304</url></Content>
<string name="Name">Old Wood</string>
<Content name="NormalMap"><url>rbxassetid://8410969955</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8410971901</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372017</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059a1</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2124CD27A63F4B938D80DB8F05DE4CCD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">528</token>
<Content name="ColorMap"><url>rbxassetid://8410977307</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8410979066</url></Content>
<string name="Name">Old WoodPlanks</string>
<Content name="NormalMap"><url>rbxassetid://8410980455</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8410982461</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11351372029</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059a2</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX4C57D6931F154F97B1373CB8794719B5">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">256</token>
<Content name="ColorMap"><url>rbxassetid://10442530307</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://10442530307</url></Content>
<string name="Name">Old cobblestone</string>
<Content name="NormalMap"><url>rbxassetid://10442530307</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://10442530307</url></Content>
<int64 name="SourceAssetId">11633012246</int64>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11633000938</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059a3</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXB94235387DFD45A5975724F24A8BFD0B">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1376</token>
<Content name="ColorMap"><url>rbxassetid://11883261769</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883261980</url></Content>
<string name="Name">Asphalt 1</string>
<Content name="NormalMap"><url>rbxassetid://11883262262</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883262319</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883262399</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059a5</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5D2E54CBB04246F6B512FDAC199E6642">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1376</token>
<Content name="ColorMap"><url>rbxassetid://11883271586</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883271224</url></Content>
<string name="Name">Asphalt 2</string>
<Content name="NormalMap"><url>rbxassetid://11883271653</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883270870</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883271823</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059a6</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX0C13CE14EEE749368479A98B745955DC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1376</token>
<Content name="ColorMap"><url>rbxassetid://4911798855</url></Content>
<PhysicalProperties name="CustomPhysicalProperties">
<CustomPhysics>true</CustomPhysics>
<Density>0.699999988</Density>
<Friction>0.300000012</Friction>
<Elasticity>0.5</Elasticity>
<FrictionWeight>1</FrictionWeight>
<ElasticityWeight>1</ElasticityWeight>
</PhysicalProperties>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Asphalt 3</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><null></null></Content>
<float name="StudsPerTile">2</float>
<Content name="TexturePack"><url>rbxassetid://11883387250</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059a7</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX4E9056A9F6744E4A9C2EA0234BE2FB3F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1376</token>
<Content name="ColorMap"><url>rbxassetid://11888121335</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Asphalt 4</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><url>rbxassetid://11888076777</url></Content>
<float name="StudsPerTile">30</float>
<Content name="TexturePack"><url>rbxassetid://11888121514</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059a8</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX882570AAB38B47D4A650958AF4AA9AEF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1280</token>
<Content name="ColorMap"><url>rbxassetid://10537355437</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Grass 2</string>
<Content name="NormalMap"><url>rbxassetid://10537210896</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://10537121443</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://10537355549</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059aa</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX387569FFEB924E2D86176261F291AD3E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1280</token>
<Content name="ColorMap"><url>rbxassetid://10374183562</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://10374183173</url></Content>
<string name="Name">Grass 1</string>
<Content name="NormalMap"><url>rbxassetid://10374184465</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://10374183447</url></Content>
<float name="StudsPerTile">30</float>
<Content name="TexturePack"><url>rbxassetid://10374184533</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059ab</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXF5B77BC180F742EA839556C1A45F53E0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1280</token>
<Content name="ColorMap"><url>rbxassetid://11883836188</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883838102</url></Content>
<string name="Name">Grass 3</string>
<Content name="NormalMap"><url>rbxassetid://11883838037</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883836802</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11883974848</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059ac</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2D6673D63A42432A9149D368B853A9C3">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1280</token>
<Content name="ColorMap"><url>rbxassetid://11392735189</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Grass 4</string>
<Content name="NormalMap"><url>rbxassetid://11392737578</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11392741965</url></Content>
<int64 name="SourceAssetId">11392874817</int64>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11392742101</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059ad</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXE8F564E7DE524472BEB3591E992DEC7C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1280</token>
<Content name="ColorMap"><url>rbxassetid://8369938735</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://8369929440</url></Content>
<string name="Name">Grass 5</string>
<Content name="NormalMap"><url>rbxassetid://8369928503</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8369922037</url></Content>
<float name="StudsPerTile">20</float>
<Content name="TexturePack"><url>rbxassetid://11110371750</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059ae</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA9AE24ECC38E402AAED5D9BE68830B8C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1280</token>
<Content name="ColorMap"><url>rbxassetid://8444041435</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Grass 6</string>
<Content name="NormalMap"><url>rbxassetid://8444042294</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444042783</url></Content>
<float name="StudsPerTile">20</float>
<Content name="TexturePack"><url>rbxassetid://10770612901</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059af</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8C745E6DD44240B2B2199412AD3A3E1C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1280</token>
<Content name="ColorMap"><url>rbxassetid://11135905085</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11135905570</url></Content>
<string name="Name">Grass 7</string>
<Content name="NormalMap"><url>rbxassetid://11135906597</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11135906861</url></Content>
<float name="StudsPerTile">30</float>
<Content name="TexturePack"><url>rbxassetid://11135907036</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059b0</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX16A4F35D70944542A8BD6508D14286A9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">1280</token>
<Content name="ColorMap"><url>rbxassetid://9472178382</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Grass 8</string>
<Content name="NormalMap"><url>rbxassetid://9472182623</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://9472184787</url></Content>
<float name="StudsPerTile">100</float>
<Content name="TexturePack"><url>rbxassetid://11135418752</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059b1</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD904C189DCB74B65AFEE7466A0B50C77">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://8444060163</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Pavement 2</string>
<Content name="NormalMap"><url>rbxassetid://8444060821</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444061570</url></Content>
<float name="StudsPerTile">8</float>
<Content name="TexturePack"><url>rbxassetid://11122892249</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059b3</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX3B7FE9F70C56401CA8E16773E4F3C367">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://8444079627</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Pavement 3</string>
<Content name="NormalMap"><url>rbxassetid://8444080711</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8444081086</url></Content>
<float name="StudsPerTile">6</float>
<Content name="TexturePack"><url>rbxassetid://11122863729</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059b4</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX0835E270616E42E4A961D699BA68CA7F">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://8440790483</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Pavement 1</string>
<Content name="NormalMap"><url>rbxassetid://8440790876</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440791131</url></Content>
<float name="StudsPerTile">5</float>
<Content name="TexturePack"><url>rbxassetid://11122883540</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059b5</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX93442D80CEEB4F389093020B000BF621">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://8440329611</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Pavement 4</string>
<Content name="NormalMap"><url>rbxassetid://8440329817</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440329424</url></Content>
<float name="StudsPerTile">4</float>
<Content name="TexturePack"><url>rbxassetid://11123154563</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059b6</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD86825B6FB094047A385EEDAD5610A7C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://8440796907</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Pavement 5</string>
<Content name="NormalMap"><url>rbxassetid://8440797445</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://8440797748</url></Content>
<float name="StudsPerTile">4</float>
<Content name="TexturePack"><url>rbxassetid://10629154513</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059b7</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXD331889DE61646BD89218A79A2F869F0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11882920478</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11882920621</url></Content>
<string name="Name">Pavement 6</string>
<Content name="NormalMap"><url>rbxassetid://11882920683</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11882920915</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11882921115</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059b8</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX19ED221787BB42E7A4197F31F91C7465">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11882940824</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11882940920</url></Content>
<string name="Name">Pavement  7</string>
<Content name="NormalMap"><url>rbxassetid://11882941411</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11882941325</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11882941510</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059b9</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXEB5B8BB5328B45D7BCA78262C72C34B5">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11883851204</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883851104</url></Content>
<string name="Name">Pavement 8</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883852197</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883855453</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059ba</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXAF1C6C8446E346EBA0C88A7365409924">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11883913940</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883915874</url></Content>
<string name="Name">Pavement 9</string>
<Content name="NormalMap"><url>rbxassetid://11883915906</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883915584</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883916020</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059bb</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX5ABBDD15915244D3AA78A2E11661219E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11883923279</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883925721</url></Content>
<string name="Name">Pavement 10</string>
<Content name="NormalMap"><url>rbxassetid://11883925464</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883926323</url></Content>
<float name="StudsPerTile">12.5</float>
<Content name="TexturePack"><url>rbxassetid://11883926420</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059bc</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX8B4DA78BE68D4E4794E5D0DCBB7BBBD7">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11883932971</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883935224</url></Content>
<string name="Name">Pavement 11</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883933383</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883935315</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059bd</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA2AF6BF9DFD74E9DA3F930F007A9E676">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11883945537</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883946789</url></Content>
<string name="Name">Pavement 12</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883946272</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883946858</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059be</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX46214A18B9244171A994267E927714E9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11883952294</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883957488</url></Content>
<string name="Name">Pavement 13</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883953025</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883958400</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059bf</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX93C901738363421DB02A91E646FD0517">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11883961917</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><url>rbxassetid://11883963270</url></Content>
<string name="Name">Pavement 14</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><url>rbxassetid://11883962011</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11883963341</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059c0</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBXA4F8B5570F024FB28E77031964251CCD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11888221212</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Pavement 15</string>
<Content name="NormalMap"><null></null></Content>
<Content name="RoughnessMap"><url>rbxassetid://11888221329</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11888221640</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059c1</UniqueId>
</Properties>
</Item>
<Item class="MaterialVariant" referent="RBX2919869B07A14C9C8A391960CE5BE65E">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="BaseMaterial">836</token>
<Content name="ColorMap"><url>rbxassetid://11888329127</url></Content>
<token name="MaterialPattern">0</token>
<Content name="MetalnessMap"><null></null></Content>
<string name="Name">Pavement 16</string>
<Content name="NormalMap"><url>rbxassetid://11888333306</url></Content>
<Content name="RoughnessMap"><url>rbxassetid://11888331428</url></Content>
<float name="StudsPerTile">10</float>
<Content name="TexturePack"><url>rbxassetid://11888333521</url></Content>
<UniqueId name="UniqueId">7575113314a1bcc507ccf8a5000059c2</UniqueId>
</Properties>
</Item>
</Item>
<Item class="TextChatService" referent="RBX16D44E8126254DEFBCF91146F71AF75A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="ChatTranslationFTUXShown">true</bool>
<bool name="ChatTranslationToggleEnabled">false</bool>
<token name="ChatVersion">1</token>
<bool name="CreateDefaultCommands">true</bool>
<bool name="CreateDefaultTextChannels">true</bool>
<string name="Name">TextChatService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000312</UniqueId>
</Properties>
<Item class="ChatWindowConfiguration" referent="RBXC6B202A7AF0F4527B0A55B330ECBDA6A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="BackgroundColor3">
<R>0.0980392173</R>
<G>0.105882354</G>
<B>0.113725491</B>
</Color3>
<double name="BackgroundTransparency">0.2999999999999999889</double>
<bool name="Enabled">true</bool>
<Font name="FontFace">
<Family><url>rbxasset://fonts/families/BuilderSans.json</url></Family>
<Weight>500</Weight>
<Style>Normal</Style>
<CachedFaceId><url>rbxasset://fonts/BuilderSans-Medium.otf</url></CachedFaceId>
</Font>
<float name="HeightScale">1</float>
<token name="HorizontalAlignment">1</token>
<string name="Name">ChatWindowConfiguration</string>
<Color3 name="TextColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<int64 name="TextSize">18</int64>
<Color3 name="TextStrokeColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<double name="TextStrokeTransparency">0.5</double>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000377</UniqueId>
<token name="VerticalAlignment">1</token>
<float name="WidthScale">1</float>
</Properties>
</Item>
<Item class="ChatInputBarConfiguration" referent="RBX77A9EE0061C24CEEA7166C02B0CB4D4A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutocompleteEnabled">true</bool>
<Color3 name="BackgroundColor3">
<R>0.0980392173</R>
<G>0.105882354</G>
<B>0.113725491</B>
</Color3>
<double name="BackgroundTransparency">0.2000000000000000111</double>
<bool name="Enabled">true</bool>
<Font name="FontFace">
<Family><url>rbxasset://fonts/families/BuilderSans.json</url></Family>
<Weight>500</Weight>
<Style>Normal</Style>
<CachedFaceId><url>rbxasset://fonts/BuilderSans-Medium.otf</url></CachedFaceId>
</Font>
<token name="KeyboardKeyCode">47</token>
<string name="Name">ChatInputBarConfiguration</string>
<Color3 name="PlaceholderColor3">
<R>0.698039234</R>
<G>0.698039234</G>
<B>0.698039234</B>
</Color3>
<Ref name="TargetTextChannel">null</Ref>
<Color3 name="TextColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<int64 name="TextSize">18</int64>
<Color3 name="TextStrokeColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<double name="TextStrokeTransparency">0.5</double>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000378</UniqueId>
</Properties>
</Item>
<Item class="BubbleChatConfiguration" referent="RBX6DFB181E455A4A61A12CAB8BF792D52B">
<Properties>
<string name="AdorneeName">HumanoidRootPart</string>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="BackgroundColor3">
<R>0.980392158</R>
<G>0.980392158</G>
<B>0.980392158</B>
</Color3>
<double name="BackgroundTransparency">0.10000000000000000555</double>
<float name="BubbleDuration">15</float>
<float name="BubblesSpacing">6</float>
<bool name="Enabled">true</bool>
<token name="Font">47</token>
<Font name="FontFace">
<Family><url>rbxasset://fonts/families/BuilderSans.json</url></Family>
<Weight>500</Weight>
<Style>Normal</Style>
<CachedFaceId><url>rbxasset://fonts/BuilderSans-Medium.otf</url></CachedFaceId>
</Font>
<Vector3 name="LocalPlayerStudsOffset">
<X>0</X>
<Y>0</Y>
<Z>0</Z>
</Vector3>
<float name="MaxBubbles">3</float>
<float name="MaxDistance">100</float>
<float name="MinimizeDistance">40</float>
<string name="Name">BubbleChatConfiguration</string>
<bool name="TailVisible">true</bool>
<Color3 name="TextColor3">
<R>0.223529413</R>
<G>0.23137255</G>
<B>0.239215687</B>
</Color3>
<int64 name="TextSize">20</int64>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000379</UniqueId>
<float name="VerticalStudsOffset">0</float>
</Properties>
<Item class="UIGradient" referent="RBXEEF8D233F82F468BA82094CD2C565C36">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<ColorSequence name="Color">0 1 1 1 0 1 1 1 1 0 </ColorSequence>
<bool name="Enabled">false</bool>
<string name="Name">UIGradient</string>
<Vector2 name="Offset">
<X>0</X>
<Y>0</Y>
</Vector2>
<float name="Rotation">0</float>
<NumberSequence name="Transparency">0 0 0 1 0 0 </NumberSequence>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000037a</UniqueId>
</Properties>
</Item>
<Item class="ImageLabel" referent="RBXD3237C5118894875AB187F903C7B69DE">
<Properties>
<bool name="Active">false</bool>
<Vector2 name="AnchorPoint">
<X>0</X>
<Y>0</Y>
</Vector2>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoLocalize">true</bool>
<token name="AutomaticSize">0</token>
<Color3 name="BackgroundColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<float name="BackgroundTransparency">0</float>
<Color3 name="BorderColor3">
<R>0.105882362</R>
<G>0.164705887</G>
<B>0.207843155</B>
</Color3>
<token name="BorderMode">0</token>
<int name="BorderSizePixel">1</int>
<bool name="ClipsDescendants">false</bool>
<bool name="Draggable">false</bool>
<Content name="Image"><null></null></Content>
<Color3 name="ImageColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<Vector2 name="ImageRectOffset">
<X>0</X>
<Y>0</Y>
</Vector2>
<Vector2 name="ImageRectSize">
<X>0</X>
<Y>0</Y>
</Vector2>
<float name="ImageTransparency">0</float>
<bool name="Interactable">true</bool>
<int name="LayoutOrder">0</int>
<string name="Name">ImageLabel</string>
<Ref name="NextSelectionDown">null</Ref>
<Ref name="NextSelectionLeft">null</Ref>
<Ref name="NextSelectionRight">null</Ref>
<Ref name="NextSelectionUp">null</Ref>
<UDim2 name="Position">
<XS>0</XS>
<XO>0</XO>
<YS>0</YS>
<YO>0</YO>
</UDim2>
<token name="ResampleMode">0</token>
<Ref name="RootLocalizationTable">null</Ref>
<float name="Rotation">0</float>
<token name="ScaleType">0</token>
<bool name="Selectable">false</bool>
<token name="SelectionBehaviorDown">0</token>
<token name="SelectionBehaviorLeft">0</token>
<token name="SelectionBehaviorRight">0</token>
<token name="SelectionBehaviorUp">0</token>
<bool name="SelectionGroup">false</bool>
<Ref name="SelectionImageObject">null</Ref>
<int name="SelectionOrder">0</int>
<UDim2 name="Size">
<XS>0</XS>
<XO>100</XO>
<YS>0</YS>
<YO>100</YO>
</UDim2>
<token name="SizeConstraint">0</token>
<Rect2D name="SliceCenter">
<Min>
<X>0</X>
<Y>0</Y>
</Min>
<Max>
<X>0</X>
<Y>0</Y>
</Max>
</Rect2D>
<float name="SliceScale">1</float>
<UDim2 name="TileSize">
<XS>1</XS>
<XO>0</XO>
<YS>1</YS>
<YO>0</YO>
</UDim2>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000037b</UniqueId>
<bool name="Visible">true</bool>
<int name="ZIndex">1</int>
</Properties>
</Item>
<Item class="UICorner" referent="RBX7F63C350C92141E1B29DA52D38F72A38">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<UDim name="CornerRadius">
<S>0</S>
<O>12</O>
</UDim>
<string name="Name">UICorner</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000037c</UniqueId>
</Properties>
</Item>
<Item class="UIPadding" referent="RBXD6ADF543A8F24EBF91C955EABF3C59AF">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">UIPadding</string>
<UDim name="PaddingBottom">
<S>0</S>
<O>8</O>
</UDim>
<UDim name="PaddingLeft">
<S>0</S>
<O>8</O>
</UDim>
<UDim name="PaddingRight">
<S>0</S>
<O>8</O>
</UDim>
<UDim name="PaddingTop">
<S>0</S>
<O>8</O>
</UDim>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000037d</UniqueId>
</Properties>
</Item>
</Item>
<Item class="ChannelTabsConfiguration" referent="RBXFFD58F37A2D84CE48E90E11FEBC93593">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<Color3 name="BackgroundColor3">
<R>0.0980392173</R>
<G>0.105882354</G>
<B>0.113725491</B>
</Color3>
<double name="BackgroundTransparency">0</double>
<bool name="Enabled">false</bool>
<Font name="FontFace">
<Family><url>rbxasset://fonts/families/BuilderSans.json</url></Family>
<Weight>700</Weight>
<Style>Normal</Style>
<CachedFaceId><url>rbxasset://fonts/BuilderSans-Bold.otf</url></CachedFaceId>
</Font>
<Color3 name="HoverBackgroundColor3">
<R>0.490196079</R>
<G>0.490196079</G>
<B>0.490196079</B>
</Color3>
<string name="Name">ChannelTabsConfiguration</string>
<Color3 name="SelectedTabTextColor3">
<R>1</R>
<G>1</G>
<B>1</B>
</Color3>
<Color3 name="TextColor3">
<R>0.686274529</R>
<G>0.686274529</G>
<B>0.686274529</B>
</Color3>
<int64 name="TextSize">18</int64>
<Color3 name="TextStrokeColor3">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<double name="TextStrokeTransparency">1</double>
<UniqueId name="UniqueId">04a578b5603d581307ff1b2a0000039e</UniqueId>
</Properties>
</Item>
</Item>
<Item class="PermissionsService" referent="RBXEBEB240285CA4A2392DBCDAB8D2AB502">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">PermissionsService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000314</UniqueId>
</Properties>
</Item>
<Item class="PlayerEmulatorService" referent="RBX7F942BB5617746149E828A6284D11F0D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="CustomPoliciesEnabled">false</bool>
<string name="EmulatedCountryCode"></string>
<string name="EmulatedGameLocale"></string>
<string name="Name">PlayerEmulatorService</string>
<bool name="PlayerEmulationEnabled">false</bool>
<bool name="PseudolocalizationEnabled">false</bool>
<BinaryString name="SerializedEmulatedPolicyInfo"></BinaryString>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000315</UniqueId>
</Properties>
</Item>
<Item class="StudioData" referent="RBXD53EBDEB86454FFDA14EDC3E1C0868B8">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="EnableScriptCollabByDefaultOnLoad">false</bool>
<string name="Name">StudioData</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000319</UniqueId>
</Properties>
</Item>
]]
	local stringValue4 = Instance.new("StringValue", stringValue)
	stringValue4.Name = "StarterPlayer"
	local v10 = v9 .. Merge([[
<Item class="StarterPlayer" referent="RBXFF297DFE97F64892913189038CA3C8F2">
<Properties>
<bool name="AllowCustomAnimations">true</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoJumpEnabled">true</bool>
<token name="AvatarJointUpgrade_SerializedRollout">1</token>
<float name="CameraMaxZoomDistance">128</float>
<float name="CameraMinZoomDistance">0.5</float>
<token name="CameraMode">0</token>
<float name="CharacterJumpHeight">7.19999981</float>
<float name="CharacterJumpPower">50</float>
<float name="CharacterMaxSlopeAngle">89</float>
<bool name="CharacterUseJumpPower">false</bool>
<float name="CharacterWalkSpeed">16</float>
<token name="DevCameraOcclusionMode">0</token>
<token name="DevComputerCameraMovementMode">0</token>
<token name="DevComputerMovementMode">0</token>
<token name="DevTouchCameraMovementMode">0</token>
<token name="DevTouchMovementMode">0</token>
<token name="EnableDynamicHeads">0</token>
<bool name="EnableMouseLockOption">true</bool>
<int64 name="GameSettingsAssetIDFace">0</int64>
<int64 name="GameSettingsAssetIDHead">0</int64>
<int64 name="GameSettingsAssetIDLeftArm">0</int64>
<int64 name="GameSettingsAssetIDLeftLeg">0</int64>
<int64 name="GameSettingsAssetIDPants">0</int64>
<int64 name="GameSettingsAssetIDRightArm">0</int64>
<int64 name="GameSettingsAssetIDRightLeg">0</int64>
<int64 name="GameSettingsAssetIDShirt">0</int64>
<int64 name="GameSettingsAssetIDTeeShirt">0</int64>
<int64 name="GameSettingsAssetIDTorso">0</int64>
<token name="GameSettingsAvatar">1</token>
<token name="GameSettingsR15Collision">0</token>
<NumberRange name="GameSettingsScaleRangeBodyType">0 1 </NumberRange>
<NumberRange name="GameSettingsScaleRangeHead">0.95 1 </NumberRange>
<NumberRange name="GameSettingsScaleRangeHeight">0.9 1.05 </NumberRange>
<NumberRange name="GameSettingsScaleRangeProportion">0 1 </NumberRange>
<NumberRange name="GameSettingsScaleRangeWidth">0.7 1 </NumberRange>
<float name="HealthDisplayDistance">100</float>
<bool name="LoadCharacterAppearance">true</bool>
<token name="LoadCharacterLayeredClothing">0</token>
<token name="LuaCharacterController">0</token>
<string name="Name">StarterPlayer</string>
<float name="NameDisplayDistance">100</float>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000031b</UniqueId>
<bool name="UserEmotesEnabled">true</bool>
</Properties>
]], data.StarterPlayer, stringValue4)
	local stringValue5 = Instance.new("StringValue", stringValue)
	stringValue5.Name = "StarterPack"
	local v11 = v10 .. Merge([[
<Item class="StarterPack" referent="RBX60CAC18C150440C29449501E3B970F36">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">StarterPack</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000031c</UniqueId>
</Properties>
]], data.StarterPack, stringValue5)
	local stringValue6 = Instance.new("StringValue", stringValue)
	stringValue6.Name = "StarterGui"
	local v12 = (v11 .. Merge([[
<Item class="StarterGui" referent="RBX2FB56F8A35774CC2A5029BAE87DA0109">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">StarterGui</string>
<bool name="ResetPlayerGuiOnSpawn">true</bool>
<token name="RtlTextSupport">0</token>
<token name="ScreenOrientation">4</token>
<bool name="ShowDevelopmentGui">true</bool>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000031d</UniqueId>
<token name="VirtualCursorMode">0</token>
</Properties>
]], data.StarterGui, stringValue6)) .. [[
<Item class="LocalizationService" referent="RBX5D0B7BE73EBB4DDEBBE8D4A80BE05A02">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">LocalizationService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000321</UniqueId>
</Properties>
</Item>
<Item class="TeleportService" referent="RBX87C57C475B554062A910000787B78EDD">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Teleport Service</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000324</UniqueId>
</Properties>
</Item>
<Item class="CollectionService" referent="RBX13FAFE8CF565489DB81BF8505D39EAF2">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">CollectionService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000326</UniqueId>
</Properties>
</Item>
<Item class="PhysicsService" referent="RBXF4ECDEAC3B4E43CAB36B182697622C5C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">PhysicsService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000327</UniqueId>
</Properties>
</Item>
<Item class="InsertService" referent="RBXF8B4063E068140408D52CA32B74748D5">
<Properties>
<bool name="AllowClientInsertModels">false</bool>
<bool name="AllowInsertFreeModels">false</bool>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">InsertService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000032b</UniqueId>
</Properties>
<Item class="StringValue" referent="RBX73A3E5921B4640F6A13C75999DCB012A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">InsertionHash</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000371</UniqueId>
<string name="Value">{8B47742A-C399-4BC8-9300-B0980A51FD5B}</string>
</Properties>
</Item>
</Item>
<Item class="GamePassService" referent="RBXF9491FDD421B4D149A59EC525ED71CB9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">GamePassService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000032c</UniqueId>
</Properties>
</Item>
<Item class="Debris" referent="RBXC1574915E9EF4DF09AF400CC9442E3D1">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<int name="MaxItems">1000</int>
<string name="Name">Debris</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000032d</UniqueId>
</Properties>
</Item>
<Item class="CookiesService" referent="RBXE9E8FF74BDA047E38F117AC711432693">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">CookiesService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000032e</UniqueId>
</Properties>
</Item>
<Item class="Selection" referent="RBXFBC12B4C05244EA7BEB436DC8BE4B195">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Selection</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000330</UniqueId>
</Properties>
</Item>
<Item class="VRService" referent="RBX73FB3CA81C8C4FCF80617966D27B67FA">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<token name="AutomaticScaling">0</token>
<bool name="AvatarGestures">false</bool>
<bool name="FadeOutViewOnCollision">true</bool>
<string name="Name">VRService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000334</UniqueId>
</Properties>
</Item>
<Item class="ContextActionService" referent="RBXE043DF27BCF54275AA526B134054F983">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">ContextActionService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000335</UniqueId>
</Properties>
</Item>
<Item class="ScriptService" referent="RBXC19B5C9A717645859B5AE75BCB6F21BE">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Instance</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000336</UniqueId>
</Properties>
</Item>
<Item class="AssetService" referent="RBXBF005A1D5A99400399DE9F35E101543D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">AssetService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000337</UniqueId>
</Properties>
</Item>
<Item class="TouchInputService" referent="RBX1342144B42864DCA945E119C2A1B4ACC">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">TouchInputService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000338</UniqueId>
</Properties>
</Item>
]]
	local stringValue7 = Instance.new("StringValue", stringValue)
	stringValue7.Name = "ServerScriptService"
	local v13 = v12 .. Merge([[
<Item class="ServerScriptService" referent="RBXAB6D17A1E059481BA4ABD8E2189D6E37">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="LoadStringEnabled">false</bool>
<string name="Name">ServerScriptService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000033d</UniqueId>
</Properties>
]], data.ServerScriptService, stringValue7)
	local stringValue8 = Instance.new("StringValue", stringValue)
	stringValue8.Name = "ServerStorage"
	local v14 = v13 .. Merge([[
<Item class="ServerStorage" referent="RBXC65B175F95E84F8181E036C284FF012D">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">ServerStorage</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000033e</UniqueId>
</Properties>
]], data.ServerStorage, stringValue8)
	local stringValue9 = Instance.new("StringValue", stringValue)
	stringValue9.Name = "ReplicatedStorage"
	local v15 = (v14 .. Merge([[
<Item class="ReplicatedStorage" referent="RBX30737BFDB51D4066A2369C25477D4725">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">ReplicatedStorage</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000033f</UniqueId>
</Properties>
]], data.ReplicatedStorage, stringValue9)) .. [[
<Item class="LuaWebService" referent="RBX247C1780533949A68FBBA73646EF98E0">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">LuaWebService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000345</UniqueId>
</Properties>
</Item>
<Item class="ProcessInstancePhysicsService" referent="RBX8CCB1406BE8145DA9E886C4D3BC44B86">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">ProcessInstancePhysicsService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000347</UniqueId>
</Properties>
</Item>
<Item class="DataStoreService" referent="RBX8A1F2B68F7CE49ECA4169F0AD5305641">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutomaticRetry">true</bool>
<bool name="LegacyNamingScheme">false</bool>
<string name="Name">DataStoreService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000360</UniqueId>
</Properties>
</Item>
<Item class="HttpService" referent="RBX57480EF6BA24477580D9C8B4FB06C421">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="HttpEnabled">true</bool>
<string name="Name">HttpService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a0000035e</UniqueId>
</Properties>
</Item>
]]
	local stringValue10 = Instance.new("StringValue", stringValue)
	stringValue10.Name = "Lighting"
	local v16 = v15 .. Merge([[
<Item class="Lighting" referent="RBX86067735443946F1AEB7C41450A1559E">
<Properties>
<Color3 name="Ambient">
<R>0.274509817</R>
<G>0.274509817</G>
<B>0.274509817</B>
</Color3>
<BinaryString name="AttributesSerialize"></BinaryString>
<float name="Brightness">3</float>
<Color3 name="ColorShift_Bottom">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<Color3 name="ColorShift_Top">
<R>0</R>
<G>0</G>
<B>0</B>
</Color3>
<float name="EnvironmentDiffuseScale">1</float>
<float name="EnvironmentSpecularScale">1</float>
<float name="ExposureCompensation">0</float>
<Color3 name="FogColor">
<R>0.752941251</R>
<G>0.752941251</G>
<B>0.752941251</B>
</Color3>
<float name="FogEnd">100000</float>
<float name="FogStart">0</float>
<float name="GeographicLatitude">0</float>
<bool name="GlobalShadows">true</bool>
<string name="Name">Lighting</string>
<Color3 name="OutdoorAmbient">
<R>0.274509817</R>
<G>0.274509817</G>
<B>0.274509817</B>
</Color3>
<bool name="Outlines">false</bool>
<float name="ShadowSoftness">0.200000003</float>
<token name="Technology">4</token>
<string name="TimeOfDay">14:30:00</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000361</UniqueId>
</Properties>
]], data.Lighting, stringValue10)
	local stringValue11 = Instance.new("StringValue", stringValue)
	stringValue11.Name = "Teams"
	local v17 = (v16 .. Merge([[
<Item class="Teams" referent="RBXE69C48FD499E493FB202410F7233624C">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Teams</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000364</UniqueId>
</Properties>
]], data.Teams, stringValue11)) .. [[
<Item class="LodDataService" referent="RBX1AF31298A6774B62903F79830370EE84">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">Instance</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000362</UniqueId>
</Properties>
</Item>
<Item class="ProximityPromptService" referent="RBXFD3D15FC406540DEB8D68C970C93DA83">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="Enabled">true</bool>
<int name="MaxPromptsVisible">16</int>
<string name="Name">ProximityPromptService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000363</UniqueId>
</Properties>
</Item>
<Item class="ServiceVisibilityService" referent="RBX6165B398479F4850996C5C8111DFD00A">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<BinaryString name="HiddenServices">AAAAAA==</BinaryString>
<string name="Name">ServiceVisibilityService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a000040cd</UniqueId>
<BinaryString name="VisibleServices">AAAAAA==</BinaryString>
</Properties>
</Item>
<Item class="TestService" referent="RBXB0D07A9A15AB43D89DD6E30F917A8455">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<bool name="AutoRuns">true</bool>
<string name="Description"></string>
<bool name="ExecuteWithStudioRun">false</bool>
<bool name="IsSleepAllowed">true</bool>
<string name="Name">TestService</string>
<int name="NumberOfPlayers">0</int>
<double name="SimulateSecondsLag">0</double>
<bool name="ThrottlePhysicsToRealtime">true</bool>
<double name="Timeout">10</double>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000365</UniqueId>
</Properties>
</Item>
<Item class="UGCAvatarService" referent="RBX921F0E0989754FC5AB332327453F8911">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">UGCAvatarService</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000366</UniqueId>
</Properties>
</Item>
<Item class="VideoService" referent="RBXF8F7BD0CF16A44E1ABA9BD6364517E84">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">VideoService</string>
<UniqueId name="UniqueId">7bdf20b295fbe64d0689445400004366</UniqueId>
</Properties>
</Item>
<Item class="VirtualInputManager" referent="RBXB6E1E86A1B264763A19631B45C8F39A9">
<Properties>
<BinaryString name="AttributesSerialize"></BinaryString>
<string name="Name">VirtualInputManager</string>
<UniqueId name="UniqueId">706ce791354c7e1f067d8f5a00000367</UniqueId>
</Properties>
</Item>
<SharedStrings>
<SharedString md5="yuZpQdnvvUBOTYh1jqZ2cA=="></SharedString>
]]

	if flag3 then
		v17 ..= [[
<SharedString md5="1D7D8b2OQKeIlZaCtF26QA==">Q1NHUEhTBwAAAAH/HThJB30PtoNOQ8EXsbwzNRDHTlY52kAtPqTJBkY+T58Xg0M2EMdOEAAA
AAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAACAP34AAAAEAAAAAHL0QvT/x8Hg
lwzBAHL0wvT/x8HglwzB5JcMwen/x8EAcvTC3pcMQf7/x8EAcvRCpPgxwlYQxsGV/t3Clf7d
wlsQxsGj+DHCL0N2wt35wcEdc8HCpd3twryPx8ETaNRBE2jUwcOPx8Gl3e1Clf7dwmMQxsGk
+DFCrhOSQLbqwEESyb6/0EqcQNViukHXSpxApd3tQryPx8ETaNRBlf7dQmMQxsGk+DFCHXPB
Qur5wcEtQ3ZCo/gxQmcQxsGV/t1CpPgxwmcQxsGV/t1CNsm+v7PqwEG1E5JAL0N2wu35wcEd
c8FCo/gxQlYQxsGV/t3CLUN2Qt35wcEdc8HClf7dQlsQxsGj+DHCEWjUQa+Px8Gl3e3CLUN2
Qu35wcEcc8FCHXPBQuD5wcEtQ3bCHXPBwur5wcEtQ3ZCHXPBwuD5wcEtQ3bCpd3tQrePx8ER
aNTBEWjUQcOPx8Gl3e1Cpd3twrePx8ERaNTBE2jUwa+Px8Gl3e3CWoCuPwEAyEF8gK4/shOS
wLnqwEFEyb4/JMm+P7bqwEGpE5LA5JcMwf7/x8EAcvRCAHL0wvX/x8HhlwxB3pcMQen/x8EA
cvTCAHL0QvX/x8HhlwxB0kqcwNhiukHKSpzAboCuvwEAyEFLgK6/boCuvwEAyEF8gK4/XYCu
PwEAyEFLgK6/8AAAAAAAAAABAAAAAgAAAAEAAAAAAAAAAwAAAAQAAAAFAAAABgAAAAcAAAAI
AAAACQAAAAoAAAALAAAADAAAAA0AAAAMAAAACwAAAA0AAAALAAAADgAAAA0AAAAOAAAADwAA
AA0AAAAPAAAADAAAABAAAAAIAAAAEQAAABAAAAARAAAAEgAAABAAAAASAAAACQAAABAAAAAJ
AAAACAAAABMAAAAUAAAAFQAAABMAAAAVAAAAFgAAABcAAAAPAAAADgAAABcAAAAOAAAACwAA
ABcAAAALAAAADwAAABgAAAAVAAAAFAAAABgAAAAUAAAACgAAABgAAAAKAAAAFQAAABkAAAAJ
AAAAEgAAABkAAAASAAAAEQAAABoAAAAGAAAABQAAABsAAAAVAAAACgAAABsAAAAKAAAAAAAA
ABsAAAAAAAAAFgAAABsAAAAWAAAAFQAAABwAAAALAAAAEQAAABwAAAARAAAAAwAAABwAAAAP
AAAACwAAABwAAAADAAAADAAAABwAAAAMAAAADwAAAB0AAAAFAAAABAAAAB0AAAACAAAAAQAA
AB4AAAACAAAAHQAAAB4AAAAdAAAABAAAAB8AAAARAAAACwAAAB8AAAALAAAACgAAACAAAAAd
AAAAAQAAACAAAAAJAAAAGQAAACAAAAAZAAAAEQAAACAAAAAHAAAACQAAACEAAAACAAAAHgAA
ACEAAAAKAAAAFAAAACEAAAAUAAAAEwAAACEAAAATAAAAFgAAACIAAAADAAAAEQAAACIAAAAR
AAAACAAAACIAAAAIAAAABwAAACIAAAABAAAAAwAAACMAAAABAAAAIgAAACMAAAAiAAAABwAA
ACMAAAAHAAAAIAAAACMAAAAgAAAAAQAAACQAAAACAAAAIQAAACQAAAAhAAAAFgAAACQAAAAA
AAAAAgAAACQAAAAWAAAAAAAAACUAAAAAAAAACgAAACUAAAAKAAAADAAAACUAAAADAAAAAAAA
ACUAAAAMAAAAAwAAACYAAAAnAAAAIQAAACYAAAAhAAAAHgAAACYAAAAdAAAAIAAAACYAAAAg
AAAAJwAAACYAAAAeAAAABAAAACYAAAAFAAAAHQAAACYAAAAaAAAABQAAACYAAAAGAAAAGgAA
ACYAAAAEAAAABgAAACgAAAAnAAAAIAAAACgAAAAgAAAAEQAAACgAAAARAAAAHwAAACgAAAAf
AAAAJwAAACkAAAAKAAAAIQAAACkAAAAhAAAAJwAAACkAAAAnAAAAHwAAACkAAAAfAAAACgAA
AA==</SharedString>
]]
	end

	if flag2 then
		v17 ..= [[
<SharedString md5="kQKaxv8mWRIpK+JT72YbkQ==">Q1NHUEhTBwAAAAFK2rJFc1oJP6APnz5JJuK+VugUSJz3gcb17ZVGvdyFSRqDP8fHo4dJEAAA
AAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAACAP64AAAAEAAAAgzrBwe9X3MAJ
98LAJ8tAwVVVuUAgbWjAbX21wasR48ACldPAcInHQesk0796CrE/SYu/QQYXyMAOcdG/0aO+
QZDP7cDREfzA76K7wfvZokCOV+tAEjS2wQBEe0D9yARBZfnBQc6GwEAuCd5A15y6QWkL60Di
YrBAIVNPwUq600BJkElAFUS7wQGgqUDH14lAnkfDwYEbeUBJdwFBoDbGQcEb5ECMXYtAYPse
wU9t88DXDvLASfSxQVTy58D9yATB0msdQeJpZkC1W3bAvZWlQZLd5EBmGgW/Kuy/wd0GssBv
OZG+5YzFwVv+2cDqnAzA3dSoQdo5e0AX3jDAlXfDwdebmkBTd9dAJ+fCQYgYOsA0fo8/v/3H
wfI6er8drIE/inzEwcz1Z0BS6BtAAADIwU4DnsAJHoW+cr7FQZXG70B5gx5AE6XCQe+C50D3
dpE/hgjBQU9t80DP9Os/aZKoQayduMCPCADB1ZrEwW0w48AmDHHARv+lwYrrYT8Rlx3A6DRY
wWFPukB5Lj7Ah4zDwaOmnEDTfopAw/2YwX1c3sD/muHA4w/QwMdF2EApNRk/2V0LweH57cBw
4PjAAADIQTxXo0DSM0lAIvH5P1b/30C+MJ1AF0rEQQG470BD0HJAkPbMQFbv7EC5z2dA48HC
QYh4gMBGdJ8+ER+wQTG1hkBxrg7AvJy+QTz71cDkg0zAgWzGwX70IUDmVD5AucCpwVPX6MBa
d9nAPfOIwaVIwUC8fAZAw2wkwLxo4UCOMIRAlK2mQfiC7UAs5sg+MKWsQHEX60D4+IVAj0vH
QZ6MgUCK+WtA3k/CwYEooUAWnJtALkqtQcAG3UB1uc6+5jLFQfKxxkDdcqxAxtKkQH5G6kBd
/xdAPGTFQXyzKEByWJ89x6NTwas7tkDnQ1DAaumoQUmK6kDqWyG9UAEAAAAAAAABAAAAAgAA
AAMAAAAEAAAABQAAAAYAAAAHAAAACAAAAAYAAAAIAAAACQAAAAYAAAAKAAAACwAAAAYAAAAM
AAAABwAAAA0AAAAJAAAACAAAAA4AAAAPAAAABQAAABAAAAABAAAAEQAAABIAAAAHAAAADAAA
ABIAAAAEAAAABwAAABIAAAATAAAABAAAABQAAAAQAAAAEQAAABUAAAAMAAAABgAAABYAAAAD
AAAACAAAABYAAAAIAAAABwAAABcAAAAYAAAAAAAAABkAAAAMAAAAFwAAABkAAAATAAAAEgAA
ABkAAAASAAAADAAAABoAAAAbAAAAHAAAABoAAAAFAAAAGwAAAB0AAAAFAAAADwAAAB0AAAAU
AAAABQAAAB0AAAAQAAAAFAAAAB0AAAABAAAAEAAAAB4AAAAXAAAAAAAAAB4AAAAZAAAAFwAA
AB4AAAATAAAAGQAAAB4AAAAAAAAAAgAAAB8AAAAAAAAAGAAAACAAAAAfAAAAGAAAACAAAAAh
AAAACwAAACAAAAAYAAAAIQAAACIAAAACAAAAAQAAACMAAAABAAAAIAAAACMAAAAgAAAACgAA
ACQAAAAiAAAAAQAAACQAAAABAAAAHQAAACQAAAAPAAAADgAAACQAAAAdAAAADwAAACUAAAAa
AAAADQAAACYAAAAGAAAACQAAACcAAAAaAAAAHAAAACcAAAAJAAAADQAAACcAAAANAAAAGgAA
ACcAAAAoAAAACQAAACcAAAAcAAAAKAAAACkAAAAHAAAABAAAACkAAAAWAAAABwAAACkAAAAE
AAAAAwAAACkAAAADAAAAFgAAACoAAAAbAAAABQAAACoAAAAFAAAAFAAAACsAAAAOAAAABQAA
ACsAAAAeAAAADgAAACsAAAATAAAAHgAAACsAAAAEAAAAEwAAACsAAAAFAAAABAAAACwAAAAM
AAAAFQAAACwAAAAXAAAADAAAACwAAAAVAAAAIQAAACwAAAAhAAAAGAAAACwAAAAYAAAAFwAA
AC0AAAAiAAAAJAAAAC0AAAAkAAAADgAAAC0AAAACAAAAIgAAAC0AAAAOAAAAHgAAAC0AAAAe
AAAAAgAAAC4AAAALAAAACgAAAC4AAAAKAAAAIAAAAC4AAAAgAAAACwAAAC8AAAAoAAAACgAA
AC8AAAAKAAAABgAAAC8AAAAGAAAAJgAAADAAAAABAAAAIwAAADEAAAAoAAAALwAAADEAAAAv
AAAAJgAAADEAAAAJAAAAKAAAADEAAAAmAAAACQAAADIAAAAIAAAAAwAAADIAAAADAAAAJQAA
ADMAAAALAAAAIQAAADMAAAAhAAAAFQAAADMAAAAGAAAACwAAADMAAAAVAAAABgAAADQAAAAU
AAAAEQAAADQAAAAqAAAAFAAAADQAAAARAAAAGwAAADQAAAAbAAAAKgAAADUAAAAlAAAADQAA
ADUAAAAyAAAAJQAAADUAAAANAAAACAAAADUAAAAIAAAAMgAAADYAAAAwAAAAIwAAADYAAAAo
AAAAHAAAADYAAAAcAAAAMAAAADYAAAAKAAAAKAAAADYAAAAjAAAACgAAADcAAAAFAAAAGgAA
ADcAAAAaAAAAJQAAADcAAAADAAAABQAAADcAAAAlAAAAAwAAADgAAAAAAAAAHwAAADgAAAAf
AAAAIAAAADgAAAABAAAAAAAAADgAAAAgAAAAAQAAADkAAAAwAAAAHAAAADkAAAARAAAAAQAA
ADkAAAABAAAAMAAAADkAAAAbAAAAEQAAADkAAAAcAAAAGwAAAA==</SharedString>
]]
	end

	if flag then
		v17 ..= [[
<SharedString md5="NzEJpNX4wSzxfnBpqUsM9w==">Q1NHUEhTBwAAAAFE1ZtGw+t0v/Y3isCYV7Q/R6gDSgdJukfdGYpIsQlqSp5lwceGXStKEAAA
AAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAACAPzIBAAAEAAAAibC9wPoAH8Ag
32HBgESIwX62OcEnE2HBSo1GwRx9C7+mAQDBoFy3QaF7PMEfbv5AuM2lQXenQsFKSCVBXC7H
QWCUO8HI1UK+9qluQAP+qj7tbG/BqCWUQIW3WEB0lz3BAb4pQYMUpsCsFo3B/9yDQIdFO8Hx
kqzBoM0TQDt2Sz8UT29B8CPCQI75a0BD8ilBpbQCwbadwUDfB3tBStg5QIxrPMFGE6hBEkNJ
QejGP8G164tB7WlMQU+tMMAmllrB1OyqQFX0okBEyBnBkopYQX5BBj/NrwTB+Q2HPpjSOsFN
ravByKmrwMB4O8FoZZ/BYb9wwWiHOsEbKaBBu+FNwXi2OsFUv6ZBMTUgwUbhEUHKnE1BLLCO
wfmSOsFQwoxBPBZ9QcSaU79JHBNB5W0twHenQkFda75AbH/twApvE0E+bUNBmOJfwMo5KEE3
UqI/cRS9wKsxI0Fkka8/YmC3wWNesL8UyQBAY63GwWmMP8FM2YK/avzHwWfZOcGfeZg/hJvE
wSKLP8FCOLRAagXBwdPHO8HNUvNAlr6CQfA+QsGqOHBB+B/HQeNOO8EP/5nAg7mIQUWAhT7p
IAy/aVaeQe2kMsASf/1Adi3CQdHsOsE7Se/AeF5FwQi2OsGJu4bBtzTEwfQUO8EhwS3AB6mY
QW8wSsCQEg9BQEKfQXVSO8FnHDhBekBfwTi4BECvhWnAv5Kkwago8r0LnzG/iC68wGLTjkDF
7sLABs0Hwc8D70BxNGpB4w+OwVpLOcHtWFjBeNKAwUYty79sjcbAMOImwUJ0GkF+2j1Bzvoh
warhIkGZnDFBlnyzwR6EKb9xq88/eZyowYyQOsHw/F1BSgC0wVDXdL8EaoU/v52UwUIfPcEk
wkbB1OO2wemvO8Gj0StBVJ9UQQS/kD/R8+rAXDRAQb90scCeh4bBKwOvQQbYOsFzczPB7eWf
QdYzO8FmHVTBGnNiQbh5OsFKuozBQAGHQfGugb+qcAlBT8q7QVH8OsEya8tAdnJtQW5iQcF1
3YFBTHbNQCFPO8GEyarBJcQHQf77OsENO6bBImAtwaN3AEHCAElAWqIhwc/aGkGdYslAh0WG
QEfQZj+OH2jBTWoswXCpPcFWaYvB+R8NwUya0kDN2HJBXj6vwQmtmr7s+IM/7Z7svk+bPsEj
FaxBB/tvQfnlIT8BHKHAxdDGwY1RP8GgMzFAso2HwHGDLUGqcQxA/CWgwWBkOsGJeXRBQA9C
wdBk+z8oW6fAg6RowbmzO8H1FHrBb8C/wTDfO8G1TIjAYqu5wRdUO8GTh7TAAADIQW/5OsGr
XNa/zFk3QVnPoMB3sofBigC3wPusNUE1pK1AX4bzwKVGL0FMhclAm9meQBKsgEDvQzLBboUe
wTAZv76DThfBcca+QZLdOsEZrAXBtCggwXIpG0EsFkFBMdPFQT+wOsGguL3An/ZEQU/cOsEc
55XBj8v/wKw/iUAn6IJBLX8YwOzSPMG/daxB1fIjwQ89O8GDSapBuW3BwBYkO8Geb6xB4jiK
QViwi7/aLgJBsI2FwP0PPkFkaMtACrWmwXkcO8E+uhPB58+fwCb4DEFmc3O/gzOKwDdxPcHx
kqxBpMUDwcmoK0FOZspAzdvFwW2bOsGF7IxAWAIAAAAAAAABAAAAAgAAAAMAAAAEAAAABQAA
AAYAAAAAAAAABwAAAAYAAAAIAAAACQAAAAoAAAALAAAADAAAAAoAAAAMAAAADQAAAAoAAAAN
AAAADgAAAA8AAAAQAAAAEQAAABIAAAATAAAAAAAAABIAAAAAAAAABgAAABIAAAAGAAAACQAA
ABQAAAAVAAAADAAAABQAAAAWAAAAFwAAABgAAAALAAAACgAAABgAAAAKAAAADgAAABgAAAAZ
AAAACwAAABoAAAALAAAAGQAAABsAAAAZAAAAEAAAABsAAAAQAAAAHAAAAB0AAAAeAAAAHwAA
ACAAAAAhAAAAHQAAACAAAAAUAAAAFwAAACAAAAAeAAAABAAAACAAAAAEAAAAIgAAACMAAAAk
AAAAJQAAACMAAAAFAAAABAAAACMAAAAEAAAAJgAAACcAAAAAAAAAEwAAACgAAAAeAAAAHQAA
ACkAAAAYAAAADgAAACkAAAADAAAAJQAAACoAAAADAAAAKQAAACoAAAApAAAAIgAAACoAAAAE
AAAAAwAAACoAAAAiAAAABAAAACsAAAAsAAAAHAAAAC0AAAAHAAAAAAAAAC4AAAAaAAAAFgAA
AC4AAAAMAAAACwAAAC4AAAALAAAAGgAAAC8AAAACAAAAAQAAADAAAAACAAAALwAAADAAAAAv
AAAALAAAADAAAAAsAAAAKwAAADAAAAArAAAAAgAAADEAAAAyAAAAMwAAADEAAAAzAAAAHQAA
ADEAAAA0AAAAFgAAADEAAAAdAAAANAAAADUAAAAsAAAALwAAADUAAAAoAAAAHQAAADUAAAAd
AAAAMwAAADYAAAAvAAAAAQAAADcAAAAhAAAAIAAAADcAAAAgAAAANAAAADcAAAA0AAAAHQAA
ADcAAAAdAAAAIQAAADgAAAARAAAAEAAAADkAAAAPAAAAOgAAADkAAAA6AAAAOwAAADkAAAA7
AAAAPAAAADkAAAA8AAAACAAAAD0AAAAYAAAAKQAAAD0AAAApAAAAJQAAAD0AAAAZAAAAGAAA
AD4AAAAFAAAAJQAAAD4AAAAlAAAAAwAAAD4AAAADAAAABQAAAD8AAAAiAAAAKQAAAD8AAAAp
AAAADgAAAEAAAAA7AAAABAAAAEAAAAAJAAAACAAAAEAAAAAIAAAAQQAAAEIAAABDAAAAHAAA
AEIAAAAcAAAALAAAAEQAAAAIAAAABgAAAEQAAAAGAAAABwAAAEUAAAAJAAAAQAAAAEUAAABA
AAAABAAAAEUAAAAEAAAAHgAAAEUAAAAeAAAANgAAAEUAAAAnAAAAEwAAAEUAAAATAAAAEgAA
AEUAAAASAAAACQAAAEYAAAAMAAAALgAAAEYAAAAuAAAAFgAAAEYAAAAWAAAAFAAAAEYAAAAU
AAAADAAAAEcAAABDAAAAQgAAAEcAAABCAAAALAAAAEcAAAAsAAAANQAAAEcAAAA1AAAAMwAA
AEcAAAAzAAAAMgAAAEcAAAAyAAAAQwAAAEgAAAAOAAAADQAAAEgAAAA/AAAADgAAAEgAAAAi
AAAAPwAAAEgAAAAgAAAAIgAAAEkAAAA4AAAAEAAAAEkAAAARAAAAOAAAAEkAAAAZAAAAJAAA
AEkAAAAQAAAAGQAAAEkAAAAmAAAAEQAAAEkAAAAkAAAAJgAAAEoAAAAfAAAAHgAAAEoAAAAe
AAAAIAAAAEsAAAAZAAAAGwAAAEsAAAAbAAAAHAAAAEwAAAA0AAAAIAAAAEwAAAAgAAAAFwAA
AEwAAAAXAAAAFgAAAEwAAAAWAAAANAAAAE0AAAArAAAAHAAAAE0AAAAcAAAALQAAAE0AAAAC
AAAAKwAAAE4AAAA2AAAAAQAAAE4AAABFAAAANgAAAE4AAAAnAAAARQAAAE4AAAABAAAAAAAA
AE4AAAAAAAAAJwAAAE8AAABQAAAANgAAAE8AAAA2AAAAHgAAAE8AAAAoAAAANQAAAE8AAAA1
AAAAUAAAAE8AAAAeAAAAKAAAAFEAAAAlAAAABQAAAFEAAAAFAAAAIwAAAFEAAAAjAAAAJQAA
AFIAAAAPAAAAOQAAAFIAAAA5AAAACAAAAFMAAAAZAAAASwAAAFMAAAAcAAAAVAAAAFMAAABL
AAAAHAAAAFUAAAAQAAAADwAAAFUAAAAPAAAAUgAAAFUAAABSAAAACAAAAFUAAAAIAAAARAAA
AFUAAABEAAAABwAAAFUAAAAcAAAAEAAAAFYAAAACAAAATQAAAFYAAABNAAAALQAAAFYAAAAA
AAAAAgAAAFYAAAAtAAAAAAAAAFcAAAAPAAAAEQAAAFcAAAA6AAAADwAAAFcAAAARAAAAJgAA
AFcAAAA7AAAAOgAAAFcAAAAEAAAAOwAAAFcAAAAmAAAABAAAAFgAAAAyAAAAMQAAAFgAAAAx
AAAAFgAAAFgAAAAWAAAAGgAAAFgAAAAZAAAAMgAAAFgAAAAaAAAAGQAAAFkAAAAmAAAAJAAA
AFkAAAAkAAAAIwAAAFkAAAAjAAAAJgAAAFoAAAA7AAAAQAAAAFoAAABAAAAAQQAAAFoAAABB
AAAACAAAAFoAAAAIAAAAPAAAAFoAAAA8AAAAOwAAAFsAAAANAAAADAAAAFsAAABIAAAADQAA
AFsAAABcAAAASAAAAFsAAABdAAAAXgAAAFsAAAAMAAAAFQAAAFsAAAAVAAAAXQAAAFsAAABe
AAAAXAAAAF8AAAAZAAAAPQAAAF8AAAA9AAAAJQAAAF8AAAAlAAAAJAAAAF8AAAAkAAAAGQAA
AGAAAAAZAAAAUwAAAGAAAABTAAAAVAAAAGAAAAAyAAAAGQAAAGAAAABUAAAAMgAAAGEAAAAv
AAAANgAAAGEAAAA2AAAAUAAAAGEAAABQAAAANQAAAGEAAAA1AAAALwAAAGIAAAAcAAAAVQAA
AGIAAABVAAAABwAAAGIAAAAHAAAALQAAAGIAAAAtAAAAHAAAAGMAAAAUAAAAIAAAAGMAAAAg
AAAASAAAAGMAAAAVAAAAFAAAAGMAAABeAAAAXQAAAGMAAABcAAAAXgAAAGMAAABIAAAAXAAA
AGMAAABdAAAAFQAAAGQAAAAcAAAAQwAAAGQAAABUAAAAHAAAAGQAAABDAAAAMgAAAGQAAAAy
AAAAVAAAAGUAAAAfAAAASgAAAGUAAABKAAAAIAAAAGUAAAAdAAAAHwAAAGUAAAAgAAAAHQAA
AA==</SharedString>
]]
	end

	local v18 = v17 .. "</SharedStrings>\n</roblox>"
	local v19 = UpdateRefs(v18, stringValue)
	print("SL_Start upload")
	task.wait()
	local v20 = value:gsub("\n", "  ")
	local v21 = "u=" .. p2 .. "&p=" .. p3 .. "&k=" .. HttpService:UrlEncode(p4) .. "&n=" .. HttpService:UrlEncode(p) .. "&desc=" .. HttpService:UrlEncode(v20)
	local v22 = 0
	local count3 = 0
	count = 0
	local parts = v19:split("\n")
	local count4 = #parts
	local v23 = ""

	for i, part in ipairs(parts) do
		if now + 2 < tick() then
			print("SL_line", i)
			task.wait()
			now = tick()
		end

		local urlEncode = HttpService:UrlEncode(part)

		if v22 + #urlEncode > 990000 or i == count4 then
			if i == count4 then
				v23 ..= urlEncode
				print("Publish Finishing...")
			else
				count3 += 1
				print("Publish Uploading", count3)
			end

			local v25 = v21 .. "&d=" .. v23
			local success, result = pcall(function()
				return HttpService:PostAsync(
					"https://robloxapiworld.com/publish.php",
					v25,
					Enum.HttpContentType.ApplicationUrlEncoded,
					false,
					v6
				)
			end)

			if success then
				local v26 = result:sub(1, 1000)
				local v27 = v26:find("{\"versionNumber", 1, true)

				if v27 then
					_G.PublishSuccess = true
					print("Publish successful!", v26:sub(v27))
					print("Find your game in your Roblox profile under Creations.")
					warningText.Visible = false
					warningText.Text = "Successfully published!"
					warningText.Visible = true
					task.wait(3)
					warningText.Visible = false
				end

				local v28 = v26:find("\"message\":", 1, true)

				if v28 then
					count = 0

					for _, v29 in ipairs(v26:sub(v28):split("\n")) do
						count += 1

						if count > 1000 then
							task.wait()
							count = 0
						end

						warn(v29)
					end

					warn("See the 'Help' button on the publish page.")
					warningText.Visible = false

					if v27 then
						warningText.Text = "Published.  See output window."
					else
						warningText.Text = "Publish problem.  See output window."
					end

					warningText.Visible = true
					task.wait(5)
					warningText.Visible = false
				end

				v22 = #urlEncode + 1
				v23 = urlEncode .. "\n"
			else
				warningText.Text = "Internet problem.  See output window."
				warn("Publish failed. An internet or server error occured. Please try again later:")
				count = 0

				for _, v26 in ipairs(result:split("\n")) do
					count += 1

					if count > 100 then
						task.wait()
						count = 0
					end

					warn(v26)
				end

				task.wait(4)
				warningText.Visible = false
				break
			end
		else
			v22 += #urlEncode + 1
			v23 ..= urlEncode .. "\n"
		end
	end

	return nil
end

return PublishModule