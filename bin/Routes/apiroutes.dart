import '../Auth/auth.dart';
import '../constants.dart';

class ApiRoutes {
  alfedRoutes() {
    app.post("/api/login", AuthHandler.login);
    app.post("/api/signup", AuthHandler.signup);
    app.post("/api/forgotPassword", AuthHandler.signup);
    app.post("/api/verifyotp", AuthHandler.signup);
    app.post("/api/updatePassword", AuthHandler.signup);
    app.get('/images/*', (req, res) => directory);
  }
}
