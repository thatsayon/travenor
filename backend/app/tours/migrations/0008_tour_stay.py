import uuid
import django.db.models.deletion
from django.db import migrations, models

def create_default_stay(apps, schema_editor):
    Stay = apps.get_model('tours', 'Stay')
    db_alias = schema_editor.connection.alias
    Stay.objects.using(db_alias).get_or_create(
        id='4fa042cd-a947-4270-ae4a-255a35b04f56',
        defaults={
            'name': 'Default Stay',
            'is_active': True
        }
    )

class Migration(migrations.Migration):

    dependencies = [
        ('tours', '0007_remove_stay_stay_type_stay_icon'),
    ]

    operations = [
        migrations.RunPython(create_default_stay),
        migrations.AddField(
            model_name='tour',
            name='stay',
            field=models.ForeignKey(default='4fa042cd-a947-4270-ae4a-255a35b04f56', on_delete=django.db.models.deletion.PROTECT, related_name='tours', to='tours.stay'),
            preserve_default=False,
        ),
    ]
