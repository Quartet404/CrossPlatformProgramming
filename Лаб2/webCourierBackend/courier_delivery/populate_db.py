import os
import django

# Налаштування змінної середовища для налаштувань Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'courier_delivery.settings')
django.setup()

from business.models import BusinessUser, Category, Item

def populate():
    # Створення бізнес користувачів
    business1 = BusinessUser.objects.create_user(username='Store 1', address='Address 1', status='Open')
    business2 = BusinessUser.objects.create_user(username='Store 2', address='Address 2', status='Open')

    # Створення категорій для бізнесу 1
    category1 = Category.objects.create(business_id=business1, name='Electronics')
    category2 = Category.objects.create(business_id=business1, name='Clothing')

    # Створення товарів для категорій
    Item.objects.create(category_id=category1, name='Laptop', descriprtion='A high-end laptop', price=1500.00)
    Item.objects.create(category_id=category1, name='Smartphone', descriprtion='A latest model smartphone', price=800.00)
    Item.objects.create(category_id=category2, name='T-shirt', descriprtion='A cotton t-shirt', price=20.00)
    Item.objects.create(category_id=category2, name='Jeans', descriprtion='A pair of jeans', price=40.00)

    # Створення категорій для бізнесу 2
    category3 = Category.objects.create(business_id=business2, name='Groceries')
    category4 = Category.objects.create(business_id=business2, name='Stationery')

    # Створення товарів для категорій
    Item.objects.create(category_id=category3, name='Apple', descriprtion='Fresh apple', price=2.00)
    Item.objects.create(category_id=category3, name='Banana', descriprtion='Ripe banana', price=1.50)
    Item.objects.create(category_id=category4, name='Notebook', descriprtion='A ruled notebook', price=3.00)
    Item.objects.create(category_id=category4, name='Pen', descriprtion='A ballpoint pen', price=1.00)

    print("Database populated successfully!")

if __name__ == '__main__':
    populate()
