local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local uiLetters = ReplicatedStorage.ui.letters

local screenGui = playerGui:WaitForChild("screenGui")
local logoContainer = screenGui:WaitForChild("logoContainer")

local word = "squidsync"
local letterSize = 50
local spacing = 5
local totalWidth = (#word * letterSize) + ((#word - 1) * spacing)
-- Adjust for the screenGui's current size
local screenWidth = screenGui.AbsoluteSize.X
local startPositionX = (screenWidth - totalWidth) / 2
local centerY = 0.5 -- Center vertically in the screenGui

-- Assuming logoContainer is a Frame or similar UI element
logoContainer.AnchorPoint = Vector2.new(0.5, 0.5) -- Set anchor to the center
logoContainer.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center on screen
logoContainer.Size = UDim2.new(0, totalWidth, 0, letterSize) -- Set size to contain all letters

-- Collect all assets to preload
local assetsToPreload = {}
for i = 1, #word do
    local char = word:sub(i, i)
    local letterImage = uiLetters:FindFirstChild("letter-" .. char)
    if letterImage then
        table.insert(assetsToPreload, letterImage.Value)
    end
end

-- Function to create the tween for each letter
local function createTween(letterImage, startPosition, endPosition, delay, duration, repeatCount, reverses)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, repeatCount, reverses, delay)
    local goal = { Position = endPosition }
    local tween = TweenService:Create(letterImage, tweenInfo, goal)
    return tween
end

-- Preload assets and wait for a minimum of 5 seconds
local startTime = tick()
ContentProvider:PreloadAsync(assetsToPreload)
local elapsedTime = tick() - startTime
if elapsedTime < 5 then
    wait(5 - elapsedTime) -- Ensure a minimum of 5 seconds wait time
end

-- Create, play, and store tweens for each letter
local tweens = {}
for i = 1, #word do
    local char = word:sub(i, i)
    local letterImage = uiLetters:FindFirstChild("letter-" .. char)
    if letterImage then
        local imageInstance = Instance.new("ImageLabel")
        imageInstance.Image = letterImage.Value
        imageInstance.Size = UDim2.new(0, letterSize, 0, letterSize)
        -- Calculate the initial position for each letter
        local initialPosition = UDim2.new(0, startPositionX + (i - 1) * (letterSize + spacing), centerY, 0)
        imageInstance.Position = initialPosition
        imageInstance.AnchorPoint = Vector2.new(0, 0.5)
        imageInstance.BackgroundTransparency = 1
        imageInstance.Parent = logoContainer

        local bouncePosition = initialPosition + UDim2.new(0, 0, 0, -20)
        local tween = createTween(imageInstance, initialPosition, bouncePosition, (i - 1) * 0.1, 0.75, -1, true)
        table.insert(tweens, tween)
        tween:Play()
    end
end

-- Wait for the condition to tween letters back and fade out
wait(5) -- Simulate additional wait time or conditions

-- Cancel all repeating tweens and tween letters back to their starting positions
for i, tween in ipairs(tweens) do
    tween:Cancel()
    local letterImage = tween.Instance
    local initialPosition = UDim2.new(0, startPositionX + (i - 1) * (letterSize + spacing), centerY, 0)
    local resetTween = createTween(letterImage, letterImage.Position, initialPosition, 0, 0.5, 0, false)
    resetTween:Play()
end

-- Wait for all letters to move back to their starting positions
wait(0.5)

-- Fade out each letter
for _, tween in ipairs(tweens) do
    local letterImage = tween.Instance
    local fadeOutTween = TweenService:Create(letterImage, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1})
    fadeOutTween:Play()
end

-- Wait for the letters to fade out
wait(0.5)

-- Finally, fade out and destroy the logoContainer
local fadeOutTween = TweenService:Create(logoContainer, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1})
fadeOutTween.Completed:Connect(function()
    logoContainer:Destroy()
end)
fadeOutTween:Play()