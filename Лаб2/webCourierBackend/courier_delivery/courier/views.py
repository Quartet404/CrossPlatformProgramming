from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from client.models import Client, Order, OrderItem
from business.models import BusinessUser, Item
from .models import Courier
import json

@csrf_exempt
def courier_login(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            phone = data['phone']
            password = data['password']
            courier = Courier.objects.get(phone=phone)
            if courier.password == password:
                return JsonResponse({'status': 'success', 'courier': {'id': courier.id}}, status=200)
            else:
                return JsonResponse({'status': 'error', 'message': 'Invalid password'}, status=400)
        except Courier.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Courier not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)

@csrf_exempt
def toggle_shift(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            courier_id = data['courier_id']
            courier = Courier.objects.get(id=courier_id)
            courier.status = 'on shift' if courier.status == 'off shift' else 'off shift'
            courier.save()
            return JsonResponse({'status': 'success', 'courier': {'id': courier.id, 'status': courier.status}}, status=200)
        except Courier.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Courier not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)

@csrf_exempt
def accept_order(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            courier_id = data['courier_id']
            order_id = data['order_id']
            courier = Courier.objects.get(id=courier_id)
            order = Order.objects.get(id=order_id)
            order.courier = courier
            order.status = 'Доставляється'
            order.save()
            return JsonResponse({'status': 'success', 'order': {'id': order.id, 'status': order.status}}, status=200)
        except Courier.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Courier not found'}, status=404)
        except Order.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Order not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)

@csrf_exempt
def send_location(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            courier_id = data['courier_id']
            latitude = data['latitude']
            longitude = data['longitude']
            courier = Courier.objects.get(id=courier_id)
            courier.latitude = latitude
            courier.longitude = longitude
            courier.save()
            return JsonResponse({'status': 'success'}, status=200)
        except Courier.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Courier not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method.'}, status=405)

@csrf_exempt
def create_order(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            customer_uid = data['customer_uid']
            business_id = data['business_id']
            items = data['items']

            customer = Client.objects.get(uid=customer_uid)
            business = BusinessUser.objects.get(username=business_id)
            order = Order.objects.create(customer=customer, business=business, status='Оброблюється')

            for item in items:
                item_obj = Item.objects.get(id=item['id'])
                OrderItem.objects.create(
                    order=order,
                    item=item_obj,
                    price=item_obj.price,
                    quantity=item['quantity']
                )

            return JsonResponse({'status': 'success', 'order_id': order.id}, status=201)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)

@csrf_exempt
def get_orders(request, uid):
    if request.method == 'GET':
        try:
            orders = Order.objects.filter(customer__uid=uid)
            orders_list = [{
                'id': order.id,
                'customer': order.customer.name,
                'business': order.business.username,
                'status': order.status,
                'timestamp': order.timestamp,
            } for order in orders]

            return JsonResponse({'status': 'success', 'orders': orders_list}, status=200)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method.'}, status=405)
