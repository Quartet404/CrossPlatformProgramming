from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import BusinessUser, Category, Item


def get_stores(request):
    stores = BusinessUser.objects.all()
    stores_list = [{'name': store.username, 'address': store.address, 'photo': request.build_absolute_uri(store.photo.url) if store.photo else None} for store in stores]
    return JsonResponse({'stores': stores_list})


def get_categories(request, store_name):
    try:
        store = BusinessUser.objects.get(username=store_name)
        categories = Category.objects.filter(business_id=store.id)
        categories_list = [{'id': category.id, 'name': category.name, 'image': request.build_absolute_uri(category.image.url) if category.image else None} for category in categories]
        return JsonResponse({'status': 'success', 'categories': categories_list}, status=200)
    except BusinessUser.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Store not found'}, status=404)
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

@csrf_exempt
def get_item_details(request, item_id):
    try:
        item = Item.objects.get(id=item_id)
        item_data = {
            'name': item.name,
            'description': item.descriprtion,
            'price': str(item.price),
            'image': request.build_absolute_uri(item.image.url) if item.image else None,
            'category_name': item.category_id.name
        }
        return JsonResponse({'status': 'success', 'item': item_data}, status=200)
    except Item.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Item not found'}, status=404)
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)


@csrf_exempt
def get_items(request, category_id):
    try:
        category = Category.objects.get(id=category_id)
        items = Item.objects.filter(category_id=category.id)
        items_list = [{'id': item.id, 'name': item.name, 'description': item.descriprtion, 'price': item.price, 'image': request.build_absolute_uri(item.image.url) if item.image else None} for item in items]
        return JsonResponse({'status': 'success', 'items': items_list}, status=200)
    except Category.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Category not found'}, status=404)
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
