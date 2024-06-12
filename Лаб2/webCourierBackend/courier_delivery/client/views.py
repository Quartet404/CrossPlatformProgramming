from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from firebase_admin import auth
from .models import Client, Order, OrderItem
from business.models import BusinessUser, Item
from courier.models import Courier
import json




@csrf_exempt
def authenticate_user(request):
    body = json.loads(request.body)
    id_token = body.get('idToken')

    try:
        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token['uid']
        phone = decoded_token['phone_number']

        user, created = Client.objects.get_or_create(uid=uid)
        if created:
            user.phone = phone
            user.save()
        # Відправте успішний відповідь
        return JsonResponse({'status': 'success', 'uid': uid}, status=200)
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

def get_user_data(request, uid):
    try:
        user = Client.objects.get(uid=uid)
        data = {
            'phone': user.phone,
            'name': user.name,
            'address': user.address,
        }
        return JsonResponse(data, status=200)
    except Client.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'User not found'}, status=404)
@csrf_exempt
def update_user_info(request):
    if request.method == 'POST':
        try:
            body = json.loads(request.body)
            uid = body.get('uid')
            name = body.get('name', None)
            address = body.get('address', None)

            # Отримати користувача за uid
            user = Client.objects.get(uid=uid)

            # Оновити інформацію користувача
            if name is not None:
                user.name = name
            if address is not None:
                user.address = address

            user.save()

            return JsonResponse({'status': 'success'}, status=200)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=400)

@csrf_exempt
def get_orders(request, uid):
    try:
        client = Client.objects.get(uid=uid)
        orders = Order.objects.filter(customer_id=client)
        order_list = [
            {
                'order_number': order.id,
                'date': order.timestamp.strftime('%d.%m.%Y'),
                'time': order.timestamp.strftime('%H:%M'),
                'status': order.status,
                'total': sum(item.price * item.quantity for item in order.orderitem_set.all())
            }
            for order in orders
        ]
        return JsonResponse({'status': 'success', 'orders': order_list}, status=200)
    except Client.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'User not found'}, status=404)
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)


@csrf_exempt
def get_stores(request):
    try:
        stores = BusinessUser.objects.all().values('id', 'username', 'address', 'status', 'photo')
        stores_list = []
        for store in stores:
            if store['photo']:
                store['photo'] = request.build_absolute_uri(settings.MEDIA_URL + store['photo'])
            stores_list.append(store)
        return JsonResponse({'status': 'success', 'stores': stores_list}, status=200)
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

@csrf_exempt
def create_order(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            customer_uid = data.get('customer_uid')
            business_id = data.get('business_id')
            items = data.get('items')

            print(f"Customer UID: {customer_uid}")
            print(f"Business ID: {business_id}")
            print(f"Items: {items}")

            customer = Client.objects.get(uid=customer_uid)
            business = BusinessUser.objects.get(username=business_id)  # Assuming business_id is username

            order = Order.objects.create(
                customer=customer,
                business=business,
                courier=None,
                status='Оброблюється'
            )

            for item in items:
                item_obj = Item.objects.get(id=item['id'])
                OrderItem.objects.create(
                    order=order,
                    item=item_obj,
                    price=item['price'],
                    quantity=item['quantity']
                )

            return JsonResponse({'status': 'success', 'order_id': order.id}, status=201)

        except Exception as e:
            print(f"Error: {e}")
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method.'}, status=405)


@csrf_exempt
def get_orders(request, uid):
    if request.method == 'GET':
        try:
            customer = Client.objects.get(uid=uid)
            orders = Order.objects.filter(customer=customer)
            orders_list = [{
                'id': order.id,
                'order_number': order.id,
                'date': order.timestamp.date(),
                'time': order.timestamp.time(),
                'status': order.status,
                'total': sum(item.price * item.quantity for item in order.orderitem_set.all())
            } for order in orders]

            return JsonResponse({'status': 'success', 'orders': orders_list}, status=200)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method.'}, status=405)


@csrf_exempt
def accept_order(request, order_id):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            courier_id = data.get('courier_id')

            order = Order.objects.get(id=order_id)
            courier = Courier.objects.get(id=courier_id)
            order.status = 'Доставляється'
            order.courier = courier
            order.save()

            return JsonResponse({'status': 'success'}, status=200)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method.'}, status=405)


@csrf_exempt
def get_order_details(request, order_id):
    if request.method == 'GET':
        try:
            order = Order.objects.get(id=order_id)
            items = OrderItem.objects.filter(order=order)
            items_list = [{
                'id': item.id,
                'name': item.item.name if item.item else 'Unknown',
                'price': str(item.price),
                'quantity': item.quantity,
                'image': request.build_absolute_uri(item.item.image.url) if item.item and item.item.image else None
            } for item in items]

            order_data = {
                'id': order.id,
                'status': order.status,
                'timestamp': order.timestamp,
                'items': items_list
            }

            return JsonResponse({'status': 'success', 'order': order_data}, status=200)
        except Order.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Order not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method.'}, status=405)


