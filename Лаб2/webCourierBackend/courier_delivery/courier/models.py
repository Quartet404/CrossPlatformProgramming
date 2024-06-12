from django.db import models


# Create your models here.
class Courier(models.Model):
    phone = models.CharField('Телефон', max_length=12)
    status = models.CharField('Статус', max_length=10)
    photo = models.ImageField('Фото кур\'єра', upload_to='courier_photos/', blank=True, null=True)
    latitude = models.DecimalField('Широта', max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField('Довгота', max_digits=9, decimal_places=6, null=True, blank=True)
