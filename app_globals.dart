
//Requests
String delivery_recipientAddress = "";
String delivery_receiverAddress = "";
double delivery_recipientAddressLAT = 0.0;
double delivery_recipientAddressLONG = 0.0;
double delivery_receiverAddressLAT = 0.0;
double delivery_receiverAddressLONG = 0.0;
String totalDistance = "";

//Tracking
double tracking_pickupLAT = 0.0;
double tracking_pickupLONG = 0.0;
double tracking_dropoffLAT = 0.0;
double tracking_dropoffLONG = 0.0;

//Rider
bool active_status = false;

void clearAddresses() {
  delivery_recipientAddress = "";
  delivery_receiverAddress = "";
  delivery_recipientAddressLAT = 0.0;
  delivery_recipientAddressLAT = 0.0;
  delivery_receiverAddressLONG = 0.0;
  delivery_recipientAddressLONG = 0.0;
  totalDistance = "";
}

void clearTracking() {
  tracking_pickupLAT = 0.0;
  tracking_pickupLONG = 0.0;
  tracking_dropoffLAT = 0.0;
  tracking_dropoffLONG = 0.0;
}