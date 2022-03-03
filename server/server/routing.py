from channels.routing import ProtocolTypeRouter, URLRouter
from django.urls import path

import jeopardy.urls
import weakest.urls
import whirligig.urls
import feud.urls

application = ProtocolTypeRouter({
    'websocket': URLRouter([
        path('ws/whirligig/', URLRouter(whirligig.urls.websocket_urlpatterns)),
        path('ws/jeopardy/', URLRouter(jeopardy.urls.websocket_urlpatterns)),
        path('ws/weakest/', URLRouter(weakest.urls.websocket_urlpatterns)),
        path('ws/feud/', URLRouter(feud.urls.websocket_urlpatterns)),
    ]),
})
