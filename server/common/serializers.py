from rest_framework import serializers


class GameTypeSerializer(serializers.Serializer):
    type = serializers.CharField()
