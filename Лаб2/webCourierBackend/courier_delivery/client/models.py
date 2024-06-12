# Create your models here.
from django.core.validators import MinValueValidator
from django.db import models
from django.contrib.auth.models import AbstractUser, Group, Permission
from business.models import BusinessUser, Item
from courier.models import Courier


class Client(AbstractUser):
    phone = models.CharField('Телефон', max_length=15, unique=True)
    email = models.EmailField('Пошта', unique=True, blank=True)
    address = models.CharField('Адреса', max_length=50, blank=True)
    photo = models.ImageField('Фото користувача', upload_to='customer_photos/', blank=True, null=True)
    uid = models.CharField(max_length=255, unique=True)
    name = models.CharField('Ім\'я', max_length=50, blank=True)

    class Meta:
        app_label = 'client'
    groups = models.ManyToManyField(
        Group,
        related_name='client_groups',
        blank=True,
        help_text='The groups this user belongs to.',
        verbose_name='client_groups',
    )
    user_permissions = models.ManyToManyField(
        Permission,  related_name='client_permissions',
        blank=True,
        help_text='Specific permissions for this user.',
        verbose_name='client_permissions',
    )


class Order(models.Model):
    customer = models.ForeignKey(Client, on_delete=models.CASCADE)
    business = models.ForeignKey(BusinessUser, on_delete=models.CASCADE)
    courier = models.ForeignKey(Courier, on_delete=models.CASCADE, null=True, blank=True)
    status = models.CharField('Статус', max_length=10)
    timestamp = models.DateTimeField('Час створення', auto_now_add=True)

    def __str__(self):
        return f'Order {self.id} - {self.status}'


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    item = models.ForeignKey(Item, on_delete=models.SET_NULL, null=True)
    price = models.DecimalField('Ціна', max_digits=7, decimal_places=2, default=0, validators=[MinValueValidator(0)])
    quantity = models.SmallIntegerField('Кількість')

    def __str__(self):
        return f'OrderItem {self.id} - {self.quantity} x {self.item.name if self.item else "Unknown"}'
