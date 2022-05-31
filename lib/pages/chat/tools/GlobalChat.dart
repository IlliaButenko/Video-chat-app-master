import 'package:OCWA/models/user_model.dart';
import 'package:uuid/uuid.dart';

class G {
  // Logged In User ID
  static int loggedInId;
  // Logged In User
  static UserModel loggedInUser;

  static genUniqueIdFileName(String tmpName) {
    var uuid = Uuid();
    final data = tmpName.split(".");
    String ext = data[1];
    String name = data[0].replaceAll("image_picker", "");
    return uuid.v1() + '-' + name + '.' + ext;
  }
}
