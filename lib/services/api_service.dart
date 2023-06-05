import 'dart:convert';

import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diagora/models/user_model.dart';

/// Classe qui contient toutes les routes de l'API. Utilisez [route] pour créer une Uri.
class ApiRoutes {
  static const String baseUrl = 'http://localhost:3000';
  // Authentification
  static const String loginRoute = '/user/login'; // POST
  static const String registerRoute = '/user/register'; // POST
  static const String logoutRoute = '/user/logout'; // POST
  // User(s)
  static const String usersRoute = '/user'; // GET
  static const String userRoute = '/user/:id'; // GET, PATCH, DELETE
  static const String userPermissionsRoute = '/user/permissions/:id'; // GET
  // Permissions
  static const String permissionsRoute = '/permissions'; // GET
  static const String permissionRoute = '/permissions/:id'; // GET, PATCH
  // Entreprise(s)
  static const String companiesRoute = '/company'; // GET, POST
  static const String companyRoute = '/company/:id'; // GET, PATCH, DELETE
  // Événement(s)
  static const String userScheduleRoute = '/schedule/:user_id'; // GET, POST
  static const String scheduleRoute = '/schedule/:id'; // PATCH, DELETE
  static const String scheduleSlotsRoute =
      '/schedule/avalaibleSlots/:event_id'; // GET
  // Véhicule(s)
  static const String vehiclesRoute = '/vehicle'; // GET, POST
  static const String vehicleRoute = '/vehicle/:id'; // GET, PATCH, DELETE
  // Itinéraire(s)
  static const String itinerariesUserRoute = '/itinerary/:user_id'; // GET, POST
  static const String itinerariesRoute = '/itinerary/:id'; // PATCH, DELETE

  /// Permet de créer l'URL complète d'une route.
  ///
  /// [route] est la route à utiliser.
  static Uri route(String route) => Uri.parse('$baseUrl$route');
}

/// Service qui permet de communiquer avec l'API.
/// Ce service est un singleton, pour l'instancier, il faut utiliser la méthode [getInstance].
class ApiService {
  // Attributs généraux
  bool get isInitialized => _prefs != null;
  static SharedPreferences? _prefs;
  static final Client _httpClient = Client();
  static final Logger _logger = Logger();
  static const ApiService _instance = ApiService();

  // Constructeur par défaut
  const ApiService();

  // Utilisateur connecté
  static User? _user;
  User? get user => _user;
  static String? _token;

  /// Permet d'obtenir une instance de [ApiService].
  static ApiService getInstance() {
    if (_prefs == null) {
      SharedPreferences.getInstance().then((value) {
        _prefs = value;
        _token ??= _prefs?.getString('token');
        _user ??= _prefs?.getString('user') != null
            ? User.fromJson(json.decode(_prefs!.getString('user')!))
            : null;
      });
    }
    return _instance;
  }

  /// Permet de se connecter à l'application.
  ///
  /// Prend en paramètre un [email] et un [password].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client] et un [remember] qui est un [bool].
  ///
  /// Retourne un [bool] qui indique si la connexion a réussi.
  Future<bool> login(
    String email,
    String password, {
    bool remember = false,
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.loginRoute);
      Response response = await client.post(
        url,
        body: json.encode(
          {'email': email, 'password': password, 'remember': remember},
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        _prefs?.setString('token', responseData['token']);
        return true;
      } else {
        _logger.e('Login failed with status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  /// Permet de s'inscrire à l'application.
  ///
  /// Prend en paramètre un [name], un [email] et un [password].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [bool] qui indique si l'inscription a réussi.
  Future<bool> register(
    String name,
    String email,
    String password, {
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.registerRoute);
      Response response = await client.post(
        url,
        body: json.encode(
          {'name': name, 'email': email, 'password': password},
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _logger.i(responseData);
        _prefs?.setString('user', json.encode(responseData['user']));
        _user = User.fromJson(responseData['user']);
        return true;
      } else {
        _logger.e('Register failed with status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }

  /// Permet de se déconnecter de l'application.
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [bool] qui indique si la déconnexion a réussi.
  Future<bool> logout({
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.logoutRoute);
      Response response = await client.post(
        url,
        body: json.encode({
          'id': _user?.id,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _prefs?.remove('token');
        _prefs?.remove('user');
        _user = null;
        return true;
      } else {
        _logger.e('Logout failed with status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e(e.toString());
      return false;
    }
  }
}
