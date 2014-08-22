import 'package:mailer/mailer.dart';
import 'dart:io';
import 'dart:convert' as JSON;

void main() {
  var platformEnvironment = Platform.environment;
  print(platformEnvironment);
  var port = 1988;
  if(platformEnvironment['PORT'] != null) {
    port = int.parse(Platform.environment['PORT']);
  }
    HttpServer.bind('0.0.0.0', port).then((HttpServer server) {
      print('Server started on port: ${port}');
      server.listen((HttpRequest request) {
        switch (request.method) {
          case 'GET':
            handleGet(request);
            break;
          case 'POST':
            handlePost(request);
            break;
          case 'OPTIONS':
            handleOptions(request);
            break;
          default: defaultHandler(request);
        }
        request.response..headers.set(HttpHeaders.CONTENT_TYPE, 'application/json')
                        ..write('Request completed')
                        ..close();
      });
    });

//  SendEmail("mnabeelkhan@gmail.com"
//      , "Testing email at: " + (new DateTime.now()).toString()
//      , "<html><body>Test email body</body></html>");

}

/// HTTP Action handlers
///
void addCorsHeaders(HttpResponse response) {
  response.headers.add('Access-Control-Allow-Origin', '*');
  response.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS, GET');
  response.headers.add('Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept');
}

void printError(Error err) {
  print(err);
}

void processGetAction(Uri requestURI) {
  String action = requestURI.path.replaceAll("/", "");
  switch(action.toLowerCase()) {
    case "sendemail":
      SendEmail(requestURI.queryParameters["to"]
          , requestURI.queryParameters["subject"]
          , requestURI.queryParameters["content"] );
      break;
    default: //do nothing
      break;
  }
}

void handleGet(HttpRequest request) {
  HttpResponse response = request.response;
  if(request.uri != null) {
    processGetAction(request.uri);
  }
}

void handlePost(HttpRequest request) {
  HttpResponse response = request.response;
   print('${request.method}: ${request.uri.path}');

   addCorsHeaders(response);

   request.listen((List<int> buffer) {
     // Return the data back to the client.
     response.write('Thanks for the data. This is what I heard you say: ');
     response.write(new String.fromCharCodes(buffer));
     response.close();
   },
   onError: printError);
}

void handleOptions(HttpRequest request) {
  defaultHandler(request);
}

void defaultHandler(HttpRequest request) {

}

/// HTTP Action handers

void SendEmail(String to, String subject, String content) {
  var options = new SmtpOptions()
    ..username = "mnabeelkhan2000@yahoo.com"
    ..password = "R@wa1pindi"
    ..port = 465
    ..secured = true
    ..hostName = "plus.smtp.mail.yahoo.com";

  // Create our email transport.
  var emailTransport = new SmtpTransport(options);

  // Create our mail/envelope.
  var envelope = new Envelope()
   ..from = 'mnabeelkhan2000@yahoo.com'
   ..recipients.add(to)
   ..subject = subject
   //..attachments.add(new Attachment(file: new File('path/to/file')))
   ..text = content
   ..html = content;

  // Email it.
  emailTransport.send(envelope)
   .then((success) => print('Email sent! $success'))
   .catchError((e) => print('Error occured: $e'));
}
