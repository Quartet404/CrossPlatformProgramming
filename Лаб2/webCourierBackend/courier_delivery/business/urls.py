# courier_delivery/business/urls.py

from django.urls import path
from .views import get_stores, get_categories, get_items, get_item_details

urlpatterns = [
    path('stores/', get_stores),
    path('<str:store_name>/categories/', get_categories),
    path('categories/<int:category_id>/items/', get_items),
    path('items/<int:item_id>/', get_item_details),
]
