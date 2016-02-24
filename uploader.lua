local upload = require("resty.upload")
local uuid = require("app.libs.uuid.uuid")

local sfind = string.find
local match = string.match
local ngx_var = ngx.var
local get_headers = ngx.req.get_headers()


local function getextension(filename)
	return filename:match(".+%.(%w+)$")
end


local function _multipart_formdata(config)
	local form, err = upload:new(config.chunk_size)
	if not form then
		ngx.log(ngx.ERR, "failed to new upload: ", err)
		ngx.exit(500)
	end
	form:set_timeout(config.recieve_timeout)

	local unique_name = uuid()
	local file, origin_filename, filename, path, extname
	while true do
		local typ, res, err = form:read()

		if not typ then
			ngx.log(ngx.ERR, "failed to read: ", err)
			ngx.exit(500)
		end

		if typ == "header" then
			if res[1] == "Content-Disposition" then
				key = match(res[2], "name=\"(.-)\"")
				origin_filename = match(res[2], "filename=\"(.-)\"")
			elseif res[1] == "Content-Type" then
				filetype = res[2]
			end

			if origin_filename and filetype then
				if not extname then
					extname = getextension(origin_filename)
				end

				filename = unique_name .. "." .. extname
				path = config.dir.. "/" .. filename
				
				file = io.open(path, "w+")
			end
	
		elseif typ == "body" then
			if file then
				file:write(res)
			else
				ngx.log(ngxERR, path, " not exist")
			end
		elseif typ == "part_end" then
            file:close()
            file = nil
		elseif typ == "eof" then
			break
		else
			-- do nothing
		end
	end

	return origin_filename, extname, path, filename
end

local function _check_post(config)
	local filename = nil
	local extname = nil
	local path = nil


	if ngx_var.request_method == "POST" then
		local header = get_headers['Content-Type']
		local is_multipart = sfind(header, "multipart")
		if is_multipart and is_multipart>0 then
			origin_filename, extname, path, filename= _multipart_formdata(config)
		end
	end


	return origin_filename, extname, path, filename
end

local function uploader(config)
	config = config or {}
	config.dir = config.dir or "/tmp"
	config.chunk_size = config.chunk_size or 4096
	config.recieve_timeout = config.recieve_timeout or 20000 -- 20s

	return function(req, res, next)
		local origin_filename, extname, path, filename = _check_post(config)
		req.file = req.file or {}
		req.file.origin_filename = origin_filename
		req.file.extname = extname
		req.file.path = path
		req.file.filename = filename
		next()
	end
end

return uploader

