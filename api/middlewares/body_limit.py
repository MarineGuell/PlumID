# api/middlewares/body_limit.py
from __future__ import annotations
from starlette.types import ASGIApp, Receive, Scope, Send
from starlette.responses import JSONResponse

class BodySizeLimitMiddleware:
    def __init__(self, app: ASGIApp, max_bytes: int):
        self.app = app
        self.max_bytes = max_bytes

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        received = 0
        chunks = []

        async def limited_receive():
            nonlocal received
            message = await receive()
            if message["type"] == "http.request":
                body = message.get("body", b"")
                received += len(body)
                if received > self.max_bytes:
                    resp = JSONResponse({"detail": "Request entity too large"}, status_code=413)
                    await resp(scope, receive, send)
                    return {"type": "http.disconnect"}
            return message

        await self.app(scope, limited_receive, send)
