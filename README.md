### upload middleware

this is a upload middleware for `lor`, it depends on the "uuid" module.

usage example in lor:

```lua
local uploader_middleware = require("app.middleware.uploader")
app:use(uploader_middleware({
    dir = "app/static/avatar" -- static files path
}))
``` 
