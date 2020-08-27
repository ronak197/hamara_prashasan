import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hamaraprashasan/app_configurations/app_configurations.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<bool> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

  if(googleSignInAccount == null){
    return false;
  }

  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount?.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);

  final FirebaseUser user = authResult.user;

  User.saveUserAuthInfo(user);

  user.getIdToken().then((value) => print(value));
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  if(user != null){
    return true;
  }
  else {
    return false;
  }
}

void signOutGoogle() async{
  await googleSignIn.signOut();
  AppConfigs.clearAllLocalData();

  print("User Signed Out");
}