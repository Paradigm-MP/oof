-- https://stackoverflow.com/a/40195356
--- Check if a file or directory exists in this path
function fs_exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
       if code == 13 then
          -- Permission denied, but it exists
          return true
       end
    end
    return ok, err
 end
 
 --- Check if a directory exists in this path
 function fs_isdir(path)
    -- "/" works on both Unix and Windows
    return fs_exists(path.."/")
 end
 