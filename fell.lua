
-- chest behind, wood
-- chest left, coal
-- chest right, saplings

-- slot 1 coal 
-- slot 2 sapling
-- slot 3 bonemeal
coal = 1
sapling = 2
boneMeal = 3

local SPEAK = true

movementStack = {}

horizontalSize = 0
verticalSize = 0

function say(msg)
    if SPEAK == true then
        print(msg)
    end
end

function clearTerminal()
    term.clear()
    term.setCursorPos(1,1)
end

clearTerminal()

print("Hi and welcome to Woot's Fell program!")
print("To get started, you'll need to provide Horizontal and Vertical Size.")
print("Horizontal size: How many sets of forward and backward passes. 1 Horizontal = 6 blocks width.")
print("Vertical size: How many blocks forward. 1 Vertical = 1 blocks depth")

while true do 
    write("Continue> ") 
    read()
    term.clear()
term.setCursorPos(1,1)
    break
end



print("Do you want to enable Verbosity? (y/n) (default: y)")
while true do
    write("Answer (y/n)> ")
    local text = read()

    if text == "n" or text == "no" or text == "nope" or text == "nah" then
        SPEAK = false
        print("Verbosity set to: FALSE")
    else
        print("Verbosity set to: TRUE")
    end
    break
end

-- Asks for working area
while true do
    write("Horizontal Size> ")
    local h = tonumber(read())
    write("Vertical Size> ")
    local v = tonumber(read())
    
    -- for maximum of 63 saplings
    -- local h_real = h * 2
    -- local v_real = v * 2
    -- local sapling_requirement = (h_real * v_real)
    if h > 0 and h < 51 and v > 0 and v < 51 then 

    --     h_real = h * 2
    --     v_real = v * 2
        horizontalSize = h
        verticalSize = v
        print(string.format("Horizontal Size set to: %d", horizontalSize))
        print(string.format("Vertical Size set to: %d", verticalSize))
        break
    end
    -- if sapling_requirement < 64 then
    --     horizontalSize = h
    --     verticalSize = v
    --     break
    -- end

    print("Unsupported Input: Minimum: 1, Maximum: 50")
    -- print(string.format("Size cannot exceed the need of more than 63 saplings. Current %s", sapling_requirement))
end


clearTerminal()
if SPEAK == true then
    print("Verbosity set to: TRUE")
else
    print("Verbosity set to: FALSE")
end

print(string.format("Horizontal Size set to: %d", horizontalSize))
print(string.format("Vertical Size set to: %d", verticalSize))
print("Beginning..")



function refuel()
    if turtle.getFuelLevel() < 51 then
        say("Refueling with current fuel..")
        turtle.select(coal)
        turtle.refuel(5)
    end
end


function refillEmpty()
    say("Refilling resources..")
    -- assuming default position
    -- coal
    turtle.turnLeft()
    turtle.select(coal)
    coalLeft = turtle.getItemCount(coal)

    if coalLeft == 0 and turtle.suck() == false then
        print("Waiting for Coal to be Put in Chest..")
        while not turtle.suck() do
            sleep(5)
        end
        print("Coal provided. Continuing..")
    end

    turtle.turnRight()
    
    -- pick up more saplings
    turtle.turnRight()

    saplingDetails = turtle.getItemDetail(sapling)
    if saplingDetails == nil then
        turtle.select(sapling)

        print("Waiting for Saplings to be Put in Chest.. (Minimum: 2, Recommended: 64+)")
        while turtle.getItemCount(sapling) < 2 do
            turtle.suck()
            sleep(5)
        end
        print("Saplings provided. Continuing..")
        
        saplingDetails = turtle.getItemDetail(sapling)
    end

    for j = 1,16 do
        if j == 2 then goto continue end
        selectedItemDetails = turtle.getItemDetail(j)
        if selectedItemDetails == nil then
        else
            if saplingDetails.name == selectedItemDetails.name then
                turtle.select(j)
                turtle.drop()
            end
        end
        ::continue::
    end
    turtle.turnLeft()
    
     -- drop wood
     turtle.turnRight()
     turtle.turnRight() 
     for j = 3, 16 do
         turtle.select(j)
         turtle.drop()
     end
     turtle.turnLeft()
     turtle.turnLeft()
end

function fell()
    say("Felling..")
    turtle.dig()
    turtle.forward()
    column()
    turtle.turnRight()
    turtle.turnRight()
    turtle.forward()
    turtle.turnRight()
    turtle.turnRight()
end

function column()
    while turtle.detectUp() == true do
        turtle.digUp()
        turtle.up()
        turtle.suck()
    end
    while turtle.detectDown() == false do
        turtle.down()
        turtle.suck()
    end
end

function plant()
    say("Planting..")
    turtle.select(sapling)
    saplingsLeft = turtle.getItemCount(sapling)
    if saplingsLeft > 1 then
        turtle.place()
    else
        say("Only one sapling left. Skips planting..")
    end
end 

-- function goRefill()
--     returnHome()
--     refillEmpty()
--     returnBack()
-- end

function checkTreeExists(direction)
    say("Checks if tree exists..")
    turtle.select(sapling)
    local success, block = turtle.inspect()
    local item = turtle.getItemDetail()

    -- if item == nil then
    --     if direction == "left" then
    --         turtle.turnRight()
    --     elseif direction == "right" then
    --         turtle.turnLeft()
    --     end
        
    --     goRefill()
    --     local item = turtle.getItemDetail()

    --     if direction == "left" then
    --         turtle.turnLeft()
    --     elseif direction == "right" then
    --         turtle.turnRight()
    --     end

    -- end

    if checkIfSpotEmpty() == true then
        -- is air
        plant()
        return false
    end

    if block.name == item.name then
        say("Detected Sapling.")
        -- is sapling, no tree
       return false
   else
        say("Detected Tree.")
       return true
   end 
end

function checkIfSpotEmpty()
    if turtle.detect() then
        return false
    else
        say("Detected Air in current spot.")
        return true
    end
end

function checkAroundForTrees()
    -- check left
    turtle.turnLeft()
    turtle.suck()

    local spotIsEmpty = checkIfSpotEmpty()
    if spotIsEmpty == true then
        plant()
    end

    local treeExists = checkTreeExists("left") 
    if treeExists == true then
        fell()
        plant()
    end
    
    turtle.turnRight()
    turtle.turnRight()
    turtle.suck()
    local spotIsEmpty = checkIfSpotEmpty()
    if spotIsEmpty == true then
        plant()
    end

    local treeExists = checkTreeExists("right") 
    if treeExists == true then
        fell()
        plant()
    end
    turtle.turnLeft()  
end

-- turtle.forward() -- first step to go in front of chests
-- table.insert(movementStack, "forward")


function forwardPass()
    say("Beginning Forward Pass..")
    for j = 1,verticalSize do
        turtle.forward()
        turtle.suck()
        table.insert(movementStack, "forward")
        checkAroundForTrees()
    end



    -- pass done, turn for backwards pass
    turtle.suck()
    turtle.forward()
    turtle.turnRight()
    turtle.suck()
    turtle.forward()
    turtle.suck()
    turtle.forward()
    turtle.suck()
    turtle.forward()
    turtle.suck()
    turtle.turnRight()

    table.insert(movementStack, "forward")
    table.insert(movementStack, "right")
    table.insert(movementStack, "forward")
    table.insert(movementStack, "forward")
    table.insert(movementStack, "forward")
    table.insert(movementStack, "right")
end

function backwardPass()
    say("Beginning Backward Pass..")
    for j = 1,verticalSize do
        turtle.forward()
        turtle.suck()
        table.insert(movementStack, "forward")
        checkAroundForTrees()
    end

    -- pass done, turn for backwards pass
    turtle.suck()
    turtle.forward()
    turtle.turnLeft()
    turtle.suck()
    turtle.forward()
    turtle.suck()
    turtle.forward()
    turtle.suck()
    turtle.forward()
    turtle.suck()
    turtle.turnLeft()

    table.insert(movementStack, "forward")
    table.insert(movementStack, "left")
    table.insert(movementStack, "forward")
    table.insert(movementStack, "forward")
    table.insert(movementStack, "forward")
    table.insert(movementStack, "left")
end


function returnHome()
    say("Returning Home..")
    turtle.turnRight()
    turtle.turnRight()
    for j = #movementStack, 1, -1 do
        -- inverse all instructions to go back
        if movementStack[j] == "forward" then
            turtle.forward()
            turtle.suck()
        elseif movementStack[j] == "left" then
            turtle.turnRight()
            turtle.suck()
        elseif movementStack[j] == "right" then
            turtle.turnLeft()
            turtle.suck()
        else
            print("Invalid movement, must be forward, left or right")
        end
    end

    turtle.turnLeft()
    turtle.turnLeft()
end

-- function returnBack()
--     for j = 1, #movementStack do
--         -- inverse all instructions to go back
--         if movementStack[j] == "forward" then
--             turtle.forward()
--             turtle.suck()
--         elseif movementStack[j] == "left" then
--             turtle.turnLeft()
--             turtle.suck()
--         elseif movementStack[j] == "right" then
--             turtle.turnRight()
--             turtle.suck()
--         else
--             print("Invalid movement, must be forward, left or right")
--         end
--     end

--     turtle.turnLeft()
--     turtle.turnLeft()
-- end


-- What repeats
repeat
    
    -- searching work
    refuel()
    refillEmpty()

    for j = 1,horizontalSize do
        forwardPass()
        backwardPass()
    end

    returnHome()
    movementStack = {}

until 1 > 2