// 'name': nameController.text, // John Doe
// 'userName': userNameController.text, // Stokes and Sons
// 'password': passwordController.text,
// 'info': infoController.text
class PasswordModel {
  String? name, userName, password, info;

  PasswordModel.fromJson(Map<String, dynamic> map) {
    name = map["name"];
    password = map["password"];
    info = map["info"];
    userName = map["userName"];
  }

  toJson() {
    Map<String, String> passwordMap = <String, String>{};
    passwordMap["name"] = name!;
    passwordMap["userName"] = userName!;
    passwordMap["password"] = password!;
    passwordMap["info"] = info!;
    return passwordMap;
  }
}
