import 'dart:convert';

import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diagora/models/user_model.dart';

/// Service qui permet de communiquer avec l'API.
/// Ce service est un singleton, pour l'instancier, il faut utiliser la méthode [getInstance].
class ApiService {
  // Attributs généraux
  static SharedPreferences? _prefs;
  static final http.Client _client = http.Client();
  static final Logger _logger = Logger();
  static const ApiService _instance = ApiService();
  static const String _baseUrl = "http://localhost:3000";

  // Constructeur par défaut
  const ApiService();

  // Utilisateur connecté
  static User? _user;
  User? get user => _user;
  static String? _token;

  // Routes - Authentification
  static const String _loginRoute = '/user/login'; // POST
  static const String _registerRoute = '/user/register'; // POST
  static const String _logoutRoute = '/user/logout'; // POST

  // Routes - Utilisateurs
  static const String _usersRoute = '/user'; // GET
  static const String _userRoute = '/user/:id'; // GET, PATCH, DELETE
  static const String _userPermissionsRoute = '/user/permissions/:id'; // GET

  // Routes - Permissions
  static const String _permissionsRoute = '/permissions'; // GET
  static const String _permissionRoute = '/permissions/:id'; // GET, PATCH

  // Routes - Entreprises
  static const String _companiesRoute = '/company'; // GET, POST
  static const String _companyRoute = '/company/:id'; // GET, PATCH, DELETE

  // Routes - Événements
  static const String _userScheduleRoute = '/schedule/:user_id'; // GET, POST
  static const String _scheduleRoute = '/schedule/:id'; // PATCH, DELETE
  static const String _scheduleSlotsRoute =
      '/schedule/avalaibleSlots/:event_id'; // GET

  // Routes - Véhicules
  static const String _vehiclesRoute = '/vehicle'; // GET, POST
  static const String _vehicleRoute = '/vehicle/:id'; // GET, PATCH, DELETE

  // Routes - Itinéraires
  static const String _itinerariesUserRoute =
      '/itinerary/:user_id'; // GET, POST
  static const String _itinerariesRoute = '/itinerary/:id'; // PATCH, DELETE

  /// Permet d'obtenir une instance de [ApiService].
  /// Cette méthode est asynchrone.
  static Future<ApiService> getInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    String? user = _prefs!.getString('user');
    if (user != null) {
      _user = User.fromJson(json.decode(user));
    }
    _token = _prefs!.getString('token');
    return _instance;
  }

  /// Permet de se connecter à l'application.
  ///
  /// Prend en paramètre un [email] et un [password].
  ///
  /// Peut prendre en paramètre un [client] qui est un [http.Client] et un [remember] qui est un [bool].
  ///
  /// Retourne un [bool] qui indique si la connexion a réussi.
  Future<bool> login(
    String email,
    String password, {
    bool remember = false,
    http.Client? client,
  }) async {
    try {
      client ??= _client;
      Uri url = Uri.parse(_baseUrl + _loginRoute);
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
        _prefs?.setString('user', json.encode(responseData['user']));
        _user = User.fromJson(responseData['user']);
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
  /// Peut prendre en paramètre un [client] qui est un [http.Client].
  ///
  /// Retourne un [bool] qui indique si l'inscription a réussi.
  Future<bool> register(
    String name,
    String email,
    String password, {
    http.Client? client,
  }) async {
    try {
      client ??= _client;
      Uri url = Uri.parse(_baseUrl + _registerRoute);
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
        _prefs?.setString('token', responseData['token']);
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
  /// Peut prendre en paramètre un [client] qui est un [http.Client].
  ///
  /// Retourne un [bool] qui indique si la déconnexion a réussi.
  Future<bool> logout({
    http.Client? client,
  }) async {
    try {
      client ??= _client;
      Uri url = Uri.parse(_baseUrl + _logoutRoute);
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
