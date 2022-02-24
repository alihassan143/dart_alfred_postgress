import '../Auth/auth.dart';
import '../MiddleWares/middleware.dart';
import '../constants.dart';

class ApiRoutes {
  alfedRoutes() {
    app.post("/api/login", AuthHandler.login);
    app.post("/api/signup", AuthHandler.signup);
    app.post("/api/forgotPassword", AuthHandler.sendOtpTOEmail);
    app.post("/api/updatePassword", AuthHandler.updatePassword,
        middleware: [ApiMiddleWare.applicationMiddelWare]);
    app.get('/images/*', (req, res) => directory);
  }
}
