from django.contrib.auth.models import AbstractUser, Group, Permission
from django.core.validators import MinValueValidator
from django.db import models


# Create your models here.
class BusinessUser(AbstractUser):
    USERNAME_FIELD = 'username'
    username = models.CharField('Назва бізнесу', max_length=15, default='Default Name', unique=True)
    address = models.CharField('Адреса', max_length=50, default='УКРАЇНА, Київ')
    status = models.CharField('Статус', max_length=10, default='Закрито')
    photo = models.ImageField('Логотип бізнесу', upload_to='business_photos/', blank=True, null=True)
    groups = models.ManyToManyField(
        Group,
        verbose_name='Групи',
        blank=True,
        related_name='business_user_groups'
    )
    user_permissions = models.ManyToManyField(
        Permission,
        verbose_name='Дозволи користувача',
        blank=True,
        related_name='business_user_permissions'
    )


class Category(models.Model):
    business_id = models.ForeignKey(BusinessUser, on_delete=models.CASCADE) # foreign key to business
    name = models.CharField('Назва', max_length=15)
    image = models.ImageField('Зоображення категорії', upload_to='category_photos/', blank=True, null=True)


class Item(models.Model):
    category_id = models.ForeignKey(Category, on_delete=models.CASCADE) # foreign key to category
    name = models.CharField('Назва', max_length=30)
    descriprtion = models.TextField('Опис товару', max_length=200)
    price = models.DecimalField('Ціна', max_digits=7, decimal_places=2, default=0, validators=[MinValueValidator(0)])
    image = models.ImageField('Зоображення товару', upload_to='item_photos/', blank=True, null=True)
