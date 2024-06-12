from django.contrib import admin

from .models import Item, Category, BusinessUser

# Register your models here.
admin.site.register(BusinessUser)
admin.site.register(Category)
admin.site.register(Item)