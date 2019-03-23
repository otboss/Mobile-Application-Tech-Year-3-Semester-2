

class Message{
  String sender;
  String username;
  String message;
  String timestamp;

  Message(String sender, String username, String message, String timestamp){
    this.sender = sender;
    this.username = username;
    this.message = message;
    this.timestamp = timestamp;
  }
}