-- AYARLAR
local menuKey = Enum.KeyCode.RightControl

-- SERVİSLER
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- GUI OLUŞTUR
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "MyHackMenu"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.ClipsDescendants = true

-- BAŞLIK (NoxPet)
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.Text = "NoxPet"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.BorderSizePixel = 0

-- Butonlar için çerçeve
local buttonsFrame = Instance.new("Frame", mainFrame)
buttonsFrame.Size = UDim2.new(1, 0, 1, -35)
buttonsFrame.Position = UDim2.new(0, 0, 0, 35)
buttonsFrame.BackgroundTransparency = 1

-- Menü Aç/Kapat
UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == menuKey then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

-- BURASI: Menü sürükleme işlemi için kod

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

titleLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleLabel.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Buton oluşturma fonksiyonu
local buttonYOffset = 10
local function createToggleButton(text, callback)
	local button = Instance.new("TextButton", buttonsFrame)
	button.Size = UDim2.new(1, -20, 0, 30)
	button.Position = UDim2.new(0, 10, 0, buttonYOffset)
	button.Text = text .. " [KAPALI]"
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14

	local state = false
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = text .. (state and " [AÇIK]" or " [KAPALI]")
		callback(state)
	end)

	buttonYOffset = buttonYOffset + 40
end

-- Özellikler
createToggleButton("Speed Boost", function(state)
	humanoid.WalkSpeed = state and 100 or 16
end)

createToggleButton("Infinite Jump", function(state)
	_G.infiniteJump = state
end)

UserInputService.JumpRequest:Connect(function()
	if _G.infiniteJump then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

createToggleButton("NoClip", function(state)
	_G.noclip = state
end)

RunService.Stepped:Connect(function()
	if _G.noclip and character then
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

createToggleButton("Player ESP", function(state)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			if state and not plr.Character:FindFirstChild("ESPBox") then
				local box = Instance.new("BoxHandleAdornment")
				box.Name = "ESPBox"
				box.Size = Vector3.new(3, 6, 2)
				box.Transparency = 0.5
				box.Adornee = plr.Character:FindFirstChild("HumanoidRootPart")
				box.AlwaysOnTop = true
				box.ZIndex = 5
				box.Color3 = Color3.fromRGB(0, 255, 0)
				box.Parent = plr.Character

				local tag = Instance.new("BillboardGui", plr.Character)
				tag.Size = UDim2.new(0, 100, 0, 40)
				tag.Adornee = plr.Character:FindFirstChild("Head")
				tag.AlwaysOnTop = true
				tag.Name = "NameTag"

				local nameLabel = Instance.new("TextLabel", tag)
				nameLabel.Size = UDim2.new(1, 0, 1, 0)
				nameLabel.BackgroundTransparency = 1
				nameLabel.Text = plr.Name
				nameLabel.TextColor3 = Color3.new(0, 1, 0)
				nameLabel.TextScaled = true
			elseif not state then
				if plr.Character:FindFirstChild("ESPBox") then
					plr.Character.ESPBox:Destroy()
				end
				if plr.Character:FindFirstChild("NameTag") then
					plr.Character.NameTag:Destroy()
				end
			end
		end
	end
end)