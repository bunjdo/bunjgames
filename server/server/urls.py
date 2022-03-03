from django.conf import settings
from django.conf.urls.static import static
from django.urls import path, include

urlpatterns = [
    path('api/common/', include('common.urls')),
    path('api/whirligig/', include('whirligig.urls')),
    path('api/jeopardy/', include('jeopardy.urls')),
    path('api/weakest/', include('weakest.urls')),
    path('api/feud/', include('feud.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
