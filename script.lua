local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- CONFIG
local VERSION = "1.0.1"
local GITHUB_SCRIPT_URL = "https://raw.githubusercontent.com/rvxyzc/Z5-Teleporter/refs/heads/main/script.lua"
local VERSION_CHECK_URL = "https://raw.githubusercontent.com/rvxyzc/Z5-Teleporter/refs/heads/main/version.txt"

-- Auto-update system
local function checkUpdates()
    local success, latestVersion = pcall(function()
        return HttpService:GetAsync(VERSION_CHECK_URL, true)
    end)
    
    if success and latestVersion and latestVersion:match("%d+%.%d+%.%d+") then
        if latestVersion ~= VERSION then
            warn("[Z5Ware] Update found! Loading latest version...")
            loadstring(game:HttpGet(GITHUB_SCRIPT_URL))()
            return
        end
    end
end

-- Main bomb teleportation logic
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function findBombs()
    local objectives = workspace:FindFirstChild("Objectives")
    if not objectives then
        warn("Objectives folder not found!")
        return nil, nil
    end
    
    -- Support multiple bomb naming conventions
    local bombA = objectives:FindFirstChild("Bomb_A") or objectives:FindFirstChild("Bomb A") or objectives:FindFirstChild("BombA")
    local bombB = objectives:FindFirstChild("Bomb_B") or objectives:FindFirstChild("Bomb B") or objectives:FindFirstChild("BombB")
    
    return bombA, bombB
end

local function teleportToBomb(bombName)
    local bombA, bombB = findBombs()
    local targetBomb = bombName == "Bomb_A" and bombA or bombB
    
    if targetBomb then
        if targetBomb:IsA("Model") and targetBomb.PrimaryPart then
            humanoid.RootPart.CFrame = targetBomb.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
        elseif targetBomb:IsA("BasePart") then
            humanoid.RootPart.CFrame = targetBomb.CFrame * CFrame.new(0, 3, 0)
        end
        return true
    end
    return false
end

-- Create draggable UI
local gui = Instance.new("ScreenGui")
gui.Name = "Z5WareBombTeleporter"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 180)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Text = "Z5WARE BOMB TELEPORTER"
titleText.TextColor3 = Color3.fromRGB(0, 162, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Parent = titleBar

-- Close button
local closeButton = Instance.new("ImageButton")
closeButton.Image = "rbxassetid://3926305904"
closeButton.ImageRectOffset = Vector2.new(284, 4)
closeButton.ImageRectSize = Vector2.new(24, 24)
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -30, 0, 3)
closeButton.BackgroundTransparency = 1
closeButton.Parent = titleBar

-- Status display
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 40)
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.Text = "Scanning for bombs..."
statusLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Teleport buttons
local buttonA = Instance.new("TextButton")
buttonA.Size = UDim2.new(1, -20, 0, 35)
buttonA.Position = UDim2.new(0, 10, 0, 90)
buttonA.Text = "TELEPORT TO BOMB A"
buttonA.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
buttonA.TextColor3 = Color3.new(1, 1, 1)
buttonA.Font = Enum.Font.GothamBold
buttonA.TextSize = 12
buttonA.Parent = mainFrame

local buttonB = Instance.new("TextButton")
buttonB.Size = UDim2.new(1, -20, 0, 35)
buttonB.Position = UDim2.new(0, 10, 0, 135)
buttonB.Text = "TELEPORT TO BOMB B"
buttonB.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
buttonB.TextColor3 = Color3.new(1, 1, 1)
buttonB.Font = Enum.Font.GothamBold
buttonB.TextSize = 12
buttonB.Parent = mainFrame

-- Button styling
local function applyButtonStyle(button)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        if button == buttonA then
            button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        else
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
        end
    end)
end

applyButtonStyle(buttonA)
applyButtonStyle(buttonB)

-- Update bomb status
local function updateStatus()
    local bombA, bombB = findBombs()
    
    if bombA and bombB then
        statusLabel.Text = "STATUS: Both bombs detected\nReady for teleportation"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    elseif bombA then
        statusLabel.Text = "STATUS: Only Bomb A detected"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        buttonB.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    elseif bombB then
        statusLabel.Text = "STATUS: Only Bomb B detected"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        buttonA.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    else
        statusLabel.Text = "STATUS: No bombs found!\nCheck Objectives folder"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        buttonA.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        buttonB.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end

-- Connect functionality
buttonA.Activated:Connect(function()
    if teleportToBomb("Bomb_A") then
        statusLabel.Text = "SUCCESS: Teleported to Bomb A!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "ERROR: Bomb A not found!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

buttonB.Activated:Connect(function()
    if teleportToBomb("Bomb_B") then
        statusLabel.Text = "SUCCESS: Teleported to Bomb B!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "ERROR: Bomb B not found!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

closeButton.Activated:Connect(function()
    gui:Destroy()
end)

-- Initialize
mainFrame.Parent = gui
gui.Parent = player:WaitForChild("PlayerGui")

-- Auto-update check
task.spawn(checkUpdates)

-- Periodic status updates
while task.wait(5) and gui and gui.Parent do
    updateStatus()
end
