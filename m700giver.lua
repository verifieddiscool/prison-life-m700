local tooltipModule = require(game.ReplicatedStorage.SharedModules.TooltipModule)
local plr = game.Players.LocalPlayer
local oldmousehoverUI = plr.PlayerGui.Home.hud.AddedGui.mousehover
local interactwithitem = game.ReplicatedStorage.Remotes.InteractWithItem

local mousehoverUi
local item_name = "M700"

if oldmousehoverUI then
	mousehoverUi = oldmousehoverUI:Clone()
	mousehoverUi.Parent = oldmousehoverUI.Parent
	mousehoverUi.Name = "mousehover2"
end

function changeuiName(name,type)
	if type == "clothes" then
		mousehoverUi.TextLabel.Text = "Clothes - "..name
	elseif type == "item" then
		mousehoverUi.TextLabel.Text = "Item - "..name
	end
end

function getAsset(asset)
	return game:GetObjects(getcustomasset(asset))[1]
end

local newM700rack = getAsset('m700rack.rbxm')
local mouse = plr:GetMouse()
local ishovering = false

function hover(ui)
	if not ishovering then
		ishovering = true
		mousehoverUi.Visible = true
	end

	local uiSizeX = ui.AbsoluteSize.X
	mousehoverUi.Position = UDim2.new(0, mouse.X - (uiSizeX / 2), 0, mouse.Y + 25)
end

function itemHover()
	if mouse.Target and mouse.Target:IsDescendantOf(newM700rack.M700) then
		changeuiName("M700","item")
		hover(mousehoverUi)
	elseif mouse.Target and mouse.Target:IsDescendantOf(newM700rack.noob) then
		changeuiName("Marksman","clothes")
		hover(mousehoverUi)
	else
		if ishovering then
			ishovering = false
			mousehoverUi.Visible = false
		end
	end
end 

function itemClick()
	if mouse.Target and mouse.Target:IsDescendantOf(newM700rack.M700) then
		collectItemUI("M700")
		collectM700()
	elseif mouse.Target and mouse.Target:IsDescendantOf(newM700rack.noob) then
		wearvest()
	end
end

newM700rack.TouchGiver.TouchGiver.Touched:Connect(function(hit)
	if hit.Parent == plr.Character then
		collectM700()
	end
end)

mouse.Move:Connect(itemHover)

mouse.button1Down:Connect(itemClick)

function wearvest()
	local hasM700 = pcall(function() return game.Players.LocalPlayer.Character.vest or game.Players.LocalPlayer.Backpack.vest end)
	if hasM700 then 
		collectItemUI("wore", "armor") 
		return 
	end

	local vest = getAsset('vest.rbxm')
	vest.Name = "vest"
	vest.Parent = plr.Character
	vest.CFrame = plr.Character.Torso.CFrame

	local weld = Instance.new("Weld")
	weld.Part0 = plr.Character.Torso
	weld.Part1 = vest
	weld.C0 = CFrame.new(0, 0, 0)
	weld.Parent = vest

	collectItemUI("clothes", "Marksman Vest")
end

function collectM700()
	interactwithitem:InvokeServer(workspace.Prison_ITEMS.giver["Remington 870"]["Meshes/r870_2"])
		
	local hasM700 = pcall(function() return game.Players.LocalPlayer.Backpack.M700 or game.Players.LocalPlayer.Character.M700 end)
	if hasM700 then 
		collectItemUI("has", "M700") 
		return 
	end
	
	local rem = game.Players.LocalPlayer.Backpack:WaitForChild("Remington 870", 5)
	if not rem then
		rem = game.Players.LocalPlayer.Character:WaitForChild("Remington 870", 5)
	end
	if not rem then return end
	
	rem.Parent = game.Players.LocalPlayer.Backpack

	for i,v in pairs(rem:GetChildren()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
		end
	end

	rem:SetAttribute("ProjectileCount", 1)
	rem:SetAttribute("FireRate", 2)
	rem:SetAttribute("SpreadRadius", 0)
	rem:SetAttribute("MaxAmmo", 3)
	
	rem.Name = "M700"
	rem.Handle.SecondarySound.Volume = 0
	rem.Handle.ShootSound.SoundId = "rbxassetid://76555847593119"

	rem:GetAttributeChangedSignal("Local_CurrentAmmo"):Connect(function()
		local atts = rem:GetAttributes()
		if atts.Local_CurrentAmmo > atts.MaxAmmo then
			rem:SetAttribute("Local_CurrentAmmo", atts.MaxAmmo)
		end
	end)

	local model = game:GetObjects(getcustomasset("sniperwelded.rbxm"))[1]
	model.Parent = rem 
	model.PrimaryPart.Transparency = 1

	local weld = Instance.new("Weld", model.PrimaryPart)
	weld.Part0 = rem.Handle
	weld.Part1 = model.PrimaryPart
	weld.C0 = CFrame.new(0, 0.1, 0)

	local muzzle = model.Muzzle
	rem.Muzzle.Parent = model
	muzzle.Parent = rem

	collectItemUI("weapon", "M700")
end

function collectItemUI(type, item)
	if type == "weapon" then
		tooltipModule.update("You have picked up a "..item)
	elseif type == "wore" then
		tooltipModule.update("You're already wearing armor!")
	elseif type == "has" then
		tooltipModule.update("You already have that!")
	end
end

for i,model in pairs(workspace:GetChildren()) do
	if model:IsA("Model") then
		if model:FindFirstChild("nil") and model:FindFirstChild("noob") and model:FindFirstChild("Part") and model:FindFirstChild("sign") and model:FindFirstChild("vest") then
			model:Destroy()
			newM700rack.Parent = workspace
		end
	end
end
