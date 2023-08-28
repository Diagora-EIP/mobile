import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:diagora/services/performance_client.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diagora/models/user_model.dart';
import 'package:diagora/models/permissions_model.dart';

/// Classe qui contient toutes les routes de l'API. Utilisez [route] pour créer une Uri.
class ApiRoutes {
  static const String baseUrl = 'http://20.111.8.106:3000';
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

  // Calendrier
  static const String calendrierValues = 'user/:user_id/';

  /// Permet de créer l'URL complète d'une route.
  ///
  /// [route] est la route à utiliser.
  static Uri route(String route) => Uri.parse('$baseUrl$route');
}

/// Service qui permet de communiquer avec l'API.
/// Ce service est un singleton, pour l'instancier, il faut utiliser la méthode [getInstance].
class ApiService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Attributs généraux
  bool get isInitialized => _prefs != null;
  static SharedPreferences? _prefs;
  static final Client _httpClient = PerformanceHttpClient();
  static final Logger _logger = Logger();
  static const ApiService _instance = ApiService();

  // Constructeur par défaut
  const ApiService();

  // Informations sur l'utilisateur connecté
  static User? _user;
  User? get user => _user;
  static Permissions? _permissions;
  Permissions? get permissions => _permissions;
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
          {
            'email': email.toLowerCase(),
            'password': password,
            'remember': remember
          },
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _prefs?.setString('token', responseData['token']);
        _token = responseData['token'];
        _prefs?.setString('user', json.encode(responseData['user'][0]));
        _user = User.fromJson(responseData['user'][0]);
        _logger.i(responseData);
        analytics.logLogin(loginMethod: 'email').ignore();
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
          {'email': email.toLowerCase(), 'name': name, 'password': password},
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        _prefs?.setString('user', json.encode(responseData['user']));
        _user = User.fromJson(responseData['user']);
        analytics.logSignUp(signUpMethod: 'email').ignore();
        _logger.i(responseData);
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
      if (_token == null || _token!.isEmpty) return false;
      client ??= _httpClient;
      Uri url = ApiRoutes.route(ApiRoutes.logoutRoute);
      Response response = await client.post(
        url,
        body: json.encode({
          'token': _token,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _prefs?.remove('token');
        _prefs?.remove('user');
        _user = null;
        _permissions = null;
        _token = null;
        _logger.i('Logout successful');
        analytics.logEvent(name: 'logout').ignore();
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

  /// Permet de récupérer les permissions d'un utilisateur.
  ///
  /// Prend en paramètre un [userId] qui est un [int].
  ///
  /// Peut prendre en paramètre un [client] qui est un [Client].
  ///
  /// Retourne un [Permissions] qui est le modèle de données des permissions. Si la requête échoue, retourne null.
  Future<Permissions?> fetchPermissions(
    int userId, {
    Client? client,
  }) async {
    try {
      client ??= _httpClient;
      Uri url = ApiRoutes.route(
          ApiRoutes.permissionRoute.replaceAll(':id', userId.toString()));
      Response response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer Valorant-35"
        },
      );
      if (response.statusCode == 200 || response.statusCode == 202) {
        dynamic responseData = json.decode(response.body);
        _permissions = Permissions.fromJson(responseData);
        _logger.i(responseData);
        return (_permissions);
      } else {
        _logger.e(
            'fetchPermissions failed with status code ${response.statusCode}');
        return (null);
      }
    } catch (e) {
      _logger.e(e.toString());
      return (null);
    }
  }

  /// Takes [DateTime] [begin], [end] as input and returns an output string if the api call succeed.
  ///
  /// The[begin], [end] parameter are required and cannot be null.
  /// The output value will be the shipment date if the call succeed.
  /// If [response.statusCode] is not 200 or 202, this function will return "false".
  Future<String> calendarValues(
    DateTime begin,
    DateTime end,
    int userId, {
    Client? client,
  }) async {
    String beginTimeStamp =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(begin.toUtc());
    String endTimeStamp =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(end.toUtc());
    client ??= _httpClient;

    String id;
    if (userId == -1) {
      id = '31';
    } else {
      id = userId.toString();
    }

    Uri url = ApiRoutes.route(
        "/user/$id/schedule?begin=$beginTimeStamp&end=$endTimeStamp");

    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer Valorant-35"
        },
      );
      if (response.body ==
          "\"failed to parse filter (in.))\" (line 1, column 4)") {
        return ("false");
      }
      if (response.statusCode == 200 || response.statusCode == 202) {
        return (response.body);
      } else {
        return "false";
      }
    } catch (e) {
      return "false";
    }
  }
}
