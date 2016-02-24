### upload middleware

this is a upload middleware for `lor`, it depends on the "uuid" module.

usage:

```lua
app:use(uploader_middleware({
    dir = "app/static/avatar"
}))
``` 
