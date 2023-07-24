--Written by darkrising
version = 1.101

function checkUpdate()
  if http then
    local getGit = http.get("https://raw.githubusercontent.com/rservices/darkprograms/darkprograms/programVersions")
    local getGit = getGit.readAll()
    NVersion = textutils.unserialize(getGit)
    if NVersion["darkfile"].Version > version then
      getGit = http.get(NVersion["darkfile"].GitURL)
      getGit = getGit.readAll()
      local file = fs.open("darkfile", "w")
      file.write(getGit)
      file.close()
      return true
    end
  else
    return false
  end
end
local function readFile(filename)
  local contents = {}
  if fs.exists(filename) then
    local file = fs.open(filename, "r")
    while true do
      line = file.readLine()
      if line then
        table.insert(contents, line)
      else
        file.close()
        contents.filename = fs.getName(filename)
        return contents
      end
    end
  else
    error("File doesn't exist.")
  end
end
local function prepFiles(dir)
  if fs.exists(dir) and fs.isDir(dir) then
    local files = fs.list(dir)
    local contents = {}
    contents.bunch = true
    for _,name in pairs(files) do
      if fs.isDir(name) == false then
        contents[name] = readFile(dir..name)
      end
    end
    return contents
  else
    error("Not a directory.")
  end
end

function unpackFiles(m, dir)
  if (fs.exists(dir) == false) and (fs.isDir(dir) == false) then
    error("Passed dir is not a dir or doesn't exist")
  end
  if type(m) == "table" then
    if m.bunch then
      for name,data in pairs(m) do
        if type(data) == "table" then
          file = fs.open(dir.. data.filename, "w")
          for i = 1, #data do
            file.writeLine(data[i])
          end
          file.close()
        end
      end
    else
      file = fs.open(dir.. m.filename, "w")
      for i = 1, #m do
        file.writeLine(m[i])
      end
      file.close()
    end
  else
    error("Not a table.")
  end
end
function unpackFile(message, dir)
  unpackFiles(message, dir)
end
function packFile(filename)
  local file = readFile(filename)
  return file
end
function packDir(dir)
  local filer = prepFiles(dir)
  return filer
end
