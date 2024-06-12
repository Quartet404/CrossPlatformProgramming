from django.contrib import admin

from .models import Client, Order, OrderItem

# Register your models here.
admin.site.register(Client)
admin.site.register(Order)
admin.site.register(OrderItem)