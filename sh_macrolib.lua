macro_lib = {}
macro_lib.author = "smokingplaya"
macro_lib.version = "0.0.1"
macro_lib.colors = {}

-- Print function
function Print(...)
  for _, obj in ipairs({...}) do
    local fn = istable(obj) and PrintTable or print
    fn(obj)
  end
end

-- Color caching

function CacheColor(ind, col_or_r, g, b, a)
  macro_lib.colors[ind] = IsColor(col_or_r) and col_or_r or Color(r, g, b, a)
end

function GetColor(ind)
  return macro_lib.colors[ind]
end

-- Fonts
