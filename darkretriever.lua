Version = 2.12
x,y = term.getSize()

if not http then
  print("Herp derp, forget to enable http?")
  return exit
end

local function getUrlFile(url)
  local mrHttpFile = http.get(url)
  mrHttpFile = mrHttpFile.readAll()
  return mrHttpFile
end

local function writeFile(filename, data)
  local file = fs.open(filename, "w")
  file.write(data)
  file.close()
end

local function cs()
  term.clear()
  term.setCursorPos(1,1)
end

local function tc(tcolor,bcolor)
  if term.isColor() then
    if tcolor then
      term.setTextColor(colors[tcolor])
    end
    if bcolor then
      term.setBackgroundColor(colors[bcolor])  
    end
  end
end

local function writeC(text,line)
  term.setCursorPos((x / 2) - (#text / 2),line)
  term.write(text)
end

term.oldWrite = term.write
function term.write(text)
  if not text then
    text = ""
  end
  term.oldWrite(text)
end

local function header(text)
  tc("white","blue")
  writeC(string.rep("  ",x),1)
  writeC(string.rep("  ",x),y)
  writeC(text,1)
  tc("white","black")
end

local function gitUpdate(ProgramName, Filename, ProgramVersion)
  if http then
    local status, getGit = pcall(http.get, "https://raw.github.com/darkrising/darkprograms/darkprograms/programVersions")
    if not status then
      print("\nFailed to get Program Versions file.")
      print("Error: ".. getGit)
      return exit
    end 
    local getGit = getGit.readAll()
    NVersion = textutils.unserialize(getGit)
    if NVersion[ProgramName].Version > ProgramVersion then
      getGit = http.get(NVersion[ProgramName].GitURL)
      getGit = getGit.readAll()
      local file = fs.open(Filename, "w")
      file.write(getGit)
      file.close()
      return true
    end
  else
    return false
  end
end

-- Loading Animation --

-- Define a variable to keep track of the loading duration
local loadingDuration = 5  -- 5 seconds

-- Modify the loading animation function
function loadingAnimation()
  local loadingStartTime = os.clock()  -- Get the starting time

  -- Run the loading animation until the loading duration is reached
  while os.clock() - loadingStartTime < loadingDuration do
    -- Perform the loading animation logic
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Loading...")

    -- Add your loading animation logic here
    -- ...

    sleep(0.1)  -- Adjust the delay between frames if needed
  end
end

-- Modify the runMenu function to include the loading animation
function runMenu()
  cs()
  print("Checking for updates...")
  if gitUpdate("darkretriever", shell.getRunningProgram(), Version) == true then
    print("Update found and downloaded.")
    print("\nPlease run ".. shell.getRunningProgram() .. " again.")
    return exit
  else
    print("Program up-to-date.")
  end
  sleep(1)

  x,y = term.getSize()
  cs()
  write("-> Grabbing file...")
  cat = getUrlFile("https://raw.github.com/darkrising/darkprograms/darkprograms/programVersions")
  write(" Done.")
  sleep(1)
  cs()
  write("-> Updating file...")
  writeFile("programVersions",cat)
  write(" Done.")
  sleep(1)
  cs()
  write("-> Loading file...")
  sleep(1)
  write(" Done.")
  sleep(1)
  cs()
  write("-> Decoding file...")
  sleep(1)
  write(" Done.")
  sleep(1)
  cs()
  write("-> Importing file...")
  cat = textutils.unserialize(cat)
  write(" Done.")
  sleep(1)
  cs()

  menu = {}
  rawName = {}
  rawCat = {}

  for i = 1, #cat do
    rawName[i] = cat[i].name
    rawCat[i] = cat[i].cat
    if cat[i].hidden ~= true then
      if not menu[rawCat[i]] then
        menu[rawCat[i]] = {}
      end
      table.insert(menu[rawCat[i]], i)
    end
  end

  while true do
    header("Main Menu")
    local yPrint = 3
    for i = 1, #rawName do
      if cat[i].hidden ~= true then
        term.setCursorPos(2, yPrint)
        print(i .. " - " .. rawName[i])
        yPrint = yPrint + 1
      end
    end

    local event, button, mx, my = os.pullEvent("mouse_click")
    if mx >= 2 and my >= 3 and mx <= x - 1 and my <= yPrint - 1 then
      selection = (my - 3) + 1
      shell.run(cat[selection].location)
    end
    cs()
  end
end

-- Call the loading animation function to start the program
loadingAnimation()

-- Call the runMenu function to run the rest of the program
runMenu()
