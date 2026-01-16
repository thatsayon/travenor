import uuid
import django.db.models.deletion
from django.db import migrations, models

def create_default_transport(apps, schema_editor):
    Transport = apps.get_model('tours', 'Transport')
    db_alias = schema_editor.connection.alias
    Transport.objects.using(db_alias).get_or_create(
        id='73ae01c6-a27a-4224-ad33-514d1024840c',
        defaults={
            'name': 'Default Transport',
            'is_active': True
        }
    )

class Migration(migrations.Migration):

    dependencies = [
        ('tours', '0008_tour_stay'),
    ]

    operations = [
        migrations.RunPython(create_default_transport),
        migrations.AddField(
            model_name='tour',
            name='transport',
            field=models.ForeignKey(default='73ae01c6-a27a-4224-ad33-514d1024840c', on_delete=django.db.models.deletion.PROTECT, related_name='tours', to='tours.transport'),
            preserve_default=False,
        ),
    ]
