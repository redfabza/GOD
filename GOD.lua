local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local SystemActive = false

-- Static blue color (WackShop style)
local staticBlue = Color3.fromRGB(0, 170, 255)

-- =========================
-- GUI CREATION
-- =========================
local Gui = Instance.new("ScreenGui")
Gui.Name = "NoFall_Fix_WackShop"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
Gui.Parent = (success and coreGui) or player:WaitForChild("PlayerGui")

-- Main window (centered on right side)
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromOffset(250, 170)
Main.Position = UDim2.new(1, -20, 0.5, 0) 
Main.AnchorPoint = Vector2.new(1, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = staticBlue
MainStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Text = "Anti-Death Engine [Fix Fall]"
Title.TextColor3 = staticBlue
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Permanent close button
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.fromOffset(30, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16

-- =========================
-- FLOATING & TOGGLE SYSTEM
-- =========================
-- W button (blue, left-center of screen)
local FloatBtn = Instance.new("TextButton", Gui)
FloatBtn.Size = UDim2.fromOffset(50, 50)
FloatBtn.Position = UDim2.new(0, 20, 0.5, 0) 
FloatBtn.AnchorPoint = Vector2.new(0, 0.5)
FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatBtn.Text = "W"
FloatBtn.TextColor3 = staticBlue
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 22
FloatBtn.Visible = true
FloatBtn.BorderSizePixel = 0
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Thickness = 2
FloatStroke.Color = staticBlue

FloatBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end
MakeDraggable(Main)
MakeDraggable(FloatBtn)

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(1, -20, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0, 55)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Text = "[OFF] Protection Disabled"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleBtn.BorderSizePixel = 0
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- Warning text set to bright red for visibility
local Info = Instance.new("TextLabel", Main)
Info.Size = UDim2.new(1, -20, 0, 50)
Info.Position = UDim2.new(0, 10, 0, 110)
Info.BackgroundTransparency = 1
Info.Text = "[Warning] This script does not guarantee 100% death prevention.\nReduces gravity and clears fall velocity on landing.\nDrag the window and W button freely anywhere on screen."
Info.TextColor3 = Color3.fromRGB(255, 50, 50) 
Info.Font = Enum.Font.GothamBold
Info.TextSize = 10
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextWrapped = true

-- RGB Color Loop (rainbow effect when system is active)
local RenderConnection
local function GetRGBColor()
    local tickTime = tick()
    local r = (math.sin(tickTime * 2.5) + 1) / 2
    local g = (math.sin(tickTime * 2.5 + 2) + 1) / 2
    local b = (math.sin(tickTime * 2.5 + 4) + 1) / 2
    return Color3.new(r, g, b)
end

RenderConnection = RunService.RenderStepped:Connect(function()
    if SystemActive then
        local rainbow = GetRGBColor()
        MainStroke.Color = rainbow
        Title.TextColor3 = rainbow
    else
        MainStroke.Color = staticBlue
        Title.TextColor3 = staticBlue
    end
end)

-- =========================
-- CORE FUNCTIONALITY
-- =========================
local HeartbeatConnection
local ChildAddedConnection
local StateConnection
local UpwardForce

local function StopProtection()
    if HeartbeatConnection then HeartbeatConnection:Disconnect() end
    if ChildAddedConnection then ChildAddedConnection:Disconnect() end
    if StateConnection then StateConnection:Disconnect() end
    
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
        if root then
            if root:FindFirstChild("LowGravForce") then root.LowGravForce:Destroy() end
            if root:FindFirstChild("LowGravAttachment") then root.LowGravAttachment:Destroy() end
        end
        local highlight = char:FindFirstChild("AntiDeath_Aura")
        if highlight then highlight:Destroy() end
    end
end

local function StartProtection()
    local char = player.Character or player.CharacterAdded:Wait()
    if not char then return end
    
    local humanoid = char:WaitForChild("Humanoid", 5)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not root then return end
    
    humanoid.MaxHealth = 999999
    humanoid.Health = 999999
    humanoid.BreakJointsOnDeath = false 
    humanoid.RequiresNeck = false       
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

    if not root:FindFirstChild("LowGravForce") then
        local attachment = Instance.new("Attachment", root)
        attachment.Name = "LowGravAttachment"
        
        UpwardForce = Instance.new("VectorForce", root)
        UpwardForce.Name = "LowGravForce"
        UpwardForce.Attachment0 = attachment
        UpwardForce.Force = Vector3.new(0, 0, 0)
    end

    local highlight = char:FindFirstChild("AntiDeath_Aura")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "AntiDeath_Aura"
        highlight.FillTransparency = 0.8
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char
    end

    local function GetBodyMass()
        local mass = 0
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then mass = mass + part:GetMass() end
        end
        return mass
    end

    StateConnection = humanoid.StateChanged:Connect(function(oldState, newState)
        if not SystemActive then return end
        if newState == Enum.HumanoidStateType.Jumping then
            if UpwardForce then UpwardForce.Force = Vector3.new(0, 0, 0) end
        end
    end)

    HeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not char or not char:IsDescendantOf(workspace) or not SystemActive then
            StopProtection()
            return
        end
        
        local rainbow = GetRGBColor()
        highlight.OutlineColor = rainbow
        highlight.FillColor = rainbow
        
        if humanoid.Health < 500000 then
            humanoid.Health = 999999
        end
        
        local currentVelocityY = root.Velocity.Y
        
        if UpwardForce then
            if currentVelocityY < 0 then
                local mass = GetBodyMass()
                UpwardForce.Force = Vector3.new(0, mass * workspace.Gravity * 0.6, 0)
            else
                UpwardForce.Force = Vector3.new(0, 0, 0)
            end
        end
        
        if currentVelocityY < -15 then 
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {char}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local raycastResult = workspace:Raycast(root.Position, Vector3.new(0, -8, 0), raycastParams)
            
            if raycastResult then
                humanoid:ChangeState(Enum.HumanoidStateType.Landed)
            end
        end
    end)
    
    ChildAddedConnection = char.ChildAdded:Connect(function(child)
        if child:IsA("LocalScript") and (string.find(string.lower(child.Name), "fall") or string.find(string.lower(child.Name), "damage")) then
            pcall(function() child:Destroy() end)
        end
    end)
end

ToggleBtn.MouseButton1Click:Connect(function()
    SystemActive = not SystemActive
    if SystemActive then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
        ToggleBtn.Text = "[ON] Protection Active"
        StartProtection()
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleBtn.Text = "[OFF] Protection Disabled"
        StopProtection()
    end
end)

local CharacterConnection
CharacterConnection = player.CharacterAdded:Connect(function()
    if SystemActive then
        task.wait(0.5)
        StartProtection()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    SystemActive = false
    StopProtection()
    
    if RenderConnection then RenderConnection:Disconnect() end
    if CharacterConnection then CharacterConnection:Disconnect() end
    
    Gui:Destroy()
    print("[WackShop] Script has been permanently disabled and removed!")
end)

print("[OK] Anti-Fall Ultimate [Side Swap Edition] Loaded!")
