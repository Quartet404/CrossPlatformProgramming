from django.urls import path
from .views import authenticate_user, update_user_info, get_user_data, get_orders, get_stores, create_order, \
    get_order_details

urlpatterns = [
    path('auth/', authenticate_user),
    path('update/', update_user_info),
    path('user/<str:uid>/', get_user_data),
    path('orders/<str:uid>/', get_orders),
    path('stores/', get_stores),
    path('orders/', create_order, name='create_order'),
    path('order/<int:order_id>/details/', get_order_details),
]