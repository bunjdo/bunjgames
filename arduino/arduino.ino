#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiUdp.h>
#include "accessPoints.h"

ESP8266WiFiMulti wifiMulti;
WiFiUDP udp;

const uint32_t connectTimeoutMs = 5000;

IPAddress broadcastAddress;
unsigned int port = 9009;
char buffer[255];

const int buttonPin = 0;
volatile int button = HIGH;

void handleButtonPress() {
  if (button == LOW) {
      button = HIGH;
      udp.beginPacketMulticast(broadcastAddress, port, WiFi.localIP());
      udp.write(buffer);
      udp.endPacket();
  }
}

void ICACHE_RAM_ATTR interrupt() {
  button = LOW;
}

void setup() {
    Serial.begin(115200);

    Serial.println("\n\n");
    Serial.println("Setting up");

    WiFi.mode(WIFI_STA);
    WiFi.disconnect();

    for (const char** accessPoint: ACCESS_POINTS) {
      wifiMulti.addAP(accessPoint[0], accessPoint[1]);
    }

    udp.begin(port);

    pinMode (buttonPin, INPUT);
    attachInterrupt(digitalPinToInterrupt(buttonPin), interrupt, FALLING);

    Serial.println("Setup done");
}

void updateBroadcastIp() {
    broadcastAddress = WiFi.gatewayIP();
    broadcastAddress[3] = 255;

    Serial.print("Broadcasting to: ");
    Serial.print(broadcastAddress);
    Serial.print(":");
    Serial.println(port);
}

void fillBuffer() {
    IPAddress address = WiFi.localIP();

    Serial.print("Local IP: ");
    Serial.println(address);

    sprintf(buffer, "%d.%d.%d.%d:%d", address[0], address[1], address[2], address[3], port);
}

void loop() {
  if(!WiFi.isConnected()) {
     if (wifiMulti.run(connectTimeoutMs) == WL_CONNECTED) {
      Serial.println("Wifi Connected");

      updateBroadcastIp();
      fillBuffer();
      
      delay(100);
    }
  }

  handleButtonPress();
  delay(1);
}
