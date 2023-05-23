-- Dark Package Manager

local function tc(bg, fg)
  term.setBackgroundColor(bg)
  term.setTextColor(fg)
end

local function cs()
  term.clear()
  term.setCursorPos(1, 1)
end

local function header(text)
  tc(colors.white, colors.black)
  term.setCursorPos(1, 1)
  term.write("Dark Package Manager")
  tc(colors.black, colors.gray)
  term.setCursorPos(1, 2)
  term.write(text)
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

local function writeFile(filename, content)
  local file = fs.open(filename, "w")
  file.write(content)
  file.close()
end

local function darkPackageManager()
  local level = 1
  local menu = {}
  local osel = {}
  local csel = 1
  local ind = 4

  cs()
  header("Loading...")

  local content = getUrlFile("https://raw.githubusercontent.com/darkrising/dark-pm/main/index.json")
  if not content then
    cs()
    header("Failed to load data.")
    sleep(2)
    return
  end

  menu = textutils.unserialize(content)

  local function selection(c, data, tpages)
    local mod = (csel - 1) % (term.getSize().y - ind)
    local ava = term.getSize().y - ind
    local sdat = {}
    local odat = {}

    if level == 2 then
      sdat = data[osel[1]]
    elseif level == 3 then
      sdat = data[osel[1]][osel[2]]
    elseif level == 4 then
      sdat = data[osel[1]][osel[2]]
      odat = sdat
      sdat = sdat[csel]
    end

    term.setCursorPos(1, ind)

    if mod ~= 0 then
      tc(colors.white, colors.black)
      term.write("      [Back]")
    end

    for i = 1, term.getSize().y - ind - 1 do
      term.setCursorPos(1, i + ind)
      term.clearLine()

      if (i + mod) <= c then
        if level == 4 then
          if (i + mod) == csel then
            tc(colors.white, colors.blue)
            term.write("[" .. (i + mod) .. "] ")
            tc(colors.blue, colors.white)
          else
            tc(colors.white, colors.black)
            term.write("[" .. (i + mod) .. "] ")
          end
          term.write(sdat)
        else
          if (i + mod) == csel then
            tc(colors.white, colors.blue)
            term.write("[" .. (i + mod) .. "] ")
            tc(colors.blue, colors.white)
          else
            tc(colors.white, colors.black)
            term.write("[" .. (i + mod) .. "] ")
          end
          term.write(data[i + mod])
        end
      end
    end

    if mod == 0 then
      tc(colors.white, colors.black)
      term.write("      [Next]")
    end
  end

  local function draw(list)
    local c = #list
    local mod = (csel - 1) % (term.getSize().y - ind)
    local ava = term.getSize().y - ind
    local page = math.floor((csel - 1) / ava)
    local tpages = math.ceil(c / ava)

    cs()
    header("Main Menu")

    term.setCursorPos(1, ind)
    tc(colors.white, colors.black)
    term.write("      [Exit]")

    selection(c, list, tpages)
  end

  local function runMenu()
    while true do
      draw(menu[level])

      local event, key = os.pullEvent("key")

      if key == keys.enter then
        if csel == 1 and level > 1 then
          if level == 2 then
            level = 1
            osel = {}
          elseif level == 3 then
            level = 2
            table.remove(osel)
          elseif level == 4 then
            level = 3
          end
          csel = 1
        elseif level == 4 and menu[level][csel] ~= nil then
          cs()
          header("Downloading...")
          term.setCursorPos(1, ind + 1)

          local url = odat[csel]
          local filename = fs.getName(url)
          local content = getUrlFile(url)
          if content then
            writeFile(filename, content)
            header("Download completed!")
          else
            header("Failed to download.")
          end
          sleep(2)
        elseif level < 4 and menu[level][csel] ~= nil then
          table.insert(osel, csel)
          level = level + 1
          csel = 1
        end
      elseif key == keys.backspace and level > 1 then
        if level == 2 then
          level = 1
          osel = {}
        elseif level == 3 then
          level = 2
          table.remove(osel)
        elseif level == 4 then
          level = 3
        end
        csel = 1
      elseif key == keys.up then
        if csel > 1 then
          csel = csel - 1
        end
      elseif key == keys.down then
        if csel < #menu[level] then
          csel = csel + 1
        end
      elseif key == keys.pageUp then
        if page > 0 then
          page = page - 1
          csel = csel - ava
        end
      elseif key == keys.pageDown then
        local tpages = math.ceil(#menu[level] / (term.getSize().y - ind))
        if page < tpages - 1 then
          page = page + 1
          csel = csel + ava
        end
      end
    end
  end

  runMenu()
end

darkPackageManager()
