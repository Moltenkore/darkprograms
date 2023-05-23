local Version = 2.12
local x, y = term.getSize()

if not http then
  print("Herp derp, forgot to enable HTTP?")
  return
end

local function getUrlFile(url)
  local response = http.get(url)
  if response then
    local content = response.readAll()
    response.close()
    return content
  end
  return nil
end

local function writeFile(filename, data)
  local file = fs.open(filename, "w")
  file.write(data)
  file.close()
end

local function cs()
  term.clear()
  term.setCursorPos(1, 1)
end

local function tc(tcolor, bcolor)
  if term.isColor() then
    if tcolor then
      term.setTextColor(colors[tcolor])
    end
    if bcolor then
      term.setBackgroundColor(colors[bcolor])
    end
  end
end

local function writeC(text, line)
  term.setCursorPos((x / 2) - (#text / 2), line)
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
  tc("white", "blue")
  writeC(string.rep("  ", x), 1)
  writeC(string.rep("  ", x), y)
  writeC(text, 1)
  tc("white", "black")
end

local function gitUpdate(ProgramName, Filename, ProgramVersion)
  if http then
    local status, getGit = pcall(http.get, "https://raw.githubusercontent.com/rservices/darkprograms/darkprograms/programVersions")
    if not status then
      print("\nFailed to get Program Versions file.")
      print("Error: " .. getGit)
      return false
    end
    local getGitContent = getGit.readAll()
    getGit.close()
    local NVersion = textutils.unserialize(getGitContent)
    if NVersion[ProgramName].Version > ProgramVersion then
      getGit = http.get(NVersion[ProgramName].GitURL)
      if getGit then
        local getGitContent = getGit.readAll()
        getGit.close()
        writeFile(Filename, getGitContent)
        return true
      else
        print("\nFailed to download updated program.")
        return false
      end
    end
  else
    return false
  end
end

cs()
print("Checking for updates...")
if gitUpdate("darkretriever", shell.getRunningProgram(), Version) then
  print("Update found and downloaded.")
  print("\nPlease run " .. shell.getRunningProgram() .. " again.")
  return
else
  print("Program up-to-date.")
end
sleep(1)

x, y = term.getSize()
cs()
term.write("-> Grabbing file...")
local cat = getUrlFile("https://raw.githubusercontent.com/rservices/darkprograms/darkprograms/programVersions")
if cat then
  cat = textutils.unserialize(cat)
  term.write(" Done.")
  sleep(1)
  cs()

  local menu = {}
  local rawName = {}

  --[[
  -Author
  --Package
  ---Program
  ]]--

  for name, data in pairs(cat) do
    if not menu[data.Author] then
      menu[data.Author] = {}
    end
    if not menu[data.Author][data.Package] then
      menu[data.Author][data.Package] = {}
    end
    if not menu[data.Author][data.Package][name] then
      menu[data.Author][data.Package][data.Name] = data
      rawName[data.Name] = name
    end
  end

  local state = "top"
  local csel = 1 --Current selected
  local osel = {1} --breadcrumb

  local page = 0
  local ind = 3 --Y indent
  local ava = y - ind --Available space
  local level = 1

  local function selection(no, list, totpage)
    term.setCursorPos(1, (no - mod) + (ind - 1))
    tc("white")
    term.write("[" .. list[no] .. "]")
    tc("white", "black")
    term.setCursorPos(1, y)
    tc("white", "blue")
    term.write("Page: " .. page + 1 .. "/" .. totpage)
    term.setCursorPos(x - 8, y)
    term.write("By OutragedMetro .INC")
    tc("white", "black")
  end

  local function draw(tbl)
    local c = 1
    local sdat = {}
    local odat = {}
    for n, d in pairs(tbl) do
      table.insert(sdat, n)
      table.insert(odat, d)
      c = c + 1
    end
    if level ~= 4 then
      table.sort(sdat)
    end

    local tpages = math.ceil(c / (y - ind))
    local mod = page * (y - ind)

    for i = 1, y - ind do
      term.setCursorPos(2, i + ind - 1)
      term.write(sdat[i + mod])

      if level == 4 then
        term.setCursorPos(15, i + ind - 1)
        if type(odat[i + mod]) == "string" and #odat[i + mod] + 14 > x then
          term.write(string.sub(odat[i + mod], 1, x - 14 - 2) .. "..")
        else
          term.write(odat[i + mod])
        end
      end
    end

    if level == 4 then
      term.setCursorPos(1, y - 2)
      writeC("Press enter to download.", y - 2)
    end

    return sdat, tpages, mod
  end

  local function runMenu()
    while true do
      cs()
      if level == 1 then
        local list, totpage, mod = draw(menu)
        header("Authors")

        tc("white", "black")
        writeC("Press 'h' for help, 'q' to quit.", 2)
        tc("white", "black")

      elseif level == 2 then
        local list, totpage, mod = draw(menu[auna])
        header("Packages")
      elseif level == 3 then
        local list, totpage, mod = draw(menu[auna][pkg])
        header("Programs")
      elseif level == 4 then
        header("Program Data")
        local list, totpage, mod = draw(menu[auna][pkg][pro])
      end

      selection(csel, list, totpage)

      local event, key = os.pullEvent("key")

      if key == keys.h then
        cs()
        header("Help")
        term.setCursorPos(1, ind)
        print("Use the up and down arrows to move through the list.")
        print("Use the right arrow to enter a menu item and the left arrow to exit.")
        print("https://outragedmetro.wixsite.com/darkprograms\n")
        print("Press any key to continue.")
        os.pullEvent("key")
      elseif key == keys.q then
        return
      elseif key == keys.right then
        if level == 1 then
          auna = list[csel]
          level = 2
          table.insert(osel, csel)
        elseif level == 2 then
          pkg = list[csel]
          level = 3
          table.insert(osel, csel)
        elseif level == 3 then
          pro = rawName[list[csel]]
          level = 4
        elseif level == 4 then
          local meta = menu[auna][pkg][pro]
          cs()
          header("Downloading " .. meta.Name)
          term.setCursorPos(1, ind)
          term.write("-> Downloading file...")

          local content = getUrlFile(meta.GitURL)
          if content then
            local filename = meta.Name .. ".lua"
            writeFile(filename, content)
            term.setCursorPos(1, ind + 2)
            term.write("-> File downloaded successfully!")
            sleep(2)
            return
          else
            term.setCursorPos(1, ind + 2)
            term.write("-> Failed to download the file.")
            sleep(2)
            return
          end
        end
        csel = 1
      elseif key == keys.left then
        if level == 1 then
          return
        elseif level == 2 then
          level = 1
          table.remove(osel)
          csel = osel[#osel]
        elseif level == 3 then
          level = 2
          table.remove(osel)
          csel = osel[#osel]
        elseif level == 4 then
          level = 3
        end
      elseif key == keys.up then
        if csel > 1 then
          csel = csel - 1
        else
          if page > 0 then
            page = page - 1
          end
        end
      elseif key == keys.down then
        if csel < ava then
          if csel < #list then
            csel = csel + 1
          end
        else
          if page < totpage - 1 then
            page = page + 1
          end
        end
      end
    end
  end

  runMenu()
end
