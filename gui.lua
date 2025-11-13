local Inv = script.Parent.OpenInv
local Gui = script.Parent.Main
local Close = script.Parent.Main.CloseInv
local requestinv = game.ReplicatedStorage.Remotes.RequestInventory
local petModule = require(game.ReplicatedStorage.PetModule)
local Equip = script.Parent.Main.Side.Equip
local PetData = game.ReplicatedStorage.Remotes.RequestPetData:InvokeServer()
local UpdateCoins = game.ReplicatedStorage.Remotes.UpdateCoins
local TweenService = game:GetService("TweenService")

local CoinLabel = script.Parent.Coins.CoinLabel
--local RubyLabel = script.Parent.Coins.RubyLabel

local Coin = script.Parent.Coins.Coin

local player = game.Players.LocalPlayer

CoinLabel.Text = player:FindFirstChild("leaderstats"):FindFirstChild("Coins").Value
--RubyLabel.Text = player:FindFirstChild("leaderstats"):FindFirstChild("Rubies").Value

local inventory = requestinv:InvokeServer()

table.sort(inventory, function(a,b) return a.Power > b.Power end)

petModule.updateInv(player, inventory, PetData)

for _, pet in ipairs(inventory) do
	if(pet.Equipped == true) then
		game.ReplicatedStorage.Remotes.EquipPet:FireServer(pet.Uid)
	end
end

Inv.MouseButton1Click:Connect(function()
	Gui.Visible = true
end)

Close.MouseButton1Click:Connect(function()
	Gui.Visible = false
end)

Equip.MouseButton1Click:Connect(function()
	if Equip.Text == "Equip" then
		game.ReplicatedStorage.Remotes.EquipPet:FireServer(Equip:GetAttribute("Uid"))

	else if Equip.Text == "Unequip" then
			game.ReplicatedStorage.Remotes.UnequipPet:FireServer(Equip:GetAttribute("Uid"))
		end
	end
	inventory = requestinv:InvokeServer()

	table.sort(inventory, function(a,b) return a.Power > b.Power end)

	petModule.updateInv(player, inventory, PetData)
end)

local displayedCoins = player:FindFirstChild("leaderstats"):FindFirstChild("Coins").Value
local Coin = script.Parent.Coins.Coin
local actualCoins = displayedCoins
local normalScale = Coin.Size
local animating = false
local scaleTween = nil 
local scaledownTween = nil
local scaling = false

local incrementSpeed = 100

local TweenService = game:GetService("TweenService")

local function animateCoins()
	if animating then return end
	animating = true

	-- run animation until number matches
	while displayedCoins ~= actualCoins do
		task.wait(0.01)

		local diff = actualCoins - displayedCoins
		local direction = math.sign(diff)
		local updatesPerTick = math.clamp(math.floor(math.abs(diff) / 100), 1, 100)

		for _ = 1, updatesPerTick do
			if displayedCoins == actualCoins then break end
			displayedCoins += direction
			CoinLabel.Text = displayedCoins
		end

		-- trigger pulse tween only once when big change detected
		if not scaling then
			scaling = true

			-- cancel any existing tweens if already running
			if scaleTween then scaleTween:Cancel() end
			if scaledownTween then scaledownTween:Cancel() end

			local scaleUp = TweenService:Create(
				Coin,
				TweenInfo.new(0.04, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{Size = UDim2.new(0, 82, 0, 82)}
			)
			local scaleDown = TweenService:Create(
				Coin,
				TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Size = normalScale}
			)

			scaleUp:Play()
			scaleUp.Completed:Connect(function()
				scaleDown:Play()
				scaleDown.Completed:Connect(function()
					scaling = false
				end)
			end)
		end
	end

	animating = false
end



-- Call this when coins are collected
local function onCoinsCollected(newTotal)
	actualCoins = newTotal
	animateCoins()
end

UpdateCoins.OnClientEvent:Connect(function()
	onCoinsCollected(player:FindFirstChild("leaderstats"):FindFirstChild("Coins").Value)
end)

player:FindFirstChild("leaderstats"):FindFirstChild("Rubies").Changed:Connect(function()
	--RubyLabel.Text = player:FindFirstChild("leaderstats"):FindFirstChild("Rubies").Value
end)




