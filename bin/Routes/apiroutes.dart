import '../Auth/auth.dart';
import '../server.dart';

class ApiRoutes {
  alfedRoutes() {
    app.post("/api/login", AuthHandler.login);
    app.post("/api/signup", AuthHandler.signup);
    app.get('/images/*', (req, res) => directory);
  }
}
