#include <bluefruit.h>
//#incude <bluemicro_hid.h>
//#include <Adafruit_CircuitPlayground.h>
#include <Adafruit_TinyUSB.h> // for Serial
//#include <Adafruit_HID.h>

#define debounceDelay 50 // milliseconds

int analogPin1 = A0; // Sensor 1 for red LED
int analogPin2 = A1; // Sensor 2 for yellow LED
int analogPin3 = A2; // Sensor 3 for blue LED
int analogPin4 = A3; // Sensor 4 for green LED
int ledPin1 = 10;  // Red LED
int ledPin2 = 9;  // Yellow LED
int ledPin3 = 6;  // Blue LED
int ledPin4 = 5;  // Green LED
int val1 = 0;  // Variable to store the value read
int val2 = 0;
int val3 = 0;
int val4 = 0;
bool Sens1Pressed = false;
bool Sens2Pressed = false;
bool Sens3Pressed = false;
bool Sens4Pressed = false;

/*------------_DebounceStuff--------------*/
unsigned long lastDebounceTime1 = 0;
unsigned long lastDebounceTime2 = 0;
unsigned long lastDebounceTime3 = 0;
unsigned long lastDebounceTime4 = 0;
bool lastState1 = LOW;
bool lastState2 = LOW;
bool lastState3 = LOW;
bool lastState4 = LOW;
int buttonState1 = HIGH;  // Initial state for sensor 1
int buttonState2 = HIGH;  // Initial state for sensor 2
int buttonState3 = HIGH;  // Initial state for sensor 3
int buttonState4 = HIGH;  // Initial state for sensor 4




// nRF52 based Bluefruit LE modules
BLEDis bledis;          // Bluetooth descriptor characteristic
BLEHidAdafruit blehid;  // Bluetooth HID characteristic

// The setup function runs once when you press reset or power the board
void setup() {
  Serial.begin(115200);
// Initialize digital pin LED_BUILTIN as an output.
  pinMode(ledPin1, OUTPUT);
  pinMode(ledPin2, OUTPUT);
  pinMode(ledPin3, OUTPUT);
  pinMode(ledPin4, OUTPUT);
  
// Initialize hid control
//bluemicro_hid.begin();
Bluefruit.begin();
Bluefruit.setTxPower(4);
Bluefruit.setName("Bluefruit52");

bledis.setManufacturer("Adafruit Industries");
bledis.setModel("Bluefruit Feather 52");
bledis.begin();

blehid.begin();

startAdv();
}

void startAdv(void)
{  
  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  Bluefruit.Advertising.addAppearance(BLE_APPEARANCE_HID_KEYBOARD);
  
  // Include BLE HID service
  Bluefruit.Advertising.addService(blehid);

  // There is enough room for the dev name in the advertising packet
  Bluefruit.Advertising.addName();
  
  /* Start Advertising
   * - Enable auto advertising if disconnected
   * - Interval:  fast mode = 20 ms, slow mode = 152.5 ms
   * - Timeout for fast mode is 30 seconds
   * - Start(timeout) with timeout = 0 will advertise forever (until connected)
   * 
   * For recommended advertising interval
   * https://developer.apple.com/library/content/qa/qa1931/_index.html   
   */
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);                // 0 = Don't stop advertising after n seconds
}

// The loop function runs over and over again forever
void loop() {
  val1 = 1023 - analogRead(analogPin1);  // Read input pin 1
  val2 = 1023 - analogRead(analogPin2);  // Read input pin 2
  val3 = 1023 - analogRead(analogPin3);  // Read input pin 3
  val4 = 1023 - analogRead(analogPin4);  // Read input pin 4

   int state1 = val1 >= 400 ? HIGH : LOW;
   int state2 = val2 >= 400 ? HIGH : LOW;
   int state3 = val3 >= 400 ? HIGH : LOW;
   int state4 = val4 >= 400 ? HIGH : LOW;

    
  // Print sensor values
  Serial.println("Sensor 1: " + String(val1));        
  Serial.println("Sensor 2: " + String(val2));     
  Serial.println("Sensor 3: " + String(val3)); 
  Serial.println("Sensor 4: " + String(val4));
  // Turn on red LED if sensor 1 is pressed
  if (state1 != lastState1) {
        lastDebounceTime1 = millis();
    }
    if ((millis() - lastDebounceTime1) > debounceDelay) {
        if (state1 != buttonState1) {
            buttonState1 = state1;
            if (buttonState1 == HIGH) {
                digitalWrite(ledPin1, HIGH);
                blehid.keyPress('d');
            } else {
                digitalWrite(ledPin1, LOW);
                blehid.keyRelease('d');
            }
        }
    }
    lastState1 = state1;

    // Debounce logic for sensor 2
    if (state2 != lastState2) {
        lastDebounceTime2 = millis();
    }
    if ((millis() - lastDebounceTime2) > debounceDelay) {
        if (state2 != buttonState2) {
            buttonState2 = state2;
            if (buttonState2 == HIGH) {
                digitalWrite(ledPin2, HIGH);
                blehid.keyPress('f');
            } else {
                digitalWrite(ledPin2, LOW);
                blehid.keyRelease('f');
            }
        }
    }
    lastState2 = state2;

    // Debounce logic for sensor 3
    if (state3 != lastState3) {
        lastDebounceTime3 = millis();
    }
    if ((millis() - lastDebounceTime3) > debounceDelay) {
        if (state3 != buttonState3) {
            buttonState3 = state3;
            if (buttonState3 == HIGH) {
                digitalWrite(ledPin3, HIGH);
                blehid.keyPress('j');
            } else {
                digitalWrite(ledPin3, LOW);
                blehid.keyRelease('j');
            }
        }
    }
    lastState3 = state3;

    // Debounce logic for sensor 4
    if (state4 != lastState4) {
        lastDebounceTime4 = millis();
    }
    if ((millis() - lastDebounceTime4) > debounceDelay) {
        if (state4 != buttonState4) {
            buttonState4 = state4;
            if (buttonState4 == HIGH) {
                digitalWrite(ledPin4, HIGH);
                blehid.keyPress('k');
            } else {
                digitalWrite(ledPin4, LOW);
                blehid.keyRelease('k');
            }
        }
    }
    lastState4 = state4;

    // General key release call
    // Note: This might not be necessary if keyPress and keyRelease are handled individually for each key
    // blehid.keyRelease();
}
