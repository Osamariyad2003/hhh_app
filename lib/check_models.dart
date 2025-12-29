import 'dart:io';
import 'dart:convert';

void main() async {
  var url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models?key=AIzaSyDFm5n8FpYpyreghigysmptTJ2xZlZQX_8");
  var request = await HttpClient().getUrl(url);
  var response = await request.close();
  var json = await response.transform(utf8.decoder).join();
  var data = jsonDecode(json);
  print('AVAILABLE MODELS:');
  for (var m in data['models']) {
    print(m['name']);
  }
}
