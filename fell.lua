
-- chest behind, wood
-- chest left, coal
-- chest right, saplings

-- slot 1 coal 
-- slot 2 sapling
-- slot 3 bonemeal

coal = 1
sapling = 2
boneMeal = 3


local MINFUEL = 50
local SPEAK = true
local SAFEDIG = true

movementStack = {}

horizontalSize = 0
verticalSize = 0

function say(msg)
    if SPEAK == true then
        print(msg)
    end
end

function forwardCheckMove() 
    ensureFuel(MINFUEL)
    if checkIfSpotEmpty() == false then
        if SAFEDIG == true then
            print("Path obstructed. Waiting for manual clearance..")
            while checkIfSpotEmpty() == false do
                sleep(5)
            end
            print("Path cleared. Continuing..")
        elseif SAFEDIG == false then
            print("Path obstructed. Safedig protocol off. Digging..")
            while checkIfSpotEmpty() == false do
                turtle.dig()
            end
        end
    end

    while not turtle.forward() do
        print("Failed to move.")
        if SAFEDIG == true then
            print("SafeDig enabled. Waiting for manual clearance..")
        
        elseif SAFEDIG == false then
            print("SafeDig disabled. Digging..")
            turtle.dig()
        end
    end
end

function clearTerminal()
    term.clear()
    term.setCursorPos(1,1)
end

clearTerminal()

print("Hi and welcome to Woot's Fell program!")
print("\n")
print("To get started, you'll need to provide Horizontal and Vertical Size.")
print("Horizontal size: How many sets of forward and backward passes. 1 Horizontal = 6 blocks width.")
print("Vertical size: How many blocks forward. 1 Vertical = 1 blocks depth")

while true do 
    write("Continue> ") 
    read()
    clearTerminal()
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

print("\n")
print("Do you want to enable SafeDig? (y/n) (default and recommended: y)")
print("SafeDig enabled will make sure that turtle does not dig unauthorized blocks. If disabled, turtle may BREAK UNWANTED BLOCKS if it gets lost.")
while true do
    write("Answer (y/n)> ")
    local text = read()

    if text == "n" or text == "no" or text == "nope" or text == "nah" then
        SAFEDIG = false
        print("SafeDig set to: FALSE")
    else
        print("SafeDig set to: TRUE")
    end
    break
end

print("\n")
-- Asks for working area
while true do
    write("Horizontal Size> ")
    local h = tonumber(read())
    write("Vertical Size> ")
    local v = tonumber(read())
    
    if h > 0 and h < 51 and v > 0 and v < 51 then 

        horizontalSize = h
        verticalSize = v
        print(string.format("Horizontal Size set to: %d", horizontalSize))
        print(string.format("Vertical Size set to: %d", verticalSize))
        break
    end

    print("Unsupported Input: Minimum: 1, Maximum: 50")
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



function ensureFuel(min)
    min = min or 1
    if turtle.getFuelLevel() < min then
        refuel()
    end
end

function refuel()

        say("Refueling with current fuel..")
        turtle.select(coal)
        currentFuelLevel = turtle.getFuelLevel()
        turtle.refuel(5)
        newFuelLevel = turtle.getFuelLevel()

        if newFuelLevel > currentFuelLevel then
        else
            print("Invalid or little to no fuel left. Please refill the turtle directly to continue..")
            while true do
                sleep(5)

                currentFuelLevel = turtle.getFuelLevel()
                turtle.refuel(5)
                newFuelLevel = turtle.getFuelLevel()

                if newFuelLevel > currentFuelLevel then
                    print("Successfully refueled. Continuing..")
                    break
                end
            end
        end
end


function refillEmpty()
    say("Refilling resources..")
    -- assuming default position
    
    -- coal
    turtle.turnLeft()
    coalDetails = turtle.getItemDetail(coal)
    if coalDetails == nil then
        turtle.select(coal)
        print("Waiting for Coal to be Put in Chest..")
        while true do
            turtle.suck()
            if turtle.getItemCount(coal) > 0 then
                break
            end
            
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
        while true do
            turtle.suck()
            if turtle.getItemCount(sapling) > 1 then
                break
            end
            
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
    turtle.select(sapling)
    saplingsLeft = turtle.getItemCount(sapling)
    turtle.suck(64 - saplingsLeft)
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
    forwardCheckMove()
    column()
    turtle.turnRight()
    turtle.turnRight()
    forwardCheckMove()
    turtle.turnRight()
    turtle.turnRight()
end

function column()
    local heightReached = 0

    while turtle.detectUp() == true and heightReached < 5 do
        ensureFuel(MINFUEL)
        turtle.digUp()
        while not turtle.up() do
        print("Failed to move.")
        if SAFEDIG == true then
            print("SafeDig enabled. Waiting for manual clearance..")
        
        elseif SAFEDIG == false then
            print("SafeDig disabled. Digging..")
            turtle.digUp()
        end
    end
        heightReached = heightReached + 1
        turtle.suck()
    end

    for j = 1,heightReached - 1 do
        ensureFuel(MINFUEL)
        turtle.digDown()
        while not turtle.down() do
        print("Failed to move.")
        if SAFEDIG == true then
            print("SafeDig enabled. Waiting for manual clearance..")
        
        elseif SAFEDIG == false then
            print("SafeDig disabled. Digging..")
            turtle.digDown()
        end
    end
        turtle.suck()
    end
    while not turtle.down() do
        print("Failed to move.")
        if SAFEDIG == true then
            print("SafeDig enabled. Waiting for manual clearance..")
        
        elseif SAFEDIG == false then
            print("SafeDig disabled. Digging..")
            turtle.digDown()
        end
    end
    turtle.suck()
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

function checkTreeExists(direction)
    say("Checks if tree exists..")
    turtle.select(sapling)
    local success, block = turtle.inspect()
    local item = turtle.getItemDetail()

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

    -- check right
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

function forwardPass()
    say("Beginning Forward Pass..")
    for j = 1,verticalSize do
        if checkIfSpotEmpty() == false then
            print("TRYING TO FORWARD WHEN BLOCK BLOCKS.")
        end
        forwardCheckMove()
        turtle.suck()
        table.insert(movementStack, "forward")
        checkAroundForTrees()
    end

    -- pass done, turn for backwards pass
    turtle.suck()
    forwardCheckMove()
    turtle.turnRight()
    turtle.suck()
    forwardCheckMove()
    turtle.suck()
    forwardCheckMove()
    turtle.suck()
    forwardCheckMove()
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
        if checkIfSpotEmpty() == false then
            print("TRYING TO FORWARD WHEN BLOCK BLOCKS.")
        end
        forwardCheckMove()
        turtle.suck()
        table.insert(movementStack, "forward")
        checkAroundForTrees()
    end

    -- pass done, turn for backwards pass
    turtle.suck()
    forwardCheckMove()
    turtle.turnLeft()
    turtle.suck()
    forwardCheckMove()
    turtle.suck()
    forwardCheckMove()
    turtle.suck()
    forwardCheckMove()
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
    for j = #movementStack, 2, -1 do
        -- inverse all instructions to go back
        if movementStack[j] == "forward" then
            forwardCheckMove()
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

    -- as for loop is only to 2 and needs to get into default position. Prevents sucking from back chest
    forwardCheckMove()

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
    refillEmpty()
    ensureFuel(MINFUEL)

    for j = 1,horizontalSize do
        forwardPass()
        backwardPass()
    end

    returnHome()
    movementStack = {}

until 1 > 2
