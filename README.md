### upload middleware

this is a upload middleware for `lor`, it depends on the "uuid" module.

usage example in lor:

```lua
local upload_middleware = require("app.middleware.upload")
app:use(upload_middleware({
    dir = "app/static/avatar" -- static files path
}))
``` 
