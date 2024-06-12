# courier_delivery/courier/urls.py

from django.urls import path
from .views import courier_login, toggle_shift, accept_order, send_location, create_order, get_orders

urlpatterns = [
    path('courier/login/', courier_login),
    path('courier/toggle_shift/', toggle_shift),
    path('courier/accept_order/', accept_order),
    path('courier/send_location/', send_location),
    path('orders/<str:uid>/', get_orders),
    path('orders/', create_order),
]
