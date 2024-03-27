#include <WiFi.h>
#include <WebServer.h>

const char* ssid = "YOUR_WIFI_NETWORK_NAME";
const char* password = "YOUR_WIFI_PASSWORD";

WebServer server(80);

void handleRoot() {
  // Read available data from UART
  String uartData = readUARTData();

  // Print received data to serial terminal
  Serial.println("Data received from UART: " + uartData);
  
  // Send response based on received data
  String response;
  if (uartData.length() > 0) {
    response = "Data received from UART: " + uartData;
  } else {
    response = "No data received from UART.";
  }
  
  server.send(200, "text/plain", response);
}

String readUARTData() {
  String data = "";
  while (Serial.available() > 0) {
    char incomingByte = Serial.read();
    data += incomingByte;
  }
  return data;
}

void setup() {
  Serial.begin(115200); // Initialize UART0
  delay(10);

  // Connect to WiFi
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  // Configure web server
  server.on("/", handleRoot);
  server.begin();
  Serial.println("Web server started");
}

void loop() {
  server.handleClient();

  // Send data through UART and wait for response
  Serial.println("Sending message via UART");
  delay(1000); // Optional: wait to establish communication
  
  // Wait for response for a certain period of time
  unsigned long startMillis = millis();
  while (millis() - startMillis < 5000) { // 5-second timeout
    String uartData = readUARTData();
    if (uartData.length() > 0) {
      Serial.println("Response received from UART: " + uartData);
      // Send response to web server
      server.send(200, "text/plain", "Response from UART: " + uartData);
      break; // Exit waiting loop
    }
  }
}
